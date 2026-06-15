from __future__ import annotations

from datetime import date, datetime
from typing import Any, Optional
from uuid import UUID

from pydantic import BaseModel, Field


class TeamBase(BaseModel):
    team_name: str
    short_name: Optional[str] = None
    primary_color: Optional[str] = None
    secondary_color: Optional[str] = None
    accent_color: Optional[str] = None
    logo_url: Optional[str] = None


class TeamCreate(TeamBase):
    pass


class TeamUpdate(BaseModel):
    team_name: Optional[str] = None
    short_name: Optional[str] = None
    primary_color: Optional[str] = None
    secondary_color: Optional[str] = None
    accent_color: Optional[str] = None
    logo_url: Optional[str] = None


class TeamResponse(TeamBase):
    id: UUID
    created_at: datetime


class VenueBase(BaseModel):
    venue_name: str
    city: Optional[str] = None
    country: Optional[str] = None


class VenueCreate(VenueBase):
    pass


class VenueResponse(VenueBase):
    id: UUID
    created_at: datetime


class PlayerBase(BaseModel):
    player_name: str
    team_id: UUID
    role: Optional[str] = None
    batting_style: Optional[str] = None
    bowling_style: Optional[str] = None


class PlayerCreate(PlayerBase):
    pass


class PlayerResponse(PlayerBase):
    id: UUID
    created_at: datetime


class MatchBase(BaseModel):
    match_date: date
    season: str
    tournament: str
    match_number: int
    team_a_id: UUID
    team_b_id: UUID
    venue_id: UUID
    toss_winner_id: Optional[UUID] = None
    toss_decision: Optional[str] = None
    bat_first_team_id: Optional[UUID] = None
    bowl_first_team_id: Optional[UUID] = None
    first_innings_score: Optional[int] = None
    first_innings_wickets: Optional[int] = None
    first_innings_overs: Optional[float] = None
    second_innings_score: Optional[int] = None
    second_innings_wickets: Optional[int] = None
    second_innings_overs: Optional[float] = None
    winner_id: Optional[UUID] = None
    loser_id: Optional[UUID] = None
    result_type: Optional[str] = None
    margin_runs: Optional[int] = None
    margin_wickets: Optional[int] = None
    player_of_match_id: Optional[UUID] = None
    notes: Optional[str] = None


class MatchCreate(MatchBase):
    pass


class MatchResponse(MatchBase):
    id: UUID
    created_at: datetime


class PlayerMatchStatBase(BaseModel):
    match_id: UUID
    player_id: UUID
    team_id: UUID
    batting_position: Optional[int] = None
    runs: int = 0
    balls: int = 0
    fours: int = 0
    sixes: int = 0
    strike_rate: Optional[float] = None
    overs: float = 0
    maidens: int = 0
    runs_conceded: int = 0
    wickets: int = 0
    dot_balls: int = 0
    economy: Optional[float] = None
    catches: int = 0
    runouts: int = 0
    stumpings: int = 0


class PlayerMatchStatCreate(PlayerMatchStatBase):
    pass


class PlayerMatchStatResponse(PlayerMatchStatBase):
    id: UUID
    created_at: datetime


class TournamentBase(BaseModel):
    tournament_name: str
    season: str
    start_date: Optional[date] = None
    end_date: Optional[date] = None


class TournamentResponse(TournamentBase):
    id: UUID
    created_at: datetime


class ReportResponse(BaseModel):
    id: UUID
    match_id: UUID
    report_title: str
    report_json: dict[str, Any]
    created_at: datetime


class DashboardResponse(BaseModel):
    total_matches: int
    total_teams: int
    total_players: int
    average_first_innings_score: float
    chase_win_percentage: float
    bat_first_win_percentage: float
    toss_conversion_percentage: float
    highest_score: int
    top_run_scorers: list[dict[str, Any]]
    top_wicket_takers: list[dict[str, Any]]
    team_win_percentage_chart: list[dict[str, Any]]
    venue_score_chart: list[dict[str, Any]]
    summary_points: list[str]


class TeamAnalyticsResponse(BaseModel):
    team: dict[str, Any]
    metrics: dict[str, Any]
    insights: list[str]
    recent_matches: list[dict[str, Any]]
    head_to_head_summary: list[dict[str, Any]] = Field(default_factory=list)


class PlayerAnalyticsResponse(BaseModel):
    player: dict[str, Any]
    batting: dict[str, Any]
    bowling: dict[str, Any]
    impact: dict[str, Any]
    insights: list[str]


class VenueAnalyticsResponse(BaseModel):
    venue: dict[str, Any]
    metrics: dict[str, Any]
    insights: list[str]


class TossAnalyticsResponse(BaseModel):
    overall: dict[str, Any]
    team_wise: list[dict[str, Any]]
    insights: list[str]


class HeadToHeadResponse(BaseModel):
    team_a: dict[str, Any]
    team_b: dict[str, Any]
    metrics: dict[str, Any]
    recent_matches: list[dict[str, Any]]
    insights: list[str]


class PredictionRequest(BaseModel):
    team_a_id: UUID
    team_b_id: UUID
    venue_id: UUID
    toss_winner_id: Optional[UUID] = None
    toss_decision: Optional[str] = None
    bat_first_team_id: Optional[UUID] = None


class PredictionResponse(BaseModel):
    team_a_win_probability: float
    team_b_win_probability: float
    recommended_decision: str
    confidence_level: str
    reasoning_points: list[str]
    key_advantages: list[str]
    risk_factors: list[str]
    raw_score: dict[str, Any]


class MatchReportCreateResponse(BaseModel):
    report: dict[str, Any]


class ParsedBattingRow(BaseModel):
    player_name: str = ""
    dismissal: str = ""
    runs: int = 0
    balls: int = 0
    dots: int = 0
    fours: int = 0
    sixes: int = 0
    strike_rate: float = 0.0
    is_not_out: bool = False
    is_captain: bool = False
    is_wicketkeeper: bool = False


class ParsedBowlingRow(BaseModel):
    player_name: str = ""
    overs: float = 0.0
    maidens: int = 0
    runs_conceded: int = 0
    wickets: int = 0
    dots: int = 0
    wides: int = 0
    no_balls: int = 0
    economy: float = 0.0


class ParsedFOWRow(BaseModel):
    score: int = 0
    wicket_number: int = 0
    player_out: str = ""
    over: float = 0.0


class ParsedInnings(BaseModel):
    team_name: str = ""
    score: int = 0
    wickets: int = 0
    overs: float = 0.0
    run_rate: float = 0.0
    extras: int = 0
    extras_breakdown: dict[str, int] = Field(default_factory=dict)
    batting: list[ParsedBattingRow] = Field(default_factory=list)
    bowling: list[ParsedBowlingRow] = Field(default_factory=list)
    fall_of_wickets: list[ParsedFOWRow] = Field(default_factory=list)
    yet_to_bat: list[str] = Field(default_factory=list)


class ParsedMatchDetails(BaseModel):
    venue: str = ""
    city: str = ""
    match_date: str = ""
    match_time: str = ""
    toss_winner: str = ""
    toss_decision: str = ""
    player_of_match: str = ""
    umpires: list[str] = Field(default_factory=list)
    match_number: Optional[int] = None


class ParsedMatchResult(BaseModel):
    winner: str = ""
    loser: str = ""
    result_type: str = ""
    margin_runs: int = 0
    margin_wickets: int = 0


class ParsedMatchImport(BaseModel):
    match_details: ParsedMatchDetails = Field(default_factory=ParsedMatchDetails)
    innings: list[ParsedInnings] = Field(default_factory=list)
    result: ParsedMatchResult = Field(default_factory=ParsedMatchResult)
    parser_warnings: list[str] = Field(default_factory=list)
    confidence_score: float = 0.0


class MatchImportResponse(BaseModel):
    id: UUID
    import_type: str
    raw_text: str
    parsed_json: dict[str, Any]
    confidence_score: float
    status: str
    created_at: datetime


class ImportUrlRequest(BaseModel):
    url: str


class ImportConfirmRequest(BaseModel):
    import_id: UUID
    parsed_json: dict[str, Any]


class ImportConfirmResponse(BaseModel):
    import_record: dict[str, Any]
    match: dict[str, Any]
    report: Optional[dict[str, Any]] = None
    warnings: list[str] = Field(default_factory=list)
