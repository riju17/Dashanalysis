from __future__ import annotations

from datetime import datetime
from uuid import uuid4
from typing import Any

from app.data.store import store
from app.services.insights_service import insights_service


class ReportService:
    def __init__(self, data_store=store):
        self.store = data_store

    def generate_match_report(self, match_id: str, context: dict[str, list[dict[str, Any]]] | None = None) -> dict:
        report_payload = insights_service.generate_match_report(match_id, context=context)
        if not report_payload:
            return {}
        match = next((row for row in (context or {}).get("matches", []) if str(row.get("id")) == str(match_id)), None) if context else None
        if not match:
            match = self.store.get("matches", match_id)
        report = {
            "id": str(uuid4()),
            "match_id": match_id,
            "tournament_id": match.get("tournament_id") if match else None,
            "report_title": f"{match['tournament']} Match {match['match_number']} Intelligence Report",
            "report_json": report_payload,
            "created_at": datetime.utcnow().isoformat(),
        }
        self.store.insert("reports", report)
        return report

    def get_report(self, report_id: str):
        return self.store.get("reports", report_id)


report_service = ReportService()
