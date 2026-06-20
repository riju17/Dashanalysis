"use client";

import { useEffect, useMemo, useRef, useState } from "react";
import { useSearchParams } from "next/navigation";
import { api } from "@/lib/api";
import { AppShell } from "@/components/layout/AppShell";
import { GlassCard } from "@/components/ui/GlassCard";
import { Loader } from "@/components/ui/Loader";
import { ErrorState } from "@/components/ui/ErrorState";
import { EmptyState } from "@/components/ui/EmptyState";
import { PlayerImpactCard } from "@/components/cards/PlayerImpactCard";
import { PlayerRankingChart } from "@/components/charts/PlayerRankingChart";
import type { DashboardData, Player, PlayerAnalytics, Team } from "@/types/cricket";

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
