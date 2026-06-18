"use client";

import { useEffect, useState } from "react";
import { api } from "@/lib/api";
import { AppShell } from "@/components/layout/AppShell";
import { GlassCard } from "@/components/ui/GlassCard";
import { Loader } from "@/components/ui/Loader";
import { ErrorState } from "@/components/ui/ErrorState";
import { EmptyState } from "@/components/ui/EmptyState";
import { TeamComparisonChart } from "@/components/charts/TeamComparisonChart";
import { getTeamTheme } from "@/config/teamThemes";
import type { Team, Venue, TeamAnalytics } from "@/types/cricket";

type StrategyData = {
  head_to_head: Record<string, number>;
  best_toss_decision: string;
  suggested_target: number;
  opponent_weakness: string;
  top_batsmen: Array<{
    player_name: string;
    runs: number;
    wickets: number;
    batting_impact: number;
  }>;
  top_bowlers: Array<{
    player_name: string;
    runs: number;
    wickets: number;
    bowling_impact: number;
  }>;
  bowling_strategy: string;
  batting_strategy: string;
  insights: string[];
};

export default function OpponentStrategyPage() {
  const [teams, setTeams] = useState<Team[]>([]);
  const [venues, setVenues] = useState<Venue[]>([]);
  const [ourTeamId, setOurTeamId] = useState("");
  const [opponentTeamId, setOpponentTeamId] = useState("");
  const [venueId, setVenueId] = useState("");
  const [ourTeam, setOurTeam] = useState<TeamAnalytics | null>(null);
  const [opponentTeam, setOpponentTeam] = useState<TeamAnalytics | null>(null);
  const [data, setData] = useState<StrategyData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const load = async () => {
    setLoading(true);
    setError("");
    try {
      const [teamList, venueList] = await Promise.all([api.getTeams(), api.getVenues()]);
      setTeams(teamList);
      setVenues(venueList);
      const firstTeam = ourTeamId || teamList[0]?.id;
      const secondTeam = opponentTeamId || teamList[1]?.id;
      const firstVenue = venueId || venueList[0]?.id;
      if (firstTeam && secondTeam && firstVenue) {
        setOurTeamId(firstTeam);
        setOpponentTeamId(secondTeam);
        setVenueId(firstVenue);
        const [ourAnalytics, opponentAnalytics, strategy] = await Promise.all([
          api.getTeam(firstTeam),
          api.getTeam(secondTeam),
          api.getOpponentStrategy(firstTeam, secondTeam, firstVenue),
        ]);
        setOurTeam(ourAnalytics);
        setOpponentTeam(opponentAnalytics);
        setData(strategy as StrategyData);
      }
    } catch {
      setError("Could not load opponent strategy.");
    } finally {
      setLoading(false);
    }
  };

  const runStrategy = async (nextOurTeamId = ourTeamId, nextOpponentTeamId = opponentTeamId, nextVenueId = venueId) => {
    setLoading(true);
    try {
      const [ourAnalytics, opponentAnalytics, strategy] = await Promise.all([
        api.getTeam(nextOurTeamId),
        api.getTeam(nextOpponentTeamId),
        api.getOpponentStrategy(nextOurTeamId, nextOpponentTeamId, nextVenueId),
      ]);
      setOurTeam(ourAnalytics);
      setOpponentTeam(opponentAnalytics);
      setData(strategy as StrategyData);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, []);

  const theme = getTeamTheme(ourTeam?.team?.team_name);

  return (
    <AppShell title="Opponent Strategy Engine" subtitle="Turn matchup data into specific batting and bowling instructions." actionLabel="Recompute" onAction={() => runStrategy()}>
      {loading && <Loader />}
      {error && !loading && <ErrorState message={error} onRetry={load} />}
      {!loading && !error && data && ourTeam && opponentTeam && (
        <div className="space-y-6">
          <GlassCard>
            <div className="grid gap-4 md:grid-cols-3">
              <Select value={ourTeamId} onChange={setOurTeamId} label="Our team" options={teams} />
              <Select value={opponentTeamId} onChange={setOpponentTeamId} label="Opponent" options={teams} />
              <Select value={venueId} onChange={setVenueId} label="Venue" options={venues} />
            </div>
            <div className="mt-4">
              <button
                onClick={() => runStrategy()}
                className="rounded-2xl bg-gradient-to-r from-cyan-500 to-violet-500 px-4 py-2 text-sm font-semibold text-white shadow-neon"
              >
                Analyse matchup
              </button>
            </div>
          </GlassCard>

          <TeamComparisonChart
            teamALabel={ourTeam.team.team_name}
            teamBLabel={opponentTeam.team.team_name}
            data={[
              { label: "Win %", teamA: ourTeam.metrics.win_percentage, teamB: opponentTeam.metrics.win_percentage },
              { label: "Bat first %", teamA: ourTeam.metrics.bat_first_win_percentage, teamB: opponentTeam.metrics.bat_first_win_percentage },
              { label: "Chase %", teamA: ourTeam.metrics.chase_win_percentage, teamB: opponentTeam.metrics.chase_win_percentage },
              { label: "Strength", teamA: ourTeam.metrics.team_strength_score, teamB: opponentTeam.metrics.team_strength_score },
            ]}
          />

          <div className="grid gap-4 xl:grid-cols-2">
            <GlassCard>
              <h3 className="text-lg font-semibold text-white">Tactical output</h3>
              <div className="mt-4 space-y-3 text-sm text-slate-300">
                {[
                  `Best toss decision: ${data.best_toss_decision}`,
                  `Suggested target: ${data.suggested_target}`,
                  `Opponent weakness: ${data.opponent_weakness}`,
                  `Bowling strategy: ${data.bowling_strategy}`,
                  `Batting strategy: ${data.batting_strategy}`,
                ].map((line) => (
                  <p key={line} className="rounded-2xl border border-white/10 bg-white/5 px-4 py-3">
                    {line}
                  </p>
                ))}
              </div>
            </GlassCard>
            <div className="space-y-4">
              <GlassCard>
                <h3 className="text-lg font-semibold text-white">Top batsmen</h3>
                <div className="mt-4 space-y-2">
                  {data.top_batsmen.map((player) => (
                    <div key={player.player_name} className="rounded-2xl border border-white/10 bg-white/5 px-4 py-3">
                      <p className="text-sm font-semibold text-white">{player.player_name}</p>
                      <p className="mt-1 text-xs uppercase tracking-[0.22em] text-slate-400">
                        Runs {player.runs} • Wickets {player.wickets} • Batting impact {player.batting_impact.toFixed(2)}
                      </p>
                    </div>
                  ))}
                </div>
              </GlassCard>
              <GlassCard>
                <h3 className="text-lg font-semibold text-white">Top bowlers</h3>
                <div className="mt-4 space-y-2">
                  {data.top_bowlers.map((player) => (
                    <div key={player.player_name} className="rounded-2xl border border-white/10 bg-white/5 px-4 py-3">
                      <p className="text-sm font-semibold text-white">{player.player_name}</p>
                      <p className="mt-1 text-xs uppercase tracking-[0.22em] text-slate-400">
                        Wickets {player.wickets} • Runs {player.runs} • Bowling impact {player.bowling_impact.toFixed(2)}
                      </p>
                    </div>
                  ))}
                </div>
              </GlassCard>
              <GlassCard>
                <h3 className="text-lg font-semibold text-white">Match insights</h3>
                <div className="mt-4 space-y-2">
                  {data.insights.map((insight) => (
                    <p key={insight} className="rounded-2xl border border-cyan-300/20 bg-cyan-400/10 px-4 py-3 text-sm text-cyan-100">
                      {insight}
                    </p>
                  ))}
                </div>
              </GlassCard>
            </div>
          </div>
        </div>
      )}
      {!loading && !error && (!data || !ourTeam || !opponentTeam) && (
        <EmptyState title="No matchup data" description="Opponent strategy requires at least two teams and completed match history." actionLabel="Open dashboard" onAction={() => window.location.assign("/dashboard")} />
      )}
    </AppShell>
  );
}

function Select({
  label,
  value,
  onChange,
  options,
}: {
  label: string;
  value: string;
  onChange: (value: string) => void;
  options: Array<Team | Venue>;
}) {
  return (
    <label className="block">
      <span className="mb-2 block text-xs uppercase tracking-[0.24em] text-slate-400">{label}</span>
      <select
        value={value}
        onChange={(event) => onChange(event.target.value)}
        className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-cyan-300/50"
      >
        <option value="">Select</option>
        {options.map((option) => (
          <option key={option.id} value={option.id}>
            {"team_name" in option ? option.team_name : option.venue_name}
          </option>
        ))}
      </select>
    </label>
  );
}
