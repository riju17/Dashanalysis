from __future__ import annotations

from functools import lru_cache
from typing import Any, Optional

from app.core.config import settings


@lru_cache(maxsize=1)
def get_supabase_client() -> Optional[Any]:
    if not settings.supabase_url or not settings.supabase_service_key:
        return None
    try:
        from supabase import create_client
    except Exception:
        return None
    return create_client(settings.supabase_url, settings.supabase_service_key)
