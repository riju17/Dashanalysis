"use client";

import { useEffect, useState } from "react";
import { api } from "@/lib/api";
import { AppShell } from "@/components/layout/AppShell";
import { GlassCard } from "@/components/ui/GlassCard";
import { Loader } from "@/components/ui/Loader";
import { ErrorState } from "@/components/ui/ErrorState";
import { EmptyState } from "@/components/ui/EmptyState";
import { WinProbabilityCard } from "@/components/cards/WinProbabilityCard";
import { getTeamTheme } from "@/config/teamThemes";
import type { PredictionInput, PredictionOutput, Team, Venue } from "@/types/cricket";

const initialInput: PredictionInput = {
  team_a_id: "",
  team_b_id: "",
  venue_id: "",
  toss_winner_id: "",
  toss_decision: "bat",
  bat_first_team_id: "",
};

export default function PredictionPage() {
  const [teams, setTeams] = useState<Team[]>([]);
  const [venues, setVenues] = useState<Venue[]>([]);
  const [input, setInput] = useState<PredictionInput>(initialInput);
  const [output, setOutput] = useState<PredictionOutput | null>(null);
  const [loading, setLoading] = useState(true);
  const [working, setWorking] = useState(false);
  const [error, setError] = useState("");

  const load = async () => {
    setLoading(true);
    setError("");
    try {
      const [teamList, venueList] = await Promise.all([api.getTeams(), api.getVenues()]);
      setTeams(teamList);
      setVenues(venueList);
      const nextInput = {
        team_a_id: input.team_a_id || teamList[0]?.id || "",
        team_b_id: input.team_b_id || teamList[1]?.id || "",
        venue_id: input.venue_id || venueList[0]?.id || "",
        toss_winner_id: input.toss_winner_id || teamList[0]?.id || "",
        toss_decision: input.toss_decision || "bat",
        bat_first_team_id: input.bat_first_team_id || teamList[0]?.id || "",
      };
      setInput(nextInput);
      setOutput(await api.predictWinProbability(nextInput));
    } catch {
      setError("Could not load prediction inputs.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, []);

  const runPrediction = async () => {
    setWorking(true);
    try {
      setOutput(await api.predictWinProbability(input));
    } finally {
      setWorking(false);
    }
  };

  const selectedTheme = getTeamTheme(teams.find((team) => team.id === input.team_a_id)?.team_name);

  return (
    <AppShell title="Prediction Engine" subtitle="Generate rule-based win probability, reasoning, and tactical signals." actionLabel="Predict" onAction={runPrediction}>
      {loading && <Loader />}
      {error && !loading && <ErrorState message={error} onRetry={load} />}
      {!loading && !error && output && (
        <div className="space-y-6">
          <GlassCard>
            <div className="grid gap-4 md:grid-cols-3">
              <Select label="Team A" value={input.team_a_id} onChange={(value) => setInput((current) => ({ ...current, team_a_id: value }))} options={teams} />
              <Select label="Team B" value={input.team_b_id} onChange={(value) => setInput((current) => ({ ...current, team_b_id: value }))} options={teams} />
              <Select label="Venue" value={input.venue_id} onChange={(value) => setInput((current) => ({ ...current, venue_id: value }))} options={venues} />
              <Select label="Toss winner" value={input.toss_winner_id || ""} onChange={(value) => setInput((current) => ({ ...current, toss_winner_id: value }))} options={teams} />
              <Select label="Toss decision" value={input.toss_decision || "bat"} onChange={(value) => setInput((current) => ({ ...current, toss_decision: value }))} options={[{ id: "bat", team_name: "Bat" } as any, { id: "bowl", team_name: "Bowl" } as any]} />
              <Select label="Bat first team" value={input.bat_first_team_id || ""} onChange={(value) => setInput((current) => ({ ...current, bat_first_team_id: value }))} options={teams} />
            </div>
            <div className="mt-4">
              <button
                onClick={runPrediction}
                disabled={working}
                className="rounded-2xl bg-gradient-to-r from-cyan-500 via-blue-500 to-violet-500 px-4 py-2 text-sm font-semibold text-white shadow-neon disabled:opacity-60"
              >
                {working ? "Predicting..." : "Run prediction"}
              </button>
            </div>
          </GlassCard>

          <WinProbabilityCard
            teamALabel={teams.find((team) => team.id === input.team_a_id)?.team_name || "Team A"}
            teamAValue={output.team_a_win_probability}
            teamBLabel={teams.find((team) => team.id === input.team_b_id)?.team_name || "Team B"}
            teamBValue={output.team_b_win_probability}
            theme={selectedTheme}
          />

          <div className="grid gap-4 xl:grid-cols-2">
            <GlassCard>
              <h3 className="text-lg font-semibold text-white">Reasoning</h3>
              <div className="mt-4 space-y-3 text-sm text-slate-300">
                {output.reasoning_points.map((item) => (
                  <p key={item} className="rounded-2xl border border-white/10 bg-white/5 px-4 py-3">
                    {item}
                  </p>
                ))}
              </div>
            </GlassCard>
            <GlassCard>
              <h3 className="text-lg font-semibold text-white">Advantages and risks</h3>
              <div className="mt-4 space-y-3 text-sm">
                <Section title="Advantages" items={output.key_advantages} accent="text-emerald-300" />
                <Section title="Risk factors" items={output.risk_factors} accent="text-rose-300" />
                <p className="rounded-2xl border border-cyan-300/20 bg-cyan-400/10 px-4 py-3 text-cyan-100">
                  Confidence: {output.confidence_level}
                </p>
                <p className="rounded-2xl border border-white/10 bg-white/5 px-4 py-3 text-slate-200">{output.recommended_decision}</p>
              </div>
            </GlassCard>
          </div>
        </div>
      )}
      {!loading && !error && !output && (
        <EmptyState title="No prediction ready" description="Add teams and venue data to generate win probability estimates." actionLabel="Add match" onAction={() => window.location.assign("/add-match")} />
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
  options: Array<any>;
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
            {option.team_name || option.venue_name || option.label || option.name}
          </option>
        ))}
      </select>
    </label>
  );
}

function Section({ title, items, accent }: { title: string; items: string[]; accent: string }) {
  return (
    <div className="space-y-2">
      <p className={`text-xs uppercase tracking-[0.24em] ${accent}`}>{title}</p>
      {items.map((item) => (
        <p key={item} className="rounded-2xl border border-white/10 bg-white/5 px-4 py-3 text-slate-300">
          {item}
        </p>
      ))}
    </div>
  );
}
