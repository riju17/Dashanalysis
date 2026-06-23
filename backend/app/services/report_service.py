from __future__ import annotations

from datetime import datetime
from uuid import uuid4

from app.data.store import store
from app.services.insights_service import insights_service


class ReportService:
    def __init__(self, data_store=store):
        self.store = data_store

    def generate_match_report(self, match_id: str) -> dict:
        report_payload = insights_service.generate_match_report(match_id)
        if not report_payload:
            return {}
        match = self.store.get("matches", match_id)
        report = {
            "id": str(uuid4()),
            "match_id": match_id,
            "report_title": f"{match['tournament']} Match {match['match_number']} Intelligence Report",
            "report_json": report_payload,
            "created_at": datetime.utcnow().isoformat(),
        }
        self.store.insert("reports", report)
        return report

    def get_report(self, report_id: str):
        return self.store.get("reports", report_id)


report_service = ReportService()
