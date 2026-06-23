"use client";

import { useEffect, useMemo, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { ArrowLeft, ChartColumnBig, FileText, Sparkles } from "lucide-react";
import { api } from "@/lib/api";
import { AppShell } from "@/components/layout/AppShell";
import { GlassCard } from "@/components/ui/GlassCard";
import { Loader } from "@/components/ui/Loader";
import { ErrorState } from "@/components/ui/ErrorState";
import { EmptyState } from "@/components/ui/EmptyState";
import { NeonButton } from "@/components/ui/NeonButton";
import { WinProbabilityCard } from "@/components/cards/WinProbabilityCard";
import { getTeamTheme } from "@/config/teamThemes";
import { getBrowserTournamentPath } from "@/lib/tournament";
import type { MatchImportRecord, MatchPlayerStatRecord, MatchRecord, Player, ReportRecord, Team, Venue } from "@/types/cricket";

type MatchSectionRow = MatchPlayerStatRecord & {
  player_name: string;
  team_name: string;
};

export default function MatchDetailPage() {
  const router = useRouter();
  const params = useParams<{ matchId: string }>();
  const matchId = params?.matchId || "";
  const [match, setMatch] = useState<MatchRecord | null>(null);
  const [stats, setStats] = useState<MatchPlayerStatRecord[]>([]);
  const [teams, setTeams] = useState<Team[]>([]);
  const [players, setPlayers] = useState<Player[]>([]);
  const [venues, setVenues] = useState<Venue[]>([]);
  const [reports, setReports] = useState<ReportRecord[]>([]);
  const [matchImport, setMatchImport] = useState<MatchImportRecord | null>(null);
  const [loading, setLoading] = useState(true);
  const [working, setWorking] = useState(false);
  const [error, setError] = useState("");
  const [message, setMessage] = useState("");

  const load = async () => {
    if (!matchId) return;
    setLoading(true);
    setError("");
    try {
      const [matchData, statRows, teamRows, playerRows, venueRows, reportRows, importRecord] = await Promise.all([
        api.getMatch(matchId),
        api.getMatchPlayerStats(matchId),
        api.getTeams(),
        api.getPlayers(),
        api.getVenues(),
        api.getReports(),
        api.getImportForMatch(matchId).catch(() => null),
      ]);
      setMatch(matchData);
      setStats(statRows);
      setTeams(teamRows);
      setPlayers(playerRows);
      setVenues(venueRows);
      setReports(reportRows);
      setMatchImport(importRecord);
    } catch {
      setError("Could not load match details.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, [matchId]);

  const teamById = useMemo(() => new Map(teams.map((team) => [team.id, team])), [teams]);
  const playerById = useMemo(() => new Map(players.map((player) => [player.id, player])), [players]);
  const venueById = useMemo(() => new Map(venues.map((venue) => [venue.id, venue])), [venues]);
  const reportForMatch = useMemo(() => reports.find((report) => report.match_id === matchId), [reports, matchId]);
  const dismissalByPlayerId = useMemo(() => {
    const lookup = new Map<string, string>();
    if (!matchImport?.parsed_json?.innings?.length || !players.length || !teams.length) return lookup;

    const teamNameToId = new Map(teams.map((team) => [team.team_name.trim().toLowerCase(), team.id]));
    const playerNameToId = new Map(players.map((player) => [`${player.team_id}:${player.player_name.trim().toLowerCase()}`, player.id]));

    matchImport.parsed_json.innings.forEach((inning) => {
      const teamId = teamNameToId.get(inning.team_name.trim().toLowerCase());
      if (!teamId) return;
      inning.batting.forEach((battingRow) => {
        const dismissal = battingRow.dismissal?.trim();
        if (!dismissal) return;
        const playerId = playerNameToId.get(`${teamId}:${battingRow.player_name.trim().toLowerCase()}`);
        if (playerId && !lookup.has(playerId)) {
          lookup.set(playerId, dismissal);
        }
      });
    });

    return lookup;
  }, [matchImport, players, teams]);

  const teamA = match ? teamById.get(match.team_a_id) : undefined;
  const teamB = match ? teamById.get(match.team_b_id) : undefined;
  const venue = match ? venueById.get(match.venue_id) : undefined;
  const teamATheme = getTeamTheme(teamA?.team_name);
  const teamBTheme = getTeamTheme(teamB?.team_name);
  const homeTheme = teamATheme ?? teamBTheme;

  const innings = useMemo(() => {
    if (!match) return [];
    const firstBattingTeamId = match.bat_first_team_id || match.team_a_id;
    const secondBattingTeamId = firstBattingTeamId === match.team_a_id ? match.team_b_id : match.team_a_id;

    const buildInnings = (
      label: string,
      battingTeamId: string,
      score: number | null | undefined,
      wickets: number | null | undefined,
      overs: number | null | undefined,
    ) => {
      const team = teamById.get(battingTeamId);
      const rows = stats
        .filter((row) => row.team_id === battingTeamId)
        .map((row) => ({
          ...row,
          player_name: playerById.get(row.player_id)?.player_name || row.player_id,
          team_name: team?.team_name || row.team_id,
        }))
        .sort((left, right) => (left.batting_position || 99) - (right.batting_position || 99));

      return {
        label,
        team,
        battingTeamId,
        score: score ?? 0,
        wickets: wickets ?? 0,
        overs: overs ?? 0,
        batting: rows.filter((row) => (row.batting_position || 0) > 0 || row.runs > 0 || row.balls > 0),
        bowling: rows
          .filter((row) => row.overs > 0 || row.wickets > 0 || row.runs_conceded > 0)
          .sort((left, right) => right.wickets - left.wickets || Number(right.overs) - Number(left.overs)),
      };
    };

    return [
      buildInnings("First innings", firstBattingTeamId, match.first_innings_score, match.first_innings_wickets, match.first_innings_overs),
      buildInnings("Second innings", secondBattingTeamId, match.second_innings_score, match.second_innings_wickets, match.second_innings_overs),
    ];
  }, [match, playerById, stats, teamById]);

  const reportPreview = reportForMatch?.report_json || null;

  const generateReport = async () => {
    if (!matchId) return;
    setWorking(true);
    setMessage("");
    try {
      const response = await api.createReport(matchId);
      setReports((current) => {
        const next = current.filter((item) => item.id !== response.report.id);
        return [...next, response.report];
      });
      setMessage("Report generated successfully.");
    } finally {
      setWorking(false);
    }
  };

  return (
    <AppShell
      title="Match Detail"
      subtitle="Single-match review with scorecard, innings breakdown, player stats, and generated intelligence."
      actionLabel="Back to data manager"
      onAction={() => router.push(getBrowserTournamentPath("/data-manager"))}
    >
      {loading && <Loader label="Loading match detail..." />}
      {error && !loading && <ErrorState message={error} onRetry={load} />}
      {!loading && !error && !match && (
        <EmptyState
          title="Match not found"
          description="This match record does not exist yet or was deleted."
          actionLabel="Go to data manager"
          onAction={() => router.push(getBrowserTournamentPath("/data-manager"))}
        />
      )}

      {!loading && !error && match && (
        <div className="space-y-6">
          <div style={{ boxShadow: `0 0 42px ${homeTheme.glow}` }} className="rounded-3xl">
            <GlassCard className="overflow-hidden p-0">
              <div className="grid gap-6 p-6 lg:grid-cols-[1.2fr_0.8fr]" style={{ background: homeTheme.gradient }}>
                <div className="space-y-4">
                  <div className="flex flex-wrap items-center gap-2 text-xs uppercase tracking-[0.24em] text-white/80">
                    <span>{match.tournament}</span>
                    <span>•</span>
                    <span>Match {match.match_number}</span>
                    <span>•</span>
                    <span>{match.season}</span>
                  </div>
                  <h1 className="text-3xl font-semibold text-white md:text-4xl">
                    {teamA?.team_name || "Team A"} vs {teamB?.team_name || "Team B"}
                  </h1>
                  <p className="text-sm text-white/85">
                    {venue?.venue_name || "Venue not found"}
                    {venue?.city ? ` • ${venue.city}` : ""}
                    {match.match_date ? ` • ${match.match_date}` : ""}
                  </p>
                  <div className="flex flex-wrap gap-3">
                    <NeonButton className="bg-white/10" onClick={generateReport} loading={working}>
                      Generate report
                    </NeonButton>
                    <NeonButton className="bg-white/10" onClick={() => router.push(getBrowserTournamentPath("/reports"))}>
                      Open reports
                    </NeonButton>
                    <NeonButton className="bg-white/10" onClick={() => router.push(getBrowserTournamentPath("/data-manager"))}>
                      Back to matches
                    </NeonButton>
                  </div>
                  {message && <p className="text-sm font-medium text-emerald-100">{message}</p>}
                </div>

                <div className="grid gap-3">
                  <StatPill label="Result" value={formatResult(match)} />
                  <StatPill label="Toss" value={formatToss(match, teamById)} />
                  <StatPill
                    label="Player of match"
                    value={playerById.get(match.player_of_match_id || "")?.player_name || "Not set"}
                  />
                  <StatPill label="Margin" value={formatMargin(match)} />
                </div>
              </div>
            </GlassCard>
          </div>

          <div className="grid gap-4 lg:grid-cols-2">
            <GlassCard>
              <h2 className="text-lg font-semibold text-white">Match summary</h2>
              <div className="mt-4 grid gap-3 md:grid-cols-2">
                <SummaryField label="Bat first" value={teamById.get(match.bat_first_team_id || "")?.team_name || "Not set"} />
                <SummaryField label="Bowl first" value={teamById.get(match.bowl_first_team_id || "")?.team_name || "Not set"} />
                <SummaryField label="Winner" value={teamById.get(match.winner_id || "")?.team_name || "Not set"} />
                <SummaryField label="Loser" value={teamById.get(match.loser_id || "")?.team_name || "Not set"} />
                <SummaryField label="First innings" value={formatScore(match.first_innings_score, match.first_innings_wickets, match.first_innings_overs)} />
                <SummaryField label="Second innings" value={formatScore(match.second_innings_score, match.second_innings_wickets, match.second_innings_overs)} />
              </div>
              {match.notes && <p className="mt-4 rounded-2xl border border-white/10 bg-slate-950/50 px-4 py-3 text-sm text-slate-300">{match.notes}</p>}
            </GlassCard>

            <GlassCard>
              <h2 className="text-lg font-semibold text-white">Win snapshot</h2>
              <div className="mt-4">
                <WinProbabilityCard
                  teamALabel={teamA?.team_name || "Team A"}
                  teamAValue={match.team_a_id === match.winner_id ? 68 : 44}
                  teamBLabel={teamB?.team_name || "Team B"}
                  teamBValue={match.team_b_id === match.winner_id ? 68 : 44}
                  theme={{
                    ringGradient: homeTheme.ringGradient,
                    primary: homeTheme.primary,
                    accent: homeTheme.accent,
                  }}
                />
              </div>
            </GlassCard>
          </div>

          <div className="grid gap-4">
            {innings.map((inning) => (
              <GlassCard key={inning.label}>
                <div className="flex flex-wrap items-center justify-between gap-3">
                  <div>
                    <p className="text-xs uppercase tracking-[0.24em] text-cyan-200/70">{inning.label}</p>
                    <h3 className="mt-1 text-2xl font-semibold text-white">{inning.team?.team_name || "Unknown team"}</h3>
                  </div>
                  <div className="text-right">
                    <p className="text-3xl font-semibold text-white">
                      {inning.score}/{inning.wickets}
                    </p>
                    <p className="text-sm text-slate-400">{inning.overs} ov</p>
                  </div>
                </div>

                <div className="mt-6 grid gap-4 xl:grid-cols-2">
                  <div>
                    <h4 className="text-sm uppercase tracking-[0.24em] text-slate-400">Batting card</h4>
                    <div className="mt-3 overflow-x-auto rounded-3xl border border-white/10">
                      <table className="min-w-full text-left text-sm">
                        <thead className="bg-white/5 text-slate-300">
                          <tr>
                            <th className="px-3 py-2">Batter</th>
                            <th className="px-3 py-2">Dismissal</th>
                            <th className="px-3 py-2">R</th>
                            <th className="px-3 py-2">B</th>
                            <th className="px-3 py-2">4s</th>
                            <th className="px-3 py-2">6s</th>
                            <th className="px-3 py-2">SR</th>
                          </tr>
                        </thead>
                        <tbody>
                          {inning.batting.length > 0 ? (
                            inning.batting.map((row) => (
                              <tr key={row.id} className="border-t border-white/10">
                                <td className="px-3 py-2 text-white">{row.player_name}</td>
                                <td className="px-3 py-2 text-slate-300">{row.dismissal || dismissalByPlayerId.get(row.player_id) || "—"}</td>
                                <td className="px-3 py-2 text-slate-300">{row.runs}</td>
                                <td className="px-3 py-2 text-slate-300">{row.balls}</td>
                                <td className="px-3 py-2 text-slate-300">{row.fours}</td>
                                <td className="px-3 py-2 text-slate-300">{row.sixes}</td>
                                <td className="px-3 py-2 text-slate-300">{formatNumber(row.strike_rate)}</td>
                              </tr>
                            ))
                          ) : (
                            <tr>
                              <td className="px-3 py-4 text-slate-400" colSpan={7}>
                                No batting rows available.
                              </td>
                            </tr>
                          )}
                        </tbody>
                      </table>
                    </div>
                  </div>

                  <div>
                    <h4 className="text-sm uppercase tracking-[0.24em] text-slate-400">Bowling card</h4>
                    <div className="mt-3 overflow-x-auto rounded-3xl border border-white/10">
                      <table className="min-w-full text-left text-sm">
                        <thead className="bg-white/5 text-slate-300">
                          <tr>
                            <th className="px-3 py-2">Bowler</th>
                            <th className="px-3 py-2">O</th>
                            <th className="px-3 py-2">M</th>
                            <th className="px-3 py-2">R</th>
                            <th className="px-3 py-2">W</th>
                            <th className="px-3 py-2">Dots</th>
                            <th className="px-3 py-2">Econ</th>
                          </tr>
                        </thead>
                        <tbody>
                          {inning.bowling.length > 0 ? (
                            inning.bowling.map((row) => (
                              <tr key={row.id} className="border-t border-white/10">
                                <td className="px-3 py-2 text-white">{row.player_name}</td>
                                <td className="px-3 py-2 text-slate-300">{formatNumber(row.overs)}</td>
                                <td className="px-3 py-2 text-slate-300">{row.maidens}</td>
                                <td className="px-3 py-2 text-slate-300">{row.runs_conceded}</td>
                                <td className="px-3 py-2 text-slate-300">{row.wickets}</td>
                                <td className="px-3 py-2 text-slate-300">{row.dot_balls}</td>
                                <td className="px-3 py-2 text-slate-300">{formatNumber(row.economy)}</td>
                              </tr>
                            ))
                          ) : (
                            <tr>
                              <td className="px-3 py-4 text-slate-400" colSpan={7}>
                                No bowling rows available.
                              </td>
                            </tr>
                          )}
                        </tbody>
                      </table>
                    </div>
                  </div>
                </div>
              </GlassCard>
            ))}
          </div>

          <div className="grid gap-4 xl:grid-cols-[1.2fr_0.8fr]">
            <GlassCard>
              <h2 className="flex items-center gap-2 text-lg font-semibold text-white">
                <ChartColumnBig className="h-5 w-5 text-cyan-200" />
                Scorecard review
              </h2>
              <p className="mt-2 text-sm text-slate-400">
                This page shows the saved innings totals, player scorecard rows, and the derived match outcome for a single fixture.
              </p>
              <div className="mt-4 space-y-3">
                {stats.length === 0 ? (
                  <EmptyState
                    title="No player stats"
                    description="This match does not have player-level stats yet."
                    actionLabel="Edit match"
                    onAction={() => router.push(getBrowserTournamentPath("/add-match"))}
                  />
                ) : (
                  stats
                    .slice()
                    .sort((left, right) => {
                      const leftTeamPriority = left.team_id === match.team_a_id ? 0 : 1;
                      const rightTeamPriority = right.team_id === match.team_a_id ? 0 : 1;
                      return leftTeamPriority - rightTeamPriority;
                    })
                    .map((row) => (
                      <div key={row.id} className="rounded-2xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-slate-300">
                        <div className="flex flex-wrap items-center justify-between gap-2">
                          <span className="font-medium text-white">{playerById.get(row.player_id)?.player_name || row.player_id}</span>
                          <span className="text-xs uppercase tracking-[0.22em] text-cyan-200/70">{teamById.get(row.team_id)?.team_name || row.team_id}</span>
                        </div>
                        <p className="mt-2">
                          Batting: {row.runs} runs off {row.balls} balls, {row.fours}x4, {row.sixes}x6, SR {formatNumber(row.strike_rate)}
                          {" "}• Dismissal: {row.dismissal || dismissalByPlayerId.get(row.player_id) || "—"}
                        </p>
                        <p>
                          Bowling: {row.overs} ov, {row.runs_conceded} runs, {row.wickets} wickets, econ {formatNumber(row.economy)}
                        </p>
                      </div>
                    ))
                )}
              </div>
            </GlassCard>

            <GlassCard>
              <h2 className="flex items-center gap-2 text-lg font-semibold text-white">
                <FileText className="h-5 w-5 text-violet-200" />
                Match report
              </h2>
              <p className="mt-2 text-sm text-slate-400">
                Generate a report for a structured intelligence summary, then review it alongside the match card.
              </p>
              <div className="mt-4 space-y-3">
                {reportPreview ? (
                  Object.entries(reportPreview).map(([key, value]) => (
                    <div key={key} className="rounded-2xl border border-white/10 bg-slate-950/50 px-4 py-3">
                      <p className="text-xs uppercase tracking-[0.22em] text-cyan-200/70">{key.replaceAll("_", " ")}</p>
                      <p className="mt-1 text-sm text-slate-200">{typeof value === "string" ? value : JSON.stringify(value, null, 2)}</p>
                    </div>
                  ))
                ) : (
                  <EmptyState
                    title="No report yet"
                    description="Generate the report to view summary insights here."
                    actionLabel="Generate report"
                    onAction={generateReport}
                  />
                )}
              </div>
            </GlassCard>
          </div>
        </div>
      )}
    </AppShell>
  );
}

function formatNumber(value: number | null | undefined) {
  if (value === null || value === undefined) return "—";
  return Number.isInteger(value) ? String(value) : Number(value).toFixed(2).replace(/\.00$/, "");
}

function formatScore(score?: number | null, wickets?: number | null, overs?: number | null) {
  return `${score ?? 0}/${wickets ?? 0} (${formatNumber(overs)} ov)`;
}

function formatMargin(match: MatchRecord) {
  if (match.result_type === "runs") return `${match.margin_runs ?? 0} runs`;
  if (match.result_type === "wickets") return `${match.margin_wickets ?? 0} wickets`;
  return "—";
}

function formatResult(match: MatchRecord) {
  const winner = match.winner_id ? "Winner recorded" : "Result pending";
  return `${winner} • ${match.result_type || "unclassified"}`;
}

function formatToss(match: MatchRecord, teamById: Map<string, Team>) {
  const tossWinner = match.toss_winner_id ? teamById.get(match.toss_winner_id)?.team_name || "Unknown" : "Not set";
  return `${tossWinner} • ${match.toss_decision || "—"}`;
}

function StatPill({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-3xl border border-white/10 bg-white/5 p-4">
      <p className="text-xs uppercase tracking-[0.24em] text-slate-400">{label}</p>
      <p className="mt-2 text-lg font-semibold text-white">{value}</p>
    </div>
  );
}

function SummaryField({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-2xl border border-white/10 bg-slate-950/50 px-4 py-3">
      <p className="text-xs uppercase tracking-[0.24em] text-slate-400">{label}</p>
      <p className="mt-1 text-sm font-medium text-white">{value}</p>
    </div>
  );
}
