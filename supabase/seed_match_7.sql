begin;

-- Match 7: Indore Pink Panthers vs Jabalpur Royal Lions
-- Holkar Stadium, Indore | June 6, 2026 | 19:30:00
-- Jabalpur Royal Lions won by 5 wickets
-- Toss: Jabalpur Royal Lions won and chose to field
-- Player of the Match: Ritik Tada

insert into venues (id, venue_name, city, country, created_at)
values
  ('0b2128b7-a408-5c19-a6bf-cdd7c3ffa816', 'Holkar Stadium', 'Indore', 'India', '2026-06-06T19:30:00')
on conflict (venue_name) do update set
  city = excluded.city,
  country = excluded.country,
  created_at = excluded.created_at
;

-- Correct player/team display names where seed.sql differs from the scorecard
update teams set team_name = 'Indore Pink Panthers' where id = '582e73b3-b982-5677-b88b-d940deb2e79c';
update players set player_name = 'Atharv Joshi' where id = 'e934d378-43e4-5740-a2a1-abeda43b917e';
update players set player_name = 'Punit Datey' where id = '4d98b52f-c702-5ecb-9124-a36c23e956bc';
update players set player_name = 'Akarsh Parihar' where id = 'c92621ac-3bf1-5f82-b55e-215425cbb283';
update players set player_name = 'Nayan Mewada' where id = 'bb5c157d-7607-5723-9023-d11cc790cec7';

delete from reports where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000007';
delete from player_match_stats where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000007';
delete from matches where id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000007';

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
  '8a9b4c2d-1f2e-4d3c-8a9b-24d240000007',
  '2026-06-06',
  '2026',
  'MPt20',
  7,
  '582e73b3-b982-5677-b88b-d940deb2e79c',
  '834605bb-cc4a-5b89-88c7-218cbb32d6ab',
  '0b2128b7-a408-5c19-a6bf-cdd7c3ffa816',
  '834605bb-cc4a-5b89-88c7-218cbb32d6ab',
  'field',
  '582e73b3-b982-5677-b88b-d940deb2e79c',
  '834605bb-cc4a-5b89-88c7-218cbb32d6ab',
  148,
  8,
  20.0,
  149,
  5,
  18.0,
  '834605bb-cc4a-5b89-88c7-218cbb32d6ab',
  '582e73b3-b982-5677-b88b-d940deb2e79c',
  'wickets',
  null,
  5,
  '29993758-c857-5658-9114-cc74a26c1880',
  'Aditya Birla Group MP League T20 Match 7 at Holkar Stadium, Indore. Jabalpur Royal Lions won by 5 wickets with 12 balls remaining after chasing 149/5 in 18 overs against Indore Pink Panthers 148/8 in 20 overs. Toss: Jabalpur Royal Lions won and chose to field. Umpires: Manish Jain and Vijay Negi. Third umpire: Pushpendra Singh. Reserve umpire: Vyomkesh Tripathi. Scorer: Sunil Gupta. Referee: Sanjeev Rao. Ball type: Leather. Ball color: White. Phase: League.',
  '2026-06-06T19:30:00'
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
  -- Atharv Joshi (wk): c Abhishek Bhandari b Pankaj Patel | 8 (5)
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000701', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000007', 'e934d378-43e4-5740-a2a1-abeda43b917e', '582e73b3-b982-5677-b88b-d940deb2e79c', 1, 8, 5, 2, 0, 160.00, 0.0, 0, 0, 0, 0, 0.00, 2, 0, 0, '2026-06-06T19:30:00'),
  -- Siddarth Patidar: c Ajay Rohera b Punit Datey | 0 (1)
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000702', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000007', '21662ce5-2368-571f-8d64-26d735145aa5', '582e73b3-b982-5677-b88b-d940deb2e79c', 2, 0, 1, 0, 0, 0.00, 0.0, 0, 0, 0, 0, 0.00, 0, 0, 0, '2026-06-06T19:30:00'),
  -- Karan Tahliyani: c Abhishek Bhandari b Pankaj Patel | 4 (5)
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000703', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000007', 'b1507fce-9244-5c38-bf11-cfc4aa6461d8', '582e73b3-b982-5677-b88b-d940deb2e79c', 3, 4, 5, 0, 0, 80.00, 0.0, 0, 0, 0, 0, 0.00, 1, 0, 0, '2026-06-06T19:30:00'),
  -- Venkatesh Iyer (c): c Abhishek Bhandari b Rahul Batham | 33 (40)
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000704', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000007', 'f56a747c-cd41-5456-ab5d-60a273526bf4', '582e73b3-b982-5677-b88b-d940deb2e79c', 4, 33, 40, 3, 0, 82.50, 1.0, 0, 8, 0, 2, 8.00, 0, 0, 0, '2026-06-06T19:30:00'),
  -- Sidhant Agrawal: c Arpit Gaud b Rahul Batham | 15 (11)
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000705', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000007', '931345fe-8b9c-57fd-bb11-04cbf011a5c6', '582e73b3-b982-5677-b88b-d940deb2e79c', 5, 15, 11, 0, 1, 136.36, 3.0, 0, 25, 1, 5, 8.33, 1, 0, 0, '2026-06-06T19:30:00'),
  -- Saransh Surana: c Abhishek Bhandari b Ritik Tada | 22 (11)
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000706', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000007', 'd4a25b3f-0333-564f-bc8b-8e57a3b41a99', '582e73b3-b982-5677-b88b-d940deb2e79c', 6, 22, 11, 1, 2, 200.00, 1.0, 0, 18, 0, 2, 18.00, 1, 0, 0, '2026-06-06T19:30:00'),
  -- Shubham Rathore: not out | 24 (19)
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000707', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000007', '64e22a56-f1ff-59a6-91b3-6b88e9d0cdeb', '582e73b3-b982-5677-b88b-d940deb2e79c', 7, 24, 19, 2, 1, 126.32, 0.0, 0, 0, 0, 0, 0.00, 0, 0, 0, '2026-06-06T19:30:00'),
  -- Anvesh Chawla: run out (Rahul Batham/Ajay Rohera) | 8 (6)
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000708', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000007', '9b8ce6e3-bb3b-56d0-8930-9c503e517e4d', '582e73b3-b982-5677-b88b-d940deb2e79c', 8, 8, 6, 2, 0, 133.33, 3.0, 0, 28, 1, 9, 9.33, 0, 0, 0, '2026-06-06T19:30:00'),
  -- Shivam Shukla: b Pankaj Patel | 28 (20)
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000709', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000007', '8c118ea4-e9c1-5620-a56e-885ee57dbd4a', '582e73b3-b982-5677-b88b-d940deb2e79c', 9, 28, 20, 4, 1, 140.00, 3.0, 0, 33, 0, 4, 11.00, 0, 0, 0, '2026-06-06T19:30:00'),
  -- Vishnu Bhardwaj: not out | 0 (2)
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000710', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000007', 'd52da864-1c4f-53e1-b7b4-94fc1879d773', '582e73b3-b982-5677-b88b-d940deb2e79c', 10, 0, 2, 0, 0, 0.00, 3.0, 0, 14, 1, 5, 4.67, 0, 0, 0, '2026-06-06T19:30:00'),
  -- Roshan Kewat: did not bat; 4.0-1-22-2
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000711', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000007', 'c8d836da-3c55-5fa1-b68a-2989f45aab44', '582e73b3-b982-5677-b88b-d940deb2e79c', null, 0, 0, 0, 0, 0.00, 4.0, 1, 22, 2, 16, 5.50, 0, 0, 0, '2026-06-06T19:30:00'),
  -- Arpit Gaud: c Karan Tahliyani b Anvesh Chawla | 0 (7)
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000712', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000007', 'fab398ff-2405-564f-8d25-4e33023b20e6', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', 1, 0, 7, 0, 0, 0.00, 0.0, 0, 0, 0, 0, 0.00, 1, 0, 0, '2026-06-06T19:30:00'),
  -- Ajay Rohera (wk): c Atharv Joshi b Vishnu Bhardwaj | 51 (41)
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000713', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000007', 'af9615ee-2603-5400-92a5-834a5d2719e9', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', 2, 51, 41, 4, 2, 124.39, 0.0, 0, 0, 0, 0, 0.00, 1, 1, 0, '2026-06-06T19:30:00'),
  -- Abhishek Bhandari: c Saransh Surana b Roshan Kewat | 6 (3)
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000714', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000007', 'e9ab0e02-e7e6-5595-b7d0-8bb2891e2c4a', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', 3, 6, 3, 0, 1, 200.00, 0.0, 0, 0, 0, 0, 0.00, 4, 0, 0, '2026-06-06T19:30:00'),
  -- Akarsh Parihar: c Atharv Joshi b Sidhant Agrawal | 14 (14)
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000715', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000007', 'c92621ac-3bf1-5f82-b55e-215425cbb283', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', 4, 14, 14, 2, 1, 100.00, 0.0, 0, 0, 0, 0, 0.00, 0, 0, 0, '2026-06-06T19:30:00'),
  -- Ritik Tada: c Sidhant Agrawal b Roshan Kewat | 47 (27)
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000716', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000007', '29993758-c857-5658-9114-cc74a26c1880', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', 5, 47, 27, 3, 3, 174.07, 1.0, 0, 16, 1, 1, 16.00, 0, 0, 0, '2026-06-06T19:30:00'),
  -- Sanjog Nijjar: not out | 23 (13)
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000717', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000007', '14819b05-062e-56b6-a956-bc5711eb6673', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', 6, 23, 13, 1, 2, 176.92, 0.0, 0, 0, 0, 0, 0.00, 0, 0, 0, '2026-06-06T19:30:00'),
  -- Rahul Batham (c): not out | 3 (3)
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000718', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000007', '1f44fb2f-bd66-5467-bf4d-085daeb7c176', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', 7, 3, 3, 0, 0, 100.00, 4.0, 0, 39, 2, 8, 9.75, 0, 1, 0, '2026-06-06T19:30:00'),
  -- Nayan Mewada: did not bat; 3.0-0-21-0
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000719', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000007', 'bb5c157d-7607-5723-9023-d11cc790cec7', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', null, 0, 0, 0, 0, 0.00, 3.0, 0, 21, 0, 9, 7.00, 0, 0, 0, '2026-06-06T19:30:00'),
  -- Akshay Sharma: did not bat; 4.0-0-22-0
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000720', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000007', '03029869-5b08-58a5-8ba2-6af1ed546d6a', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', null, 0, 0, 0, 0, 0.00, 4.0, 0, 22, 0, 8, 5.50, 0, 0, 0, '2026-06-06T19:30:00'),
  -- Pankaj Patel: did not bat; 4.0-0-30-3
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000721', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000007', '0bc71b97-5af4-586d-96fb-ecbaa7affaab', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', null, 0, 0, 0, 0, 0.00, 4.0, 0, 30, 3, 9, 7.50, 0, 0, 0, '2026-06-06T19:30:00'),
  -- Punit Datey: did not bat; 4.0-0-18-1
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000722', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000007', '4d98b52f-c702-5ecb-9124-a36c23e956bc', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', null, 0, 0, 0, 0, 0.00, 4.0, 0, 18, 1, 15, 4.50, 0, 0, 0, '2026-06-06T19:30:00');

commit;
