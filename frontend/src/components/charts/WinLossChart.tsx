"use client";

import {
  BarChart,
  Bar,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { GlassCard } from "@/components/ui/GlassCard";

type Props = {
  data: Array<{ team_name: string; wins?: number; losses?: number; win_percentage?: number }>;
};

export function WinLossChart({ data }: Props) {
  return (
    <GlassCard>
      <h3 className="mb-4 text-lg font-semibold text-white">Team Win Percentage</h3>
      <div className="h-80">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={data}>
            <CartesianGrid strokeDasharray="3 3" stroke="rgba(148,163,184,0.15)" />
            <XAxis dataKey="team_name" tick={{ fill: "#CBD5E1", fontSize: 12 }} interval={0} angle={-25} textAnchor="end" height={60} />
            <YAxis tick={{ fill: "#CBD5E1", fontSize: 12 }} />
            <Tooltip contentStyle={{ background: "#020617", border: "1px solid rgba(255,255,255,0.1)", borderRadius: 16 }} />
            <Bar dataKey="win_percentage" fill="#60A5FA" radius={[12, 12, 0, 0]} />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </GlassCard>
  );
}
