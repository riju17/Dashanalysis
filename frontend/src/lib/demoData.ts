import { teamThemes } from "@/config/teamThemes";
import roster from "@/data/mpT20Roster.json";
import type {
  DashboardData,
  MatchRecord,
  Player,
  PlayerAnalytics,
  PredictionOutput,
  Team,
  TeamAnalytics,
  TossAnalytics,
  Venue,
  VenueAnalytics,
} from "@/types/cricket";

type RosterTeam = {
  team_name: string;
  short_name: string;
  players: Array<[string, string]>;
};

const rosterTeams = roster.teams as RosterTeam[];
const teamNames = rosterTeams.map((team) => team.team_name);
const teamShortNames: Record<string, string> = Object.fromEntries(
  rosterTeams.map((team) => [team.team_name, team.short_name]),
);
const teamIds: Record<string, string> = Object.fromEntries(
  rosterTeams.map((team, index) => [team.team_name, `team-${index + 1}`]),
);

const roleStyles: Record<string, { batting_style: string; bowling_style: string }> = {
  Batter: {
    batting_style: "Right-hand bat",
    bowling_style: "Right-arm medium",
  },
  Wicketkeeper: {
    batting_style: "Right-hand bat",
    bowling_style: "Right-arm medium",
  },
  "All-rounder": {
    batting_style: "Left-hand bat",
    bowling_style: "Right-arm offbreak",
  },
  Bowler: {
    batting_style: "Right-hand bat",
    bowling_style: "Left-arm fast",
  },
};

export const demoTeams: Team[] = teamNames.map((teamName, index) => ({
  id: `team-${index + 1}`,
  team_name: teamName,
  short_name: teamShortNames[teamName],
  primary_color: teamThemes[teamName].primary,
  secondary_color: teamThemes[teamName].secondary,
  accent_color: teamThemes[teamName].accent,
  logo_url: `https://dummyimage.com/128x128/0f172a/${teamThemes[teamName].primary.replace("#", "")}&text=${teamShortNames[teamName]}`,
}));

export const demoVenues: Venue[] = [
  { id: "venue-1", venue_name: "Skyline Cricket Arena", city: "Mumbai", country: "India" },
  { id: "venue-2", venue_name: "Neon Dome Stadium", city: "Dubai", country: "UAE" },
  { id: "venue-3", venue_name: "Aurora Sports Park", city: "Chennai", country: "India" },
  { id: "venue-4", venue_name: "Quantum Oval", city: "London", country: "England" },
  { id: "venue-5", venue_name: "Pulse Field", city: "Johannesburg", country: "South Africa" },
  { id: "venue-6", venue_name: "Delhi College", city: "Indore", country: "India" },
  { id: "venue-7", venue_name: "Holkar Stadium", city: "Indore", country: "India" },
];

export const demoPlayers: Player[] = rosterTeams.flatMap((team, teamIndex) =>
  team.players.map(([playerName, role], playerIndex) => ({
    id: `player-${teamIndex + 1}-${playerIndex + 1}`,
    player_name: playerName,
    team_id: teamIds[team.team_name],
    role,
    batting_style: roleStyles[role]?.batting_style ?? "Right-hand bat",
    bowling_style: roleStyles[role]?.bowling_style ?? "Right-arm medium",
  })),
);

const playerIdByRole = (teamName: string, role: string) =>
  demoPlayers.find((player) => player.team_id === teamIds[teamName] && player.role === role)?.id ?? "";

const playerNameByRole = (teamName: string, role: string) =>
  demoPlayers.find((player) => player.team_id === teamIds[teamName] && player.role === role)?.player_name ?? "";

export const demoMatches: MatchRecord[] = [];

export const demoDashboard: DashboardData = {
  total_matches: 0,
  total_teams: 10,
  total_players: demoPlayers.length,
  average_first_innings_score: 0,
  total_runs: 0,
  avg_strike_rate: 0,
  avg_economy: 0,
  fours: 0,
  sixes: 0,
  wickets_taken: 0,
  chase_win_percentage: 0,
  bat_first_win_percentage: 0,
  toss_conversion_percentage: 0,
  highest_score: 0,
  top_run_scorers: [],
  top_wicket_takers: [],
  team_win_percentage_chart: demoTeams.map((team) => ({
    team_id: team.id,
    team_name: team.team_name,
    win_percentage: 0,
    bat_first_win_percentage: 0,
    chase_win_percentage: 0,
  })),
  venue_score_chart: demoVenues.map((venue, index) => ({
    venue_id: venue.id,
    venue_name: venue.venue_name,
    average_first_innings_score: 0,
    average_second_innings_score: 0,
    par_score: 0,
    safe_score: 0,
  })),
  summary_points: [
    "No completed matches have been entered yet.",
    "Add finished MPt20 fixtures to unlock team, venue, and player intelligence.",
    "The dashboard will populate automatically after the first match is saved.",
  ],
};

export const demoTeamAnalytics: TeamAnalytics = {
  team: demoTeams[0],
  metrics: {
    matches_played: 0,
    wins: 0,
    losses: 0,
    win_percentage: 0,
    bat_first_matches: 0,
    bat_first_wins: 0,
    bat_first_win_percentage: 0,
    chase_matches: 0,
    chase_wins: 0,
    chase_win_percentage: 0,
    toss_wins: 0,
    wins_after_toss: 0,
    toss_conversion_percentage: 0,
    average_score_batting_first: 0,
    average_score_chasing: 0,
    total_runs: 0,
    avg_strike_rate: 0,
    avg_economy: 0,
    fours: 0,
    sixes: 0,
    wickets_taken: 0,
    form_index: 0,
    team_strength_score: 0,
  },
  insights: [
    "No completed matches are available for this team yet.",
    "Enter finished fixtures to generate team form and strategy insights.",
  ],
  recent_matches: demoMatches,
  head_to_head_summary: [],
};

export const demoPlayerAnalytics: PlayerAnalytics = {
  player: demoPlayers.find((player) => player.player_name === "Venkatesh Iyer") ?? demoPlayers[0],
  batting: {
    total_runs: 0,
    total_balls: 0,
    batting_strike_rate: 0,
    average_runs_per_match: 0,
    fours: 0,
    sixes: 0,
    boundary_percentage: 0,
    finishing_score: 0,
  },
  bowling: {
    overs: 0,
    wickets: 0,
    economy: 0,
    dot_ball_percentage: 0,
    bowling_strike_impact: 0,
    pressure_bowling_score: 0,
  },
  impact: {
    batting_impact: 0,
    bowling_impact: 0,
    all_rounder_index: 0,
  },
  insights: ["No match samples are available yet for this player."],
};

export const demoVenueAnalytics: VenueAnalytics = {
  venue: demoVenues[0],
  metrics: {
    total_matches: 0,
    average_first_innings_score: 0,
    average_second_innings_score: 0,
    bat_first_win_percentage: 0,
    chase_win_percentage: 0,
    highest_score: 0,
    highest_successful_chase: 0,
    lowest_defended_score: 0,
    par_score: 0,
    safe_score: 0,
  },
  insights: [
    "No venue results are available yet.",
    "Add completed matches to calculate par and safe scores.",
  ],
};

export const demoTossAnalytics: TossAnalytics = {
  overall: {
    toss_winner_match_win_percentage: 0,
    bat_decision_success_percentage: 0,
    bowl_decision_success_percentage: 0,
  },
  team_wise: demoTeams.map((team) => ({
    team_id: team.id,
    team_name: team.team_name,
    toss_wins: 0,
    toss_conversion_percentage: 0,
  })),
  insights: [
    "No toss history exists yet.",
    "Enter completed matches to analyse toss conversion and decision success.",
  ],
};

export const demoPrediction: PredictionOutput = {
  team_a_win_probability: 50,
  team_b_win_probability: 50,
  recommended_decision: "Insufficient match history available to recommend a decision.",
  confidence_level: "low",
  reasoning_points: [
    "No completed matches have been entered yet.",
    "Add real fixtures to activate the rule-based win probability engine.",
  ],
  key_advantages: [],
  risk_factors: ["No historical signals available yet."],
  raw_score: { score_a: 50, score_b: 50, win_diff: 0, strength_diff: 0, form_diff: 0, h2h_diff: 0, venue_bias: 0 },
};

export const demoReports = [];

export type StandingRow = {
  team_id: string;
  team_name: string;
  played: number;
  wins: number;
  losses: number;
  points: number;
  nrr: string;
};

export const demoStandings: StandingRow[] = [];
