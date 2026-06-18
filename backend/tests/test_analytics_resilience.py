from __future__ import annotations

import sys
import unittest
from pathlib import Path
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[2]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

BACKEND = Path(__file__).resolve().parents[1]
if str(BACKEND) not in sys.path:
    sys.path.insert(0, str(BACKEND))

from fastapi.testclient import TestClient

from backend.main import app
from app.api.routes_dashboard import analytics_service
from app.data.store import store


class FakeSupabaseTable:
    def __init__(self, rows):
        self.rows = rows
        self.execute_calls = 0

    def select(self, *_args, **_kwargs):
        return self

    def execute(self):
        self.execute_calls += 1

        class Response:
            def __init__(self, data):
                self.data = data

        return Response(self.rows)


class FakeSupabaseClient:
    def __init__(self, rows):
        self.table_calls = 0
        self._table = FakeSupabaseTable(rows)

    def table(self, _name):
        self.table_calls += 1
        return self._table


class AnalyticsResilienceTests(unittest.TestCase):
    def setUp(self):
        store.reset()

    def test_dashboard_route_returns_partial_payload_when_service_fails(self):
        client = TestClient(app)

        with patch.object(analytics_service, "dashboard_summary", side_effect=RuntimeError("boom")):
            response = client.get("/analytics/dashboard")

        self.assertEqual(response.status_code, 200)
        payload = response.json()
        self.assertEqual(payload["total_matches"], 0)
        self.assertEqual(payload["total_teams"], 0)
        self.assertEqual(payload["summary_points"], [])
        self.assertIn("top_run_scorers", payload)

    def test_store_list_uses_cached_remote_snapshot(self):
        fake_client = FakeSupabaseClient([{"id": "1", "team_name": "Alpha"}])

        with patch.object(store, "_supabase", return_value=fake_client):
            first = store.list("teams")
            second = store.list("teams")

        self.assertEqual(first, second)
        self.assertEqual(fake_client.table_calls, 1)
        self.assertEqual(fake_client._table.execute_calls, 1)


if __name__ == "__main__":
    unittest.main()
