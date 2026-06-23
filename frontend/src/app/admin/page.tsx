"use client";

import { useEffect, useMemo, useState } from "react";
import { usePathname } from "next/navigation";
import { api } from "@/lib/api";
import { AppShell } from "@/components/layout/AppShell";
import { GlassCard } from "@/components/ui/GlassCard";
import { Loader } from "@/components/ui/Loader";
import { ErrorState } from "@/components/ui/ErrorState";
import { EmptyState } from "@/components/ui/EmptyState";
import { NeonButton } from "@/components/ui/NeonButton";
import { TeamForm } from "@/components/forms/TeamForm";
import { VenueForm } from "@/components/forms/VenueForm";
import { resolveTournamentSlug } from "@/lib/tournament";
import type {
  AccessKeyCreatePayload,
  AccessKeyRecord,
  Player,
  Team,
  TournamentAccessRecord,
  TournamentRecord,
  Venue,
} from "@/types/cricket";

function toDateTimeLocal(value?: string | null) {
  if (!value) return "";
  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) return "";
  return new Date(parsed.getTime() - (parsed.getTimezoneOffset() * 60 * 1000)).toISOString().slice(0, 16);
}

function toIsoOrNull(value: string) {
  if (!value) return null;
  const parsed = new Date(value);
  return Number.isNaN(parsed.getTime()) ? null : parsed.toISOString();
}

export default function AdminPage() {
  const pathname = usePathname();
  const tournamentSlug = resolveTournamentSlug(pathname);
  const [tournament, setTournament] = useState<TournamentRecord | null>(null);
  const [teams, setTeams] = useState<Team[]>([]);
  const [players, setPlayers] = useState<Player[]>([]);
  const [venues, setVenues] = useState<Venue[]>([]);
  const [accessRows, setAccessRows] = useState<TournamentAccessRecord[]>([]);
  const [accessKeys, setAccessKeys] = useState<AccessKeyRecord[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [message, setMessage] = useState("");
  const [keyMessage, setKeyMessage] = useState("");
  const [generatedKey, setGeneratedKey] = useState("");
  const [settingsWorking, setSettingsWorking] = useState(false);
  const [accessWorkingId, setAccessWorkingId] = useState<string | null>(null);
  const [accessKeyWorking, setAccessKeyWorking] = useState(false);
  const [keyForm, setKeyForm] = useState<AccessKeyCreatePayload>({
    tournament_id: "",
    role: "viewer",
    expires_at: "",
    access_duration_days: 30,
    max_uses: 1,
  });
  const [settingsForm, setSettingsForm] = useState({
    name: "",
    slug: "",
    season: "",
    description: "",
    logo_url: "",
    start_date: "",
    end_date: "",
    is_active: true,
  });

  const accessRoleOptions = useMemo(() => ["owner", "admin", "analyst", "viewer"] as const, []);

  const hydrateTournamentForm = (nextTournament: TournamentRecord) => {
    setSettingsForm({
      name: nextTournament.name || "",
      slug: nextTournament.slug || "",
      season: nextTournament.season || "",
      description: nextTournament.description || "",
      logo_url: nextTournament.logo_url || "",
      start_date: nextTournament.start_date || "",
      end_date: nextTournament.end_date || "",
      is_active: nextTournament.is_active,
    });
    setKeyForm((current) => ({
      ...current,
      tournament_id: nextTournament.id,
      expires_at: current.expires_at || new Date(Date.now() + (7 * 24 * 60 * 60 * 1000)).toISOString(),
    }));
  };

  const load = async () => {
    if (!tournamentSlug) {
      setLoading(false);
      setError("");
      return;
    }

    setLoading(true);
    setError("");
    setMessage("");
    setGeneratedKey("");
    try {
      const [currentTournament, teamList, playerList, venueList, accessList] = await Promise.all([
        api.getTournament(tournamentSlug),
        api.getTeams(),
        api.getPlayers(),
        api.getVenues(),
        api.getTournamentAccess(tournamentSlug),
      ]);
      const keyList = await api.listAccessKeys(currentTournament.id);

      setTournament(currentTournament);
      setTeams(teamList);
      setPlayers(playerList);
      setVenues(venueList);
      setAccessRows(accessList);
      setAccessKeys(keyList);
      hydrateTournamentForm(currentTournament);
    } catch (loadError) {
      setError(loadError instanceof Error ? loadError.message : "Could not load admin data.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void load();
  }, [tournamentSlug]);

  const saveTournamentSettings = async () => {
    if (!tournament) return;
    setSettingsWorking(true);
    setMessage("");
    try {
      const updated = await api.updateTournament(tournament.id, {
        name: settingsForm.name.trim(),
        slug: settingsForm.slug.trim(),
        season: settingsForm.season.trim(),
        description: settingsForm.description.trim() || null,
        logo_url: settingsForm.logo_url.trim() || null,
        start_date: settingsForm.start_date || null,
        end_date: settingsForm.end_date || null,
        is_active: settingsForm.is_active,
      });
      setTournament(updated);
      hydrateTournamentForm(updated);
      setMessage("Tournament settings updated.");
    } catch (saveError) {
      setMessage(saveError instanceof Error ? saveError.message : "Could not update tournament.");
    } finally {
      setSettingsWorking(false);
    }
  };

  const saveAccessRow = async (row: TournamentAccessRecord) => {
    if (!tournamentSlug) return;
    setAccessWorkingId(row.id);
    setMessage("");
    try {
      const updated = await api.updateTournamentAccess(tournamentSlug, row.id, {
        role: row.role,
        is_active: row.is_active,
        access_expires_at: row.access_expires_at || null,
      });
      setAccessRows((current) => current.map((entry) => (entry.id === updated.id ? updated : entry)));
    } catch (saveError) {
      setMessage(saveError instanceof Error ? saveError.message : "Could not update tournament access.");
    } finally {
      setAccessWorkingId(null);
    }
  };

  const revokeAccess = async (accessId: string) => {
    if (!tournamentSlug) return;
    setAccessWorkingId(accessId);
    setMessage("");
    try {
      await api.revokeTournamentAccess(tournamentSlug, accessId);
      setAccessRows((current) => current.filter((entry) => entry.id !== accessId));
    } catch (saveError) {
      setMessage(saveError instanceof Error ? saveError.message : "Could not revoke access.");
    } finally {
      setAccessWorkingId(null);
    }
  };

  const createAccessKey = async () => {
    setAccessKeyWorking(true);
    setKeyMessage("");
    setGeneratedKey("");
    try {
      const created = await api.createAccessKey({
        ...keyForm,
        expires_at: toIsoOrNull(keyForm.expires_at) || keyForm.expires_at,
      });
      setGeneratedKey(created.key);
      setKeyMessage("Access key created. Copy it now because it will not be shown again.");
      setAccessKeys((current) => [created.record, ...current]);
    } catch (createError) {
      setKeyMessage(createError instanceof Error ? createError.message : "Could not create access key.");
    } finally {
      setAccessKeyWorking(false);
    }
  };

  const disableAccessKey = async (accessKeyId: string) => {
    setAccessWorkingId(accessKeyId);
    setKeyMessage("");
    try {
      const disabled = await api.disableAccessKey(accessKeyId);
      setAccessKeys((current) => current.map((entry) => (entry.id === disabled.id ? disabled : entry)));
    } catch (disableError) {
      setKeyMessage(disableError instanceof Error ? disableError.message : "Could not disable access key.");
    } finally {
      setAccessWorkingId(null);
    }
  };

  return (
    <AppShell
      title={tournament ? `${tournament.name} Admin` : "Tournament Admin"}
      subtitle="Manage tournament settings, reference data, user access, and expiring access keys."
      actionLabel="Reload"
      onAction={() => void load()}
    >
      {loading && <Loader />}
      {error && !loading && <ErrorState message={error} onRetry={() => void load()} />}
      {!loading && !error && !tournamentSlug && (
        <EmptyState
          title="Tournament not selected"
          description="Open admin from a tournament route so settings, access, and keys are scoped correctly."
        />
      )}
      {!loading && !error && tournament && (
        <div className="space-y-6">
          <div className="grid gap-4 xl:grid-cols-2">
            <GlassCard>
              <div className="flex items-start justify-between gap-4">
                <div>
                  <h3 className="text-lg font-semibold text-white">Tournament settings</h3>
                  <p className="mt-1 text-sm text-slate-400">Name, slug, dates, branding, and active status for this tournament.</p>
                </div>
                <div className="rounded-full border border-white/10 bg-white/5 px-3 py-1 text-xs uppercase tracking-[0.2em] text-slate-300">
                  {tournament.season}
                </div>
              </div>
              <div className="mt-4 grid gap-3 md:grid-cols-2">
                <label className="space-y-2">
                  <span className="text-xs uppercase tracking-[0.24em] text-slate-400">Name</span>
                  <input
                    value={settingsForm.name}
                    onChange={(event) => setSettingsForm((current) => ({ ...current, name: event.target.value }))}
                    className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-cyan-300/50"
                  />
                </label>
                <label className="space-y-2">
                  <span className="text-xs uppercase tracking-[0.24em] text-slate-400">Slug</span>
                  <input
                    value={settingsForm.slug}
                    onChange={(event) => setSettingsForm((current) => ({ ...current, slug: event.target.value }))}
                    className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-cyan-300/50"
                  />
                </label>
                <label className="space-y-2">
                  <span className="text-xs uppercase tracking-[0.24em] text-slate-400">Season</span>
                  <input
                    value={settingsForm.season}
                    onChange={(event) => setSettingsForm((current) => ({ ...current, season: event.target.value }))}
                    className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-cyan-300/50"
                  />
                </label>
                <label className="space-y-2">
                  <span className="text-xs uppercase tracking-[0.24em] text-slate-400">Logo URL</span>
                  <input
                    value={settingsForm.logo_url}
                    onChange={(event) => setSettingsForm((current) => ({ ...current, logo_url: event.target.value }))}
                    className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-cyan-300/50"
                  />
                </label>
                <label className="space-y-2">
                  <span className="text-xs uppercase tracking-[0.24em] text-slate-400">Start date</span>
                  <input
                    type="date"
                    value={settingsForm.start_date}
                    onChange={(event) => setSettingsForm((current) => ({ ...current, start_date: event.target.value }))}
                    className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-cyan-300/50"
                  />
                </label>
                <label className="space-y-2">
                  <span className="text-xs uppercase tracking-[0.24em] text-slate-400">End date</span>
                  <input
                    type="date"
                    value={settingsForm.end_date}
                    onChange={(event) => setSettingsForm((current) => ({ ...current, end_date: event.target.value }))}
                    className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-cyan-300/50"
                  />
                </label>
              </div>
              <label className="mt-3 flex items-center gap-3 rounded-2xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-slate-200">
                <input
                  type="checkbox"
                  checked={settingsForm.is_active}
                  onChange={(event) => setSettingsForm((current) => ({ ...current, is_active: event.target.checked }))}
                />
                Tournament is active
              </label>
              <label className="mt-3 block space-y-2">
                <span className="text-xs uppercase tracking-[0.24em] text-slate-400">Description</span>
                <textarea
                  value={settingsForm.description}
                  onChange={(event) => setSettingsForm((current) => ({ ...current, description: event.target.value }))}
                  className="min-h-28 w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-cyan-300/50"
                />
              </label>
              <div className="mt-4 flex items-center gap-3">
                <NeonButton onClick={saveTournamentSettings} disabled={!settingsForm.name || !settingsForm.slug || !settingsForm.season}>
                  {settingsWorking ? "Saving..." : "Save settings"}
                </NeonButton>
                {message ? <p className="text-sm text-slate-300">{message}</p> : null}
              </div>
            </GlassCard>

            <GlassCard>
              <h3 className="text-lg font-semibold text-white">Access key manager</h3>
              <p className="mt-1 text-sm text-slate-400">Generate expiring keys, copy them once, and disable them when needed.</p>
              <div className="mt-4 grid gap-3 md:grid-cols-2">
                <label className="space-y-2">
                  <span className="text-xs uppercase tracking-[0.24em] text-slate-400">Role</span>
                  <select
                    value={keyForm.role}
                    onChange={(event) => setKeyForm((current) => ({ ...current, role: event.target.value as AccessKeyCreatePayload["role"] }))}
                    className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-cyan-300/50"
                  >
                    {accessRoleOptions.map((role) => (
                      <option key={role} value={role}>
                        {role}
                      </option>
                    ))}
                  </select>
                </label>
                <label className="space-y-2">
                  <span className="text-xs uppercase tracking-[0.24em] text-slate-400">Expiry</span>
                  <input
                    type="datetime-local"
                    value={toDateTimeLocal(keyForm.expires_at)}
                    onChange={(event) => setKeyForm((current) => ({ ...current, expires_at: event.target.value }))}
                    className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-cyan-300/50"
                  />
                </label>
                <label className="space-y-2">
                  <span className="text-xs uppercase tracking-[0.24em] text-slate-400">Access duration days</span>
                  <input
                    type="number"
                    min={1}
                    value={keyForm.access_duration_days ?? ""}
                    onChange={(event) =>
                      setKeyForm((current) => ({
                        ...current,
                        access_duration_days: event.target.value ? Number(event.target.value) : null,
                      }))
                    }
                    className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-cyan-300/50"
                  />
                </label>
                <label className="space-y-2">
                  <span className="text-xs uppercase tracking-[0.24em] text-slate-400">Max uses</span>
                  <input
                    type="number"
                    min={1}
                    value={keyForm.max_uses}
                    onChange={(event) => setKeyForm((current) => ({ ...current, max_uses: Number(event.target.value || 1) }))}
                    className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-cyan-300/50"
                  />
                </label>
              </div>
              <div className="mt-4 flex flex-wrap items-center gap-3">
                <NeonButton onClick={createAccessKey} disabled={!keyForm.tournament_id || !keyForm.expires_at}>
                  {accessKeyWorking ? "Generating..." : "Generate access key"}
                </NeonButton>
                {keyMessage ? <p className="text-sm text-slate-300">{keyMessage}</p> : null}
              </div>
              {generatedKey ? (
                <div className="mt-4 rounded-2xl border border-emerald-300/25 bg-emerald-400/10 px-4 py-3">
                  <p className="text-xs uppercase tracking-[0.24em] text-emerald-100/75">Generated key</p>
                  <div className="mt-2 flex flex-wrap items-center gap-3">
                    <code className="rounded-xl bg-slate-950/60 px-3 py-2 text-sm text-emerald-100">{generatedKey}</code>
                    <NeonButton className="px-3 py-2 text-xs" onClick={() => navigator.clipboard.writeText(generatedKey)}>
                      Copy
                    </NeonButton>
                  </div>
                </div>
              ) : null}
              <div className="mt-5 space-y-3">
                {accessKeys.map((accessKey) => (
                  <div key={accessKey.id} className="rounded-2xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-slate-300">
                    <div className="flex flex-wrap items-center justify-between gap-3">
                      <div>
                        <p className="font-semibold text-white">
                          {accessKey.role} • {accessKey.used_count}/{accessKey.max_uses} uses
                        </p>
                        <p className="mt-1 text-xs uppercase tracking-[0.2em] text-slate-400">
                          Expires {new Date(accessKey.expires_at).toLocaleString("en-IN")}
                        </p>
                      </div>
                      <div className="flex items-center gap-3">
                        <div className="rounded-full border border-white/10 bg-white/5 px-3 py-1 text-xs uppercase tracking-[0.2em] text-slate-300">
                          {accessKey.is_active ? "active" : "disabled"}
                        </div>
                        {accessKey.is_active ? (
                          <button
                            type="button"
                            onClick={() => void disableAccessKey(accessKey.id)}
                            className="rounded-2xl border border-rose-300/20 bg-rose-500/10 px-3 py-2 text-xs font-semibold text-rose-100 transition hover:border-rose-300/40"
                          >
                            {accessWorkingId === accessKey.id ? "Disabling..." : "Disable"}
                          </button>
                        ) : null}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </GlassCard>
          </div>

          <div className="grid gap-4 xl:grid-cols-2">
            <GlassCard>
              <h3 className="text-lg font-semibold text-white">Tournament access</h3>
              <p className="mt-1 text-sm text-slate-400">Review roles, expiry, and account status for users with access to this tournament.</p>
              <div className="mt-4 space-y-3">
                {accessRows.map((row) => (
                  <div key={row.id} className="rounded-2xl border border-white/10 bg-white/5 p-4">
                    <div className="grid gap-3 md:grid-cols-[1.2fr_0.8fr_0.9fr_auto]">
                      <div>
                        <p className="font-semibold text-white">{row.email || row.user_id}</p>
                        <p className="mt-1 text-xs uppercase tracking-[0.2em] text-slate-400">User access row</p>
                      </div>
                      <select
                        value={row.role}
                        onChange={(event) =>
                          setAccessRows((current) =>
                            current.map((entry) => (entry.id === row.id ? { ...entry, role: event.target.value as TournamentAccessRecord["role"] } : entry)),
                          )
                        }
                        className="rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-cyan-300/50"
                      >
                        {accessRoleOptions.map((role) => (
                          <option key={role} value={role}>
                            {role}
                          </option>
                        ))}
                      </select>
                      <input
                        type="datetime-local"
                        value={toDateTimeLocal(row.access_expires_at)}
                        onChange={(event) =>
                          setAccessRows((current) =>
                            current.map((entry) => (entry.id === row.id ? { ...entry, access_expires_at: toIsoOrNull(event.target.value) } : entry)),
                          )
                        }
                        className="rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-cyan-300/50"
                      />
                      <label className="flex items-center justify-center gap-2 rounded-2xl border border-white/10 bg-slate-950/50 px-4 py-3 text-sm text-slate-200">
                        <input
                          type="checkbox"
                          checked={row.is_active}
                          onChange={(event) =>
                            setAccessRows((current) =>
                              current.map((entry) => (entry.id === row.id ? { ...entry, is_active: event.target.checked } : entry)),
                            )
                          }
                        />
                        Active
                      </label>
                    </div>
                    <div className="mt-3 flex flex-wrap items-center gap-3">
                      <NeonButton className="px-3 py-2 text-xs" onClick={() => void saveAccessRow(row)}>
                        {accessWorkingId === row.id ? "Saving..." : "Save"}
                      </NeonButton>
                      <button
                        type="button"
                        onClick={() => void revokeAccess(row.id)}
                        className="rounded-2xl border border-rose-300/20 bg-rose-500/10 px-3 py-2 text-xs font-semibold text-rose-100 transition hover:border-rose-300/40"
                      >
                        {accessWorkingId === row.id ? "Revoking..." : "Revoke"}
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            </GlassCard>

            <div className="grid gap-4">
              <GlassCard>
                <h3 className="text-lg font-semibold text-white">Reference data</h3>
                <div className="mt-4 grid gap-4 xl:grid-cols-2">
                  <TeamForm onSaved={() => void load()} />
                  <VenueForm onSaved={() => void load()} />
                </div>
              </GlassCard>

              <div className="grid gap-4 xl:grid-cols-3">
                <GlassCard>
                  <h3 className="text-lg font-semibold text-white">Teams</h3>
                  <div className="mt-4 space-y-2">
                    {teams.map((team) => (
                      <div key={team.id} className="rounded-2xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-slate-300">
                        {team.team_name}
                      </div>
                    ))}
                  </div>
                </GlassCard>
                <GlassCard>
                  <h3 className="text-lg font-semibold text-white">Players</h3>
                  <div className="mt-4 space-y-2">
                    {players.slice(0, 12).map((player) => (
                      <div key={player.id} className="rounded-2xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-slate-300">
                        {player.player_name} • {player.role || "Player"}
                      </div>
                    ))}
                  </div>
                </GlassCard>
                <GlassCard>
                  <h3 className="text-lg font-semibold text-white">Venues</h3>
                  <div className="mt-4 space-y-2">
                    {venues.map((venue) => (
                      <div key={venue.id} className="rounded-2xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-slate-300">
                        {venue.venue_name} {venue.city ? `• ${venue.city}` : ""}
                      </div>
                    ))}
                  </div>
                </GlassCard>
              </div>
            </div>
          </div>
        </div>
      )}
    </AppShell>
  );
}
