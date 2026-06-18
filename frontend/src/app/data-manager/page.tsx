"use client";

import { useEffect, useMemo, useState } from "react";
import { api } from "@/lib/api";
import { AppShell } from "@/components/layout/AppShell";
import { GlassCard } from "@/components/ui/GlassCard";
import { Loader } from "@/components/ui/Loader";
import { ErrorState } from "@/components/ui/ErrorState";
import { EmptyState } from "@/components/ui/EmptyState";
import { NeonButton } from "@/components/ui/NeonButton";
import { getTeamTheme } from "@/config/teamThemes";
import type { MatchRecord, Team } from "@/types/cricket";

function hexToRgba(hex: string, alpha: number) {
  const normalized = hex.replace("#", "");
  const full = normalized.length === 3 ? normalized.split("").map((char) => char + char).join("") : normalized;
  const red = Number.parseInt(full.slice(0, 2), 16);
  const green = Number.parseInt(full.slice(2, 4), 16);
  const blue = Number.parseInt(full.slice(4, 6), 16);
  return `rgba(${red}, ${green}, ${blue}, ${alpha})`;
}

function buildMatchCardStyle(teamAColor: string, teamBColor: string) {
  return {
    backgroundImage: [
      `linear-gradient(135deg, ${hexToRgba(teamAColor, 0.32)}, ${hexToRgba(teamBColor, 0.28)})`,
      "linear-gradient(135deg, rgba(15, 23, 42, 0.94), rgba(15, 23, 42, 0.84))",
    ].join(", "),
    boxShadow: `0 0 26px ${hexToRgba(teamAColor, 0.14)}, 0 0 26px ${hexToRgba(teamBColor, 0.12)}`,
    borderColor: hexToRgba(teamAColor, 0.28),
  };
}

export default function DataManagerPage() {
  const [matches, setMatches] = useState<MatchRecord[]>([]);
  const [teams, setTeams] = useState<Team[]>([]);
  const [query, setQuery] = useState("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const load = async () => {
    setLoading(true);
    setError("");
    try {
      const [matchesResult, teamsResult] = await Promise.allSettled([api.getMatches(), api.getTeams()]);
      if (matchesResult.status === "fulfilled") {
        setMatches(matchesResult.value);
      } else {
        throw matchesResult.reason;
      }
      setTeams(teamsResult.status === "fulfilled" ? teamsResult.value : []);
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
              <EmptyState title="No matches found" description="Clear the filter or add completed matches to populate the data manager." actionLabel="Add match" onAction={() => window.location.assign("/add-match")} />
            )}
            {filtered.map((match) => (
              <MatchCard key={match.id} match={match} teamLookup={teamLookup} deleteMatch={deleteMatch} />
            ))}
          </div>
        </div>
      )}
    </AppShell>
  );
}

function MatchCard({
  match,
  teamLookup,
  deleteMatch,
}: {
  match: MatchRecord;
  teamLookup: Map<string, Team>;
  deleteMatch?: (matchId: string) => void;
}) {
  const teamA = teamLookup.get(match.team_a_id);
  const teamB = teamLookup.get(match.team_b_id);
  const themeA = getTeamTheme(teamA?.team_name);
  const themeB = getTeamTheme(teamB?.team_name);
  const cardStyle = buildMatchCardStyle(themeA.primary, themeB.primary);

  return (
    <GlassCard className="relative flex flex-col gap-4 overflow-hidden md:flex-row md:items-center md:justify-between" style={cardStyle}>
      <div className="pointer-events-none absolute inset-x-0 top-0 h-1.5" style={{ backgroundImage: `linear-gradient(90deg, ${themeA.primary}, ${themeB.primary})` }} />
      <div className="pointer-events-none absolute inset-0 bg-slate-950/40" />
      <div className="relative z-10">
        <p className="text-xs uppercase tracking-[0.24em] text-white/75">
          Match {match.match_number} • {match.season}
        </p>
        <h3 className="mt-1 text-lg font-semibold text-white">{match.tournament}</h3>
        <p className="mt-1 text-sm text-white/75">
          {match.match_date} • Score {match.first_innings_score}-{match.second_innings_score} • {match.notes}
        </p>
      </div>
      <div className="relative z-10 flex items-center gap-3">
        <NeonButton className="bg-white/10" onClick={() => window.location.assign(`/matches/${match.id}`)}>
          View match
        </NeonButton>
        <NeonButton onClick={() => window.location.assign(`/reports?match=${match.id}`)}>Generate report</NeonButton>
        <button onClick={() => deleteMatch?.(match.id)} className="rounded-2xl border border-rose-400/30 bg-rose-500/10 px-4 py-2 text-sm font-semibold text-rose-100">
          Delete
        </button>
      </div>
    </GlassCard>
  );
}
