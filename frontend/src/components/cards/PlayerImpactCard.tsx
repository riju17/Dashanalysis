"use client";

import { GlassCard } from "@/components/ui/GlassCard";
import type { PlayerAnalytics } from "@/types/cricket";

type Props = {
  data: PlayerAnalytics;
  rankLabel?: string;
};

export function PlayerImpactCard({ data, rankLabel }: Props) {
  const { player, batting, bowling, impact, insights } = data;
  return (
    <GlassCard className="h-full">
      <div className="flex items-start justify-between gap-4">
        <div>
          <p className="text-xs uppercase tracking-[0.3em] text-cyan-200/70">{rankLabel || player.role}</p>
          <h3 className="mt-2 text-xl font-semibold text-white">{player.player_name}</h3>
          <p className="text-sm text-slate-400">{player.batting_style} • {player.bowling_style}</p>
        </div>
        <div className="rounded-2xl border border-cyan-300/20 bg-cyan-400/10 px-3 py-2 text-right">
          <p className="text-[10px] uppercase tracking-[0.3em] text-cyan-200/80">All-rounder</p>
          <p className="text-lg font-semibold text-white">{impact.all_rounder_index?.toFixed?.(1) ?? impact.all_rounder_index}</p>
        </div>
      </div>
      <div className="mt-4 grid grid-cols-2 gap-3 text-sm">
        <Stat label="Runs" value={batting.total_runs} />
        <Stat label="Strike rate" value={`${batting.batting_strike_rate?.toFixed?.(1) ?? batting.batting_strike_rate}`} />
        <Stat label="Wickets" value={bowling.wickets} />
        <Stat label="Economy" value={`${bowling.economy?.toFixed?.(2) ?? bowling.economy}`} />
      </div>
      <div className="mt-4 space-y-2 text-sm text-slate-300">
        {insights.slice(0, 2).map((item) => (
          <p key={item} className="rounded-2xl border border-white/10 bg-white/5 px-3 py-2">
            {item}
          </p>
        ))}
      </div>
    </GlassCard>
  );
}

function Stat({ label, value }: { label: string; value: string | number }) {
  return (
    <div className="rounded-2xl border border-white/10 bg-white/5 p-3">
      <p className="text-[10px] uppercase tracking-[0.22em] text-slate-400">{label}</p>
      <p className="mt-1 text-base font-semibold text-white">{value}</p>
    </div>
  );
}
