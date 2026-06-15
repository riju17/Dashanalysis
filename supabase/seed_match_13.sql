begin;

-- Match 13: Malwa Stallions vs Indore Pink Panthers
-- Holkar Stadium, Indore | June 8, 2026 | 19:30:00
-- Indore Pink Panthers won by 31 runs
-- Toss: Indore Pink Panthers won and chose to bat
-- Player of the Match: Shivam Shukla

insert into venues (id, venue_name, city, country, created_at)
values
  ('0b2128b7-a408-5c19-a6bf-cdd7c3ffa816', 'Holkar Stadium', 'Indore', 'India', '2026-06-08T19:30:00')
on conflict (venue_name) do update set
  city = excluded.city,
  country = excluded.country,
  created_at = excluded.created_at
;

-- Name corrections from the scorecard
update players set player_name = 'Atharv Joshi' where id = 'e934d378-43e4-5740-a2a1-abeda43b917e';
update players set player_name = 'Siddarth Patidar' where id = '21662ce5-2368-571f-8d64-26d735145aa5';
update players set player_name = 'Akhil Nigote Yadav' where id = '0fedfcd7-31fe-5be9-9e65-58daaf7d89e1';
update players set player_name = 'Rishabh Chouhan' where id = '580812e1-bbb3-5071-8e0b-bc7ce717c1e2';
update players set player_name = 'Harshvardhan Singh' where id = '827fbd94-bf19-51e7-b3d8-24bca42f8d9b';

-- Player present in Match 13 scorecard but missing from seed.sql
insert into players (id, player_name, team_id, role, batting_style, bowling_style, created_at)
values
  ('f9e2b8a7-5d31-5a14-9f3e-24d240001313', 'Sachin Vishwakarma', '42c007fa-6d22-56b0-981b-fae8db3c0483', 'Batter', 'Right-hand bat', 'Right-arm medium', '2026-06-08T19:30:00')
on conflict (id) do update set
  player_name = excluded.player_name,
  team_id = excluded.team_id,
  role = excluded.role,
  batting_style = excluded.batting_style,
  bowling_style = excluded.bowling_style
;

delete from reports where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000013';
delete from player_match_stats where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000013';
delete from matches where id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000013';

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
  '8a9b4c2d-1f2e-4d3c-8a9b-24d240000013',
  '2026-06-08',
  '2026',
  'MPt20',
  13,
  '42c007fa-6d22-56b0-981b-fae8db3c0483',   -- team_a/home: Malwa Stallions
  '582e73b3-b982-5677-b88b-d940deb2e79c',   -- team_b/away: Indore Pink Panthers
  '0b2128b7-a408-5c19-a6bf-cdd7c3ffa816',   -- Holkar Stadium
  '582e73b3-b982-5677-b88b-d940deb2e79c',   -- toss winner: Indore Pink Panthers
  'bat',
  '582e73b3-b982-5677-b88b-d940deb2e79c',   -- bat first: Indore Pink Panthers
  '42c007fa-6d22-56b0-981b-fae8db3c0483',   -- bowl first: Malwa Stallions
  229,
  5,
  20,
  198,
  9,
  20,
  '582e73b3-b982-5677-b88b-d940deb2e79c',   -- winner: Indore Pink Panthers
  '42c007fa-6d22-56b0-981b-fae8db3c0483',   -- loser: Malwa Stallions
  'runs',
  31,
  null,
  '8c118ea4-e9c1-5620-a56e-885ee57dbd4a',   -- Player of the Match: Shivam Shukla
  'Match 13 at Holkar Stadium, Indore. Indore Pink Panthers won by 31 runs after posting 229/5 in 20 overs and restricting Malwa Stallions to 198/9 in 20 overs. Toss: Indore Pink Panthers won and chose to bat. Umpires: Sachin Parashar and Ritika Buley. Third umpire: Nikhil Patwardhan. Reserve umpire: Rameez Khan. Scorer: Sunil Gupta. Referee: Sanjeev Rao. Ball type: Leather. Ball color: White.',
  '2026-06-08T19:30:00'
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
  -- Indore Pink Panthers batting: 229/5
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001301', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000013', 'e934d378-43e4-5740-a2a1-abeda43b917e', '582e73b3-b982-5677-b88b-d940deb2e79c', 1, 45, 20, 5, 3, 225.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001302', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000013', '21662ce5-2368-571f-8d64-26d735145aa5', '582e73b3-b982-5677-b88b-d940deb2e79c', 2,  2, 10, 0, 0,  20.00, 0, 0, 0, 0, 0, 0, 2, 0, 0, '2026-06-08T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001303', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000013', 'b1507fce-9244-5c38-bf11-cfc4aa6461d8', '582e73b3-b982-5677-b88b-d940deb2e79c', 3, 50, 39, 5, 2, 128.21, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001304', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000013', '9b8ce6e3-bb3b-56d0-8930-9c503e517e4d', '582e73b3-b982-5677-b88b-d940deb2e79c', 4, 23, 12, 3, 1, 191.67, 0, 0, 0, 0, 0, 0, 2, 0, 0, '2026-06-08T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001305', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000013', 'f56a747c-cd41-5456-ab5d-60a273526bf4', '582e73b3-b982-5677-b88b-d940deb2e79c', 5, 54, 22, 1, 6, 245.45, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001306', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000013', 'd4a25b3f-0333-564f-bc8b-8e57a3b41a99', '582e73b3-b982-5677-b88b-d940deb2e79c', 6, 50, 17, 3, 5, 294.12, 0, 0, 0, 0, 0, 0, 1, 0, 0, '2026-06-08T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001307', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000013', '64e22a56-f1ff-59a6-91b3-6b88e9d0cdeb', '582e73b3-b982-5677-b88b-d940deb2e79c', 7,  0,  0, 0, 0,   0.00, 0, 0, 0, 0, 0, 0, 1, 0, 0, '2026-06-08T19:30:00'),

  -- Indore Pink Panthers bowling vs Malwa Stallions: 198/9
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001311', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000013', 'c8d836da-3c55-5fa1-b68a-2989f45aab44', '582e73b3-b982-5677-b88b-d940deb2e79c', null, 0, 0, 0, 0, 0, 3.0, 0, 42, 1,  6, 14.00, 0, 0, 0, '2026-06-08T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001312', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000013', '9b8ce6e3-bb3b-56d0-8930-9c503e517e4d', '582e73b3-b982-5677-b88b-d940deb2e79c', null, 0, 0, 0, 0, 0, 4.0, 0, 38, 1, 11,  9.50, 0, 0, 0, '2026-06-08T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001313', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000013', '931345fe-8b9c-57fd-bb11-04cbf011a5c6', '582e73b3-b982-5677-b88b-d940deb2e79c', null, 0, 0, 0, 0, 0, 3.0, 0, 36, 0,  6, 12.00, 1, 0, 0, '2026-06-08T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001314', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000013', 'd52da864-1c4f-53e1-b7b4-94fc1879d773', '582e73b3-b982-5677-b88b-d940deb2e79c', null, 0, 0, 0, 0, 0, 1.0, 0,  9, 0,  3,  9.00, 1, 0, 0, '2026-06-08T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001315', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000013', 'f56a747c-cd41-5456-ab5d-60a273526bf4', '582e73b3-b982-5677-b88b-d940deb2e79c', null, 0, 0, 0, 0, 0, 4.0, 0, 25, 1,  9,  6.25, 0, 0, 0, '2026-06-08T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001316', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000013', '8c118ea4-e9c1-5620-a56e-885ee57dbd4a', '582e73b3-b982-5677-b88b-d940deb2e79c', null, 0, 0, 0, 0, 0, 4.0, 1, 27, 5, 13,  6.75, 0, 0, 0, '2026-06-08T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001317', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000013', 'd4a25b3f-0333-564f-bc8b-8e57a3b41a99', '582e73b3-b982-5677-b88b-d940deb2e79c', null, 0, 0, 0, 0, 0, 1.0, 0, 21, 1,  1, 21.00, 0, 0, 0, '2026-06-08T19:30:00'),

  -- Malwa Stallions batting: 198/9
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001321', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000013', 'd1aba495-c7db-5b97-850b-60e778095755', '42c007fa-6d22-56b0-981b-fae8db3c0483',  1, 10,  5, 1, 1, 200.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001322', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000013', '5c41a2db-95b8-5fda-94cb-baf02e8545d3', '42c007fa-6d22-56b0-981b-fae8db3c0483',  2, 31, 19, 5, 1, 163.16, 0, 0, 0, 0, 0, 0, 2, 0, 0, '2026-06-08T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001323', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000013', 'f9e2b8a7-5d31-5a14-9f3e-24d240001313', '42c007fa-6d22-56b0-981b-fae8db3c0483',  3, 47, 32, 4, 2, 146.88, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001324', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000013', '0fedfcd7-31fe-5be9-9e65-58daaf7d89e1', '42c007fa-6d22-56b0-981b-fae8db3c0483',  4,  3,  6, 0, 0,  50.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001325', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000013', '580812e1-bbb3-5071-8e0b-bc7ce717c1e2', '42c007fa-6d22-56b0-981b-fae8db3c0483',  5,  9,  7, 0, 1, 128.57, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001326', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000013', 'fe7efb2f-9244-58c6-a3fd-55f32427a875', '42c007fa-6d22-56b0-981b-fae8db3c0483',  6,  5,  9, 1, 0,  55.56, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001327', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000013', '760c9582-173c-5107-8472-55496ef09cef', '42c007fa-6d22-56b0-981b-fae8db3c0483',  7, 54, 28, 4, 4, 192.86, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001328', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000013', '8a5aad69-90e1-5713-b7f7-5bf83631cbc1', '42c007fa-6d22-56b0-981b-fae8db3c0483',  8,  7,  8, 1, 0,  87.50, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001329', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000013', 'b5bd61ff-5683-51bb-b5f9-4c60259e25c5', '42c007fa-6d22-56b0-981b-fae8db3c0483',  9,  6,  2, 0, 1, 300.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001330', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000013', '827fbd94-bf19-51e7-b3d8-24bca42f8d9b', '42c007fa-6d22-56b0-981b-fae8db3c0483', 10,  9,  4, 2, 0, 225.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001331', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000013', 'd98dae83-73f6-5b91-a61d-c3988fe29777', '42c007fa-6d22-56b0-981b-fae8db3c0483', 11,  0,  1, 0, 0,   0.00, 0, 0, 0, 0, 0, 0, 2, 0, 0, '2026-06-08T19:30:00'),

  -- Malwa Stallions bowling vs Indore Pink Panthers: 229/5
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001341', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000013', '760c9582-173c-5107-8472-55496ef09cef', '42c007fa-6d22-56b0-981b-fae8db3c0483', null, 0, 0, 0, 0, 0, 4.0, 0, 38, 2, 10,  9.50, 0, 0, 0, '2026-06-08T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001342', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000013', '8a5aad69-90e1-5713-b7f7-5bf83631cbc1', '42c007fa-6d22-56b0-981b-fae8db3c0483', null, 0, 0, 0, 0, 0, 2.0, 0, 22, 0,  3, 11.00, 0, 0, 0, '2026-06-08T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001343', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000013', 'd98dae83-73f6-5b91-a61d-c3988fe29777', '42c007fa-6d22-56b0-981b-fae8db3c0483', null, 0, 0, 0, 0, 0, 4.0, 1, 41, 2,  8, 10.25, 0, 0, 0, '2026-06-08T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001344', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000013', '827fbd94-bf19-51e7-b3d8-24bca42f8d9b', '42c007fa-6d22-56b0-981b-fae8db3c0483', null, 0, 0, 0, 0, 0, 4.0, 0, 70, 0,  5, 17.50, 0, 0, 0, '2026-06-08T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001345', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000013', 'd1aba495-c7db-5b97-850b-60e778095755', '42c007fa-6d22-56b0-981b-fae8db3c0483', null, 0, 0, 0, 0, 0, 2.0, 0, 23, 0,  3, 11.50, 0, 0, 0, '2026-06-08T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001346', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000013', 'fe7efb2f-9244-58c6-a3fd-55f32427a875', '42c007fa-6d22-56b0-981b-fae8db3c0483', null, 0, 0, 0, 0, 0, 4.0, 0, 32, 1,  6,  8.00, 0, 0, 0, '2026-06-08T19:30:00');

commit;
