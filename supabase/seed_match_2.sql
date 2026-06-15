begin;

-- Match 2: Malwa Stallions vs Chambal Ghariyals
-- Holkar Stadium, Indore | June 4, 2026 | 15:00:00
-- Chambal Ghariyals won by 6 wickets with 26 balls remaining
-- Toss: Chambal Ghariyals won and chose to field
-- Player of the Match: Ankush Singh

insert into venues (id, venue_name, city, country, created_at)
values
  ('0b2128b7-a408-5c19-a6bf-cdd7c3ffa816', 'Holkar Stadium', 'Indore', 'India', '2026-06-04T15:00:00')
on conflict (venue_name) do update set
  city = excluded.city,
  country = excluded.country,
  created_at = excluded.created_at
;

-- Name corrections from the scorecard
update players set player_name = 'Aavesh Khan' where id = '4beced42-4683-5cd7-a3d4-eafb40a735c1';
update players set player_name = 'Apurve Dwivedi' where id = '1a2a261a-eab8-5945-805f-ab56e7ee4265';
update players set player_name = 'Rohit Gupta' where id = '810363ec-7c2f-59ec-b81f-071000960904';
update players set player_name = 'Gautam Raghuwanshi' where id = '33e1f887-5e0a-513d-b17e-d50a5f9eae6f';
update players set player_name = 'Aman Bhadoriya' where id = 'bfd18390-21b9-5c61-8765-373789c7f2f2';
update players set player_name = 'Mayur Patel' where id = '661efd97-7f59-5db8-a791-fa9a2779d9cc';
update players set player_name = 'Rishabh Chouhan' where id = '580812e1-bbb3-5071-8e0b-bc7ce717c1e2';

delete from reports where match_id = '4181f7f5-26b0-49fc-93d6-99724d5e6738';
delete from player_match_stats where match_id = '4181f7f5-26b0-49fc-93d6-99724d5e6738';
delete from matches where id = '4181f7f5-26b0-49fc-93d6-99724d5e6738';

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
  '4181f7f5-26b0-49fc-93d6-99724d5e6738',
  '2026-06-04',
  '2026',
  'MPt20',
  2,
  '42c007fa-6d22-56b0-981b-fae8db3c0483',
  '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e',
  '0b2128b7-a408-5c19-a6bf-cdd7c3ffa816',
  '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e',
  'field',
  '42c007fa-6d22-56b0-981b-fae8db3c0483',
  '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e',
  154,
  7,
  20.0,
  157,
  4,
  15.4,
  '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e',
  '42c007fa-6d22-56b0-981b-fae8db3c0483',
  'wickets',
  null,
  6,
  'c3abcf6b-af87-50dd-b6cd-bef5ba923ff4',
  'Aditya Birla Group MP League T20 Match 2 at Holkar Stadium, Indore. Chambal Ghariyals won by 6 wickets with 26 balls remaining after chasing 157/4 in 15.4 overs against Malwa Stallions 154/7 in 20 overs. Toss: Chambal Ghariyals won and chose to field. Umpires: Akshay Totre and Rajesh Timane. Third umpire: Nikhil Menon. Reserve umpire: Jitendra Gupta. Scorer: Dattatraya Varat. Referee: Sanjeev Rao. Ball type: Leather. Ball color: White. Phase: League.',
  '2026-06-04T15:00:00'
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
  -- Malwa Stallions batting + bowling/fielding
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000201', '4181f7f5-26b0-49fc-93d6-99724d5e6738', 'd2fda9b6-adf3-536b-b8d5-10529664d2c1', '42c007fa-6d22-56b0-981b-fae8db3c0483', 1, 20, 13, 4, 0, 153.85, 0, 0, 0, 0, 0, 0, 1, 0, 0, '2026-06-04T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000202', '4181f7f5-26b0-49fc-93d6-99724d5e6738', '5c41a2db-95b8-5fda-94cb-baf02e8545d3', '42c007fa-6d22-56b0-981b-fae8db3c0483', 2, 3, 9, 0, 0, 33.33, 0, 0, 0, 0, 0, 0, 1, 0, 0, '2026-06-04T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000203', '4181f7f5-26b0-49fc-93d6-99724d5e6738', 'd1aba495-c7db-5b97-850b-60e778095755', '42c007fa-6d22-56b0-981b-fae8db3c0483', 3, 0, 3, 0, 0, 0.00, 2.4, 0, 42, 1, 3, 17.50, 1, 0, 0, '2026-06-04T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000204', '4181f7f5-26b0-49fc-93d6-99724d5e6738', 'b5bd61ff-5683-51bb-b5f9-4c60259e25c5', '42c007fa-6d22-56b0-981b-fae8db3c0483', 4, 11, 8, 2, 0, 137.50, 0, 0, 0, 0, 0, 0, 1, 0, 0, '2026-06-04T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000205', '4181f7f5-26b0-49fc-93d6-99724d5e6738', '760c9582-173c-5107-8472-55496ef09cef', '42c007fa-6d22-56b0-981b-fae8db3c0483', 5, 11, 17, 1, 0, 64.71, 3.0, 0, 15, 1, 7, 5.00, 1, 0, 0, '2026-06-04T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000206', '4181f7f5-26b0-49fc-93d6-99724d5e6738', '580812e1-bbb3-5071-8e0b-bc7ce717c1e2', '42c007fa-6d22-56b0-981b-fae8db3c0483', 6, 57, 41, 4, 4, 139.02, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-04T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000207', '4181f7f5-26b0-49fc-93d6-99724d5e6738', 'fe7efb2f-9244-58c6-a3fd-55f32427a875', '42c007fa-6d22-56b0-981b-fae8db3c0483', 7, 1, 4, 0, 0, 25.00, 2.0, 0, 15, 0, 3, 7.50, 0, 0, 0, '2026-06-04T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000208', '4181f7f5-26b0-49fc-93d6-99724d5e6738', '8a5aad69-90e1-5713-b7f7-5bf83631cbc1', '42c007fa-6d22-56b0-981b-fae8db3c0483', 8, 29, 19, 4, 1, 152.63, 2.0, 0, 19, 0, 5, 9.50, 0, 0, 0, '2026-06-04T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000209', '4181f7f5-26b0-49fc-93d6-99724d5e6738', '3d68aabb-51d3-51d6-9aa3-44c84c72caea', '42c007fa-6d22-56b0-981b-fae8db3c0483', 9, 4, 6, 0, 0, 66.67, 1.0, 0, 15, 0, 1, 15.00, 0, 0, 0, '2026-06-04T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000210', '4181f7f5-26b0-49fc-93d6-99724d5e6738', 'd98dae83-73f6-5b91-a61d-c3988fe29777', '42c007fa-6d22-56b0-981b-fae8db3c0483', null, 0, 0, 0, 0, 0, 2.0, 0, 27, 0, 4, 13.50, 0, 0, 0, '2026-06-04T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000211', '4181f7f5-26b0-49fc-93d6-99724d5e6738', '827fbd94-bf19-51e7-b3d8-24bca42f8d9b', '42c007fa-6d22-56b0-981b-fae8db3c0483', null, 0, 0, 0, 0, 0, 3.0, 0, 23, 2, 9, 7.67, 1, 0, 0, '2026-06-04T15:00:00'),

  -- Chambal Ghariyals batting + bowling/fielding
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000212', '4181f7f5-26b0-49fc-93d6-99724d5e6738', 'c3abcf6b-af87-50dd-b6cd-bef5ba923ff4', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 1, 58, 36, 3, 4, 161.11, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-04T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000213', '4181f7f5-26b0-49fc-93d6-99724d5e6738', '1a2a261a-eab8-5945-805f-ab56e7ee4265', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 2, 4, 7, 0, 0, 57.14, 0, 0, 0, 0, 0, 0, 0, 0, 1, '2026-06-04T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000214', '4181f7f5-26b0-49fc-93d6-99724d5e6738', 'bdd646e4-e7c4-51c1-a3bf-f1bac631a751', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 3, 12, 8, 3, 0, 150.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-04T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000215', '4181f7f5-26b0-49fc-93d6-99724d5e6738', '810363ec-7c2f-59ec-b81f-071000960904', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 4, 37, 23, 5, 2, 160.87, 0, 0, 0, 0, 0, 0, 2, 0, 0, '2026-06-04T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000216', '4181f7f5-26b0-49fc-93d6-99724d5e6738', '33e1f887-5e0a-513d-b17e-d50a5f9eae6f', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 5, 17, 12, 2, 0, 141.67, 0, 0, 0, 0, 0, 0, 1, 0, 0, '2026-06-04T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000217', '4181f7f5-26b0-49fc-93d6-99724d5e6738', '8f53ea6e-5db4-5b51-beec-3cf622142bf7', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 6, 21, 9, 2, 1, 233.33, 4.0, 0, 51, 1, 6, 12.75, 0, 0, 0, '2026-06-04T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000218', '4181f7f5-26b0-49fc-93d6-99724d5e6738', '4beced42-4683-5cd7-a3d4-eafb40a735c1', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', null, 0, 0, 0, 0, 0, 4.0, 0, 29, 2, 12, 7.25, 0, 0, 0, '2026-06-04T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000219', '4181f7f5-26b0-49fc-93d6-99724d5e6738', 'bfd18390-21b9-5c61-8765-373789c7f2f2', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', null, 0, 0, 0, 0, 0, 4.0, 0, 20, 1, 16, 5.00, 0, 0, 0, '2026-06-04T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000220', '4181f7f5-26b0-49fc-93d6-99724d5e6738', '661efd97-7f59-5db8-a791-fa9a2779d9cc', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', null, 0, 0, 0, 0, 0, 4.0, 0, 33, 1, 11, 8.25, 1, 0, 0, '2026-06-04T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000221', '4181f7f5-26b0-49fc-93d6-99724d5e6738', 'cfbc5a3c-7efa-5f50-b9a4-0bf3f2e2fa2a', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', null, 0, 0, 0, 0, 0, 4.0, 0, 21, 2, 13, 5.25, 1, 0, 0, '2026-06-04T15:00:00');

commit;
