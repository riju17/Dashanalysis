from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, status

from app.api.deps import require_role
from app.models.schemas import MatchReportCreateResponse, ReportResponse
from app.data.store import store
from app.services.report_service import report_service


router = APIRouter()


@router.get("")
def list_reports():
    return store.list("reports")


@router.post("/match/{match_id}", response_model=MatchReportCreateResponse, status_code=status.HTTP_201_CREATED)
def create_match_report(match_id: str, x_user_role: str = Depends(require_role)):
    report = report_service.generate_match_report(match_id)
    if not report:
        raise HTTPException(status_code=404, detail="Match not found")
    return {"report": report}


@router.get("/{report_id}", response_model=ReportResponse)
def get_report(report_id: str):
    report = report_service.get_report(report_id)
    if not report:
        raise HTTPException(status_code=404, detail="Report not found")
    return report
