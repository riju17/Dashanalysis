begin;

-- Match 17: Ujjain Falcons vs Jabalpur Royal Lions
-- Daly College Ground, Indore | June 11, 2026 | 14:30:00
-- Jabalpur Royal Lions won by 5 wickets with 8 balls remaining
-- Toss: Jabalpur Royal Lions won and chose to field
-- Player of the Match: Ritik Tada

-- Venue already exists (Daly College Ground), upsert for safety
insert into venues (id, venue_name, city, country, created_at)
values
  ('6d2f4b21-7c5e-4a4a-9f31-24e71f0d2401', 'Daly College Ground', 'Indore', 'India', '2026-06-11T14:30:00')
on conflict (venue_name) do update set
  city = excluded.city,
  country = excluded.country,
  created_at = excluded.created_at
;

-- Correct player names where seed.sql differs from scorecard
update players set player_name = 'Punit Datey'           where id = '4d98b52f-c702-5ecb-9124-a36c23e956bc';
update players set player_name = 'Nayan Mewada'          where id = 'bb5c157d-7607-5723-9023-d11cc790cec7';
update players set player_name = 'Akarsh Parihar'        where id = 'c92621ac-3bf1-5f82-b55e-215425cbb283';
update players set player_name = 'Ankur Chauhan'         where id = '17ec0eb7-e6f6-5367-9484-40316d13e11d';
update players set player_name = 'Harshvardhan Hardia'   where id = '07f64c0c-c68f-5b8a-9ba5-efaf48a27ceb';

-- Clean up any existing data for match 17 (idempotent re-run)
delete from reports            where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000017';
delete from player_match_stats where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000017';
delete from matches            where id       = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000017';

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
  '8a9b4c2d-1f2e-4d3c-8a9b-24d240000017',
  '2026-06-11',
  '2026',
  'MPt20',
  17,
  '2e16f308-a4d9-590a-9823-1489edc087df',   -- team_a: Ujjain Falcons
  '834605bb-cc4a-5b89-88c7-218cbb32d6ab',   -- team_b: Jabalpur Royal Lions
  '6d2f4b21-7c5e-4a4a-9f31-24e71f0d2401',   -- Daly College Ground
  '834605bb-cc4a-5b89-88c7-218cbb32d6ab',   -- toss winner: Jabalpur Royal Lions
  'field',                                   -- chose to field
  '2e16f308-a4d9-590a-9823-1489edc087df',   -- bat first: Ujjain Falcons
  '834605bb-cc4a-5b89-88c7-218cbb32d6ab',   -- bowl first: Jabalpur Royal Lions
  210,                                       -- first innings score
  4,                                         -- first innings wickets
  20,                                        -- first innings overs
  212,                                       -- second innings score
  5,                                         -- second innings wickets
  18.4,                                      -- second innings overs
  '834605bb-cc4a-5b89-88c7-218cbb32d6ab',   -- winner: Jabalpur Royal Lions
  '2e16f308-a4d9-590a-9823-1489edc087df',   -- loser: Ujjain Falcons
  'wickets',
  null,
  5,                                         -- margin: 5 wickets
  '29993758-c857-5658-9114-cc74a26c1880',   -- Player of the Match: Ritik Tada
  'Match 17 at Daly College Ground, Indore. Jabalpur Royal Lions won by 5 wickets with 8 balls remaining after chasing 212/5 in 18.4 overs against Ujjain Falcons 210/4 in 20 overs. Toss: Jabalpur Royal Lions won and chose to field. Umpires: Pushpendra Singh and Rameez Khan. Third umpire: Prem Bhargav. Reserve umpire: Vijendra Singh. Referee: Manish Majithia. Ball type: Leather. Ball color: White.',
  '2026-06-11T14:30:00'
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
  -- UJJAIN FALCONS BATTING (1st innings: 210/4)
  -- =============================================
  -- Soham Patwardhan: c Nayan Mewada b Punit Datey | 50, 36, 6x4, 2x6, SR 138.89
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001701', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000017', 'aab476d8-1b1e-5e64-b131-f8a20a926547', '2e16f308-a4d9-590a-9823-1489edc087df', 1, 50, 36, 6, 2, 138.89, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-11T14:30:00'),
  -- Chanchal Rathore (c/wk): c Pankaj Patel b Punit Datey | 4, 2, 1x4, 0x6, SR 200.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001702', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000017', '76c8afae-d578-5f7d-a434-bff3e9426dc8', '2e16f308-a4d9-590a-9823-1489edc087df', 2,  4,  2, 1, 0, 200.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-11T14:30:00'),
  -- Yash Dubey: c Abhishek Bhandari b Punit Datey | 4, 2, 1x4, 0x6, SR 200.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001703', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000017', 'c9704649-b025-5ae3-a7e1-58959be7b68c', '2e16f308-a4d9-590a-9823-1489edc087df', 3,  4,  2, 1, 0, 200.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-11T14:30:00'),
  -- Aryan Pandey: c Sanjog Nijjar b Akshay Sharma | 36, 24, 7x4, 0x6, SR 150.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001704', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000017', 'f37d1d1d-bd57-559c-9e29-7bebccc95480', '2e16f308-a4d9-590a-9823-1489edc087df', 4, 36, 24, 7, 0, 150.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-11T14:30:00'),
  -- Madhav Tiwari: not out | 92, 52, 9x4, 6x6, SR 176.92
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001705', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000017', 'd58207e1-c9a0-5d95-a068-5c1ef03e6086', '2e16f308-a4d9-590a-9823-1489edc087df', 5, 92, 52, 9, 6, 176.92, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-11T14:30:00'),
  -- Ojaswa Yadav: not out | 12, 6, 2x4, 0x6, SR 200.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001706', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000017', '26fe523a-8080-5d6b-91df-2a56855d6b82', '2e16f308-a4d9-590a-9823-1489edc087df', 6, 12,  6, 2, 0, 200.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-11T14:30:00'),
  -- Yet to bat: Naveen Nagle, Rishi Miglani, Vishesh Mudgal, Aayush Mankar, Ankur Chauhan

  -- =============================================
  -- UJJAIN FALCONS BOWLING (2nd innings vs Jabalpur 212/5)
  -- =============================================
  -- Aryan Pandey: 4.0-0-42-1, 7 dots, econ 10.50
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001711', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000017', 'f37d1d1d-bd57-559c-9e29-7bebccc95480', '2e16f308-a4d9-590a-9823-1489edc087df', null, 0, 0, 0, 0, 0, 4.0, 0, 42, 1,  7, 10.50, 0, 0, 0, '2026-06-11T14:30:00'),
  -- Rishi Miglani: 4.0-0-22-1, 13 dots, econ 5.50
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001712', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000017', '5f9d6003-67e6-5524-b959-57d064eb9ac2', '2e16f308-a4d9-590a-9823-1489edc087df', null, 0, 0, 0, 0, 0, 4.0, 0, 22, 1, 13,  5.50, 0, 0, 0, '2026-06-11T14:30:00'),
  -- Naveen Nagle: 3.0-0-40-1, 8 dots, econ 13.33
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001713', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000017', '04be1900-80cc-5f43-a46d-d1f0f514299e', '2e16f308-a4d9-590a-9823-1489edc087df', null, 0, 0, 0, 0, 0, 3.0, 0, 40, 1,  8, 13.33, 0, 0, 0, '2026-06-11T14:30:00'),
  -- Madhav Tiwari: 3.0-0-49-1, 2 dots, econ 16.33
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001714', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000017', 'd58207e1-c9a0-5d95-a068-5c1ef03e6086', '2e16f308-a4d9-590a-9823-1489edc087df', null, 0, 0, 0, 0, 0, 3.0, 0, 49, 1,  2, 16.33, 0, 0, 0, '2026-06-11T14:30:00'),
  -- Aayush Mankar: 3.4-0-46-1, 2 dots, econ 13.53
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001715', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000017', '23350497-ca69-525f-b620-d61b88cb8670', '2e16f308-a4d9-590a-9823-1489edc087df', null, 0, 0, 0, 0, 0, 3.4, 0, 46, 1,  2, 13.53, 0, 0, 0, '2026-06-11T14:30:00'),
  -- Vishesh Mudgal: 1.0-0-13-0, 1 dot, econ 13.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001716', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000017', 'f398a1ab-b968-5027-b072-70586c71d93f', '2e16f308-a4d9-590a-9823-1489edc087df', null, 0, 0, 0, 0, 0, 1.0, 0, 13, 0,  1, 13.00, 0, 0, 0, '2026-06-11T14:30:00'),

  -- =============================================
  -- JABALPUR ROYAL LIONS BATTING (2nd innings: 212/5)
  -- =============================================
  -- Arpit Gaud: c Vishesh Mudgal b Aryan Pandey | 1, 4, 0x4, 0x6, SR 25.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001721', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000017', 'fab398ff-2405-564f-8d25-4e33023b20e6', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', 1,  1,  4,  0, 0,  25.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-11T14:30:00'),
  -- Ajay Rohera (wk): c Ankur Chauhan b Naveen Nagle | 7, 7, 1x4, 0x6, SR 100.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001722', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000017', 'af9615ee-2603-5400-92a5-834a5d2719e9', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', 2,  7,  7,  1, 0, 100.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-11T14:30:00'),
  -- Abhishek Bhandari: c Chanchal Rathore b Madhav Tiwari | 23, 20, 4x4, 0x6, SR 115.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001723', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000017', 'e9ab0e02-e7e6-5595-b7d0-8bb2891e2c4a', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', 3, 23, 20,  4, 0, 115.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-11T14:30:00'),
  -- Akarsh Parihar: c Chanchal Rathore b Rishi Miglani | 40, 21, 5x4, 2x6, SR 190.48
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001724', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000017', 'c92621ac-3bf1-5f82-b55e-215425cbb283', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', 4, 40, 21,  5, 2, 190.48, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-11T14:30:00'),
  -- Ritik Tada: not out | 91, 32, 11x4, 6x6, SR 284.38
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001725', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000017', '29993758-c857-5658-9114-cc74a26c1880', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', 5, 91, 32, 11, 6, 284.38, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-11T14:30:00'),
  -- Sanjog Nijjar: c Aryan Pandey b Aayush Mankar | 3, 5, 0x4, 0x6, SR 60.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001726', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000017', '14819b05-062e-56b6-a956-bc5711eb6673', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', 6,  3,  5,  0, 0,  60.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-11T14:30:00'),
  -- Rahul Batham (c): not out | 46, 23, 6x4, 1x6, SR 200.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001727', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000017', '1f44fb2f-bd66-5467-bf4d-085daeb7c176', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', 7, 46, 23,  6, 1, 200.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-11T14:30:00'),
  -- Yet to bat: Nayan Mewada, Akshay Sharma, Pankaj Patel, Punit Datey

  -- =============================================
  -- JABALPUR ROYAL LIONS BOWLING (1st innings vs Ujjain 210/4)
  -- =============================================
  -- Punit Datey: 4.0-0-31-3, 10 dots, econ 7.75
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001741', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000017', '4d98b52f-c702-5ecb-9124-a36c23e956bc', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', null, 0, 0, 0, 0, 0, 4.0, 0, 31, 3, 10,  7.75, 0, 0, 0, '2026-06-11T14:30:00'),
  -- Pankaj Patel: 4.0-0-49-0, 7 dots, econ 12.25
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001742', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000017', '0bc71b97-5af4-586d-96fb-ecbaa7affaab', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', null, 0, 0, 0, 0, 0, 4.0, 0, 49, 0,  7, 12.25, 0, 0, 0, '2026-06-11T14:30:00'),
  -- Akshay Sharma: 4.0-1-37-1, 11 dots, econ 9.25
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001743', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000017', '03029869-5b08-58a5-8ba2-6af1ed546d6a', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', null, 0, 0, 0, 0, 0, 4.0, 1, 37, 1, 11,  9.25, 0, 0, 0, '2026-06-11T14:30:00'),
  -- Nayan Mewada: 3.0-0-30-0, 8 dots, econ 10.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001744', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000017', 'bb5c157d-7607-5723-9023-d11cc790cec7', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', null, 0, 0, 0, 0, 0, 3.0, 0, 30, 0,  8, 10.00, 0, 0, 0, '2026-06-11T14:30:00'),
  -- Rahul Batham: 4.0-0-50-0, 6 dots, econ 12.50
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001745', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000017', '1f44fb2f-bd66-5467-bf4d-085daeb7c176', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', null, 0, 0, 0, 0, 0, 4.0, 0, 50, 0,  6, 12.50, 0, 0, 0, '2026-06-11T14:30:00'),
  -- Sanjog Nijjar: 1.0-0-8-0, 3 dots, econ 8.00
  ('c8d2f0a1-1234-4a0d-9f8d-24d240001746', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000017', '14819b05-062e-56b6-a956-bc5711eb6673', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', null, 0, 0, 0, 0, 0, 1.0, 0,  8, 0,  3,  8.00, 0, 0, 0, '2026-06-11T14:30:00');

commit;
