from __future__ import annotations

from typing import Any

import pandas as pd

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
        danger_players = self._top_opponent_danger_players(context, opponent_team_id)
        return {
            "head_to_head": h2h["metrics"],
            "best_toss_decision": suggested_decision,
            "suggested_target": suggested_target,
            "opponent_weakness": (
                f"{opponent_team_name} is more vulnerable when forced to defend below venue par."
                if venue_metrics.get("par_score", 0) else "Opponent vulnerabilities depend on venue conditions."
            ),
            "danger_players": danger_players,
            "bowling_strategy": "Attack stumps early, then vary pace through overs 7-15 and target the weaker finisher.",
            "batting_strategy": "Preserve wickets through powerplay, then accelerate against the third/fourth bowler.",
            "insights": [
                f"{our_team_name} should use the toss to maximize their stronger match phase.",
                f"{venue_name} par is {venue_metrics.get('par_score', 0)} and safe score is {venue_metrics.get('safe_score', 0)}.",
            ],
        }

    def _top_opponent_danger_players(self, context: dict[str, list[dict[str, Any]]], opponent_team_id: str) -> list[str]:
        player_rows = context.get("players", [])
        stats_rows = [row for row in context.get("player_match_stats", []) if str(row.get("team_id")) == str(opponent_team_id)]
        if not stats_rows:
            return [player["player_name"] for player in player_rows if str(player.get("team_id")) == str(opponent_team_id)][:3]

        stats_df = pd.DataFrame(stats_rows)
        if stats_df.empty or "player_id" not in stats_df or "runs" not in stats_df:
            return [player["player_name"] for player in player_rows if str(player.get("team_id")) == str(opponent_team_id)][:3]

        player_lookup = {str(player.get("id")): player for player in player_rows}
        run_totals = (
            stats_df.groupby("player_id", as_index=False)["runs"]
            .sum()
            .sort_values(["runs", "player_id"], ascending=[False, True])
            .head(3)
        )
        danger_players: list[str] = []
        for _, row in run_totals.iterrows():
            player = player_lookup.get(str(row["player_id"]))
            player_name = player.get("player_name", "Unknown") if player else "Unknown"
            danger_players.append(f"{player_name} - {int(row['runs'])} runs")
        return danger_players

    def generate_match_report(self, match_id: str) -> dict[str, Any]:
        context = self.analytics.store.snapshot(["teams", "venues", "matches", "players", "player_match_stats"])
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


insights_service = InsightsService()
