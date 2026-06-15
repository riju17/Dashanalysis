from __future__ import annotations

from functools import lru_cache
from pathlib import Path
from typing import List, Optional

from dotenv import load_dotenv
from pydantic import BaseModel, Field


load_dotenv(Path(__file__).resolve().parents[2] / ".env", override=False)


class Settings(BaseModel):
    app_name: str = Field(default="StatStrike Match Intelligence Engine")
    app_env: str = Field(default="development")
    supabase_url: Optional[str] = None
    supabase_service_key: Optional[str] = None
    supabase_anon_key: Optional[str] = None
    allowed_origins: List[str] = Field(default_factory=lambda: ["http://localhost:3000"])


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    import os

    allowed_origins_raw = os.getenv("ALLOWED_ORIGINS", "http://localhost:3000")
    return Settings(
        app_name=os.getenv("APP_NAME", "StatStrike Match Intelligence Engine"),
        app_env=os.getenv("APP_ENV", "development"),
        supabase_url=os.getenv("SUPABASE_URL"),
        supabase_service_key=os.getenv("SUPABASE_SERVICE_KEY"),
        supabase_anon_key=os.getenv("SUPABASE_ANON_KEY"),
        allowed_origins=[origin.strip() for origin in allowed_origins_raw.split(",") if origin.strip()],
    )


settings = get_settings()
