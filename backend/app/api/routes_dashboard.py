from __future__ import annotations

from fastapi import APIRouter

from app.services.insights_service import insights_service
from app.services.analytics_service import analytics_service


router = APIRouter()


@router.get("/dashboard")
def dashboard():
    return analytics_service.dashboard_summary()


@router.get("/standings")
def standings():
    return analytics_service.standings()


@router.get("/team/{team_id}")
def team_dashboard(team_id: str):
    return analytics_service.team_summary(team_id)


@router.get("/player/{player_id}")
def player_dashboard(player_id: str):
    return analytics_service.player_summary(player_id)


@router.get("/venue/{venue_id}")
def venue_dashboard(venue_id: str):
    return analytics_service.venue_summary(venue_id)


@router.get("/toss")
def toss_dashboard():
    return analytics_service.toss_summary()


@router.get("/head-to-head/{team_a_id}/{team_b_id}")
def head_to_head(team_a_id: str, team_b_id: str):
    return analytics_service.head_to_head(team_a_id, team_b_id)


@router.get("/opponent-strategy/{our_team_id}/{opponent_team_id}/{venue_id}")
def opponent_strategy(our_team_id: str, opponent_team_id: str, venue_id: str):
    return insights_service.generate_opponent_strategy(our_team_id, opponent_team_id, venue_id)
