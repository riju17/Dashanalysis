create extension if not exists pgcrypto;

create table if not exists teams (
  id uuid primary key default gen_random_uuid(),
  team_name text unique not null,
  short_name text,
  primary_color text,
  secondary_color text,
  accent_color text,
  logo_url text,
  created_at timestamp default now()
);

create table if not exists venues (
  id uuid primary key default gen_random_uuid(),
  venue_name text unique not null,
  city text,
  country text,
  created_at timestamp default now()
);

create table if not exists players (
  id uuid primary key default gen_random_uuid(),
  player_name text not null,
  team_id uuid references teams(id) on delete set null,
  role text,
  batting_style text,
  bowling_style text,
  created_at timestamp default now()
);

create table if not exists tournaments (
  id uuid primary key default gen_random_uuid(),
  tournament_name text,
  season text,
  start_date date,
  end_date date,
  created_at timestamp default now()
);

create table if not exists matches (
  id uuid primary key default gen_random_uuid(),
  match_date date,
  season text,
  tournament text,
  match_number int,
  team_a_id uuid references teams(id),
  team_b_id uuid references teams(id),
  venue_id uuid references venues(id),
  toss_winner_id uuid references teams(id),
  toss_decision text,
  bat_first_team_id uuid references teams(id),
  bowl_first_team_id uuid references teams(id),
  first_innings_score int,
  first_innings_wickets int,
  first_innings_overs numeric(4,1),
  second_innings_score int,
  second_innings_wickets int,
  second_innings_overs numeric(4,1),
  winner_id uuid references teams(id),
  loser_id uuid references teams(id),
  result_type text,
  margin_runs int,
  margin_wickets int,
  player_of_match_id uuid references players(id),
  notes text,
  created_at timestamp default now()
);

create table if not exists player_match_stats (
  id uuid primary key default gen_random_uuid(),
  match_id uuid references matches(id) on delete cascade,
  player_id uuid references players(id),
  team_id uuid references teams(id),
  batting_position int,
  runs int default 0,
  balls int default 0,
  fours int default 0,
  sixes int default 0,
  strike_rate numeric(6,2),
  overs numeric(4,1) default 0,
  maidens int default 0,
  runs_conceded int default 0,
  wickets int default 0,
  dot_balls int default 0,
  economy numeric(6,2),
  catches int default 0,
  runouts int default 0,
  stumpings int default 0,
  created_at timestamp default now()
);

create table if not exists reports (
  id uuid primary key default gen_random_uuid(),
  match_id uuid references matches(id) on delete cascade,
  report_title text,
  report_json jsonb,
  created_at timestamp default now()
);

create table if not exists match_imports (
  id uuid primary key default gen_random_uuid(),
  import_type text,
  raw_text text,
  parsed_json jsonb,
  confidence_score numeric(5,2),
  status text,
  created_at timestamp default now()
);

create index if not exists idx_matches_team_a_id on matches(team_a_id);
create index if not exists idx_matches_team_b_id on matches(team_b_id);
create index if not exists idx_matches_winner_id on matches(winner_id);
create index if not exists idx_matches_venue_id on matches(venue_id);
create index if not exists idx_matches_tournament on matches(tournament);
create index if not exists idx_matches_season on matches(season);
create index if not exists idx_player_match_stats_player_id on player_match_stats(player_id);
create index if not exists idx_player_match_stats_match_id on player_match_stats(match_id);
create index if not exists idx_player_match_stats_team_id on player_match_stats(team_id);

create or replace view team_summary_view as
with team_matches as (
  select
    t.id as team_id,
    t.team_name,
    m.*,
    case when m.winner_id = t.id then 1 else 0 end as win_flag,
    case when m.loser_id = t.id then 1 else 0 end as loss_flag,
    case when m.bat_first_team_id = t.id then 1 else 0 end as bat_first_flag,
    case when m.winner_id = t.id and m.bat_first_team_id = t.id then 1 else 0 end as bat_first_win_flag,
    case when m.bat_first_team_id <> t.id then 1 else 0 end as chase_flag,
    case when m.winner_id = t.id and m.bat_first_team_id <> t.id then 1 else 0 end as chase_win_flag,
    case when m.toss_winner_id = t.id then 1 else 0 end as toss_win_flag,
    case when m.toss_winner_id = t.id and m.winner_id = t.id then 1 else 0 end as wins_after_toss_flag
  from teams t
  left join matches m on m.team_a_id = t.id or m.team_b_id = t.id
)
select
  team_id,
  team_name,
  count(id) filter (where id is not null) as matches_played,
  count(id) filter (where win_flag = 1) as wins,
  count(id) filter (where loss_flag = 1) as losses,
  round((count(id) filter (where win_flag = 1) * 100.0) / nullif(count(id) filter (where id is not null), 0), 2) as win_percentage,
  count(id) filter (where bat_first_flag = 1) as bat_first_matches,
  count(id) filter (where bat_first_win_flag = 1) as bat_first_wins,
  round((count(id) filter (where bat_first_win_flag = 1) * 100.0) / nullif(count(id) filter (where bat_first_flag = 1), 0), 2) as bat_first_win_percentage,
  count(id) filter (where chase_flag = 1) as chase_matches,
  count(id) filter (where chase_win_flag = 1) as chase_wins,
  round((count(id) filter (where chase_win_flag = 1) * 100.0) / nullif(count(id) filter (where chase_flag = 1), 0), 2) as chase_win_percentage,
  count(id) filter (where toss_win_flag = 1) as toss_wins,
  count(id) filter (where wins_after_toss_flag = 1) as wins_after_toss,
  round((count(id) filter (where wins_after_toss_flag = 1) * 100.0) / nullif(count(id) filter (where toss_win_flag = 1), 0), 2) as toss_conversion_percentage,
  round(avg(first_innings_score) filter (where bat_first_flag = 1), 2) as average_score_batting_first,
  round(avg(second_innings_score) filter (where chase_flag = 1), 2) as average_score_chasing
from team_matches
group by team_id, team_name;

create or replace view venue_summary_view as
select
  v.id as venue_id,
  v.venue_name,
  count(m.id) as total_matches,
  round(avg(m.first_innings_score), 2) as average_first_innings_score,
  round(avg(m.second_innings_score), 2) as average_second_innings_score,
  round((count(m.id) filter (where m.winner_id = m.bat_first_team_id) * 100.0) / nullif(count(m.id), 0), 2) as bat_first_win_percentage,
  round((count(m.id) filter (where m.winner_id <> m.bat_first_team_id) * 100.0) / nullif(count(m.id), 0), 2) as chase_win_percentage,
  max(m.first_innings_score) as highest_score,
  max(m.second_innings_score) filter (where m.winner_id <> m.bat_first_team_id) as highest_successful_chase,
  min(m.first_innings_score) filter (where m.winner_id = m.bat_first_team_id) as lowest_defended_score,
  round(avg(m.first_innings_score) + 10, 2) as par_score,
  round(avg(m.first_innings_score) + 20, 2) as safe_score
from venues v
left join matches m on m.venue_id = v.id
group by v.id, v.venue_name;

create or replace view player_summary_view as
select
  p.id as player_id,
  p.player_name,
  p.team_id,
  count(ps.id) as matches_played,
  sum(ps.runs) as total_runs,
  sum(ps.balls) as total_balls,
  round((sum(ps.runs) * 100.0) / nullif(sum(ps.balls), 0), 2) as batting_strike_rate,
  round((sum(ps.runs) * 1.0) / nullif(count(ps.id), 0), 2) as average_runs_per_match,
  sum(ps.fours) as fours,
  sum(ps.sixes) as sixes,
  round((sum(ps.fours) + sum(ps.sixes)) * 100.0 / nullif(sum(ps.balls), 0), 2) as boundary_percentage,
  sum(ps.overs) as overs,
  sum(ps.wickets) as wickets,
  round((sum(ps.runs_conceded) * 1.0) / nullif(sum(ps.overs), 0), 2) as economy,
  round((sum(ps.dot_balls) * 100.0) / nullif(sum(ps.overs) * 6, 0), 2) as dot_ball_percentage,
  round((sum(ps.runs) + (sum(ps.runs) * 100.0 / nullif(sum(ps.balls), 0)) * 0.2 + sum(ps.fours) * 2 + sum(ps.sixes) * 3), 2) as batting_impact,
  round((sum(ps.wickets) * 25 + sum(ps.dot_balls) * 1.5 - (sum(ps.runs_conceded) * 1.0 / nullif(sum(ps.overs), 0)) * 3), 2) as bowling_impact,
  round((sum(ps.runs) + (sum(ps.runs) * 100.0 / nullif(sum(ps.balls), 0)) * 0.2 + sum(ps.fours) * 2 + sum(ps.sixes) * 3) +
        (sum(ps.wickets) * 25 + sum(ps.dot_balls) * 1.5 - (sum(ps.runs_conceded) * 1.0 / nullif(sum(ps.overs), 0)) * 3), 2) as all_rounder_index
from players p
left join player_match_stats ps on ps.player_id = p.id
group by p.id, p.player_name, p.team_id;

create or replace view toss_summary_view as
select
  t.id as team_id,
  t.team_name,
  count(m.id) filter (where m.toss_winner_id = t.id) as toss_wins,
  count(m.id) filter (where m.toss_winner_id = t.id and m.winner_id = t.id) as wins_after_toss,
  round((count(m.id) filter (where m.toss_winner_id = t.id and m.winner_id = t.id) * 100.0) / nullif(count(m.id) filter (where m.toss_winner_id = t.id), 0), 2) as toss_conversion_percentage,
  round((count(m.id) filter (where m.toss_winner_id = m.winner_id) * 100.0) / nullif(count(m.id), 0), 2) as toss_winner_match_win_percentage,
  round((count(m.id) filter (where m.toss_decision = 'bat' and m.winner_id = m.toss_winner_id) * 100.0) / nullif(count(m.id) filter (where m.toss_decision = 'bat'), 0), 2) as bat_decision_success_percentage,
  round((count(m.id) filter (where m.toss_decision = 'bowl' and m.winner_id = m.toss_winner_id) * 100.0) / nullif(count(m.id) filter (where m.toss_decision = 'bowl'), 0), 2) as bowl_decision_success_percentage
from teams t
left join matches m on m.toss_winner_id = t.id
group by t.id, t.team_name;

create or replace view head_to_head_view as
select
  least(m.team_a_id, m.team_b_id) as team_low_id,
  greatest(m.team_a_id, m.team_b_id) as team_high_id,
  count(*) as matches_played,
  count(*) filter (where m.winner_id = least(m.team_a_id, m.team_b_id)) as low_team_wins,
  count(*) filter (where m.winner_id = greatest(m.team_a_id, m.team_b_id)) as high_team_wins,
  round((count(*) filter (where m.winner_id = least(m.team_a_id, m.team_b_id)) * 100.0) / nullif(count(*), 0), 2) as low_team_win_percentage,
  round((count(*) filter (where m.winner_id = greatest(m.team_a_id, m.team_b_id)) * 100.0) / nullif(count(*), 0), 2) as high_team_win_percentage,
  round(avg(m.first_innings_score), 2) as average_first_innings_score
from matches m
group by least(m.team_a_id, m.team_b_id), greatest(m.team_a_id, m.team_b_id);
