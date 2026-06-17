begin;

update teams set team_name = 'Chambal Ghariyals' where id = '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e';
update players set player_name = 'Atharv Joshi' where id = 'e934d378-43e4-5740-a2a1-abeda43b917e';
update players set player_name = 'Siddarth Patidar' where id = '21662ce5-2368-571f-8d64-26d735145aa5';
update players set player_name = 'Aayaam Verma' where id = '86a3bdf2-0579-543c-bd84-12d083001309';
update players set player_name = 'Gautam Raghuwanshi' where id = '33e1f887-5e0a-513d-b17e-d50a5f9eae6f';
update players set player_name = 'Apurve Dwivedi' where id = '1a2a261a-eab8-5945-805f-ab56e7ee4265';
update players set player_name = 'Mayur Patel' where id = '661efd97-7f59-5db8-a791-fa9a2779d9cc';

insert into venues (id, venue_name, city, country, created_at)
values
  ('6d2f4b21-7c5e-4a4a-9f31-24e71f0d2401', 'Daly College Ground', 'Indore', 'India', '2026-06-14T09:30:00')
on conflict (venue_name) do update set
  city = excluded.city,
  country = excluded.country,
  created_at = excluded.created_at
;

delete from reports where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000026';
delete from player_match_stats where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000026';
delete from matches where id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000026';

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
  '8a9b4c2d-1f2e-4d3c-8a9b-24d240000026',
  '2026-06-14',
  '2026',
  'MPt20',
  26,
  '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e',
  '582e73b3-b982-5677-b88b-d940deb2e79c',
  '6d2f4b21-7c5e-4a4a-9f31-24e71f0d2401',
  '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e',
  'field',
  '582e73b3-b982-5677-b88b-d940deb2e79c',
  '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e',
  120,
  10,
  20,
  121,
  6,
  17.5,
  '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e',
  '582e73b3-b982-5677-b88b-d940deb2e79c',
  'wickets',
  null,
  4,
  '8f53ea6e-5db4-5b51-beec-3cf622142bf7',
  'Match 26 at Daly College Ground, Indore. Chambal Ghariyals won by 4 wickets with 13 balls remaining after chasing 121/6 in 17.5 overs against Indore Pink Panthers 120/10 in 20 overs. Toss: Chambal Ghariyals won and chose to field. Umpires: Rameez Khan and Abhishek Tomar. Third umpire: Nikhil Patwardhan. Reserve umpire: Rohit Dhakad. Scorer: Mayank Thanwar. Referee: Manish Majithia. Ball type: Leather. Ball color: White.',
  '2026-06-14T09:30:00'
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
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002601', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000026', 'e934d378-43e4-5740-a2a1-abeda43b917e', '582e73b3-b982-5677-b88b-d940deb2e79c', 1,  1,  6, 0, 0,  16.67, 0, 0, 0, 0, 0,  0.00, 0, 0, 0, '2026-06-14T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002602', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000026', '21662ce5-2368-571f-8d64-26d735145aa5', '582e73b3-b982-5677-b88b-d940deb2e79c', 2, 22, 17, 1, 1, 129.41, 0, 0, 0, 0, 0,  0.00, 0, 0, 0, '2026-06-14T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002603', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000026', 'f56a747c-cd41-5456-ab5d-60a273526bf4', '582e73b3-b982-5677-b88b-d940deb2e79c', 3,  1,  2, 0, 0,  50.00, 0, 0, 0, 0, 0,  0.00, 0, 0, 0, '2026-06-14T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002604', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000026', '86a3bdf2-0579-543c-bd84-12d083001309', '582e73b3-b982-5677-b88b-d940deb2e79c', 4, 21, 27, 2, 0,  77.78, 0, 0, 0, 0, 0,  0.00, 0, 0, 0, '2026-06-14T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002605', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000026', '9b8ce6e3-bb3b-56d0-8930-9c503e517e4d', '582e73b3-b982-5677-b88b-d940deb2e79c', 5, 17, 18, 2, 0,  94.44, 0, 0, 0, 0, 0,  0.00, 0, 0, 0, '2026-06-14T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002606', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000026', 'd4a25b3f-0333-564f-bc8b-8e57a3b41a99', '582e73b3-b982-5677-b88b-d940deb2e79c', 6,  1,  6, 0, 0,  16.67, 0, 0, 0, 0, 0,  0.00, 0, 0, 0, '2026-06-14T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002607', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000026', 'a981d5c5-3b3b-523b-9407-aaf99cc9eeb7', '582e73b3-b982-5677-b88b-d940deb2e79c', 7, 12, 15, 1, 0,  80.00, 0, 0, 0, 0, 0,  0.00, 0, 0, 0, '2026-06-14T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002608', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000026', '64e22a56-f1ff-59a6-91b3-6b88e9d0cdeb', '582e73b3-b982-5677-b88b-d940deb2e79c', 8, 22, 16, 2, 1, 137.50, 0, 0, 0, 0, 0,  0.00, 0, 0, 0, '2026-06-14T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002609', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000026', '8c118ea4-e9c1-5620-a56e-885ee57dbd4a', '582e73b3-b982-5677-b88b-d940deb2e79c', 9,  0,  1, 0, 0,   0.00, 0, 0, 0, 0, 0,  0.00, 0, 0, 0, '2026-06-14T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002610', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000026', 'd52da864-1c4f-53e1-b7b4-94fc1879d773', '582e73b3-b982-5677-b88b-d940deb2e79c', 10, 16, 11, 2, 1, 145.45, 0, 0, 0, 0, 0,  0.00, 0, 0, 0, '2026-06-14T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002611', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000026', 'c8d836da-3c55-5fa1-b68a-2989f45aab44', '582e73b3-b982-5677-b88b-d940deb2e79c', 11,  0,  1, 0, 0,   0.00, 0, 0, 0, 0, 0,  0.00, 0, 0, 0, '2026-06-14T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002612', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000026', 'c8d836da-3c55-5fa1-b68a-2989f45aab44', '582e73b3-b982-5677-b88b-d940deb2e79c', null, 0, 0, 0, 0, 0, 3.5, 0, 27, 0, 11,  7.71, 0, 0, 0, '2026-06-14T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002613', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000026', '9b8ce6e3-bb3b-56d0-8930-9c503e517e4d', '582e73b3-b982-5677-b88b-d940deb2e79c', null, 0, 0, 0, 0, 0, 4.0, 0, 32, 4, 11,  8.00, 0, 0, 0, '2026-06-14T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002614', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000026', '8c118ea4-e9c1-5620-a56e-885ee57dbd4a', '582e73b3-b982-5677-b88b-d940deb2e79c', null, 0, 0, 0, 0, 0, 3.0, 0, 17, 0, 6,  5.67, 0, 0, 0, '2026-06-14T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002615', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000026', 'f56a747c-cd41-5456-ab5d-60a273526bf4', '582e73b3-b982-5677-b88b-d940deb2e79c', null, 0, 0, 0, 0, 0, 1.0, 0, 10, 0, 2, 10.00, 0, 0, 0, '2026-06-14T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002616', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000026', 'a981d5c5-3b3b-523b-9407-aaf99cc9eeb7', '582e73b3-b982-5677-b88b-d940deb2e79c', null, 0, 0, 0, 0, 0, 3.0, 0, 16, 0, 8,  5.33, 0, 0, 0, '2026-06-14T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002617', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000026', 'd52da864-1c4f-53e1-b7b4-94fc1879d773', '582e73b3-b982-5677-b88b-d940deb2e79c', null, 0, 0, 0, 0, 0, 3.0, 0, 18, 2, 6,  6.00, 0, 0, 0, '2026-06-14T09:30:00'),

  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002621', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000026', 'c3abcf6b-af87-50dd-b6cd-bef5ba923ff4', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 1, 24, 27, 2, 1,  88.89, 0, 0, 0, 0, 0,  0.00, 0, 0, 0, '2026-06-14T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002622', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000026', '1a2a261a-eab8-5945-805f-ab56e7ee4265', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 2,  1,  2, 0, 0,  50.00, 0, 0, 0, 0, 0,  0.00, 0, 0, 0, '2026-06-14T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002623', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000026', 'bdd646e4-e7c4-51c1-a3bf-f1bac631a751', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 3, 10,  6, 2, 0, 166.67, 0, 0, 0, 0, 0,  0.00, 0, 0, 0, '2026-06-14T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002624', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000026', '810363ec-7c2f-59ec-b81f-071000960904', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 4, 29, 24, 3, 1, 120.83, 0, 0, 0, 0, 0,  0.00, 0, 0, 0, '2026-06-14T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002625', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000026', '33e1f887-5e0a-513d-b17e-d50a5f9eae6f', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 5, 32, 25, 4, 0, 128.00, 0, 0, 0, 0, 0,  0.00, 0, 0, 0, '2026-06-14T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002626', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000026', '8f53ea6e-5db4-5b51-beec-3cf622142bf7', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 6, 11, 10, 0, 1, 110.00, 0, 0, 0, 0, 0,  0.00, 0, 0, 0, '2026-06-14T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002627', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000026', '661efd97-7f59-5db8-a791-fa9a2779d9cc', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 7,  4,  8, 0, 0,  50.00, 0, 0, 0, 0, 0,  0.00, 0, 0, 0, '2026-06-14T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002628', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000026', 'bfd18390-21b9-5c61-8765-373789c7f2f2', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 8,  6,  5, 1, 0, 120.00, 0, 0, 0, 0, 0,  0.00, 0, 0, 0, '2026-06-14T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002629', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000026', '59efe8ae-f3df-5200-b756-93fd814d31c6', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', null, 0, 0, 0, 0, 0, 4.0, 0, 20, 0, 14,  5.00, 0, 0, 0, '2026-06-14T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002630', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000026', 'bfd18390-21b9-5c61-8765-373789c7f2f2', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', null, 0, 0, 0, 0, 0, 3.0, 0, 15, 2, 6,  5.00, 0, 0, 0, '2026-06-14T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002631', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000026', '8f53ea6e-5db4-5b51-beec-3cf622142bf7', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', null, 0, 0, 0, 0, 0, 4.0, 0, 29, 3, 13,  7.25, 0, 0, 0, '2026-06-14T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002632', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000026', '661efd97-7f59-5db8-a791-fa9a2779d9cc', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', null, 0, 0, 0, 0, 0, 3.0, 0, 14, 1, 7,  4.67, 0, 0, 0, '2026-06-14T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002633', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000026', 'f9e2b8a7-5d31-5a14-9f3e-24d240001919', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', null, 0, 0, 0, 0, 0, 4.0, 0, 24, 2, 12,  6.00, 0, 0, 0, '2026-06-14T09:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002634', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000026', '29b93c79-f1bc-5d03-ac0c-11d631feaed0', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', null, 0, 0, 0, 0, 0, 2.0, 0, 11, 0, 4,  5.50, 0, 0, 0, '2026-06-14T09:30:00');

commit;
