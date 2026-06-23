from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, status

from app.api.deps import get_current_user
from app.models.schemas import (
    ReportExportRequest,
    ReportResponse,
)
from app.services.report_export_service import report_export_service


router = APIRouter()


@router.get("")
def list_reports(user=Depends(get_current_user)):
    raise HTTPException(status_code=400, detail="Use /tournaments/{slug}/reports for scoped report data")

@router.post("/export")
def export_report(payload: ReportExportRequest, user=Depends(get_current_user)):
    if payload.report_kind == "match":
        if payload.match_report is None:
            raise HTTPException(status_code=400, detail="match_report is required for match exports")
        return report_export_service.export_match_report(payload.match_report, payload.format)
    if payload.performance_report is None:
        raise HTTPException(status_code=400, detail="performance_report is required for performance exports")
    return report_export_service.export_performance_report(payload.performance_report.model_dump(), payload.format)


@router.get("/{report_id}", response_model=ReportResponse)
def get_report(report_id: str, user=Depends(get_current_user)):
    raise HTTPException(status_code=400, detail="Use /tournaments/{slug}/reports for scoped report data")
