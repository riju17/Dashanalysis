begin;

-- Match 15: Bhopal Leopards vs Ujjain Falcons
-- Holkar Stadium, Indore | June 10, 2026 | 15:00:00
-- Ujjain Falcons won by 16 runs
-- Toss: Bhopal Leopards won and chose to field
-- Player of the Match: Madhav Tiwari

-- Venue already exists (Holkar Stadium), upsert for safety
insert into venues (id, venue_name, city, country, created_at)
values
  ('0b2128b7-a408-5c19-a6bf-cdd7c3ffa816', 'Holkar Stadium', 'Indore', 'India', '2026-06-10T15:00:00')
on conflict (venue_name) do update set
  city = excluded.city,
  country = excluded.country,
  created_at = excluded.created_at
;

-- Correct player names where seed.sql differs from scorecard
update players set player_name = 'Harshvardhan Hardia' where id = '07f64c0c-c68f-5b8a-9ba5-efaf48a27ceb';
update players set player_name = 'Pranjul Puri'         where id = 'a1a052ca-de3c-5bc8-811f-fb5b9c0ca160';
update players set player_name = 'Anurag Malviya'       where id = '3d0ebbab-1221-5ab5-a086-dcb55c9653b1';

-- Player present in Match 15 scorecard but missing from seed.sql
insert into players (id, player_name, team_id, role, batting_style, bowling_style, created_at)
values
  ('f9e2b8a7-5d31-5a14-9f3e-24d240001111', 'Priyanshu Shukla', '89c8bea7-a025-55f9-8858-3b1220253648', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-06-10T15:00:00')
on conflict (id) do update set
  player_name = excluded.player_name,
  team_id = excluded.team_id,
  role = excluded.role,
  batting_style = excluded.batting_style,
  bowling_style = excluded.bowling_style
;

-- Clean up any existing data for match 15 (idempotent re-run)
delete from reports            where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000015';
delete from player_match_stats where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000015';
delete from matches            where id       = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000015';

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
  '8a9b4c2d-1f2e-4d3c-8a9b-24d240000015',
  '2026-06-10',
  '2026',
  'MPt20',
  15,
  '89c8bea7-a025-55f9-8858-3b1220253648',   -- team_a/home: Bhopal Leopards
  '2e16f308-a4d9-590a-9823-1489edc087df',   -- team_b/away: Ujjain Falcons
  '0b2128b7-a408-5c19-a6bf-cdd7c3ffa816',   -- Holkar Stadium
  '89c8bea7-a025-55f9-8858-3b1220253648',   -- toss winner: Bhopal Leopards
  'field',                                   -- chose to field
  '2e16f308-a4d9-590a-9823-1489edc087df',   -- bat first: Ujjain Falcons
  '89c8bea7-a025-55f9-8858-3b1220253648',   -- bowl first: Bhopal Leopards
  195,                                       -- first innings score
  8,                                         -- first innings wickets
  20,                                        -- first innings overs
  179,                                       -- second innings score
  7,                                         -- second innings wickets
  20,                                        -- second innings overs
  '2e16f308-a4d9-590a-9823-1489edc087df',   -- winner: Ujjain Falcons
  '89c8bea7-a025-55f9-8858-3b1220253648',   -- loser: Bhopal Leopards
  'runs',
  16,                                        -- margin: 16 runs
  null,
  'd58207e1-c9a0-5d95-a068-5c1ef03e6086',   -- Player of the Match: Madhav Tiwari
  'Match 15 at Holkar Stadium, Indore. Ujjain Falcons won by 16 runs after posting 195/8 in 20 overs and restricting Bhopal Leopards to 179/7 in 20 overs. Toss: Bhopal Leopards won and chose to field. Umpires: Sachin Parashar and Pushpendra Singh. Third umpire: Rameez Khan. Reserve umpire: Vijendra Singh. Referee: Manish Majithia. Scorer: Dattatraya Varat. Ball type: Leather. Ball color: White.',
  '2026-06-10T15:00:00'
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

  -- =============================================
  -- UJJAIN FALCONS BATTING (1st innings: 195/8)
  -- =============================================
  -- Chanchal Rathore (c/wk): c Suraj Yadav b Anurag Malviya | 8, 8, 1x4, 0x6, SR 100.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001501', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000015', '76c8afae-d578-5f7d-a434-bff3e9426dc8', '2e16f308-a4d9-590a-9823-1489edc087df', 1,  8,  8, 1, 0, 100.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T15:00:00'),
  -- Soham Patwardhan: c Aniket Verma b Priyanshu Shukla | 0, 4, 0x4, 0x6, SR 0.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001502', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000015', 'aab476d8-1b1e-5e64-b131-f8a20a926547', '2e16f308-a4d9-590a-9823-1489edc087df', 2,  0,  4, 0, 0,   0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T15:00:00'),
  -- Yash Dubey: c Pawan Nirwani b Pranjul Puri | 54, 31, 4x4, 3x6, SR 174.19
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001503', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000015', 'c9704649-b025-5ae3-a7e1-58959be7b68c', '2e16f308-a4d9-590a-9823-1489edc087df', 3, 54, 31, 4, 3, 174.19, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T15:00:00'),
  -- Darshan Rathore: c Aniket Verma b Anurag Malviya | 2, 8, 0x4, 0x6, SR 25.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001504', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000015', '8acb0d9d-2348-5e81-b225-c4b61ab10274', '2e16f308-a4d9-590a-9823-1489edc087df', 4,  2,  8, 0, 0,  25.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T15:00:00'),
  -- Harshvardhan Hardia: c Aniket Verma b Kamal Tripathi | 32, 18, 3x4, 2x6, SR 177.78
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001505', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000015', '07f64c0c-c68f-5b8a-9ba5-efaf48a27ceb', '2e16f308-a4d9-590a-9823-1489edc087df', 5, 32, 18, 3, 2, 177.78, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T15:00:00'),
  -- Madhav Tiwari: not out | 61, 28, 6x4, 4x6, SR 217.86
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001506', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000015', 'd58207e1-c9a0-5d95-a068-5c1ef03e6086', '2e16f308-a4d9-590a-9823-1489edc087df', 6, 61, 28, 6, 4, 217.86, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T15:00:00'),
  -- Ojaswa Yadav: c and b Himanshu Shinde | 15, 10, 1x4, 1x6, SR 150.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001507', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000015', '26fe523a-8080-5d6b-91df-2a56855d6b82', '2e16f308-a4d9-590a-9823-1489edc087df', 7, 15, 10, 1, 1, 150.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T15:00:00'),
  -- Aryan Pandey: c and b Himanshu Shinde | 1, 4, 0x4, 0x6, SR 25.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001508', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000015', 'f37d1d1d-bd57-559c-9e29-7bebccc95480', '2e16f308-a4d9-590a-9823-1489edc087df', 8,  1,  4, 0, 0,  25.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T15:00:00'),
  -- Rishi Miglani: c Pranjul Puri b Priyanshu Shukla | 15, 9, 1x4, 1x6, SR 166.67
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001509', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000015', '5f9d6003-67e6-5524-b959-57d064eb9ac2', '2e16f308-a4d9-590a-9823-1489edc087df', 9, 15,  9, 1, 1, 166.67, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T15:00:00'),
  -- Aayush Mankar: not out | 1, 1, 0x4, 0x6, SR 100.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001510', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000015', '23350497-ca69-525f-b620-d61b88cb8670', '2e16f308-a4d9-590a-9823-1489edc087df', 10, 1,  1, 0, 0, 100.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T15:00:00'),
  -- Naveen Nagle: yet to bat (no batting entry)

  -- =============================================
  -- UJJAIN FALCONS BOWLING (2nd innings vs Bhopal 179/7)
  -- =============================================
  -- Aryan Pandey: 4.0-0-35-1, 11 dots, econ 8.75
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001511', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000015', 'f37d1d1d-bd57-559c-9e29-7bebccc95480', '2e16f308-a4d9-590a-9823-1489edc087df', null, 0, 0, 0, 0, 0, 4.0, 0, 35, 1, 11,  8.75, 0, 0, 0, '2026-06-10T15:00:00'),
  -- Harshvardhan Hardia: 2.0-0-28-1, 2 dots, econ 14.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001512', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000015', '07f64c0c-c68f-5b8a-9ba5-efaf48a27ceb', '2e16f308-a4d9-590a-9823-1489edc087df', null, 0, 0, 0, 0, 0, 2.0, 0, 28, 1,  2, 14.00, 0, 0, 0, '2026-06-10T15:00:00'),
  -- Rishi Miglani: 2.0-0-26-0, 5 dots, econ 13.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001513', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000015', '5f9d6003-67e6-5524-b959-57d064eb9ac2', '2e16f308-a4d9-590a-9823-1489edc087df', null, 0, 0, 0, 0, 0, 2.0, 0, 26, 0,  5, 13.00, 0, 0, 0, '2026-06-10T15:00:00'),
  -- Madhav Tiwari: 4.0-0-26-2, 10 dots, econ 6.50
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001514', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000015', 'd58207e1-c9a0-5d95-a068-5c1ef03e6086', '2e16f308-a4d9-590a-9823-1489edc087df', null, 0, 0, 0, 0, 0, 4.0, 0, 26, 2, 10,  6.50, 0, 0, 0, '2026-06-10T15:00:00'),
  -- Aayush Mankar: 4.0-0-25-2, 10 dots, econ 6.25
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001515', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000015', '23350497-ca69-525f-b620-d61b88cb8670', '2e16f308-a4d9-590a-9823-1489edc087df', null, 0, 0, 0, 0, 0, 4.0, 0, 25, 2, 10,  6.25, 0, 0, 0, '2026-06-10T15:00:00'),
  -- Naveen Nagle: 4.0-0-39-1, 4 dots, econ 9.75
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001516', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000015', '04be1900-80cc-5f43-a46d-d1f0f514299e', '2e16f308-a4d9-590a-9823-1489edc087df', null, 0, 0, 0, 0, 0, 4.0, 0, 39, 1,  4,  9.75, 0, 0, 0, '2026-06-10T15:00:00'),

  -- =============================================
  -- BHOPAL LEOPARDS BATTING (2nd innings: 179/7)
  -- =============================================
  -- Tanishq Yadav: c Chanchal Rathore b Aayush Mankar | 42, 27, 4x4, 3x6, SR 155.56
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001521', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000015', 'fcb64b16-e1c9-5810-8b52-311c6dc0dab0', '89c8bea7-a025-55f9-8858-3b1220253648', 1, 42, 27, 4, 3, 155.56, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T15:00:00'),
  -- Rahul Chandrol (wk): c Soham Patwardhan b Madhav Tiwari | 31, 13, 2x4, 3x6, SR 238.46
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001522', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000015', 'a652e185-c0c1-5361-9b36-14f575b0c276', '89c8bea7-a025-55f9-8858-3b1220253648', 2, 31, 13, 2, 3, 238.46, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T15:00:00'),
  -- Suraj Yadav: c Ojaswa Yadav b Aayush Mankar | 22, 19, 2x4, 0x6, SR 115.79
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001523', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000015', '15915c22-37bb-5f32-8ffe-ebd791791ed5', '89c8bea7-a025-55f9-8858-3b1220253648', 3, 22, 19, 2, 0, 115.79, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T15:00:00'),
  -- Pawan Nirwani: c Yash Dubey b Naveen Nagle | 17, 14, 2x4, 0x6, SR 121.43
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001524', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000015', '175f38b8-8402-57e3-a9ac-296f10ea624a', '89c8bea7-a025-55f9-8858-3b1220253648', 4, 17, 14, 2, 0, 121.43, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T15:00:00'),
  -- Aniket Verma (c): c Soham Patwardhan b Madhav Tiwari | 18, 14, 1x4, 1x6, SR 128.57
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001525', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000015', 'bdfb9f70-ac54-5c21-b013-cc0c4ad44b45', '89c8bea7-a025-55f9-8858-3b1220253648', 5, 18, 14, 1, 1, 128.57, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T15:00:00'),
  -- Himanshu Shinde: c Soham Patwardhan b Harshvardhan Hardia | 16, 16, 0x4, 1x6, SR 100.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001526', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000015', 'df7c6a07-1ed8-5d13-b601-f52736f8d7d6', '89c8bea7-a025-55f9-8858-3b1220253648', 6, 16, 16, 0, 1, 100.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T15:00:00'),
  -- Kamal Tripathi: c Yash Dubey b Aryan Pandey | 5, 6, 1x4, 0x6, SR 83.33
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001527', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000015', 'e8d4cbc5-c3e3-5276-ac3b-a3c363258fb3', '89c8bea7-a025-55f9-8858-3b1220253648', 7,  5,  6, 1, 0,  83.33, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T15:00:00'),
  -- Pranjul Puri: not out | 19, 11, 0x4, 2x6, SR 172.73
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001528', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000015', 'a1a052ca-de3c-5bc8-811f-fb5b9c0ca160', '89c8bea7-a025-55f9-8858-3b1220253648', 8, 19, 11, 0, 2, 172.73, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T15:00:00'),
  -- Yuvraj Nema, Priyanshu Shukla, Anurag Malviya: yet to bat (no batting entry)

  -- =============================================
  -- BHOPAL LEOPARDS BOWLING (1st innings vs Ujjain 195/8)
  -- =============================================
  -- Priyanshu Shukla: 4.0-0-37-2, 10 dots, econ 9.25
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001541', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000015', 'f9e2b8a7-5d31-5a14-9f3e-24d240001111', '89c8bea7-a025-55f9-8858-3b1220253648', null, 0, 0, 0, 0, 0, 4.0, 0, 37, 2, 10,  9.25, 0, 0, 0, '2026-06-10T15:00:00'),
  -- Anurag Malviya: 4.0-0-55-2, 9 dots, econ 13.75
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001542', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000015', '3d0ebbab-1221-5ab5-a086-dcb55c9653b1', '89c8bea7-a025-55f9-8858-3b1220253648', null, 0, 0, 0, 0, 0, 4.0, 0, 55, 2,  9, 13.75, 0, 0, 0, '2026-06-10T15:00:00'),
  -- Pawan Nirwani: 3.0-0-37-0, 5 dots, econ 12.33
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001543', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000015', '175f38b8-8402-57e3-a9ac-296f10ea624a', '89c8bea7-a025-55f9-8858-3b1220253648', null, 0, 0, 0, 0, 0, 3.0, 0, 37, 0,  5, 12.33, 0, 0, 0, '2026-06-10T15:00:00'),
  -- Kamal Tripathi: 4.0-0-39-1, 6 dots, econ 9.75
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001544', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000015', 'e8d4cbc5-c3e3-5276-ac3b-a3c363258fb3', '89c8bea7-a025-55f9-8858-3b1220253648', null, 0, 0, 0, 0, 0, 4.0, 0, 39, 1,  6,  9.75, 0, 0, 0, '2026-06-10T15:00:00'),
  -- Pranjul Puri: 4.0-0-24-1, 7 dots, econ 6.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001545', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000015', 'a1a052ca-de3c-5bc8-811f-fb5b9c0ca160', '89c8bea7-a025-55f9-8858-3b1220253648', null, 0, 0, 0, 0, 0, 4.0, 0, 24, 1,  7,  6.00, 0, 0, 0, '2026-06-10T15:00:00'),
  -- Himanshu Shinde: 1.0-0-2-2, 4 dots, econ 2.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001546', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000015', 'df7c6a07-1ed8-5d13-b601-f52736f8d7d6', '89c8bea7-a025-55f9-8858-3b1220253648', null, 0, 0, 0, 0, 0, 1.0, 0,  2, 2,  4,  2.00, 0, 0, 0, '2026-06-10T15:00:00');

commit;
