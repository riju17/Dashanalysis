from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Query

from app.api.deps import get_current_user, require_platform_admin_user
from app.models.schemas import (
    AccessKeyCreateRequest,
    AccessKeyCreateResponse,
    AccessKeyResponse,
    TournamentAccessUpdateRequest,
    TournamentCreate,
    TournamentResponse,
    TournamentUpdate,
    UserTournamentAccessResponse,
)
from app.services.tournament_service import (
    ADMIN_ROLES,
    create_access_key,
    create_tournament,
    disable_access_key,
    ensure_tournament_access,
    get_tournament_by_id,
    get_tournament_by_slug,
    list_access_keys_for_tournament,
    list_tournament_access_with_users,
    normalize_role,
    revoke_tournament_access,
    update_tournament,
    upsert_user_tournament_access,
)


router = APIRouter()


@router.post("/tournaments", response_model=TournamentResponse)
def create_tournament_admin(payload: TournamentCreate, user=Depends(require_platform_admin_user)):
    return create_tournament(payload.model_dump(), user)


@router.put("/tournaments/{tournament_id}", response_model=TournamentResponse)
def update_tournament_admin(tournament_id: str, payload: TournamentUpdate, user=Depends(get_current_user)):
    return update_tournament(tournament_id, payload.model_dump(exclude_none=True), user)


@router.get("/tournaments/{slug}/access", response_model=list[UserTournamentAccessResponse])
def list_tournament_access(slug: str, user=Depends(get_current_user)):
    tournament = get_tournament_by_slug(slug)
    if not tournament:
        raise HTTPException(status_code=404, detail="Tournament not found")
    ensure_tournament_access(user, tournament, ADMIN_ROLES)
    return list_tournament_access_with_users(str(tournament.get("id")))


@router.put("/tournaments/{slug}/access/{access_id}", response_model=UserTournamentAccessResponse)
def update_tournament_access(slug: str, access_id: str, payload: TournamentAccessUpdateRequest, user=Depends(get_current_user)):
    tournament = get_tournament_by_slug(slug)
    if not tournament:
        raise HTTPException(status_code=404, detail="Tournament not found")
    ensure_tournament_access(user, tournament, ADMIN_ROLES)
    existing_rows = list_tournament_access_with_users(str(tournament.get("id")))
    existing = next((row for row in existing_rows if str(row.get("id")) == str(access_id)), None)
    if not existing:
        raise HTTPException(status_code=404, detail="Tournament access row not found")
    next_role = payload.role or existing.get("role")
    next_expiry = payload.access_expires_at
    if next_expiry is None and "access_expires_at" not in payload.model_fields_set:
        next_expiry = existing.get("access_expires_at")
    updated = upsert_user_tournament_access(
        user_id=str(existing.get("user_id")),
        tournament_id=str(existing.get("tournament_id")),
        role=normalize_role(str(next_role)),
        access_expires_at=next_expiry,
        actor=user,
    )
    if payload.is_active is not None:
        from app.data.store import store

        updated = store.update("user_tournament_access", str(updated.get("id")), {"is_active": payload.is_active}) or {**updated, "is_active": payload.is_active}
    return updated


@router.delete("/tournaments/{slug}/access/{access_id}", response_model=UserTournamentAccessResponse)
def revoke_access(slug: str, access_id: str, user=Depends(get_current_user)):
    tournament = get_tournament_by_slug(slug)
    if not tournament:
        raise HTTPException(status_code=404, detail="Tournament not found")
    ensure_tournament_access(user, tournament, ADMIN_ROLES)
    return revoke_tournament_access(access_id, user)


@router.post("/access-keys", response_model=AccessKeyCreateResponse)
def create_access_key_admin(payload: AccessKeyCreateRequest, user=Depends(get_current_user)):
    created = create_access_key(
        tournament_id=str(payload.tournament_id),
        role=payload.role,
        expires_at=payload.expires_at,
        access_duration_days=payload.access_duration_days,
        max_uses=payload.max_uses,
        actor=user,
    )
    return created


@router.get("/access-keys", response_model=list[AccessKeyResponse])
def list_access_keys(
    tournament_id: str = Query(...),
    user=Depends(get_current_user),
):
    tournament = get_tournament_by_id(tournament_id)
    if not tournament:
        raise HTTPException(status_code=404, detail="Tournament not found")
    ensure_tournament_access(user, tournament, ADMIN_ROLES)
    return list_access_keys_for_tournament(tournament_id, user)


@router.put("/access-keys/{access_key_id}/disable", response_model=AccessKeyResponse)
def disable_access_key_admin(access_key_id: str, user=Depends(get_current_user)):
    return disable_access_key(access_key_id, user)
