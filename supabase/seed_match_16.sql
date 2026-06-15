begin;

-- Match 16: Bundelkhand Bulls vs Malwa Stallions
-- Holkar Stadium, Indore | June 10, 2026 | 19:30:00
-- Bundelkhand Bulls won by 3 wickets with 5 balls remaining
-- Toss: Malwa Stallions won and chose to bat
-- Player of the Match: Shivang Kumar

insert into venues (id, venue_name, city, country, created_at)
values
  ('0b2128b7-a408-5c19-a6bf-cdd7c3ffa816', 'Holkar Stadium', 'Indore', 'India', '2026-06-10T19:30:00')
on conflict (venue_name) do update set
  city = excluded.city,
  country = excluded.country,
  created_at = excluded.created_at
;

-- Name corrections from the scorecard
update players set player_name = 'Harsh Gawli' where id = 'c8f284a8-e738-59e4-b7b5-ace9a37f6a2b';
update players set player_name = 'Shivang Kumar' where id = 'e0b867ba-e046-579b-854b-4bf09ce97592';
update players set player_name = 'Goutam Joshi' where id = '1259d056-9bad-51ef-8ab7-caf13adcbff6';
update players set player_name = 'Akhil Nigote Yadav' where id = '0fedfcd7-31fe-5be9-9e65-58daaf7d89e1';
update players set player_name = 'Ishan Choudhary' where id = '75d0d91b-b3b6-5f3c-88af-7db4e964d45c';

-- Players present in Match 16 scorecard but missing from seed.sql
insert into players (id, player_name, team_id, role, batting_style, bowling_style, created_at)
values
  ('f9e2b8a7-5d31-5a14-9f3e-24d240001313', 'Sachin Vishwakarma', '42c007fa-6d22-56b0-981b-fae8db3c0483', 'Batter', 'Right-hand bat', 'Right-arm medium', '2026-06-10T19:30:00'),
  ('f9e2b8a7-5d31-5a14-9f3e-24d240001616', 'Pawan Yadav', '42c007fa-6d22-56b0-981b-fae8db3c0483', 'Bowler', 'Right-hand bat', 'Right-arm medium', '2026-06-10T19:30:00')
on conflict (id) do update set
  player_name = excluded.player_name,
  team_id = excluded.team_id,
  role = excluded.role,
  batting_style = excluded.batting_style,
  bowling_style = excluded.bowling_style
;

delete from reports where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000016';
delete from player_match_stats where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000016';
delete from matches where id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000016';

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
  '8a9b4c2d-1f2e-4d3c-8a9b-24d240000016',
  '2026-06-10',
  '2026',
  'MPt20',
  16,
  '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff',   -- team_a/home: Bundelkhand Bulls
  '42c007fa-6d22-56b0-981b-fae8db3c0483',   -- team_b/away: Malwa Stallions
  '0b2128b7-a408-5c19-a6bf-cdd7c3ffa816',   -- Holkar Stadium
  '42c007fa-6d22-56b0-981b-fae8db3c0483',   -- toss winner: Malwa Stallions
  'bat',
  '42c007fa-6d22-56b0-981b-fae8db3c0483',   -- bat first: Malwa Stallions
  '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff',   -- bowl first: Bundelkhand Bulls
  215,
  5,
  20,
  219,
  7,
  19.1,
  '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff',   -- winner: Bundelkhand Bulls
  '42c007fa-6d22-56b0-981b-fae8db3c0483',   -- loser: Malwa Stallions
  'wickets',
  null,
  3,
  'e0b867ba-e046-579b-854b-4bf09ce97592',   -- Player of the Match: Shivang Kumar
  'Match 16 at Holkar Stadium, Indore. Bundelkhand Bulls won by 3 wickets with 5 balls remaining after chasing 219/7 in 19.1 overs against Malwa Stallions 215/5 in 20 overs. Toss: Malwa Stallions won and chose to bat. Umpires: Sachin Parashar and Pushpendra Singh. Third umpire: Rameez Khan. Reserve umpire: Vijendra Singh. Scorer: Dattatraya Varat. Referee: Manish Majithia. Ball type: Leather. Ball color: White.',
  '2026-06-10T19:30:00'
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
  -- Malwa Stallions batting: 215/5
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001601', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000016', 'b4fc481b-9d0c-5ffb-9bd7-576c9bbd0252', '42c007fa-6d22-56b0-981b-fae8db3c0483', 1, 40, 26, 7, 0, 153.85, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001602', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000016', '5c41a2db-95b8-5fda-94cb-baf02e8545d3', '42c007fa-6d22-56b0-981b-fae8db3c0483', 2, 81, 44, 5, 6, 184.09, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001603', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000016', '0fedfcd7-31fe-5be9-9e65-58daaf7d89e1', '42c007fa-6d22-56b0-981b-fae8db3c0483', 3, 33, 25, 3, 1, 132.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001604', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000016', 'fe7efb2f-9244-58c6-a3fd-55f32427a875', '42c007fa-6d22-56b0-981b-fae8db3c0483', 4, 25,  8, 1, 3, 312.50, 4.0, 0, 39, 0, 1,  9.75, 0, 0, 0, '2026-06-10T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001605', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000016', '580812e1-bbb3-5071-8e0b-bc7ce717c1e2', '42c007fa-6d22-56b0-981b-fae8db3c0483', 5,  8,  6, 2, 0, 133.33, 0, 0, 0, 0, 0, 0, 3, 0, 0, '2026-06-10T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001606', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000016', '760c9582-173c-5107-8472-55496ef09cef', '42c007fa-6d22-56b0-981b-fae8db3c0483', 6, 20, 10, 3, 1, 200.00, 3.0, 0, 31, 2, 8, 10.33, 1, 0, 0, '2026-06-10T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001607', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000016', '8a5aad69-90e1-5713-b7f7-5bf83631cbc1', '42c007fa-6d22-56b0-981b-fae8db3c0483', 7,  0,  1, 0, 0,   0.00, 4.0, 0, 37, 2, 8,  9.25, 1, 0, 0, '2026-06-10T19:30:00'),

  -- Malwa Stallions bowling vs Bundelkhand Bulls: 219/7
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001611', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000016', 'd98dae83-73f6-5b91-a61d-c3988fe29777', '42c007fa-6d22-56b0-981b-fae8db3c0483', null, 0, 0, 0, 0, 0, 2.0, 0, 40, 0, 3, 20.00, 0, 0, 0, '2026-06-10T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001612', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000016', '75d0d91b-b3b6-5f3c-88af-7db4e964d45c', '42c007fa-6d22-56b0-981b-fae8db3c0483', null, 0, 0, 0, 0, 0, 2.1, 0, 27, 0, 2, 12.86, 0, 1, 0, '2026-06-10T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001613', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000016', 'f9e2b8a7-5d31-5a14-9f3e-24d240001616', '42c007fa-6d22-56b0-981b-fae8db3c0483', null, 0, 0, 0, 0, 0, 4.0, 0, 44, 2, 3, 11.00, 0, 0, 0, '2026-06-10T19:30:00'),

  -- Bundelkhand Bulls batting: 219/7
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001621', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000016', '7f40be31-fc73-5139-a38d-5194608282e1', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 1, 22, 11, 2, 2, 200.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001622', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000016', 'c8f284a8-e738-59e4-b7b5-ace9a37f6a2b', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 2, 16, 19, 1, 0,  84.21, 0, 0, 0, 0, 0, 0, 1, 0, 0, '2026-06-10T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001623', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000016', 'e0b867ba-e046-579b-854b-4bf09ce97592', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 3, 65, 17, 7, 5, 382.35, 4.0, 0, 45, 2, 8, 11.25, 0, 0, 0, '2026-06-10T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001624', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000016', '7c3bef67-21bb-5f49-b72f-29484f10aa3c', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 4, 22, 22, 1, 0, 100.00, 0, 0, 0, 0, 0, 0, 1, 0, 0, '2026-06-10T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001625', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000016', '3a6cb1d7-9e68-5074-8653-b57573a9f9eb', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 5, 43, 21, 4, 3, 204.76, 0, 0, 0, 0, 0, 0, 1, 0, 0, '2026-06-10T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001626', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000016', '0746cd79-5361-5ef8-ad53-8df4ee43b5bc', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 6,  8,  7, 1, 0, 114.29, 4.0, 0, 21, 1, 9,  5.25, 1, 0, 0, '2026-06-10T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001627', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000016', '1259d056-9bad-51ef-8ab7-caf13adcbff6', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 7, 19, 12, 1, 1, 158.33, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001628', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000016', '660e82ef-f58e-562f-983e-53fc4a2d6b32', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 8, 17,  8, 1, 1, 212.50, 0, 0, 0, 0, 0, 0, 1, 0, 0, '2026-06-10T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001629', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000016', '2541f929-1c7b-5ec4-8e9d-6f8ae8f22ff8', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 9,  0,  0, 0, 0,   0.00, 4.0, 0, 41, 2, 9, 10.25, 0, 0, 0, '2026-06-10T19:30:00'),

  -- Bundelkhand Bulls bowling vs Malwa Stallions: 215/5
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001631', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000016', 'd07905cb-9b4f-594a-972d-ceedba4bf8a6', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', null, 0, 0, 0, 0, 0, 4.0, 0, 57, 0, 6, 14.25, 0, 0, 0, '2026-06-10T19:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001632', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000016', '16ec489b-ec1f-537d-bf0e-431af7a9e9f8', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', null, 0, 0, 0, 0, 0, 4.0, 0, 48, 0, 5, 12.00, 0, 0, 0, '2026-06-10T19:30:00');

commit;
