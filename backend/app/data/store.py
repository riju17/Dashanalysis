from __future__ import annotations

from copy import deepcopy
from datetime import datetime
from threading import Lock
from uuid import uuid4

from fastapi.encoders import jsonable_encoder

from app.core.config import settings
from app.core.supabase_client import get_supabase_client


class InMemoryStore:
    def __init__(self):
        self._lock = Lock()
        self.reset()

    def reset(self):
        with self._lock:
            self._data = {}

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
            self._raise_if_production("Supabase is required in production.")
            return None
        return client.table(table)

    def list(self, table: str):
        remote_table = self._remote_table(table)
        if remote_table is not None:
            try:
                response = remote_table.select("*").execute()
                return response.data or []
            except Exception:
                self._raise_if_production(f"Failed to read remote table '{table}'.")
        with self._lock:
            return deepcopy(self._data.get(table, []))

    def get(self, table: str, record_id: str):
        remote_table = self._remote_table(table)
        if remote_table is not None:
            try:
                response = remote_table.select("*").eq("id", record_id).limit(1).execute()
                records = response.data or []
                return records[0] if records else None
            except Exception:
                self._raise_if_production(f"Failed to read remote table '{table}'.")
        with self._lock:
            for record in self._data.get(table, []):
                if record["id"] == record_id:
                    return deepcopy(record)
        return None

    def find_one(self, table: str, **filters):
        records = self.filter(table, **filters)
        return records[0] if records else None

    def filter(self, table: str, **filters):
        remote_table = self._remote_table(table)
        if remote_table is not None:
            try:
                query = remote_table.select("*")
                for key, value in filters.items():
                    query = query.eq(key, value)
                response = query.execute()
                return response.data or []
            except Exception:
                self._raise_if_production(f"Failed to query remote table '{table}'.")
        with self._lock:
            result = []
            for record in self._data.get(table, []):
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
                    return data[0]
            except Exception:
                self._raise_if_production(f"Failed to insert into remote table '{table}'.")
        with self._lock:
            self._data.setdefault(table, []).append(record)
            return deepcopy(record)

    def update(self, table: str, record_id: str, payload: dict):
        updated_payload = jsonable_encoder(payload)
        remote_table = self._remote_table(table)
        if remote_table is not None:
            try:
                response = remote_table.update(updated_payload).eq("id", record_id).execute()
                data = response.data or []
                if data:
                    return data[0]
            except Exception:
                self._raise_if_production(f"Failed to update remote table '{table}'.")
        with self._lock:
            for index, record in enumerate(self._data.get(table, [])):
                if record["id"] == record_id:
                    updated = {**record, **updated_payload}
                    self._data[table][index] = updated
                    return deepcopy(updated)
        return None

    def delete(self, table: str, record_id: str):
        remote_table = self._remote_table(table)
        if remote_table is not None:
            try:
                remote_table.delete().eq("id", record_id).execute()
                return True
            except Exception:
                self._raise_if_production(f"Failed to delete from remote table '{table}'.")
        with self._lock:
            records = self._data.get(table, [])
            before = len(records)
            self._data[table] = [record for record in records if record["id"] != record_id]
            return before != len(self._data[table])

    def delete_match_cascade(self, match_id: str):
        remote_table = self._remote_table("matches")
        if remote_table is not None:
            try:
                self._remote_table("player_match_stats").delete().eq("match_id", match_id).execute()
                self._remote_table("reports").delete().eq("match_id", match_id).execute()
                remote_table.delete().eq("id", match_id).execute()
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
                return True
            except Exception:
                self._raise_if_production("Failed to insert player stats into Supabase.")
        with self._lock:
            self._data.setdefault("player_match_stats", [])
            for row in payloads:
                self._data["player_match_stats"].append(row)
        return True


store = InMemoryStore()
