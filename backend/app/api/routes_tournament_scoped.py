from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Request, status

from app.api.deps import get_current_user
from app.data.store import store
from app.models.schemas import (
    DashboardResponse,
    HeadToHeadResponse,
    ImportConfirmResponse,
    MatchCreate,
    MatchImportResponse,
    MatchReportCreateResponse,
    MatchResponse,
    PlayerAnalyticsResponse,
    PlayerCreate,
    PlayerMatchStatCreate,
    PlayerMatchStatResponse,
    PlayerPerformanceReportRequest,
    PlayerPerformanceReportResponse,
    PlayerResponse,
    PredictionRequest,
    PredictionResponse,
    ReportResponse,
    StandingRow,
    TeamAnalyticsResponse,
    TeamCreate,
    TeamResponse,
    TeamUpdate,
    TossAnalyticsResponse,
    VenueAnalyticsResponse,
    VenueCreate,
    VenueResponse,
)
from app.services.analytics_service import analytics_service
from app.services.import_service import import_service
from app.services.insights_service import insights_service
from app.services.prediction_service import prediction_service
from app.services.report_service import report_service
from app.services.tournament_service import (
    ADMIN_ROLES,
    READ_ROLES,
    WRITE_ROLES,
    build_tournament_context,
    ensure_resource_belongs_to_tournament,
    ensure_tournament_access,
    get_tournament_by_slug,
)
from app.services.validation_service import (
    validate_match_payload,
    validate_player_payload,
    validate_team_payload,
    validate_venue_payload,
)
from app.utils.cricket_calculations import derive_match_result


router = APIRouter(prefix="/tournaments/{slug}")

try:
    import multipart  # type: ignore  # noqa: F401
    MULTIPART_AVAILABLE = True
except Exception:  # pragma: no cover
    MULTIPART_AVAILABLE = False

if MULTIPART_AVAILABLE:
    from fastapi import File, UploadFile


def _tournament_or_404(slug: str):
    tournament = get_tournament_by_slug(slug)
    if not tournament:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Tournament not found")
    return tournament


def _scoped_context(tournament_id: str):
    return build_tournament_context(tournament_id)


def _scoped_match(tournament_id: str, match_id: str) -> dict:
    return ensure_resource_belongs_to_tournament(store.get("matches", match_id), tournament_id, "Match")


def _scoped_team(tournament_id: str, team_id: str) -> dict:
    return ensure_resource_belongs_to_tournament(store.get("teams", team_id), tournament_id, "Team")


def _scoped_player(tournament_id: str, player_id: str) -> dict:
    return ensure_resource_belongs_to_tournament(store.get("players", player_id), tournament_id, "Player")


def _scoped_venue(tournament_id: str, venue_id: str) -> dict:
    return ensure_resource_belongs_to_tournament(store.get("venues", venue_id), tournament_id, "Venue")


@router.get("/teams", response_model=list[TeamResponse])
def list_teams(slug: str, user=Depends(get_current_user)):
    tournament = _tournament_or_404(slug)
    ensure_tournament_access(user, tournament, READ_ROLES)
    return _scoped_context(str(tournament["id"]))["teams"]


@router.post("/teams", response_model=TeamResponse, status_code=status.HTTP_201_CREATED)
def create_team(slug: str, payload: TeamCreate, user=Depends(get_current_user)):
    tournament = _tournament_or_404(slug)
    ensure_tournament_access(user, tournament, WRITE_ROLES)
    data = payload.model_dump()
    data["tournament_id"] = tournament["id"]
    validate_team_payload(data, tournament_id=str(tournament["id"]))
    return store.insert("teams", data)


@router.get("/teams/{team_id}", response_model=TeamResponse)
def get_team(slug: str, team_id: str, user=Depends(get_current_user)):
    tournament = _tournament_or_404(slug)
    ensure_tournament_access(user, tournament, READ_ROLES)
    return _scoped_team(str(tournament["id"]), team_id)


@router.put("/teams/{team_id}", response_model=TeamResponse)
def update_team(slug: str, team_id: str, payload: TeamUpdate, user=Depends(get_current_user)):
    tournament = _tournament_or_404(slug)
    ensure_tournament_access(user, tournament, WRITE_ROLES)
    existing = _scoped_team(str(tournament["id"]), team_id)
    merged = {**existing, **payload.model_dump(exclude_none=True)}
    validate_team_payload(merged, team_id=team_id, tournament_id=str(tournament["id"]))
    return store.update("teams", team_id, payload.model_dump(exclude_none=True)) or merged


@router.get("/players", response_model=list[PlayerResponse])
def list_players(slug: str, user=Depends(get_current_user)):
    tournament = _tournament_or_404(slug)
    ensure_tournament_access(user, tournament, READ_ROLES)
    return _scoped_context(str(tournament["id"]))["players"]


@router.post("/players", response_model=PlayerResponse, status_code=status.HTTP_201_CREATED)
def create_player(slug: str, payload: PlayerCreate, user=Depends(get_current_user)):
    tournament = _tournament_or_404(slug)
    ensure_tournament_access(user, tournament, WRITE_ROLES)
    data = payload.model_dump()
    data["tournament_id"] = tournament["id"]
    validate_player_payload(data, tournament_id=str(tournament["id"]))
    return store.insert("players", data)


@router.get("/players/team/{team_id}", response_model=list[PlayerResponse])
def list_players_by_team(slug: str, team_id: str, user=Depends(get_current_user)):
    tournament = _tournament_or_404(slug)
    ensure_tournament_access(user, tournament, READ_ROLES)
    _scoped_team(str(tournament["id"]), team_id)
    return [row for row in _scoped_context(str(tournament["id"]))["players"] if str(row.get("team_id")) == str(team_id)]


@router.get("/players/{player_id}", response_model=PlayerResponse)
def get_player(slug: str, player_id: str, user=Depends(get_current_user)):
    tournament = _tournament_or_404(slug)
    ensure_tournament_access(user, tournament, READ_ROLES)
    return _scoped_player(str(tournament["id"]), player_id)


@router.get("/players/{player_id}/analytics", response_model=PlayerAnalyticsResponse)
def player_analytics(slug: str, player_id: str, user=Depends(get_current_user)):
    tournament = _tournament_or_404(slug)
    ensure_tournament_access(user, tournament, READ_ROLES)
    _scoped_player(str(tournament["id"]), player_id)
    return analytics_service.player_summary(player_id, context=_scoped_context(str(tournament["id"])))


@router.get("/venues", response_model=list[VenueResponse])
def list_venues(slug: str, user=Depends(get_current_user)):
    tournament = _tournament_or_404(slug)
    ensure_tournament_access(user, tournament, READ_ROLES)
    return _scoped_context(str(tournament["id"]))["venues"]


@router.post("/venues", response_model=VenueResponse, status_code=status.HTTP_201_CREATED)
def create_venue(slug: str, payload: VenueCreate, user=Depends(get_current_user)):
    tournament = _tournament_or_404(slug)
    ensure_tournament_access(user, tournament, WRITE_ROLES)
    data = payload.model_dump()
    data["tournament_id"] = tournament["id"]
    validate_venue_payload(data, tournament_id=str(tournament["id"]))
    return store.insert("venues", data)


@router.get("/venues/{venue_id}", response_model=VenueResponse)
def get_venue(slug: str, venue_id: str, user=Depends(get_current_user)):
    tournament = _tournament_or_404(slug)
    ensure_tournament_access(user, tournament, READ_ROLES)
    return _scoped_venue(str(tournament["id"]), venue_id)


@router.get("/matches", response_model=list[MatchResponse])
def list_matches(slug: str, user=Depends(get_current_user)):
    tournament = _tournament_or_404(slug)
    ensure_tournament_access(user, tournament, READ_ROLES)
    return _scoped_context(str(tournament["id"]))["matches"]


@router.post("/matches", response_model=MatchResponse, status_code=status.HTTP_201_CREATED)
def create_match(slug: str, payload: MatchCreate, user=Depends(get_current_user)):
    tournament = _tournament_or_404(slug)
    ensure_tournament_access(user, tournament, WRITE_ROLES)
    data = payload.model_dump()
    data["tournament_id"] = tournament["id"]
    data["season"] = str(tournament.get("season") or data.get("season") or "")
    data["tournament"] = str(tournament.get("name") or data.get("tournament") or "")
    derived = derive_match_result(
        data.get("first_innings_score"),
        data.get("second_innings_score"),
        data.get("first_innings_wickets"),
        data.get("second_innings_wickets"),
        str(data.get("bat_first_team_id")) if data.get("bat_first_team_id") else None,
        str(data.get("bowl_first_team_id")) if data.get("bowl_first_team_id") else None,
        data.get("result_type"),
        data.get("margin_runs"),
        data.get("margin_wickets"),
    )
    data.update({key: value for key, value in derived.items() if value is not None or key in {"margin_runs", "margin_wickets"}})
    validate_match_payload(data, tournament_id=str(tournament["id"]))
    return store.insert("matches", data)


@router.get("/matches/{match_id}", response_model=MatchResponse)
def get_match(slug: str, match_id: str, user=Depends(get_current_user)):
    tournament = _tournament_or_404(slug)
    ensure_tournament_access(user, tournament, READ_ROLES)
    return _scoped_match(str(tournament["id"]), match_id)


@router.delete("/matches/{match_id}")
def delete_match(slug: str, match_id: str, user=Depends(get_current_user)):
    tournament = _tournament_or_404(slug)
    ensure_tournament_access(user, tournament, WRITE_ROLES)
    _scoped_match(str(tournament["id"]), match_id)
    deleted = store.delete_match_cascade(match_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Match not found")
    return {"success": True, "message": "Match deleted"}


@router.get("/matches/{match_id}/player-stats", response_model=list[PlayerMatchStatResponse])
def get_match_stats(slug: str, match_id: str, user=Depends(get_current_user)):
    tournament = _tournament_or_404(slug)
    ensure_tournament_access(user, tournament, READ_ROLES)
    _scoped_match(str(tournament["id"]), match_id)
    return [
        row
        for row in _scoped_context(str(tournament["id"]))["player_match_stats"]
        if str(row.get("match_id")) == str(match_id)
    ]


@router.post("/matches/{match_id}/player-stats", response_model=list[PlayerMatchStatResponse], status_code=status.HTTP_201_CREATED)
def create_match_stats(slug: str, match_id: str, payload: list[PlayerMatchStatCreate], user=Depends(get_current_user)):
    tournament = _tournament_or_404(slug)
    ensure_tournament_access(user, tournament, WRITE_ROLES)
    _scoped_match(str(tournament["id"]), match_id)
    rows = []
    for stat in payload:
        data = stat.model_dump()
        data["tournament_id"] = tournament["id"]
        data["match_id"] = match_id
        _scoped_player(str(tournament["id"]), str(data.get("player_id")))
        _scoped_team(str(tournament["id"]), str(data.get("team_id")))
        rows.append(store.insert("player_match_stats", data))
    return rows


@router.get("/analytics/dashboard", response_model=DashboardResponse)
def dashboard(slug: str, user=Depends(get_current_user)):
    tournament = _tournament_or_404(slug)
    ensure_tournament_access(user, tournament, READ_ROLES)
    return analytics_service.dashboard_summary(context=_scoped_context(str(tournament["id"])))


@router.get("/analytics/standings", response_model=list[StandingRow])
def standings(slug: str, user=Depends(get_current_user)):
    tournament = _tournament_or_404(slug)
    ensure_tournament_access(user, tournament, READ_ROLES)
    return analytics_service.standings(context=_scoped_context(str(tournament["id"])))


@router.get("/analytics/team/{team_id}", response_model=TeamAnalyticsResponse)
def team_dashboard(slug: str, team_id: str, user=Depends(get_current_user)):
    tournament = _tournament_or_404(slug)
    ensure_tournament_access(user, tournament, READ_ROLES)
    _scoped_team(str(tournament["id"]), team_id)
    return analytics_service.team_summary(team_id, context=_scoped_context(str(tournament["id"])))


@router.get("/analytics/player/{player_id}", response_model=PlayerAnalyticsResponse)
def player_dashboard(slug: str, player_id: str, user=Depends(get_current_user)):
    tournament = _tournament_or_404(slug)
    ensure_tournament_access(user, tournament, READ_ROLES)
    _scoped_player(str(tournament["id"]), player_id)
    return analytics_service.player_summary(player_id, context=_scoped_context(str(tournament["id"])))


@router.get("/analytics/venue/{venue_id}", response_model=VenueAnalyticsResponse)
def venue_dashboard(slug: str, venue_id: str, user=Depends(get_current_user)):
    tournament = _tournament_or_404(slug)
    ensure_tournament_access(user, tournament, READ_ROLES)
    _scoped_venue(str(tournament["id"]), venue_id)
    return analytics_service.venue_summary(venue_id, context=_scoped_context(str(tournament["id"])))


@router.get("/analytics/toss", response_model=TossAnalyticsResponse)
def toss_dashboard(slug: str, user=Depends(get_current_user)):
    tournament = _tournament_or_404(slug)
    ensure_tournament_access(user, tournament, READ_ROLES)
    return analytics_service.toss_summary(context=_scoped_context(str(tournament["id"])))


@router.get("/analytics/head-to-head/{team_a_id}/{team_b_id}", response_model=HeadToHeadResponse)
def head_to_head(slug: str, team_a_id: str, team_b_id: str, user=Depends(get_current_user)):
    tournament = _tournament_or_404(slug)
    ensure_tournament_access(user, tournament, READ_ROLES)
    _scoped_team(str(tournament["id"]), team_a_id)
    _scoped_team(str(tournament["id"]), team_b_id)
    return analytics_service.head_to_head(team_a_id, team_b_id, context=_scoped_context(str(tournament["id"])))


@router.get("/analytics/opponent-strategy/{our_team_id}/{opponent_team_id}/{venue_id}")
def opponent_strategy(slug: str, our_team_id: str, opponent_team_id: str, venue_id: str, user=Depends(get_current_user)):
    tournament = _tournament_or_404(slug)
    ensure_tournament_access(user, tournament, READ_ROLES)
    _scoped_team(str(tournament["id"]), our_team_id)
    _scoped_team(str(tournament["id"]), opponent_team_id)
    _scoped_venue(str(tournament["id"]), venue_id)
    return insights_service.generate_opponent_strategy(
        our_team_id,
        opponent_team_id,
        venue_id,
        context=_scoped_context(str(tournament["id"])),
    )


@router.post("/prediction/win-probability", response_model=PredictionResponse)
def predict_win_probability(slug: str, payload: PredictionRequest, user=Depends(get_current_user)):
    tournament = _tournament_or_404(slug)
    ensure_tournament_access(user, tournament, READ_ROLES)
    _scoped_team(str(tournament["id"]), str(payload.team_a_id))
    _scoped_team(str(tournament["id"]), str(payload.team_b_id))
    _scoped_venue(str(tournament["id"]), str(payload.venue_id))
    return prediction_service.predict_win_probability(
        team_a_id=str(payload.team_a_id),
        team_b_id=str(payload.team_b_id),
        venue_id=str(payload.venue_id),
        toss_winner_id=str(payload.toss_winner_id) if payload.toss_winner_id else None,
        toss_decision=payload.toss_decision,
        bat_first_team_id=str(payload.bat_first_team_id) if payload.bat_first_team_id else None,
        context=_scoped_context(str(tournament["id"])),
    )


@router.get("/reports", response_model=list[ReportResponse])
def list_reports(slug: str, user=Depends(get_current_user)):
    tournament = _tournament_or_404(slug)
    ensure_tournament_access(user, tournament, READ_ROLES)
    return _scoped_context(str(tournament["id"]))["reports"]


@router.post("/reports/match/{match_id}", response_model=MatchReportCreateResponse, status_code=status.HTTP_201_CREATED)
def create_match_report(slug: str, match_id: str, user=Depends(get_current_user)):
    tournament = _tournament_or_404(slug)
    ensure_tournament_access(user, tournament, WRITE_ROLES)
    _scoped_match(str(tournament["id"]), match_id)
    context = _scoped_context(str(tournament["id"]))
    report = report_service.generate_match_report(match_id, context=context)
    if not report:
        raise HTTPException(status_code=404, detail="Match not found")
    return {"report": report}


@router.post("/reports/player-performance", response_model=PlayerPerformanceReportResponse)
def create_player_performance_report(slug: str, payload: PlayerPerformanceReportRequest, user=Depends(get_current_user)):
    tournament = _tournament_or_404(slug)
    ensure_tournament_access(user, tournament, READ_ROLES)
    context = _scoped_context(str(tournament["id"]))
    if payload.use_venue_filter and payload.venue_id is None:
        raise HTTPException(status_code=400, detail="venue_id is required when venue filtering is enabled")
    if payload.venue_id is not None:
        _scoped_venue(str(tournament["id"]), str(payload.venue_id))
    if payload.team_ids:
        for team_id in payload.team_ids:
            _scoped_team(str(tournament["id"]), str(team_id))
    return analytics_service.player_performance_report(
        mode=payload.mode,
        style=payload.style,
        venue_id=str(payload.venue_id) if payload.venue_id else None,
        include_venue=payload.use_venue_filter,
        team_ids=[str(team_id) for team_id in payload.team_ids] if payload.team_ids else None,
        context=context,
    )


if MULTIPART_AVAILABLE:
    @router.post("/imports/screenshot", response_model=MatchImportResponse, status_code=status.HTTP_201_CREATED)
    async def import_screenshots(slug: str, files: list[UploadFile] = File(...), user=Depends(get_current_user)):
        tournament = _tournament_or_404(slug)
        ensure_tournament_access(user, tournament, WRITE_ROLES)
        return await import_service.import_from_screenshots(files, tournament_id=str(tournament["id"]))


    @router.post("/imports/pdf", response_model=MatchImportResponse, status_code=status.HTTP_201_CREATED)
    async def import_pdf(slug: str, file: UploadFile = File(...), user=Depends(get_current_user)):
        tournament = _tournament_or_404(slug)
        ensure_tournament_access(user, tournament, WRITE_ROLES)
        return await import_service.import_from_pdf(file, tournament_id=str(tournament["id"]))
else:
    @router.post("/imports/screenshot", status_code=status.HTTP_503_SERVICE_UNAVAILABLE)
    async def import_screenshots_unavailable(slug: str, user=Depends(get_current_user)):
        tournament = _tournament_or_404(slug)
        ensure_tournament_access(user, tournament, WRITE_ROLES)
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="python-multipart is not installed. Install backend dependencies and restart the backend.",
        )


    @router.post("/imports/pdf", status_code=status.HTTP_503_SERVICE_UNAVAILABLE)
    async def import_pdf_unavailable(slug: str, user=Depends(get_current_user)):
        tournament = _tournament_or_404(slug)
        ensure_tournament_access(user, tournament, WRITE_ROLES)
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="python-multipart is not installed. Install backend dependencies and restart the backend.",
        )


@router.post("/imports/url", response_model=MatchImportResponse, status_code=status.HTTP_201_CREATED)
async def import_from_url(slug: str, request: Request, user=Depends(get_current_user)):
    tournament = _tournament_or_404(slug)
    ensure_tournament_access(user, tournament, WRITE_ROLES)
    payload = await request.json()
    url = payload.get("url") or payload.get("payload", {}).get("url")
    if not url:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="url is required")
    return import_service.import_from_url(str(url), tournament_id=str(tournament["id"]))


@router.post("/imports/confirm", response_model=ImportConfirmResponse)
async def confirm_import(slug: str, request: Request, user=Depends(get_current_user)):
    tournament = _tournament_or_404(slug)
    ensure_tournament_access(user, tournament, WRITE_ROLES)
    payload = await request.json()
    import_id = payload.get("import_id") or payload.get("payload", {}).get("import_id")
    parsed_json = payload.get("parsed_json") or payload.get("payload", {}).get("parsed_json")
    if not import_id or not parsed_json:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="import_id and parsed_json are required")
    return import_service.confirm_import(str(import_id), parsed_json, tournament_id=str(tournament["id"]))


@router.get("/imports/match/{match_id}", response_model=MatchImportResponse)
def get_import_for_match(slug: str, match_id: str, user=Depends(get_current_user)):
    tournament = _tournament_or_404(slug)
    ensure_tournament_access(user, tournament, READ_ROLES)
    _scoped_match(str(tournament["id"]), match_id)
    return import_service.get_import_for_match(match_id, tournament_id=str(tournament["id"]))


@router.get("/imports/{import_id}", response_model=MatchImportResponse)
def get_import(slug: str, import_id: str, user=Depends(get_current_user)):
    tournament = _tournament_or_404(slug)
    ensure_tournament_access(user, tournament, READ_ROLES)
    return import_service.get_import(import_id, tournament_id=str(tournament["id"]))
