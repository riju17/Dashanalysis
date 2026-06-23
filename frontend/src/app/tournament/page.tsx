"use client";

import { useEffect, useState } from "react";
import { api } from "@/lib/api";
import { AppShell } from "@/components/layout/AppShell";
import { GlassCard } from "@/components/ui/GlassCard";
import { Loader } from "@/components/ui/Loader";
import { ErrorState } from "@/components/ui/ErrorState";
import { EmptyState } from "@/components/ui/EmptyState";
import { getBrowserTournamentPath } from "@/lib/tournament";
import type { StandingRow } from "@/types/cricket";

export default function TournamentPage() {
  const [standings, setStandings] = useState<StandingRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const load = async () => {
    setLoading(true);
    setError("");
    try {
      setStandings(await api.getStandings());
    } catch {
      setError("Could not load tournament dashboard.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, []);

  return (
    <AppShell title="Tournament Dashboard" subtitle="Track table momentum and qualification readiness with broadcast-style clarity." actionLabel="Reload" onAction={load}>
      {loading && <Loader />}
      {error && !loading && <ErrorState message={error} onRetry={load} />}
      {!loading && !error && (
        <div className="space-y-6">
          <div className="grid gap-4 md:grid-cols-2">
            {[
              ["Points leader", standings[0]?.team_name],
              ["Qualification probability", "Model ready"],
            ].map(([label, value]) => (
              <GlassCard key={label as string}>
                <p className="text-[10px] uppercase tracking-[0.24em] text-slate-400">{label as string}</p>
                <p className="mt-2 text-2xl font-semibold text-white">{String(value)}</p>
              </GlassCard>
            ))}
          </div>

          <GlassCard>
            <h3 className="text-lg font-semibold text-white">Points table</h3>
            <div className="mt-4 overflow-x-auto">
              <table className="min-w-full text-left text-sm">
                <thead className="text-slate-400">
                  <tr>
                    <th className="px-3 py-2">Team</th>
                    <th className="px-3 py-2">Played</th>
                    <th className="px-3 py-2">Wins</th>
                    <th className="px-3 py-2">Losses</th>
                    <th className="px-3 py-2">Points</th>
                  </tr>
                </thead>
                <tbody>
                  {standings.map((row) => (
                    <tr key={row.team_id} className="border-t border-white/10">
                      <td className="px-3 py-3 text-white">{row.team_name}</td>
                      <td className="px-3 py-3 text-slate-300">{row.played}</td>
                      <td className="px-3 py-3 text-slate-300">{row.wins}</td>
                      <td className="px-3 py-3 text-slate-300">{row.losses}</td>
                      <td className="px-3 py-3 text-slate-300">{row.points}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </GlassCard>

          <GlassCard>
            <h3 className="text-lg font-semibold text-white">Top performers and momentum placeholders</h3>
            <p className="mt-3 text-sm text-slate-300">
              This module is wired for future qualification models, playoff probabilities, and momentum curves once more season-level match data accumulates.
            </p>
          </GlassCard>
        </div>
      )}
      {!loading && !error && standings.length === 0 && (
        <EmptyState title="No tournament data" description="Seed matches to populate the tournament dashboard and points table." actionLabel="Add match" onAction={() => window.location.assign(getBrowserTournamentPath("/add-match"))} />
      )}
    </AppShell>
  );
}
