"use client";

import { useEffect, useState } from "react";
import { Activity, Trophy, Users, MapPin, TrendingUp, Target, CircleDollarSign, Scale } from "lucide-react";
import { api } from "@/lib/api";
import { AppShell } from "@/components/layout/AppShell";
import { KPICard } from "@/components/cards/KPICard";
import { WinLossChart } from "@/components/charts/WinLossChart";
import { BatFirstVsChaseChart } from "@/components/charts/BatFirstVsChaseChart";
import { VenueTrendChart } from "@/components/charts/VenueTrendChart";
import { PlayerRankingChart } from "@/components/charts/PlayerRankingChart";
import { GlassCard } from "@/components/ui/GlassCard";
import { EmptyState } from "@/components/ui/EmptyState";
import { ErrorState } from "@/components/ui/ErrorState";
import { Loader } from "@/components/ui/Loader";
import type { DashboardData } from "@/types/cricket";

const neutralDashboardTheme = {
  primary: "#38BDF8",
  secondary: "#60A5FA",
  accent: "#A5B4FC",
  gradient: "linear-gradient(135deg, rgba(15,23,42,0.18), rgba(56,189,248,0.12), rgba(96,165,250,0.10))",
  glow: "rgba(56,189,248,0.18)",
  border: "rgba(148,163,184,0.22)",
};

export default function DashboardPage() {
  const [data, setData] = useState<DashboardData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const load = async () => {
    setLoading(true);
    setError("");
    try {
      const dashboard = await api.getDashboard();
      setData(dashboard);
    } catch (err) {
      setError("Dashboard data could not be loaded.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, []);

  const dashboardTotals = [
    { label: "Total Runs", value: data ? data.total_runs.toLocaleString() : "0" },
    { label: "Wickets", value: data ? data.wickets_taken.toLocaleString() : "0" },
    { label: "4s", value: data ? data.fours.toLocaleString() : "0" },
    { label: "6s", value: data ? data.sixes.toLocaleString() : "0" },
    { label: "Avg Strike Rate", value: `${data ? data.avg_strike_rate.toFixed(2) : "0.00"}%` },
    { label: "Avg Economy", value: data ? data.avg_economy.toFixed(2) : "0.00" },
  ];

  return (
    <AppShell
      title="Main Dashboard"
      subtitle="Completed-match intelligence, team momentum, venue behaviour, and player rankings in one cockpit."
      actionLabel="Refresh"
      onAction={load}
    >
      {loading && <Loader />}
      {error && !loading && <ErrorState message={error} onRetry={load} />}
      {!loading && !error && data && (
        <div className="space-y-6">
          <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
            <KPICard label="Total Matches" value={data.total_matches} icon={<Activity className="h-4 w-4" />} theme={neutralDashboardTheme} />
            <KPICard label="Total Teams" value={data.total_teams} icon={<Trophy className="h-4 w-4" />} theme={neutralDashboardTheme} />
            <KPICard label="Total Players" value={data.total_players} icon={<Users className="h-4 w-4" />} theme={neutralDashboardTheme} />
            <KPICard label="Average 1st Innings" value={data.average_first_innings_score.toFixed(1)} icon={<MapPin className="h-4 w-4" />} theme={neutralDashboardTheme} />
            <KPICard label="Chase Win %" value={`${data.chase_win_percentage.toFixed(1)}%`} icon={<TrendingUp className="h-4 w-4" />} trend="Chasing edge rising" trendDirection="up" theme={neutralDashboardTheme} />
            <KPICard label="Bat First Win %" value={`${data.bat_first_win_percentage.toFixed(1)}%`} icon={<CircleDollarSign className="h-4 w-4" />} theme={neutralDashboardTheme} />
            <KPICard label="Toss Conversion %" value={`${data.toss_conversion_percentage.toFixed(1)}%`} icon={<Target className="h-4 w-4" />} theme={neutralDashboardTheme} />
            <KPICard label="Highest Score" value={data.highest_score} icon={<Scale className="h-4 w-4" />} theme={neutralDashboardTheme} />
          </div>

          <GlassCard className="overflow-hidden border border-cyan-300/20 bg-gradient-to-r from-slate-950 via-cyan-950/70 to-slate-950">
            <div className="flex items-center justify-between gap-4">
              <div>
                <p className="text-xs uppercase tracking-[0.32em] text-cyan-200/70">Match Totals</p>
                <h3 className="mt-2 text-lg font-semibold text-white">Aggregate batting and bowling output</h3>
              </div>
              <p className="text-sm text-cyan-100/80">Team-wide performance snapshot</p>
            </div>
            <div className="mt-5 grid gap-3 sm:grid-cols-2 xl:grid-cols-6">
              {dashboardTotals.map((item, index) => (
                <div
                  key={item.label}
                  className={`rounded-2xl border px-4 py-4 ${
                    index % 2 === 0 ? "border-sky-300/20 bg-sky-400/10" : "border-blue-300/20 bg-blue-400/10"
                  }`}
                >
                  <p className="text-[10px] uppercase tracking-[0.24em] text-slate-300/80">{item.label}</p>
                  <p className="mt-2 text-2xl font-semibold text-white">{item.value}</p>
                </div>
              ))}
            </div>
          </GlassCard>

          <div className="grid gap-4 xl:grid-cols-2">
            <WinLossChart data={data.team_win_percentage_chart as any} />
            <BatFirstVsChaseChart batFirst={data.bat_first_win_percentage} chase={data.chase_win_percentage} />
          </div>

          <div className="grid gap-4 xl:grid-cols-2">
            <VenueTrendChart data={data.venue_score_chart as any} />
            <GlassCard>
              <h3 className="text-lg font-semibold text-white">Analyst summary</h3>
              <div className="mt-4 space-y-3">
                {data.summary_points.map((point) => (
                  <p key={point} className="rounded-2xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-slate-300">
                    {point}
                  </p>
                ))}
              </div>
            </GlassCard>
          </div>

          <div className="grid gap-4 xl:grid-cols-2">
            <PlayerRankingChart
              title="Top Run Scorers"
              data={data.top_run_scorers.map((player) => ({
                name: player.player_name,
                value: player.runs,
              }))}
            />
            <PlayerRankingChart
              title="Top Wicket Takers"
              data={data.top_wicket_takers.map((player) => ({
                name: player.player_name,
                value: player.wickets,
              }))}
            />
          </div>

          <div className="grid gap-4 xl:grid-cols-3">
            <PlayerRankingChart
              title="Top 4s"
              fill="#60A5FA"
              data={data.top_four_hitters.map((player) => ({
                name: player.player_name,
                value: player.fours,
              }))}
            />
            <PlayerRankingChart
              title="Top 6s"
              fill="#3B82F6"
              data={data.top_six_hitters.map((player) => ({
                name: player.player_name,
                value: player.sixes,
              }))}
            />
            <PlayerRankingChart
              title="Most Dot Balls"
              fill="#1D4ED8"
              data={data.top_dot_ball_bowlers.map((player) => ({
                name: player.player_name,
                value: player.dot_balls,
              }))}
            />
          </div>
        </div>
      )}
      {!loading && !error && !data && <EmptyState title="No data yet" description="The analytics layer has no completed matches to analyse." actionLabel="Add match" onAction={() => window.location.assign("/add-match")} />}
    </AppShell>
  );
}
