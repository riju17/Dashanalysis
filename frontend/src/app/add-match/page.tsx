"use client";

import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { api } from "@/lib/api";
import { AppShell } from "@/components/layout/AppShell";
import { MatchEntryForm } from "@/components/forms/MatchEntryForm";
import { AutoMatchImportForm } from "@/components/forms/AutoMatchImportForm";
import { Loader } from "@/components/ui/Loader";
import { ErrorState } from "@/components/ui/ErrorState";
import type { Player, Team, Venue } from "@/types/cricket";

export default function AddMatchPage() {
  const router = useRouter();
  const [mode, setMode] = useState<"manual" | "auto">("manual");
  const [teams, setTeams] = useState<Team[]>([]);
  const [venues, setVenues] = useState<Venue[]>([]);
  const [players, setPlayers] = useState<Player[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const load = async () => {
    setLoading(true);
    setError("");
    try {
      const [teamList, venueList, playerList] = await Promise.all([api.getTeams(), api.getVenues(), api.getPlayers()]);
      setTeams(teamList);
      setVenues(venueList);
      setPlayers(playerList);
    } catch {
      setError("Could not load match entry references.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, []);

  return (
    <AppShell title="Match Entry" subtitle="Capture a completed match, then unlock tactical intelligence instantly." actionLabel="Reload" onAction={load}>
      <div className="mb-4 flex flex-wrap gap-2">
        <button
          type="button"
          onClick={() => setMode("manual")}
          className={`rounded-2xl border px-4 py-2 text-sm font-semibold transition ${
            mode === "manual"
              ? "border-cyan-300/40 bg-cyan-400/15 text-cyan-100 shadow-[0_0_24px_rgba(34,211,238,0.16)]"
              : "border-white/10 bg-white/5 text-slate-300 hover:border-cyan-300/30 hover:text-white"
          }`}
        >
          Manual Entry
        </button>
        <button
          type="button"
          onClick={() => setMode("auto")}
          className={`rounded-2xl border px-4 py-2 text-sm font-semibold transition ${
            mode === "auto"
              ? "border-violet-300/40 bg-violet-400/15 text-violet-100 shadow-[0_0_24px_rgba(168,85,247,0.16)]"
              : "border-white/10 bg-white/5 text-slate-300 hover:border-violet-300/30 hover:text-white"
          }`}
        >
          Auto Import
        </button>
      </div>

      {loading && <Loader />}
      {error && !loading && <ErrorState message={error} onRetry={load} />}
      {!loading && !error && mode === "manual" && (
        <MatchEntryForm teams={teams} venues={venues} players={players} onSubmitted={(match) => router.push(`/matches/${match.id}`)} />
      )}
      {!loading && !error && mode === "auto" && <AutoMatchImportForm teams={teams} venues={venues} players={players} />}
    </AppShell>
  );
}
