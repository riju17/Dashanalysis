from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, status

from app.api.deps import require_role
from app.data.store import store
from app.models.schemas import TeamCreate, TeamResponse, TeamUpdate
from app.services.analytics_service import analytics_service
from app.services.validation_service import validate_team_payload


router = APIRouter()


@router.get("", response_model=list[TeamResponse])
def list_teams():
    return store.list("teams")


@router.post("", response_model=TeamResponse, status_code=status.HTTP_201_CREATED)
def create_team(payload: TeamCreate, x_user_role: str = Depends(require_role)):
    validate_team_payload(payload.model_dump())
    return store.insert("teams", payload.model_dump())


@router.get("/{team_id}", response_model=TeamResponse)
def get_team(team_id: str):
    team = store.get("teams", team_id)
    if not team:
        raise HTTPException(status_code=404, detail="Team not found")
    return team


@router.put("/{team_id}", response_model=TeamResponse)
def update_team(team_id: str, payload: TeamUpdate, x_user_role: str = Depends(require_role)):
    existing = store.get("teams", team_id)
    if not existing:
        raise HTTPException(status_code=404, detail="Team not found")
    merged = {**existing, **{key: value for key, value in payload.model_dump().items() if value is not None}}
    validate_team_payload(merged, team_id=team_id)
    updated = store.update("teams", team_id, payload.model_dump(exclude_none=True))
    return updated


@router.get("/{team_id}/analytics")
def team_analytics(team_id: str):
    return analytics_service.team_summary(team_id)
