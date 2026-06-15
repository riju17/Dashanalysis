"use client";

import { ResponsiveContainer, AreaChart, Area, Tooltip, CartesianGrid, XAxis, YAxis } from "recharts";
import { GlassCard } from "@/components/ui/GlassCard";

type Props = {
  data: Array<{ venue_name: string; average_first_innings_score?: number; average_second_innings_score?: number }>;
};

export function VenueTrendChart({ data }: Props) {
  return (
    <GlassCard>
      <h3 className="mb-4 text-lg font-semibold text-white">Venue Score Trend</h3>
      <div className="h-80">
        <ResponsiveContainer width="100%" height="100%">
          <AreaChart data={data}>
            <CartesianGrid strokeDasharray="3 3" stroke="rgba(148,163,184,0.15)" />
            <XAxis dataKey="venue_name" tick={{ fill: "#CBD5E1", fontSize: 12 }} interval={0} angle={-20} textAnchor="end" height={60} />
            <YAxis tick={{ fill: "#CBD5E1", fontSize: 12 }} />
            <Tooltip contentStyle={{ background: "#020617", border: "1px solid rgba(255,255,255,0.1)", borderRadius: 16 }} />
            <Area type="monotone" dataKey="average_first_innings_score" stroke="#22D3EE" fill="rgba(34,211,238,0.18)" strokeWidth={2} />
            <Area type="monotone" dataKey="average_second_innings_score" stroke="#A855F7" fill="rgba(168,85,247,0.12)" strokeWidth={2} />
          </AreaChart>
        </ResponsiveContainer>
      </div>
    </GlassCard>
  );
}
