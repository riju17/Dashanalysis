"use client";

import { useEffect, useMemo, useState } from "react";
import { api } from "@/lib/api";
import { AppShell } from "@/components/layout/AppShell";
import { GlassCard } from "@/components/ui/GlassCard";
import { Loader } from "@/components/ui/Loader";
import { ErrorState } from "@/components/ui/ErrorState";
import { EmptyState } from "@/components/ui/EmptyState";
import { PlayerImpactCard } from "@/components/cards/PlayerImpactCard";
import { PlayerRankingChart } from "@/components/charts/PlayerRankingChart";
import type { DashboardData, Player, PlayerAnalytics } from "@/types/cricket";

export default function PlayersPage() {
  const [players, setPlayers] = useState<Player[]>([]);
  const [dashboard, setDashboard] = useState<DashboardData | null>(null);
  const [selectedPlayerId, setSelectedPlayerId] = useState("");
  const [playerAnalytics, setPlayerAnalytics] = useState<PlayerAnalytics | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const selectedPlayer = useMemo(() => players.find((player) => player.id === selectedPlayerId) || players[0], [players, selectedPlayerId]);

  const load = async () => {
    setLoading(true);
    setError("");
    try {
      const playerList = await api.getPlayers();
      setPlayers(playerList);
      const playerId = selectedPlayerId || playerList[0]?.id;
      if (playerId) {
        setSelectedPlayerId(playerId);
        setPlayerAnalytics(await api.getPlayer(playerId));
      }

      api.getDashboard()
        .then(setDashboard)
        .catch(() => setDashboard(null));
    } catch {
      setError("Could not load player intelligence.");
    } finally {
      setLoading(false);
    }
  };

  const selectPlayer = async (playerId: string) => {
    setSelectedPlayerId(playerId);
    setLoading(true);
    try {
      setPlayerAnalytics(await api.getPlayer(playerId));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, []);

  const runChart = dashboard?.top_run_scorers.map((player) => ({ name: player.player_name, value: player.runs })) || [];
  const wicketChart = dashboard?.top_wicket_takers.map((player) => ({ name: player.player_name, value: player.wickets })) || [];

  return (
    <AppShell title="Player Analysis" subtitle="Rank batters, bowlers, and all-rounders through impact-aware metrics." actionLabel="Reload" onAction={load}>
      {loading && <Loader />}
      {error && !loading && <ErrorState message={error} onRetry={load} />}
      {!loading && !error && playerAnalytics && (
        <div className="space-y-6">
          <GlassCard>
            <label className="block">
              <span className="mb-2 block text-xs uppercase tracking-[0.24em] text-slate-400">Select player</span>
              <select
                value={selectedPlayerId}
                onChange={(event) => selectPlayer(event.target.value)}
                className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-cyan-300/50"
              >
                {players.map((player) => (
                  <option key={player.id} value={player.id}>
                    {player.player_name}
                  </option>
                ))}
              </select>
            </label>
          </GlassCard>

          <PlayerImpactCard data={playerAnalytics} rankLabel={selectedPlayer?.role || "Player"} />

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
                    <p className="text-[10px] uppercase tracking-[0.24em] text-slate-400">{label.replaceAll("_", " ")}</p>
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
        </div>
      )}
      {!loading && !error && (!playerAnalytics || players.length === 0) && (
        <EmptyState title="No player data" description="Player impact analysis appears once the database has players and match stats." actionLabel="Add match" onAction={() => window.location.assign("/add-match")} />
      )}
    </AppShell>
  );
}
