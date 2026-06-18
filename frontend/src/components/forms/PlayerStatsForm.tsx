"use client";

import { useEffect, useMemo, useState } from "react";
import { GlassCard } from "@/components/ui/GlassCard";
import { NeonButton } from "@/components/ui/NeonButton";
import type { Player } from "@/types/cricket";

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

type Props = {
  players: Player[];
  matchTeams?: Array<{ id: string; label: "Team A" | "Team B"; name: string }>;
  value: PlayerStatRow[];
  onChange: (rows: PlayerStatRow[]) => void;
};

export function PlayerStatsForm({ players, matchTeams = [], value, onChange }: Props) {
  const [activeTeamId, setActiveTeamId] = useState(matchTeams[0]?.id || "");
  const [draft, setDraft] = useState<PlayerStatRow>({
    player_id: players[0]?.id || "",
    team_id: players[0]?.team_id || "",
    batting_position: 1,
    dismissal: "",
    runs: 0,
    balls: 0,
    fours: 0,
    sixes: 0,
    strike_rate: 0,
    overs: 0,
    maidens: 0,
    runs_conceded: 0,
    wickets: 0,
    dot_balls: 0,
    economy: 0,
    catches: 0,
    runouts: 0,
    stumpings: 0,
  });

  const playerNameMap = useMemo(() => new Map(players.map((player) => [player.id, player.player_name])), [players]);
  const activeTeam = useMemo(
    () => matchTeams.find((team) => team.id === activeTeamId) || matchTeams[0] || null,
    [activeTeamId, matchTeams],
  );
  const activePlayers = useMemo(
    () => players.filter((player) => player.team_id === activeTeam?.id),
    [players, activeTeam],
  );
  const fields = [
    {
      key: "batting_position",
      label: "Batting position",
      helper: "1 for opener, 4-7 for middle order, 0 if not batted",
      section: "Batting",
      placeholder: "1",
      inputType: "number",
    },
    {
      key: "runs",
      label: "Runs",
      helper: "Total runs scored by the player",
      section: "Batting",
      placeholder: "Runs scored",
      inputType: "number",
    },
    {
      key: "balls",
      label: "Balls",
      helper: "Total balls faced while batting",
      section: "Batting",
      placeholder: "Balls faced",
      inputType: "number",
    },
    {
      key: "dismissal",
      label: "Dismissal",
      helper: "How the batter got out, e.g. c fielder b bowler or not out",
      section: "Batting",
      placeholder: "Dismissal",
      inputType: "text",
    },
    {
      key: "fours",
      label: "Fours",
      helper: "Number of boundaries hit along the ground",
      section: "Batting",
      placeholder: "Fours",
      inputType: "number",
    },
    {
      key: "sixes",
      label: "Sixes",
      helper: "Number of sixes hit over the boundary",
      section: "Batting",
      placeholder: "Sixes",
      inputType: "number",
    },
    {
      key: "overs",
      label: "Overs bowled",
      helper: "Overs completed in bowling; use decimals like 3.4 if needed",
      section: "Bowling",
      placeholder: "Overs",
      inputType: "number",
    },
    {
      key: "wickets",
      label: "Wickets",
      helper: "Total wickets taken by the bowler",
      section: "Bowling",
      placeholder: "Wickets",
      inputType: "number",
    },
    {
      key: "runs_conceded",
      label: "Runs conceded",
      helper: "Runs given away in bowling",
      section: "Bowling",
      placeholder: "Runs conceded",
      inputType: "number",
    },
    {
      key: "dot_balls",
      label: "Dot balls",
      helper: "Balls that conceded no runs",
      section: "Bowling",
      placeholder: "Dot balls",
      inputType: "number",
    },
    {
      key: "maidens",
      label: "Maidens",
      helper: "Overs where no runs were conceded",
      section: "Bowling",
      placeholder: "Maidens",
      inputType: "number",
    },
    {
      key: "catches",
      label: "Catches",
      helper: "Catches taken in the field",
      section: "Fielding",
      placeholder: "Catches",
      inputType: "number",
    },
    {
      key: "runouts",
      label: "Run-outs",
      helper: "Direct or assisted run-outs",
      section: "Fielding",
      placeholder: "Run-outs",
      inputType: "number",
    },
    {
      key: "stumpings",
      label: "Stumpings",
      helper: "Stumpings completed by the wicketkeeper",
      section: "Fielding",
      placeholder: "Stumpings",
      inputType: "number",
    },
  ] as const;

  const sections = ["Batting", "Bowling", "Fielding"] as const;

  useEffect(() => {
    if (!matchTeams.length) {
      return;
    }

    const nextActiveTeam = matchTeams.find((team) => team.id === activeTeamId) || matchTeams[0];
    if (nextActiveTeam && nextActiveTeam.id !== activeTeamId) {
      setActiveTeamId(nextActiveTeam.id);
    }
  }, [activeTeamId, matchTeams]);

  useEffect(() => {
    if (!activePlayers.length) {
      setDraft((current) => ({ ...current, player_id: "", team_id: activeTeam?.id || current.team_id }));
      return;
    }

    const selectedPlayer = activePlayers.find((player) => player.id === draft.player_id) || activePlayers[0];
    setDraft((current) => ({
      ...current,
      player_id: selectedPlayer.id,
      team_id: selectedPlayer.team_id,
    }));
  }, [activeTeam?.id, activePlayers, draft.player_id]);

  const addRow = () => {
    if (!draft.player_id) {
      return;
    }
    const selectedPlayer = players.find((player) => player.id === draft.player_id);
    onChange([
      ...value,
      {
        ...draft,
        team_id: selectedPlayer?.team_id || draft.team_id,
        strike_rate: draft.balls ? Number(((draft.runs / draft.balls) * 100).toFixed(2)) : 0,
        economy: draft.overs ? Number((draft.runs_conceded / draft.overs).toFixed(2)) : 0,
      },
    ]);
  };

  const removeRow = (index: number) => {
    onChange(value.filter((_, rowIndex) => rowIndex !== index));
  };

  return (
    <GlassCard>
      {players.length === 0 ? (
        <p className="rounded-2xl border border-dashed border-white/15 bg-white/5 px-4 py-5 text-sm text-slate-400">
          Select Team A and Team B in match details to load the eligible player list.
        </p>
      ) : (
        <div className="space-y-5">
          {matchTeams.length > 0 && (
            <div className="flex flex-wrap gap-2">
              {matchTeams.map((team) => (
                <button
                  key={team.id}
                  type="button"
                  onClick={() => setActiveTeamId(team.id)}
                  className={`rounded-full px-4 py-2 text-xs font-semibold transition ${
                    activeTeam?.id === team.id
                      ? "border border-cyan-300/40 bg-cyan-300/15 text-cyan-100 shadow-[0_0_20px_rgba(34,211,238,0.2)]"
                      : "border border-white/10 bg-white/5 text-slate-300 hover:border-cyan-300/25 hover:text-white"
                  }`}
                >
                  {team.label} • {team.name}
                </button>
              ))}
            </div>
          )}

          <div>
            <p className="mb-2 text-xs uppercase tracking-[0.24em] text-slate-400">
              Player selection {activeTeam ? `• ${activeTeam.label}` : ""}
            </p>
            <select
              value={draft.player_id}
              onChange={(e) => {
                const player = activePlayers.find((current) => current.id === e.target.value);
                setDraft((current) => ({ ...current, player_id: e.target.value, team_id: player?.team_id || current.team_id }));
              }}
              className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white"
            >
              {activePlayers.map((player) => (
                <option key={player.id} value={player.id}>
                  {player.player_name}
                </option>
              ))}
            </select>
            <p className="mt-2 text-xs text-slate-500">
              Pick the player from {activeTeam?.label || "the selected team"} who contributed to this match.
            </p>
          </div>

          {sections.map((section) => {
            const sectionFields = fields.filter((field) => field.section === section);
            return (
              <div key={section} className="rounded-3xl border border-white/10 bg-white/5 p-4">
                <div className="mb-4">
                  <h4 className="text-sm font-semibold uppercase tracking-[0.24em] text-cyan-200">{section}</h4>
                  <p className="mt-1 text-xs text-slate-400">
                    {section === "Batting" && "Enter batting output for this player."}
                    {section === "Bowling" && "Enter bowling figures for this player."}
                    {section === "Fielding" && "Enter fielding contributions for this player."}
                  </p>
                </div>
                <div className="grid gap-3 md:grid-cols-2 xl:grid-cols-3">
                  {sectionFields.map((field) => (
                    <label key={field.key} className="block">
                      <span className="mb-2 block text-xs uppercase tracking-[0.22em] text-slate-400">{field.label}</span>
                      <input
                        type={field.inputType ?? "number"}
                        value={(draft as any)[field.key]}
                        onChange={(e) =>
                          setDraft((current) => ({
                            ...current,
                            [field.key]: field.inputType === "text" ? e.target.value : Number(e.target.value),
                          }))
                        }
                        placeholder={field.placeholder}
                        className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none placeholder:text-slate-500 focus:border-cyan-300/50"
                      />
                      <span className="mt-2 block text-xs text-slate-500">{field.helper}</span>
                    </label>
                  ))}
                </div>
              </div>
            );
          })}
        </div>
      )}
      <div className="mt-4 flex items-center gap-3">
        <NeonButton onClick={addRow} disabled={players.length === 0}>
          Add player stat
        </NeonButton>
        <p className="text-sm text-slate-400">Capture innings and bowling impact rows for the selected match.</p>
      </div>
      <div className="mt-4 space-y-2">
        {value.length === 0 ? (
          <p className="rounded-2xl border border-dashed border-white/15 bg-white/5 px-4 py-5 text-sm text-slate-400">
            No player stats added yet.
          </p>
        ) : (
          value
            .map((row, index) => ({ row, index }))
            .filter(({ row }) => !activeTeamId || row.team_id === activeTeamId)
            .map(({ row, index }) => (
              <div key={`${row.player_id}-${index}`} className="flex flex-wrap items-center justify-between gap-3 rounded-2xl border border-white/10 bg-white/5 px-4 py-3 text-sm">
                <span className="text-white">{playerNameMap.get(row.player_id) || row.player_id}</span>
                <span className="text-slate-400">
                  Dismissal {row.dismissal || "—"} • Runs {row.runs} • Balls {row.balls} • Wickets {row.wickets}
                </span>
                <button className="text-xs text-rose-300" onClick={() => removeRow(index)}>
                  Remove
                </button>
              </div>
            ))
        )}
      </div>
    </GlassCard>
  );
}
