"use client";

import { useEffect, useMemo, useRef, useState } from "react";
import { useSearchParams } from "next/navigation";
import { api } from "@/lib/api";
import { AppShell } from "@/components/layout/AppShell";
import { GlassCard } from "@/components/ui/GlassCard";
import { Loader } from "@/components/ui/Loader";
import { ErrorState } from "@/components/ui/ErrorState";
import { EmptyState } from "@/components/ui/EmptyState";
import { NeonButton } from "@/components/ui/NeonButton";
import { PlayerImpactCard } from "@/components/cards/PlayerImpactCard";
import { PlayerRankingChart } from "@/components/charts/PlayerRankingChart";
import type { DashboardData, Player, PlayerAnalytics, PlayerMatchPerformance, Team } from "@/types/cricket";

export default function PlayersClient() {
  const searchParams = useSearchParams();
  const requestedPlayerId = searchParams.get("playerId") || "";
  const [players, setPlayers] = useState<Player[]>([]);
  const [teams, setTeams] = useState<Team[]>([]);
  const [dashboard, setDashboard] = useState<DashboardData | null>(null);
  const [selectedTeamId, setSelectedTeamId] = useState("");
  const [selectedPlayerId, setSelectedPlayerId] = useState(requestedPlayerId);
  const [playerAnalytics, setPlayerAnalytics] = useState<PlayerAnalytics | null>(null);
  const [loading, setLoading] = useState(true);
  const [playerLoading, setPlayerLoading] = useState(false);
  const [error, setError] = useState("");
  const playerRequestId = useRef(0);

  const teamNameById = useMemo(() => new Map(teams.map((team) => [team.id, team.team_name])), [teams]);
  const visiblePlayers = useMemo(
    () => (selectedTeamId ? players.filter((player) => player.team_id === selectedTeamId) : players),
    [players, selectedTeamId],
  );
  const selectedPlayer = useMemo(
    () => visiblePlayers.find((player) => player.id === selectedPlayerId) || visiblePlayers[0] || null,
    [visiblePlayers, selectedPlayerId],
  );
  const selectedPlayerTeamName = selectedPlayer ? teamNameById.get(selectedPlayer.team_id) || "" : "";
  const battingMatches = useMemo(
    () =>
      (playerAnalytics?.matchwise_performance ?? []).filter(
        (match) => match.runs > 0 || match.balls > 0 || match.fours > 0 || match.sixes > 0 || typeof match.dismissal === "string",
      ),
    [playerAnalytics],
  );
  const bowlingMatches = useMemo(
    () =>
      (playerAnalytics?.matchwise_performance ?? []).filter(
        (match) =>
          match.overs > 0 ||
          match.maidens > 0 ||
          match.runs_conceded > 0 ||
          match.wickets > 0 ||
          match.dot_balls > 0 ||
          match.catches > 0 ||
          match.runouts > 0 ||
          match.stumpings > 0,
      ),
    [playerAnalytics],
  );

  const loadPlayerAnalytics = async (playerId: string) => {
    const requestId = ++playerRequestId.current;
    setSelectedPlayerId(playerId);
    setPlayerLoading(true);
    try {
      const analytics = await api.getPlayer(playerId);
      if (requestId === playerRequestId.current) {
        setPlayerAnalytics(analytics);
      }
    } catch {
      if (requestId === playerRequestId.current) {
        setPlayerAnalytics(null);
      }
    } finally {
      if (requestId === playerRequestId.current) {
        setPlayerLoading(false);
      }
    }
  };

  const load = async () => {
    setLoading(true);
    setError("");
    try {
      const [teamList, playerList, dashboardData] = await Promise.all([api.getTeams(), api.getPlayers(), api.getDashboard()]);
      setTeams(teamList);
      setPlayers(playerList);
      setDashboard(dashboardData);
      const playerId = selectedPlayerId && playerList.some((player) => player.id === selectedPlayerId) ? selectedPlayerId : playerList[0]?.id;
      if (playerId) {
        await loadPlayerAnalytics(playerId);
      } else {
        setPlayerAnalytics(null);
      }
    } catch {
      setError("Could not load player intelligence.");
    } finally {
      setLoading(false);
    }
  };

  const selectPlayer = (playerId: string) => {
    void loadPlayerAnalytics(playerId);
  };

  const selectTeam = (teamId: string) => {
    setSelectedTeamId(teamId);
    const nextPlayers = teamId ? players.filter((player) => player.team_id === teamId) : players;
    const nextPlayer = nextPlayers.find((player) => player.id === selectedPlayerId) || nextPlayers[0];

    if (!nextPlayer) {
      setSelectedPlayerId("");
      setPlayerAnalytics(null);
      return;
    }

    if (nextPlayer.id !== selectedPlayerId) {
      void loadPlayerAnalytics(nextPlayer.id);
    }
  };

  useEffect(() => {
    load();
  }, []);

  useEffect(() => {
    if (requestedPlayerId && requestedPlayerId !== selectedPlayerId) {
      setSelectedPlayerId(requestedPlayerId);
      void loadPlayerAnalytics(requestedPlayerId);
    }
  }, [requestedPlayerId, selectedPlayerId]);

  const runChart = dashboard?.top_run_scorers.map((player) => ({ name: player.player_name, value: player.runs })) || [];
  const wicketChart = dashboard?.top_wicket_takers.map((player) => ({ name: player.player_name, value: player.wickets })) || [];

  const formatBowlingLabel = (label: string) => {
    if (label === "runs_conceded") return "runs given";
    if (label === "dot_balls") return "dot balls";
    return label.replaceAll("_", " ");
  };

  const formatMatchDate = (value?: string | null) => {
    if (!value) return "Unknown date";
    const parsed = new Date(value);
    if (Number.isNaN(parsed.getTime())) return value;
    return parsed.toLocaleDateString("en-IN", { day: "2-digit", month: "short", year: "numeric" });
  };

  const formatMetric = (value: number) => (Number.isInteger(value) ? value.toString() : value.toFixed(2));

  const formatFieldingSummary = (match: PlayerMatchPerformance) => {
    const entries: string[] = [];
    if (match.catches) entries.push(`Ct ${match.catches}`);
    if (match.runouts) entries.push(`RO ${match.runouts}`);
    if (match.stumpings) entries.push(`St ${match.stumpings}`);
    return entries.length ? entries.join(" • ") : "No dismissals";
  };

  const toFilename = (title: string, format: "csv" | "pdf") =>
    `${title
      .trim()
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-+|-+$/g, "") || "report"}.${format}`;

  const downloadBlob = (blob: Blob, filename: string) => {
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = filename;
    link.click();
    URL.revokeObjectURL(url);
  };

  const escapeCsvCell = (value: string | number | null | undefined) => {
    const normalized = value == null ? "" : String(value);
    if (/[",\n]/.test(normalized)) {
      return `"${normalized.replace(/"/g, "\"\"")}"`;
    }
    return normalized;
  };

  const exportRowsAsCsv = (title: string, headers: string[], rows: Array<Array<string | number | null | undefined>>) => {
    const csv = [headers, ...rows]
      .map((row) => row.map((cell) => escapeCsvCell(cell)).join(","))
      .join("\n");
    downloadBlob(new Blob([csv], { type: "text/csv;charset=utf-8;" }), toFilename(title, "csv"));
  };

  const exportReportAsPdf = (title: string, headers: string[], rows: Array<Array<string | number | null | undefined>>) => {
    const reportWindow = window.open("", "_blank", "noopener,noreferrer,width=1200,height=900");
    if (!reportWindow) return;

    const tableHead = headers.map((header) => `<th>${header}</th>`).join("");
    const tableBody = rows
      .map(
        (row) =>
          `<tr>${row
            .map((cell) => `<td>${String(cell ?? "").replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")}</td>`)
            .join("")}</tr>`,
      )
      .join("");

    reportWindow.document.write(`
      <html>
        <head>
          <title>${title}</title>
          <style>
            body { font-family: Arial, sans-serif; padding: 24px; color: #111827; }
            h1 { font-size: 24px; margin-bottom: 8px; }
            p { color: #4b5563; margin-bottom: 24px; }
            table { width: 100%; border-collapse: collapse; font-size: 12px; }
            th, td { border: 1px solid #d1d5db; padding: 8px; text-align: left; vertical-align: top; }
            th { background: #f3f4f6; font-size: 11px; text-transform: uppercase; letter-spacing: 0.08em; }
            tr:nth-child(even) td { background: #f9fafb; }
          </style>
        </head>
        <body>
          <h1>${title}</h1>
          <p>${selectedPlayer?.player_name || "Player"} • ${selectedPlayerTeamName || "Unknown team"}</p>
          <table>
            <thead><tr>${tableHead}</tr></thead>
            <tbody>${tableBody}</tbody>
          </table>
        </body>
      </html>
    `);
    reportWindow.document.close();
    reportWindow.focus();
    reportWindow.print();
  };

  const exportBattingPerformance = (format: "csv" | "pdf") => {
    if (!playerAnalytics) return;
    const title = `${selectedPlayer?.player_name || "player"} batting performance`;
    const headers = ["Match", "Date", "Opponent", "Venue", "Position", "Dismissal", "Runs", "Balls", "Fours", "Sixes", "Strike Rate"];
    const rows = battingMatches.map((match) => [
      `Match ${match.match_number || "-"}`,
      formatMatchDate(match.match_date),
      match.opponent_team_name,
      match.venue_name,
      typeof match.batting_position === "number" ? match.batting_position : "",
      match.dismissal || "Not out / unavailable",
      match.runs,
      match.balls,
      match.fours,
      match.sixes,
      formatMetric(match.strike_rate),
    ]);
    if (format === "csv") {
      exportRowsAsCsv(title, headers, rows);
      return;
    }
    exportReportAsPdf(title, headers, rows);
  };

  const exportBowlingPerformance = (format: "csv" | "pdf") => {
    if (!playerAnalytics) return;
    const title = `${selectedPlayer?.player_name || "player"} bowling performance`;
    const headers = ["Match", "Date", "Opponent", "Venue", "Overs", "Maidens", "Runs Conceded", "Wickets", "Dot Balls", "Economy", "Fielding"];
    const rows = bowlingMatches.map((match) => [
      `Match ${match.match_number || "-"}`,
      formatMatchDate(match.match_date),
      match.opponent_team_name,
      match.venue_name,
      formatMetric(match.overs),
      match.maidens,
      match.runs_conceded,
      match.wickets,
      match.dot_balls,
      match.overs > 0 || match.runs_conceded > 0 ? formatMetric(match.economy) : "DNB",
      formatFieldingSummary(match),
    ]);
    if (format === "csv") {
      exportRowsAsCsv(title, headers, rows);
      return;
    }
    exportReportAsPdf(title, headers, rows);
  };

  return (
    <AppShell title="Player Analysis" subtitle="Rank batters, bowlers, and all-rounders through impact-aware metrics." actionLabel="Reload" onAction={load}>
      {loading && <Loader />}
      {error && !loading && <ErrorState message={error} onRetry={load} />}
      {!loading && !error && players.length > 0 && (
        <div className="space-y-6">
          <GlassCard>
            <div className="grid gap-4 md:grid-cols-2">
              <label className="block">
                <span className="mb-2 block text-xs uppercase tracking-[0.24em] text-slate-400">Select team (optional)</span>
                <select
                  value={selectedTeamId}
                  onChange={(event) => selectTeam(event.target.value)}
                  className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-cyan-300/50"
                >
                  <option value="">All teams</option>
                  {teams.map((team) => (
                    <option key={team.id} value={team.id}>
                      {team.team_name}
                    </option>
                  ))}
                </select>
              </label>
              <label className="block">
                <span className="mb-2 block text-xs uppercase tracking-[0.24em] text-slate-400">Select player</span>
                <select
                  value={selectedPlayerId}
                  onChange={(event) => selectPlayer(event.target.value)}
                  disabled={visiblePlayers.length === 0}
                  className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-cyan-300/50"
                >
                  <option value="" disabled>
                    {visiblePlayers.length === 0 ? "No players available" : "Select player"}
                  </option>
                  {visiblePlayers.map((player) => (
                    <option key={player.id} value={player.id}>
                      {player.player_name}
                    </option>
                  ))}
                </select>
              </label>
            </div>
          </GlassCard>

          {playerLoading && (
            <GlassCard>
              <p className="text-sm text-slate-300">Loading player analysis...</p>
            </GlassCard>
          )}

          {!playerLoading && playerAnalytics ? (
            <>
              <PlayerImpactCard data={playerAnalytics} rankLabel={selectedPlayer?.role || "Player"} teamName={selectedPlayerTeamName} />
              <div className="grid gap-4 xl:grid-cols-2">
                <GlassCard>
                  <h3 className="text-lg font-semibold text-white">Batting profile</h3>
                  <div className="mt-4 grid gap-3 md:grid-cols-2">
                    {Object.entries(playerAnalytics.batting).map(([label, value]) => (
                      <div key={label} className="rounded-2xl border border-white/10 bg-white/5 p-3">
                        <p className="text-[10px] uppercase tracking-[0.24em] text-slate-400">{label.replaceAll("_", " ")}</p>
                        <p className="mt-1 text-base font-semibold text-white">{typeof value === "number" ? value.toFixed(2) : value}</p>
                      </div>
                    ))}
                  </div>
                </GlassCard>
                <GlassCard>
                  <h3 className="text-lg font-semibold text-white">Bowling profile</h3>
                  <div className="mt-4 grid gap-3 md:grid-cols-2">
                    {Object.entries(playerAnalytics.bowling).map(([label, value]) => (
                      <div key={label} className="rounded-2xl border border-white/10 bg-white/5 p-3">
                        <p className="text-[10px] uppercase tracking-[0.24em] text-slate-400">{formatBowlingLabel(label)}</p>
                        <p className="mt-1 text-base font-semibold text-white">{typeof value === "number" ? value.toFixed(2) : value}</p>
                      </div>
                    ))}
                  </div>
                </GlassCard>
              </div>

              <div className="grid gap-4 xl:grid-cols-2">
                <PlayerRankingChart title="Top Run Scorers" data={runChart} />
                <PlayerRankingChart title="Top Wicket Takers" data={wicketChart} />
              </div>
              <div className="grid gap-4 xl:grid-cols-2">
                <GlassCard>
                  <div className="flex items-center justify-between gap-3">
                    <div>
                      <h3 className="text-lg font-semibold text-white">Batting performance</h3>
                      <p className="mt-1 text-sm text-slate-400">Matchwise batting output for the selected player.</p>
                    </div>
                    <div className="flex items-center gap-2">
                      <div className="rounded-full border border-white/10 bg-white/5 px-3 py-1 text-xs uppercase tracking-[0.2em] text-slate-300">
                        {battingMatches.length} matches
                      </div>
                      <NeonButton className="px-3 py-1.5 text-xs" onClick={() => exportBattingPerformance("csv")}>
                        Export CSV
                      </NeonButton>
                      <NeonButton className="px-3 py-1.5 text-xs" onClick={() => exportBattingPerformance("pdf")}>
                        Export PDF
                      </NeonButton>
                    </div>
                  </div>
                  {battingMatches.length ? (
                    <div className="mt-4 overflow-x-auto">
                      <table className="min-w-full divide-y divide-white/10 text-left text-sm text-slate-200">
                        <thead className="text-[11px] uppercase tracking-[0.24em] text-slate-400">
                          <tr>
                            <th className="px-3 py-3">Match</th>
                            <th className="px-3 py-3">Venue</th>
                            <th className="px-3 py-3">Runs</th>
                            <th className="px-3 py-3">Balls</th>
                            <th className="px-3 py-3">4s/6s</th>
                            <th className="px-3 py-3">SR</th>
                          </tr>
                        </thead>
                        <tbody className="divide-y divide-white/5">
                          {battingMatches.map((match) => (
                            <tr key={`batting-${match.match_id}-${match.match_number}`} className="align-top">
                              <td className="px-3 py-3">
                                <div className="font-medium text-white">
                                  Match {match.match_number || "-"}{match.tournament ? ` • ${match.tournament}` : ""}
                                </div>
                                <div className="mt-1 text-xs text-slate-400">{match.opponent_team_name}</div>
                                <div className="mt-1 text-xs text-slate-500">{formatMatchDate(match.match_date)}</div>
                                {match.dismissal ? <div className="mt-1 text-xs text-slate-500">{match.dismissal}</div> : null}
                              </td>
                              <td className="px-3 py-3">
                                <div>{match.venue_name}</div>
                                <div className="mt-1 text-xs text-slate-400">
                                  {typeof match.batting_position === "number" ? `Pos ${match.batting_position}` : "Position unavailable"}
                                </div>
                              </td>
                              <td className="px-3 py-3 font-medium text-white">{match.runs}</td>
                              <td className="px-3 py-3">{match.balls}</td>
                              <td className="px-3 py-3">{match.fours} / {match.sixes}</td>
                              <td className="px-3 py-3">{formatMetric(match.strike_rate)}</td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  ) : (
                    <p className="mt-4 rounded-2xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-slate-300">
                      No matchwise batting stats are available for this player yet.
                    </p>
                  )}
                </GlassCard>

                <GlassCard>
                  <div className="flex items-center justify-between gap-3">
                    <div>
                      <h3 className="text-lg font-semibold text-white">Bowling performance</h3>
                      <p className="mt-1 text-sm text-slate-400">Matchwise bowling output for the selected player.</p>
                    </div>
                    <div className="flex items-center gap-2">
                      <div className="rounded-full border border-white/10 bg-white/5 px-3 py-1 text-xs uppercase tracking-[0.2em] text-slate-300">
                        {bowlingMatches.length} matches
                      </div>
                      <NeonButton className="px-3 py-1.5 text-xs" onClick={() => exportBowlingPerformance("csv")}>
                        Export CSV
                      </NeonButton>
                      <NeonButton className="px-3 py-1.5 text-xs" onClick={() => exportBowlingPerformance("pdf")}>
                        Export PDF
                      </NeonButton>
                    </div>
                  </div>
                  {bowlingMatches.length ? (
                    <div className="mt-4 overflow-x-auto">
                      <table className="min-w-full divide-y divide-white/10 text-left text-sm text-slate-200">
                        <thead className="text-[11px] uppercase tracking-[0.24em] text-slate-400">
                          <tr>
                            <th className="px-3 py-3">Match</th>
                            <th className="px-3 py-3">Venue</th>
                            <th className="px-3 py-3">Overs</th>
                            <th className="px-3 py-3">Runs</th>
                            <th className="px-3 py-3">Wkts</th>
                            <th className="px-3 py-3">Dots</th>
                            <th className="px-3 py-3">Econ</th>
                            <th className="px-3 py-3">Fielding</th>
                          </tr>
                        </thead>
                        <tbody className="divide-y divide-white/5">
                          {bowlingMatches.map((match) => (
                            <tr key={`bowling-${match.match_id}-${match.match_number}`} className="align-top">
                              <td className="px-3 py-3">
                                <div className="font-medium text-white">
                                  Match {match.match_number || "-"}{match.tournament ? ` • ${match.tournament}` : ""}
                                </div>
                                <div className="mt-1 text-xs text-slate-400">{match.opponent_team_name}</div>
                                <div className="mt-1 text-xs text-slate-500">{formatMatchDate(match.match_date)}</div>
                              </td>
                              <td className="px-3 py-3">{match.venue_name}</td>
                              <td className="px-3 py-3">{formatMetric(match.overs)}</td>
                              <td className="px-3 py-3">{match.runs_conceded}</td>
                              <td className="px-3 py-3 font-medium text-white">{match.wickets}</td>
                              <td className="px-3 py-3">{match.dot_balls}</td>
                              <td className="px-3 py-3">{match.overs > 0 || match.runs_conceded > 0 ? formatMetric(match.economy) : "DNB"}</td>
                              <td className="px-3 py-3">{formatFieldingSummary(match)}</td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  ) : (
                    <p className="mt-4 rounded-2xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-slate-300">
                      No matchwise bowling stats are available for this player yet.
                    </p>
                  )}
                </GlassCard>
              </div>
              <GlassCard>
                <h3 className="text-lg font-semibold text-white">Player insights</h3>
                <div className="mt-4 space-y-3 text-sm text-slate-300">
                  {playerAnalytics.insights.map((insight) => (
                    <p key={insight} className="rounded-2xl border border-white/10 bg-white/5 px-4 py-3">
                      {insight}
                    </p>
                  ))}
                </div>
              </GlassCard>
            </>
          ) : (
            !playerLoading && (
              <EmptyState
                title="No player analysis"
                description="Choose a player to see impact metrics, or reload to fetch the latest data."
                actionLabel="Reload"
                onAction={load}
              />
            )
          )}
        </div>
      )}
      {!loading && !error && players.length === 0 && (
        <EmptyState title="No player data" description="Player impact analysis appears once the database has players and match stats." actionLabel="Add match" onAction={() => window.location.assign("/add-match")} />
      )}
    </AppShell>
  );
}
