"use client";

import { useEffect, useMemo, useState } from "react";
import { motion } from "framer-motion";
import { api } from "@/lib/api";
import { AppShell } from "@/components/layout/AppShell";
import { GlassCard } from "@/components/ui/GlassCard";
import { Loader } from "@/components/ui/Loader";
import { ErrorState } from "@/components/ui/ErrorState";
import { EmptyState } from "@/components/ui/EmptyState";
import { NeonButton } from "@/components/ui/NeonButton";
import { getTeamTheme } from "@/config/teamThemes";
import { getBrowserTournamentPath } from "@/lib/tournament";
import type { MatchRecord } from "@/types/cricket";

export default function DataManagerPage() {
  const [matches, setMatches] = useState<MatchRecord[]>([]);
  const [teams, setTeams] = useState<Array<{ id: string; team_name: string }>>([]);
  const [query, setQuery] = useState("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const load = async () => {
    setLoading(true);
    setError("");
    try {
      const [matchList, teamList] = await Promise.all([api.getMatches(), api.getTeams()]);
      setMatches(matchList);
      setTeams(teamList);
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
  const teamLookup = useMemo(() => new Map(teams.map((team) => [team.id, team])), [teams]);

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
              <EmptyState title="No matches found" description="Clear the filter or add completed matches to populate the data manager." actionLabel="Add match" onAction={() => window.location.assign(getBrowserTournamentPath("/add-match"))} />
            )}
            {filtered.map((match) => (
              <ThemedMatchCard
                key={match.id}
                match={match}
                teamA={teamLookup.get(match.team_a_id)}
                teamB={teamLookup.get(match.team_b_id)}
                onDelete={deleteMatch}
              />
            ))}
          </div>
        </div>
      )}
    </AppShell>
  );
}

function toRgba(hex: string, alpha: number) {
  const clean = hex.replace("#", "");
  const normalized = clean.length === 3 ? clean.split("").map((char) => char + char).join("") : clean;
  const red = Number.parseInt(normalized.slice(0, 2), 16);
  const green = Number.parseInt(normalized.slice(2, 4), 16);
  const blue = Number.parseInt(normalized.slice(4, 6), 16);
  return `rgba(${red}, ${green}, ${blue}, ${alpha})`;
}

function ThemedMatchCard({
  match,
  teamA,
  teamB,
  onDelete,
}: {
  match: MatchRecord;
  teamA?: { id: string; team_name: string };
  teamB?: { id: string; team_name: string };
  onDelete: (matchId: string) => void;
}) {
  const themeA = getTeamTheme(teamA?.team_name);
  const themeB = getTeamTheme(teamB?.team_name);
  const cardA = toRgba(themeA.primary, 0.10);
  const cardB = toRgba(themeB.primary, 0.10);
  const hoverA = toRgba(themeA.primary, 0.28);
  const hoverB = toRgba(themeB.primary, 0.26);
  const borderA = toRgba(themeA.primary, 0.18);
  const borderB = toRgba(themeB.primary, 0.16);

  return (
    <motion.div
      initial={{ opacity: 0, y: 16 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.35 }}
      className="group relative overflow-hidden rounded-3xl border border-white/10 bg-slate-950/80 p-4 backdrop-blur-xl transition-all duration-300 hover:-translate-y-0.5 hover:border-transparent"
      style={{
        backgroundImage: `linear-gradient(135deg, ${cardA}, ${cardB}), linear-gradient(135deg, rgba(9, 15, 32, 0.96), rgba(15, 23, 42, 0.92))`,
        boxShadow: `0 0 0 1px ${borderA}, 0 0 0 1px ${borderB}, 0 12px 34px rgba(2, 6, 23, 0.35)`,
      }}
    >
      <div
        className="absolute inset-0 opacity-0 transition-opacity duration-300 group-hover:opacity-100"
        style={{
          backgroundImage: `radial-gradient(circle at top left, ${hoverA}, transparent 42%), radial-gradient(circle at bottom right, ${hoverB}, transparent 38%), linear-gradient(135deg, rgba(15, 23, 42, 0.16), rgba(15, 23, 42, 0.28))`,
          boxShadow: `inset 0 0 0 1px ${toRgba(themeA.primary, 0.30)}, inset 0 0 0 1px ${toRgba(themeB.primary, 0.26)}, 0 0 34px ${hoverA}, 0 0 34px ${hoverB}`,
        }}
      />
      <div
        className="absolute inset-x-0 top-0 h-1.5 origin-left scale-x-75 rounded-full opacity-60 transition-all duration-300 group-hover:scale-x-100 group-hover:opacity-100"
        style={{
          backgroundImage: `linear-gradient(90deg, ${themeA.primary}, ${themeB.primary})`,
          boxShadow: `0 0 18px ${toRgba(themeA.primary, 0.55)}, 0 0 18px ${toRgba(themeB.primary, 0.45)}`,
        }}
      />
      <div className="relative z-10 flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
        <div className="min-w-0">
          <p className="text-xs uppercase tracking-[0.24em] text-white/55">
            Match {match.match_number} • {match.season}
          </p>
          <h3 className="mt-1 text-lg font-semibold text-white">{match.tournament}</h3>
          <p className="mt-1 text-sm text-white/68">
            {match.match_date} • Score {match.first_innings_score}-{match.second_innings_score} • {match.notes}
          </p>
          <div className="mt-3 flex flex-wrap items-center gap-2 text-[10px] uppercase tracking-[0.22em] text-white/55">
            <span className="rounded-full border border-white/10 bg-white/5 px-2.5 py-1">{teamA?.team_name || "Team A"}</span>
            <span className="rounded-full border border-white/10 bg-white/5 px-2.5 py-1">vs</span>
            <span className="rounded-full border border-white/10 bg-white/5 px-2.5 py-1">{teamB?.team_name || "Team B"}</span>
          </div>
        </div>
        <div className="flex flex-wrap items-center gap-3">
          <NeonButton className="bg-white/10 transition-transform duration-300 group-hover:translate-y-[-1px]" onClick={() => window.location.assign(getBrowserTournamentPath(`/matches/${match.id}`))}>
            View match
          </NeonButton>
          <NeonButton className="transition-transform duration-300 group-hover:translate-y-[-1px]" onClick={() => window.location.assign(getBrowserTournamentPath(`/reports?match=${match.id}`))}>
            Generate report
          </NeonButton>
          <button
            onClick={() => onDelete(match.id)}
            className="rounded-2xl border border-rose-400/20 bg-rose-500/10 px-4 py-2 text-sm font-semibold text-rose-100 transition-all duration-300 group-hover:border-rose-300/40 group-hover:bg-rose-500/20"
          >
            Delete
          </button>
        </div>
      </div>
    </motion.div>
  );
}
