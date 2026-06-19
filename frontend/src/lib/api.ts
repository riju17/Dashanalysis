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
  ReportRecord,
  Team,
  TeamAnalytics,
  TossAnalytics,
  Venue,
  VenueAnalytics,
  StandingRow,
} from "@/types/cricket";

function getApiUrl() {
  const explicitUrl = process.env.NEXT_PUBLIC_API_URL?.replace(/\/$/, "");
  if (explicitUrl) return explicitUrl;

  if (process.env.NODE_ENV === "development") {
    return "http://127.0.0.1:8000";
  }

  if (typeof window !== "undefined") {
    const host = window.location.hostname;
    if (host === "localhost" || host === "127.0.0.1") {
      return "http://127.0.0.1:8000";
    }
  }

  return "";
}

async function request<T>(path: string, init?: RequestInit): Promise<T> {
  const apiUrl = getApiUrl();
  if (!apiUrl) {
    throw new Error("NEXT_PUBLIC_API_URL is not set.");
  }
  try {
    const headers = new Headers(init?.headers || {});
    const isFormData = typeof FormData !== "undefined" && init?.body instanceof FormData;
    if (!isFormData && !headers.has("Content-Type")) {
      headers.set("Content-Type", "application/json");
    }
    const response = await fetch(`${apiUrl}${path}`, {
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
    const payload = await response.json();
    return payload.data ?? payload;
  } catch (error) {
    throw error;
  }
}

export const api = {
  getDashboard: () => request<DashboardData>("/analytics/dashboard"),
  getTeams: () => request<Team[]>("/teams"),
  getTeam: (teamId: string) => request<TeamAnalytics>(`/analytics/team/${teamId}`),
  getVenues: () => request<Venue[]>("/venues"),
  getVenue: (venueId: string) => request<VenueAnalytics>(`/analytics/venue/${venueId}`),
  getPlayers: () => request<Player[]>("/players"),
  getPlayersByTeam: (teamId: string) => request<Player[]>(`/players/team/${teamId}`),
  getPlayer: (playerId: string) => request<PlayerAnalytics>(`/analytics/player/${playerId}`),
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
