"use client";

import { ResponsiveContainer, BarChart, Bar, CartesianGrid, Tooltip, XAxis, YAxis } from "recharts";
import { GlassCard } from "@/components/ui/GlassCard";

type Props = {
  data: Array<{ name: string; value: number }>;
  title: string;
};

export function PlayerRankingChart({ data, title }: Props) {
  return (
    <GlassCard>
      <h3 className="mb-4 text-lg font-semibold text-white">{title}</h3>
      <div className="h-80">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={data} layout="vertical">
            <CartesianGrid strokeDasharray="3 3" stroke="rgba(148,163,184,0.15)" />
            <XAxis type="number" tick={{ fill: "#CBD5E1", fontSize: 12 }} />
            <YAxis type="category" dataKey="name" tick={{ fill: "#CBD5E1", fontSize: 12 }} width={140} />
            <Tooltip contentStyle={{ background: "#020617", border: "1px solid rgba(255,255,255,0.1)", borderRadius: 16 }} />
            <Bar dataKey="value" fill="#38BDF8" radius={[0, 12, 12, 0]} />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </GlassCard>
  );
}
