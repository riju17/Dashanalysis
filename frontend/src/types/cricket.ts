export type Team = {
  id: string;
  team_name: string;
  short_name?: string | null;
  primary_color?: string | null;
  secondary_color?: string | null;
  accent_color?: string | null;
  logo_url?: string | null;
  created_at?: string;
};

export type Venue = {
  id: string;
  venue_name: string;
  city?: string | null;
  country?: string | null;
  created_at?: string;
};

export type Player = {
  id: string;
  player_name: string;
  team_id: string;
  role?: string | null;
  batting_style?: string | null;
  bowling_style?: string | null;
  created_at?: string;
};

export type MatchRecord = {
  id: string;
  match_date: string;
  season: string;
  tournament: string;
  match_number: number;
  team_a_id: string;
  team_b_id: string;
  venue_id: string;
  toss_winner_id?: string | null;
  toss_decision?: string | null;
  bat_first_team_id?: string | null;
  bowl_first_team_id?: string | null;
  first_innings_score?: number | null;
  first_innings_wickets?: number | null;
  first_innings_overs?: number | null;
  second_innings_score?: number | null;
  second_innings_wickets?: number | null;
  second_innings_overs?: number | null;
  winner_id?: string | null;
  loser_id?: string | null;
  result_type?: string | null;
  margin_runs?: number | null;
  margin_wickets?: number | null;
  player_of_match_id?: string | null;
  notes?: string | null;
  created_at?: string;
};

export type MatchPlayerStatRecord = {
  id: string;
  match_id: string;
  player_id: string;
  team_id: string;
  batting_position?: number | null;
  runs: number;
  balls: number;
  fours: number;
  sixes: number;
  strike_rate?: number | null;
  overs: number;
  maidens: number;
  runs_conceded: number;
  wickets: number;
  dot_balls: number;
  economy?: number | null;
  catches: number;
  runouts: number;
  stumpings: number;
  created_at?: string;
};

export type DashboardData = {
  total_matches: number;
  total_teams: number;
  total_players: number;
  average_first_innings_score: number;
  total_runs: number;
  avg_strike_rate: number;
  avg_economy: number;
  fours: number;
  sixes: number;
  wickets_taken: number;
  chase_win_percentage: number;
  bat_first_win_percentage: number;
  toss_conversion_percentage: number;
  highest_score: number;
  top_run_scorers: Array<{ player_id: string; player_name: string; runs: number }>;
  top_wicket_takers: Array<{ player_id: string; player_name: string; wickets: number }>;
  team_win_percentage_chart: Array<Record<string, number | string>>;
  venue_score_chart: Array<Record<string, number | string>>;
  summary_points: string[];
};

export type TeamAnalytics = {
  team: Team;
  metrics: Record<string, number>;
  insights: string[];
  recent_matches: MatchRecord[];
  head_to_head_summary?: Array<Record<string, number | string>>;
};

export type PlayerAnalytics = {
  player: Player;
  batting: Record<string, number>;
  bowling: Record<string, number>;
  impact: Record<string, number>;
  insights: string[];
};

export type VenueAnalytics = {
  venue: Venue;
  metrics: Record<string, number>;
  insights: string[];
};

export type TossAnalytics = {
  overall: Record<string, number>;
  team_wise: Array<Record<string, number | string>>;
  insights: string[];
};

export type StandingRow = {
  team_id: string;
  team_name: string;
  played: number;
  wins: number;
  losses: number;
  points: number;
  nrr: string;
};

export type PredictionInput = {
  team_a_id: string;
  team_b_id: string;
  venue_id: string;
  toss_winner_id?: string;
  toss_decision?: string;
  bat_first_team_id?: string;
};

export type PredictionOutput = {
  team_a_win_probability: number;
  team_b_win_probability: number;
  recommended_decision: string;
  confidence_level: string;
  reasoning_points: string[];
  key_advantages: string[];
  risk_factors: string[];
  raw_score: Record<string, number>;
};

export type ReportRecord = {
  id: string;
  match_id: string;
  report_title: string;
  report_json: Record<string, unknown>;
  created_at?: string;
};

export type MatchReportCreateResponse = {
  report: ReportRecord;
};

export type ParsedBattingRow = {
  player_name: string;
  dismissal: string;
  runs: number;
  balls: number;
  dots: number;
  fours: number;
  sixes: number;
  strike_rate: number;
  is_not_out: boolean;
  is_captain: boolean;
  is_wicketkeeper: boolean;
};

export type ParsedBowlingRow = {
  player_name: string;
  overs: number;
  maidens: number;
  runs_conceded: number;
  wickets: number;
  dots: number;
  wides: number;
  no_balls: number;
  economy: number;
};

export type ParsedFowRow = {
  score: number;
  wicket_number: number;
  player_out: string;
  over: number;
};

export type ParsedInnings = {
  team_name: string;
  score: number;
  wickets: number;
  overs: number;
  run_rate: number;
  extras: number;
  extras_breakdown: Record<string, number>;
  batting: ParsedBattingRow[];
  bowling: ParsedBowlingRow[];
  fall_of_wickets: ParsedFowRow[];
  yet_to_bat: string[];
};

export type ParsedMatchImport = {
  match_details: {
    venue: string;
    city: string;
    match_date: string;
    match_time: string;
    toss_winner: string;
    toss_decision: string;
    player_of_match: string;
    umpires: string[];
    match_number?: number | null;
  };
  innings: ParsedInnings[];
  result: {
    winner: string;
    loser: string;
    result_type: string;
    margin_runs: number;
    margin_wickets: number;
  };
  parser_warnings: string[];
  confidence_score: number;
};

export type MatchImportRecord = {
  id: string;
  import_type: string;
  raw_text: string;
  parsed_json: ParsedMatchImport;
  confidence_score: number;
  status: string;
  created_at?: string;
};

export type ImportConfirmPayload = {
  import_id: string;
  parsed_json: ParsedMatchImport;
};

export type ImportConfirmResult = {
  import_record: MatchImportRecord;
  match: MatchRecord;
  report?: Record<string, unknown> | null;
  warnings: string[];
};
