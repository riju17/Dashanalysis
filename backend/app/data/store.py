from __future__ import annotations

from copy import deepcopy
from datetime import datetime
import logging
import time
from threading import Lock
from uuid import uuid4
from typing import Iterable

from fastapi.encoders import jsonable_encoder

from app.core.config import settings
from app.core.supabase_client import get_supabase_client


logger = logging.getLogger(__name__)


class InMemoryStore:
    cache_ttl_seconds = 45

    def __init__(self):
        self._lock = Lock()
        self._cache_lock = Lock()
        self._table_cache: dict[str, dict[str, object]] = {}
        self.reset()

    def reset(self):
        with self._lock:
            self._data = {}
        with self._cache_lock:
            self._table_cache = {}

    def _supabase(self):
        return get_supabase_client()

    def _remote_enabled(self) -> bool:
        return self._supabase() is not None

    def _allow_local_fallback(self) -> bool:
        return settings.app_env.lower() != "production"

    def _raise_if_production(self, message: str):
        if not self._allow_local_fallback():
            raise RuntimeError(message)

    def _remote_table(self, table: str):
        client = self._supabase()
        if client is None:
            return None
        return client.table(table)

    def _cache_entry(self, table: str) -> dict[str, object] | None:
        with self._cache_lock:
            entry = self._table_cache.get(table)
            if not entry:
                return None
            return deepcopy(entry)

    def _cached_rows(self, table: str, allow_stale: bool = False):
        entry = self._cache_entry(table)
        if not entry:
            return None
        expires_at = float(entry.get("expires_at") or 0)
        if allow_stale or expires_at > time.monotonic():
            return deepcopy(entry.get("rows") or [])
        return None

    def _store_cache(self, table: str, rows):
        with self._cache_lock:
            self._table_cache[table] = {
                "rows": deepcopy(rows),
                "expires_at": time.monotonic() + self.cache_ttl_seconds,
            }

    def _invalidate_cache(self, *tables: str):
        with self._cache_lock:
            for table in tables:
                self._table_cache.pop(table, None)

    def _local_rows(self, table: str):
        with self._lock:
            return deepcopy(self._data.get(table, []))

    def snapshot(self, tables: Iterable[str]):
        snapshot: dict[str, list[dict]] = {}
        for table in dict.fromkeys(tables):
            snapshot[table] = self.list(table)
        return snapshot

    def list(self, table: str):
        cached = self._cached_rows(table)
        if cached is not None:
            return cached

        stale_rows = self._cached_rows(table, allow_stale=True)
        remote_table = self._remote_table(table)
        if remote_table is not None:
            try:
                response = remote_table.select("*").execute()
                rows = response.data or []
                self._store_cache(table, rows)
                return deepcopy(rows)
            except Exception:
                logger.exception("Failed to read remote table '%s' for list().", table)
                if stale_rows is not None:
                    self._store_cache(table, stale_rows)
                    return stale_rows

        if stale_rows is not None:
            self._store_cache(table, stale_rows)
            return stale_rows

        rows = self._local_rows(table)
        self._store_cache(table, rows)
        return deepcopy(rows)

    def get(self, table: str, record_id: str):
        for record in self.list(table):
            if str(record.get("id")) == str(record_id):
                return deepcopy(record)
        return None

    def find_one(self, table: str, **filters):
        records = self.filter(table, **filters)
        return records[0] if records else None

    def filter(self, table: str, **filters):
        records = self.list(table)
        if not filters:
            return records
        result = []
        for record in records:
            if all(record.get(key) == value for key, value in filters.items()):
                result.append(deepcopy(record))
        return result

    def insert(self, table: str, payload: dict):
        record = jsonable_encoder(deepcopy(payload))
        record.setdefault("id", str(uuid4()))
        record.setdefault("created_at", datetime.utcnow().isoformat())
        remote_table = self._remote_table(table)
        if remote_table is not None:
            try:
                response = remote_table.insert(record).execute()
                data = response.data or []
                if data:
                    self._invalidate_cache(table)
                    return data[0]
            except Exception:
                self._raise_if_production(f"Failed to insert into remote table '{table}'.")
        with self._lock:
            self._data.setdefault(table, []).append(record)
            self._store_cache(table, self._data.get(table, []))
            return deepcopy(record)

    def update(self, table: str, record_id: str, payload: dict):
        updated_payload = jsonable_encoder(payload)
        remote_table = self._remote_table(table)
        if remote_table is not None:
            try:
                response = remote_table.update(updated_payload).eq("id", record_id).execute()
                data = response.data or []
                if data:
                    self._invalidate_cache(table)
                    return data[0]
            except Exception:
                self._raise_if_production(f"Failed to update remote table '{table}'.")
        with self._lock:
            for index, record in enumerate(self._data.get(table, [])):
                if record["id"] == record_id:
                    updated = {**record, **updated_payload}
                    self._data[table][index] = updated
                    self._store_cache(table, self._data.get(table, []))
                    return deepcopy(updated)
        return None

    def delete(self, table: str, record_id: str):
        remote_table = self._remote_table(table)
        if remote_table is not None:
            try:
                remote_table.delete().eq("id", record_id).execute()
                self._invalidate_cache(table)
                return True
            except Exception:
                self._raise_if_production(f"Failed to delete from remote table '{table}'.")
        with self._lock:
            records = self._data.get(table, [])
            before = len(records)
            self._data[table] = [record for record in records if record["id"] != record_id]
            self._store_cache(table, self._data.get(table, []))
            return before != len(self._data[table])

    def delete_match_cascade(self, match_id: str):
        remote_table = self._remote_table("matches")
        if remote_table is not None:
            try:
                self._remote_table("player_match_stats").delete().eq("match_id", match_id).execute()
                self._remote_table("reports").delete().eq("match_id", match_id).execute()
                remote_table.delete().eq("id", match_id).execute()
                self._invalidate_cache("matches", "player_match_stats", "reports")
                return True
            except Exception:
                self._raise_if_production("Failed to cascade delete match from Supabase.")
        deleted = self.delete("matches", match_id)
        if not deleted:
            return False
        with self._lock:
            self._data["player_match_stats"] = [
                record for record in self._data.get("player_match_stats", []) if record["match_id"] != match_id
            ]
            self._data["reports"] = [record for record in self._data.get("reports", []) if record["match_id"] != match_id]
            self._store_cache("player_match_stats", self._data.get("player_match_stats", []))
            self._store_cache("reports", self._data.get("reports", []))
        return True

    def append_player_stats(self, match_id: str, stats: list[dict]):
        remote_table = self._remote_table("player_match_stats")
        payloads = []
        for stat in stats:
            row = jsonable_encoder(deepcopy(stat))
            row.setdefault("id", str(uuid4()))
            row.setdefault("match_id", match_id)
            row.setdefault("created_at", datetime.utcnow().isoformat())
            payloads.append(row)
        if remote_table is not None:
            try:
                remote_table.insert(payloads).execute()
                self._invalidate_cache("player_match_stats")
                return True
            except Exception:
                self._raise_if_production("Failed to insert player stats into Supabase.")
        with self._lock:
            self._data.setdefault("player_match_stats", [])
            for row in payloads:
                self._data["player_match_stats"].append(row)
            self._store_cache("player_match_stats", self._data.get("player_match_stats", []))
        return True


store = InMemoryStore()
