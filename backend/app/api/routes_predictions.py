from __future__ import annotations

from fastapi import APIRouter

from app.models.schemas import PredictionRequest
from app.services.prediction_service import prediction_service


router = APIRouter()


@router.post("/win-probability")
def win_probability(payload: PredictionRequest):
    return prediction_service.predict_win_probability(
        team_a_id=str(payload.team_a_id),
        team_b_id=str(payload.team_b_id),
        venue_id=str(payload.venue_id),
        toss_winner_id=str(payload.toss_winner_id) if payload.toss_winner_id else None,
        toss_decision=payload.toss_decision,
        bat_first_team_id=str(payload.bat_first_team_id) if payload.bat_first_team_id else None,
    )
