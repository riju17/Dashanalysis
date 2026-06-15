from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, status

from app.api.deps import require_role
from app.data.store import store
from app.models.schemas import MatchCreate, MatchResponse, PlayerMatchStatCreate, PlayerMatchStatResponse
from app.services.validation_service import validate_match_payload
from app.utils.cricket_calculations import derive_match_result


router = APIRouter()


@router.get("", response_model=list[MatchResponse])
def list_matches():
    return store.list("matches")


@router.post("", response_model=MatchResponse, status_code=status.HTTP_201_CREATED)
def create_match(payload: MatchCreate, x_user_role: str = Depends(require_role)):
    data = payload.model_dump()
    derived = derive_match_result(
        data.get("first_innings_score"),
        data.get("second_innings_score"),
        data.get("first_innings_wickets"),
        data.get("second_innings_wickets"),
        str(data.get("bat_first_team_id")) if data.get("bat_first_team_id") else None,
        str(data.get("bowl_first_team_id")) if data.get("bowl_first_team_id") else None,
        data.get("result_type"),
        data.get("margin_runs"),
        data.get("margin_wickets"),
    )
    data.update({key: value for key, value in derived.items() if value is not None or key in {"margin_runs", "margin_wickets"}})
    validate_match_payload(data)
    return store.insert("matches", data)


@router.get("/{match_id}", response_model=MatchResponse)
def get_match(match_id: str):
    match = store.get("matches", match_id)
    if not match:
        raise HTTPException(status_code=404, detail="Match not found")
    return match


@router.delete("/{match_id}")
def delete_match(match_id: str, x_user_role: str = Depends(require_role)):
    deleted = store.delete_match_cascade(match_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Match not found")
    return {"success": True, "message": "Match deleted"}


@router.post("/{match_id}/player-stats", response_model=list[PlayerMatchStatResponse], status_code=status.HTTP_201_CREATED)
def create_player_stats(match_id: str, payload: list[PlayerMatchStatCreate], x_user_role: str = Depends(require_role)):
    if not store.get("matches", match_id):
        raise HTTPException(status_code=404, detail="Match not found")
    rows = []
    for stat in payload:
        data = stat.model_dump()
        data["match_id"] = match_id
        rows.append(store.insert("player_match_stats", data))
    return rows


@router.get("/{match_id}/player-stats", response_model=list[PlayerMatchStatResponse])
def get_player_stats(match_id: str):
    return store.filter("player_match_stats", match_id=match_id)
