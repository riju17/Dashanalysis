"use client";

import { useEffect, useMemo, useState } from "react";
import { api } from "@/lib/api";
import { GlassCard } from "@/components/ui/GlassCard";
import { NeonButton } from "@/components/ui/NeonButton";
import { PlayerStatsForm } from "@/components/forms/PlayerStatsForm";
import type { MatchRecord, Player, Team, Venue } from "@/types/cricket";
import { Loader } from "@/components/ui/Loader";

type PlayerStatRow = {
  player_id: string;
  team_id: string;
  batting_position: number;
  dismissal: string;
  runs: number;
  balls: number;
  fours: number;
  sixes: number;
  strike_rate: number;
  overs: number;
  maidens: number;
  runs_conceded: number;
  wickets: number;
  dot_balls: number;
  economy: number;
  catches: number;
  runouts: number;
  stumpings: number;
};

type DerivedOutcome = {
  result_type: "runs" | "wickets";
  margin_runs: number | null;
  margin_wickets: number | null;
  winner_id?: string;
  loser_id?: string;
};

type Props = {
  teams: Team[];
  venues: Venue[];
  players: Player[];
  onSubmitted?: (match: MatchRecord) => void;
};

const steps = ["Match details", "Toss details", "Innings scores", "Result details", "Player stats", "Review"];

const initialForm = {
  match_date: "",
  season: "2026",
  tournament: "MPt20",
  match_number: 1,
  team_a_id: "",
  team_b_id: "",
  venue_id: "",
  toss_winner_id: "",
  toss_decision: "bat",
  bat_first_team_id: "",
  bowl_first_team_id: "",
  first_innings_score: 0,
  first_innings_wickets: 0,
  first_innings_overs: 20,
  second_innings_score: 0,
  second_innings_wickets: 0,
  second_innings_overs: 20,
  winner_id: "",
  loser_id: "",
  result_type: "runs",
  margin_runs: 0,
  margin_wickets: 0,
  player_of_match_id: "",
  notes: "",
};

function deriveMatchOutcome({
  first_innings_score,
  second_innings_score,
  second_innings_wickets,
  bat_first_team_id,
  bowl_first_team_id,
}: {
  first_innings_score: number;
  second_innings_score: number;
  second_innings_wickets: number;
  bat_first_team_id: string;
  bowl_first_team_id: string;
}): DerivedOutcome | null {
  if (first_innings_score > second_innings_score) {
    return {
      result_type: "runs",
      margin_runs: first_innings_score - second_innings_score,
      margin_wickets: 0,
      winner_id: bat_first_team_id || undefined,
      loser_id: bowl_first_team_id || undefined,
    };
  }

  if (second_innings_score > first_innings_score) {
    const wickets_lost = Math.max(0, second_innings_wickets || 0);
    const wickets_margin = Math.max(1, Math.min(10, 10 - wickets_lost));
    return {
      result_type: "wickets",
      margin_runs: 0,
      margin_wickets: wickets_margin,
      winner_id: bowl_first_team_id || undefined,
      loser_id: bat_first_team_id || undefined,
    };
  }

  return null;
}

export function MatchEntryForm({ teams, venues, players, onSubmitted }: Props) {
  const [step, setStep] = useState(0);
  const [form, setForm] = useState(initialForm);
  const [rows, setRows] = useState<PlayerStatRow[]>([]);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState("");

  const selectedTeams = useMemo(
    () =>
      [teams.find((team) => team.id === form.team_a_id), teams.find((team) => team.id === form.team_b_id)].filter(
        (team): team is Team => team !== undefined,
      ),
    [teams, form.team_a_id, form.team_b_id],
  );

  const selectedTeamIds = useMemo(() => new Set(selectedTeams.map((team) => team.id)), [selectedTeams]);

  const teamAPlayers = useMemo(() => players.filter((player) => player.team_id === form.team_a_id), [players, form.team_a_id]);
  const teamBPlayers = useMemo(() => players.filter((player) => player.team_id === form.team_b_id), [players, form.team_b_id]);

  const selectedPlayers = useMemo(
    () => [...teamAPlayers, ...teamBPlayers],
    [teamAPlayers, teamBPlayers],
  );

  const selectedPlayerIds = useMemo(() => new Set(selectedPlayers.map((player) => player.id)), [selectedPlayers]);

  const selectedTeamName = (teamId: string) => teams.find((team) => team.id === teamId)?.team_name || "";
  const matchTeamsForStats = useMemo(
    () =>
      [
        { id: form.team_a_id, label: "Team A" as const, name: selectedTeamName(form.team_a_id) || "Team A" },
        { id: form.team_b_id, label: "Team B" as const, name: selectedTeamName(form.team_b_id) || "Team B" },
      ].filter((team) => team.id),
    [form.team_a_id, form.team_b_id, teams],
  );

  const derivedOutcome = useMemo(
    () =>
      deriveMatchOutcome({
        first_innings_score: form.first_innings_score,
        second_innings_score: form.second_innings_score,
        second_innings_wickets: form.second_innings_wickets,
        bat_first_team_id: form.bat_first_team_id,
        bowl_first_team_id: form.bowl_first_team_id,
      }),
    [form.first_innings_score, form.second_innings_score, form.second_innings_wickets, form.bat_first_team_id, form.bowl_first_team_id],
  );

  useEffect(() => {
    setForm((current) => {
      const next = { ...current };
      if (next.toss_winner_id && !selectedTeamIds.has(next.toss_winner_id)) next.toss_winner_id = "";
      if (next.bat_first_team_id && !selectedTeamIds.has(next.bat_first_team_id)) next.bat_first_team_id = "";
      if (next.bowl_first_team_id && !selectedTeamIds.has(next.bowl_first_team_id)) next.bowl_first_team_id = "";
      if (next.winner_id && !selectedTeamIds.has(next.winner_id)) next.winner_id = "";
      if (next.loser_id && !selectedTeamIds.has(next.loser_id)) next.loser_id = "";
      if (next.player_of_match_id && !selectedPlayerIds.has(next.player_of_match_id)) next.player_of_match_id = "";
      return next;
    });

    setRows((current) => current.filter((row) => selectedPlayerIds.has(row.player_id)));
  }, [selectedPlayerIds, selectedTeamIds]);

  useEffect(() => {
    if (!derivedOutcome) {
      return;
    }

    setForm((current) => {
      const next = { ...current };
      let changed = false;

      if (derivedOutcome.result_type && next.result_type !== derivedOutcome.result_type) {
        next.result_type = derivedOutcome.result_type;
        changed = true;
      }

      if (typeof derivedOutcome.margin_runs === "number" && next.margin_runs !== derivedOutcome.margin_runs) {
        next.margin_runs = derivedOutcome.margin_runs;
        changed = true;
      }

      if (typeof derivedOutcome.margin_wickets === "number" && next.margin_wickets !== derivedOutcome.margin_wickets) {
        next.margin_wickets = derivedOutcome.margin_wickets;
        changed = true;
      }

      if (derivedOutcome.winner_id && next.winner_id !== derivedOutcome.winner_id) {
        next.winner_id = derivedOutcome.winner_id;
        changed = true;
      }

      if (derivedOutcome.loser_id && next.loser_id !== derivedOutcome.loser_id) {
        next.loser_id = derivedOutcome.loser_id;
        changed = true;
      }

      return changed ? next : current;
    });
  }, [derivedOutcome]);

  const update = (field: keyof typeof form, value: string | number) => setForm((current) => ({ ...current, [field]: value }));

  const next = () => setStep((current) => Math.min(current + 1, steps.length - 1));
  const back = () => setStep((current) => Math.max(current - 1, 0));
  const canProceedFromMatchDetails =
    Boolean(form.match_date && form.season && form.tournament && form.team_a_id && form.team_b_id && form.venue_id) &&
    form.team_a_id !== form.team_b_id;

  const submit = async () => {
    setLoading(true);
    setMessage("");
    try {
      const payload = {
        ...form,
        team_a_id: form.team_a_id,
        team_b_id: form.team_b_id,
        venue_id: form.venue_id,
        toss_winner_id: form.toss_winner_id || null,
        bat_first_team_id: form.bat_first_team_id || null,
        bowl_first_team_id: form.bowl_first_team_id || null,
        player_of_match_id: form.player_of_match_id || null,
        result_type: derivedOutcome?.result_type || form.result_type,
        margin_runs: derivedOutcome?.margin_runs ?? (form.result_type === "runs" ? Number(form.margin_runs) : null),
        margin_wickets: derivedOutcome?.margin_wickets ?? (form.result_type === "wickets" ? Number(form.margin_wickets) : null),
        winner_id: derivedOutcome?.winner_id || form.winner_id || null,
        loser_id: derivedOutcome?.loser_id || form.loser_id || null,
      };
      const match = await api.createMatch(payload);
      if (rows.length > 0) {
        await api.createPlayerStats(match.id, rows as any);
      }
      setMessage("Match saved successfully.");
      onSubmitted?.(match);
      setForm(initialForm);
      setRows([]);
      setStep(0);
    } finally {
      setLoading(false);
    }
  };

  return (
    <GlassCard>
      <div className="mb-6 flex flex-wrap gap-2">
        {steps.map((label, index) => (
          <div
            key={label}
            className={`rounded-full px-3 py-1 text-xs font-semibold ${
              index === step ? "bg-cyan-400/20 text-cyan-200" : "bg-white/5 text-slate-400"
            }`}
          >
            {index + 1}. {label}
          </div>
        ))}
      </div>

      {loading && (
        <div className="mb-4">
          <Loader label="Saving match intelligence..." />
        </div>
      )}

      {step === 0 && (
        <StepGrid>
          <Field label="Match date" type="date" value={form.match_date} onChange={(value) => update("match_date", value)} />
          <Field label="Season" value={form.season} onChange={(value) => update("season", value)} />
          <Field label="Tournament" value={form.tournament} onChange={(value) => update("tournament", value)} />
          <Field label="Match number" type="number" value={form.match_number} onChange={(value) => update("match_number", Number(value))} />
          <SelectField label="Team A" value={form.team_a_id} onChange={(value) => update("team_a_id", value)}>
            <OptionPlaceholder label="Select team A" />
            {teams
              .filter((team) => team.id !== form.team_b_id)
              .map((team) => (
                <option key={team.id} value={team.id}>
                  {team.team_name}
                </option>
              ))}
          </SelectField>
          <SelectField label="Team B" value={form.team_b_id} onChange={(value) => update("team_b_id", value)}>
            <OptionPlaceholder label="Select team B" />
            {teams
              .filter((team) => team.id !== form.team_a_id)
              .map((team) => (
                <option key={team.id} value={team.id}>
                  {team.team_name}
                </option>
              ))}
          </SelectField>
          <SelectField label="Venue" value={form.venue_id} onChange={(value) => update("venue_id", value)}>
            <OptionPlaceholder label="Select venue" />
            {venues.map((venue) => (
              <option key={venue.id} value={venue.id}>{venue.venue_name}</option>
            ))}
          </SelectField>
          <SelectField label="Match type" value="T20" onChange={() => undefined}>
            <option value="T20">T20</option>
          </SelectField>
        </StepGrid>
      )}

      {step === 1 && (
        <StepGrid>
          <SelectField label="Toss winner" value={form.toss_winner_id} onChange={(value) => update("toss_winner_id", value)}>
            <OptionPlaceholder label="Select toss winner" />
            {selectedTeams.map((team) => (
              <option key={team.id} value={team.id}>
                {team.team_name}
              </option>
            ))}
          </SelectField>
          <SelectField label="Toss decision" value={form.toss_decision} onChange={(value) => update("toss_decision", value)}>
            <option value="bat">Bat</option>
            <option value="bowl">Bowl</option>
          </SelectField>
          <SelectField label="Bat first team" value={form.bat_first_team_id} onChange={(value) => update("bat_first_team_id", value)}>
            <OptionPlaceholder label="Select batting first team" />
            {selectedTeams.map((team) => (
              <option key={team.id} value={team.id}>
                {team.team_name}
              </option>
            ))}
          </SelectField>
          <SelectField label="Bowl first team" value={form.bowl_first_team_id} onChange={(value) => update("bowl_first_team_id", value)}>
            <OptionPlaceholder label="Select bowling first team" />
            {selectedTeams.map((team) => (
              <option key={team.id} value={team.id}>
                {team.team_name}
              </option>
            ))}
          </SelectField>
        </StepGrid>
      )}

      {step === 2 && (
        <StepGrid>
          <Field label="First innings score" type="number" value={form.first_innings_score} onChange={(value) => update("first_innings_score", Number(value))} />
          <Field label="First innings wickets" type="number" value={form.first_innings_wickets} onChange={(value) => update("first_innings_wickets", Number(value))} />
          <Field label="First innings overs" type="number" value={form.first_innings_overs} onChange={(value) => update("first_innings_overs", Number(value))} />
          <Field label="Second innings score" type="number" value={form.second_innings_score} onChange={(value) => update("second_innings_score", Number(value))} />
          <Field label="Second innings wickets" type="number" value={form.second_innings_wickets} onChange={(value) => update("second_innings_wickets", Number(value))} />
          <Field label="Second innings overs" type="number" value={form.second_innings_overs} onChange={(value) => update("second_innings_overs", Number(value))} />
        </StepGrid>
      )}

      {step === 3 && (
        <StepGrid>
          <SelectField label="Winner" value={form.winner_id} onChange={(value) => update("winner_id", value)}>
            <OptionPlaceholder label="Select winner" />
            {selectedTeams.map((team) => (
              <option key={team.id} value={team.id}>
                {team.team_name}
              </option>
            ))}
          </SelectField>
          <SelectField label="Loser" value={form.loser_id} onChange={(value) => update("loser_id", value)}>
            <OptionPlaceholder label="Select loser" />
            {selectedTeams.map((team) => (
              <option key={team.id} value={team.id}>
                {team.team_name}
              </option>
            ))}
          </SelectField>
          <Field label="Result type" value={derivedOutcome?.result_type || form.result_type} onChange={() => undefined} readOnly />
          <Field label="Margin runs" type="number" value={derivedOutcome?.margin_runs ?? form.margin_runs} onChange={() => undefined} readOnly />
          <Field label="Margin wickets" type="number" value={derivedOutcome?.margin_wickets ?? form.margin_wickets} onChange={() => undefined} readOnly />
          <SelectField label="Player of match" value={form.player_of_match_id} onChange={(value) => update("player_of_match_id", value)}>
            <OptionPlaceholder label="Select player of match" />
            {selectedPlayers.map((player) => (
              <option key={player.id} value={player.id}>{player.player_name}</option>
            ))}
          </SelectField>
          <div className="md:col-span-2">
            <label className="mb-2 block text-xs uppercase tracking-[0.24em] text-slate-400">Notes</label>
            <textarea
              value={form.notes}
              onChange={(e) => update("notes", e.target.value)}
              rows={4}
              className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none placeholder:text-slate-500 focus:border-cyan-300/50"
              placeholder="Key turning points and tactical notes"
            />
          </div>
        </StepGrid>
      )}

      {step === 4 && (
        <PlayerStatsForm
          players={selectedPlayers}
          matchTeams={matchTeamsForStats}
          value={rows}
          onChange={setRows}
        />
      )}

      {step === 5 && (
        <div className="grid gap-4 md:grid-cols-2">
          <SummaryBlock title="Match summary" lines={[
            `Match ${form.match_number} • ${form.tournament}`,
            `Teams: ${selectedTeamName(form.team_a_id) || "Team A"} vs ${selectedTeamName(form.team_b_id) || "Team B"}`,
            `Venue: ${venues.find((venue) => venue.id === form.venue_id)?.venue_name || "Select a venue"}`,
          ]} />
          <SummaryBlock title="Result summary" lines={[
            `Winner: ${selectedTeamName(form.winner_id) || "Select winner"}`,
            `Toss: ${selectedTeamName(form.toss_winner_id) || "Select toss winner"} (${form.toss_decision})`,
            `Scoreline: ${form.first_innings_score}-${form.first_innings_wickets} and ${form.second_innings_score}-${form.second_innings_wickets}`,
            `Margin: ${derivedOutcome?.result_type === "runs" ? `${derivedOutcome.margin_runs} runs` : `${derivedOutcome?.margin_wickets ?? 0} wickets`}`,
          ]} />
        </div>
      )}

      <div className="mt-6 flex flex-wrap items-center justify-between gap-3">
        <div className="text-sm text-slate-400">
          {message || "Capture the completed match and produce instant intelligence after submission."}
        </div>
        <div className="flex gap-2">
          <NeonButton onClick={back} disabled={step === 0 || loading}>
            Back
          </NeonButton>
          {step < steps.length - 1 ? (
            <NeonButton onClick={next} disabled={loading || (step === 0 && !canProceedFromMatchDetails)}>
              Next
            </NeonButton>
          ) : (
            <NeonButton onClick={submit} loading={loading}>
              Save match
            </NeonButton>
          )}
        </div>
      </div>
    </GlassCard>
  );
}

function StepGrid({ children }: { children: React.ReactNode }) {
  return <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">{children}</div>;
}

function Field({
  label,
  value,
  type = "text",
  readOnly = false,
  onChange,
}: {
  label: string;
  value: string | number;
  type?: string;
  readOnly?: boolean;
  onChange: (value: string) => void;
}) {
  return (
    <label className="block">
      <span className="mb-2 block text-xs uppercase tracking-[0.24em] text-slate-400">{label}</span>
      <input
        type={type}
        value={value}
        onChange={(event) => onChange(event.target.value)}
        readOnly={readOnly}
        className={`w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none placeholder:text-slate-500 focus:border-cyan-300/50 ${
          readOnly ? "cursor-not-allowed border-cyan-300/20 text-cyan-100" : ""
        }`}
      />
    </label>
  );
}

function SelectField({
  label,
  value,
  onChange,
  children,
}: {
  label: string;
  value: string;
  onChange: (value: string) => void;
  children: React.ReactNode;
}) {
  return (
    <label className="block">
      <span className="mb-2 block text-xs uppercase tracking-[0.24em] text-slate-400">{label}</span>
      <select
        value={value}
        onChange={(event) => onChange(event.target.value)}
        className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-cyan-300/50"
      >
        {children}
      </select>
    </label>
  );
}

function OptionPlaceholder({ label }: { label: string }) {
  return <option value="">{label}</option>;
}

function SummaryBlock({ title, lines }: { title: string; lines: string[] }) {
  return (
    <div className="rounded-3xl border border-white/10 bg-white/5 p-5">
      <h4 className="text-lg font-semibold text-white">{title}</h4>
      <div className="mt-3 space-y-2 text-sm text-slate-300">
        {lines.map((line) => (
          <p key={line} className="rounded-2xl border border-white/10 bg-slate-950/50 px-3 py-2">
            {line}
          </p>
        ))}
      </div>
    </div>
  );
}
