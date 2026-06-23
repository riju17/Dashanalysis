from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
import hashlib
import re
import secrets
from typing import Any
from uuid import NAMESPACE_URL, uuid5

from fastapi import HTTPException, status

from app.core.config import settings
from app.core.supabase_client import get_supabase_client
from app.data.store import store


ROLE_PRIORITY = {
    "viewer": 0,
    "analyst": 1,
    "admin": 2,
    "owner": 3,
}

READ_ROLES = {"viewer", "analyst", "admin", "owner"}
WRITE_ROLES = {"analyst", "admin", "owner"}
ADMIN_ROLES = {"admin", "owner"}
OWNER_ONLY_ROLES = {"owner"}


@dataclass
class AuthenticatedUser:
    id: str
    email: str | None = None
    raw_user: Any | None = None


def _utc_now() -> datetime:
    return datetime.now(timezone.utc)


def _parse_datetime(value: Any) -> datetime | None:
    if value in {None, ""}:
        return None
    if isinstance(value, datetime):
        if value.tzinfo is None:
            return value.replace(tzinfo=timezone.utc)
        return value.astimezone(timezone.utc)
    parsed = None
    try:
        parsed = datetime.fromisoformat(str(value).replace("Z", "+00:00"))
    except ValueError:
        return None
    if parsed.tzinfo is None:
        return parsed.replace(tzinfo=timezone.utc)
    return parsed.astimezone(timezone.utc)


def normalize_role(role: Any) -> str:
    normalized = str(role or "").strip().lower()
    if normalized not in ROLE_PRIORITY:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid role")
    return normalized


def is_platform_owner(user_id: str) -> bool:
    return str(user_id) in set(settings.platform_owner_ids)


def local_dev_auth_enabled() -> bool:
    return settings.app_env.lower() != "production" and settings.enable_local_dev_auth


def get_local_dev_user() -> AuthenticatedUser:
    return AuthenticatedUser(
        id=str(settings.local_dev_user_id),
        email=settings.local_dev_user_email,
        raw_user={"local_dev": True},
    )


def _local_dev_tournament_defaults() -> dict[str, str]:
    return {
        "id": str(uuid5(NAMESPACE_URL, "statstrike:tournament:mpt20-2026")),
        "name": "MPT20 2026",
        "slug": "mpt20-2026",
        "season": "2026",
    }


def bootstrap_local_dev_state(user: AuthenticatedUser | None = None) -> None:
    if not local_dev_auth_enabled() or get_supabase_client() is not None:
        return

    acting_user = user or get_local_dev_user()
    defaults = _local_dev_tournament_defaults()
    tournament = next(
        (
            row
            for row in store.list("tournaments")
            if str(row.get("slug") or "").strip().lower() == defaults["slug"]
        ),
        None,
    )
    if not tournament:
        tournament = store.insert(
            "tournaments",
            {
                "id": defaults["id"],
                "name": defaults["name"],
                "slug": defaults["slug"],
                "season": defaults["season"],
                "description": "Local development tournament bootstrap",
                "logo_url": None,
                "start_date": None,
                "end_date": None,
                "is_active": True,
                "created_by": acting_user.id,
            },
        )

    existing_access = store.find_one("user_tournament_access", user_id=str(acting_user.id), tournament_id=str(tournament["id"]))
    if not existing_access:
        store.insert(
            "user_tournament_access",
            {
                "user_id": acting_user.id,
                "tournament_id": str(tournament["id"]),
                "role": "owner",
                "access_expires_at": None,
                "is_active": True,
                "email": acting_user.email,
            },
        )


def role_satisfies(role: str, allowed_roles: set[str] | list[str] | tuple[str, ...] | None) -> bool:
    if allowed_roles is None:
        return True
    normalized_role = normalize_role(role)
    normalized_allowed = {normalize_role(candidate) for candidate in allowed_roles}
    return normalized_role in normalized_allowed


def stronger_role(*roles: str) -> str:
    normalized_roles = [normalize_role(role) for role in roles if role]
    return max(normalized_roles, key=lambda role: ROLE_PRIORITY[role]) if normalized_roles else "viewer"


def is_access_row_active(row: dict[str, Any]) -> bool:
    if not row or not row.get("is_active", True):
        return False
    expires_at = _parse_datetime(row.get("access_expires_at"))
    return expires_at is None or expires_at > _utc_now()


def hash_access_key(raw_key: str) -> str:
    return hashlib.sha256(raw_key.strip().encode("utf-8")).hexdigest()


def list_all_tournaments() -> list[dict[str, Any]]:
    bootstrap_local_dev_state()
    return store.list("tournaments")


def get_tournament_by_slug(slug: str) -> dict[str, Any] | None:
    normalized_slug = str(slug or "").strip().lower()
    return next((row for row in list_all_tournaments() if str(row.get("slug") or "").strip().lower() == normalized_slug), None)


def get_tournament_by_id(tournament_id: str) -> dict[str, Any] | None:
    return next((row for row in list_all_tournaments() if str(row.get("id")) == str(tournament_id)), None)


def _list_access_rows(user_id: str, tournament_id: str | None = None, include_inactive: bool = False) -> list[dict[str, Any]]:
    rows = store.list("user_tournament_access")
    filtered: list[dict[str, Any]] = []
    for row in rows:
        if str(row.get("user_id")) != str(user_id):
            continue
        if tournament_id and str(row.get("tournament_id")) != str(tournament_id):
            continue
        if include_inactive or is_access_row_active(row):
            filtered.append(row)
    return filtered


def resolve_user_role(user_id: str, tournament_id: str) -> str | None:
    if is_platform_owner(user_id):
        return "owner"
    roles = [normalize_role(row.get("role")) for row in _list_access_rows(user_id, tournament_id=tournament_id)]
    if not roles:
        return None
    return stronger_role(*roles)


def ensure_tournament_access(
    user: AuthenticatedUser,
    tournament: dict[str, Any],
    allowed_roles: set[str] | list[str] | tuple[str, ...] | None = None,
) -> str:
    role = resolve_user_role(user.id, str(tournament.get("id")))
    if role is None:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You do not have access to this tournament")
    if allowed_roles and not role_satisfies(role, allowed_roles):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You do not have permission for this tournament")
    return role


def ensure_platform_admin(user: AuthenticatedUser) -> None:
    if is_platform_owner(user.id):
        return
    rows = _list_access_rows(user.id)
    if any(role_satisfies(str(row.get("role")), ADMIN_ROLES) for row in rows):
        return
    raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Platform admin access is required")


def list_accessible_tournaments(user: AuthenticatedUser) -> list[dict[str, Any]]:
    tournaments = list_all_tournaments()
    if is_platform_owner(user.id):
        return tournaments
    active_tournament_ids = {str(row.get("tournament_id")) for row in _list_access_rows(user.id)}
    return [row for row in tournaments if str(row.get("id")) in active_tournament_ids]


def _filter_rows(table: str, tournament_id: str) -> list[dict[str, Any]]:
    return [row for row in store.list(table) if str(row.get("tournament_id")) == str(tournament_id)]


def build_tournament_context(tournament_id: str) -> dict[str, list[dict[str, Any]]]:
    return {
        "teams": _filter_rows("teams", tournament_id),
        "players": _filter_rows("players", tournament_id),
        "venues": _filter_rows("venues", tournament_id),
        "matches": _filter_rows("matches", tournament_id),
        "player_match_stats": _filter_rows("player_match_stats", tournament_id),
        "reports": _filter_rows("reports", tournament_id),
        "match_imports": _filter_rows("match_imports", tournament_id),
        "tournaments": [row for row in list_all_tournaments() if str(row.get("id")) == str(tournament_id)],
    }


def ensure_resource_belongs_to_tournament(resource: dict[str, Any] | None, tournament_id: str, label: str) -> dict[str, Any]:
    if not resource or str(resource.get("tournament_id")) != str(tournament_id):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"{label} not found")
    return resource


def create_owner_access(user_id: str, tournament_id: str) -> dict[str, Any]:
    existing = store.find_one("user_tournament_access", user_id=str(user_id), tournament_id=str(tournament_id))
    payload = {
        "user_id": str(user_id),
        "tournament_id": str(tournament_id),
        "role": "owner",
        "access_expires_at": None,
        "is_active": True,
    }
    if existing:
        return store.update("user_tournament_access", existing["id"], payload) or {**existing, **payload}
    return store.insert("user_tournament_access", payload)


def create_tournament(payload: dict[str, Any], user: AuthenticatedUser) -> dict[str, Any]:
    ensure_platform_admin(user)
    slug = str(payload.get("slug") or "").strip().lower()
    if not slug:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="slug is required")
    if get_tournament_by_slug(slug):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Tournament slug already exists")
    record = store.insert(
        "tournaments",
        {
            "name": str(payload.get("name") or "").strip(),
            "slug": slug,
            "season": str(payload.get("season") or "").strip(),
            "description": payload.get("description"),
            "logo_url": payload.get("logo_url"),
            "start_date": payload.get("start_date"),
            "end_date": payload.get("end_date"),
            "is_active": bool(payload.get("is_active", True)),
            "created_by": user.id,
        },
    )
    create_owner_access(user.id, str(record["id"]))
    log_audit_event(user.id, "tournament_created", str(record["id"]), {"slug": slug, "name": record.get("name")})
    return record


def update_tournament(tournament_id: str, payload: dict[str, Any], user: AuthenticatedUser) -> dict[str, Any]:
    tournament = get_tournament_by_id(tournament_id)
    if not tournament:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Tournament not found")
    if not is_platform_owner(user.id):
        ensure_tournament_access(user, tournament, ADMIN_ROLES)
    if "slug" in payload and payload["slug"]:
        normalized_slug = str(payload["slug"]).strip().lower()
        existing = get_tournament_by_slug(normalized_slug)
        if existing and str(existing.get("id")) != str(tournament_id):
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Tournament slug already exists")
        payload["slug"] = normalized_slug
    updated = store.update("tournaments", tournament_id, payload)
    log_audit_event(user.id, "tournament_updated", tournament_id, {"fields": sorted(payload.keys())})
    return updated or {**tournament, **payload}


def _friendly_tournament_code(tournament: dict[str, Any]) -> str:
    slug = str(tournament.get("slug") or "tournament").upper()
    slug = re.sub(r"[^A-Z0-9]+", "-", slug).strip("-")
    if not slug:
        slug = "TOURNAMENT"
    return slug[:16]


def generate_access_key_value(tournament: dict[str, Any]) -> str:
    chunk_one = secrets.token_hex(2).upper()
    chunk_two = secrets.token_hex(2).upper()
    return f"STAT-{_friendly_tournament_code(tournament)}-{chunk_one}-{chunk_two}"


def _resolve_access_expiry(expires_at: Any, access_duration_days: int | None) -> datetime:
    key_expiry = _parse_datetime(expires_at)
    if key_expiry is None:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="expires_at is required")
    if access_duration_days and access_duration_days > 0:
        derived_expiry = _utc_now() + timedelta(days=int(access_duration_days))
        return min(key_expiry, derived_expiry)
    return key_expiry


def log_audit_event(user_id: str | None, action: str, tournament_id: str | None, metadata: dict[str, Any] | None = None) -> dict[str, Any]:
    return store.insert(
        "audit_logs",
        {
            "user_id": user_id,
            "action": action,
            "tournament_id": tournament_id,
            "metadata": metadata or {},
        },
    )


def list_tournament_access_rows(tournament_id: str) -> list[dict[str, Any]]:
    return [row for row in store.list("user_tournament_access") if str(row.get("tournament_id")) == str(tournament_id)]


def list_tournament_access_with_users(tournament_id: str) -> list[dict[str, Any]]:
    rows = list_tournament_access_rows(tournament_id)
    client = get_supabase_client()
    email_by_user_id: dict[str, str | None] = {}
    if client is not None:
        try:
            users = client.auth.admin.list_users(page=1, per_page=1000) or []
            email_by_user_id = {str(user.id): getattr(user, "email", None) for user in users}
        except Exception:
            email_by_user_id = {}
    elif local_dev_auth_enabled():
        email_by_user_id[str(settings.local_dev_user_id)] = settings.local_dev_user_email
    enriched = []
    for row in rows:
        enriched.append({**row, "email": email_by_user_id.get(str(row.get("user_id")))})
    enriched.sort(key=lambda row: (normalize_role(row.get("role")), str(row.get("email") or row.get("user_id"))))
    return enriched


def upsert_user_tournament_access(
    user_id: str,
    tournament_id: str,
    role: str,
    access_expires_at: datetime | None,
    actor: AuthenticatedUser | None = None,
) -> dict[str, Any]:
    normalized_role = normalize_role(role)
    existing = store.find_one("user_tournament_access", user_id=str(user_id), tournament_id=str(tournament_id))
    payload = {
        "user_id": str(user_id),
        "tournament_id": str(tournament_id),
        "role": normalized_role,
        "access_expires_at": access_expires_at.isoformat() if access_expires_at else None,
        "is_active": True,
    }
    if existing:
        updated = store.update("user_tournament_access", existing["id"], payload) or {**existing, **payload}
        if actor:
            log_audit_event(actor.id, "tournament_access_updated", tournament_id, {"target_user_id": user_id, "role": normalized_role})
        return updated
    created = store.insert("user_tournament_access", payload)
    if actor:
        log_audit_event(actor.id, "tournament_access_granted", tournament_id, {"target_user_id": user_id, "role": normalized_role})
    return created


def revoke_tournament_access(access_id: str, actor: AuthenticatedUser) -> dict[str, Any]:
    existing = store.get("user_tournament_access", access_id)
    if not existing:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Tournament access row not found")
    tournament = get_tournament_by_id(str(existing.get("tournament_id")))
    if not tournament:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Tournament not found")
    if not is_platform_owner(actor.id):
        ensure_tournament_access(actor, tournament, ADMIN_ROLES)
    updated = store.update("user_tournament_access", access_id, {"is_active": False})
    log_audit_event(actor.id, "tournament_access_revoked", str(existing.get("tournament_id")), {"target_user_id": existing.get("user_id")})
    return updated or {**existing, "is_active": False}


def create_access_key(
    tournament_id: str,
    role: str,
    expires_at: Any,
    access_duration_days: int | None,
    max_uses: int,
    actor: AuthenticatedUser,
) -> dict[str, Any]:
    tournament = get_tournament_by_id(tournament_id)
    if not tournament:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Tournament not found")
    if not is_platform_owner(actor.id):
        ensure_tournament_access(actor, tournament, ADMIN_ROLES)
    normalized_role = normalize_role(role)
    raw_key = generate_access_key_value(tournament)
    key_hash = hash_access_key(raw_key)
    record = store.insert(
        "access_keys",
        {
            "key_hash": key_hash,
            "tournament_id": tournament_id,
            "role": normalized_role,
            "expires_at": _parse_datetime(expires_at).isoformat() if _parse_datetime(expires_at) else None,
            "access_duration_days": access_duration_days,
            "max_uses": max_uses or 1,
            "used_count": 0,
            "is_active": True,
            "created_by": actor.id,
        },
    )
    log_audit_event(
        actor.id,
        "access_key_created",
        tournament_id,
        {"access_key_id": record.get("id"), "role": normalized_role, "max_uses": max_uses or 1},
    )
    return {"record": record, "raw_key": raw_key}


def list_access_keys_for_tournament(tournament_id: str, actor: AuthenticatedUser) -> list[dict[str, Any]]:
    tournament = get_tournament_by_id(tournament_id)
    if not tournament:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Tournament not found")
    if not is_platform_owner(actor.id):
        ensure_tournament_access(actor, tournament, ADMIN_ROLES)
    return [row for row in store.list("access_keys") if str(row.get("tournament_id")) == str(tournament_id)]


def disable_access_key(access_key_id: str, actor: AuthenticatedUser) -> dict[str, Any]:
    row = store.get("access_keys", access_key_id)
    if not row:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Access key not found")
    tournament = get_tournament_by_id(str(row.get("tournament_id")))
    if not tournament:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Tournament not found")
    if not is_platform_owner(actor.id):
        ensure_tournament_access(actor, tournament, ADMIN_ROLES)
    updated = store.update("access_keys", access_key_id, {"is_active": False})
    log_audit_event(actor.id, "access_key_disabled", str(row.get("tournament_id")), {"access_key_id": access_key_id})
    return updated or {**row, "is_active": False}


def redeem_access_key(raw_key: str, user: AuthenticatedUser) -> dict[str, Any]:
    normalized_key = str(raw_key or "").strip()
    if not normalized_key:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Access key is required")
    key_hash = hash_access_key(normalized_key)
    access_key = next((row for row in store.list("access_keys") if str(row.get("key_hash")) == key_hash), None)
    if not access_key:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Access key is invalid")
    if not access_key.get("is_active", True):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Access key is inactive")
    key_expiry = _parse_datetime(access_key.get("expires_at"))
    if key_expiry is None or key_expiry <= _utc_now():
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Access key has expired")
    if int(access_key.get("used_count") or 0) >= int(access_key.get("max_uses") or 1):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Access key has reached its maximum uses")

    existing_redemption = next(
        (
            row
            for row in store.list("access_key_redemptions")
            if str(row.get("access_key_id")) == str(access_key.get("id")) and str(row.get("user_id")) == user.id
        ),
        None,
    )
    if existing_redemption:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="You have already redeemed this access key")

    tournament_id = str(access_key.get("tournament_id"))
    expires_at = _resolve_access_expiry(access_key.get("expires_at"), access_key.get("access_duration_days"))
    current_access = store.find_one("user_tournament_access", user_id=user.id, tournament_id=tournament_id)
    next_role = normalize_role(access_key.get("role"))
    next_expiry = expires_at
    if current_access:
        current_role = normalize_role(current_access.get("role"))
        next_role = stronger_role(current_role, next_role)
        current_expiry = _parse_datetime(current_access.get("access_expires_at"))
        if current_expiry and current_expiry > next_expiry:
            next_expiry = current_expiry

    access_row = upsert_user_tournament_access(
        user_id=user.id,
        tournament_id=tournament_id,
        role=next_role,
        access_expires_at=next_expiry,
    )
    store.insert(
        "access_key_redemptions",
        {
            "access_key_id": str(access_key.get("id")),
            "user_id": user.id,
            "redeemed_at": _utc_now().isoformat(),
        },
    )
    store.update(
        "access_keys",
        str(access_key.get("id")),
        {"used_count": int(access_key.get("used_count") or 0) + 1},
    )
    log_audit_event(user.id, "access_key_redeemed", tournament_id, {"access_key_id": access_key.get("id"), "role": next_role})
    tournament = get_tournament_by_id(tournament_id)
    return {
        "tournament": tournament,
        "access": access_row,
    }
