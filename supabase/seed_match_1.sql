begin;

-- Match 1: Gwalior Cheetahs vs Ujjain Falcons
-- Holkar Stadium, Indore | June 3, 2026 | 19:30:00
-- Ujjain Falcons won by 92 runs
-- Toss: Gwalior Cheetahs won and chose to field
-- Player of the Match: Madhav Tiwari

insert into venues (id, venue_name, city, country, created_at)
values
  ('0b2128b7-a408-5c19-a6bf-cdd7c3ffa816', 'Holkar Stadium', 'Indore', 'India', '2026-06-03T19:30:00')
on conflict (venue_name) do update set
  city = excluded.city,
  country = excluded.country,
  created_at = excluded.created_at
;

-- Name correction from the scorecard
update players set player_name = 'Ankur Chauhan' where id = '17ec0eb7-e6f6-5367-9484-40316d13e11d';

delete from reports where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000001';
delete from player_match_stats where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000001';
delete from matches where id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000001';

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
  '8a9b4c2d-1f2e-4d3c-8a9b-24d240000001',
  '2026-06-03',
  '2026',
  'MPt20',
  1,
  '1303eab5-3486-5a12-ae69-0648c95de9f1',
  '2e16f308-a4d9-590a-9823-1489edc087df',
  '0b2128b7-a408-5c19-a6bf-cdd7c3ffa816',
  '1303eab5-3486-5a12-ae69-0648c95de9f1',
  'field',
  '2e16f308-a4d9-590a-9823-1489edc087df',
  '1303eab5-3486-5a12-ae69-0648c95de9f1',
  221,
  6,
  20.0,
  129,
  10,
  14.2,
  '2e16f308-a4d9-590a-9823-1489edc087df',
  '1303eab5-3486-5a12-ae69-0648c95de9f1',
  'runs',
  92,
  null,
  'd58207e1-c9a0-5d95-a068-5c1ef03e6086',
  'Aditya Birla Group MP League T20 Match 1 at Holkar Stadium, Indore. Ujjain Falcons won by 92 runs after posting 221/6 in 20 overs and bowling out Gwalior Cheetahs for 129 in 14.2 overs. Toss: Gwalior Cheetahs won and chose to field. Umpires: Rajesh Timane and Rohan Shrivastava. Third umpire: Akshay Totre. Reserve umpire: Sachin Parashar. Scorer: Dattatraya Varat. Referee: Sanjeev Rao. Ball type: Leather. Ball color: White. Phase: League.',
  '2026-06-03T19:30:00'
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
  -- Ujjain Falcons batting + bowling/fielding
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000011', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000001', 'c9704649-b025-5ae3-a7e1-58959be7b68c', '2e16f308-a4d9-590a-9823-1489edc087df', 1, 37, 26, 6, 0, 142.31, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-03T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000012', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000001', '76c8afae-d578-5f7d-a434-bff3e9426dc8', '2e16f308-a4d9-590a-9823-1489edc087df', 2, 33, 17, 2, 3, 194.12, 0, 0, 0, 0, 0, 0, 1, 0, 0, '2026-06-03T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000013', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000001', '26fe523a-8080-5d6b-91df-2a56855d6b82', '2e16f308-a4d9-590a-9823-1489edc087df', 3, 31, 23, 2, 2, 134.78, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-03T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000014', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000001', 'd58207e1-c9a0-5d95-a068-5c1ef03e6086', '2e16f308-a4d9-590a-9823-1489edc087df', 4, 62, 31, 4, 5, 200.00, 1.2, 0, 11, 2, 4, 9.17, 1, 0, 0, '2026-06-03T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000015', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000001', '4c5420f4-0540-53d4-ba92-5a185793cff3', '2e16f308-a4d9-590a-9823-1489edc087df', 5, 15, 11, 2, 0, 136.36, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-03T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000016', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000001', '17ec0eb7-e6f6-5367-9484-40316d13e11d', '2e16f308-a4d9-590a-9823-1489edc087df', 6, 5, 4, 1, 0, 125.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-03T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000017', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000001', 'f37d1d1d-bd57-559c-9e29-7bebccc95480', '2e16f308-a4d9-590a-9823-1489edc087df', 7, 18, 7, 1, 2, 257.14, 2.0, 0, 26, 0, 3, 13.00, 0, 0, 0, '2026-06-03T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000018', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000001', '5f9d6003-67e6-5524-b959-57d064eb9ac2', '2e16f308-a4d9-590a-9823-1489edc087df', 8, 4, 2, 1, 0, 200.00, 3.0, 0, 14, 2, 8, 4.67, 1, 0, 0, '2026-06-03T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000019', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000001', '27d217d2-3af4-5405-a088-c7ef5ad6ac41', '2e16f308-a4d9-590a-9823-1489edc087df', null, 0, 0, 0, 0, 0, 2.0, 0, 27, 1, 4, 13.50, 0, 0, 0, '2026-06-03T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000020', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000001', 'e81c782b-8204-50d9-9e14-c0968343fe65', '2e16f308-a4d9-590a-9823-1489edc087df', null, 0, 0, 0, 0, 0, 2.0, 0, 16, 2, 6, 8.00, 0, 0, 0, '2026-06-03T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000021', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000001', '23350497-ca69-525f-b620-d61b88cb8670', '2e16f308-a4d9-590a-9823-1489edc087df', null, 0, 0, 0, 0, 0, 4.0, 0, 31, 3, 12, 7.75, 0, 0, 0, '2026-06-03T19:30:00'),

  -- Gwalior Cheetahs batting + bowling/fielding
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000031', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000001', '3ea57ec9-dd66-5321-8669-ec767c467f61', '1303eab5-3486-5a12-ae69-0648c95de9f1', 1, 46, 18, 3, 5, 255.56, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-03T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000032', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000001', '3313c4ab-7f84-51a6-a9db-707f3b4f0983', '1303eab5-3486-5a12-ae69-0648c95de9f1', 2, 5, 6, 1, 0, 83.33, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-03T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000033', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000001', 'c07ce930-7239-56c7-a87c-8dfab62436c5', '1303eab5-3486-5a12-ae69-0648c95de9f1', 3, 9, 4, 2, 0, 225.00, 0, 0, 0, 0, 0, 0, 1, 0, 0, '2026-06-03T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000034', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000001', 'f772a481-aac3-5e96-bdee-6f6466852b92', '1303eab5-3486-5a12-ae69-0648c95de9f1', 4, 4, 7, 0, 0, 57.14, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-03T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000035', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000001', 'f6d907f4-f8bb-52aa-99ae-772bbf4b652a', '1303eab5-3486-5a12-ae69-0648c95de9f1', 5, 11, 8, 1, 0, 137.50, 0, 0, 0, 0, 0, 0, 0, 1, 0, '2026-06-03T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000036', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000001', '8f502ba1-ed08-5dd7-b9a1-9eeafda52406', '1303eab5-3486-5a12-ae69-0648c95de9f1', 6, 18, 11, 2, 1, 163.64, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-03T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000037', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000001', '40c90b46-0444-56dd-a8db-9fc2cef21a1b', '1303eab5-3486-5a12-ae69-0648c95de9f1', 7, 2, 3, 0, 0, 66.67, 4.0, 0, 42, 1, 10, 10.50, 1, 0, 0, '2026-06-03T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000038', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000001', 'd6b5b3f7-4583-59e6-89a1-9b9f5e883ba2', '1303eab5-3486-5a12-ae69-0648c95de9f1', 8, 1, 3, 0, 0, 33.33, 4.0, 0, 56, 1, 7, 14.00, 0, 0, 0, '2026-06-03T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000039', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000001', 'b199ea13-ead3-59fd-8f86-530506d3227a', '1303eab5-3486-5a12-ae69-0648c95de9f1', 9, 5, 8, 0, 0, 62.50, 4.0, 0, 27, 1, 12, 6.75, 0, 0, 0, '2026-06-03T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000040', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000001', 'cfbc5a3c-7efa-5f50-b9a4-0bf3f2e2fa2a', '1303eab5-3486-5a12-ae69-0648c95de9f1', 10, 16, 11, 0, 2, 145.45, 4.0, 0, 50, 2, 7, 12.50, 0, 0, 0, '2026-06-03T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000041', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000001', '9f47f49c-29f6-5aaf-b21e-047fc3b72985', '1303eab5-3486-5a12-ae69-0648c95de9f1', 11, 7, 7, 0, 1, 100.00, 4.0, 0, 38, 0, 6, 9.50, 0, 0, 0, '2026-06-03T19:30:00');

commit;
