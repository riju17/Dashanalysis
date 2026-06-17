"use client";

import { useEffect, useMemo, useState } from "react";
import { api } from "@/lib/api";
import { AppShell } from "@/components/layout/AppShell";
import { GlassCard } from "@/components/ui/GlassCard";
import { Loader } from "@/components/ui/Loader";
import { ErrorState } from "@/components/ui/ErrorState";
import { EmptyState } from "@/components/ui/EmptyState";
import { NeonButton } from "@/components/ui/NeonButton";
import type { MatchRecord } from "@/types/cricket";

export default function DataManagerPage() {
  const [matches, setMatches] = useState<MatchRecord[]>([]);
  const [query, setQuery] = useState("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const load = async () => {
    setLoading(true);
    setError("");
    try {
      setMatches(await api.getMatches());
    } catch {
      setError("Could not load match data.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, []);

  const filtered = useMemo(
    () =>
      matches
        .slice()
        .sort((left, right) => right.match_number - left.match_number)
        .filter((match) => `${match.tournament} ${match.season} ${match.match_number} ${match.notes || ""}`.toLowerCase().includes(query.toLowerCase())),
    [matches, query],
  );

  const exportCsv = () => {
    const headers = ["match_number", "tournament", "season", "date", "winner", "venue", "first_innings_score", "second_innings_score"];
    const rows = filtered.map((match) => [
      match.match_number,
      match.tournament,
      match.season,
      match.match_date,
      match.winner_id,
      match.venue_id,
      match.first_innings_score,
      match.second_innings_score,
    ]);
    const csv = [headers, ...rows].map((row) => row.join(",")).join("\n");
    const blob = new Blob([csv], { type: "text/csv;charset=utf-8;" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = "statstrike-matches.csv";
    link.click();
    URL.revokeObjectURL(url);
  };

  const deleteMatch = async (matchId: string) => {
    if (!confirm("Delete this match and its dependent player stats?")) {
      return;
    }
    await api.deleteMatch(matchId);
    setMatches((current) => current.filter((match) => match.id !== matchId));
  };

  return (
    <AppShell title="Data Manager" subtitle="Browse, export, and maintain completed match records." actionLabel="Reload" onAction={load}>
      {loading && <Loader />}
      {error && !loading && <ErrorState message={error} onRetry={load} />}
      {!loading && !error && (
        <div className="space-y-6">
          <GlassCard>
            <div className="flex flex-wrap items-center gap-3">
              <input
                value={query}
                onChange={(event) => setQuery(event.target.value)}
                placeholder="Filter matches by season, tournament, or notes"
                className="min-w-[280px] flex-1 rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-cyan-300/50"
              />
              <NeonButton onClick={exportCsv}>Export CSV</NeonButton>
              <NeonButton className="bg-white/10">Import CSV placeholder</NeonButton>
            </div>
          </GlassCard>

          <div className="space-y-3">
            {filtered.length === 0 && (
              <EmptyState title="No matches found" description="Clear the filter or add completed matches to populate the data manager." actionLabel="Add match" onAction={() => window.location.assign("/add-match")} />
            )}
            {filtered.map((match) => (
              <GlassCard key={match.id} className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
                <div>
                  <p className="text-xs uppercase tracking-[0.24em] text-cyan-200/70">
                    Match {match.match_number} • {match.season}
                  </p>
                  <h3 className="mt-1 text-lg font-semibold text-white">{match.tournament}</h3>
                  <p className="mt-1 text-sm text-slate-400">
                    {match.match_date} • Score {match.first_innings_score}-{match.second_innings_score} • {match.notes}
                  </p>
                </div>
                <div className="flex items-center gap-3">
                  <NeonButton className="bg-white/10" onClick={() => window.location.assign(`/matches/${match.id}`)}>
                    View match
                  </NeonButton>
                  <NeonButton onClick={() => window.location.assign(`/reports?match=${match.id}`)}>Generate report</NeonButton>
                  <button onClick={() => deleteMatch(match.id)} className="rounded-2xl border border-rose-400/30 bg-rose-500/10 px-4 py-2 text-sm font-semibold text-rose-100">
                    Delete
                  </button>
                </div>
              </GlassCard>
            ))}
          </div>
        </div>
      )}
    </AppShell>
  );
}
