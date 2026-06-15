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
import { getTeamTheme } from "@/config/teamThemes";
import type { DashboardData } from "@/types/cricket";

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

  const theme = getTeamTheme("Indore Pink Panthers");

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
            <KPICard label="Total Matches" value={data.total_matches} icon={<Activity className="h-4 w-4" />} theme={theme} />
            <KPICard label="Total Teams" value={data.total_teams} icon={<Trophy className="h-4 w-4" />} theme={theme} />
            <KPICard label="Total Players" value={data.total_players} icon={<Users className="h-4 w-4" />} theme={theme} />
            <KPICard label="Average 1st Innings" value={data.average_first_innings_score.toFixed(1)} icon={<MapPin className="h-4 w-4" />} theme={theme} />
            <KPICard label="Chase Win %" value={`${data.chase_win_percentage.toFixed(1)}%`} icon={<TrendingUp className="h-4 w-4" />} trend="Chasing edge rising" trendDirection="up" theme={theme} />
            <KPICard label="Bat First Win %" value={`${data.bat_first_win_percentage.toFixed(1)}%`} icon={<CircleDollarSign className="h-4 w-4" />} theme={theme} />
            <KPICard label="Toss Conversion %" value={`${data.toss_conversion_percentage.toFixed(1)}%`} icon={<Target className="h-4 w-4" />} theme={theme} />
            <KPICard label="Highest Score" value={data.highest_score} icon={<Scale className="h-4 w-4" />} theme={theme} />
          </div>

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
        </div>
      )}
      {!loading && !error && !data && <EmptyState title="No data yet" description="The analytics layer has no completed matches to analyse." actionLabel="Add match" onAction={() => window.location.assign("/add-match")} />}
    </AppShell>
  );
}
