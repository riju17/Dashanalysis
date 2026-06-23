"use client";

import { useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import type { AuthChangeEvent, Session } from "@supabase/supabase-js";
import { ArrowRight, KeyRound, LockKeyhole, LogOut, ShieldCheck, Trophy } from "lucide-react";
import { GlassCard } from "@/components/ui/GlassCard";
import { NeonButton } from "@/components/ui/NeonButton";
import { api } from "@/lib/api";
import { getSupabaseBrowserClient, hasSupabaseBrowserCredentials } from "@/lib/supabase-browser";
import { buildTournamentPath, clearStoredTournamentSlug, setStoredTournamentSlug } from "@/lib/tournament";
import type { TournamentRecord, UserAccessSummary } from "@/types/cricket";

type AuthMode = "signin" | "signup";

const initialTournamentForm = {
  name: "",
  slug: "",
  season: "",
  description: "",
};

export default function HomePage() {
  const router = useRouter();
  const localDevAuthEnabled = useMemo(() => process.env.NEXT_PUBLIC_ENABLE_LOCAL_DEV_AUTH === "true", []);
  const hasSupabaseCredentials = useMemo(() => hasSupabaseBrowserCredentials(), []);
  const localDevUserEmail = process.env.NEXT_PUBLIC_LOCAL_DEV_USER_EMAIL || "local-admin@statstrike.local";
  const supabase = useMemo(
    () => (localDevAuthEnabled || typeof window === "undefined" ? null : getSupabaseBrowserClient()),
    [localDevAuthEnabled],
  );
  const [authMode, setAuthMode] = useState<AuthMode>("signin");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [authWorking, setAuthWorking] = useState(false);
  const [sessionEmail, setSessionEmail] = useState<string | null>(null);
  const [authError, setAuthError] = useState("");
  const [tournaments, setTournaments] = useState<TournamentRecord[]>([]);
  const [accessSummary, setAccessSummary] = useState<UserAccessSummary | null>(null);
  const [loadingTournaments, setLoadingTournaments] = useState(true);
  const [accessKey, setAccessKey] = useState("");
  const [redeemWorking, setRedeemWorking] = useState(false);
  const [redeemMessage, setRedeemMessage] = useState("");
  const [createTournamentForm, setCreateTournamentForm] = useState(initialTournamentForm);
  const [createTournamentWorking, setCreateTournamentWorking] = useState(false);
  const [createTournamentMessage, setCreateTournamentMessage] = useState("");

  const accessByTournamentId = useMemo(() => {
    return new Map((accessSummary?.tournaments ?? []).map((entry) => [entry.tournament_id, entry]));
  }, [accessSummary]);

  const loadAccessibleTournaments = async () => {
    if (!supabase && !localDevAuthEnabled) {
      setLoadingTournaments(false);
      return;
    }

    setLoadingTournaments(true);
    setAuthError("");
    try {
      const [tournamentList, myAccess, sessionData] = await Promise.all([
        api.getTournaments(),
        api.getMyAccess(),
        supabase ? supabase.auth.getSession() : Promise.resolve({ data: { session: null } }),
      ]);

      setSessionEmail(sessionData.data.session?.user?.email ?? (localDevAuthEnabled ? localDevUserEmail : null));
      setTournaments(tournamentList);
      setAccessSummary(myAccess);
    } catch (error) {
      setTournaments([]);
      setAccessSummary(null);
      const message = error instanceof Error ? error.message : "Could not load tournaments.";
      setAuthError(message);
    } finally {
      setLoadingTournaments(false);
    }
  };

  useEffect(() => {
    if (!supabase && !localDevAuthEnabled) {
      setLoadingTournaments(false);
      return;
    }

    if (!supabase && localDevAuthEnabled) {
      setSessionEmail(localDevUserEmail);
      void loadAccessibleTournaments();
      return;
    }

    const bootstrapSession = async () => {
      const { data } = await supabase.auth.getSession();
      setSessionEmail(data.session?.user?.email ?? null);
      if (data.session) {
        void loadAccessibleTournaments();
      } else {
        setLoadingTournaments(false);
      }
    };

    void bootstrapSession();

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event: AuthChangeEvent, session: Session | null) => {
      setSessionEmail(session?.user?.email ?? null);
      if (session) {
        void loadAccessibleTournaments();
      } else {
        setTournaments([]);
        setAccessSummary(null);
        setLoadingTournaments(false);
      }
    });

    return () => subscription.unsubscribe();
  }, [supabase]);

  const submitAuth = async () => {
    if (localDevAuthEnabled && !supabase) {
      setSessionEmail(localDevUserEmail);
      void loadAccessibleTournaments();
      return;
    }
    if (!supabase) return;
    setAuthWorking(true);
    setAuthError("");
    try {
      if (authMode === "signin") {
        const { error } = await supabase.auth.signInWithPassword({ email, password });
        if (error) throw error;
      } else {
        const { error } = await supabase.auth.signUp({ email, password });
        if (error) throw error;
      }
    } catch (error) {
      setAuthError(error instanceof Error ? error.message : "Authentication failed.");
    } finally {
      setAuthWorking(false);
    }
  };

  const signOut = async () => {
    if (localDevAuthEnabled && !supabase) {
      clearStoredTournamentSlug();
      setRedeemMessage("");
      setCreateTournamentMessage("");
      setSessionEmail(localDevUserEmail);
      return;
    }
    if (!supabase) return;
    await supabase.auth.signOut();
    clearStoredTournamentSlug();
    setRedeemMessage("");
    setCreateTournamentMessage("");
  };

  const openTournament = (slug: string) => {
    setStoredTournamentSlug(slug);
    router.push(buildTournamentPath(slug, "/dashboard"));
  };

  const redeemTournamentKey = async () => {
    if (!sessionEmail) {
      setRedeemMessage("Sign in before redeeming an access key.");
      return;
    }

    setRedeemWorking(true);
    setRedeemMessage("");
    try {
      const result = await api.redeemAccessKey(accessKey.trim());
      setStoredTournamentSlug(result.tournament.slug);
      setRedeemMessage(`Access granted to ${result.tournament.name}.`);
      setAccessKey("");
      await loadAccessibleTournaments();
      router.push(buildTournamentPath(result.tournament.slug, "/dashboard"));
    } catch (error) {
      setRedeemMessage(error instanceof Error ? error.message : "Could not redeem this access key.");
    } finally {
      setRedeemWorking(false);
    }
  };

  const createTournament = async () => {
    setCreateTournamentWorking(true);
    setCreateTournamentMessage("");
    try {
      const created = await api.createTournament({
        name: createTournamentForm.name.trim(),
        slug: createTournamentForm.slug.trim(),
        season: createTournamentForm.season.trim(),
        description: createTournamentForm.description.trim() || null,
      });
      setCreateTournamentMessage(`Tournament ${created.name} created.`);
      setCreateTournamentForm(initialTournamentForm);
      await loadAccessibleTournaments();
    } catch (error) {
      setCreateTournamentMessage(error instanceof Error ? error.message : "Could not create tournament.");
    } finally {
      setCreateTournamentWorking(false);
    }
  };

  return (
    <div className="min-h-screen bg-[radial-gradient(circle_at_top,rgba(56,189,248,0.18),transparent_32%),radial-gradient(circle_at_bottom_right,rgba(99,102,241,0.18),transparent_30%),linear-gradient(180deg,#020617,#0f172a)] px-4 py-6 text-white md:px-8">
      <div className="mx-auto max-w-7xl space-y-6">
        {!localDevAuthEnabled && !hasSupabaseCredentials ? (
          <GlassCard className="border-red-400/35 bg-red-500/10 p-5">
            <p className="text-xs uppercase tracking-[0.28em] text-red-200">Configuration Required</p>
            <h2 className="mt-2 text-xl font-semibold text-white">Supabase public credentials are missing.</h2>
            <p className="mt-3 text-sm text-red-100/90">
              Set <code className="rounded bg-black/20 px-1 py-0.5">NEXT_PUBLIC_SUPABASE_URL</code> and{" "}
              <code className="rounded bg-black/20 px-1 py-0.5">NEXT_PUBLIC_SUPABASE_ANON_KEY</code> in this deployment,
              then redeploy the frontend.
            </p>
          </GlassCard>
        ) : null}

        <GlassCard className="overflow-hidden border-cyan-300/15 bg-white/5 p-8 md:p-10">
          <div className="grid gap-8 lg:grid-cols-[1.2fr_0.8fr]">
            <div>
              <p className="text-xs uppercase tracking-[0.45em] text-cyan-300/80">StatStrike Multi-Tournament Control Room</p>
              <h1 className="mt-4 max-w-3xl text-4xl font-semibold leading-tight md:text-6xl">
                Secure tournament intelligence for every league you operate.
              </h1>
              <p className="mt-5 max-w-2xl text-base text-slate-300 md:text-lg">
                Sign in, redeem tournament access, and enter a tournament-specific analytics workspace with isolated teams, players, matches, reports, and admin controls.
              </p>
              <div className="mt-8 grid gap-3 sm:grid-cols-3">
                {[
                  ["Tournament-scoped data", "Dashboards and reports run inside one selected tournament."],
                  ["Role-based access", "Viewer, analyst, admin, and owner permissions are enforced server-side."],
                  ["Time-bounded keys", "Admins can issue expiring access keys without exposing raw secrets in the database."],
                ].map(([headline, text]) => (
                  <GlassCard key={headline} className="p-4">
                    <p className="text-lg font-semibold text-white">{headline}</p>
                    <p className="mt-2 text-sm text-slate-400">{text}</p>
                  </GlassCard>
                ))}
              </div>
            </div>

            <div className="grid gap-4">
              <GlassCard className="space-y-4">
                <div className="flex items-center justify-between gap-3">
                  <div>
                    <p className="text-xs uppercase tracking-[0.28em] text-slate-400">Authentication</p>
                    <h2 className="mt-2 text-xl font-semibold text-white">
                      {sessionEmail ? "Signed in" : authMode === "signin" ? "Sign in" : "Create account"}
                    </h2>
                  </div>
                  {sessionEmail ? (
                    <button
                      type="button"
                      onClick={signOut}
                      className="rounded-2xl border border-white/10 bg-white/5 p-2 text-slate-200 transition hover:border-cyan-300/35 hover:text-white"
                    >
                      <LogOut className="h-4 w-4" />
                    </button>
                  ) : null}
                </div>

                {sessionEmail ? (
                  <div className="rounded-2xl border border-emerald-300/20 bg-emerald-400/10 px-4 py-3 text-sm text-emerald-100">
                    Signed in as {sessionEmail}
                    {localDevAuthEnabled && !supabase ? " (local development owner session)" : ""}
                  </div>
                ) : (
                  <>
                    <div className="grid gap-3">
                      <label className="space-y-2">
                        <span className="text-xs uppercase tracking-[0.24em] text-slate-400">Email</span>
                        <input
                          value={email}
                          onChange={(event) => setEmail(event.target.value)}
                          className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-cyan-300/50"
                          placeholder="analyst@league.com"
                        />
                      </label>
                      <label className="space-y-2">
                        <span className="text-xs uppercase tracking-[0.24em] text-slate-400">Password</span>
                        <input
                          type="password"
                          value={password}
                          onChange={(event) => setPassword(event.target.value)}
                          className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-cyan-300/50"
                          placeholder="Minimum 6 characters"
                        />
                      </label>
                    </div>

                    <div className="flex flex-wrap gap-2">
                      <button
                        type="button"
                        onClick={() => setAuthMode("signin")}
                        className={`rounded-2xl border px-4 py-2 text-sm font-semibold transition ${
                          authMode === "signin"
                            ? "border-cyan-300/40 bg-cyan-400/15 text-cyan-100"
                            : "border-white/10 bg-white/5 text-slate-300 hover:text-white"
                        }`}
                      >
                        Sign in
                      </button>
                      <button
                        type="button"
                        onClick={() => setAuthMode("signup")}
                        className={`rounded-2xl border px-4 py-2 text-sm font-semibold transition ${
                          authMode === "signup"
                            ? "border-violet-300/40 bg-violet-400/15 text-violet-100"
                            : "border-white/10 bg-white/5 text-slate-300 hover:text-white"
                        }`}
                      >
                        Create account
                      </button>
                    </div>

                    <NeonButton onClick={submitAuth} className="w-full justify-center" disabled={!email || !password}>
                      <LockKeyhole className="h-4 w-4" />
                      {authWorking ? "Working..." : authMode === "signin" ? "Sign in" : "Create account"}
                    </NeonButton>
                  </>
                )}

                {authError ? <p className="text-sm text-rose-200">{authError}</p> : null}
              </GlassCard>

              <GlassCard className="space-y-4">
                <div>
                  <p className="text-xs uppercase tracking-[0.28em] text-slate-400">Access key redemption</p>
                  <h2 className="mt-2 text-xl font-semibold text-white">Join a tournament</h2>
                </div>
                <label className="space-y-2">
                  <span className="text-xs uppercase tracking-[0.24em] text-slate-400">Access key</span>
                  <input
                    value={accessKey}
                    onChange={(event) => setAccessKey(event.target.value.toUpperCase())}
                    className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-cyan-300/50"
                    placeholder="STAT-MPT20-2026-XXXX-XXXX"
                  />
                </label>
                <NeonButton onClick={redeemTournamentKey} className="w-full justify-center" disabled={!accessKey.trim()}>
                  <KeyRound className="h-4 w-4" />
                  {redeemWorking ? "Redeeming..." : "Redeem access key"}
                </NeonButton>
                {redeemMessage ? <p className="text-sm text-slate-300">{redeemMessage}</p> : null}
              </GlassCard>
            </div>
          </div>
        </GlassCard>

        <div className="grid gap-6 lg:grid-cols-[1.15fr_0.85fr]">
          <GlassCard className="space-y-4">
            <div className="flex items-center justify-between gap-3">
              <div>
                <p className="text-xs uppercase tracking-[0.28em] text-slate-400">Accessible tournaments</p>
                <h2 className="mt-2 text-2xl font-semibold text-white">Choose your workspace</h2>
              </div>
              <button
                type="button"
                onClick={() => void loadAccessibleTournaments()}
                className="rounded-2xl border border-white/10 bg-white/5 px-4 py-2 text-sm font-semibold text-slate-200 transition hover:border-cyan-300/35 hover:text-white"
              >
                Reload
              </button>
            </div>

            {!sessionEmail ? (
              <p className="rounded-2xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-slate-300">
                Sign in first to load the tournaments available to your account.
              </p>
            ) : loadingTournaments ? (
              <p className="rounded-2xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-slate-300">Loading tournaments...</p>
            ) : tournaments.length === 0 ? (
              <p className="rounded-2xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-slate-300">
                No tournament access is active on this account yet. Redeem an access key or create a tournament if you are a platform owner.
              </p>
            ) : (
              <div className="grid gap-4">
                {tournaments.map((tournament) => {
                  const access = accessByTournamentId.get(tournament.id);
                  return (
                    <button
                      key={tournament.id}
                      type="button"
                      onClick={() => openTournament(tournament.slug)}
                      className="rounded-3xl border border-white/10 bg-white/5 p-5 text-left transition hover:border-cyan-300/35 hover:bg-white/10"
                    >
                      <div className="flex flex-wrap items-start justify-between gap-4">
                        <div>
                          <div className="flex items-center gap-2 text-cyan-200">
                            <Trophy className="h-4 w-4" />
                            <span className="text-xs uppercase tracking-[0.28em]">{tournament.season}</span>
                          </div>
                          <h3 className="mt-3 text-2xl font-semibold text-white">{tournament.name}</h3>
                          <p className="mt-2 text-sm text-slate-400">{tournament.description || "Tournament analytics workspace."}</p>
                        </div>
                        <div className="text-right">
                          <div className="rounded-full border border-white/10 bg-white/5 px-3 py-1 text-xs uppercase tracking-[0.22em] text-slate-300">
                            {access?.role || "access granted"}
                          </div>
                          {access?.access_expires_at ? (
                            <p className="mt-2 text-xs text-slate-400">
                              Expires {new Date(access.access_expires_at).toLocaleString("en-IN")}
                            </p>
                          ) : (
                            <p className="mt-2 text-xs text-slate-400">No expiry set</p>
                          )}
                        </div>
                      </div>
                      <div className="mt-5 flex items-center gap-2 text-sm font-semibold text-cyan-200">
                        Open tournament <ArrowRight className="h-4 w-4" />
                      </div>
                    </button>
                  );
                })}
              </div>
            )}
          </GlassCard>

          <GlassCard className="space-y-4">
            <div>
              <p className="text-xs uppercase tracking-[0.28em] text-slate-400">Platform owner tools</p>
              <h2 className="mt-2 text-2xl font-semibold text-white">Create tournament</h2>
              <p className="mt-2 text-sm text-slate-400">
                This section succeeds only for platform owners configured on the backend. Other users will receive a permission error.
              </p>
            </div>

            <div className="grid gap-3">
              <label className="space-y-2">
                <span className="text-xs uppercase tracking-[0.24em] text-slate-400">Tournament name</span>
                <input
                  value={createTournamentForm.name}
                  onChange={(event) => setCreateTournamentForm((current) => ({ ...current, name: event.target.value }))}
                  className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-cyan-300/50"
                  placeholder="MPT20 2026"
                />
              </label>
              <label className="space-y-2">
                <span className="text-xs uppercase tracking-[0.24em] text-slate-400">Slug</span>
                <input
                  value={createTournamentForm.slug}
                  onChange={(event) => setCreateTournamentForm((current) => ({ ...current, slug: event.target.value }))}
                  className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-cyan-300/50"
                  placeholder="mpt20-2026"
                />
              </label>
              <label className="space-y-2">
                <span className="text-xs uppercase tracking-[0.24em] text-slate-400">Season</span>
                <input
                  value={createTournamentForm.season}
                  onChange={(event) => setCreateTournamentForm((current) => ({ ...current, season: event.target.value }))}
                  className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-cyan-300/50"
                  placeholder="2026"
                />
              </label>
              <label className="space-y-2">
                <span className="text-xs uppercase tracking-[0.24em] text-slate-400">Description</span>
                <textarea
                  value={createTournamentForm.description}
                  onChange={(event) => setCreateTournamentForm((current) => ({ ...current, description: event.target.value }))}
                  className="min-h-28 w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-cyan-300/50"
                  placeholder="Short tournament description"
                />
              </label>
            </div>

            <NeonButton
              onClick={createTournament}
              className="w-full justify-center"
              disabled={!createTournamentForm.name || !createTournamentForm.slug || !createTournamentForm.season}
            >
              <ShieldCheck className="h-4 w-4" />
              {createTournamentWorking ? "Creating..." : "Create tournament"}
            </NeonButton>

            {createTournamentMessage ? <p className="text-sm text-slate-300">{createTournamentMessage}</p> : null}
          </GlassCard>
        </div>
      </div>
    </div>
  );
}
