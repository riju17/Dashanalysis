"use client";

import { GlassCard } from "@/components/ui/GlassCard";
import type { TeamAnalytics } from "@/types/cricket";

type TeamCardProps = {
  data: TeamAnalytics;
  theme?: {
    primary: string;
    secondary: string;
    accent: string;
    gradient: string;
    glow: string;
    border: string;
  };
};

export function TeamCard({ data, theme }: TeamCardProps) {
  const { team, metrics, insights } = data;
  const formatPercent = (value: number | undefined) => `${(value ?? 0).toFixed(2)}%`;
  const formatNumber = (value: number | undefined) => (value ?? 0).toLocaleString();
  return (
    <GlassCard className="relative overflow-hidden">
      <div
        className="absolute inset-0 opacity-70"
        style={{ background: theme?.gradient || "linear-gradient(135deg, rgba(56,189,248,0.14), rgba(168,85,247,0.12))" }}
      />
      <div className="relative flex items-start justify-between gap-4">
        <div>
          <p className="text-xs uppercase tracking-[0.35em] text-cyan-200/70">Selected Team</p>
          <h3 className="mt-2 text-2xl font-semibold text-white">{team.team_name}</h3>
          <p className="mt-1 text-sm text-slate-300">{team.short_name} • Strategy, form, and matchup intelligence</p>
        </div>
        <div
          className="rounded-3xl border px-4 py-2 text-sm font-semibold text-white"
          style={{
            borderColor: theme?.border || "rgba(56,189,248,0.4)",
            boxShadow: theme ? `0 0 20px ${theme.glow}` : undefined,
          }}
        >
          Strength {metrics.team_strength_score?.toFixed?.(1) ?? metrics.team_strength_score}
        </div>
      </div>
      <div className="relative mt-5 grid grid-cols-2 gap-3 md:grid-cols-4">
        {[
          ["Win %", formatPercent(metrics.win_percentage)],
          ["Bat first %", formatPercent(metrics.bat_first_win_percentage)],
          ["Chase %", formatPercent(metrics.chase_win_percentage)],
          ["Toss conv %", formatPercent(metrics.toss_conversion_percentage)],
        ].map(([label, value]) => (
          <div key={String(label)} className="rounded-2xl border border-white/10 bg-slate-950/40 p-3">
            <p className="text-xs uppercase tracking-[0.24em] text-slate-400">{label as string}</p>
            <p className="mt-2 text-lg font-semibold text-white">{value as string}</p>
          </div>
        ))}
      </div>
      <div className="relative mt-5">
        <p className="text-xs uppercase tracking-[0.3em] text-slate-400">Team totals</p>
        <div className="mt-3 grid grid-cols-2 gap-3 md:grid-cols-3">
          {[
            ["Runs", formatNumber(metrics.total_runs)],
            ["Avg SR", formatPercent(metrics.avg_strike_rate)],
            ["Avg Econ", (metrics.avg_economy ?? 0).toFixed(2)],
            ["Fours", formatNumber(metrics.fours)],
            ["Sixes", formatNumber(metrics.sixes)],
            ["Wickets", formatNumber(metrics.wickets_taken)],
          ].map(([label, value]) => (
            <div key={String(label)} className="rounded-2xl border border-white/10 bg-slate-950/40 p-3">
              <p className="text-xs uppercase tracking-[0.24em] text-slate-400">{label as string}</p>
              <p className="mt-2 text-lg font-semibold text-white">{value as string}</p>
            </div>
          ))}
        </div>
      </div>
      <div className="relative mt-5 space-y-2 text-sm text-slate-300">
        {insights.slice(0, 3).map((insight) => (
          <p key={insight} className="rounded-2xl border border-white/10 bg-white/5 px-3 py-2">
            {insight}
          </p>
        ))}
      </div>
    </GlassCard>
  );
}
