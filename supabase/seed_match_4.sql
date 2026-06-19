begin;

-- Match 4: Gwalior Cheetahs vs Bhopal Leopards
-- Holkar Stadium, Indore | June 5, 2026 | 15:00:00
-- Gwalior Cheetahs won by 12 runs
-- Toss: Gwalior Cheetahs won and chose to bat
-- Player of the Match: Parth Chaudhary

insert into venues (id, venue_name, city, country, created_at)
values
  ('0b2128b7-a408-5c19-a6bf-cdd7c3ffa816', 'Holkar Stadium', 'Indore', 'India', '2026-06-05T15:00:00')
on conflict (venue_name) do update set
  city = excluded.city,
  country = excluded.country,
  created_at = excluded.created_at
;

-- Name corrections from the scorecard
update players set player_name = 'Anchit Singh Thakur' where id = '15915c22-37bb-5f32-8ffe-ebd791791ed5';
update players set player_name = 'Pranjul Puri' where id = 'a1a052ca-de3c-5bc8-811f-fb5b9c0ca160';

-- Player present in the scorecard but missing from seed.sql
insert into players (id, player_name, team_id, role, batting_style, bowling_style, created_at)
values
  ('f9e2b8a7-5d31-5a14-9f3e-24d240001111', 'Priyanshu Shukla', '89c8bea7-a025-55f9-8858-3b1220253648', 'All-rounder', 'Right-hand bat', 'Right-arm medium fast', '2026-06-05T15:00:00')
on conflict (id) do update set
  player_name = excluded.player_name,
  team_id = excluded.team_id,
  role = excluded.role,
  batting_style = excluded.batting_style,
  bowling_style = excluded.bowling_style
;

delete from reports where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000004';
delete from player_match_stats where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000004';
delete from matches where id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000004';

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
  '8a9b4c2d-1f2e-4d3c-8a9b-24d240000004',
  '2026-06-05',
  '2026',
  'MPt20',
  4,
  '89c8bea7-a025-55f9-8858-3b1220253648',
  '1303eab5-3486-5a12-ae69-0648c95de9f1',
  '0b2128b7-a408-5c19-a6bf-cdd7c3ffa816',
  '1303eab5-3486-5a12-ae69-0648c95de9f1',
  'bat',
  '1303eab5-3486-5a12-ae69-0648c95de9f1',
  '89c8bea7-a025-55f9-8858-3b1220253648',
  220,
  6,
  18.0,
  208,
  7,
  18.0,
  '1303eab5-3486-5a12-ae69-0648c95de9f1',
  '89c8bea7-a025-55f9-8858-3b1220253648',
  'runs',
  12,
  null,
  '3ea57ec9-dd66-5321-8669-ec767c467f61',
  'Aditya Birla Group MP League T20 Match 4 at Holkar Stadium, Indore. Gwalior Cheetahs won by 12 runs after posting 220/6 in 18 overs and restricting Bhopal Leopards to 208/7 in 18 overs. Toss: Gwalior Cheetahs won and chose to bat. Umpires: Rajesh Timane and Pushpendra Singh. Third umpire: Nikhil Menon. Reserve umpire: Raja Thakur. Scorer: Sunil Gupta. Referee: Manish Majithia. Ball type: Leather. Ball color: White. Phase: League.',
  '2026-06-05T15:00:00'
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
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000401', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000004', 'fcb64b16-e1c9-5810-8b52-311c6dc0dab0', '89c8bea7-a025-55f9-8858-3b1220253648', 1, 23, 13, 2, 2, 176.92, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-05T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000402', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000004', 'a652e185-c0c1-5361-9b36-14f575b0c276', '89c8bea7-a025-55f9-8858-3b1220253648', 2, 23, 11, 5, 0, 209.09, 0, 0, 0, 0, 0, 0, 0, 1, 1, '2026-06-05T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000403', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000004', '15915c22-37bb-5f32-8ffe-ebd791791ed5', '89c8bea7-a025-55f9-8858-3b1220253648', 3, 0, 3, 0, 0, 0.00, 0, 0, 0, 0, 0, 0, 1, 0, 0, '2026-06-05T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000404', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000004', 'bdfb9f70-ac54-5c21-b013-cc0c4ad44b45', '89c8bea7-a025-55f9-8858-3b1220253648', 4, 1, 3, 0, 0, 33.33, 0, 0, 0, 0, 0, 0, 1, 0, 0, '2026-06-05T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000405', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000004', 'df7c6a07-1ed8-5d13-b601-f52736f8d7d6', '89c8bea7-a025-55f9-8858-3b1220253648', 5, 14, 6, 3, 0, 233.33, 1.0, 0, 13, 0, 1, 13.00, 1, 0, 0, '2026-06-05T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000406', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000004', '175f38b8-8402-57e3-a9ac-296f10ea624a', '89c8bea7-a025-55f9-8858-3b1220253648', 6, 73, 41, 6, 4, 178.05, 3.0, 0, 37, 1, 8, 12.33, 0, 0, 0, '2026-06-05T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000407', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000004', 'a1a052ca-de3c-5bc8-811f-fb5b9c0ca160', '89c8bea7-a025-55f9-8858-3b1220253648', 7, 38, 21, 4, 2, 180.95, 4.0, 0, 36, 3, 8, 9.00, 1, 0, 0, '2026-06-05T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000408', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000004', 'e8d4cbc5-c3e3-5276-ac3b-a3c363258fb3', '89c8bea7-a025-55f9-8858-3b1220253648', 8, 16, 8, 0, 2, 200.00, 1.0, 0, 20, 0, 2, 20.00, 1, 0, 0, '2026-06-05T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000409', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000004', '332c919b-7eac-5035-8014-dcc5dce42255', '89c8bea7-a025-55f9-8858-3b1220253648', 9, 8, 4, 0, 1, 200.00, 3.0, 0, 47, 1, 4, 15.67, 0, 0, 0, '2026-06-05T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000410', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000004', 'f9e2b8a7-5d31-5a14-9f3e-24d240001111', '89c8bea7-a025-55f9-8858-3b1220253648', null, 0, 0, 0, 0, 0, 4.0, 0, 38, 0, 4, 9.50, 0, 0, 0, '2026-06-05T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000411', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000004', 'c2af755b-5e2b-552e-84d5-f15701bf9248', '89c8bea7-a025-55f9-8858-3b1220253648', null, 0, 0, 0, 0, 0, 2.0, 0, 29, 0, 2, 14.50, 0, 0, 0, '2026-06-05T15:00:00'),

  -- Gwalior Cheetahs batting + bowling/fielding
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000412', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000004', 'c07ce930-7239-56c7-a87c-8dfab62436c5', '1303eab5-3486-5a12-ae69-0648c95de9f1', 1, 35, 22, 3, 2, 159.09, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-05T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000413', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000004', '3ea57ec9-dd66-5321-8669-ec767c467f61', '1303eab5-3486-5a12-ae69-0648c95de9f1', 2, 107, 51, 9, 7, 209.80, 0, 0, 0, 0, 0, 0, 2, 0, 0, '2026-06-05T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000414', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000004', '3313c4ab-7f84-51a6-a9db-707f3b4f0983', '1303eab5-3486-5a12-ae69-0648c95de9f1', 3, 10, 15, 2, 0, 66.67, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-05T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000415', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000004', 'f6d907f4-f8bb-52aa-99ae-772bbf4b652a', '1303eab5-3486-5a12-ae69-0648c95de9f1', 4, 29, 15, 3, 1, 193.33, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-05T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000416', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000004', '8f502ba1-ed08-5dd7-b9a1-9eeafda52406', '1303eab5-3486-5a12-ae69-0648c95de9f1', 5, 14, 4, 0, 2, 350.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-05T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000417', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000004', '40c90b46-0444-56dd-a8db-9fc2cef21a1b', '1303eab5-3486-5a12-ae69-0648c95de9f1', 6, 0, 1, 0, 0, 0.00, 4.0, 0, 38, 1, 7, 9.50, 0, 0, 0, '2026-06-05T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000418', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000004', 'f772a481-aac3-5e96-bdee-6f6466852b92', '1303eab5-3486-5a12-ae69-0648c95de9f1', 7, 10, 3, 1, 1, 333.33, 1.0, 0, 8, 1, 1, 8.00, 1, 0, 0, '2026-06-05T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000419', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000004', 'b199ea13-ead3-59fd-8f86-530506d3227a', '1303eab5-3486-5a12-ae69-0648c95de9f1', null, 0, 0, 0, 0, 0, 4.0, 0, 55, 3, 10, 13.75, 0, 0, 0, '2026-06-05T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000420', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000004', 'd6b5b3f7-4583-59e6-89a1-9b9f5e883ba2', '1303eab5-3486-5a12-ae69-0648c95de9f1', null, 0, 0, 0, 0, 0, 3.0, 0, 27, 2, 11, 9.00, 2, 0, 0, '2026-06-05T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000421', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000004', '4f062956-019c-5a34-82e6-2b4508a34d17', '1303eab5-3486-5a12-ae69-0648c95de9f1', null, 0, 0, 0, 0, 0, 2.0, 0, 23, 0, 0, 11.50, 0, 0, 0, '2026-06-05T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000422', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000004', 'cfbc5a3c-7efa-5f50-b9a4-0bf3f2e2fa2a', '1303eab5-3486-5a12-ae69-0648c95de9f1', null, 0, 0, 0, 0, 0, 4.0, 0, 54, 0, 3, 13.50, 0, 0, 0, '2026-06-05T15:00:00');

commit;
