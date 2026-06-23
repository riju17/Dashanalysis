from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException

from app.api.deps import get_current_user
from app.models.schemas import TournamentResponse
from app.services.tournament_service import ensure_tournament_access, get_tournament_by_slug, list_accessible_tournaments


router = APIRouter()


@router.get("", response_model=list[TournamentResponse])
def list_tournaments(user=Depends(get_current_user)):
    return list_accessible_tournaments(user)


@router.get("/{slug}", response_model=TournamentResponse)
def get_tournament(slug: str, user=Depends(get_current_user)):
    tournament = get_tournament_by_slug(slug)
    if not tournament:
        raise HTTPException(status_code=404, detail="Tournament not found")
    ensure_tournament_access(user, tournament)
    return tournament
