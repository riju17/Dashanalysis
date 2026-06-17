"use client";

import { useEffect, useMemo, useState } from "react";
import { api } from "@/lib/api";
import { AppShell } from "@/components/layout/AppShell";
import { GlassCard } from "@/components/ui/GlassCard";
import { Loader } from "@/components/ui/Loader";
import { ErrorState } from "@/components/ui/ErrorState";
import { EmptyState } from "@/components/ui/EmptyState";
import { TeamCard } from "@/components/cards/TeamCard";
import { TeamComparisonChart } from "@/components/charts/TeamComparisonChart";
import { getTeamTheme, teamThemeNames } from "@/config/teamThemes";
import type { Team, TeamAnalytics } from "@/types/cricket";

export default function TeamsPage() {
  const [teams, setTeams] = useState<Team[]>([]);
  const [selectedTeamId, setSelectedTeamId] = useState("");
  const [teamAnalytics, setTeamAnalytics] = useState<TeamAnalytics | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const selectedTeam = useMemo(() => teams.find((team) => team.id === selectedTeamId) || teams[0], [teams, selectedTeamId]);
  const theme = getTeamTheme(selectedTeam?.team_name);
  const teamLookup = useMemo(() => new Map(teams.map((team) => [team.id, team.team_name])), [teams]);

  const load = async () => {
    setLoading(true);
    setError("");
    try {
      const teamList = await api.getTeams();
      setTeams(teamList);
      const firstTeam = selectedTeamId || teamList[0]?.id;
      if (firstTeam) {
        setSelectedTeamId(firstTeam);
        setTeamAnalytics(await api.getTeam(firstTeam));
      }
    } catch {
      setError("Could not load team analytics.");
    } finally {
      setLoading(false);
    }
  };

  const selectTeam = async (teamId: string) => {
    setSelectedTeamId(teamId);
    setLoading(true);
    try {
      setTeamAnalytics(await api.getTeam(teamId));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, []);

  return (
    <AppShell title="Team Analysis" subtitle="Compare form, phase strength, toss conversion, and coach-ready insights." actionLabel="Refresh" onAction={load}>
      {loading && <Loader />}
      {error && !loading && <ErrorState message={error} onRetry={load} />}
      {!loading && !error && teamAnalytics && selectedTeam && (
        <div className="space-y-6">
          <GlassCard>
            <label className="block">
              <span className="mb-2 block text-xs uppercase tracking-[0.24em] text-slate-400">Select team</span>
              <select
                value={selectedTeamId}
                onChange={(event) => selectTeam(event.target.value)}
                className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-cyan-300/50"
              >
                {teams.map((team) => (
                  <option key={team.id} value={team.id}>
                    {team.team_name}
                  </option>
                ))}
              </select>
            </label>
          </GlassCard>
          <TeamCard data={teamAnalytics} theme={theme} />
          <div className="grid gap-4 xl:grid-cols-2">
            <GlassCard>
              <h3 className="text-lg font-semibold text-white">Key metrics</h3>
              <div className="mt-4 grid gap-3 md:grid-cols-2">
                {Object.entries(teamAnalytics.metrics).map(([label, value]) => (
                  <div key={label} className="rounded-2xl border border-white/10 bg-white/5 p-3">
                    <p className="text-[10px] uppercase tracking-[0.24em] text-slate-400">{label.replaceAll("_", " ")}</p>
                    <p className="mt-1 text-base font-semibold text-white">{typeof value === "number" ? value.toFixed(2) : value}</p>
                  </div>
                ))}
              </div>
            </GlassCard>
            <GlassCard>
              <h3 className="text-lg font-semibold text-white">Match history</h3>
              <div className="mt-4 space-y-2">
                {teamAnalytics.recent_matches.map((match) => {
                  const isWin = match.winner_id === selectedTeamId;
                  const opponentId = match.team_a_id === selectedTeamId ? match.team_b_id : match.team_a_id;
                  const opponentName = teamLookup.get(opponentId) || "Unknown opponent";
                  const teamScore = match.bat_first_team_id === selectedTeamId ? match.first_innings_score : match.second_innings_score;
                  const opponentScore = match.bat_first_team_id === selectedTeamId ? match.second_innings_score : match.first_innings_score;

                  return (
                  <div key={match.id} className="flex items-center gap-3 rounded-2xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-slate-300">
                    <span
                      className={`inline-flex h-8 w-8 items-center justify-center rounded-full text-xs font-semibold ${
                        isWin ? "bg-emerald-400/20 text-emerald-200" : "bg-rose-400/20 text-rose-200"
                      }`}
                    >
                      {isWin ? "W" : "L"}
                    </span>
                    <div className="min-w-0 flex-1">
                      <p className="font-medium text-white">Match {match.match_number} • vs {opponentName}</p>
                      <p className="mt-1 text-xs uppercase tracking-[0.22em] text-slate-400">
                        {isWin ? "Won" : "Lost"} • {match.tournament} • {match.match_date}
                      </p>
                    </div>
                    <p className="text-right text-sm font-semibold text-white">
                      {teamScore ?? 0}-{opponentScore ?? 0}
                    </p>
                  </div>
                  );
                })}
              </div>
            </GlassCard>
          </div>
          <GlassCard>
            <h3 className="text-lg font-semibold text-white">Analyst insights</h3>
            <div className="mt-4 space-y-3 text-sm text-slate-300">
              {teamAnalytics.insights.map((insight) => (
                <p key={insight} className="rounded-2xl border border-white/10 bg-white/5 px-4 py-3">
                  {insight}
                </p>
              ))}
            </div>
          </GlassCard>
        </div>
      )}
      {!loading && !error && (!teamAnalytics || teams.length === 0) && (
        <EmptyState title="No team data" description="Add teams and completed matches to unlock team analysis." actionLabel="Go to admin" onAction={() => window.location.assign("/admin")} />
      )}
    </AppShell>
  );
}
