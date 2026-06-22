from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, status

from app.api.deps import require_role
from app.data.store import store
from app.models.schemas import PlayerAnalyticsResponse, PlayerCreate, PlayerResponse
from app.services.analytics_service import analytics_service
from app.services.validation_service import validate_player_payload


router = APIRouter()


@router.get("", response_model=list[PlayerResponse])
def list_players():
    return store.list("players")


@router.post("", response_model=PlayerResponse, status_code=status.HTTP_201_CREATED)
def create_player(payload: PlayerCreate, x_user_role: str = Depends(require_role)):
    validate_player_payload(payload.model_dump())
    return store.insert("players", payload.model_dump())


@router.get("/team/{team_id}", response_model=list[PlayerResponse])
def list_players_by_team(team_id: str):
    return store.filter("players", team_id=team_id)


@router.get("/{player_id}")
def get_player(player_id: str):
    player = store.get("players", player_id)
    if not player:
        raise HTTPException(status_code=404, detail="Player not found")
    return player


@router.get("/{player_id}/analytics", response_model=PlayerAnalyticsResponse)
def player_analytics(player_id: str):
    return analytics_service.player_summary(player_id)
