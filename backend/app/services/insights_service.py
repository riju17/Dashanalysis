from __future__ import annotations

from typing import Any

from app.services.analytics_service import analytics_service


class InsightsService:
    def __init__(self, analytics=analytics_service):
        self.analytics = analytics

    def generate_team_insights(self, team_id: str) -> list[str]:
        return self.analytics.team_summary(team_id)["insights"]

    def generate_venue_insights(self, venue_id: str) -> list[str]:
        return self.analytics.venue_summary(venue_id)["insights"]

    def generate_player_insights(self, player_id: str) -> list[str]:
        return self.analytics.player_summary(player_id)["insights"]

    def generate_toss_insights(self) -> list[str]:
        return self.analytics.toss_summary()["insights"]

    def generate_opponent_strategy(
        self,
        our_team_id: str,
        opponent_team_id: str,
        venue_id: str,
        context: dict[str, list[dict[str, Any]]] | None = None,
    ) -> dict[str, Any]:
        context = context or self.analytics.store.snapshot(["teams", "venues", "matches", "player_match_stats", "players"])
        our_team = self.analytics.team_summary(our_team_id, context=context)
        opponent_team = self.analytics.team_summary(opponent_team_id, context=context)
        venue = self.analytics.venue_summary(venue_id, context=context)
        h2h = self.analytics.head_to_head(our_team_id, opponent_team_id, context=context)
        metrics = our_team["metrics"]
        venue_metrics = venue["metrics"]
        opponent_metrics = opponent_team["metrics"]
        our_team_name = (our_team.get("team") or {}).get("team_name", "Our team")
        opponent_team_name = (opponent_team.get("team") or {}).get("team_name", "Opponent team")
        venue_name = (venue.get("venue") or {}).get("venue_name", "Venue")
        suggested_decision = "bowl" if metrics["chase_win_percentage"] >= metrics["bat_first_win_percentage"] else "bat"
        suggested_target = int(venue_metrics.get("safe_score", 0) or metrics.get("average_score_batting_first", 0) + 15)
        danger_players, top_batsmen, top_bowlers = self._top_opponent_players(context, opponent_team_id)
        return {
            "head_to_head": h2h["metrics"],
            "best_toss_decision": suggested_decision,
            "suggested_target": suggested_target,
            "opponent_weakness": (
                f"{opponent_team_name} is more vulnerable when forced to defend below venue par."
                if venue_metrics.get("par_score", 0) else "Opponent vulnerabilities depend on venue conditions."
            ),
            "danger_players": danger_players,
            "top_batsmen": top_batsmen,
            "top_bowlers": top_bowlers,
            "bowling_strategy": "Attack stumps early, then vary pace through overs 7-15 and target the weaker finisher.",
            "batting_strategy": "Preserve wickets through powerplay, then accelerate against the third/fourth bowler.",
            "insights": [
                f"{our_team_name} should use the toss to maximize their stronger match phase.",
                f"{venue_name} par is {venue_metrics.get('par_score', 0)} and safe score is {venue_metrics.get('safe_score', 0)}.",
            ],
        }

    def _top_opponent_players(
        self,
        context: dict[str, list[dict[str, Any]]],
        opponent_team_id: str,
    ) -> tuple[list[dict[str, Any]], list[dict[str, Any]], list[dict[str, Any]]]:
        player_rows = [player for player in context.get("players", []) if str(player.get("team_id")) == str(opponent_team_id)]
        if not player_rows:
            return [], [], []

        opponent_players: list[dict[str, Any]] = []
        for player in player_rows:
            summary = self.analytics.player_summary(str(player.get("id")), context=context)
            batting = summary.get("batting", {})
            bowling = summary.get("bowling", {})
            impact = summary.get("impact", {})
            opponent_players.append(
                {
                    "player_id": str(player.get("id")),
                    "player_name": player.get("player_name", "Unknown"),
                    "runs": int(batting.get("total_runs", 0) or 0),
                    "wickets": int(bowling.get("wickets", 0) or 0),
                    "batting_impact": round(float(impact.get("batting_impact", 0) or 0), 2),
                    "bowling_impact": round(float(impact.get("bowling_impact", 0) or 0), 2),
                    "all_rounder_score": round(float(impact.get("all_rounder_index", 0) or 0), 2),
                }
            )

        danger_players = sorted(
            opponent_players,
            key=lambda row: (
                -row["all_rounder_score"],
                -row["runs"],
                -row["wickets"],
                row["player_name"],
            ),
        )[:3]
        top_batsmen = sorted(
            opponent_players,
            key=lambda row: (
                -row["runs"],
                -row["batting_impact"],
                -row["wickets"],
                row["player_name"],
            ),
        )[:3]
        top_bowlers = sorted(
            opponent_players,
            key=lambda row: (
                -row["wickets"],
                -row["bowling_impact"],
                -row["runs"],
                row["player_name"],
            ),
        )[:3]
        return danger_players, top_batsmen, top_bowlers

    def generate_match_report_with_context(self, match_id: str, context: dict[str, list[dict[str, Any]]]) -> dict[str, Any]:
        match = next((row for row in context.get("matches", []) if str(row.get("id")) == str(match_id)), None)
        if not match:
            return {}
        team_lookup = {str(team.get("id")): team for team in context.get("teams", [])}
        player_lookup = {str(player.get("id")): player for player in context.get("players", [])}
        venue_lookup = {str(venue.get("id")): venue for venue in context.get("venues", [])}
        team_a = team_lookup.get(str(match["team_a_id"]))
        team_b = team_lookup.get(str(match["team_b_id"]))
        venue = venue_lookup.get(str(match["venue_id"]))
        winner = team_lookup.get(str(match["winner_id"])) if match.get("winner_id") else None
        player_of_match = player_lookup.get(str(match["player_of_match_id"])) if match.get("player_of_match_id") else None
        team_a_name = team_a["team_name"] if team_a else "Team A"
        team_b_name = team_b["team_name"] if team_b else "Team B"
        venue_name = venue["venue_name"] if venue else "Unknown venue"
        winner_name = winner["team_name"] if winner else "no result"
        return {
            "match_summary": f"{team_a_name} vs {team_b_name} at {venue_name} ended with {winner_name} prevailing.",
            "key_turning_points": [
                "Powerplay execution created the scoring platform.",
                "Middle-overs control dictated the run-rate pressure.",
                "Death-overs bowling protected the final result.",
            ],
            "team_insights": {
                team_a_name: self.analytics.team_summary(team_a["id"], context=context)["insights"] if team_a else [],
                team_b_name: self.analytics.team_summary(team_b["id"], context=context)["insights"] if team_b else [],
            },
            "player_impact": self.analytics.player_summary(str(player_of_match["id"]), context=context) if player_of_match else {},
            "strategy_notes": self.generate_opponent_strategy(str(match["team_a_id"]), str(match["team_b_id"]), str(match["venue_id"]), context=context),
        }

    def generate_match_report(self, match_id: str, context: dict[str, list[dict[str, Any]]] | None = None) -> dict[str, Any]:
        scoped_context = context or self.analytics.store.snapshot(["teams", "venues", "matches", "players", "player_match_stats"])
        return self.generate_match_report_with_context(match_id, scoped_context)


insights_service = InsightsService()
