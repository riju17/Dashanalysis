begin;

-- Match 5: Ujjain Falcons vs Malwa Stallions
-- Holkar Stadium, Indore | June 5, 2026 | 19:30:00
-- Malwa Stallions won by 6 wickets with 10 balls remaining
-- Toss: Ujjain Falcons won and chose to bat
-- Player of the Match: Ashutosh Rambabu Sharma

insert into venues (id, venue_name, city, country, created_at)
values
  ('0b2128b7-a408-5c19-a6bf-cdd7c3ffa816', 'Holkar Stadium', 'Indore', 'India', '2026-06-05T19:30:00')
on conflict (venue_name) do update set
  city = excluded.city,
  country = excluded.country,
  created_at = excluded.created_at
;

-- Name correction from scorecard display
update players set player_name = 'Akhil Nigote Yadav' where id = '0fedfcd7-31fe-5be9-9e65-58daaf7d89e1';

delete from reports where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000005';
delete from player_match_stats where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000005';
delete from matches where id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000005';

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
  '8a9b4c2d-1f2e-4d3c-8a9b-24d240000005',
  '2026-06-05',
  '2026',
  'MPt20',
  5,
  '2e16f308-a4d9-590a-9823-1489edc087df',
  '42c007fa-6d22-56b0-981b-fae8db3c0483',
  '0b2128b7-a408-5c19-a6bf-cdd7c3ffa816',
  '2e16f308-a4d9-590a-9823-1489edc087df',
  'bat',
  '2e16f308-a4d9-590a-9823-1489edc087df',
  '42c007fa-6d22-56b0-981b-fae8db3c0483',
  206,
  8,
  20,
  207,
  4,
  18.2,
  '42c007fa-6d22-56b0-981b-fae8db3c0483',
  '2e16f308-a4d9-590a-9823-1489edc087df',
  'wickets',
  null,
  6,
  'fe7efb2f-9244-58c6-a3fd-55f32427a875',
  'Aditya Birla Group MP League T20 Match 5 at Holkar Stadium, Indore. Malwa Stallions won by 6 wickets with 10 balls remaining after chasing 207/4 in 18.2 overs against Ujjain Falcons 206/8 in 20 overs. Toss: Ujjain Falcons won and chose to bat. Umpires: Rajesh Timane and Pushpendra Singh. Third umpire: Nikhil Patwardhan. Reserve umpire: Raja Thakur. Scorer: Sunil Gupta. Referee: Manish Majithia. Ball type: Leather. Ball color: White. Phase: League.',
  '2026-06-05T19:30:00'
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
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000501', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000005', 'c9704649-b025-5ae3-a7e1-58959be7b68c', '2e16f308-a4d9-590a-9823-1489edc087df', 1, 17, 11, 3, 0, 154.55, 0, 0, 0, 0, 0, 0.00, 0, 0, 0, '2026-06-05T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000502', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000005', '76c8afae-d578-5f7d-a434-bff3e9426dc8', '2e16f308-a4d9-590a-9823-1489edc087df', 2, 56, 38, 5, 3, 147.37, 0, 0, 0, 0, 0, 0.00, 0, 1, 0, '2026-06-05T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000503', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000005', '4c5420f4-0540-53d4-ba92-5a185793cff3', '2e16f308-a4d9-590a-9823-1489edc087df', 3, 10, 10, 1, 0, 100.00, 0, 0, 0, 0, 0, 0.00, 0, 0, 0, '2026-06-05T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000504', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000005', 'd58207e1-c9a0-5d95-a068-5c1ef03e6086', '2e16f308-a4d9-590a-9823-1489edc087df', 4, 43, 24, 5, 1, 179.17, 4.0, 0, 38, 0, 10, 9.50, 2, 0, 0, '2026-06-05T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000505', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000005', '26fe523a-8080-5d6b-91df-2a56855d6b82', '2e16f308-a4d9-590a-9823-1489edc087df', 5, 34, 17, 4, 2, 200.00, 0, 0, 0, 0, 0, 0.00, 0, 0, 0, '2026-06-05T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000506', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000005', '17ec0eb7-e6f6-5367-9484-40316d13e11d', '2e16f308-a4d9-590a-9823-1489edc087df', 6, 2, 4, 0, 0, 50.00, 1.0, 0, 17, 0, 0, 17.00, 1, 0, 0, '2026-06-05T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000507', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000005', 'f37d1d1d-bd57-559c-9e29-7bebccc95480', '2e16f308-a4d9-590a-9823-1489edc087df', 7, 9, 5, 2, 0, 180.00, 3.0, 0, 31, 1, 9, 10.33, 0, 0, 0, '2026-06-05T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000508', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000005', '5f9d6003-67e6-5524-b959-57d064eb9ac2', '2e16f308-a4d9-590a-9823-1489edc087df', 8, 27, 11, 1, 3, 245.45, 2.0, 0, 26, 0, 3, 13.00, 0, 0, 0, '2026-06-05T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000509', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000005', '23350497-ca69-525f-b620-d61b88cb8670', '2e16f308-a4d9-590a-9823-1489edc087df', 9, 0, 0, 0, 0, 0.00, 3.0, 0, 24, 2, 9, 8.00, 0, 0, 0, '2026-06-05T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000510', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000005', '27d217d2-3af4-5405-a088-c7ef5ad6ac41', '2e16f308-a4d9-590a-9823-1489edc087df', null, 0, 0, 0, 0, 0.00, 3.2, 0, 47, 0, 4, 14.69, 0, 0, 0, '2026-06-05T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000511', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000005', 'e81c782b-8204-50d9-9e14-c0968343fe65', '2e16f308-a4d9-590a-9823-1489edc087df', null, 0, 0, 0, 0, 0.00, 2.0, 0, 21, 0, 2, 10.50, 0, 1, 0, '2026-06-05T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000512', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000005', 'd1aba495-c7db-5b97-850b-60e778095755', '42c007fa-6d22-56b0-981b-fae8db3c0483', 1, 20, 20, 2, 1, 100.00, 1.0, 0, 9, 1, 3, 9.00, 0, 0, 0, '2026-06-05T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000513', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000005', '5c41a2db-95b8-5fda-94cb-baf02e8545d3', '42c007fa-6d22-56b0-981b-fae8db3c0483', 2, 29, 18, 3, 2, 161.11, 0, 0, 0, 0, 0, 0.00, 1, 0, 0, '2026-06-05T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000514', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000005', '0fedfcd7-31fe-5be9-9e65-58daaf7d89e1', '42c007fa-6d22-56b0-981b-fae8db3c0483', 3, 60, 35, 4, 4, 171.43, 0, 0, 0, 0, 0, 0.00, 0, 0, 0, '2026-06-05T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000515', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000005', '8a5aad69-90e1-5713-b7f7-5bf83631cbc1', '42c007fa-6d22-56b0-981b-fae8db3c0483', 4, 52, 25, 2, 5, 208.00, 2.0, 0, 19, 0, 4, 9.50, 0, 0, 0, '2026-06-05T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000516', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000005', 'fe7efb2f-9244-58c6-a3fd-55f32427a875', '42c007fa-6d22-56b0-981b-fae8db3c0483', 5, 19, 7, 3, 1, 271.43, 2.0, 0, 15, 3, 5, 7.50, 0, 1, 0, '2026-06-05T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000517', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000005', '580812e1-bbb3-5071-8e0b-bc7ce717c1e2', '42c007fa-6d22-56b0-981b-fae8db3c0483', 6, 17, 8, 0, 2, 212.50, 0, 0, 0, 0, 0, 0.00, 1, 0, 0, '2026-06-05T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000518', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000005', '760c9582-173c-5107-8472-55496ef09cef', '42c007fa-6d22-56b0-981b-fae8db3c0483', null, 0, 0, 0, 0, 0.00, 3.0, 0, 22, 0, 9, 7.33, 1, 0, 0, '2026-06-05T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000519', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000005', '827fbd94-bf19-51e7-b3d8-24bca42f8d9b', '42c007fa-6d22-56b0-981b-fae8db3c0483', null, 0, 0, 0, 0, 0.00, 4.0, 0, 55, 0, 3, 13.75, 0, 1, 0, '2026-06-05T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000520', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000005', 'd98dae83-73f6-5b91-a61d-c3988fe29777', '42c007fa-6d22-56b0-981b-fae8db3c0483', null, 0, 0, 0, 0, 0.00, 4.0, 0, 33, 1, 6, 8.25, 0, 0, 0, '2026-06-05T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000521', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000005', '17b7067e-ff1f-5a30-955b-b01d8a27702a', '42c007fa-6d22-56b0-981b-fae8db3c0483', null, 0, 0, 0, 0, 0.00, 4.0, 0, 51, 1, 5, 12.75, 0, 0, 0, '2026-06-05T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000522', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000005', 'b5bd61ff-5683-51bb-b5f9-4c60259e25c5', '42c007fa-6d22-56b0-981b-fae8db3c0483', null, 0, 0, 0, 0, 0.00, 0, 0, 0, 0, 0, 0.00, 1, 2, 0, '2026-06-05T19:30:00');

commit;
