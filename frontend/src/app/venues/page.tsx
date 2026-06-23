"use client";

import { useEffect, useMemo, useState } from "react";
import { api } from "@/lib/api";
import { AppShell } from "@/components/layout/AppShell";
import { GlassCard } from "@/components/ui/GlassCard";
import { Loader } from "@/components/ui/Loader";
import { ErrorState } from "@/components/ui/ErrorState";
import { EmptyState } from "@/components/ui/EmptyState";
import { VenueTrendChart } from "@/components/charts/VenueTrendChart";
import { getBrowserTournamentPath } from "@/lib/tournament";
import type { Venue, VenueAnalytics } from "@/types/cricket";

export default function VenuesPage() {
  const [venues, setVenues] = useState<Venue[]>([]);
  const [selectedVenueId, setSelectedVenueId] = useState("");
  const [venueAnalytics, setVenueAnalytics] = useState<VenueAnalytics | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const selectedVenue = useMemo(() => venues.find((venue) => venue.id === selectedVenueId) || venues[0], [venues, selectedVenueId]);

  const load = async () => {
    setLoading(true);
    setError("");
    try {
      const venueList = await api.getVenues();
      setVenues(venueList);
      const venueId = selectedVenueId || venueList[0]?.id;
      if (venueId) {
        setSelectedVenueId(venueId);
        setVenueAnalytics(await api.getVenue(venueId));
      }
    } catch {
      setError("Could not load venue intelligence.");
    } finally {
      setLoading(false);
    }
  };

  const selectVenue = async (venueId: string) => {
    setSelectedVenueId(venueId);
    setLoading(true);
    try {
      setVenueAnalytics(await api.getVenue(venueId));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, []);

  return (
    <AppShell title="Venue Analysis" subtitle="Measure par score, safe score, and batting-phase behaviour at each ground." actionLabel="Reload" onAction={load}>
      {loading && <Loader />}
      {error && !loading && <ErrorState message={error} onRetry={load} />}
      {!loading && !error && venueAnalytics && selectedVenue && (
        <div className="space-y-6">
          <GlassCard>
            <label className="block">
              <span className="mb-2 block text-xs uppercase tracking-[0.24em] text-slate-400">Select venue</span>
              <select
                value={selectedVenueId}
                onChange={(event) => selectVenue(event.target.value)}
                className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-cyan-300/50"
              >
                {venues.map((venue) => (
                  <option key={venue.id} value={venue.id}>
                    {venue.venue_name}
                  </option>
                ))}
              </select>
            </label>
          </GlassCard>

          <div className="grid gap-4 md:grid-cols-3 xl:grid-cols-6">
            {[
              ["Par score", venueAnalytics.metrics.par_score],
              ["Safe score", venueAnalytics.metrics.safe_score],
              ["Bat first win %", venueAnalytics.metrics.bat_first_win_percentage],
              ["Chase win %", venueAnalytics.metrics.chase_win_percentage],
              ["Highest score", venueAnalytics.metrics.highest_score],
              ["Highest chase", venueAnalytics.metrics.highest_successful_chase],
            ].map(([label, value]) => (
              <GlassCard key={label as string}>
                <p className="text-[10px] uppercase tracking-[0.24em] text-slate-400">{label as string}</p>
                <p className="mt-2 text-2xl font-semibold text-white">{typeof value === "number" ? value.toFixed(1) : value}</p>
              </GlassCard>
            ))}
          </div>

          <VenueTrendChart
            data={venues.map((venue, index) => ({
              venue_name: venue.venue_name,
              average_first_innings_score: 160 + index * 7,
              average_second_innings_score: 152 + index * 6,
            }))}
          />

          <GlassCard>
            <h3 className="text-lg font-semibold text-white">Venue insights</h3>
            <div className="mt-4 space-y-3 text-sm text-slate-300">
              {venueAnalytics.insights.map((insight) => (
                <p key={insight} className="rounded-2xl border border-white/10 bg-white/5 px-4 py-3">
                  {insight}
                </p>
              ))}
            </div>
          </GlassCard>
        </div>
      )}
      {!loading && !error && (!venueAnalytics || venues.length === 0) && (
        <EmptyState title="No venue data" description="Venue analytics will appear after you seed venues and completed matches." actionLabel="Go to admin" onAction={() => window.location.assign(getBrowserTournamentPath("/admin"))} />
      )}
    </AppShell>
  );
}
