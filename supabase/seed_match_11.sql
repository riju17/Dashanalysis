begin;

-- Match 11: Bundelkhand Bulls vs Bhopal Leopards
insert into venues (id, venue_name, city, country, created_at)
values
  ('6d2f4b21-7c5e-4a4a-9f31-24e71f0d2401', 'Daly College Ground', 'Indore', 'India', '2026-06-08T14:30:00')
on conflict (venue_name) do update set
  city = excluded.city,
  country = excluded.country,
  created_at = excluded.created_at
;

-- Name corrections from scorecard screenshots
update players set player_name = 'Harsh Gawli' where id = 'c8f284a8-e738-59e4-b7b5-ace9a37f6a2b';
update players set player_name = 'Shivang Kumar' where id = 'e0b867ba-e046-579b-854b-4bf09ce97592';
update players set player_name = 'Pranjul Puri' where id = 'a1a052ca-de3c-5bc8-811f-fb5b9c0ca160';

-- Player present in Match 11 scorecard but missing from seed.sql
insert into players (id, player_name, team_id, role, batting_style, bowling_style, created_at)
values
  ('f9e2b8a7-5d31-5a14-9f3e-24d240001111', 'Priyanshu Shukla', '89c8bea7-a025-55f9-8858-3b1220253648', 'All-rounder', 'Right-hand bat', 'Right-arm medium fast', '2026-06-08T14:30:00')
on conflict (id) do update set
  player_name = excluded.player_name,
  team_id = excluded.team_id,
  role = excluded.role,
  batting_style = excluded.batting_style,
  bowling_style = excluded.bowling_style
;

delete from reports where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000011';
delete from player_match_stats where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000011';
delete from matches where id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000011';

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
  '8a9b4c2d-1f2e-4d3c-8a9b-24d240000011',
  '2026-06-08',
  '2026',
  'MPt20',
  11,
  '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff',
  '89c8bea7-a025-55f9-8858-3b1220253648',
  '6d2f4b21-7c5e-4a4a-9f31-24e71f0d2401',
  '89c8bea7-a025-55f9-8858-3b1220253648',
  'bat',
  '89c8bea7-a025-55f9-8858-3b1220253648',
  '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff',
  197,
  3,
  20,
  201,
  4,
  18.5,
  '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff',
  '89c8bea7-a025-55f9-8858-3b1220253648',
  'wickets',
  null,
  6,
  '7c3bef67-21bb-5f49-b72f-29484f10aa3c',
  'Match 11 at Daly College Ground, Indore. Bundelkhand Bulls won by 6 wickets with 7 balls remaining after chasing 201/4 in 18.5 overs against Bhopal Leopards 197/3. Toss: Bhopal Leopards won and chose to bat. Umpires: Rajesh Timane and Rohan Shrivastava. Third umpire: Pushpendra Singh. Reserve umpire: Vyomkesh Tripathi. Scorer: Amit Parkhe. Referee: Manish Majithia. Ball type: Leather. Ball color: White.',
  '2026-06-08T14:30:00'
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
  -- Bhopal Leopards batting
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001101', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000011', 'fcb64b16-e1c9-5810-8b52-311c6dc0dab0', '89c8bea7-a025-55f9-8858-3b1220253648', 1, 8, 7, 1, 0, 114.29, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T14:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001102', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000011', 'a652e185-c0c1-5361-9b36-14f575b0c276', '89c8bea7-a025-55f9-8858-3b1220253648', 2, 33, 32, 3, 1, 103.13, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T14:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001103', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000011', '15915c22-37bb-5f32-8ffe-ebd791791ed5', '89c8bea7-a025-55f9-8858-3b1220253648', 3, 9, 8, 1, 0, 112.50, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T14:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001104', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000011', 'df7c6a07-1ed8-5d13-b601-f52736f8d7d6', '89c8bea7-a025-55f9-8858-3b1220253648', 4, 57, 37, 3, 4, 154.05, 1.0, 0, 13, 0, 3, 13.00, 0, 0, 0, '2026-06-08T14:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001105', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000011', 'bdfb9f70-ac54-5c21-b013-cc0c4ad44b45', '89c8bea7-a025-55f9-8858-3b1220253648', 5, 85, 39, 5, 9, 217.95, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T14:30:00'),

  -- Bhopal Leopards bowling
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001111', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000011', '175f38b8-8402-57e3-a9ac-296f10ea624a', '89c8bea7-a025-55f9-8858-3b1220253648', null, 0, 0, 0, 0, 0, 3.5, 0, 37, 1, 8, 10.57, 0, 0, 0, '2026-06-08T14:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001112', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000011', '8b2e24fd-e479-578d-928a-40a1ff1cf63e', '89c8bea7-a025-55f9-8858-3b1220253648', null, 0, 0, 0, 0, 0, 3.0, 0, 35, 0, 4, 11.67, 0, 0, 0, '2026-06-08T14:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001113', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000011', 'f9e2b8a7-5d31-5a14-9f3e-24d240001111', '89c8bea7-a025-55f9-8858-3b1220253648', null, 0, 0, 0, 0, 0, 4.0, 0, 33, 1, 8, 8.25, 0, 0, 0, '2026-06-08T14:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001114', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000011', 'a1a052ca-de3c-5bc8-811f-fb5b9c0ca160', '89c8bea7-a025-55f9-8858-3b1220253648', null, 0, 0, 0, 0, 0, 3.0, 0, 41, 1, 4, 13.67, 0, 0, 0, '2026-06-08T14:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001115', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000011', '332c919b-7eac-5035-8014-dcc5dce42255', '89c8bea7-a025-55f9-8858-3b1220253648', null, 0, 0, 0, 0, 0, 3.0, 0, 28, 1, 5, 9.33, 0, 0, 0, '2026-06-08T14:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001116', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000011', 'e8d4cbc5-c3e3-5276-ac3b-a3c363258fb3', '89c8bea7-a025-55f9-8858-3b1220253648', null, 0, 0, 0, 0, 0, 1.0, 0, 11, 0, 2, 11.00, 0, 0, 0, '2026-06-08T14:30:00'),

  -- Bundelkhand Bulls batting
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001121', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000011', '7f40be31-fc73-5139-a38d-5194608282e1', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 1, 1, 3, 0, 0, 33.33, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T14:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001122', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000011', 'c8f284a8-e738-59e4-b7b5-ace9a37f6a2b', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 2, 37, 31, 5, 0, 119.35, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T14:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001123', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000011', 'e0b867ba-e046-579b-854b-4bf09ce97592', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 3, 8, 9, 0, 1, 88.89, 4.0, 0, 30, 1, 6, 7.50, 0, 0, 0, '2026-06-08T14:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001124', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000011', '7c3bef67-21bb-5f49-b72f-29484f10aa3c', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 4, 101, 53, 9, 6, 190.57, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-08T14:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001125', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000011', '3a6cb1d7-9e68-5074-8653-b57573a9f9eb', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 5, 11, 4, 1, 1, 275.00, 2.0, 0, 29, 0, 4, 14.50, 0, 0, 0, '2026-06-08T14:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001126', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000011', '0746cd79-5361-5ef8-ad53-8df4ee43b5bc', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 6, 29, 13, 3, 2, 223.08, 2.0, 0, 13, 0, 4, 6.50, 0, 0, 0, '2026-06-08T14:30:00'),

  -- Bundelkhand Bulls bowling
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001131', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000011', '2541f929-1c7b-5ec4-8e9d-6f8ae8f22ff8', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', null, 0, 0, 0, 0, 0, 4.0, 0, 38, 1, 8, 9.50, 0, 0, 0, '2026-06-08T14:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001132', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000011', 'd07905cb-9b4f-594a-972d-ceedba4bf8a6', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', null, 0, 0, 0, 0, 0, 4.0, 0, 47, 0, 8, 11.75, 0, 0, 0, '2026-06-08T14:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240001133', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000011', '16ec489b-ec1f-537d-bf0e-431af7a9e9f8', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', null, 0, 0, 0, 0, 0, 4.0, 0, 40, 1, 12, 10.00, 0, 0, 0, '2026-06-08T14:30:00');

commit;
