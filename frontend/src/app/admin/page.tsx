"use client";

import { useEffect, useState } from "react";
import { api } from "@/lib/api";
import { AppShell } from "@/components/layout/AppShell";
import { GlassCard } from "@/components/ui/GlassCard";
import { Loader } from "@/components/ui/Loader";
import { ErrorState } from "@/components/ui/ErrorState";
import { EmptyState } from "@/components/ui/EmptyState";
import { TeamForm } from "@/components/forms/TeamForm";
import { VenueForm } from "@/components/forms/VenueForm";
import type { Player, Team, Venue } from "@/types/cricket";

export default function AdminPage() {
  const [teams, setTeams] = useState<Team[]>([]);
  const [players, setPlayers] = useState<Player[]>([]);
  const [venues, setVenues] = useState<Venue[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const load = async () => {
    setLoading(true);
    setError("");
    try {
      const [teamList, playerList, venueList] = await Promise.all([api.getTeams(), api.getPlayers(), api.getVenues()]);
      setTeams(teamList);
      setPlayers(playerList);
      setVenues(venueList);
    } catch {
      setError("Could not load admin data.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, []);

  return (
    <AppShell title="Admin Panel" subtitle="Manage teams, players, venues, seasons, and theme colours." actionLabel="Reload" onAction={load}>
      {loading && <Loader />}
      {error && !loading && <ErrorState message={error} onRetry={load} />}
      {!loading && !error && (
        <div className="space-y-6">
          <div className="grid gap-4 xl:grid-cols-2">
            <TeamForm onSaved={load} />
            <VenueForm onSaved={load} />
          </div>

          <div className="grid gap-4 xl:grid-cols-3">
            <GlassCard>
              <h3 className="text-lg font-semibold text-white">Teams</h3>
              <div className="mt-4 space-y-2">
                {teams.map((team) => (
                  <div key={team.id} className="rounded-2xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-slate-300">
                    {team.team_name} • {team.primary_color} • {team.secondary_color} • {team.accent_color}
                  </div>
                ))}
              </div>
            </GlassCard>
            <GlassCard>
              <h3 className="text-lg font-semibold text-white">Players</h3>
              <div className="mt-4 space-y-2">
                {players.slice(0, 10).map((player) => (
                  <div key={player.id} className="rounded-2xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-slate-300">
                    {player.player_name} • {player.role}
                  </div>
                ))}
              </div>
            </GlassCard>
            <GlassCard>
              <h3 className="text-lg font-semibold text-white">Venues & seasons</h3>
              <div className="mt-4 space-y-2">
                {venues.map((venue) => (
                  <div key={venue.id} className="rounded-2xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-slate-300">
                    {venue.venue_name} • {venue.city}, {venue.country}
                  </div>
                ))}
                <div className="rounded-2xl border border-dashed border-white/15 bg-white/5 px-4 py-3 text-sm text-slate-400">
                  Tournament season manager placeholder
                </div>
              </div>
            </GlassCard>
          </div>
        </div>
      )}
      {!loading && !error && teams.length === 0 && players.length === 0 && venues.length === 0 && (
        <EmptyState title="No admin data" description="Seed the database with teams, players, and venues to manage the environment." actionLabel="Open dashboard" onAction={() => window.location.assign("/dashboard")} />
      )}
    </AppShell>
  );
}
