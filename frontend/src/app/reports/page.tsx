"use client";

import { useEffect, useMemo, useState } from "react";
import { api } from "@/lib/api";
import { AppShell } from "@/components/layout/AppShell";
import { GlassCard } from "@/components/ui/GlassCard";
import { Loader } from "@/components/ui/Loader";
import { ErrorState } from "@/components/ui/ErrorState";
import { EmptyState } from "@/components/ui/EmptyState";
import { NeonButton } from "@/components/ui/NeonButton";
import type {
  MatchRecord,
  Player,
  PlayerPerformanceReportResponse,
  PlayerPerformanceRow,
  Team,
  Venue,
} from "@/types/cricket";

export default function ReportsPage() {
  const [matches, setMatches] = useState<MatchRecord[]>([]);
  const [teams, setTeams] = useState<Team[]>([]);
  const [venues, setVenues] = useState<Venue[]>([]);
  const [players, setPlayers] = useState<Player[]>([]);
  const [selectedMatchId, setSelectedMatchId] = useState("");
  const [selectedVenueId, setSelectedVenueId] = useState("");
  const [useVenueFilter, setUseVenueFilter] = useState(true);
  const [useTeamFilter, setUseTeamFilter] = useState(false);
  const [selectedTeamIds, setSelectedTeamIds] = useState<string[]>([]);
  const [reportMode, setReportMode] = useState<"batting" | "bowling">("bowling");
  const [selectedStyle, setSelectedStyle] = useState("");
  const [bowlingFamily, setBowlingFamily] = useState("All");
  const [bowlingFastStyle, setBowlingFastStyle] = useState("");
  const [bowlingSpinnerGroup, setBowlingSpinnerGroup] = useState("");
  const [matchReport, setMatchReport] = useState<any>(null);
  const [performanceReport, setPerformanceReport] = useState<PlayerPerformanceReportResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [matchWorking, setMatchWorking] = useState(false);
  const [performanceWorking, setPerformanceWorking] = useState(false);
  const [matchExportingFormat, setMatchExportingFormat] = useState<"csv" | "pdf" | null>(null);
  const [performanceExportingFormat, setPerformanceExportingFormat] = useState<"csv" | "pdf" | null>(null);
  const [error, setError] = useState("");
  const [performanceError, setPerformanceError] = useState("");

  const load = async () => {
    setLoading(true);
    setError("");
    try {
      const [matchList, teamList, venueList, playerList] = await Promise.all([
        api.getMatches(),
        api.getTeams(),
        api.getVenues(),
        api.getPlayers(),
      ]);
      setMatches(matchList);
      setTeams(teamList);
      setVenues(venueList);
      setPlayers(playerList);
      setSelectedMatchId((current) => current || matchList[0]?.id || "");
      setSelectedTeamIds((current) => current.length ? current : teamList.map((team) => team.id));
      setSelectedVenueId((current) => current || venueList.find((venue) => venue.venue_name === "Holkar Stadium")?.id || venueList[0]?.id || "");
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
  const selectedTeams = useMemo(
    () => teams.filter((team) => selectedTeamIds.includes(team.id)),
    [selectedTeamIds, teams],
  );
  const selectedVenue = useMemo(() => venues.find((venue) => venue.id === selectedVenueId), [venues, selectedVenueId]);
  const allTeamIds = useMemo(() => teams.map((team) => team.id), [teams]);
  const selectedTeamNames = useMemo(
    () => selectedTeams.map((team) => team.team_name),
    [selectedTeams],
  );

  const toggleTeam = (teamId: string) => {
    setSelectedTeamIds((current) =>
      current.includes(teamId) ? current.filter((id) => id !== teamId) : [...current, teamId],
    );
  };

  const selectAllTeams = () => setSelectedTeamIds(allTeamIds);
  const clearTeamSelection = () => setSelectedTeamIds([]);

  const battingStyles = useMemo(
    () =>
      Array.from(
        new Set(
          players
            .map((player) => player.batting_style?.trim())
            .filter((style): style is string => Boolean(style)),
        ),
      ).sort((a, b) => a.localeCompare(b)),
    [players],
  );

  const battingStyleOptions = useMemo(
    () => [{ label: "All batting styles", value: "All" }, ...battingStyles.map((style) => ({ label: style, value: style }))],
    [battingStyles],
  );

  const bowlingStyleOptions = useMemo(
    () => [
      { label: "All bowlers", value: "All" },
      { label: "Fast bowler", value: "Fast bowler" },
      { label: "Spinners", value: "Spinners" },
      { label: "Others", value: "Others" },
    ],
    [],
  );

  const fastBowlerStyleOptions = useMemo(
    () => [
      { label: "All fast bowlers", value: "" },
      { label: "LAMF", value: "LAMF" },
      { label: "RAMF", value: "RAMF" },
    ],
    [],
  );

  const spinnerGroupOptions = useMemo(
    () => [
      { label: "All spinners", value: "" },
      { label: "CM", value: "CM" },
      { label: "Right arm off spin", value: "Right arm off spin" },
      { label: "Right arm leg spin", value: "Right arm leg spin" },
      { label: "Left arm spin", value: "Left arm spin" },
    ],
    [],
  );

  const oversToBalls = (overs: number) => {
    const wholeOvers = Math.trunc(overs || 0);
    const fractionalBalls = Math.round((((overs || 0) - wholeOvers) * 10));
    const carry = Math.floor(Math.max(0, fractionalBalls) / 6);
    const balls = Math.max(0, fractionalBalls) % 6;
    return ((wholeOvers + carry) * 6) + balls;
  };

  const ballsToOvers = (balls: number) => {
    const wholeOvers = Math.floor((balls || 0) / 6);
    const remainingBalls = Math.max(0, balls || 0) % 6;
    return Number(`${wholeOvers}.${remainingBalls}`);
  };

  const selectedBowlingStyle = useMemo(() => {
    if (bowlingFamily === "Fast bowler") {
      return bowlingFastStyle || "Fast bowler";
    }
    if (bowlingFamily === "Spinners") {
      return bowlingSpinnerGroup || "Spinners";
    }
    return bowlingFamily;
  }, [bowlingFamily, bowlingFastStyle, bowlingSpinnerGroup]);

  const normalizedPerformanceReport = useMemo(() => {
    if (!performanceReport) return null;

    const matchIdsByTeam = new Map<string, Set<string>>();
    const oversBallsByTeam = new Map<string, number>();
    const reportVenueId = performanceReport.filters.use_venue_filter ? performanceReport.filters.venue_id ?? null : null;
    const reportTeamIds = performanceReport.filters.team_ids ?? [];
    const exactVenueMatchCount = reportVenueId
      ? matches.filter((match) => match.venue_id === reportVenueId).length
      : null;
    const exactTeamMatchCount = reportTeamIds.length
      ? matches.filter((match) => {
          const isSelectedTeam = reportTeamIds.includes(match.team_a_id) || reportTeamIds.includes(match.team_b_id);
          return reportVenueId ? isSelectedTeam && match.venue_id === reportVenueId : isSelectedTeam;
        }).length
      : null;
    const rowMatchIds = new Set(
      performanceReport.rows.flatMap((row) => row.match_ids?.map((matchId) => String(matchId).trim()).filter(Boolean) ?? []),
    );
    const rowMatchCount = rowMatchIds.size;
    const backendOverallMatchCount = performanceReport.overall_total?.matches_played ?? null;
    const exactReportMatchCount = reportTeamIds.length
      ? (exactTeamMatchCount ?? rowMatchCount ?? backendOverallMatchCount)
      : (exactVenueMatchCount ?? backendOverallMatchCount);

    const collectMatchIds = (row: PlayerPerformanceRow) => {
      const ids = row.match_ids?.map((matchId) => String(matchId).trim()).filter(Boolean) ?? [];
      if (ids.length > 0) {
        return ids;
      }
      return [];
    };

    performanceReport.rows.forEach((row) => {
      const key = row.team_id || row.team_name;
      if (!key) return;
      const teamMatchIds = matchIdsByTeam.get(key) ?? new Set<string>();
      collectMatchIds(row).forEach((matchId) => {
        teamMatchIds.add(matchId);
      });
      matchIdsByTeam.set(key, teamMatchIds);

      if (performanceReport.filters.mode === "bowling") {
        const teamBalls = oversBallsByTeam.get(key) ?? 0;
        oversBallsByTeam.set(key, teamBalls + (row.overs_balls ?? oversToBalls(row.overs)));
      }
    });

    return {
      ...performanceReport,
      team_totals: (performanceReport.team_totals ?? []).map((total) => {
        const key = String(total.team_id ?? total.team_name ?? total.label);
        const uniqueMatches = matchIdsByTeam.get(key);
        const exactVenueTeamMatchCount =
          reportVenueId && total.team_id
            ? matches.filter(
                (match) =>
                  match.venue_id === reportVenueId &&
                  (match.team_a_id === total.team_id || match.team_b_id === total.team_id),
              ).length
            : null;
        if (performanceReport.filters.mode === "bowling") {
          const totalBalls = oversBallsByTeam.get(key) ?? total.overs_balls ?? oversToBalls(total.overs);
          return {
            ...total,
            matches_played: exactVenueTeamMatchCount ?? uniqueMatches?.size ?? total.matches_played,
            overs_balls: totalBalls,
            overs: ballsToOvers(totalBalls),
          };
        }
        return {
          ...total,
          matches_played: exactVenueTeamMatchCount ?? uniqueMatches?.size ?? total.matches_played,
        };
      }),
      overall_total: performanceReport.overall_total
        ? {
            ...performanceReport.overall_total,
            matches_played: exactReportMatchCount ?? performanceReport.overall_total.matches_played,
            ...(performanceReport.filters.mode === "bowling"
              ? (() => {
                  const totalBalls = (performanceReport.rows ?? []).reduce(
                    (sum, row) => sum + (row.overs_balls ?? oversToBalls(row.overs)),
                    0,
                  );
                  return {
                    overs_balls: totalBalls,
                    overs: ballsToOvers(totalBalls),
                  };
                })()
              : {}),
          }
        : null,
    };
  }, [matches, performanceReport]);
  const performanceTeamTotals = normalizedPerformanceReport?.team_totals ?? [];
  const performanceOverallTotal = normalizedPerformanceReport?.overall_total ?? null;

  useEffect(() => {
    if (reportMode === "batting" && battingStyleOptions.length > 0 && !battingStyleOptions.some((option) => option.value === selectedStyle)) {
      setSelectedStyle(battingStyleOptions[0].value);
    }
  }, [battingStyleOptions, reportMode, selectedStyle]);

  const createMatchReport = async () => {
    if (!selectedMatchId) return;
    setMatchWorking(true);
    try {
      const response = await api.createReport(selectedMatchId);
      setMatchReport(response.report || response);
    } finally {
      setMatchWorking(false);
    }
  };

  const createPerformanceReport = async () => {
    const effectiveStyle = reportMode === "batting" ? selectedStyle : selectedBowlingStyle;
    if (!effectiveStyle) return;
    if (useVenueFilter && !selectedVenueId) {
      setPerformanceError("Please choose a venue before generating a venue-filtered report.");
      return;
    }
    if (useTeamFilter && selectedTeamIds.length === 0) {
      setPerformanceError("Please choose at least one team when team filtering is enabled.");
      return;
    }
    setPerformanceWorking(true);
    setPerformanceError("");
    try {
      const response = await api.createPlayerPerformanceReport({
        use_venue_filter: useVenueFilter,
        venue_id: useVenueFilter ? selectedVenueId : null,
        mode: reportMode,
        style: effectiveStyle,
        team_ids: useTeamFilter ? selectedTeamIds : null,
      });
      setPerformanceReport(response);
    } catch (err) {
      setPerformanceError(err instanceof Error ? err.message : "Could not generate performance report.");
    } finally {
      setPerformanceWorking(false);
    }
  };

  const downloadBlob = (blob: Blob, filename: string) => {
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = filename;
    link.click();
    URL.revokeObjectURL(url);
  };

  const toFilename = (title: string, format: "csv" | "pdf") =>
    `${title
      .trim()
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-+|-+$/g, "") || "report"}.${format}`;

  const exportMatchReport = async (format: "csv" | "pdf") => {
    if (!matchReport) return;
    setMatchExportingFormat(format);
    try {
      const blob = await api.exportReport({
        report_kind: "match",
        format,
        match_report: matchReport,
      });
      const title = (matchReport?.report_title as string) || "match-report";
      downloadBlob(blob, toFilename(title, format));
    } finally {
      setMatchExportingFormat(null);
    }
  };

  const exportPerformanceReport = async (format: "csv" | "pdf") => {
    if (!normalizedPerformanceReport) return;
    setPerformanceExportingFormat(format);
    try {
      const blob = await api.exportReport({
        report_kind: "player_performance",
        format,
        performance_report: normalizedPerformanceReport,
      });
      downloadBlob(blob, toFilename(normalizedPerformanceReport.report_title, format));
    } finally {
      setPerformanceExportingFormat(null);
    }
  };

  return (
    <AppShell
      title="Report Generator"
      subtitle="Generate match intelligence and custom player performance reports with real team, venue, and player names."
      actionLabel="Generate match report"
      onAction={createMatchReport}
    >
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
              <NeonButton loading={matchWorking} onClick={createMatchReport}>
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

          <GlassCard>
            <div className="grid gap-4 lg:grid-cols-[1fr_1fr_auto] lg:items-end">
              <label className="block">
                <span className="mb-2 block text-xs uppercase tracking-[0.24em] text-slate-400">Use venue filter</span>
                <button
                  type="button"
                  onClick={() => setUseVenueFilter((current) => !current)}
                  className={`w-full rounded-2xl border px-4 py-3 text-left text-sm font-semibold transition ${
                    useVenueFilter
                      ? "border-cyan-300/40 bg-cyan-300/10 text-cyan-100"
                      : "border-white/10 bg-white/5 text-slate-300"
                  }`}
                >
                  {useVenueFilter ? "Yes, filter by venue" : "No, use all venues"}
                </button>
              </label>

              <label className="block">
                <span className="mb-2 block text-xs uppercase tracking-[0.24em] text-slate-400">Venue</span>
                <select
                  value={selectedVenueId}
                  onChange={(event) => setSelectedVenueId(event.target.value)}
                  disabled={!useVenueFilter}
                  className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none disabled:cursor-not-allowed disabled:opacity-50 focus:border-cyan-300/50"
                >
                  {venues.map((venue) => (
                    <option key={venue.id} value={venue.id}>
                      {venue.venue_name}
                    </option>
                  ))}
                </select>
              </label>

              <label className="block">
                <span className="mb-2 block text-xs uppercase tracking-[0.24em] text-slate-400">Mode</span>
                <div className="grid grid-cols-2 gap-2">
                  <button
                    type="button"
                    onClick={() => setReportMode("batting")}
                    className={`rounded-2xl border px-4 py-3 text-sm font-semibold transition ${
                      reportMode === "batting"
                        ? "border-cyan-300/40 bg-cyan-300/10 text-cyan-100"
                        : "border-white/10 bg-white/5 text-slate-300"
                    }`}
                  >
                    Batting
                  </button>
                  <button
                    type="button"
                    onClick={() => setReportMode("bowling")}
                    className={`rounded-2xl border px-4 py-3 text-sm font-semibold transition ${
                      reportMode === "bowling"
                        ? "border-cyan-300/40 bg-cyan-300/10 text-cyan-100"
                        : "border-white/10 bg-white/5 text-slate-300"
                    }`}
                  >
                    Bowling
                  </button>
                </div>
              </label>
            </div>

            <div className="mt-4 grid gap-4 md:grid-cols-[1fr_auto] md:items-end">
              <label className="block">
                <span className="mb-2 block text-xs uppercase tracking-[0.24em] text-slate-400">
                  {reportMode === "batting" ? "Batting style" : "Bowling style"}
                </span>
                {reportMode === "batting" ? (
                  <select
                    value={selectedStyle}
                    onChange={(event) => setSelectedStyle(event.target.value)}
                    className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-cyan-300/50"
                  >
                    {battingStyleOptions.map((style) => (
                      <option key={style.value} value={style.value}>
                        {style.label}
                      </option>
                    ))}
                  </select>
                ) : (
                  <div className="space-y-3">
                    <select
                      value={bowlingFamily}
                      onChange={(event) => {
                        const nextFamily = event.target.value;
                        setBowlingFamily(nextFamily);
                        setBowlingFastStyle("");
                        setBowlingSpinnerGroup("");
                      }}
                      className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-cyan-300/50"
                    >
                      {bowlingStyleOptions.map((style) => (
                        <option key={style.value} value={style.value}>
                          {style.label}
                        </option>
                      ))}
                    </select>

                    {bowlingFamily === "Fast bowler" && (
                      <select
                        value={bowlingFastStyle}
                        onChange={(event) => setBowlingFastStyle(event.target.value)}
                        className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-cyan-300/50"
                      >
                        {fastBowlerStyleOptions.map((style) => (
                          <option key={style.label} value={style.value}>
                            {style.label}
                          </option>
                        ))}
                      </select>
                    )}

                    {bowlingFamily === "Spinners" && (
                      <select
                        value={bowlingSpinnerGroup}
                        onChange={(event) => setBowlingSpinnerGroup(event.target.value)}
                        className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-cyan-300/50"
                      >
                        {spinnerGroupOptions.map((style) => (
                          <option key={style.label} value={style.value}>
                            {style.label}
                          </option>
                        ))}
                      </select>
                    )}
                  </div>
                )}
              </label>
              <NeonButton loading={performanceWorking} onClick={createPerformanceReport}>
                Generate performance report
              </NeonButton>
            </div>

            <div className="mt-4 rounded-3xl border border-white/10 bg-white/5 p-4">
              <div className="flex flex-wrap items-center justify-between gap-3">
                <div>
                  <span className="mb-2 block text-xs uppercase tracking-[0.24em] text-slate-400">Team filter</span>
                  <p className="text-sm text-slate-300">
                    {useTeamFilter
                      ? "Choose specific teams or include all teams in the report."
                      : "Team filtering is off. All teams will be included."}
                  </p>
                </div>
                <button
                  type="button"
                  onClick={() => setUseTeamFilter((current) => !current)}
                  className={`rounded-2xl border px-4 py-3 text-sm font-semibold transition ${
                    useTeamFilter
                      ? "border-cyan-300/40 bg-cyan-300/10 text-cyan-100"
                      : "border-white/10 bg-white/5 text-slate-300"
                  }`}
                >
                  {useTeamFilter ? "Selected teams" : "All teams"}
                </button>
              </div>

              {useTeamFilter && (
                <div className="mt-4 space-y-3">
                  <div className="flex flex-wrap gap-2">
                    <button
                      type="button"
                      onClick={selectAllTeams}
                      className="rounded-full border border-white/10 bg-white/5 px-3 py-1.5 text-xs font-semibold text-slate-200 transition hover:border-cyan-300/30 hover:text-white"
                    >
                      Select all
                    </button>
                    <button
                      type="button"
                      onClick={clearTeamSelection}
                      className="rounded-full border border-white/10 bg-white/5 px-3 py-1.5 text-xs font-semibold text-slate-200 transition hover:border-cyan-300/30 hover:text-white"
                    >
                      Clear
                    </button>
                    <span className="px-1 py-1.5 text-xs uppercase tracking-[0.24em] text-slate-400">
                      {selectedTeamIds.length} selected
                    </span>
                  </div>
                  <div className="grid gap-2 sm:grid-cols-2 xl:grid-cols-3">
                    {teams.map((team) => {
                      const checked = selectedTeamIds.includes(team.id);
                      return (
                        <button
                          key={team.id}
                          type="button"
                          onClick={() => toggleTeam(team.id)}
                          className={`flex items-center justify-between rounded-2xl border px-4 py-3 text-left text-sm font-semibold transition ${
                            checked
                              ? "border-cyan-300/40 bg-cyan-300/10 text-cyan-100"
                              : "border-white/10 bg-slate-950/60 text-slate-300"
                          }`}
                        >
                          <span className="pr-3">{team.team_name}</span>
                          <span className="text-xs uppercase tracking-[0.24em] text-slate-400">{checked ? "On" : "Off"}</span>
                        </button>
                      );
                    })}
                  </div>
                  {selectedTeamNames.length > 0 && (
                    <p className="text-xs uppercase tracking-[0.24em] text-slate-400">
                      Selected teams: {selectedTeamNames.join(", ")}
                    </p>
                  )}
                </div>
              )}
            </div>

            <p className="mt-4 text-sm text-slate-400">
              {useVenueFilter && selectedVenue
                ? `Filtering by ${selectedVenue.venue_name}.`
                : "Showing all venues."}{" "}
              {reportMode === "batting"
                ? "Batting styles are pulled from the canonical player records. Use All batting styles to include everyone."
                : "Bowling players can be filtered by family first, then by fast-bowler or spinner sub-categories. Use All bowlers to include everyone."}
              {useTeamFilter && selectedTeamNames.length > 0
                ? ` Teams: ${selectedTeamNames.join(", ")}.`
                : " All teams are included."}
            </p>
            {performanceError && (
              <p className="mt-3 rounded-2xl border border-rose-400/30 bg-rose-400/10 px-4 py-3 text-sm text-rose-100">
                {performanceError}
              </p>
            )}
          </GlassCard>

          <div className="grid gap-4 xl:grid-cols-2">
            <GlassCard>
              <div className="flex flex-wrap items-center justify-between gap-3">
                <h3 className="text-lg font-semibold text-white">Match report preview</h3>
                <div className="flex flex-wrap gap-2">
                  <NeonButton loading={matchExportingFormat === "csv"} disabled={!matchReport} onClick={() => exportMatchReport("csv")}>
                    Export CSV
                  </NeonButton>
                  <NeonButton loading={matchExportingFormat === "pdf"} disabled={!matchReport} onClick={() => exportMatchReport("pdf")}>
                    Export PDF
                  </NeonButton>
                </div>
              </div>
              <div className="mt-4 space-y-3 text-sm text-slate-300">
                {matchReport ? (
                  Object.entries(matchReport.report_json || matchReport).map(([key, value]) => (
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
              <div className="flex flex-wrap items-center justify-between gap-3">
                <h3 className="text-lg font-semibold text-white">
                  {performanceReport ? performanceReport.report_title : "Performance report preview"}
                </h3>
                <div className="flex flex-wrap gap-2">
                  <NeonButton
                    loading={performanceExportingFormat === "csv"}
                    disabled={!performanceReport}
                    onClick={() => exportPerformanceReport("csv")}
                  >
                    Export CSV
                  </NeonButton>
                  <NeonButton
                    loading={performanceExportingFormat === "pdf"}
                    disabled={!performanceReport}
                    onClick={() => exportPerformanceReport("pdf")}
                  >
                    Export PDF
                  </NeonButton>
                </div>
              </div>
              {performanceReport ? (
                <div className="mt-4 space-y-4">
                  <div className="space-y-2 text-sm text-slate-300">
                    {performanceReport.summary.map((line) => (
                      <p key={line} className="rounded-2xl border border-white/10 bg-white/5 px-4 py-3">
                        {line}
                      </p>
                    ))}
                  </div>
                  <div className="overflow-x-auto rounded-3xl border border-white/10">
                    <table className="min-w-full divide-y divide-white/10 text-left text-sm">
                      <thead className="bg-white/5 text-xs uppercase tracking-[0.2em] text-slate-400">
                        <tr>
                          <th className="px-4 py-3">Player</th>
                          <th className="px-4 py-3">Team</th>
                          <th className="px-4 py-3">Style</th>
                          <th className="px-4 py-3">Matches</th>
                          {performanceReport.filters.mode === "bowling" ? (
                            <>
                              <th className="px-4 py-3">Overs</th>
                              <th className="px-4 py-3">Dots</th>
                              <th className="px-4 py-3">Wkts</th>
                              <th className="px-4 py-3">Eco</th>
                              <th className="px-4 py-3">Runs</th>
                            </>
                          ) : (
                            <>
                              <th className="px-4 py-3">Runs</th>
                              <th className="px-4 py-3">Balls</th>
                              <th className="px-4 py-3">4s</th>
                              <th className="px-4 py-3">6s</th>
                              <th className="px-4 py-3">SR</th>
                            </>
                          )}
                          <th className="px-4 py-3">Best match</th>
                          <th className="px-4 py-3">Best score</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-white/10">
                        {performanceReport.rows.map((row) => (
                          <tr key={row.player_id} className="align-top">
                            <td className="px-4 py-3 text-white">{row.player_name}</td>
                            <td className="px-4 py-3 text-slate-300">{row.team_name}</td>
                            <td className="px-4 py-3 text-slate-300">
                              {performanceReport.filters.mode === "bowling"
                                ? row.bowling_style_code ?? "OTHERS"
                                : row.batting_style ?? "Unknown"}
                            </td>
                            <td className="px-4 py-3 text-slate-300">{row.matches_played}</td>
                            {performanceReport.filters.mode === "bowling" ? (
                              <>
                                <td className="px-4 py-3 text-slate-300">{row.overs.toFixed(1)}</td>
                                <td className="px-4 py-3 text-slate-300">{row.dot_balls}</td>
                                <td className="px-4 py-3 text-slate-300">{row.wickets}</td>
                                <td className="px-4 py-3 text-slate-300">{row.economy.toFixed(2)}</td>
                                <td className="px-4 py-3 text-slate-300">{row.runs_conceded}</td>
                              </>
                            ) : (
                              <>
                                <td className="px-4 py-3 text-slate-300">{row.runs}</td>
                                <td className="px-4 py-3 text-slate-300">{row.balls}</td>
                                <td className="px-4 py-3 text-slate-300">{row.fours}</td>
                                <td className="px-4 py-3 text-slate-300">{row.sixes}</td>
                                <td className="px-4 py-3 text-slate-300">{row.strike_rate.toFixed(2)}</td>
                              </>
                            )}
                            <td className="px-4 py-3 text-slate-300">
                              Match {row.best_match.match_number} vs {row.best_match.opponent_team_name} at {row.best_match.venue_name}
                            </td>
                            <td className="px-4 py-3 text-cyan-100">{row.best_score.toFixed(2)}</td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>

                  {performanceTeamTotals.length > 0 && (
                    <div className="space-y-3">
                      <h4 className="text-sm font-semibold uppercase tracking-[0.24em] text-cyan-200/80">Team totals</h4>
                      <div className="overflow-x-auto rounded-3xl border border-white/10">
                        <table className="min-w-full divide-y divide-white/10 text-left text-sm">
                          <thead className="bg-white/5 text-xs uppercase tracking-[0.2em] text-slate-400">
                            <tr>
                              <th className="px-4 py-3">Team</th>
                              <th className="px-4 py-3">Players</th>
                              <th className="px-4 py-3">Matches</th>
                              {performanceReport.filters.mode === "bowling" ? (
                                <>
                                  <th className="px-4 py-3">Overs</th>
                                  <th className="px-4 py-3">Maidens</th>
                                  <th className="px-4 py-3">Runs</th>
                                  <th className="px-4 py-3">Wkts</th>
                                  <th className="px-4 py-3">Dots</th>
                                  <th className="px-4 py-3">Eco</th>
                                </>
                              ) : (
                                <>
                                  <th className="px-4 py-3">Runs</th>
                                  <th className="px-4 py-3">Balls</th>
                                  <th className="px-4 py-3">4s</th>
                                  <th className="px-4 py-3">6s</th>
                                  <th className="px-4 py-3">SR</th>
                                </>
                              )}
                            </tr>
                          </thead>
                          <tbody className="divide-y divide-white/10">
                            {performanceTeamTotals.map((total) => (
                              <tr key={`${total.team_id ?? total.team_name}-${total.label}`} className="align-top">
                                <td className="px-4 py-3 text-white">{total.team_name ?? total.label}</td>
                                <td className="px-4 py-3 text-slate-300">{total.players_count}</td>
                                <td className="px-4 py-3 text-slate-300">{total.matches_played}</td>
                                {performanceReport.filters.mode === "bowling" ? (
                                  <>
                                    <td className="px-4 py-3 text-slate-300">{total.overs?.toFixed?.(1) ?? "0.0"}</td>
                                    <td className="px-4 py-3 text-slate-300">{total.maidens}</td>
                                    <td className="px-4 py-3 text-slate-300">{total.runs_conceded}</td>
                                    <td className="px-4 py-3 text-slate-300">{total.wickets}</td>
                                    <td className="px-4 py-3 text-slate-300">{total.dot_balls}</td>
                                    <td className="px-4 py-3 text-slate-300">{total.economy.toFixed(2)}</td>
                                  </>
                                ) : (
                                  <>
                                    <td className="px-4 py-3 text-slate-300">{total.runs}</td>
                                    <td className="px-4 py-3 text-slate-300">{total.balls}</td>
                                    <td className="px-4 py-3 text-slate-300">{total.fours}</td>
                                    <td className="px-4 py-3 text-slate-300">{total.sixes}</td>
                                    <td className="px-4 py-3 text-slate-300">{total.strike_rate.toFixed(2)}</td>
                                  </>
                                )}
                              </tr>
                            ))}
                          </tbody>
                        </table>
                      </div>
                    </div>
                  )}

                  {performanceOverallTotal && (
                    <div className="rounded-3xl border border-cyan-300/20 bg-cyan-300/5 p-4">
                      <h4 className="text-sm font-semibold uppercase tracking-[0.24em] text-cyan-100">Overall total</h4>
                      <div className="mt-3 grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
                        <div>
                          <p className="text-xs uppercase tracking-[0.24em] text-slate-400">Players</p>
                          <p className="mt-1 text-lg font-semibold text-white">{performanceOverallTotal.players_count}</p>
                        </div>
                        <div>
                          <p className="text-xs uppercase tracking-[0.24em] text-slate-400">Matches</p>
                          <p className="mt-1 text-lg font-semibold text-white">{performanceOverallTotal.matches_played}</p>
                        </div>
                        {performanceReport.filters.mode === "bowling" ? (
                          <>
                            <div>
                              <p className="text-xs uppercase tracking-[0.24em] text-slate-400">Overs</p>
                              <p className="mt-1 text-lg font-semibold text-white">{performanceOverallTotal.overs?.toFixed?.(1) ?? "0.0"}</p>
                            </div>
                            <div>
                              <p className="text-xs uppercase tracking-[0.24em] text-slate-400">Wkts</p>
                              <p className="mt-1 text-lg font-semibold text-white">{performanceOverallTotal.wickets}</p>
                            </div>
                            <div>
                              <p className="text-xs uppercase tracking-[0.24em] text-slate-400">Runs given</p>
                              <p className="mt-1 text-lg font-semibold text-white">{performanceOverallTotal.runs_conceded}</p>
                            </div>
                            <div>
                              <p className="text-xs uppercase tracking-[0.24em] text-slate-400">Economy</p>
                              <p className="mt-1 text-lg font-semibold text-white">{performanceOverallTotal.economy.toFixed(2)}</p>
                            </div>
                          </>
                        ) : (
                          <>
                            <div>
                              <p className="text-xs uppercase tracking-[0.24em] text-slate-400">Runs</p>
                              <p className="mt-1 text-lg font-semibold text-white">{performanceOverallTotal.runs}</p>
                            </div>
                            <div>
                              <p className="text-xs uppercase tracking-[0.24em] text-slate-400">Strike rate</p>
                              <p className="mt-1 text-lg font-semibold text-white">{performanceOverallTotal.strike_rate.toFixed(2)}</p>
                            </div>
                          </>
                        )}
                      </div>
                    </div>
                  )}
                </div>
              ) : (
                <p className="mt-3 rounded-2xl border border-dashed border-white/15 bg-white/5 px-4 py-5 text-sm text-slate-400">
                  Choose a venue filter, mode, and style, then generate a player performance report.
                </p>
              )}
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
