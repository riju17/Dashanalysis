begin;

-- Match 25: Ujjain Falcons vs Rewa Jaguars
-- Holkar Stadium, Indore | June 13, 2026 | 15:00:00
-- Rewa Jaguars won by 5 wickets with 6 balls remaining
-- Toss: Ujjain Falcons won and chose to bat
-- Player of the Match: Arham Aqueel

insert into venues (id, venue_name, city, country, created_at)
values
  ('0b2128b7-a408-5c19-a6bf-cdd7c3ffa816', 'Holkar Stadium', 'Indore', 'India', '2026-06-13T15:00:00')
on conflict (venue_name) do update set
  city = excluded.city,
  country = excluded.country,
  created_at = excluded.created_at
;

-- Name corrections from the scorecard
update players set player_name = 'Ankit Kushwah' where id = 'd1b49b26-555f-569a-87eb-f55a7443c614';
update players set player_name = 'Ramveer Gurjar' where id = 'a8bcd523-2f54-5dbe-bc14-55c5d83c4bf7';
update players set player_name = 'Ankur Chauhan' where id = '17ec0eb7-e6f6-5367-9484-40316d13e11d';

delete from reports where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025';
delete from player_match_stats where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025';
delete from matches where id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025';

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
  '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025',
  '2026-06-13',
  '2026',
  'MPt20',
  25,
  '2e16f308-a4d9-590a-9823-1489edc087df',
  'd1962402-4148-5a80-b691-75d24e750af1',
  '0b2128b7-a408-5c19-a6bf-cdd7c3ffa816',
  '2e16f308-a4d9-590a-9823-1489edc087df',
  'bat',
  '2e16f308-a4d9-590a-9823-1489edc087df',
  'd1962402-4148-5a80-b691-75d24e750af1',
  231,
  4,
  20,
  234,
  5,
  19,
  'd1962402-4148-5a80-b691-75d24e750af1',
  '2e16f308-a4d9-590a-9823-1489edc087df',
  'wickets',
  null,
  5,
  '26ed4478-2b30-5de3-ba83-96749866d006',
  'Match 25 at Holkar Stadium, Indore. Rewa Jaguars won by 5 wickets with 6 balls remaining after chasing 234/5 in 19 overs against Ujjain Falcons 231/4 in 20 overs. Toss: Ujjain Falcons won and chose to bat. Umpires: Manish Jain and Rameez Khan. Third umpire: Nikhil Menon. Reserve umpire: Vishal Sharma. Scorer: Jayant Wankhede. Referee: Sanjeev Rao. Ball type: Leather. Ball color: White.',
  '2026-06-13T15:00:00'
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
  -- Ujjain Falcons batting and bowling
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002501', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', 'aab476d8-1b1e-5e64-b131-f8a20a926547', '2e16f308-a4d9-590a-9823-1489edc087df',  1, 11,  6, 2, 0, 183.33, 0, 0, 0, 0,  0,  0.00, 0, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002502', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', '76c8afae-d578-5f7d-a434-bff3e9426dc8', '2e16f308-a4d9-590a-9823-1489edc087df',  2, 71, 38, 5, 6, 186.84, 0, 0, 0, 0,  0,  0.00, 0, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002503', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', 'c9704649-b025-5ae3-a7e1-58959be7b68c', '2e16f308-a4d9-590a-9823-1489edc087df',  3, 49, 40, 3, 1, 122.50, 0, 0, 0, 0,  0,  0.00, 0, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002504', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', 'd58207e1-c9a0-5d95-a068-5c1ef03e6086', '2e16f308-a4d9-590a-9823-1489edc087df',  4, 18, 13, 2, 1, 138.46, 4, 0, 58, 1,  7, 14.50, 0, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002505', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', '26fe523a-8080-5d6b-91df-2a56855d6b82', '2e16f308-a4d9-590a-9823-1489edc087df',  5, 44, 14, 1, 6, 314.29, 0, 0, 0, 0,  0,  0.00, 0, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002506', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', 'f37d1d1d-bd57-559c-9e29-7bebccc95480', '2e16f308-a4d9-590a-9823-1489edc087df',  6, 28,  9, 2, 3, 311.11, 4, 0, 39, 1,  7,  9.75, 1, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002507', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', '5f9d6003-67e6-5524-b959-57d064eb9ac2', '2e16f308-a4d9-590a-9823-1489edc087df', null, 0,  0, 0, 0,   0.00, 3, 0, 32, 0,  6, 10.67, 0, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002508', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', 'd1b49b26-555f-569a-87eb-f55a7443c614', '2e16f308-a4d9-590a-9823-1489edc087df', null, 0,  0, 0, 0,   0.00, 4, 0, 43, 2,  5, 10.75, 1, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002509', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', '27d217d2-3af4-5405-a088-c7ef5ad6ac41', '2e16f308-a4d9-590a-9823-1489edc087df', null, 0,  0, 0, 0,   0.00, 1, 0, 13, 0,  1, 13.00, 0, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002510', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', '2b2f93bb-fe9d-5b14-abb3-6a5fe6c1a9c8', '2e16f308-a4d9-590a-9823-1489edc087df', null, 0,  0, 0, 0,   0.00, 4, 0, 40, 0,  6, 10.00, 0, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002511', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', 'e81c782b-8204-50d9-9e14-c0968343fe65', '2e16f308-a4d9-590a-9823-1489edc087df', null, 0,  0, 0, 0,   0.00, 4, 0, 58, 1,  7, 14.50, 1, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002512', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', '23350497-ca69-525f-b620-d61b88cb8670', '2e16f308-a4d9-590a-9823-1489edc087df', null, 0,  0, 0, 0,   0.00, 2, 0, 29, 1,  1, 14.50, 0, 0, 0, '2026-06-13T15:00:00'),

  -- Rewa Jaguars batting and bowling
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002521', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', '8ec8ffda-bfdc-54de-89d4-85e3d75f1ab3', 'd1962402-4148-5a80-b691-75d24e750af1',  1, 24, 11, 1, 3, 218.18, 0, 0, 0, 0,  0,  0.00, 0, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002522', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', '14285295-0308-5eed-abb1-b4c02962a013', 'd1962402-4148-5a80-b691-75d24e750af1',  2, 21, 11, 1, 2, 190.91, 0, 0, 0, 0,  0,  0.00, 0, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002523', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', '26ed4478-2b30-5de3-ba83-96749866d006', 'd1962402-4148-5a80-b691-75d24e750af1',  3, 107, 49, 8, 7, 218.37, 0, 0, 0, 0,  0,  0.00, 1, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002524', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', 'c1c0d96d-ac8e-5e26-a70c-c25f11359448', 'd1962402-4148-5a80-b691-75d24e750af1',  4,  9,  6, 0, 1, 150.00, 0, 0, 0, 0,  0,  0.00, 1, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002525', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', 'c30ccf9b-cb5c-55cb-9266-d50ec530797d', 'd1962402-4148-5a80-b691-75d24e750af1',  5, 26, 20, 2, 1, 130.00, 4, 0, 29, 0,  8,  7.25, 0, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002526', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', 'd1b49b26-555f-569a-87eb-f55a7443c614', 'd1962402-4148-5a80-b691-75d24e750af1',  6,  1,  2, 0, 0,  50.00, 4, 0, 39, 2,  6,  9.75, 0, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002527', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', '480c03c5-ea83-5913-8a4b-947fc3bf5a28', 'd1962402-4148-5a80-b691-75d24e750af1',  7, 29, 17, 2, 2, 170.59, 2, 0, 26, 1,  3, 13.00, 0, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002528', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', 'cbdf43c9-cbd8-5235-936c-14d31366433c', 'd1962402-4148-5a80-b691-75d24e750af1', null, 0,  0, 0, 0,   0.00, 2, 0, 30, 0,  1, 15.00, 0, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002529', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', '2b2f93bb-fe9d-5b14-abb3-6a5fe6c1a9c8', 'd1962402-4148-5a80-b691-75d24e750af1', null, 0,  0, 0, 0,   0.00, 4, 0, 40, 0,  6, 10.00, 0, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002530', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', 'a8bcd523-2f54-5dbe-bc14-55c5d83c4bf7', 'd1962402-4148-5a80-b691-75d24e750af1', null, 0,  0, 0, 0,   0.00, 4, 0, 58, 1,  8, 14.50, 0, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002531', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', 'b218001e-c822-58e7-ab99-da490578ae53', 'd1962402-4148-5a80-b691-75d24e750af1', null, 0,  0, 0, 0,   0.00, 0, 0, 0, 0,  0,  0.00, 1, 0, 0, '2026-06-13T15:00:00');

commit;
