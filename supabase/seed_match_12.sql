begin;

-- Match 12: Chambal Ghariyals vs Ujjain Falcons
-- Holkar Stadium, Indore | June 8, 2026 | 15:00:00
-- Chambal Ghariyals won by 7 runs
-- Toss: Ujjain Falcons won and chose to field
-- Player of the Match: Tripuresh Singh

-- Venue already exists (Holkar Stadium), upsert for safety
insert into venues (id, venue_name, city, country, created_at)
values
  ('0b2128b7-a408-5c19-a6bf-cdd7c3ffa816', 'Holkar Stadium', 'Indore', 'India', '2026-06-08T15:00:00')
on conflict (venue_name) do update set
  city = excluded.city,
  country = excluded.country,
  created_at = excluded.created_at
;

-- Correct player names where seed.sql differs from scorecard
update players set player_name = 'Rohit Gupta'          where id = '810363ec-7c2f-59ec-b81f-071000960904';
update players set player_name = 'Aavesh Khan'          where id = '4beced42-4683-5cd7-a3d4-eafb40a735c1';
update players set player_name = 'Mayur Patel'          where id = '661efd97-7f59-5db8-a791-fa9a2779d9cc';
update players set player_name = 'Harshvardhan Hardia'  where id = '07f64c0c-c68f-5b8a-9ba5-efaf48a27ceb';

-- Clean up any existing data for match 12 (idempotent re-run)
delete from reports           where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012';
delete from player_match_stats where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012';
delete from matches            where id       = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012';

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
  '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012',
  '2026-06-08',
  '2026',
  'MPt20',
  12,
  '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e',   -- team_a: Chambal Ghariyals
  '2e16f308-a4d9-590a-9823-1489edc087df',   -- team_b: Ujjain Falcons
  '0b2128b7-a408-5c19-a6bf-cdd7c3ffa816',   -- Holkar Stadium
  '2e16f308-a4d9-590a-9823-1489edc087df',   -- toss winner: Ujjain Falcons
  'field',                                   -- chose to field
  '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e',   -- bat first: Chambal Ghariyals
  '2e16f308-a4d9-590a-9823-1489edc087df',   -- bowl first: Ujjain Falcons
  199,                                       -- first innings score
  7,                                         -- first innings wickets
  20,                                        -- first innings overs
  192,                                       -- second innings score
  9,                                         -- second innings wickets
  20,                                        -- second innings overs
  '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e',   -- winner: Chambal Ghariyals
  '2e16f308-a4d9-590a-9823-1489edc087df',   -- loser: Ujjain Falcons
  'runs',
  7,                                         -- margin: 7 runs
  null,
  '8f53ea6e-5db4-5b51-beec-3cf622142bf7',   -- Player of the Match: Tripuresh Singh
  'Match 12 at Holkar Stadium, Indore. Chambal Ghariyals won by 7 runs after posting 199/7 in 20 overs and restricting Ujjain Falcons to 192/9 in 20 overs. Toss: Ujjain Falcons won and chose to field. Umpires: Sachin Parashar and Rameez Khan. Third umpire: Nikhil Menon. Reserve umpire: Ravi Sharma. Referee: Sanjeev Rao. Ball type: Leather. Ball color: White.',
  '2026-06-08T15:00:00'
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
  -- CHAMBAL GHARIYALS BATTING (1st innings: 199/7)
  -- =============================================
  -- Ankush Singh: c Yash Dubey b Madhav Tiwari | 2, 7, 0x4, 0x6, SR 28.57
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001201', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012', 'c3abcf6b-af87-50dd-b6cd-bef5ba923ff4', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 1,  2,  7,  0, 0,  28.57, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T15:00:00'),
  -- Apurva Dwivedi (wk): c Aryan Pandey b Gajendra Goswami | 30, 19, 3x4, 2x6, SR 157.89
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001202', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012', '1a2a261a-eab8-5945-805f-ab56e7ee4265', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 2, 30, 19,  3, 2, 157.89, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T15:00:00'),
  -- Shubham Sharma (c): c Yash Dubey b Harshvardhan Hardia | 57, 44, 5x4, 1x6, SR 129.55
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001203', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012', 'bdd646e4-e7c4-51c1-a3bf-f1bac631a751', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 3, 57, 44,  5, 1, 129.55, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T15:00:00'),
  -- Gautam Raghuvanshi: c Soham Patwardhan b Harshvardhan Hardia | 11, 9, 2x4, 0x6, SR 122.22
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001204', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012', '33e1f887-5e0a-513d-b17e-d50a5f9eae6f', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 4, 11,  9,  2, 0, 122.22, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T15:00:00'),
  -- Tripuresh Singh: c Aryan Pandey b Madhav Tiwari | 30, 16, 2x4, 2x6, SR 187.50
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001205', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012', '8f53ea6e-5db4-5b51-beec-3cf622142bf7', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 5, 30, 16,  2, 2, 187.50, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T15:00:00'),
  -- Rohit Gupta: not out | 41, 17, 4x4, 3x6, SR 241.18
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001206', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012', '810363ec-7c2f-59ec-b81f-071000960904', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 6, 41, 17,  4, 3, 241.18, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T15:00:00'),
  -- Aman Bhadoriya: c Aryan Pandey b Gajendra Goswami | 13, 5, 0x4, 2x6, SR 260.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001207', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012', 'bfd18390-21b9-5c61-8765-373789c7f2f2', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 7, 13,  5,  0, 2, 260.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T15:00:00'),
  -- Mayur Patel: run out (Aryan Pandey) | 0, 2, 0x4, 0x6, SR 0.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001208', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012', '661efd97-7f59-5db8-a791-fa9a2779d9cc', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 8,  0,  2,  0, 0,   0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T15:00:00'),
  -- Aavesh Khan: not out | 1, 1, 0x4, 0x6, SR 100.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001209', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012', '4beced42-4683-5cd7-a3d4-eafb40a735c1', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 9,  1,  1,  0, 0, 100.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T15:00:00'),
  -- Akshay Singh: yet to bat (no batting entry)
  -- Yash Lodhi: yet to bat (no batting entry)

  -- =============================================
  -- CHAMBAL GHARIYALS BOWLING (2nd innings vs Ujjain 192/9)
  -- =============================================
  -- Akshay Singh: 3.0-0-33-0, 7 dots, econ 11.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001211', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012', '59efe8ae-f3df-5200-b756-93fd814d31c6', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', null, 0, 0, 0, 0, 0, 3.0, 0, 33, 0,  7, 11.00, 0, 0, 0, '2026-06-08T15:00:00'),
  -- Aman Bhadoriya: 4.0-0-37-1, 10 dots, econ 9.25
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001212', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012', 'bfd18390-21b9-5c61-8765-373789c7f2f2', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', null, 0, 0, 0, 0, 0, 4.0, 0, 37, 1, 10,  9.25, 0, 0, 0, '2026-06-08T15:00:00'),
  -- Aavesh Khan: 4.0-0-25-3, 12 dots, econ 6.25
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001213', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012', '4beced42-4683-5cd7-a3d4-eafb40a735c1', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', null, 0, 0, 0, 0, 0, 4.0, 0, 25, 3, 12,  6.25, 0, 0, 0, '2026-06-08T15:00:00'),
  -- Mayur Patel: 4.0-0-36-1, 7 dots, econ 9.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001214', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012', '661efd97-7f59-5db8-a791-fa9a2779d9cc', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', null, 0, 0, 0, 0, 0, 4.0, 0, 36, 1,  7,  9.00, 0, 0, 0, '2026-06-08T15:00:00'),
  -- Tripuresh Singh: 4.0-0-35-2, 7 dots, econ 8.75
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001215', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012', '8f53ea6e-5db4-5b51-beec-3cf622142bf7', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', null, 0, 0, 0, 0, 0, 4.0, 0, 35, 2,  7,  8.75, 0, 0, 0, '2026-06-08T15:00:00'),
  -- Shubham Sharma: 1.0-0-18-0, 1 dot, econ 18.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001216', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012', 'bdd646e4-e7c4-51c1-a3bf-f1bac631a751', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', null, 0, 0, 0, 0, 0, 1.0, 0, 18, 0,  1, 18.00, 0, 0, 0, '2026-06-08T15:00:00'),

  -- =============================================
  -- UJJAIN FALCONS BATTING (2nd innings: 192/9)
  -- =============================================
  -- Yash Dubey: run out (Piyush Patel) | 26, 18, 4x4, 0x6, SR 144.44
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001221', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012', 'c9704649-b025-5ae3-a7e1-58959be7b68c', '2e16f308-a4d9-590a-9823-1489edc087df', 1, 26, 18,  4, 0, 144.44, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T15:00:00'),
  -- Chanchal Rathore (c/wk): c Aavesh Khan b Aman Bhadoriya | 0, 2, 0x4, 0x6, SR 0.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001222', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012', '76c8afae-d578-5f7d-a434-bff3e9426dc8', '2e16f308-a4d9-590a-9823-1489edc087df', 2,  0,  2,  0, 0,   0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T15:00:00'),
  -- Soham Patwardhan: c Mayur Patel b Tripuresh Singh | 43, 28, 6x4, 1x6, SR 153.57
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001223', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012', 'aab476d8-1b1e-5e64-b131-f8a20a926547', '2e16f308-a4d9-590a-9823-1489edc087df', 3, 43, 28,  6, 1, 153.57, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T15:00:00'),
  -- Madhav Tiwari: c Aman Bhadoriya b Mayur Patel | 28, 18, 3x4, 1x6, SR 155.56
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001224', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012', 'd58207e1-c9a0-5d95-a068-5c1ef03e6086', '2e16f308-a4d9-590a-9823-1489edc087df', 4, 28, 18,  3, 1, 155.56, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T15:00:00'),
  -- Ojaswa Yadav: c Aman Bhadoriya b Tripuresh Singh | 16, 10, 0x4, 2x6, SR 160.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001225', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012', '26fe523a-8080-5d6b-91df-2a56855d6b82', '2e16f308-a4d9-590a-9823-1489edc087df', 5, 16, 10,  0, 2, 160.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T15:00:00'),
  -- Aryan Pandey: c Ankush Singh b Aavesh Khan | 18, 12, 3x4, 0x6, SR 150.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001226', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012', 'f37d1d1d-bd57-559c-9e29-7bebccc95480', '2e16f308-a4d9-590a-9823-1489edc087df', 6, 18, 12,  3, 0, 150.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T15:00:00'),
  -- Darshan Rathore: run out (Apurve Dwivedi/Aavesh Khan) | 16, 11, 0x4, 2x6, SR 145.45
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001227', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012', '8acb0d9d-2348-5e81-b225-c4b61ab10274', '2e16f308-a4d9-590a-9823-1489edc087df', 7, 16, 11,  0, 2, 145.45, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T15:00:00'),
  -- Rishi Miglani: c Aman Bhadoriya b Aavesh Khan | 9, 5, 2x4, 0x6, SR 180.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001228', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012', '5f9d6003-67e6-5524-b959-57d064eb9ac2', '2e16f308-a4d9-590a-9823-1489edc087df', 8,  9,  5,  2, 0, 180.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T15:00:00'),
  -- Aayush Mankar: c Aman Bhadoriya b Aavesh Khan | 0, 2, 0x4, 0x6, SR 0.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001229', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012', '23350497-ca69-525f-b620-d61b88cb8670', '2e16f308-a4d9-590a-9823-1489edc087df', 9,  0,  2,  0, 0,   0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T15:00:00'),
  -- Harshvardhan Hardia: not out | 16, 11, 0x4, 2x6, SR 145.45
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001230', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012', '07f64c0c-c68f-5b8a-9ba5-efaf48a27ceb', '2e16f308-a4d9-590a-9823-1489edc087df', 10, 16, 11,  0, 2, 145.45, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T15:00:00'),
  -- Gajendra Goswami: not out | 1, 3, 0x4, 0x6, SR 33.33
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001231', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012', '27d217d2-3af4-5405-a088-c7ef5ad6ac41', '2e16f308-a4d9-590a-9823-1489edc087df', 11,  1,  3,  0, 0,  33.33, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T15:00:00'),

  -- =============================================
  -- UJJAIN FALCONS BOWLING (1st innings vs Chambal 199/7)
  -- =============================================
  -- Aryan Pandey: 4.0-0-48-0, 9 dots, econ 12.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001241', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012', 'f37d1d1d-bd57-559c-9e29-7bebccc95480', '2e16f308-a4d9-590a-9823-1489edc087df', null, 0, 0, 0, 0, 0, 4.0, 0, 48, 0,  9, 12.00, 0, 0, 0, '2026-06-08T15:00:00'),
  -- Madhav Tiwari: 4.0-0-24-2, 11 dots, econ 6.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001242', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012', 'd58207e1-c9a0-5d95-a068-5c1ef03e6086', '2e16f308-a4d9-590a-9823-1489edc087df', null, 0, 0, 0, 0, 0, 4.0, 0, 24, 2, 11,  6.00, 0, 0, 0, '2026-06-08T15:00:00'),
  -- Harshvardhan Hardia: 4.0-0-39-2, 10 dots, econ 9.75
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001243', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012', '07f64c0c-c68f-5b8a-9ba5-efaf48a27ceb', '2e16f308-a4d9-590a-9823-1489edc087df', null, 0, 0, 0, 0, 0, 4.0, 0, 39, 2, 10,  9.75, 0, 0, 0, '2026-06-08T15:00:00'),
  -- Gajendra Goswami: 4.0-0-38-2, 11 dots, econ 9.50
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001244', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012', '27d217d2-3af4-5405-a088-c7ef5ad6ac41', '2e16f308-a4d9-590a-9823-1489edc087df', null, 0, 0, 0, 0, 0, 4.0, 0, 38, 2, 11,  9.50, 0, 0, 0, '2026-06-08T15:00:00'),
  -- Aayush Mankar: 2.0-0-24-0, 3 dots, econ 12.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001245', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012', '23350497-ca69-525f-b620-d61b88cb8670', '2e16f308-a4d9-590a-9823-1489edc087df', null, 0, 0, 0, 0, 0, 2.0, 0, 24, 0,  3, 12.00, 0, 0, 0, '2026-06-08T15:00:00'),
  -- Rishi Miglani: 2.0-0-22-0, 0 dots, econ 11.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001246', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000012', '5f9d6003-67e6-5524-b959-57d064eb9ac2', '2e16f308-a4d9-590a-9823-1489edc087df', null, 0, 0, 0, 0, 0, 2.0, 0, 22, 0,  0, 11.00, 0, 0, 0, '2026-06-08T15:00:00');

commit;