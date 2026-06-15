"use client";

import { ResponsiveContainer, LineChart, Line, CartesianGrid, Tooltip, XAxis, YAxis } from "recharts";
import { GlassCard } from "@/components/ui/GlassCard";

type Props = {
  data: Array<{ label: string; teamA: number; teamB: number }>;
  teamALabel: string;
  teamBLabel: string;
};

export function TeamComparisonChart({ data, teamALabel, teamBLabel }: Props) {
  return (
    <GlassCard>
      <h3 className="mb-4 text-lg font-semibold text-white">{teamALabel} vs {teamBLabel}</h3>
      <div className="h-80">
        <ResponsiveContainer width="100%" height="100%">
          <LineChart data={data}>
            <CartesianGrid strokeDasharray="3 3" stroke="rgba(148,163,184,0.15)" />
            <XAxis dataKey="label" tick={{ fill: "#CBD5E1", fontSize: 12 }} />
            <YAxis tick={{ fill: "#CBD5E1", fontSize: 12 }} />
            <Tooltip contentStyle={{ background: "#020617", border: "1px solid rgba(255,255,255,0.1)", borderRadius: 16 }} />
            <Line type="monotone" dataKey="teamA" stroke="#22D3EE" strokeWidth={3} dot={{ r: 4 }} />
            <Line type="monotone" dataKey="teamB" stroke="#F472B6" strokeWidth={3} dot={{ r: 4 }} />
          </LineChart>
        </ResponsiveContainer>
      </div>
    </GlassCard>
  );
}
