from __future__ import annotations

from collections import Counter, defaultdict
from datetime import datetime
import logging
from typing import Any

import pandas as pd

from app.data.store import store
from app.utils.cricket_calculations import (
    all_rounder_index,
    batting_impact,
    bowling_impact,
    balls_to_overs,
    clamp,
    parse_overs_to_balls,
    percentage,
    safe_divide,
    team_strength_score,
)


logger = logging.getLogger(__name__)


def _normalize_report_value(value: Any) -> str:
    return " ".join(str(value or "").split()).casefold()


def _bowling_style_group(style: Any) -> str:
    normalized = _normalize_report_value(style)
    if not normalized:
        return "others"
    fast_markers = (
        "fast",
        "medium",
        "pace",
        "seam",
    )
    spinner_markers = (
        "spin",
        "offbreak",
        "off break",
        "legbreak",
        "leg break",
        "orthodox",
        "wrist",
        "chinaman",
    )
    if any(marker in normalized for marker in fast_markers):
        return "fast bowler"
    if any(marker in normalized for marker in spinner_markers):
        return "spinner"
    return "others"


def _bowling_style_matches(style: Any, selection: Any) -> bool:
    selected = _normalize_report_value(selection)
    if not selected or selected in {
        "all",
        "all bowlers",
        "all bowling",
        "all bowling styles",
        "all bowler",
    }:
        return True

    player_code = _bowling_style_code(style)
    normalized_code = _normalize_report_value(player_code)
    fast_codes = {"ramf", "lamf", "ramb", "lamb"}
    spinner_codes = {"rals", "lals", "raos", "laos", "lcm", "rcm", "las"}
    selected_codes = _bowling_selection_codes(selection)

    if selected in {"fast bowler", "fast bowlers"}:
        return normalized_code in fast_codes
    if selected in fast_codes:
        return normalized_code == selected

    if selected in {"spinner", "spinners", "all spinners", "all spinner"}:
        return normalized_code in spinner_codes
    if selected_codes:
        return normalized_code in selected_codes
    if selected in spinner_codes:
        return normalized_code == selected

    if selected == "others":
        return normalized_code == "others"
    return _normalize_report_value(_bowling_style_group(style)) == selected


def _bowling_selection_codes(selection: Any) -> set[str]:
    selected = _normalize_report_value(selection)
    if selected in {"leg spinners", "leg spinner", "leg spin"}:
        return {"rals", "lals"}
    if selected in {"off spinners", "off spinner", "off spin"}:
        return {"raos", "laos"}
    if selected in {"right arm off spin", "right-arm off spin"}:
        return {"raos"}
    if selected in {"right arm leg spin", "right-arm leg spin"}:
        return {"rals"}
    if selected in {"left arm spin", "left-arm spin"}:
        return {"laos", "lals", "las"}
    if selected in {"cm", "china man", "cm (china man)", "chinaman"}:
        return {"lcm", "rcm"}
    return set()


def _bowling_style_code(style: Any) -> str:
    normalized = _normalize_report_value(style)
    if not normalized:
        return "OTHERS"
    if normalized in {"ramf", "lamf", "raos", "las", "rals", "ramb", "lacm", "lamb"}:
        return normalized.upper()

    compact = normalized.replace("-", " ")
    is_left = "left" in compact
    is_right = "right" in compact

    if any(marker in compact for marker in ("offbreak", "off break", "off spin", "offspin")):
        return "LAOS" if is_left else "RAOS"
    if any(marker in compact for marker in ("orthodox",)):
        return "LAOS" if is_left else "RAOS"
    if any(marker in compact for marker in ("legbreak", "leg break", "leg spin", "legspin")):
        return "LALS" if is_left else "RALS"
    if any(marker in compact for marker in ("chinaman", "wrist")):
        return "LCM" if is_left else "RCM"
    if any(marker in compact for marker in ("fast", "pace", "seam", "medium")):
        if "medium" in compact and "fast" not in compact and "pace" not in compact and "seam" not in compact:
            if is_left:
                return "LAMF"
            if is_right:
                return "RAMF"
        if is_left:
            return "LAMF"
        if is_right:
            return "RAMF"
        return "OTHERS"
    if "spin" in compact:
        return "LAOS" if is_left else "RAOS"
    return "OTHERS"


def _format_code_counts(counts: Counter[str]) -> str:
    if not counts:
        return "none"
    return ", ".join(
        f"{code.upper()} ({count})"
        for code, count in sorted(counts.items(), key=lambda item: (-item[1], item[0]))
    )


def _format_style_counts(counts: Counter[str], limit: int = 5) -> str:
    if not counts:
        return "none"
    ordered = sorted(counts.items(), key=lambda item: (-item[1], item[0]))
    visible = ordered[:limit]
    suffix = "" if len(ordered) <= limit else f", +{len(ordered) - limit} more"
    return ", ".join(f"{style} ({count})" for style, count in visible) + suffix


def _is_all_style_filter(style: Any) -> bool:
    normalized = _normalize_report_value(style)
    return normalized in {
        "all",
        "all batting",
        "all batting styles",
        "all batting style",
        "all bowlers",
        "all bowling",
        "all bowling styles",
        "all bowling style",
        "all bowler",
    }


def _report_style_label(style: Any, mode: str) -> str:
    if _is_all_style_filter(style):
        return "All Batting Styles" if mode == "batting" else "All Bowlers"
    return str(style or "").strip()


def _unique_string_ids(values: list[Any] | None) -> list[str]:
    if not values:
        return []
    return list(dict.fromkeys(str(value) for value in values if str(value).strip()))


def _unique_match_ids(rows: list[dict[str, Any]]) -> list[str]:
    match_ids: list[str] = []
    for row in rows:
        row_match_ids = row.get("match_ids")
        if isinstance(row_match_ids, list):
            match_ids.extend(str(match_id) for match_id in row_match_ids if str(match_id).strip())
            continue
        match_id = row.get("match_id")
        if match_id is not None and str(match_id).strip():
            match_ids.append(str(match_id))
    return list(dict.fromkeys(match_ids))


def _matches_played_from_rows(rows: list[dict[str, Any]]) -> int:
    return len(_unique_match_ids(rows))


def _has_batting_contribution(stat_row: dict[str, Any]) -> bool:
    runs = int(stat_row.get("runs", 0) or 0)
    balls = int(stat_row.get("balls", 0) or 0)
    dismissal = str(stat_row.get("dismissal") or "").strip()
    return runs > 0 or balls > 0 or bool(dismissal)


def _has_bowling_contribution(stat_row: dict[str, Any]) -> bool:
    overs_balls = parse_overs_to_balls(float(stat_row.get("overs", 0) or 0))
    maidens = int(stat_row.get("maidens", 0) or 0)
    runs_conceded = int(stat_row.get("runs_conceded", 0) or 0)
    wickets = int(stat_row.get("wickets", 0) or 0)
    dot_balls = int(stat_row.get("dot_balls", 0) or 0)
    return overs_balls > 0 or maidens > 0 or runs_conceded > 0 or wickets > 0 or dot_balls > 0


def _performance_total_row(rows: list[dict[str, Any]], mode: str, label: str, team_id: str | None = None, team_name: str | None = None) -> dict[str, Any]:
    players_count = len(rows)
    matches_played = _matches_played_from_rows(rows)
    if mode == "batting":
        total_runs = int(sum(int(row.get("runs", 0) or 0) for row in rows))
        total_balls = int(sum(int(row.get("balls", 0) or 0) for row in rows))
        total_fours = int(sum(int(row.get("fours", 0) or 0) for row in rows))
        total_sixes = int(sum(int(row.get("sixes", 0) or 0) for row in rows))
        strike_rate = round(percentage(total_runs, total_balls), 2) if total_balls else 0.0
        return {
            "label": label,
            "team_id": team_id,
            "team_name": team_name or label,
            "players_count": players_count,
            "matches_played": matches_played,
            "overs_balls": 0,
            "overs": 0.0,
            "maidens": 0,
            "runs_conceded": 0,
            "wickets": 0,
            "dot_balls": 0,
            "economy": 0.0,
            "runs": total_runs,
            "balls": total_balls,
            "fours": total_fours,
            "sixes": total_sixes,
            "strike_rate": strike_rate,
        }

    total_overs_balls = int(
        sum(
            int(row.get("overs_balls", 0) or parse_overs_to_balls(float(row.get("overs", 0) or 0)))
            for row in rows
        )
    )
    total_overs = balls_to_overs(total_overs_balls)
    total_maidens = int(sum(int(row.get("maidens", 0) or 0) for row in rows))
    total_runs_conceded = int(sum(int(row.get("runs_conceded", 0) or 0) for row in rows))
    total_wickets = int(sum(int(row.get("wickets", 0) or 0) for row in rows))
    total_dot_balls = int(sum(int(row.get("dot_balls", 0) or 0) for row in rows))
    economy = round(total_runs_conceded / (total_overs_balls / 6), 2) if total_overs_balls else 0.0
    return {
        "label": label,
        "team_id": team_id,
        "team_name": team_name or label,
        "players_count": players_count,
        "matches_played": matches_played,
        "overs_balls": total_overs_balls,
        "overs": total_overs,
        "maidens": total_maidens,
        "runs_conceded": total_runs_conceded,
        "wickets": total_wickets,
        "dot_balls": total_dot_balls,
        "economy": economy,
        "runs": 0,
        "balls": 0,
        "fours": 0,
        "sixes": 0,
        "strike_rate": 0.0,
    }


def _team_total_rows(rows: list[dict[str, Any]], mode: str, team_lookup: dict[str, dict[str, Any]], team_ids: list[str] | None = None) -> list[dict[str, Any]]:
    grouped: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for row in rows:
        grouped[str(row.get("team_id"))].append(row)

    if team_ids:
        ordered_team_ids = team_ids
    else:
        ordered_team_ids = sorted(grouped.keys(), key=lambda team_id: str(team_lookup.get(team_id, {}).get("team_name", team_id)))

    totals: list[dict[str, Any]] = []
    for team_id in ordered_team_ids:
        team = team_lookup.get(team_id) or {"team_name": "Unknown team"}
        totals.append(_performance_total_row(grouped.get(team_id, []), mode, str(team.get("team_name", "Unknown team")), team_id=team_id, team_name=team.get("team_name", "Unknown team")))
    return totals


class AnalyticsService:
    def __init__(self, data_store=store):
        self.store = data_store

    def _context(self, context: dict[str, list[dict[str, Any]]] | None, *tables: str) -> dict[str, list[dict[str, Any]]]:
        if context is not None:
            return context
        return self.store.snapshot(tables)

    def _rows(self, context: dict[str, list[dict[str, Any]]], table: str) -> list[dict[str, Any]]:
        return list(context.get(table, []))

    def _teams(self, context: dict[str, list[dict[str, Any]]] | None = None) -> list[dict[str, Any]]:
        return self._rows(self._context(context, "teams"), "teams")

    def _venues(self, context: dict[str, list[dict[str, Any]]] | None = None) -> list[dict[str, Any]]:
        return self._rows(self._context(context, "venues"), "venues")

    def _players(self, context: dict[str, list[dict[str, Any]]] | None = None) -> list[dict[str, Any]]:
        return self._rows(self._context(context, "players"), "players")

    def _matches(self, context: dict[str, list[dict[str, Any]]] | None = None) -> list[dict[str, Any]]:
        return self._rows(self._context(context, "matches"), "matches")

    def _stats(self, context: dict[str, list[dict[str, Any]]] | None = None) -> list[dict[str, Any]]:
        return self._rows(self._context(context, "player_match_stats"), "player_match_stats")

    def _team_lookup(self, context: dict[str, list[dict[str, Any]]] | None = None) -> dict[str, dict[str, Any]]:
        return {str(team.get("id")): team for team in self._teams(context)}

    def _player_lookup(self, context: dict[str, list[dict[str, Any]]] | None = None) -> dict[str, dict[str, Any]]:
        return {str(player.get("id")): player for player in self._players(context)}

    def _venue_lookup(self, context: dict[str, list[dict[str, Any]]] | None = None) -> dict[str, dict[str, Any]]:
        return {str(venue.get("id")): venue for venue in self._venues(context)}

    def _empty_dashboard(self) -> dict[str, Any]:
        return {
            "total_matches": 0,
            "total_teams": 0,
            "total_players": 0,
            "average_first_innings_score": 0.0,
            "total_runs": 0,
            "avg_strike_rate": 0.0,
            "avg_economy": 0.0,
            "fours": 0,
            "sixes": 0,
            "wickets_taken": 0,
            "chase_win_percentage": 0.0,
            "bat_first_win_percentage": 0.0,
            "toss_conversion_percentage": 0.0,
            "highest_score": 0,
            "top_run_scorers": [],
            "top_wicket_takers": [],
            "team_win_percentage_chart": [],
            "venue_score_chart": [],
            "summary_points": [],
        }

    def _empty_team_summary(self, team: dict[str, Any] | None = None) -> dict[str, Any]:
        return {
            "team": team,
            "metrics": {
                "matches_played": 0,
                "wins": 0,
                "losses": 0,
                "win_percentage": 0.0,
                "bat_first_matches": 0,
                "bat_first_wins": 0,
                "bat_first_win_percentage": 0.0,
                "chase_matches": 0,
                "chase_wins": 0,
                "chase_win_percentage": 0.0,
                "toss_wins": 0,
                "wins_after_toss": 0,
                "toss_conversion_percentage": 0.0,
                "average_score_batting_first": 0.0,
                "average_score_chasing": 0.0,
                "total_runs": 0,
                "avg_strike_rate": 0.0,
                "avg_economy": 0.0,
                "fours": 0,
                "sixes": 0,
                "wickets_taken": 0,
                "form_index": 0.0,
                "team_strength_score": 0.0,
            },
            "insights": ["Analytics temporarily unavailable."],
            "recent_matches": [],
            "head_to_head_summary": [],
        }

    def _empty_player_summary(self, player: dict[str, Any] | None = None) -> dict[str, Any]:
        return {
            "player": player,
            "batting": {},
            "bowling": {},
            "impact": {},
            "insights": ["Analytics temporarily unavailable."],
        }

    def _empty_venue_summary(self, venue: dict[str, Any] | None = None) -> dict[str, Any]:
        return {"venue": venue, "metrics": {}, "insights": ["Analytics temporarily unavailable."]}

    def _empty_toss_summary(self) -> dict[str, Any]:
        return {
            "overall": {
                "toss_winner_match_win_percentage": 0.0,
                "bat_decision_success_percentage": 0.0,
                "bowl_decision_success_percentage": 0.0,
            },
            "team_wise": [],
            "insights": ["Analytics temporarily unavailable."],
        }

    def _empty_head_to_head(self, team_a_id: str, team_b_id: str) -> dict[str, Any]:
        return {
            "team_a": {"id": team_a_id, "team_name": "Unknown team"},
            "team_b": {"id": team_b_id, "team_name": "Unknown team"},
            "metrics": {
                "matches_played": 0,
                "team_a_wins": 0,
                "team_b_wins": 0,
                "team_a_win_percentage": 0.0,
                "team_b_win_percentage": 0.0,
                "average_first_innings_score": 0.0,
            },
            "recent_matches": [],
            "insights": ["Analytics temporarily unavailable."],
        }

    def _overs_total(self, overs_values: pd.Series) -> tuple[float, int]:
        balls = sum(parse_overs_to_balls(float(overs or 0)) for overs in overs_values.fillna(0).tolist())
        return balls_to_overs(int(balls)), int(balls)

    def _matches_df(self) -> pd.DataFrame:
        matches = self._matches()
        return pd.DataFrame(matches) if matches else pd.DataFrame(columns=["id"])

    def _stats_df(self) -> pd.DataFrame:
        stats = self._stats()
        return pd.DataFrame(stats) if stats else pd.DataFrame(columns=["id"])

    def dashboard_summary(self, context: dict[str, list[dict[str, Any]]] | None = None) -> dict[str, Any]:
        context = self._context(context, "teams", "venues", "players", "matches", "player_match_stats")
        matches = self._matches(context)
        teams = self._teams(context)
        players = self._players(context)
        stats_rows = self._stats(context)
        stats_df = pd.DataFrame(stats_rows) if stats_rows else pd.DataFrame(columns=["id"])
        matches_df = pd.DataFrame(matches) if matches else pd.DataFrame(columns=["id"])
        response = self._empty_dashboard()
        warnings: list[str] = []
        player_lookup: dict[str, dict[str, Any]] = {}

        try:
            total_runs = int(stats_df["runs"].sum()) if not stats_df.empty else 0
            total_balls = int(stats_df["balls"].sum()) if not stats_df.empty else 0
            _overs_display, total_bowler_balls = self._overs_total(stats_df["overs"]) if not stats_df.empty and "overs" in stats_df else (0.0, 0)
            total_runs_conceded = int(stats_df["runs_conceded"].sum()) if not stats_df.empty else 0
            total_fours = int(stats_df["fours"].sum()) if not stats_df.empty else 0
            total_sixes = int(stats_df["sixes"].sum()) if not stats_df.empty else 0
            total_wickets = int(stats_df["wickets"].sum()) if not stats_df.empty else 0
            average_first_innings_score = round(matches_df["first_innings_score"].mean(), 2) if not matches_df.empty else 0.0
            chase_wins = [m for m in matches if m.get("winner_id") and str(m.get("winner_id")) != str(m.get("bat_first_team_id"))]
            chase_win_percentage = round(percentage(len(chase_wins), len(matches)), 2) if matches else 0.0
            bat_first_wins = [
                m
                for m in matches
                if m.get("winner_id") and m.get("bat_first_team_id") and str(m["winner_id"]) == str(m["bat_first_team_id"])
            ]
            bat_first_total = [m for m in matches if m.get("bat_first_team_id")]
            bat_first_win_percentage = round(percentage(len(bat_first_wins), len(bat_first_total)), 2) if bat_first_total else 0.0
            toss_wins = [m for m in matches if m.get("toss_winner_id")]
            toss_conversion_wins = [m for m in matches if m.get("toss_winner_id") and m.get("winner_id") == m.get("toss_winner_id")]
            toss_conversion_percentage = round(percentage(len(toss_conversion_wins), len(toss_wins)), 2) if toss_wins else 0.0
            highest_score = int(matches_df["first_innings_score"].max()) if not matches_df.empty else 0
            response.update(
                {
                    "total_matches": len(matches),
                    "total_teams": len(teams),
                    "total_players": len(players),
                    "average_first_innings_score": average_first_innings_score,
                    "total_runs": total_runs,
                    "avg_strike_rate": round(percentage(total_runs, total_balls), 2) if total_balls else 0.0,
                    "avg_economy": round(total_runs_conceded / (total_bowler_balls / 6), 2) if total_bowler_balls else 0.0,
                    "fours": total_fours,
                    "sixes": total_sixes,
                    "wickets_taken": total_wickets,
                    "chase_win_percentage": chase_win_percentage,
                    "bat_first_win_percentage": bat_first_win_percentage,
                    "toss_conversion_percentage": toss_conversion_percentage,
                    "highest_score": highest_score,
                }
            )
            response["summary_points"] = [
                f"{len(matches)} completed matches analysed across {len(teams)} teams.",
                f"Average first innings score sits at {average_first_innings_score:.1f}.",
                f"Toss winners converted into victories {toss_conversion_percentage:.1f}% of the time.",
            ]
        except Exception:
            logger.exception("Failed to compute dashboard totals from tables: matches, player_match_stats.")
            warnings.append("Some dashboard totals are unavailable.")

        try:
            player_lookup = self._player_lookup(context)
            team_win_percentage_chart = []
            for team in teams:
                try:
                    team_summary = self.team_summary(str(team.get("id")), context=context)
                    team_win_percentage_chart.append(
                        {"team_id": team.get("id"), "team_name": team.get("team_name"), **team_summary["metrics"]}
                    )
                except Exception:
                    logger.exception("Failed to build dashboard team row for team '%s'.", team.get("id"))
                    warnings.append(f"Team chart row unavailable for {team.get('team_name', 'unknown team')}.")
            response["team_win_percentage_chart"] = team_win_percentage_chart
        except Exception:
            logger.exception("Failed to build dashboard team chart using table 'teams'.")
            warnings.append("Team chart is unavailable.")

        try:
            venue_score_chart = []
            for venue in self._venues(context):
                try:
                    venue_summary = self.venue_summary(str(venue.get("id")), context=context)
                    venue_score_chart.append(
                        {"venue_id": venue.get("id"), "venue_name": venue.get("venue_name"), **venue_summary["metrics"]}
                    )
                except Exception:
                    logger.exception("Failed to build dashboard venue row for venue '%s'.", venue.get("id"))
                    warnings.append(f"Venue chart row unavailable for {venue.get('venue_name', 'unknown venue')}.")
            response["venue_score_chart"] = venue_score_chart
        except Exception:
            logger.exception("Failed to build dashboard venue chart using table 'venues'.")
            warnings.append("Venue chart is unavailable.")

        try:
            top_run_scorers = []
            top_wicket_takers = []
            top_four_hitters = []
            top_six_hitters = []
            top_dot_ball_bowlers = []
            if not stats_df.empty:
                runs_table = stats_df.groupby("player_id", as_index=False)["runs"].sum().sort_values("runs", ascending=False).head(5)
                wickets_table = stats_df.groupby("player_id", as_index=False)["wickets"].sum().sort_values("wickets", ascending=False).head(5)
                fours_table = stats_df.groupby("player_id", as_index=False)["fours"].sum().sort_values("fours", ascending=False).head(5)
                sixes_table = stats_df.groupby("player_id", as_index=False)["sixes"].sum().sort_values("sixes", ascending=False).head(5)
                dot_balls_table = stats_df.groupby("player_id", as_index=False)["dot_balls"].sum().sort_values("dot_balls", ascending=False).head(5)
                top_run_scorers = [
                    {
                        "player_id": str(row["player_id"]),
                        "player_name": player_lookup.get(str(row["player_id"]), {}).get("player_name", "Unknown"),
                        "runs": int(row["runs"]),
                    }
                    for _, row in runs_table.iterrows()
                ]
                top_wicket_takers = [
                    {
                        "player_id": str(row["player_id"]),
                        "player_name": player_lookup.get(str(row["player_id"]), {}).get("player_name", "Unknown"),
                        "wickets": int(row["wickets"]),
                    }
                    for _, row in wickets_table.iterrows()
                ]
                top_four_hitters = [
                    {
                        "player_id": str(row["player_id"]),
                        "player_name": player_lookup.get(str(row["player_id"]), {}).get("player_name", "Unknown"),
                        "fours": int(row["fours"]),
                    }
                    for _, row in fours_table.iterrows()
                ]
                top_six_hitters = [
                    {
                        "player_id": str(row["player_id"]),
                        "player_name": player_lookup.get(str(row["player_id"]), {}).get("player_name", "Unknown"),
                        "sixes": int(row["sixes"]),
                    }
                    for _, row in sixes_table.iterrows()
                ]
                top_dot_ball_bowlers = [
                    {
                        "player_id": str(row["player_id"]),
                        "player_name": player_lookup.get(str(row["player_id"]), {}).get("player_name", "Unknown"),
                        "dot_balls": int(row["dot_balls"]),
                    }
                    for _, row in dot_balls_table.iterrows()
                ]
            response["top_run_scorers"] = top_run_scorers
            response["top_wicket_takers"] = top_wicket_takers
            response["top_four_hitters"] = top_four_hitters
            response["top_six_hitters"] = top_six_hitters
            response["top_dot_ball_bowlers"] = top_dot_ball_bowlers
        except Exception:
            logger.exception("Failed to build top performer lists using table 'player_match_stats'.")
            warnings.append("Top performer lists are unavailable.")

        if warnings:
            response["warnings"] = warnings
        return response

    def standings(self, context: dict[str, list[dict[str, Any]]] | None = None) -> list[dict[str, Any]]:
        context = self._context(context, "teams", "matches")
        try:
            matches = self._matches(context)
            standings_rows: list[dict[str, Any]] = []

            for team in self._teams(context):
                team_id = str(team.get("id"))
                team_matches = [m for m in matches if str(m.get("team_a_id")) == team_id or str(m.get("team_b_id")) == team_id]
                wins = [m for m in team_matches if str(m.get("winner_id")) == team_id]
                losses = [m for m in team_matches if m.get("winner_id") and str(m.get("winner_id")) != team_id]
                runs_for = 0.0
                runs_against = 0.0
                overs_for_balls = 0
                overs_against_balls = 0
                for match in team_matches:
                    if str(match.get("bat_first_team_id")) == team_id:
                        runs_for += float(match.get("first_innings_score") or 0)
                        overs_for_balls += parse_overs_to_balls(float(match.get("first_innings_overs") or 0))
                        runs_against += float(match.get("second_innings_score") or 0)
                        overs_against_balls += parse_overs_to_balls(float(match.get("second_innings_overs") or 0))
                    else:
                        runs_for += float(match.get("second_innings_score") or 0)
                        overs_for_balls += parse_overs_to_balls(float(match.get("second_innings_overs") or 0))
                        runs_against += float(match.get("first_innings_score") or 0)
                        overs_against_balls += parse_overs_to_balls(float(match.get("first_innings_overs") or 0))
                run_rate_for = safe_divide(runs_for * 6, overs_for_balls, 0.0)
                run_rate_against = safe_divide(runs_against * 6, overs_against_balls, 0.0)
                nrr = round(run_rate_for - run_rate_against, 4)
                standings_rows.append(
                    {
                        "team_id": team_id,
                        "team_name": team.get("team_name"),
                        "played": len(team_matches),
                        "wins": len(wins),
                        "losses": len(losses),
                        "points": len(wins) * 2,
                        "nrr": f"{nrr:.4f}",
                    }
                )
            standings_rows.sort(key=lambda row: (row["points"], float(row["nrr"])), reverse=True)
            return standings_rows
        except Exception:
            logger.exception("Failed to build standings using tables: teams, matches.")
            return []

    def team_summary(self, team_id: str, context: dict[str, list[dict[str, Any]]] | None = None) -> dict[str, Any]:
        context = self._context(context, "teams", "matches", "player_match_stats")
        try:
            team_lookup = self._team_lookup(context)
            team = team_lookup.get(str(team_id)) or self.store.get("teams", team_id)
            if not team:
                return self._empty_team_summary(None)

            matches = [m for m in self._matches(context) if str(m.get("team_a_id")) == team_id or str(m.get("team_b_id")) == team_id]
            team_stats = [row for row in self._stats(context) if str(row.get("team_id")) == team_id]
            team_stats_df = pd.DataFrame(team_stats) if team_stats else pd.DataFrame(columns=["id"])
            if not matches:
                empty = self._empty_team_summary(team)
                empty["insights"] = ["No matches available for this team yet."]
                return empty

            wins = [m for m in matches if str(m.get("winner_id")) == team_id]
            losses = [m for m in matches if str(m.get("loser_id")) == team_id]
            bat_first_matches = [m for m in matches if str(m.get("bat_first_team_id")) == team_id]
            chase_matches = [m for m in matches if str(m.get("bat_first_team_id")) != team_id]
            bat_first_wins = [m for m in bat_first_matches if str(m.get("winner_id")) == team_id]
            chase_wins = [m for m in chase_matches if str(m.get("winner_id")) == team_id]
            toss_wins = [m for m in matches if str(m.get("toss_winner_id")) == team_id]
            wins_after_toss = [m for m in matches if str(m.get("toss_winner_id")) == team_id and str(m.get("winner_id")) == team_id]
            scores_batting_first = [m.get("first_innings_score", 0) for m in bat_first_matches if m.get("first_innings_score") is not None]
            scores_chasing = [m.get("second_innings_score", 0) for m in chase_matches if m.get("second_innings_score") is not None]
            recent_matches = sorted(
                matches,
                key=lambda item: (int(item.get("match_number") or 0), str(item.get("match_date") or "")),
                reverse=True,
            )
            total_runs = int(team_stats_df["runs"].sum()) if not team_stats_df.empty and "runs" in team_stats_df else 0
            total_balls = int(team_stats_df["balls"].sum()) if not team_stats_df.empty and "balls" in team_stats_df else 0
            _overs_display, total_bowler_balls = self._overs_total(team_stats_df["overs"]) if not team_stats_df.empty and "overs" in team_stats_df else (0.0, 0)
            total_runs_conceded = int(team_stats_df["runs_conceded"].sum()) if not team_stats_df.empty and "runs_conceded" in team_stats_df else 0
            total_fours = int(team_stats_df["fours"].sum()) if not team_stats_df.empty and "fours" in team_stats_df else 0
            total_sixes = int(team_stats_df["sixes"].sum()) if not team_stats_df.empty and "sixes" in team_stats_df else 0
            total_wickets = int(team_stats_df["wickets"].sum()) if not team_stats_df.empty and "wickets" in team_stats_df else 0
            recent_form_index = self._recent_form_index(team_id, context=context)
            batting_strength = clamp((percentage(len(bat_first_wins), len(bat_first_matches)) + percentage(len(chase_wins), len(chase_matches))) / 2)
            bowling_strength = clamp((percentage(len(wins_after_toss), len(toss_wins)) + percentage(len(wins), len(matches))) / 2)

            metrics = {
                "matches_played": len(matches),
                "wins": len(wins),
                "losses": len(losses),
                "win_percentage": round(percentage(len(wins), len(matches)), 2),
                "bat_first_matches": len(bat_first_matches),
                "bat_first_wins": len(bat_first_wins),
                "bat_first_win_percentage": round(percentage(len(bat_first_wins), len(bat_first_matches)), 2),
                "chase_matches": len(chase_matches),
                "chase_wins": len(chase_wins),
                "chase_win_percentage": round(percentage(len(chase_wins), len(chase_matches)), 2),
                "toss_wins": len(toss_wins),
                "wins_after_toss": len(wins_after_toss),
                "toss_conversion_percentage": round(percentage(len(wins_after_toss), len(toss_wins)), 2),
                "average_score_batting_first": round(sum(scores_batting_first) / len(scores_batting_first), 2) if scores_batting_first else 0.0,
                "average_score_chasing": round(sum(scores_chasing) / len(scores_chasing), 2) if scores_chasing else 0.0,
                "total_runs": total_runs,
                "avg_strike_rate": round(percentage(total_runs, total_balls), 2) if total_balls else 0.0,
                "avg_economy": round(total_runs_conceded / (total_bowler_balls / 6), 2) if total_bowler_balls else 0.0,
                "fours": total_fours,
                "sixes": total_sixes,
                "wickets_taken": total_wickets,
                "form_index": round(recent_form_index, 2),
                "team_strength_score": round(
                    team_strength_score(
                        percentage(len(wins), len(matches)),
                        recent_form_index,
                        batting_strength,
                        bowling_strength,
                    ),
                    2,
                ),
            }
            head_to_head_summary = []
            for opponent in self._teams(context):
                if str(opponent.get("id")) == team_id:
                    continue
                try:
                    summary = self.head_to_head(team_id, str(opponent.get("id")), context=context)
                    if summary["metrics"]["matches_played"]:
                        head_to_head_summary.append(summary["metrics"])
                except Exception:
                    logger.exception("Failed to build head-to-head row for team '%s' against '%s'.", team_id, opponent.get("id"))
            insights = self._team_insights_from_metrics(team, metrics)
            return {
                "team": team,
                "metrics": metrics,
                "insights": insights,
                "recent_matches": recent_matches,
                "head_to_head_summary": head_to_head_summary[:5],
            }
        except Exception:
            logger.exception("Failed to build team analytics using tables: teams, matches, player_match_stats.")
            team = self.store.get("teams", team_id)
            return self._empty_team_summary(team)

    def player_summary(self, player_id: str, context: dict[str, list[dict[str, Any]]] | None = None) -> dict[str, Any]:
        context = self._context(context, "players", "player_match_stats")
        try:
            player_lookup = self._player_lookup(context)
            player = player_lookup.get(str(player_id)) or self.store.get("players", player_id)
            if not player:
                return self._empty_player_summary(None)

            stats = [row for row in self._stats(context) if str(row.get("player_id")) == player_id]
            stats_df = pd.DataFrame(stats) if stats else pd.DataFrame()
            overs_balls = 0
            if stats_df.empty:
                batting = {
                    "total_runs": 0,
                    "total_balls": 0,
                    "batting_strike_rate": 0.0,
                    "average_runs_per_match": 0.0,
                    "fours": 0,
                    "sixes": 0,
                    "boundary_percentage": 0.0,
                    "finishing_score": 0.0,
                }
                bowling = {
                    "overs": 0.0,
                    "wickets": 0,
                    "economy": 0.0,
                    "runs_conceded": 0,
                    "dot_balls": 0,
                    "dot_ball_percentage": 0.0,
                    "bowling_strike_impact": 0.0,
                    "pressure_bowling_score": 0.0,
                }
            else:
                total_runs = int(stats_df["runs"].sum()) if "runs" in stats_df else 0
                total_balls = int(stats_df["balls"].sum()) if "balls" in stats_df else 0
                total_matches = max(len(stats_df), 1)
                fours = int(stats_df["fours"].sum()) if "fours" in stats_df else 0
                sixes = int(stats_df["sixes"].sum()) if "sixes" in stats_df else 0
                overs, overs_balls = self._overs_total(stats_df["overs"]) if "overs" in stats_df else (0.0, 0)
                wickets = int(stats_df["wickets"].sum()) if "wickets" in stats_df else 0
                dot_balls = int(stats_df["dot_balls"].sum()) if "dot_balls" in stats_df else 0
                runs_conceded = float(stats_df["runs_conceded"].sum()) if "runs_conceded" in stats_df else 0.0
                batting_strike_rate = round(percentage(total_runs, total_balls), 2) if total_balls else 0.0
                batting = {
                    "total_runs": total_runs,
                    "total_balls": total_balls,
                    "batting_strike_rate": round((total_runs / total_balls) * 100, 2) if total_balls else 0.0,
                    "average_runs_per_match": round(total_runs / total_matches, 2),
                    "fours": fours,
                    "sixes": sixes,
                    "boundary_percentage": round(percentage(fours + sixes, total_balls), 2) if total_balls else 0.0,
                    "finishing_score": round(batting_impact(total_runs, batting_strike_rate, fours, sixes), 2),
                }
                bowling = {
                    "overs": overs,
                    "wickets": wickets,
                    "economy": round(runs_conceded / overs, 2) if overs else 0.0,
                    "runs_conceded": int(runs_conceded),
                    "dot_balls": dot_balls,
                    "dot_ball_percentage": round(percentage(dot_balls, overs_balls), 2) if overs_balls else 0.0,
                    "bowling_strike_impact": round((wickets * 25) + (dot_balls * 1.25), 2),
                    "pressure_bowling_score": round(bowling_impact(wickets, dot_balls, round(runs_conceded / overs, 2) if overs else 0.0), 2),
                }

            impact = {
                "batting_impact": round(
                    batting_impact(batting.get("total_runs", 0), batting.get("batting_strike_rate", 0.0), batting.get("fours", 0), batting.get("sixes", 0)),
                    2,
                ),
                "bowling_impact": round(
                    bowling_impact(
                        bowling.get("wickets", 0),
                        int((bowling.get("dot_ball_percentage", 0) / 100) * overs_balls) if overs_balls else 0,
                        bowling.get("economy", 0.0),
                    ),
                    2,
                ),
            }
            impact["all_rounder_index"] = round(all_rounder_index(impact["batting_impact"], impact["bowling_impact"]), 2)
            insights = self._player_insights_from_metrics(player, batting, bowling, impact)
            return {"player": player, "batting": batting, "bowling": bowling, "impact": impact, "insights": insights}
        except Exception:
            logger.exception("Failed to build player analytics using tables: players, player_match_stats.")
            player = self.store.get("players", player_id)
            return self._empty_player_summary(player)

    def player_performance_report(
        self,
        mode: str,
        style: str,
        venue_id: str | None = None,
        include_venue: bool = False,
        team_ids: list[str] | None = None,
        context: dict[str, list[dict[str, Any]]] | None = None,
    ) -> dict[str, Any]:
        context = self._context(context, "teams", "venues", "matches", "players", "player_match_stats")
        mode = (mode or "").strip().lower()
        style_key = _normalize_report_value(style)
        all_style = _is_all_style_filter(style)
        selected_team_ids = _unique_string_ids(team_ids)
        if mode not in {"batting", "bowling"} or (not style_key and not all_style):
            return {
                "report_title": "Player Performance Report",
                "filters": {"mode": mode, "style": style, "use_venue_filter": include_venue, "venue_id": venue_id, "team_ids": selected_team_ids or None},
                "summary": ["No valid filters were provided."],
                "rows": [],
                "team_totals": [],
                "overall_total": None,
            }

        player_lookup = self._player_lookup(context)
        team_lookup = self._team_lookup(context)
        venue_lookup = self._venue_lookup(context)
        match_lookup = {str(match.get("id")): match for match in self._matches(context)}
        venue_match_count = 0
        if include_venue and venue_id:
            venue_match_count = len(
                {
                    str(match.get("id"))
                    for match in self._matches(context)
                    if str(match.get("venue_id")) == str(venue_id)
                }
            )

        selected_venue = None
        if include_venue:
            selected_venue = venue_lookup.get(str(venue_id)) if venue_id else None
            if venue_id and not selected_venue:
                return {
                    "report_title": "Player Performance Report",
                    "filters": {"mode": mode, "style": style, "use_venue_filter": include_venue, "venue_id": venue_id, "team_ids": selected_team_ids or None},
                    "summary": ["Selected venue could not be found."],
                    "rows": [],
                    "team_totals": [],
                    "overall_total": None,
                }

        filtered_rows: list[dict[str, Any]] = []
        included_match_ids: set[str] = set()
        available_bowling_player_ids: set[str] = set()
        available_bowling_codes: Counter[str] = Counter()
        available_bowling_styles: Counter[str] = Counter()
        for stat_row in self._stats(context):
            player = player_lookup.get(str(stat_row.get("player_id")))
            if not player:
                continue
            if selected_team_ids and str(player.get("team_id")) not in selected_team_ids:
                continue
            match = match_lookup.get(str(stat_row.get("match_id")))
            if not match:
                continue
            if include_venue and venue_id and str(match.get("venue_id")) != str(venue_id):
                continue
            if mode == "batting" and not _has_batting_contribution(stat_row):
                continue
            if mode == "bowling" and not _has_bowling_contribution(stat_row):
                continue
            if mode == "batting" and not all_style:
                player_style = player.get("batting_style")
                if _normalize_report_value(player_style) != style_key:
                    continue
            elif mode == "bowling":
                player_id = str(player.get("id"))
                if player_id not in available_bowling_player_ids:
                    available_bowling_player_ids.add(player_id)
                    available_bowling_codes[_normalize_report_value(_bowling_style_code(player.get("bowling_style")))] += 1
                    available_bowling_styles[" ".join(str(player.get("bowling_style") or "Unknown").split())] += 1
                if not all_style and not _bowling_style_matches(player.get("bowling_style"), style):
                    continue
            included_match_ids.add(str(match.get("id")))

            team = team_lookup.get(str(player.get("team_id"))) or {"id": player.get("team_id"), "team_name": "Unknown team"}
            venue = venue_lookup.get(str(match.get("venue_id"))) or {"venue_name": "Unknown venue"}
            opponent_id = None
            if str(match.get("team_a_id")) == str(player.get("team_id")):
                opponent_id = str(match.get("team_b_id"))
            elif str(match.get("team_b_id")) == str(player.get("team_id")):
                opponent_id = str(match.get("team_a_id"))
            opponent_name = team_lookup.get(opponent_id, {}).get("team_name", "Unknown team") if opponent_id else "Unknown team"

            if mode == "batting":
                runs = int(stat_row.get("runs", 0) or 0)
                balls = int(stat_row.get("balls", 0) or 0)
                fours = int(stat_row.get("fours", 0) or 0)
                sixes = int(stat_row.get("sixes", 0) or 0)
                strike_rate = float(stat_row.get("strike_rate", 0) or 0)
                score = round(batting_impact(runs, strike_rate, fours, sixes), 2)
                entry = {
                    "player_id": str(player.get("id")),
                    "player_name": player.get("player_name", "Unknown"),
                    "team_id": str(team.get("id")),
                    "team_name": team.get("team_name", "Unknown team"),
                    "batting_style": player.get("batting_style"),
                    "bowling_style": player.get("bowling_style"),
                    "bowling_style_code": _bowling_style_code(player.get("bowling_style")),
                    "match_id": str(match.get("id")),
                    "match_number": int(match.get("match_number") or 0),
                    "match_date": match.get("match_date"),
                    "venue_name": venue.get("venue_name", "Unknown venue"),
                    "opponent_team_name": opponent_name,
                    "runs": runs,
                    "balls": balls,
                    "fours": fours,
                    "sixes": sixes,
                    "strike_rate": round((runs / balls) * 100, 2) if balls else 0.0,
                    "score": score,
                    "runs_conceded": 0,
                    "overs_balls": 0,
                    "maidens": 0,
                    "wickets": 0,
                    "dot_balls": 0,
                    "economy": 0.0,
                }
            else:
                overs_value = float(stat_row.get("overs", 0) or 0)
                overs_balls = parse_overs_to_balls(overs_value)
                overs = balls_to_overs(overs_balls)
                runs_conceded = int(stat_row.get("runs_conceded", 0) or 0)
                wickets = int(stat_row.get("wickets", 0) or 0)
                dot_balls = int(stat_row.get("dot_balls", 0) or 0)
                maidens = int(stat_row.get("maidens", 0) or 0)
                economy = float(stat_row.get("economy", 0) or 0)
                if not economy and overs:
                    economy = round(runs_conceded / overs, 2)
                score = round(bowling_impact(wickets, dot_balls, economy), 2)
                entry = {
                    "player_id": str(player.get("id")),
                    "player_name": player.get("player_name", "Unknown"),
                    "team_id": str(team.get("id")),
                    "team_name": team.get("team_name", "Unknown team"),
                    "batting_style": player.get("batting_style"),
                    "bowling_style": player.get("bowling_style"),
                    "match_id": str(match.get("id")),
                    "match_number": int(match.get("match_number") or 0),
                    "match_date": match.get("match_date"),
                    "venue_name": venue.get("venue_name", "Unknown venue"),
                    "opponent_team_name": opponent_name,
                    "runs": 0,
                    "balls": 0,
                    "fours": 0,
                    "sixes": 0,
                    "strike_rate": 0.0,
                    "score": score,
                    "runs_conceded": runs_conceded,
                    "overs_balls": overs_balls,
                    "maidens": maidens,
                    "wickets": wickets,
                    "dot_balls": dot_balls,
                    "economy": economy,
                }

            filtered_rows.append(entry)

        grouped: dict[str, list[dict[str, Any]]] = defaultdict(list)
        for row in filtered_rows:
            grouped[row["player_id"]].append(row)

        report_rows: list[dict[str, Any]] = []
        for player_id, rows in grouped.items():
            player = player_lookup.get(player_id)
            if not player:
                continue
            team = team_lookup.get(str(player.get("team_id"))) or {"id": player.get("team_id"), "team_name": "Unknown team"}
            ordered_rows = sorted(rows, key=lambda item: (float(item["score"]), str(item["match_date"] or ""), int(item["match_number"] or 0)), reverse=True)
            best_match_row = ordered_rows[0]
            match_ids = {str(row["match_id"]) for row in rows}
            unique_match_ids = sorted(match_ids)

            if mode == "batting":
                total_runs = int(sum(row["runs"] for row in rows))
                total_balls = int(sum(row["balls"] for row in rows))
                total_fours = int(sum(row["fours"] for row in rows))
                total_sixes = int(sum(row["sixes"] for row in rows))
                best_match = {
                    "match_id": best_match_row["match_id"],
                    "match_number": best_match_row["match_number"],
                    "match_date": best_match_row["match_date"],
                    "venue_name": best_match_row["venue_name"],
                    "opponent_team_name": best_match_row["opponent_team_name"],
                    "score": best_match_row["score"],
                }
                report_rows.append(
                    {
                        "player_id": player_id,
                        "player_name": player.get("player_name", "Unknown"),
                        "team_id": str(team.get("id")),
                        "team_name": team.get("team_name", "Unknown team"),
                        "batting_style": player.get("batting_style"),
                        "bowling_style": player.get("bowling_style"),
                        "bowling_style_code": _bowling_style_code(player.get("bowling_style")),
                        "matches_played": len(match_ids),
                        "match_ids": unique_match_ids,
                        "overs_balls": 0,
                        "overs": 0.0,
                        "maidens": 0,
                        "runs_conceded": 0,
                        "wickets": 0,
                        "dot_balls": 0,
                        "economy": 0.0,
                        "runs": total_runs,
                        "balls": total_balls,
                        "fours": total_fours,
                        "sixes": total_sixes,
                        "strike_rate": round((total_runs / total_balls) * 100, 2) if total_balls else 0.0,
                        "best_match": best_match,
                        "best_score": best_match_row["score"],
                    }
                )
            else:
                total_overs_balls = int(sum(row["overs_balls"] for row in rows))
                total_overs = balls_to_overs(total_overs_balls)
                total_runs_conceded = int(sum(row["runs_conceded"] for row in rows))
                total_maidens = int(sum(row["maidens"] for row in rows))
                total_wickets = int(sum(row["wickets"] for row in rows))
                total_dot_balls = int(sum(row["dot_balls"] for row in rows))
                economy = round(total_runs_conceded / (total_overs_balls / 6), 2) if total_overs_balls else 0.0
                best_match = {
                    "match_id": best_match_row["match_id"],
                    "match_number": best_match_row["match_number"],
                    "match_date": best_match_row["match_date"],
                    "venue_name": best_match_row["venue_name"],
                    "opponent_team_name": best_match_row["opponent_team_name"],
                    "score": best_match_row["score"],
                }
                report_rows.append(
                    {
                        "player_id": player_id,
                        "player_name": player.get("player_name", "Unknown"),
                        "team_id": str(team.get("id")),
                        "team_name": team.get("team_name", "Unknown team"),
                        "batting_style": player.get("batting_style"),
                        "bowling_style": player.get("bowling_style"),
                        "bowling_style_code": _bowling_style_code(player.get("bowling_style")),
                        "matches_played": len(match_ids),
                        "match_ids": unique_match_ids,
                        "overs_balls": total_overs_balls,
                        "overs": total_overs,
                        "maidens": total_maidens,
                        "runs_conceded": total_runs_conceded,
                        "wickets": total_wickets,
                        "dot_balls": total_dot_balls,
                        "economy": economy,
                        "runs": 0,
                        "balls": 0,
                        "fours": 0,
                        "sixes": 0,
                        "strike_rate": 0.0,
                        "best_match": best_match,
                        "best_score": best_match_row["score"],
                    }
                )

        report_rows.sort(key=lambda row: (float(row["best_score"]), int(row["matches_played"]), row["player_name"]), reverse=True)

        team_totals = _team_total_rows(report_rows, mode, team_lookup, selected_team_ids or None)
        overall_total = _performance_total_row(report_rows, mode, "Overall Total")
        if selected_team_ids:
            overall_total["matches_played"] = len(included_match_ids)
        elif include_venue and venue_match_count:
            overall_total["matches_played"] = venue_match_count
        elif included_match_ids:
            overall_total["matches_played"] = len(included_match_ids)

        if include_venue and selected_venue:
            venue_name = selected_venue.get("venue_name", "Selected venue")
            venue_label = f" at {venue_name}"
        else:
            venue_label = ""

        report_style = _report_style_label(style, mode)
        team_filter_label = ", ".join(
            team_lookup.get(team_id, {}).get("team_name", "Unknown team") for team_id in selected_team_ids
        )
        report_title = f"{report_style} {mode.title()} Performance Report{venue_label}"
        summary = [
            f"{len(report_rows)} players matched the selected {mode} style." if not all_style else f"{len(report_rows)} players matched all {mode} styles.",
            f"{'Venue filter applied to ' + selected_venue.get('venue_name', 'the selected venue') if selected_venue else 'No venue filter was applied.'}",
            f"{'Teams filtered to ' + team_filter_label if selected_team_ids else 'No team filter was applied.'}",
            "Names are returned from the canonical player, team, and venue tables.",
        ]
        if mode == "bowling" and not all_style and not report_rows:
            selected_codes = _bowling_selection_codes(style)
            if selected_codes:
                summary.append(
                    "Diagnostic: "
                    + f"'{style}' maps to bowling style codes {', '.join(sorted(code.upper() for code in selected_codes))}."
                )
            summary.append(
                "Diagnostic: "
                + f"{len(available_bowling_player_ids)} bowling players remained after venue/team filters. "
                + f"Available codes: {_format_code_counts(available_bowling_codes)}."
            )
            summary.append(
                "Observed bowling_style values after filters: "
                + f"{_format_style_counts(available_bowling_styles)}."
            )
        return {
            "report_title": report_title,
            "filters": {
                "mode": mode,
                "style": style,
                "use_venue_filter": include_venue,
                "venue_id": venue_id,
                "venue_name": selected_venue.get("venue_name") if selected_venue else None,
                "team_ids": selected_team_ids or None,
                "team_names": [team_lookup.get(team_id, {}).get("team_name", "Unknown team") for team_id in selected_team_ids] if selected_team_ids else None,
            },
            "summary": summary,
            "rows": report_rows,
            "team_totals": team_totals,
            "overall_total": overall_total,
        }

    def venue_summary(self, venue_id: str, context: dict[str, list[dict[str, Any]]] | None = None) -> dict[str, Any]:
        context = self._context(context, "venues", "matches")
        try:
            venue_lookup = self._venue_lookup(context)
            venue = venue_lookup.get(str(venue_id)) or self.store.get("venues", venue_id)
            if not venue:
                return self._empty_venue_summary(None)

            matches = [m for m in self._matches(context) if str(m.get("venue_id")) == venue_id]
            if not matches:
                metrics = {
                    "total_matches": 0,
                    "average_first_innings_score": 0.0,
                    "average_second_innings_score": 0.0,
                    "bat_first_win_percentage": 0.0,
                    "chase_win_percentage": 0.0,
                    "highest_score": 0,
                    "highest_successful_chase": 0,
                    "lowest_defended_score": 0,
                    "par_score": 0.0,
                    "safe_score": 0.0,
                }
                return {"venue": venue, "metrics": metrics, "insights": ["No venue history available yet."]}
            first_scores = [m.get("first_innings_score", 0) for m in matches if m.get("first_innings_score") is not None]
            second_scores = [m.get("second_innings_score", 0) for m in matches if m.get("second_innings_score") is not None]
            bat_first_wins = [m for m in matches if str(m.get("winner_id")) == str(m.get("bat_first_team_id"))]
            chase_wins = [m for m in matches if str(m.get("winner_id")) != str(m.get("bat_first_team_id"))]
            successful_chases = [m.get("second_innings_score", 0) for m in chase_wins]
            defended_scores = [m.get("first_innings_score", 0) for m in bat_first_wins]
            average_first = round(sum(first_scores) / len(first_scores), 2) if first_scores else 0.0
            metrics = {
                "total_matches": len(matches),
                "average_first_innings_score": average_first,
                "average_second_innings_score": round(sum(second_scores) / len(second_scores), 2) if second_scores else 0.0,
                "bat_first_win_percentage": round(percentage(len(bat_first_wins), len(matches)), 2),
                "chase_win_percentage": round(percentage(len(chase_wins), len(matches)), 2),
                "highest_score": max(first_scores) if first_scores else 0,
                "highest_successful_chase": max(successful_chases) if successful_chases else 0,
                "lowest_defended_score": min(defended_scores) if defended_scores else 0,
                "par_score": round(average_first + 10, 2),
                "safe_score": round(average_first + 20, 2),
            }
            insights = self._venue_insights_from_metrics(venue, metrics)
            return {"venue": venue, "metrics": metrics, "insights": insights}
        except Exception:
            logger.exception("Failed to build venue analytics using tables: venues, matches.")
            venue = self.store.get("venues", venue_id)
            return self._empty_venue_summary(venue)

    def toss_summary(self, context: dict[str, list[dict[str, Any]]] | None = None) -> dict[str, Any]:
        context = self._context(context, "teams", "matches")
        try:
            matches = [m for m in self._matches(context) if m.get("toss_winner_id")]
            toss_wins = [m for m in matches if str(m.get("winner_id")) == str(m.get("toss_winner_id"))]
            bat_decisions = [m for m in matches if m.get("toss_decision") == "bat"]
            bowl_decisions = [m for m in matches if m.get("toss_decision") == "bowl"]
            bat_success = [m for m in bat_decisions if str(m.get("winner_id")) == str(m.get("toss_winner_id"))]
            bowl_success = [m for m in bowl_decisions if str(m.get("winner_id")) == str(m.get("toss_winner_id"))]
            overall = {
                "toss_winner_match_win_percentage": round(percentage(len(toss_wins), len(matches)), 2) if matches else 0.0,
                "bat_decision_success_percentage": round(percentage(len(bat_success), len(bat_decisions)), 2) if bat_decisions else 0.0,
                "bowl_decision_success_percentage": round(percentage(len(bowl_success), len(bowl_decisions)), 2) if bowl_decisions else 0.0,
            }
            team_wise = []
            for team in self._teams(context):
                team_id = str(team.get("id"))
                team_matches = [m for m in matches if str(m.get("toss_winner_id")) == team_id]
                conversions = [m for m in team_matches if str(m.get("winner_id")) == team_id]
                team_wise.append(
                    {
                        "team_id": team_id,
                        "team_name": team.get("team_name"),
                        "toss_wins": len(team_matches),
                        "toss_conversion_percentage": round(percentage(len(conversions), len(team_matches)), 2) if team_matches else 0.0,
                    }
                )
            return {
                "overall": overall,
                "team_wise": team_wise,
                "insights": self._toss_insights_from_metrics(overall),
            }
        except Exception:
            logger.exception("Failed to build toss analytics using tables: teams, matches.")
            return self._empty_toss_summary()

    def head_to_head(self, team_a_id: str, team_b_id: str, context: dict[str, list[dict[str, Any]]] | None = None) -> dict[str, Any]:
        context = self._context(context, "teams", "matches")
        try:
            team_lookup = self._team_lookup(context)
            team_a = self.store.get("teams", team_a_id) or team_lookup.get(team_a_id) or {"id": team_a_id, "team_name": "Unknown team"}
            team_b = self.store.get("teams", team_b_id) or team_lookup.get(team_b_id) or {"id": team_b_id, "team_name": "Unknown team"}
            matches = [
                m
                for m in self._matches(context)
                if {str(m.get("team_a_id")), str(m.get("team_b_id"))} == {team_a_id, team_b_id}
            ]
            team_a_wins = [m for m in matches if str(m.get("winner_id")) == team_a_id]
            team_b_wins = [m for m in matches if str(m.get("winner_id")) == team_b_id]
            metrics = {
                "matches_played": len(matches),
                "team_a_wins": len(team_a_wins),
                "team_b_wins": len(team_b_wins),
                "team_a_win_percentage": round(percentage(len(team_a_wins), len(matches)), 2) if matches else 0.0,
                "team_b_win_percentage": round(percentage(len(team_b_wins), len(matches)), 2) if matches else 0.0,
                "average_first_innings_score": round(sum(m.get("first_innings_score", 0) for m in matches) / len(matches), 2) if matches else 0.0,
            }
            recent_matches = sorted(matches, key=lambda item: item.get("match_date", ""), reverse=True)[:5]
            insights = [
                f"{team_a['team_name']} leads the matchup when their win percentage is higher than {team_b['team_name']} in this sample.",
            ] if matches else ["No head-to-head history is available yet."]
            return {
                "team_a": team_a,
                "team_b": team_b,
                "metrics": metrics,
                "recent_matches": recent_matches,
                "insights": insights,
            }
        except Exception:
            logger.exception("Failed to build head-to-head analytics using tables: teams, matches.")
            return self._empty_head_to_head(team_a_id, team_b_id)

    def _recent_form_index(self, team_id: str, context: dict[str, list[dict[str, Any]]] | None = None) -> float:
        matches = sorted(
            [m for m in self._matches(context) if str(m.get("team_a_id")) == team_id or str(m.get("team_b_id")) == team_id],
            key=lambda item: item.get("match_date", ""),
            reverse=True,
        )[:5]
        score = 0.0
        for index, match in enumerate(matches):
            if str(match.get("winner_id")) == team_id:
                score += max(5 - index, 1) * 2
            else:
                score += max(5 - index, 1) * 0.5
        return clamp(score * 4, 0, 100)

    def _team_insights_from_metrics(self, team: dict[str, Any], metrics: dict[str, Any]) -> list[str]:
        insights = [
            f"{team['team_name']} has a win rate of {metrics['win_percentage']}% across {metrics['matches_played']} matches.",
            f"Their batting-first success rate is {metrics['bat_first_win_percentage']}%, with a chase success rate of {metrics['chase_win_percentage']}%.",
        ]
        if metrics["chase_win_percentage"] > metrics["bat_first_win_percentage"]:
            insights.append("They are more efficient chasing. Winning the toss should usually trigger bowling first.")
        else:
            insights.append("They convert defending positions well, so totals above par can be defended with pressure bowling.")
        if metrics["team_strength_score"] >= 70:
            insights.append("Current team strength score indicates a high-confidence contender profile.")
        elif metrics["team_strength_score"] >= 50:
            insights.append("This side is balanced but still sensitive to venue and toss conditions.")
        else:
            insights.append("The sample suggests inconsistency; align batting order and bowling matchups tightly.")
        return insights

    def _venue_insights_from_metrics(self, venue: dict[str, Any], metrics: dict[str, Any]) -> list[str]:
        return [
            f"{venue['venue_name']} has produced an average first-innings score of {metrics['average_first_innings_score']}.",
            f"A par score here is around {metrics['par_score']}, while a safe score is closer to {metrics['safe_score']}.",
            "If the pitch is flat, teams should prefer attacking powerplay batting and protect wickets for overs 15-20.",
        ]

    def _player_insights_from_metrics(self, player: dict[str, Any], batting: dict[str, Any], bowling: dict[str, Any], impact: dict[str, Any]) -> list[str]:
        role = (player.get("role") or "").lower()
        insights = [
            f"{player['player_name']} currently shows a batting impact score of {impact['batting_impact']:.1f} and bowling impact of {impact['bowling_impact']:.1f}.",
        ]
        if "batter" in role or "all-rounder" in role:
            insights.append("They offer value in middle-overs stability and should be used to control risk against spin.")
        if "bowler" in role or bowling.get("wickets", 0) > 0:
            insights.append("Their bowling profile is best suited to pressure overs with attacking fields and short-of-length bowling.")
        if impact["all_rounder_index"] >= 100:
            insights.append("All-rounder index is elite for this sample and justifies higher batting leverage.")
        return insights

    def _toss_insights_from_metrics(self, overall: dict[str, Any]) -> list[str]:
        return [
            f"Toss winners convert to match wins at {overall['toss_winner_match_win_percentage']}%.",
            f"Bat-first decisions succeed at {overall['bat_decision_success_percentage']}%, while bowling-first decisions succeed at {overall['bowl_decision_success_percentage']}%.",
            "Decision quality is venue-dependent; combine toss history with surface behaviour before committing.",
        ]


analytics_service = AnalyticsService()
