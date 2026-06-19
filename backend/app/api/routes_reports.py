from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, status

from app.api.deps import require_role
from app.models.schemas import (
    MatchReportCreateResponse,
    ReportExportRequest,
    PlayerPerformanceReportRequest,
    PlayerPerformanceReportResponse,
    ReportResponse,
)
from app.data.store import store
from app.services.analytics_service import analytics_service
from app.services.report_export_service import report_export_service
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


@router.post("/player-performance", response_model=PlayerPerformanceReportResponse)
def create_player_performance_report(payload: PlayerPerformanceReportRequest, x_user_role: str = Depends(require_role)):
    if payload.use_venue_filter and payload.venue_id is None:
        raise HTTPException(status_code=400, detail="venue_id is required when venue filtering is enabled")
    if payload.venue_id is not None and not store.get("venues", str(payload.venue_id)):
        raise HTTPException(status_code=404, detail="Venue not found")
    return analytics_service.player_performance_report(
        mode=payload.mode,
        style=payload.style,
        venue_id=str(payload.venue_id) if payload.venue_id else None,
        include_venue=payload.use_venue_filter,
        team_ids=[str(team_id) for team_id in payload.team_ids] if payload.team_ids else None,
    )


@router.post("/export")
def export_report(payload: ReportExportRequest, x_user_role: str = Depends(require_role)):
    if payload.report_kind == "match":
        if payload.match_report is None:
            raise HTTPException(status_code=400, detail="match_report is required for match exports")
        return report_export_service.export_match_report(payload.match_report, payload.format)
    if payload.performance_report is None:
        raise HTTPException(status_code=400, detail="performance_report is required for performance exports")
    return report_export_service.export_performance_report(payload.performance_report.model_dump(), payload.format)


@router.get("/{report_id}", response_model=ReportResponse)
def get_report(report_id: str):
    report = report_service.get_report(report_id)
    if not report:
        raise HTTPException(status_code=404, detail="Report not found")
    return report
