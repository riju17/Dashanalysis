begin;

-- Match 19: Gwalior Cheetahs vs Chambal Ghariyals
-- Holkar Stadium, Indore | June 11, 2026 | 19:30:00
-- Chambal Ghariyals won by 3 wickets with 3 balls remaining
-- Toss: Gwalior Cheetahs won and chose to bat
-- Player of the Match: Ankush Singh

insert into venues (id, venue_name, city, country, created_at)
values
  ('0b2128b7-a408-5c19-a6bf-cdd7c3ffa816', 'Holkar Stadium', 'Indore', 'India', '2026-06-11T19:30:00')
on conflict (venue_name) do update set
  city = excluded.city,
  country = excluded.country,
  created_at = excluded.created_at
;

-- Name corrections from the scorecard
update players set player_name = 'Apurve Dwivedi' where id = '1a2a261a-eab8-5945-805f-ab56e7ee4265';
update players set player_name = 'Rohit Gupta' where id = '810363ec-7c2f-59ec-b81f-071000960904';
update players set player_name = 'Aman Bhadoriya' where id = 'bfd18390-21b9-5c61-8765-373789c7f2f2';
update players set player_name = 'Aavesh Khan' where id = '4beced42-4683-5cd7-a3d4-eafb40a735c1';
update players set player_name = 'Mayur Patel' where id = '661efd97-7f59-5db8-a791-fa9a2779d9cc';

-- Player present in Match 19 scorecard but missing from seed.sql
insert into players (id, player_name, team_id, role, batting_style, bowling_style, created_at)
values
  ('f9e2b8a7-5d31-5a14-9f3e-24d240001919', 'Sandeep Singh', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-06-11T19:30:00')
on conflict (id) do update set
  player_name = excluded.player_name,
  team_id = excluded.team_id,
  role = excluded.role,
  batting_style = excluded.batting_style,
  bowling_style = excluded.bowling_style
;

delete from reports where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000019';
delete from player_match_stats where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000019';
delete from matches where id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000019';

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
  '8a9b4c2d-1f2e-4d3c-8a9b-24d240000019',
  '2026-06-11',
  '2026',
  'MPt20',
  19,
  '1303eab5-3486-5a12-ae69-0648c95de9f1',   -- team_a/home: Gwalior Cheetahs
  '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e',   -- team_b/away: Chambal Ghariyals
  '0b2128b7-a408-5c19-a6bf-cdd7c3ffa816',   -- Holkar Stadium
  '1303eab5-3486-5a12-ae69-0648c95de9f1',   -- toss winner: Gwalior Cheetahs
  'bat',
  '1303eab5-3486-5a12-ae69-0648c95de9f1',   -- bat first: Gwalior Cheetahs
  '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e',   -- bowl first: Chambal Ghariyals
  257,
  6,
  20,
  258,
  7,
  19.3,
  '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e',   -- winner: Chambal Ghariyals
  '1303eab5-3486-5a12-ae69-0648c95de9f1',   -- loser: Gwalior Cheetahs
  'wickets',
  null,
  3,
  'c3abcf6b-af87-50dd-b6cd-bef5ba923ff4',   -- Player of the Match: Ankush Singh
  'Match 19 at Holkar Stadium, Indore. Chambal Ghariyals won by 3 wickets with 3 balls remaining after chasing 258/7 in 19.3 overs against Gwalior Cheetahs 257/6 in 20 overs. Toss: Gwalior Cheetahs won and chose to bat. Umpires: Abhishek Tomar and Nikhil Patwardhan. Third umpire: Ritika Buley. Reserve umpire: Parth Tomar. Scorer: Mayank Thanwar. Referee: Sanjeev Rao. Ball type: Leather. Ball color: White.',
  '2026-06-11T19:30:00'
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
  -- Gwalior Cheetahs batting: 257/6
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001901', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000019', 'c07ce930-7239-56c7-a87c-8dfab62436c5', '1303eab5-3486-5a12-ae69-0648c95de9f1', 1,  6,  7, 1, 0,  85.71, 1.1, 0,  4, 1, 3,  3.64, 0, 0, 0, '2026-06-11T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001902', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000019', '3ea57ec9-dd66-5321-8669-ec767c467f61', '1303eab5-3486-5a12-ae69-0648c95de9f1', 2, 73, 38, 6, 6, 192.11, 0, 0, 0, 0, 0, 0, 1, 0, 0, '2026-06-11T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001903', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000019', 'd6b5b3f7-4583-59e6-89a1-9b9f5e883ba2', '1303eab5-3486-5a12-ae69-0648c95de9f1', 3, 10,  7, 1, 0, 142.86, 4.0, 0, 44, 2, 8, 11.00, 0, 0, 0, '2026-06-11T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001904', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000019', '3313c4ab-7f84-51a6-a9db-707f3b4f0983', '1303eab5-3486-5a12-ae69-0648c95de9f1', 4, 88, 42, 4, 9, 209.52, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-11T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001905', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000019', 'f6d907f4-f8bb-52aa-99ae-772bbf4b652a', '1303eab5-3486-5a12-ae69-0648c95de9f1', 5, 46, 16, 2, 4, 287.50, 0, 0, 0, 0, 0, 0, 2, 0, 0, '2026-06-11T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001906', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000019', '40c90b46-0444-56dd-a8db-9fc2cef21a1b', '1303eab5-3486-5a12-ae69-0648c95de9f1', 6, 21,  8, 3, 1, 262.50, 1.5, 0, 31, 0, 3, 20.67, 0, 0, 0, '2026-06-11T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001907', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000019', '8f502ba1-ed08-5dd7-b9a1-9eeafda52406', '1303eab5-3486-5a12-ae69-0648c95de9f1', 7,  5,  2, 1, 0, 250.00, 0, 0, 0, 0, 0, 0, 0, 0, 1, '2026-06-11T19:30:00'),

  -- Gwalior Cheetahs bowling vs Chambal Ghariyals: 258/7
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001911', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000019', '9f47f49c-29f6-5aaf-b21e-047fc3b72985', '1303eab5-3486-5a12-ae69-0648c95de9f1', null, 0, 0, 0, 0, 0, 4.0, 0, 52, 1, 6, 13.00, 0, 0, 0, '2026-06-11T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001912', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000019', 'f772a481-aac3-5e96-bdee-6f6466852b92', '1303eab5-3486-5a12-ae69-0648c95de9f1', null, 0, 0, 0, 0, 0, 1.0, 0, 25, 0, 1, 25.00, 0, 0, 0, '2026-06-11T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001913', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000019', 'cfbc5a3c-7efa-5f50-b9a4-0bf3f2e2fa2a', '1303eab5-3486-5a12-ae69-0648c95de9f1', null, 0, 0, 0, 0, 0, 3.3, 0, 49, 1, 3, 14.85, 1, 0, 0, '2026-06-11T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001914', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000019', 'b199ea13-ead3-59fd-8f86-530506d3227a', '1303eab5-3486-5a12-ae69-0648c95de9f1', null, 0, 0, 0, 0, 0, 4.0, 0, 53, 2, 6, 13.25, 0, 0, 0, '2026-06-11T19:30:00'),

  -- Chambal Ghariyals batting: 258/7
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001921', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000019', 'c3abcf6b-af87-50dd-b6cd-bef5ba923ff4', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 1, 101, 33, 6, 11, 306.06, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-11T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001922', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000019', 'bdd646e4-e7c4-51c1-a3bf-f1bac631a751', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 2,   0,  1, 0,  0,   0.00, 0, 0, 0, 0, 0, 0, 3, 0, 0, '2026-06-11T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001923', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000019', '1a2a261a-eab8-5945-805f-ab56e7ee4265', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 3,  27, 14, 4,  1, 192.86, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-11T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001924', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000019', '33e1f887-5e0a-513d-b17e-d50a5f9eae6f', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 4,   6,  8, 0,  0,  75.00, 0, 0, 0, 0, 0, 0, 1, 0, 0, '2026-06-11T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001925', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000019', '8f53ea6e-5db4-5b51-beec-3cf622142bf7', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 5,  14,  6, 3,  0, 233.33, 4.0, 0, 48, 3, 7, 12.00, 1, 0, 0, '2026-06-11T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001926', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000019', '810363ec-7c2f-59ec-b81f-071000960904', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 6,  22, 15, 0,  2, 146.67, 0, 0, 0, 0, 0, 0, 1, 0, 0, '2026-06-11T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001927', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000019', '6d6158a0-64c1-5235-b5f3-55f601773dfd', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 7,   3,  4, 0,  0,  75.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-11T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001928', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000019', 'bfd18390-21b9-5c61-8765-373789c7f2f2', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 8,  60, 28, 3,  6, 214.29, 4.0, 0, 65, 0, 7, 16.25, 0, 0, 0, '2026-06-11T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001929', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000019', '661efd97-7f59-5db8-a791-fa9a2779d9cc', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 9,  16, 10, 1,  1, 160.00, 4.0, 0, 33, 1, 9,  8.25, 0, 0, 0, '2026-06-11T19:30:00'),

  -- Chambal Ghariyals bowling vs Gwalior Cheetahs: 257/6
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001931', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000019', '4beced42-4683-5cd7-a3d4-eafb40a735c1', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', null, 0, 0, 0, 0, 0, 4.0, 0, 65, 2, 7, 16.25, 0, 0, 0, '2026-06-11T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001932', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000019', 'f9e2b8a7-5d31-5a14-9f3e-24d240001919', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', null, 0, 0, 0, 0, 0, 4.0, 0, 46, 0, 4, 11.50, 0, 0, 0, '2026-06-11T19:30:00');

commit;
