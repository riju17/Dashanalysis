begin;

-- Match 6: Bundelkhand Bulls vs Rewa Jaguars
-- Holkar Stadium, Indore | June 6, 2026 | 15:00:00
-- Rewa Jaguars won by 9 wickets with 89 balls remaining
-- Toss: Rewa Jaguars won and chose to field
-- Player of the Match: Ramveer Singh Gurjar

insert into venues (id, venue_name, city, country, created_at)
values
  ('0b2128b7-a408-5c19-a6bf-cdd7c3ffa816', 'Holkar Stadium', 'Indore', 'India', '2026-06-06T15:00:00')
on conflict (venue_name) do update set
  city = excluded.city,
  country = excluded.country,
  created_at = excluded.created_at
;

-- Name corrections from the scorecard
update players set player_name = 'Harsh Gawli' where id = 'c8f284a8-e738-59e4-b7b5-ace9a37f6a2b';
update players set player_name = 'Shivang Kumar' where id = 'e0b867ba-e046-579b-854b-4bf09ce97592';
update players set player_name = 'Goutam Joshi' where id = '1259d056-9bad-51ef-8ab7-caf13adcbff6';
update players set player_name = 'Sagar Solanki' where id = 'c30ccf9b-cb5c-55cb-9266-d50ec530797d';
update players set player_name = 'Ankit Kushwah' where id = 'd1b49b26-555f-569a-87eb-f55a7443c614';
update players set player_name = 'Naveen Chouhan' where id = 'a4edd760-ef34-5814-bb32-3e3a238042e2';
update players set player_name = 'Ramveer Singh Gurjar' where id = 'a8bcd523-2f54-5dbe-bc14-55c5d83c4bf7';

delete from reports where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000006';
delete from player_match_stats where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000006';
delete from matches where id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000006';

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
  '8a9b4c2d-1f2e-4d3c-8a9b-24d240000006',
  '2026-06-06',
  '2026',
  'MPt20',
  6,
  '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff',
  'd1962402-4148-5a80-b691-75d24e750af1',
  '0b2128b7-a408-5c19-a6bf-cdd7c3ffa816',
  'd1962402-4148-5a80-b691-75d24e750af1',
  'field',
  '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff',
  'd1962402-4148-5a80-b691-75d24e750af1',
  74,
  10,
  15.3,
  76,
  1,
  5.1,
  'd1962402-4148-5a80-b691-75d24e750af1',
  '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff',
  'wickets',
  null,
  9,
  'a8bcd523-2f54-5dbe-bc14-55c5d83c4bf7',
  'Aditya Birla Group MP League T20 Match 6 at Holkar Stadium, Indore. Rewa Jaguars won by 9 wickets with 89 balls remaining after chasing 76/1 in 5.1 overs against Bundelkhand Bulls 74 all out in 15.3 overs. Toss: Rewa Jaguars won and chose to field. Umpires: Nikhil Menon and Vijay Negi. Third umpire: Pushpendra Singh. Reserve umpire: Vyomkesh Tripathi. Scorer: Sunil Gupta. Referee: Sanjeev Rao. Ball type: Leather. Ball color: White. Phase: League.',
  '2026-06-06T15:00:00'
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
  -- Bundelkhand Bulls batting + bowling/fielding
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000601', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000006', '7f40be31-fc73-5139-a38d-5194608282e1', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 1, 9, 8, 0, 1, 112.50, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-06T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000602', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000006', 'c8f284a8-e738-59e4-b7b5-ace9a37f6a2b', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 2, 0, 1, 0, 0, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-06T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000603', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000006', '449bf9a5-34b1-52c1-9b27-9378f96cf184', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 3, 9, 10, 1, 0, 90.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-06T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000604', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000006', '7c3bef67-21bb-5f49-b72f-29484f10aa3c', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 4, 25, 30, 3, 0, 83.33, 0, 0, 0, 0, 0, 0, 1, 0, 0, '2026-06-06T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000605', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000006', '3a6cb1d7-9e68-5074-8653-b57573a9f9eb', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 5, 5, 7, 0, 0, 71.43, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-06T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000606', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000006', 'e0b867ba-e046-579b-854b-4bf09ce97592', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 6, 5, 11, 0, 0, 45.45, 1.1, 0, 9, 1, 3, 8.18, 0, 0, 0, '2026-06-06T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000607', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000006', '660e82ef-f58e-562f-983e-53fc4a2d6b32', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 7, 3, 5, 0, 0, 60.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-06T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000608', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000006', '0746cd79-5361-5ef8-ad53-8df4ee43b5bc', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 8, 7, 7, 0, 1, 100.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-06T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000609', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000006', '1259d056-9bad-51ef-8ab7-caf13adcbff6', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 9, 3, 8, 0, 0, 37.50, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-06T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000610', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000006', '2541f929-1c7b-5ec4-8e9d-6f8ae8f22ff8', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 10, 5, 4, 1, 0, 125.00, 2.0, 0, 27, 0, 3, 13.50, 1, 0, 0, '2026-06-06T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000611', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000006', '16ec489b-ec1f-537d-bf0e-431af7a9e9f8', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 11, 1, 2, 0, 0, 50.00, 2.0, 0, 39, 0, 1, 19.50, 0, 0, 0, '2026-06-06T15:00:00'),

  -- Rewa Jaguars batting + bowling/fielding
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000612', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000006', '8ec8ffda-bfdc-54de-89d4-85e3d75f1ab3', 'd1962402-4148-5a80-b691-75d24e750af1', 1, 20, 11, 2, 1, 181.82, 1.3, 0, 5, 2, 5, 3.85, 0, 0, 0, '2026-06-06T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000613', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000006', '14285295-0308-5eed-abb1-b4c02962a013', 'd1962402-4148-5a80-b691-75d24e750af1', 2, 42, 14, 4, 4, 300.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-06T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000614', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000006', 'c30ccf9b-cb5c-55cb-9266-d50ec530797d', 'd1962402-4148-5a80-b691-75d24e750af1', 3, 13, 6, 1, 1, 216.67, 3.0, 0, 9, 2, 12, 3.00, 0, 0, 0, '2026-06-06T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000615', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000006', 'a8bcd523-2f54-5dbe-bc14-55c5d83c4bf7', 'd1962402-4148-5a80-b691-75d24e750af1', null, 0, 0, 0, 0, 0, 2.3, 0, 16, 3, 8, 6.96, 0, 0, 0, '2026-06-06T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000616', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000006', 'cbdf43c9-cbd8-5235-936c-14d31366433c', 'd1962402-4148-5a80-b691-75d24e750af1', null, 0, 0, 0, 0, 0, 4.0, 0, 17, 2, 12, 4.25, 0, 0, 0, '2026-06-06T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000617', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000006', '2b2f93bb-fe9d-5b14-abb3-6a5fe6c1a9c8', 'd1962402-4148-5a80-b691-75d24e750af1', null, 0, 0, 0, 0, 0, 2.0, 0, 12, 0, 5, 6.00, 1, 0, 0, '2026-06-06T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000618', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000006', 'd1b49b26-555f-569a-87eb-f55a7443c614', 'd1962402-4148-5a80-b691-75d24e750af1', null, 0, 0, 0, 0, 0, 2.0, 0, 12, 0, 3, 6.00, 1, 1, 0, '2026-06-06T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000619', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000006', '480c03c5-ea83-5913-8a4b-947fc3bf5a28', 'd1962402-4148-5a80-b691-75d24e750af1', null, 0, 0, 0, 0, 0, 0.3, 0, 2, 0, 1, 6.67, 1, 0, 0, '2026-06-06T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000620', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000006', '26ed4478-2b30-5de3-ba83-96749866d006', 'd1962402-4148-5a80-b691-75d24e750af1', null, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, '2026-06-06T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000621', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000006', 'c1c0d96d-ac8e-5e26-a70c-c25f11359448', 'd1962402-4148-5a80-b691-75d24e750af1', null, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, '2026-06-06T15:00:00');

commit;
