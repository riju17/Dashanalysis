begin;

create extension if not exists pgcrypto;

alter table if exists public.tournaments
  rename column tournament_name to name;

alter table if exists public.tournaments
  add column if not exists slug text,
  add column if not exists description text,
  add column if not exists logo_url text,
  add column if not exists is_active boolean not null default true,
  add column if not exists created_by uuid references auth.users (id);

update public.tournaments
set
  slug = coalesce(nullif(slug, ''), regexp_replace(lower(coalesce(name, 'tournament') || '-' || coalesce(season, 'season')), '[^a-z0-9]+', '-', 'g')),
  is_active = coalesce(is_active, true)
where slug is null or slug = '';

alter table public.tournaments
  alter column name set not null,
  alter column season set not null,
  alter column slug set not null,
  alter column created_at set default now();

create unique index if not exists tournaments_slug_key on public.tournaments (slug);
create index if not exists tournaments_is_active_idx on public.tournaments (is_active);

with default_tournament as (
  insert into public.tournaments (name, slug, season, description, is_active)
  values (
    'MPT20 2026',
    'mpt20-2026',
    '2026',
    'Default tournament created during the multi-tournament migration for existing MPT20 data.',
    true
  )
  on conflict (slug) do update
  set
    name = excluded.name,
    season = excluded.season,
    description = excluded.description,
    is_active = true
  returning id
)
select id from default_tournament
union all
select id from public.tournaments where slug = 'mpt20-2026'
limit 1;

alter table if exists public.teams
  add column if not exists tournament_id uuid references public.tournaments (id);
alter table if exists public.players
  add column if not exists tournament_id uuid references public.tournaments (id);
alter table if exists public.venues
  add column if not exists tournament_id uuid references public.tournaments (id);
alter table if exists public.matches
  add column if not exists tournament_id uuid references public.tournaments (id);
alter table if exists public.player_match_stats
  add column if not exists tournament_id uuid references public.tournaments (id);
alter table if exists public.reports
  add column if not exists tournament_id uuid references public.tournaments (id);
alter table if exists public.match_imports
  add column if not exists tournament_id uuid references public.tournaments (id);

with default_tournament as (
  select id
  from public.tournaments
  where slug = 'mpt20-2026'
  limit 1
)
update public.teams
set tournament_id = default_tournament.id
from default_tournament
where public.teams.tournament_id is null;

with default_tournament as (
  select id
  from public.tournaments
  where slug = 'mpt20-2026'
  limit 1
)
update public.players
set tournament_id = coalesce(public.players.tournament_id, public.teams.tournament_id, default_tournament.id)
from public.teams, default_tournament
where public.players.team_id = public.teams.id
  and public.players.tournament_id is null;

with default_tournament as (
  select id
  from public.tournaments
  where slug = 'mpt20-2026'
  limit 1
)
update public.venues
set tournament_id = default_tournament.id
from default_tournament
where public.venues.tournament_id is null;

with default_tournament as (
  select id
  from public.tournaments
  where slug = 'mpt20-2026'
  limit 1
)
update public.matches
set tournament_id = default_tournament.id
from default_tournament
where public.matches.tournament_id is null;

with match_tournaments as (
  select id, tournament_id
  from public.matches
  where tournament_id is not null
),
default_tournament as (
  select id
  from public.tournaments
  where slug = 'mpt20-2026'
  limit 1
)
update public.player_match_stats
set tournament_id = coalesce(match_tournaments.tournament_id, default_tournament.id)
from match_tournaments, default_tournament
where public.player_match_stats.match_id = match_tournaments.id
  and public.player_match_stats.tournament_id is null;

with match_tournaments as (
  select id, tournament_id
  from public.matches
  where tournament_id is not null
),
default_tournament as (
  select id
  from public.tournaments
  where slug = 'mpt20-2026'
  limit 1
)
update public.reports
set tournament_id = coalesce(match_tournaments.tournament_id, default_tournament.id)
from match_tournaments, default_tournament
where public.reports.match_id = match_tournaments.id
  and public.reports.tournament_id is null;

with match_tournaments as (
  select id, tournament_id
  from public.matches
  where tournament_id is not null
),
default_tournament as (
  select id
  from public.tournaments
  where slug = 'mpt20-2026'
  limit 1
)
update public.match_imports
set tournament_id = coalesce(match_tournaments.tournament_id, default_tournament.id)
from match_tournaments, default_tournament
where public.match_imports.match_id = match_tournaments.id
  and public.match_imports.tournament_id is null;

alter table public.teams
  alter column tournament_id set not null;
alter table public.players
  alter column tournament_id set not null;
alter table public.venues
  alter column tournament_id set not null;
alter table public.matches
  alter column tournament_id set not null;
alter table public.player_match_stats
  alter column tournament_id set not null;
alter table public.reports
  alter column tournament_id set not null;
alter table public.match_imports
  alter column tournament_id set not null;

create index if not exists teams_tournament_id_idx on public.teams (tournament_id);
create index if not exists players_tournament_id_idx on public.players (tournament_id);
create index if not exists venues_tournament_id_idx on public.venues (tournament_id);
create index if not exists matches_tournament_id_idx on public.matches (tournament_id);
create index if not exists player_match_stats_tournament_id_idx on public.player_match_stats (tournament_id);
create index if not exists reports_tournament_id_idx on public.reports (tournament_id);
create index if not exists match_imports_tournament_id_idx on public.match_imports (tournament_id);
create index if not exists players_tournament_team_idx on public.players (tournament_id, team_id);
create index if not exists matches_tournament_date_idx on public.matches (tournament_id, match_date desc, match_number desc);
create index if not exists player_match_stats_tournament_match_idx on public.player_match_stats (tournament_id, match_id, player_id);

alter table if exists public.teams
  drop constraint if exists teams_team_name_key;
alter table if exists public.venues
  drop constraint if exists venues_venue_name_key;

create unique index if not exists teams_tournament_name_uidx
  on public.teams (tournament_id, lower(team_name));
create unique index if not exists venues_tournament_name_uidx
  on public.venues (tournament_id, lower(venue_name));
create unique index if not exists players_tournament_team_name_uidx
  on public.players (tournament_id, team_id, lower(player_name));
create unique index if not exists matches_tournament_match_number_uidx
  on public.matches (tournament_id, match_number);

create table if not exists public.user_tournament_access (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  tournament_id uuid not null references public.tournaments (id) on delete cascade,
  role text not null check (role in ('owner', 'admin', 'analyst', 'viewer')),
  access_expires_at timestamptz,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (user_id, tournament_id)
);

create index if not exists user_tournament_access_user_idx
  on public.user_tournament_access (user_id, tournament_id);
create index if not exists user_tournament_access_active_idx
  on public.user_tournament_access (tournament_id, is_active, access_expires_at);

create table if not exists public.access_keys (
  id uuid primary key default gen_random_uuid(),
  key_hash text not null unique,
  tournament_id uuid not null references public.tournaments (id) on delete cascade,
  role text not null check (role in ('owner', 'admin', 'analyst', 'viewer')),
  expires_at timestamptz not null,
  access_duration_days integer,
  max_uses integer not null default 1 check (max_uses > 0),
  used_count integer not null default 0 check (used_count >= 0),
  is_active boolean not null default true,
  created_by uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now()
);

create index if not exists access_keys_tournament_idx
  on public.access_keys (tournament_id, is_active, expires_at);

create table if not exists public.access_key_redemptions (
  id uuid primary key default gen_random_uuid(),
  access_key_id uuid not null references public.access_keys (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  redeemed_at timestamptz not null default now(),
  unique (access_key_id, user_id)
);

create index if not exists access_key_redemptions_key_idx
  on public.access_key_redemptions (access_key_id, redeemed_at desc);

create table if not exists public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users (id) on delete set null,
  action text not null,
  tournament_id uuid references public.tournaments (id) on delete cascade,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists audit_logs_tournament_idx
  on public.audit_logs (tournament_id, created_at desc);
create index if not exists audit_logs_user_idx
  on public.audit_logs (user_id, created_at desc);

create or replace function public.has_active_tournament_access(
  target_tournament_id uuid,
  allowed_roles text[] default null
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.user_tournament_access uta
    where uta.user_id = auth.uid()
      and uta.tournament_id = target_tournament_id
      and uta.is_active = true
      and (uta.access_expires_at is null or uta.access_expires_at > now())
      and (allowed_roles is null or uta.role = any(allowed_roles))
  );
$$;

grant execute on function public.has_active_tournament_access(uuid, text[]) to authenticated;

alter view if exists public.team_summary_view set (security_invoker = on);
alter view if exists public.venue_summary_view set (security_invoker = on);
alter view if exists public.player_summary_view set (security_invoker = on);
alter view if exists public.toss_summary_view set (security_invoker = on);
alter view if exists public.head_to_head_view set (security_invoker = on);

alter table public.tournaments enable row level security;
alter table public.teams enable row level security;
alter table public.players enable row level security;
alter table public.venues enable row level security;
alter table public.matches enable row level security;
alter table public.player_match_stats enable row level security;
alter table public.reports enable row level security;
alter table public.match_imports enable row level security;
alter table public.user_tournament_access enable row level security;
alter table public.access_keys enable row level security;
alter table public.access_key_redemptions enable row level security;
alter table public.audit_logs enable row level security;

drop policy if exists tournaments_select_policy on public.tournaments;
create policy tournaments_select_policy
on public.tournaments
for select
to authenticated
using (
  public.has_active_tournament_access(id)
  or created_by = auth.uid()
);

drop policy if exists tournaments_insert_policy on public.tournaments;
create policy tournaments_insert_policy
on public.tournaments
for insert
to authenticated
with check (created_by = auth.uid());

drop policy if exists tournaments_update_policy on public.tournaments;
create policy tournaments_update_policy
on public.tournaments
for update
to authenticated
using (public.has_active_tournament_access(id, array['owner', 'admin']))
with check (public.has_active_tournament_access(id, array['owner', 'admin']));

drop policy if exists tournaments_delete_policy on public.tournaments;
create policy tournaments_delete_policy
on public.tournaments
for delete
to authenticated
using (public.has_active_tournament_access(id, array['owner']));

drop policy if exists teams_select_policy on public.teams;
create policy teams_select_policy on public.teams
for select to authenticated
using (public.has_active_tournament_access(tournament_id));

drop policy if exists teams_write_policy on public.teams;
create policy teams_write_policy on public.teams
for all to authenticated
using (public.has_active_tournament_access(tournament_id, array['owner', 'admin', 'analyst']))
with check (public.has_active_tournament_access(tournament_id, array['owner', 'admin', 'analyst']));

drop policy if exists players_select_policy on public.players;
create policy players_select_policy on public.players
for select to authenticated
using (public.has_active_tournament_access(tournament_id));

drop policy if exists players_write_policy on public.players;
create policy players_write_policy on public.players
for all to authenticated
using (public.has_active_tournament_access(tournament_id, array['owner', 'admin', 'analyst']))
with check (public.has_active_tournament_access(tournament_id, array['owner', 'admin', 'analyst']));

drop policy if exists venues_select_policy on public.venues;
create policy venues_select_policy on public.venues
for select to authenticated
using (public.has_active_tournament_access(tournament_id));

drop policy if exists venues_write_policy on public.venues;
create policy venues_write_policy on public.venues
for all to authenticated
using (public.has_active_tournament_access(tournament_id, array['owner', 'admin', 'analyst']))
with check (public.has_active_tournament_access(tournament_id, array['owner', 'admin', 'analyst']));

drop policy if exists matches_select_policy on public.matches;
create policy matches_select_policy on public.matches
for select to authenticated
using (public.has_active_tournament_access(tournament_id));

drop policy if exists matches_write_policy on public.matches;
create policy matches_write_policy on public.matches
for all to authenticated
using (public.has_active_tournament_access(tournament_id, array['owner', 'admin', 'analyst']))
with check (public.has_active_tournament_access(tournament_id, array['owner', 'admin', 'analyst']));

drop policy if exists player_match_stats_select_policy on public.player_match_stats;
create policy player_match_stats_select_policy on public.player_match_stats
for select to authenticated
using (public.has_active_tournament_access(tournament_id));

drop policy if exists player_match_stats_write_policy on public.player_match_stats;
create policy player_match_stats_write_policy on public.player_match_stats
for all to authenticated
using (public.has_active_tournament_access(tournament_id, array['owner', 'admin', 'analyst']))
with check (public.has_active_tournament_access(tournament_id, array['owner', 'admin', 'analyst']));

drop policy if exists reports_select_policy on public.reports;
create policy reports_select_policy on public.reports
for select to authenticated
using (public.has_active_tournament_access(tournament_id));

drop policy if exists reports_write_policy on public.reports;
create policy reports_write_policy on public.reports
for all to authenticated
using (public.has_active_tournament_access(tournament_id, array['owner', 'admin', 'analyst']))
with check (public.has_active_tournament_access(tournament_id, array['owner', 'admin', 'analyst']));

drop policy if exists match_imports_select_policy on public.match_imports;
create policy match_imports_select_policy on public.match_imports
for select to authenticated
using (public.has_active_tournament_access(tournament_id));

drop policy if exists match_imports_write_policy on public.match_imports;
create policy match_imports_write_policy on public.match_imports
for all to authenticated
using (public.has_active_tournament_access(tournament_id, array['owner', 'admin', 'analyst']))
with check (public.has_active_tournament_access(tournament_id, array['owner', 'admin', 'analyst']));

drop policy if exists user_tournament_access_select_policy on public.user_tournament_access;
create policy user_tournament_access_select_policy on public.user_tournament_access
for select to authenticated
using (
  user_id = auth.uid()
  or public.has_active_tournament_access(tournament_id, array['owner', 'admin'])
);

drop policy if exists user_tournament_access_write_policy on public.user_tournament_access;
create policy user_tournament_access_write_policy on public.user_tournament_access
for all to authenticated
using (public.has_active_tournament_access(tournament_id, array['owner', 'admin']))
with check (public.has_active_tournament_access(tournament_id, array['owner', 'admin']));

drop policy if exists access_keys_select_policy on public.access_keys;
create policy access_keys_select_policy on public.access_keys
for select to authenticated
using (public.has_active_tournament_access(tournament_id, array['owner', 'admin']));

drop policy if exists access_keys_write_policy on public.access_keys;
create policy access_keys_write_policy on public.access_keys
for all to authenticated
using (public.has_active_tournament_access(tournament_id, array['owner', 'admin']))
with check (public.has_active_tournament_access(tournament_id, array['owner', 'admin']));

drop policy if exists access_key_redemptions_select_policy on public.access_key_redemptions;
create policy access_key_redemptions_select_policy on public.access_key_redemptions
for select to authenticated
using (
  user_id = auth.uid()
  or exists (
    select 1
    from public.access_keys ak
    where ak.id = access_key_redemptions.access_key_id
      and public.has_active_tournament_access(ak.tournament_id, array['owner', 'admin'])
  )
);

drop policy if exists access_key_redemptions_insert_policy on public.access_key_redemptions;
create policy access_key_redemptions_insert_policy on public.access_key_redemptions
for insert to authenticated
with check (user_id = auth.uid());

drop policy if exists audit_logs_select_policy on public.audit_logs;
create policy audit_logs_select_policy on public.audit_logs
for select to authenticated
using (public.has_active_tournament_access(tournament_id, array['owner', 'admin']));

drop policy if exists audit_logs_insert_policy on public.audit_logs;
create policy audit_logs_insert_policy on public.audit_logs
for insert to authenticated
with check (
  user_id = auth.uid()
  or public.has_active_tournament_access(tournament_id, array['owner', 'admin', 'analyst'])
);

commit;
