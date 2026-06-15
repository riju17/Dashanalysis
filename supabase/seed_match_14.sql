begin;

-- Match 14: Rewa Jaguars vs Indore Pink Panthers
-- Daly College Ground, Indore | June 10, 2026 | 14:30:00
-- Rewa Jaguars won by 31 runs
-- Toss: Rewa Jaguars won and chose to bat
-- Player of the Match: Anant Verma

-- Venue upsert for safety
insert into venues (id, venue_name, city, country, created_at)
values
  ('6d2f4b21-7c5e-4a4a-9f31-24e71f0d2401', 'Daly College Ground', 'Indore', 'India', '2026-06-10T14:30:00')
on conflict (venue_name) do update set
  city = excluded.city,
  country = excluded.country,
  created_at = excluded.created_at
;

-- Correct team/player names where seed.sql differs from scorecard
update teams set team_name = 'Indore Pink Panthers' where id = '582e73b3-b982-5677-b88b-d940deb2e79c';
update players set player_name = 'Atharv Joshi'       where id = 'e934d378-43e4-5740-a2a1-abeda43b917e';
update players set player_name = 'Siddarth Patidar'   where id = '21662ce5-2368-571f-8d64-26d735145aa5';
update players set player_name = 'Sagar Solanki'      where id = 'c30ccf9b-cb5c-55cb-9266-d50ec530797d';
update players set player_name = 'Ankit Kushwah'      where id = 'd1b49b26-555f-569a-87eb-f55a7443c614';
update players set player_name = 'Naveen Chouhan'     where id = 'a4edd760-ef34-5814-bb32-3e3a238042e2';
update players set player_name = 'Ramveer Gurjar'     where id = 'a8bcd523-2f54-5dbe-bc14-55c5d83c4bf7';

-- Clean up any existing data for match 14 (idempotent re-run)
delete from reports            where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000014';
delete from player_match_stats where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000014';
delete from matches            where id       = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000014';

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
  '8a9b4c2d-1f2e-4d3c-8a9b-24d240000014',
  '2026-06-10',
  '2026',
  'MPt20',
  14,
  '582e73b3-b982-5677-b88b-d940deb2e79c',   -- team_a/home: Indore Pink Panthers
  'd1962402-4148-5a80-b691-75d24e750af1',   -- team_b/away: Rewa Jaguars
  '6d2f4b21-7c5e-4a4a-9f31-24e71f0d2401',   -- Daly College Ground
  'd1962402-4148-5a80-b691-75d24e750af1',   -- toss winner: Rewa Jaguars
  'bat',                                     -- chose to bat
  'd1962402-4148-5a80-b691-75d24e750af1',   -- bat first: Rewa Jaguars
  '582e73b3-b982-5677-b88b-d940deb2e79c',   -- bowl first: Indore Pink Panthers
  209,                                       -- first innings score
  5,                                         -- first innings wickets
  20,                                        -- first innings overs
  178,                                       -- second innings score
  10,                                        -- second innings wickets
  19.3,                                      -- second innings overs
  'd1962402-4148-5a80-b691-75d24e750af1',   -- winner: Rewa Jaguars
  '582e73b3-b982-5677-b88b-d940deb2e79c',   -- loser: Indore Pink Panthers
  'runs',
  31,                                        -- margin: 31 runs
  null,
  'c1c0d96d-ac8e-5e26-a70c-c25f11359448',   -- Player of the Match: Anant Verma
  'Match 14 at Daly College Ground, Indore. Rewa Jaguars won by 31 runs after posting 209/5 in 20 overs and bowling out Indore Pink Panthers for 178 in 19.3 overs. Toss: Rewa Jaguars won and chose to bat. Umpires: Rohan Shrivastava and Rajesh Timane. Third umpire: Vijay Negi. Reserve umpire: Parth Tomar. Scorer: Sunil Gupta. Referee: Sanjeev Rao. Ball type: Leather. Ball color: White.',
  '2026-06-10T14:30:00'
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

  -- =============================================
  -- REWA JAGUARS BATTING (1st innings: 209/5)
  -- =============================================
  -- Prithviraj Tomar (c): c Atharv Joshi b Anvesh Chawla | 22, 17, 4x4, 0x6, SR 129.41
  ('d8d2f0a1-1234-4a0d-9f8d-24d240001401', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000014', '8ec8ffda-bfdc-54de-89d4-85e3d75f1ab3', 'd1962402-4148-5a80-b691-75d24e750af1', 1, 22, 17, 4, 0, 129.41, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T14:30:00'),
  -- Akshat Raghuwanshi: c Shivam Shukla b Vishnu Bhardwaj | 18, 11, 3x4, 0x6, SR 163.64
  ('d8d2f0a1-1234-4a0d-9f8d-24d240001402', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000014', '14285295-0308-5eed-abb1-b4c02962a013', 'd1962402-4148-5a80-b691-75d24e750af1', 2, 18, 11, 3, 0, 163.64, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T14:30:00'),
  -- Arham Aqueel: lbw b Shivam Shukla | 18, 21, 3x4, 0x6, SR 85.71
  ('d8d2f0a1-1234-4a0d-9f8d-24d240001403', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000014', '26ed4478-2b30-5de3-ba83-96749866d006', 'd1962402-4148-5a80-b691-75d24e750af1', 3, 18, 21, 3, 0, 85.71, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T14:30:00'),
  -- Anant Verma (wk): not out | 71, 37, 4x4, 5x6, SR 191.89
  ('d8d2f0a1-1234-4a0d-9f8d-24d240001404', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000014', 'c1c0d96d-ac8e-5e26-a70c-c25f11359448', 'd1962402-4148-5a80-b691-75d24e750af1', 4, 71, 37, 4, 5, 191.89, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T14:30:00'),
  -- Sagar Solanki: c Saransh Surana b Anvesh Chawla | 60, 28, 5x4, 5x6, SR 214.29
  ('d8d2f0a1-1234-4a0d-9f8d-24d240001405', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000014', 'c30ccf9b-cb5c-55cb-9266-d50ec530797d', 'd1962402-4148-5a80-b691-75d24e750af1', 5, 60, 28, 5, 5, 214.29, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T14:30:00'),
  -- Atharva Mahajan: run out (Karan Tahliyani/Atharv Joshi) | 11, 6, 1x4, 1x6, SR 183.33
  ('d8d2f0a1-1234-4a0d-9f8d-24d240001406', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000014', '480c03c5-ea83-5913-8a4b-947fc3bf5a28', 'd1962402-4148-5a80-b691-75d24e750af1', 6, 11, 6, 1, 1, 183.33, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T14:30:00'),
  -- Yet to bat: Naveen Chouhan, Ramveer Gurjar, Rohit Rajawat, Ashwin Das, Ankit Kushwah

  -- =============================================
  -- REWA JAGUARS BOWLING (2nd innings vs Indore 178/10)
  -- =============================================
  -- Ankit Kushwah: 3.3-0-31-3, 9 dots, econ 9.39
  ('d8d2f0a1-1234-4a0d-9f8d-24d240001411', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000014', 'd1b49b26-555f-569a-87eb-f55a7443c614', 'd1962402-4148-5a80-b691-75d24e750af1', null, 0, 0, 0, 0, 0, 3.3, 0, 31, 3, 9, 9.39, 0, 0, 0, '2026-06-10T14:30:00'),
  -- Ramveer Gurjar: 4.0-0-36-2, 14 dots, econ 9.00
  ('d8d2f0a1-1234-4a0d-9f8d-24d240001412', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000014', 'a8bcd523-2f54-5dbe-bc14-55c5d83c4bf7', 'd1962402-4148-5a80-b691-75d24e750af1', null, 0, 0, 0, 0, 0, 4.0, 0, 36, 2, 14, 9.00, 0, 0, 0, '2026-06-10T14:30:00'),
  -- Ashwin Das: 4.0-0-37-1, 9 dots, econ 9.25
  ('d8d2f0a1-1234-4a0d-9f8d-24d240001413', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000014', '2b2f93bb-fe9d-5b14-abb3-6a5fe6c1a9c8', 'd1962402-4148-5a80-b691-75d24e750af1', null, 0, 0, 0, 0, 0, 4.0, 0, 37, 1, 9, 9.25, 0, 0, 0, '2026-06-10T14:30:00'),
  -- Sagar Solanki: 1.0-0-9-0, 2 dots, econ 9.00
  ('d8d2f0a1-1234-4a0d-9f8d-24d240001414', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000014', 'c30ccf9b-cb5c-55cb-9266-d50ec530797d', 'd1962402-4148-5a80-b691-75d24e750af1', null, 0, 0, 0, 0, 0, 1.0, 0, 9, 0, 2, 9.00, 0, 0, 0, '2026-06-10T14:30:00'),
  -- Rohit Rajawat: 4.0-0-44-2, 12 dots, econ 11.00
  ('d8d2f0a1-1234-4a0d-9f8d-24d240001415', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000014', 'cbdf43c9-cbd8-5235-936c-14d31366433c', 'd1962402-4148-5a80-b691-75d24e750af1', null, 0, 0, 0, 0, 0, 4.0, 0, 44, 2, 12, 11.00, 0, 0, 0, '2026-06-10T14:30:00'),
  -- Prithviraj Tomar: 3.0-0-21-2, 3 dots, econ 7.00
  ('d8d2f0a1-1234-4a0d-9f8d-24d240001416', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000014', '8ec8ffda-bfdc-54de-89d4-85e3d75f1ab3', 'd1962402-4148-5a80-b691-75d24e750af1', null, 0, 0, 0, 0, 0, 3.0, 0, 21, 2, 3, 7.00, 0, 0, 0, '2026-06-10T14:30:00'),

  -- =============================================
  -- INDORE PINK PANTHERS BATTING (2nd innings: 178/10)
  -- =============================================
  -- Atharv Joshi (wk): c Anant Verma b Ankit Kushwah | 4, 2, 1x4, 0x6, SR 200.00
  ('d8d2f0a1-1234-4a0d-9f8d-24d240001421', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000014', 'e934d378-43e4-5740-a2a1-abeda43b917e', '582e73b3-b982-5677-b88b-d940deb2e79c', 1, 4, 2, 1, 0, 200.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T14:30:00'),
  -- Siddarth Patidar: c Naveen Chouhan b Ankit Kushwah | 27, 17, 2x4, 2x6, SR 158.82
  ('d8d2f0a1-1234-4a0d-9f8d-24d240001422', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000014', '21662ce5-2368-571f-8d64-26d735145aa5', '582e73b3-b982-5677-b88b-d940deb2e79c', 2, 27, 17, 2, 2, 158.82, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T14:30:00'),
  -- Karan Tahliyani: lbw b Prithviraj Tomar | 28, 25, 3x4, 1x6, SR 112.00
  ('d8d2f0a1-1234-4a0d-9f8d-24d240001423', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000014', 'b1507fce-9244-5c38-bf11-cfc4aa6461d8', '582e73b3-b982-5677-b88b-d940deb2e79c', 3, 28, 25, 3, 1, 112.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T14:30:00'),
  -- Anvesh Chawla: c Prithviraj Tomar b Ashwin Das | 6, 5, 1x4, 0x6, SR 120.00
  ('d8d2f0a1-1234-4a0d-9f8d-24d240001424', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000014', '9b8ce6e3-bb3b-56d0-8930-9c503e517e4d', '582e73b3-b982-5677-b88b-d940deb2e79c', 4, 6, 5, 1, 0, 120.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T14:30:00'),
  -- Venkatesh Iyer (c): lbw b Rohit Rajawat | 19, 21, 1x4, 1x6, SR 90.48
  ('d8d2f0a1-1234-4a0d-9f8d-24d240001425', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000014', 'f56a747c-cd41-5456-ab5d-60a273526bf4', '582e73b3-b982-5677-b88b-d940deb2e79c', 5, 19, 21, 1, 1, 90.48, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T14:30:00'),
  -- Sidhant Agrawal: c Anant Verma b Rohit Rajawat | 7, 9, 0x4, 0x6, SR 77.78
  ('d8d2f0a1-1234-4a0d-9f8d-24d240001426', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000014', '931345fe-8b9c-57fd-bb11-04cbf011a5c6', '582e73b3-b982-5677-b88b-d940deb2e79c', 6, 7, 9, 0, 0, 77.78, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T14:30:00'),
  -- Saransh Surana: c Naveen Chouhan b Prithviraj Tomar | 11, 4, 1x4, 1x6, SR 275.00
  ('d8d2f0a1-1234-4a0d-9f8d-24d240001427', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000014', 'd4a25b3f-0333-564f-bc8b-8e57a3b41a99', '582e73b3-b982-5677-b88b-d940deb2e79c', 7, 11, 4, 1, 1, 275.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T14:30:00'),
  -- Shubham Rathore: c Atharva Mahajan b Ramveer Gurjar | 28, 10, 0x4, 4x6, SR 280.00
  ('d8d2f0a1-1234-4a0d-9f8d-24d240001428', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000014', '64e22a56-f1ff-59a6-91b3-6b88e9d0cdeb', '582e73b3-b982-5677-b88b-d940deb2e79c', 8, 28, 10, 0, 4, 280.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T14:30:00'),
  -- Shivam Shukla: b Ankit Kushwah | 36, 17, 2x4, 4x6, SR 211.76
  ('d8d2f0a1-1234-4a0d-9f8d-24d240001429', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000014', '8c118ea4-e9c1-5620-a56e-885ee57dbd4a', '582e73b3-b982-5677-b88b-d940deb2e79c', 9, 36, 17, 2, 4, 211.76, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T14:30:00'),
  -- Vishnu Bhardwaj: c Prithviraj Tomar b Ramveer Gurjar | 8, 6, 0x4, 1x6, SR 133.33
  ('d8d2f0a1-1234-4a0d-9f8d-24d240001430', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000014', 'd52da864-1c4f-53e1-b7b4-94fc1879d773', '582e73b3-b982-5677-b88b-d940deb2e79c', 10, 8, 6, 0, 1, 133.33, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T14:30:00'),
  -- Roshan Kewat: not out | 0, 2, 0x4, 0x6, SR 0.00
  ('d8d2f0a1-1234-4a0d-9f8d-24d240001431', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000014', 'c8d836da-3c55-5fa1-b68a-2989f45aab44', '582e73b3-b982-5677-b88b-d940deb2e79c', 11, 0, 2, 0, 0, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-10T14:30:00'),

  -- =============================================
  -- INDORE PINK PANTHERS BOWLING (1st innings vs Rewa 209/5)
  -- =============================================
  -- Roshan Kewat: 4.0-0-34-0, 7 dots, econ 8.50
  ('d8d2f0a1-1234-4a0d-9f8d-24d240001441', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000014', 'c8d836da-3c55-5fa1-b68a-2989f45aab44', '582e73b3-b982-5677-b88b-d940deb2e79c', null, 0, 0, 0, 0, 0, 4.0, 0, 34, 0, 7, 8.50, 0, 0, 0, '2026-06-10T14:30:00'),
  -- Anvesh Chawla: 4.0-0-51-2, 10 dots, econ 12.75
  ('d8d2f0a1-1234-4a0d-9f8d-24d240001442', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000014', '9b8ce6e3-bb3b-56d0-8930-9c503e517e4d', '582e73b3-b982-5677-b88b-d940deb2e79c', null, 0, 0, 0, 0, 0, 4.0, 0, 51, 2, 10, 12.75, 0, 0, 0, '2026-06-10T14:30:00'),
  -- Sidhant Agrawal: 2.0-0-21-0, 5 dots, econ 10.50
  ('d8d2f0a1-1234-4a0d-9f8d-24d240001443', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000014', '931345fe-8b9c-57fd-bb11-04cbf011a5c6', '582e73b3-b982-5677-b88b-d940deb2e79c', null, 0, 0, 0, 0, 0, 2.0, 0, 21, 0, 5, 10.50, 0, 0, 0, '2026-06-10T14:30:00'),
  -- Vishnu Bhardwaj: 4.0-0-30-1, 10 dots, econ 7.50
  ('d8d2f0a1-1234-4a0d-9f8d-24d240001444', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000014', 'd52da864-1c4f-53e1-b7b4-94fc1879d773', '582e73b3-b982-5677-b88b-d940deb2e79c', null, 0, 0, 0, 0, 0, 4.0, 0, 30, 1, 10, 7.50, 0, 0, 0, '2026-06-10T14:30:00'),
  -- Shivam Shukla: 4.0-0-43-1, 6 dots, econ 10.75
  ('d8d2f0a1-1234-4a0d-9f8d-24d240001445', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000014', '8c118ea4-e9c1-5620-a56e-885ee57dbd4a', '582e73b3-b982-5677-b88b-d940deb2e79c', null, 0, 0, 0, 0, 0, 4.0, 0, 43, 1, 6, 10.75, 0, 0, 0, '2026-06-10T14:30:00'),
  -- Venkatesh Iyer: 2.0-0-27-0, 3 dots, econ 13.50
  ('d8d2f0a1-1234-4a0d-9f8d-24d240001446', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000014', 'f56a747c-cd41-5456-ab5d-60a273526bf4', '582e73b3-b982-5677-b88b-d940deb2e79c', null, 0, 0, 0, 0, 0, 2.0, 0, 27, 0, 3, 13.50, 0, 0, 0, '2026-06-10T14:30:00');

commit;
