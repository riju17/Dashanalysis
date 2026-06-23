from __future__ import annotations

from fastapi import HTTPException, Header, status


ALLOWED_ROLES = ("Admin", "Analyst")


def require_role(x_user_role: str = Header(default="Analyst")) -> str:
    if x_user_role not in ALLOWED_ROLES:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Insufficient permissions")
    return x_user_role
