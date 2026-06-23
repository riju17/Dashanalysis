from __future__ import annotations

from typing import Any
from typing import Optional

from app.services.analytics_service import analytics_service
from app.utils.cricket_calculations import clamp


class PredictionService:
    def __init__(self, analytics=analytics_service):
        self.analytics = analytics

    def predict_win_probability(
        self,
        team_a_id: str,
        team_b_id: str,
        venue_id: str,
        toss_winner_id: Optional[str] = None,
        toss_decision: Optional[str] = None,
        bat_first_team_id: Optional[str] = None,
    ) -> dict[str, Any]:
        context = self.analytics.store.snapshot(["teams", "venues", "matches", "player_match_stats"])
        team_a = self.analytics.team_summary(team_a_id, context=context)
        team_b = self.analytics.team_summary(team_b_id, context=context)
        venue = self.analytics.venue_summary(venue_id, context=context)
        h2h = self.analytics.head_to_head(team_a_id, team_b_id, context=context)

        score_a = 50.0
        score_b = 50.0
        reasoning = []
        advantages = []
        risks = []
        team_a_name = (team_a.get("team") or {}).get("team_name", "Team A")
        team_b_name = (team_b.get("team") or {}).get("team_name", "Team B")

        win_diff = team_a["metrics"].get("win_percentage", 0) - team_b["metrics"].get("win_percentage", 0)
        strength_diff = team_a["metrics"].get("team_strength_score", 0) - team_b["metrics"].get("team_strength_score", 0)
        form_diff = team_a["metrics"].get("form_index", 0) - team_b["metrics"].get("form_index", 0)
        h2h_diff = h2h["metrics"].get("team_a_win_percentage", 0) - h2h["metrics"].get("team_b_win_percentage", 0)
        venue_bias = venue["metrics"].get("chase_win_percentage", 0) - venue["metrics"].get("bat_first_win_percentage", 0)

        score_a += win_diff * 0.25 + strength_diff * 0.35 + form_diff * 0.20 + h2h_diff * 0.20
        score_b -= win_diff * 0.25 + strength_diff * 0.35 + form_diff * 0.20 + h2h_diff * 0.20

        if bat_first_team_id:
            if str(bat_first_team_id) == team_a_id:
                score_a += venue["metrics"].get("bat_first_win_percentage", 0) * 0.15
                score_b += venue["metrics"].get("chase_win_percentage", 0) * 0.10
            elif str(bat_first_team_id) == team_b_id:
                score_b += venue["metrics"].get("bat_first_win_percentage", 0) * 0.15
                score_a += venue["metrics"].get("chase_win_percentage", 0) * 0.10

        if toss_winner_id:
            toss_bonus = 4 if toss_decision == "bowl" else 3
            if str(toss_winner_id) == team_a_id:
                score_a += toss_bonus
            elif str(toss_winner_id) == team_b_id:
                score_b += toss_bonus

        if toss_decision == "bowl":
            if venue_bias > 0:
                score_a += 2 if (bat_first_team_id and str(bat_first_team_id) != team_a_id) else 0
                score_b += 2 if (bat_first_team_id and str(bat_first_team_id) != team_b_id) else 0
            reasoning.append("Venue historically favours chasing, so bowling first can be a positive move.")
        elif toss_decision == "bat":
            reasoning.append("Venue offers defending value when totals are above par.")

        score_a = clamp(score_a, 1, 99)
        score_b = clamp(score_b, 1, 99)
        total = score_a + score_b
        team_a_probability = round((score_a / total) * 100, 2)
        team_b_probability = round((score_b / total) * 100, 2)

        if team_a_probability >= team_b_probability:
            recommended = "Team A should align with the strongest venue phase and play to their batting-strength advantage."
            advantages.append(f"{team_a_name} has the higher current model score.")
        else:
            recommended = "Team B should use the toss and matchups to push the game into their stronger phase."
            advantages.append(f"{team_b_name} has the higher current model score.")

        if team_a["metrics"].get("chase_win_percentage", 0) > team_a["metrics"].get("bat_first_win_percentage", 0):
            reasoning.append(f"{team_a_name} has a stronger chase profile.")
        if team_b["metrics"].get("bat_first_win_percentage", 0) > team_b["metrics"].get("chase_win_percentage", 0):
            reasoning.append(f"{team_b_name} defends well when batting first.")
        reasoning.append(
            f"Head-to-head edge is {h2h['metrics'].get('team_a_win_percentage', 0)}% for Team A and {h2h['metrics'].get('team_b_win_percentage', 0)}% for Team B."
        )

        if abs(team_a_probability - team_b_probability) < 8:
            confidence = "medium"
        elif abs(team_a_probability - team_b_probability) < 15:
            confidence = "high"
        else:
            confidence = "very high"

        if venue["metrics"].get("par_score", 0):
            risks.append(f"Venue par score is about {venue['metrics']['par_score']}; falling below it increases chase pressure.")
        risks.append("Middle-overs wickets can sharply swing win probability in either direction.")

        return {
            "team_a_win_probability": team_a_probability,
            "team_b_win_probability": team_b_probability,
            "recommended_decision": recommended,
            "confidence_level": confidence,
            "reasoning_points": reasoning,
            "key_advantages": advantages,
            "risk_factors": risks,
            "raw_score": {
                "score_a": round(score_a, 2),
                "score_b": round(score_b, 2),
                "win_diff": round(win_diff, 2),
                "strength_diff": round(strength_diff, 2),
                "form_diff": round(form_diff, 2),
                "h2h_diff": round(h2h_diff, 2),
                "venue_bias": round(venue_bias, 2),
            },
        }

    # Placeholder for future ML training pipeline using scikit-learn / XGBoost.
    def future_ml_pipeline_notes(self) -> list[str]:
        return [
            "Persist enriched match features to a feature store.",
            "Train baseline logistic regression before XGBoost upgrades.",
            "Calibrate probability outputs with venue and phase-specific features.",
        ]


prediction_service = PredictionService()
