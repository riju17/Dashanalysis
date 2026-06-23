from __future__ import annotations

from typing import Annotated, Optional

from fastapi import Depends, Header, HTTPException, status

from app.core.supabase_client import get_supabase_client
from app.services.tournament_service import (
    AuthenticatedUser,
    bootstrap_local_dev_state,
    ensure_platform_admin,
    get_local_dev_user,
    local_dev_auth_enabled,
)


def _extract_bearer_token(authorization: Optional[str]) -> Optional[str]:
    if not authorization:
        return None
    scheme, _, token = authorization.partition(" ")
    if scheme.lower() != "bearer" or not token.strip():
        return None
    return token.strip()


def get_optional_current_user(authorization: Annotated[Optional[str], Header()] = None) -> Optional[AuthenticatedUser]:
    token = _extract_bearer_token(authorization)
    if not token:
        if local_dev_auth_enabled():
            user = get_local_dev_user()
            bootstrap_local_dev_state(user)
            return user
        return None
    client = get_supabase_client()
    if client is None:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Supabase is not configured")
    try:
        response = client.auth.get_user(token)
        user = getattr(response, "user", None)
    except Exception as exc:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid authentication token") from exc
    if user is None or not getattr(user, "id", None):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid authentication token")
    return AuthenticatedUser(
        id=str(user.id),
        email=getattr(user, "email", None),
        raw_user=user,
    )


def get_current_user(user: Annotated[Optional[AuthenticatedUser], Depends(get_optional_current_user)]) -> AuthenticatedUser:
    if user is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Authentication is required")
    return user


def require_platform_admin_user(user: Annotated[AuthenticatedUser, Depends(get_current_user)]) -> AuthenticatedUser:
    ensure_platform_admin(user)
    return user
