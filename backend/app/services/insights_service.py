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

    def generate_opponent_strategy(self, our_team_id: str, opponent_team_id: str, venue_id: str) -> dict[str, Any]:
        our_team = self.analytics.team_summary(our_team_id)
        opponent_team = self.analytics.team_summary(opponent_team_id)
        venue = self.analytics.venue_summary(venue_id)
        h2h = self.analytics.head_to_head(our_team_id, opponent_team_id)
        metrics = our_team["metrics"]
        venue_metrics = venue["metrics"]
        opponent_metrics = opponent_team["metrics"]
        suggested_decision = "bowl" if metrics["chase_win_percentage"] >= metrics["bat_first_win_percentage"] else "bat"
        suggested_target = int(venue_metrics.get("safe_score", 0) or metrics.get("average_score_batting_first", 0) + 15)
        danger_players = [player["player_name"] for player in self.analytics.store.list("players") if player["team_id"] == opponent_team_id][:3]
        return {
            "head_to_head": h2h["metrics"],
            "best_toss_decision": suggested_decision,
            "suggested_target": suggested_target,
            "opponent_weakness": (
                f"{opponent_team['team']['team_name']} is more vulnerable when forced to defend below venue par."
                if venue_metrics.get("par_score", 0) else "Opponent vulnerabilities depend on venue conditions."
            ),
            "danger_players": danger_players,
            "bowling_strategy": "Attack stumps early, then vary pace through overs 7-15 and target the weaker finisher.",
            "batting_strategy": "Preserve wickets through powerplay, then accelerate against the third/fourth bowler.",
            "insights": [
                f"{our_team['team']['team_name']} should use the toss to maximize their stronger match phase.",
                f"Venue par is {venue_metrics.get('par_score', 0)} and safe score is {venue_metrics.get('safe_score', 0)}.",
            ],
        }

    def generate_match_report(self, match_id: str) -> dict[str, Any]:
        match = self.analytics.store.get("matches", match_id)
        if not match:
            return {}
        team_a = self.analytics.store.get("teams", str(match["team_a_id"]))
        team_b = self.analytics.store.get("teams", str(match["team_b_id"]))
        venue = self.analytics.store.get("venues", str(match["venue_id"]))
        winner = self.analytics.store.get("teams", str(match["winner_id"])) if match.get("winner_id") else None
        player_of_match = self.analytics.store.get("players", str(match["player_of_match_id"])) if match.get("player_of_match_id") else None
        return {
            "match_summary": f"{team_a['team_name']} vs {team_b['team_name']} at {venue['venue_name']} ended with {winner['team_name'] if winner else 'no result'} prevailing.",
            "key_turning_points": [
                "Powerplay execution created the scoring platform.",
                "Middle-overs control dictated the run-rate pressure.",
                "Death-overs bowling protected the final result.",
            ],
            "team_insights": {
                team_a["team_name"]: self.analytics.team_summary(team_a["id"])["insights"],
                team_b["team_name"]: self.analytics.team_summary(team_b["id"])["insights"],
            },
            "player_impact": self.analytics.player_summary(str(player_of_match["id"])) if player_of_match else {},
            "strategy_notes": self.generate_opponent_strategy(str(match["team_a_id"]), str(match["team_b_id"]), str(match["venue_id"])),
        }


insights_service = InsightsService()
