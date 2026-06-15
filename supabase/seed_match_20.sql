begin;

-- Match 20: Rewa Jaguars vs Royal Nimar Eagles
-- Daly College Ground, Indore | June 12, 2026 | 09:30:00
-- Royal Nimar Eagles won by 3 wickets with 3 balls remaining
-- Toss: Royal Nimar Eagles won and chose to field
-- Player of the Match: Anandsingh Pradeepsingh Bais

insert into venues (id, venue_name, city, country, created_at)
values
  ('6d2f4b21-7c5e-4a4a-9f31-24e71f0d2401', 'Daly College Ground', 'Indore', 'India', '2026-06-12T09:30:00')
on conflict (venue_name) do update set
  city = excluded.city,
  country = excluded.country,
  created_at = excluded.created_at
;

-- Name corrections from the scorecard
update players set player_name = 'Anandsingh Pradeepsingh Bais' where id = 'c1ba6d40-d4f7-5671-97d7-da99594292a3';
update players set player_name = 'Devendra Katheit' where id = 'a2f37dda-00a0-556f-8c5d-8dfe0e16f418';
update players set player_name = 'Ankit Kushwah' where id = 'd1b49b26-555f-569a-87eb-f55a7443c614';
update players set player_name = 'Ramveer Gurjar' where id = 'a8bcd523-2f54-5dbe-bc14-55c5d83c4bf7';

delete from reports where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000020';
delete from player_match_stats where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000020';
delete from matches where id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000020';

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
  '8a9b4c2d-1f2e-4d3c-8a9b-24d240000020',
  '2026-06-12',
  '2026',
  'MPt20',
  20,
  'd1962402-4148-5a80-b691-75d24e750af1',   -- team_a/home: Rewa Jaguars
  '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada',   -- team_b/away: Royal Nimar Eagles
  '6d2f4b21-7c5e-4a4a-9f31-24e71f0d2401',   -- Daly College Ground
  '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada',   -- toss winner: Royal Nimar Eagles
  'field',
  'd1962402-4148-5a80-b691-75d24e750af1',   -- bat first: Rewa Jaguars
  '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada',   -- bowl first: Royal Nimar Eagles
  130,
  8,
  20,
  136,
  7,
  19.3,
  '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada',   -- winner: Royal Nimar Eagles
  'd1962402-4148-5a80-b691-75d24e750af1',   -- loser: Rewa Jaguars
  'wickets',
  null,
  3,
  'c1ba6d40-d4f7-5671-97d7-da99594292a3',   -- Player of the Match: Anandsingh Pradeepsingh Bais
  'Match 20 at Daly College Ground, Indore. Royal Nimar Eagles won by 3 wickets with 3 balls remaining after chasing 136/7 in 19.3 overs against Rewa Jaguars 130/8 in 20 overs. Toss: Royal Nimar Eagles won and chose to field. Umpires: Manish Jain and Rohan Shrivastava. Third umpire: Rajesh Timaney. Reserve umpire: Vishal Sharma. Scorer: Dattatraya Varat. Referee: Sanjeev Rao. Ball type: Leather. Ball color: White.',
  '2026-06-12T09:30:00'
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
  -- Rewa Jaguars batting: 130/8
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002001', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000020', '8ec8ffda-bfdc-54de-89d4-85e3d75f1ab3', 'd1962402-4148-5a80-b691-75d24e750af1',  1, 13, 13, 3, 0, 100.00, 3.0, 0, 23, 0,  4,  7.67, 0, 1, 0, '2026-06-12T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002002', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000020', '14285295-0308-5eed-abb1-b4c02962a013', 'd1962402-4148-5a80-b691-75d24e750af1',  2,  0,  1, 0, 0,   0.00, 0,   0,  0, 0,  0,  0.00, 1, 0, 0, '2026-06-12T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002003', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000020', '2b2f93bb-fe9d-5b14-abb3-6a5fe6c1a9c8', 'd1962402-4148-5a80-b691-75d24e750af1',  3, 18, 21, 3, 0,  85.71, 3.0, 0, 15, 0,  9,  5.00, 0, 0, 0, '2026-06-12T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002004', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000020', '26ed4478-2b30-5de3-ba83-96749866d006', 'd1962402-4148-5a80-b691-75d24e750af1',  4, 33, 29, 3, 1, 113.79, 0,   0,  0, 0,  0,  0.00, 0, 1, 0, '2026-06-12T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002005', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000020', 'c1c0d96d-ac8e-5e26-a70c-c25f11359448', 'd1962402-4148-5a80-b691-75d24e750af1',  5, 14, 10, 1, 0, 140.00, 0,   0,  0, 0,  0,  0.00, 0, 0, 0, '2026-06-12T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002006', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000020', 'c30ccf9b-cb5c-55cb-9266-d50ec530797d', 'd1962402-4148-5a80-b691-75d24e750af1',  6,  4,  2, 1, 0, 200.00, 3.3, 0, 24, 1,  7,  7.27, 0, 1, 0, '2026-06-12T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002007', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000020', '480c03c5-ea83-5913-8a4b-947fc3bf5a28', 'd1962402-4148-5a80-b691-75d24e750af1',  7, 33, 28, 2, 2, 117.86, 0,   0,  0, 0,  0,  0.00, 0, 0, 0, '2026-06-12T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002008', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000020', 'd1b49b26-555f-569a-87eb-f55a7443c614', 'd1962402-4148-5a80-b691-75d24e750af1',  8,  3, 11, 0, 0,  27.27, 4.0, 0, 25, 1, 14,  6.25, 0, 0, 0, '2026-06-12T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002009', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000020', 'a8bcd523-2f54-5dbe-bc14-55c5d83c4bf7', 'd1962402-4148-5a80-b691-75d24e750af1',  9,  8,  6, 1, 0, 133.33, 4.0, 1, 31, 3, 13,  7.75, 1, 1, 0, '2026-06-12T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002010', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000020', 'cbdf43c9-cbd8-5235-936c-14d31366433c', 'd1962402-4148-5a80-b691-75d24e750af1', 10,  0,  0, 0, 0,   0.00, 1.0, 0,  9, 0,  1,  9.00, 2, 0, 0, '2026-06-12T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002011', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000020', 'd08027f6-3fd4-56aa-a805-39c6005846c7', 'd1962402-4148-5a80-b691-75d24e750af1', null, 0,  0, 0, 0,   0.00, 1.0, 0,  7, 0,  2,  7.00, 0, 0, 0, '2026-06-12T09:30:00'),

  -- Royal Nimar Eagles batting: 136/7
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002021', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000020', '8c2ac304-10da-5dbc-b8e4-db6753b7c2a8', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', 1,  7,  5, 1, 0, 140.00, 0.2, 0,  5, 0,  0, 25.00, 2, 0, 0, '2026-06-12T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002022', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000020', 'b3959799-7ce4-5e1d-bedb-0612b04f822b', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', 2,  0,  1, 0, 0,   0.00, 0,   0,  0, 0,  0,  0.00, 1, 0, 0, '2026-06-12T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002023', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000020', '58201413-0f11-5f9f-9c43-5c1ce756ccf4', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', 3,  4,  9, 1, 0,  44.44, 0,   0,  0, 0,  0,  0.00, 1, 0, 0, '2026-06-12T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002024', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000020', 'c1ba6d40-d4f7-5671-97d7-da99594292a3', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', 4, 64, 56, 8, 1, 114.29, 0,   0,  0, 0,  0,  0.00, 0, 0, 0, '2026-06-12T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002025', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000020', 'f7ac72c3-f544-5a78-b5b5-d57f962c6811', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', 5, 28, 26, 4, 0, 107.69, 4.0, 0, 18, 3, 11,  4.50, 0, 1, 0, '2026-06-12T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002026', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000020', 'd15a9fe5-8630-5bd5-a764-7aebea809a9b', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', 6, 10, 10, 1, 0, 100.00, 1.0, 0, 10, 0,  1, 10.00, 0, 0, 0, '2026-06-12T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002027', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000020', '930b10f7-a3a0-5f30-b2cc-34baf62ace88', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', 7, 15,  8, 1, 1, 187.50, 0,   0,  0, 0,  0,  0.00, 0, 0, 0, '2026-06-12T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002028', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000020', 'c2df7539-be90-5fcc-b9ee-bbaf45ea25c8', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', 8,  4,  2, 1, 0, 200.00, 4.0, 0, 34, 1, 13,  8.50, 0, 1, 0, '2026-06-12T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002029', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000020', 'cfae1e19-cece-5fcb-9ca0-c6b8ea455378', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', 9,  0,  0, 0, 0,   0.00, 2.4, 0, 28, 0,  6, 11.67, 0, 0, 0, '2026-06-12T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002030', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000020', 'a2f37dda-00a0-556f-8c5d-8dfe0e16f418', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', null, 0, 0, 0, 0,   0.00, 4.0, 0, 20, 2, 13,  5.00, 0, 0, 0, '2026-06-12T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002031', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000020', 'e3731702-dacf-5e6a-9e4c-55ee74432723', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', null, 0, 0, 0, 0,   0.00, 4.0, 0, 15, 1, 14,  3.75, 1, 0, 0, '2026-06-12T09:30:00');

commit;
