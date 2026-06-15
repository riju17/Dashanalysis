from __future__ import annotations

from collections import defaultdict
from datetime import datetime
from typing import Any

import pandas as pd

from app.data.store import store
from app.utils.cricket_calculations import (
    all_rounder_index,
    batting_impact,
    bowling_impact,
    clamp,
    percentage,
    safe_divide,
    team_strength_score,
)


class AnalyticsService:
    def __init__(self, data_store=store):
        self.store = data_store

    def _teams(self) -> list[dict[str, Any]]:
        return self.store.list("teams")

    def _venues(self) -> list[dict[str, Any]]:
        return self.store.list("venues")

    def _players(self) -> list[dict[str, Any]]:
        return self.store.list("players")

    def _matches(self) -> list[dict[str, Any]]:
        return self.store.list("matches")

    def _stats(self) -> list[dict[str, Any]]:
        return self.store.list("player_match_stats")

    def _team_lookup(self) -> dict[str, dict[str, Any]]:
        return {team["id"]: team for team in self._teams()}

    def _player_lookup(self) -> dict[str, dict[str, Any]]:
        return {player["id"]: player for player in self._players()}

    def _venue_lookup(self) -> dict[str, dict[str, Any]]:
        return {venue["id"]: venue for venue in self._venues()}

    def _matches_df(self) -> pd.DataFrame:
        matches = self._matches()
        return pd.DataFrame(matches) if matches else pd.DataFrame(columns=["id"])

    def _stats_df(self) -> pd.DataFrame:
        stats = self._stats()
        return pd.DataFrame(stats) if stats else pd.DataFrame(columns=["id"])

    def dashboard_summary(self) -> dict[str, Any]:
        matches = self._matches()
        teams = self._teams()
        players = self._players()
        stats_df = self._stats_df()
        matches_df = self._matches_df()

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
        player_lookup = self._player_lookup()
        team_win_percentage_chart = [
            {"team_id": team["id"], "team_name": team["team_name"], **self.team_summary(team["id"])["metrics"]}
            for team in teams
        ]
        venue_score_chart = [
            {"venue_id": venue["id"], "venue_name": venue["venue_name"], **self.venue_summary(venue["id"])["metrics"]}
            for venue in self._venues()
        ]
        top_run_scorers = []
        top_wicket_takers = []
        if not stats_df.empty:
            runs_table = stats_df.groupby("player_id", as_index=False)["runs"].sum().sort_values("runs", ascending=False).head(5)
            wickets_table = stats_df.groupby("player_id", as_index=False)["wickets"].sum().sort_values("wickets", ascending=False).head(5)
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

        summary_points = [
            f"{len(matches)} completed matches analysed across {len(teams)} teams.",
            f"Average first innings score sits at {average_first_innings_score:.1f}.",
            f"Toss winners converted into victories {toss_conversion_percentage:.1f}% of the time.",
        ]
        return {
            "total_matches": len(matches),
            "total_teams": len(teams),
            "total_players": len(players),
            "average_first_innings_score": average_first_innings_score,
            "chase_win_percentage": chase_win_percentage,
            "bat_first_win_percentage": bat_first_win_percentage,
            "toss_conversion_percentage": toss_conversion_percentage,
            "highest_score": highest_score,
            "top_run_scorers": top_run_scorers,
            "top_wicket_takers": top_wicket_takers,
            "team_win_percentage_chart": team_win_percentage_chart,
            "venue_score_chart": venue_score_chart,
            "summary_points": summary_points,
        }

    def standings(self) -> list[dict[str, Any]]:
        standings_rows: list[dict[str, Any]] = []
        for team in self._teams():
            team_matches = [m for m in self._matches() if str(m.get("team_a_id")) == team["id"] or str(m.get("team_b_id")) == team["id"]]
            wins = [m for m in team_matches if str(m.get("winner_id")) == team["id"]]
            losses = [m for m in team_matches if m.get("winner_id") and str(m.get("winner_id")) != team["id"]]
            runs_for = 0.0
            runs_against = 0.0
            overs_for = 0.0
            overs_against = 0.0
            for match in team_matches:
                if str(match.get("bat_first_team_id")) == team["id"]:
                    runs_for += float(match.get("first_innings_score") or 0)
                    overs_for += float(match.get("first_innings_overs") or 0)
                    runs_against += float(match.get("second_innings_score") or 0)
                    overs_against += float(match.get("second_innings_overs") or 0)
                else:
                    runs_for += float(match.get("second_innings_score") or 0)
                    overs_for += float(match.get("second_innings_overs") or 0)
                    runs_against += float(match.get("first_innings_score") or 0)
                    overs_against += float(match.get("first_innings_overs") or 0)
            run_rate_for = safe_divide(runs_for, overs_for, 0.0)
            run_rate_against = safe_divide(runs_against, overs_against, 0.0)
            nrr = round(run_rate_for - run_rate_against, 3)
            standings_rows.append(
                {
                    "team_id": team["id"],
                    "team_name": team["team_name"],
                    "played": len(team_matches),
                    "wins": len(wins),
                    "losses": len(losses),
                    "points": len(wins) * 2,
                    "nrr": f"{nrr:.3f}",
                }
            )
        standings_rows.sort(key=lambda row: (row["points"], float(row["nrr"])), reverse=True)
        return standings_rows

    def team_summary(self, team_id: str) -> dict[str, Any]:
        team = self.store.get("teams", team_id)
        if not team:
            return {"team": None, "metrics": {}, "insights": [], "recent_matches": [], "head_to_head_summary": []}

        matches = [m for m in self._matches() if str(m.get("team_a_id")) == team_id or str(m.get("team_b_id")) == team_id]
        if not matches:
            metrics = {
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
                "form_index": 0.0,
                "team_strength_score": 0.0,
            }
            return {"team": team, "metrics": metrics, "insights": ["No matches available for this team yet."], "recent_matches": [], "head_to_head_summary": []}

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
        recent_matches = sorted(matches, key=lambda item: item.get("match_date", ""), reverse=True)[:5]
        recent_form_index = self._recent_form_index(team_id)
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
        for opponent in self._teams():
            if opponent["id"] == team_id:
                continue
            summary = self.head_to_head(team_id, opponent["id"])
            if summary["metrics"]["matches_played"]:
                head_to_head_summary.append(summary["metrics"])
        insights = self._team_insights_from_metrics(team, metrics)
        return {
            "team": team,
            "metrics": metrics,
            "insights": insights,
            "recent_matches": recent_matches,
            "head_to_head_summary": head_to_head_summary[:5],
        }

    def player_summary(self, player_id: str) -> dict[str, Any]:
        player = self.store.get("players", player_id)
        if not player:
            return {"player": None, "batting": {}, "bowling": {}, "impact": {}, "insights": []}

        stats = self.store.filter("player_match_stats", player_id=player_id)
        stats_df = pd.DataFrame(stats) if stats else pd.DataFrame()
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
                "dot_ball_percentage": 0.0,
                "bowling_strike_impact": 0.0,
                "pressure_bowling_score": 0.0,
            }
        else:
            total_runs = int(stats_df["runs"].sum())
            total_balls = int(stats_df["balls"].sum())
            total_matches = max(len(stats_df), 1)
            fours = int(stats_df["fours"].sum())
            sixes = int(stats_df["sixes"].sum())
            overs = round(float(stats_df["overs"].sum()), 2)
            wickets = int(stats_df["wickets"].sum())
            dot_balls = int(stats_df["dot_balls"].sum())
            runs_conceded = float(stats_df["runs_conceded"].sum())
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
                "dot_ball_percentage": round(percentage(dot_balls, int(overs * 6)), 2) if overs else 0.0,
                "bowling_strike_impact": round((wickets * 25) + (dot_balls * 1.25), 2),
                "pressure_bowling_score": round(bowling_impact(wickets, dot_balls, round(runs_conceded / overs, 2) if overs else 0.0), 2),
            }

        impact = {
            "batting_impact": round(batting_impact(batting.get("total_runs", 0), batting.get("batting_strike_rate", 0.0), batting.get("fours", 0), batting.get("sixes", 0)), 2),
            "bowling_impact": round(bowling_impact(bowling.get("wickets", 0), int((bowling.get("dot_ball_percentage", 0) / 100) * max(int(bowling.get("overs", 0) * 6), 1)), bowling.get("economy", 0.0)), 2),
        }
        impact["all_rounder_index"] = round(all_rounder_index(impact["batting_impact"], impact["bowling_impact"]), 2)
        insights = self._player_insights_from_metrics(player, batting, bowling, impact)
        return {"player": player, "batting": batting, "bowling": bowling, "impact": impact, "insights": insights}

    def venue_summary(self, venue_id: str) -> dict[str, Any]:
        venue = self.store.get("venues", venue_id)
        if not venue:
            return {"venue": None, "metrics": {}, "insights": []}
        matches = [m for m in self._matches() if str(m.get("venue_id")) == venue_id]
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

    def toss_summary(self) -> dict[str, Any]:
        matches = [m for m in self._matches() if m.get("toss_winner_id")]
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
        for team in self._teams():
            team_matches = [m for m in matches if str(m.get("toss_winner_id")) == team["id"]]
            conversions = [m for m in team_matches if str(m.get("winner_id")) == team["id"]]
            team_wise.append(
                {
                    "team_id": team["id"],
                    "team_name": team["team_name"],
                    "toss_wins": len(team_matches),
                    "toss_conversion_percentage": round(percentage(len(conversions), len(team_matches)), 2) if team_matches else 0.0,
                }
            )
        return {
            "overall": overall,
            "team_wise": team_wise,
            "insights": self._toss_insights_from_metrics(overall),
        }

    def head_to_head(self, team_a_id: str, team_b_id: str) -> dict[str, Any]:
        team_lookup = self._team_lookup()
        team_a = self.store.get("teams", team_a_id) or team_lookup.get(team_a_id) or {"id": team_a_id, "team_name": "Unknown team"}
        team_b = self.store.get("teams", team_b_id) or team_lookup.get(team_b_id) or {"id": team_b_id, "team_name": "Unknown team"}
        matches = [
            m
            for m in self._matches()
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

    def _recent_form_index(self, team_id: str) -> float:
        matches = sorted(
            [m for m in self._matches() if str(m.get("team_a_id")) == team_id or str(m.get("team_b_id")) == team_id],
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
