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

export default function ReportsPage() {
  const [matches, setMatches] = useState<MatchRecord[]>([]);
  const [selectedMatchId, setSelectedMatchId] = useState("");
  const [report, setReport] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [working, setWorking] = useState(false);
  const [error, setError] = useState("");

  const load = async () => {
    setLoading(true);
    setError("");
    try {
      const matchList = await api.getMatches();
      setMatches(matchList);
      setSelectedMatchId((current) => current || matchList[0]?.id || "");
    } catch {
      setError("Could not load reports.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, []);

  const selectedMatch = useMemo(() => matches.find((match) => match.id === selectedMatchId), [matches, selectedMatchId]);

  const createReport = async () => {
    if (!selectedMatchId) return;
    setWorking(true);
    try {
      const response = await api.createReport(selectedMatchId);
      setReport(response.report || response);
    } finally {
      setWorking(false);
    }
  };

  return (
    <AppShell title="Report Generator" subtitle="Generate coach-friendly intelligence notes and downloadable summaries." actionLabel="Generate" onAction={createReport}>
      {loading && <Loader />}
      {error && !loading && <ErrorState message={error} onRetry={load} />}
      {!loading && !error && (
        <div className="space-y-6">
          <GlassCard>
            <div className="grid gap-4 md:grid-cols-[1fr_auto] md:items-end">
              <label className="block">
                <span className="mb-2 block text-xs uppercase tracking-[0.24em] text-slate-400">Select completed match</span>
                <select
                  value={selectedMatchId}
                  onChange={(event) => setSelectedMatchId(event.target.value)}
                  className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-cyan-300/50"
                >
                  {matches.map((match) => (
                    <option key={match.id} value={match.id}>
                      Match {match.match_number} • {match.tournament}
                    </option>
                  ))}
                </select>
              </label>
              <NeonButton loading={working} onClick={createReport}>
                Generate report
              </NeonButton>
              {selectedMatchId && (
                <button
                  type="button"
                  onClick={() => window.location.assign(`/matches/${selectedMatchId}`)}
                  className="rounded-2xl border border-white/10 bg-white/5 px-4 py-2 text-sm font-semibold text-slate-200 transition hover:border-cyan-300/30 hover:text-white"
                >
                  View match
                </button>
              )}
            </div>
            {selectedMatch && (
              <p className="mt-4 text-sm text-slate-400">
                Selected match: {selectedMatch.tournament} • {selectedMatch.match_date} • {selectedMatch.first_innings_score}-{selectedMatch.second_innings_score}
              </p>
            )}
          </GlassCard>

          <div className="grid gap-4 xl:grid-cols-2">
            <GlassCard>
              <h3 className="text-lg font-semibold text-white">Report preview</h3>
              <div className="mt-4 space-y-3 text-sm text-slate-300">
                {report ? (
                  Object.entries(report.report_json || report).map(([key, value]) => (
                    <div key={key} className="rounded-2xl border border-white/10 bg-white/5 px-4 py-3">
                      <p className="text-xs uppercase tracking-[0.24em] text-cyan-200/70">{key.replaceAll("_", " ")}</p>
                      <p className="mt-1 text-slate-200">{typeof value === "string" ? value : JSON.stringify(value, null, 2)}</p>
                    </div>
                  ))
                ) : (
                  <p className="rounded-2xl border border-dashed border-white/15 bg-white/5 px-4 py-5 text-slate-400">
                    Generate a report to preview match summary, turning points, player impact, and strategy notes.
                  </p>
                )}
              </div>
            </GlassCard>
            <GlassCard>
              <h3 className="text-lg font-semibold text-white">Downloadable output</h3>
              <p className="mt-3 text-sm text-slate-300">
                Automated PDF export is prepared as a future enhancement. The current MVP returns a structured JSON intelligence report ready for downstream rendering.
              </p>
              <div className="mt-4 rounded-2xl border border-dashed border-white/15 bg-white/5 px-4 py-5 text-sm text-slate-400">
                {report ? "Report ready for export pipeline" : "No report generated yet"}
              </div>
            </GlassCard>
          </div>
        </div>
      )}
      {!loading && !error && matches.length === 0 && (
        <EmptyState title="No reports available" description="Generate a match report after entering completed matches." actionLabel="Add match" onAction={() => window.location.assign("/add-match")} />
      )}
    </AppShell>
  );
}
