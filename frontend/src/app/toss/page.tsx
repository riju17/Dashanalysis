"use client";

import { useEffect, useState } from "react";
import { api } from "@/lib/api";
import { AppShell } from "@/components/layout/AppShell";
import { GlassCard } from "@/components/ui/GlassCard";
import { Loader } from "@/components/ui/Loader";
import { ErrorState } from "@/components/ui/ErrorState";
import { EmptyState } from "@/components/ui/EmptyState";
import type { TossAnalytics } from "@/types/cricket";

export default function TossPage() {
  const [data, setData] = useState<TossAnalytics | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const load = async () => {
    setLoading(true);
    setError("");
    try {
      setData(await api.getTossAnalytics());
    } catch {
      setError("Could not load toss analytics.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, []);

  return (
    <AppShell title="Toss Analysis" subtitle="Measure toss-winning conversion and bat/bowl decision efficiency." actionLabel="Reload" onAction={load}>
      {loading && <Loader />}
      {error && !loading && <ErrorState message={error} onRetry={load} />}
      {!loading && !error && data && (
        <div className="space-y-6">
          <div className="grid gap-4 md:grid-cols-3">
            {[
              ["Toss winner win %", data.overall.toss_winner_match_win_percentage],
              ["Bat decision %", data.overall.bat_decision_success_percentage],
              ["Bowl decision %", data.overall.bowl_decision_success_percentage],
            ].map(([label, value]) => (
              <GlassCard key={label as string}>
                <p className="text-[10px] uppercase tracking-[0.24em] text-slate-400">{label as string}</p>
                <p className="mt-2 text-3xl font-semibold text-white">{typeof value === "number" ? value.toFixed(1) : value}%</p>
              </GlassCard>
            ))}
          </div>

          <GlassCard>
            <h3 className="text-lg font-semibold text-white">Team-wise toss conversion</h3>
            <div className="mt-4 overflow-x-auto">
              <table className="min-w-full text-left text-sm">
                <thead className="text-slate-400">
                  <tr>
                    <th className="px-3 py-2">Team</th>
                    <th className="px-3 py-2">Toss wins</th>
                    <th className="px-3 py-2">Conversion %</th>
                  </tr>
                </thead>
                <tbody>
                  {data.team_wise.map((row) => (
                    <tr key={String(row.team_id)} className="border-t border-white/10">
                      <td className="px-3 py-3 text-white">{String(row.team_name)}</td>
                      <td className="px-3 py-3 text-slate-300">{String(row.toss_wins)}</td>
                      <td className="px-3 py-3 text-slate-300">{String(row.toss_conversion_percentage)}%</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </GlassCard>

          <GlassCard>
            <h3 className="text-lg font-semibold text-white">Toss insights</h3>
            <div className="mt-4 space-y-3 text-sm text-slate-300">
              {data.insights.map((insight) => (
                <p key={insight} className="rounded-2xl border border-white/10 bg-white/5 px-4 py-3">
                  {insight}
                </p>
              ))}
            </div>
          </GlassCard>
        </div>
      )}
      {!loading && !error && !data && (
        <EmptyState title="No toss data" description="Toss analysis will appear after completed matches are entered." actionLabel="Add match" onAction={() => window.location.assign("/add-match")} />
      )}
    </AppShell>
  );
}
