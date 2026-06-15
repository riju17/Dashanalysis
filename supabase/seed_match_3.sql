begin;

-- Match 3: Bhopal Leopards vs Indore Pink Panthers
-- Holkar Stadium, Indore | June 4, 2026 | 19:30:00
-- Bhopal Leopards won by 27 runs
-- Toss: Bhopal Leopards won and chose to bat
-- Player of the Match: Pawan Nirwani

insert into venues (id, venue_name, city, country, created_at)
values
  ('0b2128b7-a408-5c19-a6bf-cdd7c3ffa816', 'Holkar Stadium', 'Indore', 'India', '2026-06-04T19:30:00')
on conflict (venue_name) do update set
  city = excluded.city,
  country = excluded.country,
  created_at = excluded.created_at
;

-- Name corrections from the scorecard
update players set player_name = 'Anchit Singh Thakur' where id = '15915c22-37bb-5f32-8ffe-ebd791791ed5';
update players set player_name = 'Atharv Joshi' where id = 'e934d378-43e4-5740-a2a1-abeda43b917e';
update players set player_name = 'Siddarth Patidar' where id = '21662ce5-2368-571f-8d64-26d735145aa5';
update players set player_name = 'Pranjul Puri' where id = 'a1a052ca-de3c-5bc8-811f-fb5b9c0ca160';

-- Player present in the scorecard but missing from seed.sql
insert into players (id, player_name, team_id, role, batting_style, bowling_style, created_at)
values
  ('f9e2b8a7-5d31-5a14-9f3e-24d240001111', 'Priyanshu Shukla', '89c8bea7-a025-55f9-8858-3b1220253648', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-06-04T19:30:00')
on conflict (id) do update set
  player_name = excluded.player_name,
  team_id = excluded.team_id,
  role = excluded.role,
  batting_style = excluded.batting_style,
  bowling_style = excluded.bowling_style
;

delete from reports where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000003';
delete from player_match_stats where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000003';
delete from matches where id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000003';

insert into matches (
  id,
  match_date,
  season,
  tournament,
  match_number,
  team_a_id,
  team_b_id,
  venue_id,
  toss_winner_id,
  toss_decision,
  bat_first_team_id,
  bowl_first_team_id,
  first_innings_score,
  first_innings_wickets,
  first_innings_overs,
  second_innings_score,
  second_innings_wickets,
  second_innings_overs,
  winner_id,
  loser_id,
  result_type,
  margin_runs,
  margin_wickets,
  player_of_match_id,
  notes,
  created_at
)
values (
  '8a9b4c2d-1f2e-4d3c-8a9b-24d240000003',
  '2026-06-04',
  '2026',
  'MPt20',
  3,
  '89c8bea7-a025-55f9-8858-3b1220253648',
  '582e73b3-b982-5677-b88b-d940deb2e79c',
  '0b2128b7-a408-5c19-a6bf-cdd7c3ffa816',
  '89c8bea7-a025-55f9-8858-3b1220253648',
  'bat',
  '89c8bea7-a025-55f9-8858-3b1220253648',
  '582e73b3-b982-5677-b88b-d940deb2e79c',
  174,
  10,
  20.0,
  147,
  10,
  18.5,
  '89c8bea7-a025-55f9-8858-3b1220253648',
  '582e73b3-b982-5677-b88b-d940deb2e79c',
  'runs',
  27,
  null,
  '175f38b8-8402-57e3-a9ac-296f10ea624a',
  'Aditya Birla Group MP League T20 Match 3 at Holkar Stadium, Indore. Bhopal Leopards won by 27 runs after posting 174 all out in 20 overs and bowling out Indore Pink Panthers for 147 in 18.5 overs. Toss: Bhopal Leopards won and chose to bat. Umpires: Nikhil Patwardhan and Rajesh Timane. Third umpire: Manish Jain. Reserve umpire: Jitendra Gupta. Scorer: Dattatraya Varat. Referee: Sanjeev Rao. Ball type: Leather. Ball color: White. Phase: League.',
  '2026-06-04T19:30:00'
);

insert into player_match_stats (
  id,
  match_id,
  player_id,
  team_id,
  batting_position,
  runs,
  balls,
  fours,
  sixes,
  strike_rate,
  overs,
  maidens,
  runs_conceded,
  wickets,
  dot_balls,
  economy,
  catches,
  runouts,
  stumpings,
  created_at
)
values
  -- Bhopal Leopards batting + bowling/fielding
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000301', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000003', 'fcb64b16-e1c9-5810-8b52-311c6dc0dab0', '89c8bea7-a025-55f9-8858-3b1220253648', 1, 39, 29, 6, 1, 134.48, 0, 0, 0, 0, 0, 0, 1, 0, 0, '2026-06-04T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000302', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000003', 'a652e185-c0c1-5361-9b36-14f575b0c276', '89c8bea7-a025-55f9-8858-3b1220253648', 2, 21, 13, 4, 0, 161.54, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-04T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000303', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000003', 'bdfb9f70-ac54-5c21-b013-cc0c4ad44b45', '89c8bea7-a025-55f9-8858-3b1220253648', 3, 26, 20, 2, 0, 130.00, 0, 0, 0, 0, 0, 0, 1, 0, 0, '2026-06-04T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000304', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000003', 'df7c6a07-1ed8-5d13-b601-f52736f8d7d6', '89c8bea7-a025-55f9-8858-3b1220253648', 4, 44, 29, 4, 2, 151.72, 3.0, 0, 24, 2, 9, 8.00, 0, 0, 0, '2026-06-04T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000305', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000003', '175f38b8-8402-57e3-a9ac-296f10ea624a', '89c8bea7-a025-55f9-8858-3b1220253648', 5, 6, 5, 1, 0, 120.00, 4.0, 0, 21, 4, 13, 5.25, 1, 0, 0, '2026-06-04T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000306', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000003', '15915c22-37bb-5f32-8ffe-ebd791791ed5', '89c8bea7-a025-55f9-8858-3b1220253648', 6, 11, 11, 1, 0, 100.00, 0, 0, 0, 0, 0, 0, 1, 0, 0, '2026-06-04T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000307', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000003', 'a1a052ca-de3c-5bc8-811f-fb5b9c0ca160', '89c8bea7-a025-55f9-8858-3b1220253648', 7, 9, 8, 1, 0, 112.50, 0, 0, 0, 0, 0, 0, 1, 0, 0, '2026-06-04T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000308', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000003', 'e8d4cbc5-c3e3-5276-ac3b-a3c363258fb3', '89c8bea7-a025-55f9-8858-3b1220253648', 8, 4, 2, 1, 0, 200.00, 4.0, 0, 23, 2, 8, 5.75, 2, 0, 0, '2026-06-04T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000309', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000003', '332c919b-7eac-5035-8014-dcc5dce42255', '89c8bea7-a025-55f9-8858-3b1220253648', 9, 0, 1, 0, 0, 0.00, 2.0, 0, 14, 0, 4, 7.00, 1, 0, 0, '2026-06-04T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000310', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000003', 'eb5862bd-322f-583b-a91a-728e1aa1d5ba', '89c8bea7-a025-55f9-8858-3b1220253648', 10, 0, 3, 0, 0, 0.00, 2.0, 0, 21, 0, 2, 10.50, 0, 0, 0, '2026-06-04T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000311', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000003', 'f9e2b8a7-5d31-5a14-9f3e-24d240001111', '89c8bea7-a025-55f9-8858-3b1220253648', 11, 0, 1, 0, 0, 0.00, 3.5, 0, 34, 2, 8, 9.71, 0, 0, 0, '2026-06-04T19:30:00'),

  -- Indore Pink Panthers batting + bowling/fielding
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000312', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000003', 'e934d378-43e4-5740-a2a1-abeda43b917e', '582e73b3-b982-5677-b88b-d940deb2e79c', 1, 18, 15, 3, 0, 120.00, 0, 0, 0, 0, 0, 0, 1, 1, 0, '2026-06-04T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000313', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000003', '21662ce5-2368-571f-8d64-26d735145aa5', '582e73b3-b982-5677-b88b-d940deb2e79c', 2, 6, 5, 1, 0, 120.00, 0, 0, 0, 0, 0, 0, 3, 0, 0, '2026-06-04T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000314', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000003', 'b1507fce-9244-5c38-bf11-cfc4aa6461d8', '582e73b3-b982-5677-b88b-d940deb2e79c', 3, 0, 1, 0, 0, 0.00, 0, 0, 0, 0, 0, 0, 1, 0, 0, '2026-06-04T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000315', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000003', 'f56a747c-cd41-5456-ab5d-60a273526bf4', '582e73b3-b982-5677-b88b-d940deb2e79c', 4, 1, 3, 0, 0, 33.33, 1.0, 0, 10, 0, 2, 10.00, 0, 0, 0, '2026-06-04T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000316', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000003', '931345fe-8b9c-57fd-bb11-04cbf011a5c6', '582e73b3-b982-5677-b88b-d940deb2e79c', 5, 10, 12, 0, 0, 83.33, 2.0, 0, 18, 1, 4, 9.00, 0, 0, 0, '2026-06-04T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000317', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000003', '9b8ce6e3-bb3b-56d0-8930-9c503e517e4d', '582e73b3-b982-5677-b88b-d940deb2e79c', 6, 15, 9, 2, 1, 166.67, 4.0, 0, 27, 2, 11, 6.75, 1, 0, 0, '2026-06-04T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000318', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000003', 'd4a25b3f-0333-564f-bc8b-8e57a3b41a99', '582e73b3-b982-5677-b88b-d940deb2e79c', 7, 43, 34, 2, 3, 126.47, 1.0, 0, 13, 0, 1, 13.00, 0, 0, 0, '2026-06-04T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000319', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000003', '64e22a56-f1ff-59a6-91b3-6b88e9d0cdeb', '582e73b3-b982-5677-b88b-d940deb2e79c', 8, 38, 29, 2, 2, 131.03, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-04T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000320', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000003', '8c118ea4-e9c1-5620-a56e-885ee57dbd4a', '582e73b3-b982-5677-b88b-d940deb2e79c', 9, 0, 1, 0, 0, 0.00, 4.0, 0, 42, 1, 8, 10.50, 3, 0, 0, '2026-06-04T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000321', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000003', 'd52da864-1c4f-53e1-b7b4-94fc1879d773', '582e73b3-b982-5677-b88b-d940deb2e79c', 10, 1, 3, 0, 0, 33.33, 4.0, 0, 32, 2, 5, 8.00, 0, 0, 0, '2026-06-04T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000322', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000003', 'c8d836da-3c55-5fa1-b68a-2989f45aab44', '582e73b3-b982-5677-b88b-d940deb2e79c', 11, 1, 2, 0, 0, 50.00, 4.0, 0, 26, 3, 12, 6.50, 0, 0, 0, '2026-06-04T19:30:00');

commit;
