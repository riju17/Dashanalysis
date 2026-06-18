"use client";

import { ResponsiveContainer, PieChart, Pie, Cell, Tooltip, Legend } from "recharts";
import { GlassCard } from "@/components/ui/GlassCard";

type Props = {
  batFirst: number;
  chase: number;
};

const colors = ["#60A5FA", "#1D4ED8"];

export function BatFirstVsChaseChart({ batFirst, chase }: Props) {
  const data = [
    { name: "Bat first", value: batFirst },
    { name: "Chase", value: chase },
  ];
  return (
    <GlassCard>
      <h3 className="mb-4 text-lg font-semibold text-white">Bat First vs Chase</h3>
      <div className="h-72">
        <ResponsiveContainer width="100%" height="100%">
          <PieChart>
            <Pie data={data} dataKey="value" nameKey="name" innerRadius={60} outerRadius={95} paddingAngle={3}>
              {data.map((entry, index) => (
                <Cell key={`cell-${entry.name}`} fill={colors[index % colors.length]} />
              ))}
            </Pie>
            <Tooltip contentStyle={{ background: "#020617", border: "1px solid rgba(255,255,255,0.1)", borderRadius: 16 }} />
            <Legend />
          </PieChart>
        </ResponsiveContainer>
      </div>
    </GlassCard>
  );
}
