begin;

-- Match 18: Royal Nimar Eagles vs Malwa Stallions
-- Holkar Stadium, Indore | June 11, 2026 | 15:00:00
-- Royal Nimar Eagles won by 8 wickets with 62 balls remaining
-- Toss: Royal Nimar Eagles won and chose to field
-- Player of the Match: Parush Mandal

insert into venues (id, venue_name, city, country, created_at)
values
  ('0b2128b7-a408-5c19-a6bf-cdd7c3ffa816', 'Holkar Stadium', 'Indore', 'India', '2026-06-11T15:00:00')
on conflict (venue_name) do update set
  city = excluded.city,
  country = excluded.country,
  created_at = excluded.created_at
;

-- Name corrections from the scorecard
update players set player_name = 'Anand Bais' where id = 'c1ba6d40-d4f7-5671-97d7-da99594292a3';
update players set player_name = 'Devendra Katheit' where id = 'a2f37dda-00a0-556f-8c5d-8dfe0e16f418';
update players set player_name = 'Akhil Nigote Yadav' where id = '0fedfcd7-31fe-5be9-9e65-58daaf7d89e1';
update players set player_name = 'Rishabh Chouhan' where id = '580812e1-bbb3-5071-8e0b-bc7ce717c1e2';
update players set player_name = 'Ishan Choudhary' where id = '75d0d91b-b3b6-5f3c-88af-7db4e964d45c';

-- Player present in Match 18 scorecard but missing from seed.sql
insert into players (id, player_name, team_id, role, batting_style, bowling_style, created_at)
values
  ('f9e2b8a7-5d31-5a14-9f3e-24d240001313', 'Sachin Vishwakarma', '42c007fa-6d22-56b0-981b-fae8db3c0483', 'Batter', 'Right-hand bat', 'Right-arm medium', '2026-06-11T15:00:00')
on conflict (id) do update set
  player_name = excluded.player_name,
  team_id = excluded.team_id,
  role = excluded.role,
  batting_style = excluded.batting_style,
  bowling_style = excluded.bowling_style
;

delete from reports where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000018';
delete from player_match_stats where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000018';
delete from matches where id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000018';

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
  '8a9b4c2d-1f2e-4d3c-8a9b-24d240000018',
  '2026-06-11',
  '2026',
  'MPt20',
  18,
  '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada',   -- team_a/home: Royal Nimar Eagles
  '42c007fa-6d22-56b0-981b-fae8db3c0483',   -- team_b/away: Malwa Stallions
  '0b2128b7-a408-5c19-a6bf-cdd7c3ffa816',   -- Holkar Stadium
  '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada',   -- toss winner: Royal Nimar Eagles
  'field',
  '42c007fa-6d22-56b0-981b-fae8db3c0483',   -- bat first: Malwa Stallions
  '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada',   -- bowl first: Royal Nimar Eagles
  113,
  10,
  17.5,
  116,
  2,
  9.4,
  '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada',   -- winner: Royal Nimar Eagles
  '42c007fa-6d22-56b0-981b-fae8db3c0483',   -- loser: Malwa Stallions
  'wickets',
  null,
  8,
  'c2df7539-be90-5fcc-b9ee-bbaf45ea25c8',   -- Player of the Match: Parush Mandal
  'Match 18 at Holkar Stadium, Indore. Royal Nimar Eagles won by 8 wickets with 62 balls remaining after chasing 116/2 in 9.4 overs against Malwa Stallions 113 all out in 17.5 overs. Toss: Royal Nimar Eagles won and chose to field. Umpires: Abhishek Tomar and Nikhil Patwardhan. Third umpire: Ritika Buley. Reserve umpire: Parth Tomar. Scorer: Mayank Thanwar. Referee: Sanjeev Rao. Ball type: Leather. Ball color: White.',
  '2026-06-11T15:00:00'
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
  -- Malwa Stallions batting: 113 all out
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001801', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000018', 'b4fc481b-9d0c-5ffb-9bd7-576c9bbd0252', '42c007fa-6d22-56b0-981b-fae8db3c0483',  1,  0,  3, 0, 0,   0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-11T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001802', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000018', '5c41a2db-95b8-5fda-94cb-baf02e8545d3', '42c007fa-6d22-56b0-981b-fae8db3c0483',  2, 15, 10, 2, 1, 150.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-11T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001803', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000018', '0fedfcd7-31fe-5be9-9e65-58daaf7d89e1', '42c007fa-6d22-56b0-981b-fae8db3c0483',  3,  0,  2, 0, 0,   0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-11T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001804', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000018', '580812e1-bbb3-5071-8e0b-bc7ce717c1e2', '42c007fa-6d22-56b0-981b-fae8db3c0483',  4,  7, 10, 1, 0,  70.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-11T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001805', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000018', 'fe7efb2f-9244-58c6-a3fd-55f32427a875', '42c007fa-6d22-56b0-981b-fae8db3c0483',  5, 38, 24, 1, 4, 158.33, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-11T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001806', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000018', '8a5aad69-90e1-5713-b7f7-5bf83631cbc1', '42c007fa-6d22-56b0-981b-fae8db3c0483',  6, 15, 19, 2, 1,  78.95, 1.0, 0, 16, 0, 1, 16.00, 0, 0, 0, '2026-06-11T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001807', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000018', '760c9582-173c-5107-8472-55496ef09cef', '42c007fa-6d22-56b0-981b-fae8db3c0483',  7, 27, 19, 3, 1, 142.11, 1.0, 0, 10, 0, 2, 10.00, 0, 0, 0, '2026-06-11T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001808', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000018', 'f9e2b8a7-5d31-5a14-9f3e-24d240001313', '42c007fa-6d22-56b0-981b-fae8db3c0483',  8,  3, 12, 0, 0,  25.00, 1.4, 0, 10, 1, 3,  7.14, 0, 0, 0, '2026-06-11T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001809', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000018', '75d0d91b-b3b6-5f3c-88af-7db4e964d45c', '42c007fa-6d22-56b0-981b-fae8db3c0483',  9,  3,  6, 0, 0,  50.00, 2.0, 0, 27, 0, 4, 13.50, 1, 0, 0, '2026-06-11T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001810', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000018', '3d68aabb-51d3-51d6-9aa3-44c84c72caea', '42c007fa-6d22-56b0-981b-fae8db3c0483', 10,  0,  2, 0, 0,   0.00, 2.0, 0, 29, 0, 4, 14.50, 0, 0, 0, '2026-06-11T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001811', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000018', '17b7067e-ff1f-5a30-955b-b01d8a27702a', '42c007fa-6d22-56b0-981b-fae8db3c0483', 11,  0,  2, 0, 0,   0.00, 2.0, 0, 23, 1, 3, 11.50, 0, 0, 0, '2026-06-11T15:00:00'),

  -- Royal Nimar Eagles batting: 116/2
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001821', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000018', '8c2ac304-10da-5dbc-b8e4-db6753b7c2a8', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', 1, 11,  4, 1, 1, 275.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-11T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001822', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000018', 'b3959799-7ce4-5e1d-bedb-0612b04f822b', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', 2, 61, 27, 4, 6, 225.93, 0, 0, 0, 0, 0, 0, 1, 0, 0, '2026-06-11T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001823', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000018', '58201413-0f11-5f9f-9c43-5c1ce756ccf4', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', 3, 26, 19, 2, 1, 136.84, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-11T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001824', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000018', 'c1ba6d40-d4f7-5671-97d7-da99594292a3', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', 4, 16,  8, 0, 2, 200.00, 0, 0, 0, 0, 0, 0, 0, 1, 0, '2026-06-11T15:00:00'),

  -- Royal Nimar Eagles bowling vs Malwa Stallions: 113 all out
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001831', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000018', 'c2df7539-be90-5fcc-b9ee-bbaf45ea25c8', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', null, 0, 0, 0, 0, 0, 2.5, 1, 11, 5, 14,  4.40, 0, 0, 0, '2026-06-11T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001832', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000018', 'a2f37dda-00a0-556f-8c5d-8dfe0e16f418', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', null, 0, 0, 0, 0, 0, 4.0, 0, 15, 1, 15,  3.75, 0, 0, 0, '2026-06-11T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001833', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000018', 'cfae1e19-cece-5fcb-9ca0-c6b8ea455378', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', null, 0, 0, 0, 0, 0, 2.0, 0, 17, 0,  8,  8.50, 0, 0, 0, '2026-06-11T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001834', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000018', 'e3731702-dacf-5e6a-9e4c-55ee74432723', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', null, 0, 0, 0, 0, 0, 4.0, 0, 24, 1, 13,  6.00, 1, 0, 0, '2026-06-11T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001835', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000018', 'f7ac72c3-f544-5a78-b5b5-d57f962c6811', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', null, 0, 0, 0, 0, 0, 4.0, 0, 33, 2, 13,  8.25, 1, 0, 0, '2026-06-11T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001836', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000018', 'd15a9fe5-8630-5bd5-a764-7aebea809a9b', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', null, 0, 0, 0, 0, 0, 1.0, 0, 13, 0,  1, 13.00, 1, 0, 0, '2026-06-11T15:00:00');

commit;
