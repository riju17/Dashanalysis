import type {
  ImportConfirmPayload,
  ImportConfirmResult,
  DashboardData,
  MatchImportRecord,
  MatchRecord,
  MatchPlayerStatRecord,
  Player,
  PlayerAnalytics,
  PredictionInput,
  PredictionOutput,
  MatchReportCreateResponse,
  PlayerPerformanceReportRequest,
  PlayerPerformanceReportResponse,
  ReportExportRequest,
  ReportRecord,
  Team,
  TeamAnalytics,
  TossAnalytics,
  Venue,
  VenueAnalytics,
  StandingRow,
} from "@/types/cricket";

const API_BASE_PATH = "/api/backend";

function getDirectApiBaseUrl() {
  return process.env.NEXT_PUBLIC_API_URL?.replace(/\/$/, "") || "";
}

function buildHeaders(init?: RequestInit) {
  const headers = new Headers(init?.headers || {});
  const isFormData = typeof FormData !== "undefined" && init?.body instanceof FormData;
  const method = (init?.method || "GET").toUpperCase();
  const shouldSendJsonContentType = method !== "GET" && method !== "HEAD";
  if (!isFormData && shouldSendJsonContentType && !headers.has("Content-Type")) {
    headers.set("Content-Type", "application/json");
  }
  return headers;
}

function getFallbackTargets(path: string) {
  const targets = [`${API_BASE_PATH}${path}`];
  const directApiBaseUrl = getDirectApiBaseUrl();
  if (directApiBaseUrl) {
    targets.push(`${directApiBaseUrl}${path}`);
  }
  return targets;
}

async function requestOnce<T>(url: string, init?: RequestInit): Promise<T> {
  const response = await fetch(url, {
    cache: "no-store",
    ...init,
  });
  if (!response.ok) {
    let errorMessage = `Request failed with status ${response.status}.`;
    try {
      const payload = await response.json();
      errorMessage = payload?.detail || payload?.message || errorMessage;
    } catch {
      const text = await response.text();
      if (text) {
        errorMessage = text;
      }
    }
    throw new Error(errorMessage);
  }
  const payload = await response.json();
  return payload.data ?? payload;
}

async function request<T>(path: string, init?: RequestInit): Promise<T> {
  const headers = buildHeaders(init);
  let lastError: unknown = null;

  for (const url of getFallbackTargets(path)) {
    try {
      return await requestOnce<T>(url, { ...init, headers });
    } catch (error) {
      lastError = error;
    }
  }

  throw lastError instanceof Error ? lastError : new Error("Request failed.");
}

async function requestBlob(path: string, init?: RequestInit): Promise<Blob> {
  const headers = buildHeaders(init);
  let lastError: unknown = null;

  for (const url of getFallbackTargets(path)) {
    try {
      const response = await fetch(url, {
        cache: "no-store",
        ...init,
        headers,
      });
      if (!response.ok) {
        let errorMessage = `Request failed with status ${response.status}.`;
        try {
          const payload = await response.json();
          errorMessage = payload?.detail || payload?.message || errorMessage;
        } catch {
          const text = await response.text();
          if (text) {
            errorMessage = text;
          }
        }
        throw new Error(errorMessage);
      }
      return response.blob();
    } catch (error) {
      lastError = error;
    }
  }

  throw lastError instanceof Error ? lastError : new Error("Request failed.");
}

function normalizePlayerAnalytics(payload: unknown): PlayerAnalytics {
  const candidate = (payload && typeof payload === "object" ? payload : {}) as Partial<PlayerAnalytics>;

  return {
    player: candidate.player ?? {
      id: "",
      player_name: "Unknown player",
      team_id: "",
    },
    batting: candidate.batting ?? {
      total_runs: 0,
      total_balls: 0,
      batting_strike_rate: 0,
      average_runs_per_match: 0,
      fours: 0,
      sixes: 0,
      boundary_percentage: 0,
      finishing_score: 0,
    },
    bowling: candidate.bowling ?? {
      overs: 0,
      wickets: 0,
      economy: 0,
      runs_conceded: 0,
      dot_balls: 0,
      dot_ball_percentage: 0,
      bowling_strike_impact: 0,
      pressure_bowling_score: 0,
    },
    impact: candidate.impact ?? {
      batting_impact: 0,
      bowling_impact: 0,
      all_rounder_index: 0,
    },
    insights: Array.isArray(candidate.insights) ? candidate.insights : [],
    matchwise_performance: Array.isArray(candidate.matchwise_performance) ? candidate.matchwise_performance : [],
  };
}

function scorePlayerAnalytics(candidate: PlayerAnalytics) {
  const hasMatchwiseRows = candidate.matchwise_performance.length > 0;
  const hasAggregateActivity =
    candidate.batting.total_runs > 0 ||
    candidate.batting.total_balls > 0 ||
    candidate.bowling.overs > 0 ||
    candidate.bowling.wickets > 0 ||
    candidate.bowling.runs_conceded > 0;

  return (hasMatchwiseRows ? 10 : 0) + (hasAggregateActivity ? 1 : 0);
}

async function getPlayerAnalytics(path: string): Promise<PlayerAnalytics> {
  const headers = buildHeaders();
  let lastError: unknown = null;
  let bestCandidate: PlayerAnalytics | null = null;
  let bestScore = -1;

  for (const url of getFallbackTargets(path)) {
    try {
      const payload = await requestOnce<unknown>(url, { headers });
      const normalized = normalizePlayerAnalytics(payload);
      const score = scorePlayerAnalytics(normalized);

      if (score > bestScore) {
        bestCandidate = normalized;
        bestScore = score;
      }

      if (normalized.matchwise_performance.length > 0) {
        return normalized;
      }
    } catch (error) {
      lastError = error;
    }
  }

  if (bestCandidate) {
    return bestCandidate;
  }

  throw lastError instanceof Error ? lastError : new Error("Request failed.");
}

export const api = {
  getDashboard: () => request<DashboardData>("/analytics/dashboard"),
  getTeams: () => request<Team[]>("/teams"),
  getTeam: (teamId: string) => request<TeamAnalytics>(`/analytics/team/${teamId}`),
  getVenues: () => request<Venue[]>("/venues"),
  getVenue: (venueId: string) => request<VenueAnalytics>(`/analytics/venue/${venueId}`),
  getPlayers: () => request<Player[]>("/players"),
  getPlayersByTeam: (teamId: string) => request<Player[]>(`/players/team/${teamId}`),
  getPlayer: (playerId: string) => getPlayerAnalytics(`/analytics/player/${playerId}`),
  getTossAnalytics: () => request<TossAnalytics>("/analytics/toss"),
  getMatches: () => request<MatchRecord[]>("/matches"),
  getMatch: (matchId: string) => request<MatchRecord>(`/matches/${matchId}`),
  getMatchPlayerStats: (matchId: string) => request<MatchPlayerStatRecord[]>(`/matches/${matchId}/player-stats`),
  getStandings: () => request<StandingRow[]>("/analytics/standings"),
  getHeadToHead: (teamAId: string, teamBId: string) => request(`/analytics/head-to-head/${teamAId}/${teamBId}`),
  predictWinProbability: (payload: PredictionInput) =>
    request<PredictionOutput>("/prediction/win-probability", {
      method: "POST",
      body: JSON.stringify(payload),
    }),
  createMatch: async (payload: Record<string, unknown>) =>
    request<MatchRecord>("/matches", {
      method: "POST",
      body: JSON.stringify(payload),
    }),
  createPlayerStats: async (matchId: string, payload: Record<string, unknown>[]) =>
    request(`/matches/${matchId}/player-stats`, {
      method: "POST",
      body: JSON.stringify(payload),
    }),
  createTeam: async (payload: Record<string, unknown>) =>
    request<Team>("/teams", {
      method: "POST",
      body: JSON.stringify(payload),
    }),
  createVenue: async (payload: Record<string, unknown>) =>
    request<Venue>("/venues", {
      method: "POST",
      body: JSON.stringify(payload),
    }),
  deleteMatch: async (matchId: string) =>
    request(`/matches/${matchId}`, { method: "DELETE" }),
  createReport: async (matchId: string) =>
    request<MatchReportCreateResponse>(`/reports/match/${matchId}`, { method: "POST" }),
  createPlayerPerformanceReport: async (payload: PlayerPerformanceReportRequest) =>
    request<PlayerPerformanceReportResponse>("/reports/player-performance", {
      method: "POST",
      body: JSON.stringify(payload),
    }),
  exportReport: async (payload: ReportExportRequest) =>
    requestBlob("/reports/export", {
      method: "POST",
      body: JSON.stringify(payload),
    }),
  importScreenshots: async (files: File[]) => {
    const formData = new FormData();
    files.forEach((file) => formData.append("files", file));
    return request<MatchImportRecord>("/imports/screenshot", {
      method: "POST",
      body: formData,
    });
  },
  importUrl: async (url: string) =>
    request<MatchImportRecord>(
      "/imports/url",
      {
        method: "POST",
        body: JSON.stringify({ url }),
      },
    ),
  importPdf: async (file: File) => {
    const formData = new FormData();
    formData.append("file", file);
    return request<MatchImportRecord>("/imports/pdf", {
      method: "POST",
      body: formData,
    });
  },
  getImport: (importId: string) => request<MatchImportRecord>(`/imports/${importId}`),
  getImportForMatch: (matchId: string) => request<MatchImportRecord>(`/imports/match/${matchId}`),
  confirmImport: async (payload: ImportConfirmPayload) =>
    request<ImportConfirmResult>(
      "/imports/confirm",
      {
        method: "POST",
        body: JSON.stringify(payload),
      },
    ),
  getReports: () => request<ReportRecord[]>("/reports"),
  getOpponentStrategy: (ourTeamId: string, opponentTeamId: string, venueId: string) =>
    request(`/analytics/opponent-strategy/${ourTeamId}/${opponentTeamId}/${venueId}`),
};

export type ApiClient = typeof api;
