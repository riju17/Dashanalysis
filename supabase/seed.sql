insert into teams (id, team_name, short_name, primary_color, secondary_color, accent_color, logo_url, created_at)
values
  ('582e73b3-b982-5677-b88b-d940deb2e79c', 'Indore Pink Panther', 'IPP', '#7C3AED', '#A855F7', '#22D3EE', 'https://dummyimage.com/256x256/0f172a/7C3AED&text=IPP', '2026-01-01T10:00:00'),
  ('1303eab5-3486-5a12-ae69-0648c95de9f1', 'Gwalior Cheetahs', 'GCH', '#EF4444', '#F97316', '#FDE047', 'https://dummyimage.com/256x256/0f172a/EF4444&text=GCH', '2026-01-01T10:00:00'),
  ('4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 'Bundelkhand Bulls', 'BKB', '#0EA5E9', '#14B8A6', '#22C55E', 'https://dummyimage.com/256x256/0f172a/0EA5E9&text=BKB', '2026-01-01T10:00:00'),
  ('834605bb-cc4a-5b89-88c7-218cbb32d6ab', 'Jabalpur Royal Lions', 'JRL', '#1D4ED8', '#6366F1', '#38BDF8', 'https://dummyimage.com/256x256/0f172a/1D4ED8&text=JRL', '2026-01-01T10:00:00'),
  ('2e16f308-a4d9-590a-9823-1489edc087df', 'Ujjain Falcons', 'UJF', '#8B5CF6', '#C084FC', '#F472B6', 'https://dummyimage.com/256x256/0f172a/8B5CF6&text=UJF', '2026-01-01T10:00:00'),
  ('92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', 'Nimar Eagles', 'RNE', '#F43F5E', '#FB7185', '#F97316', 'https://dummyimage.com/256x256/0f172a/F43F5E&text=RNE', '2026-01-01T10:00:00'),
  ('3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 'Chambal Ghariyals', 'CHG', '#10B981', '#34D399', '#F59E0B', 'https://dummyimage.com/256x256/0f172a/10B981&text=CHG', '2026-01-01T10:00:00'),
  ('d1962402-4148-5a80-b691-75d24e750af1', 'Rewa Jaguars', 'RJG', '#0284C7', '#38BDF8', '#60A5FA', 'https://dummyimage.com/256x256/0f172a/0284C7&text=RJG', '2026-01-01T10:00:00'),
  ('89c8bea7-a025-55f9-8858-3b1220253648', 'Bhopal Leopards', 'BPL', '#7C2D12', '#EA580C', '#F59E0B', 'https://dummyimage.com/256x256/0f172a/7C2D12&text=BPL', '2026-01-01T10:00:00'),
  ('42c007fa-6d22-56b0-981b-fae8db3c0483', 'Malwa Stallions', 'MSL', '#0F172A', '#2563EB', '#22D3EE', 'https://dummyimage.com/256x256/0f172a/0F172A&text=MSL', '2026-01-01T10:00:00')
on conflict (team_name) do nothing
;

insert into venues (id, venue_name, city, country, created_at)
values
  ('0b2128b7-a408-5c19-a6bf-cdd7c3ffa816', 'Holkar Stadium', 'Indore', 'India', '2026-01-01T10:00:00'),
  ('5bcc3dd4-ede2-5608-a322-75f757823378', 'Delhi College', 'Indore', 'India', '2026-01-01T10:00:00')
on conflict (venue_name) do nothing
;

insert into tournaments (id, tournament_name, season, start_date, end_date, created_at)
values
  ('40394a6f-7007-5e0c-a3a5-94c20f1f0b36', 'MPt20', '2026', '2026-02-01', '2026-04-01', '2026-01-01T10:00:00')
on conflict (id) do nothing
;

-- Match 24: Gwalior Cheetahs vs Bundelkhand Bulls
insert into venues (id, venue_name, city, country, created_at)
values
  ('6d2f4b21-7c5e-4a4a-9f31-24e71f0d2401', 'Daly College Ground', 'Indore', 'India', '2026-06-13T14:30:00')
on conflict (venue_name) do update set
  city = excluded.city,
  country = excluded.country,
  created_at = excluded.created_at
;

delete from reports where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000024';
delete from player_match_stats where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000024';
delete from matches where id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000024';

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
  '8a9b4c2d-1f2e-4d3c-8a9b-24d240000024',
  '2026-06-13',
  '2026',
  'MPt20',
  24,
  '1303eab5-3486-5a12-ae69-0648c95de9f1',
  '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff',
  '6d2f4b21-7c5e-4a4a-9f31-24e71f0d2401',
  '1303eab5-3486-5a12-ae69-0648c95de9f1',
  'bat',
  '1303eab5-3486-5a12-ae69-0648c95de9f1',
  '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff',
  249,
  4,
  20,
  226,
  9,
  20,
  '1303eab5-3486-5a12-ae69-0648c95de9f1',
  '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff',
  'runs',
  23,
  null,
  '3ea57ec9-dd66-5321-8669-ec767c467f61',
  'Match 24 at Daly College Ground, Indore. Gwalior Cheetahs won by 23 runs after posting 249/4 and restricting Bundelkhand Bulls to 226/9. Toss: Gwalior Cheetahs won and chose to bat. Umpires: Prem Bhargav and Vijay Negi. Third umpire: Abhishek Tomar. Reserve umpire: Pankaj Bharti. Referee: Manish Majithia.',
  '2026-06-13T14:30:00'
);

-- Match 25: Ujjain Falcons vs Rewa Jaguars
insert into venues (id, venue_name, city, country, created_at)
values
  ('0b2128b7-a408-5c19-a6bf-cdd7c3ffa816', 'Holkar Stadium', 'Indore', 'India', '2026-06-13T15:00:00')
on conflict (venue_name) do update set
  city = excluded.city,
  country = excluded.country,
  created_at = excluded.created_at
;

-- Name corrections from the scorecard
update players set player_name = 'Ankit Kushwah' where id = 'd1b49b26-555f-569a-87eb-f55a7443c614';
update players set player_name = 'Ramveer Gurjar' where id = 'a8bcd523-2f54-5dbe-bc14-55c5d83c4bf7';
update players set player_name = 'Ankur Chauhan' where id = '17ec0eb7-e6f6-5367-9484-40316d13e11d';

delete from reports where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025';
delete from player_match_stats where match_id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025';
delete from matches where id = '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025';

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
  '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025',
  '2026-06-13',
  '2026',
  'MPt20',
  25,
  '2e16f308-a4d9-590a-9823-1489edc087df',
  'd1962402-4148-5a80-b691-75d24e750af1',
  '0b2128b7-a408-5c19-a6bf-cdd7c3ffa816',
  '2e16f308-a4d9-590a-9823-1489edc087df',
  'bat',
  '2e16f308-a4d9-590a-9823-1489edc087df',
  'd1962402-4148-5a80-b691-75d24e750af1',
  231,
  4,
  20,
  234,
  5,
  19,
  'd1962402-4148-5a80-b691-75d24e750af1',
  '2e16f308-a4d9-590a-9823-1489edc087df',
  'wickets',
  null,
  5,
  '26ed4478-2b30-5de3-ba83-96749866d006',
  'Match 25 at Holkar Stadium, Indore. Rewa Jaguars won by 5 wickets with 6 balls remaining after chasing 234/5 in 19 overs against Ujjain Falcons 231/4 in 20 overs. Toss: Ujjain Falcons won and chose to bat. Umpires: Manish Jain and Rameez Khan. Third umpire: Nikhil Menon. Reserve umpire: Vishal Sharma. Scorer: Jayant Wankhede. Referee: Sanjeev Rao. Ball type: Leather. Ball color: White.',
  '2026-06-13T15:00:00'
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
  -- Ujjain Falcons batting and bowling
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002501', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', 'aab476d8-1b1e-5e64-b131-f8a20a926547', '2e16f308-a4d9-590a-9823-1489edc087df',  1, 11,  6, 2, 0, 183.33, 0, 0, 0, 0,  0,  0.00, 0, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002502', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', '76c8afae-d578-5f7d-a434-bff3e9426dc8', '2e16f308-a4d9-590a-9823-1489edc087df',  2, 71, 38, 5, 6, 186.84, 0, 0, 0, 0,  0,  0.00, 0, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002503', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', 'c9704649-b025-5ae3-a7e1-58959be7b68c', '2e16f308-a4d9-590a-9823-1489edc087df',  3, 49, 40, 3, 1, 122.50, 0, 0, 0, 0,  0,  0.00, 0, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002504', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', 'd58207e1-c9a0-5d95-a068-5c1ef03e6086', '2e16f308-a4d9-590a-9823-1489edc087df',  4, 18, 13, 2, 1, 138.46, 4, 0, 58, 1,  7, 14.50, 0, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002505', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', '26fe523a-8080-5d6b-91df-2a56855d6b82', '2e16f308-a4d9-590a-9823-1489edc087df',  5, 44, 14, 1, 6, 314.29, 0, 0, 0, 0,  0,  0.00, 0, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002506', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', 'f37d1d1d-bd57-559c-9e29-7bebccc95480', '2e16f308-a4d9-590a-9823-1489edc087df',  6, 28,  9, 2, 3, 311.11, 4, 0, 39, 1,  7,  9.75, 1, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002507', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', '5f9d6003-67e6-5524-b959-57d064eb9ac2', '2e16f308-a4d9-590a-9823-1489edc087df', null, 0,  0, 0, 0,   0.00, 3, 0, 32, 0,  6, 10.67, 0, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002508', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', 'd1b49b26-555f-569a-87eb-f55a7443c614', '2e16f308-a4d9-590a-9823-1489edc087df', null, 0,  0, 0, 0,   0.00, 4, 0, 43, 2,  5, 10.75, 1, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002509', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', '27d217d2-3af4-5405-a088-c7ef5ad6ac41', '2e16f308-a4d9-590a-9823-1489edc087df', null, 0,  0, 0, 0,   0.00, 1, 0, 13, 0,  1, 13.00, 0, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002510', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', '2b2f93bb-fe9d-5b14-abb3-6a5fe6c1a9c8', '2e16f308-a4d9-590a-9823-1489edc087df', null, 0,  0, 0, 0,   0.00, 4, 0, 40, 0,  6, 10.00, 0, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002511', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', 'e81c782b-8204-50d9-9e14-c0968343fe65', '2e16f308-a4d9-590a-9823-1489edc087df', null, 0,  0, 0, 0,   0.00, 4, 0, 58, 1,  7, 14.50, 0, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002512', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', '23350497-ca69-525f-b620-d61b88cb8670', '2e16f308-a4d9-590a-9823-1489edc087df', null, 0,  0, 0, 0,   0.00, 2, 0, 29, 1,  1, 14.50, 0, 0, 0, '2026-06-13T15:00:00'),

  -- Rewa Jaguars batting and bowling
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002521', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', '8ec8ffda-bfdc-54de-89d4-85e3d75f1ab3', 'd1962402-4148-5a80-b691-75d24e750af1',  1, 24, 11, 1, 3, 218.18, 0, 0, 0, 0,  0,  0.00, 0, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002522', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', '14285295-0308-5eed-abb1-b4c02962a013', 'd1962402-4148-5a80-b691-75d24e750af1',  2, 21, 11, 1, 2, 190.91, 0, 0, 0, 0,  0,  0.00, 0, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002523', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', '26ed4478-2b30-5de3-ba83-96749866d006', 'd1962402-4148-5a80-b691-75d24e750af1',  3, 107, 49, 8, 7, 218.37, 0, 0, 0, 0,  0,  0.00, 1, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002524', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', 'c1c0d96d-ac8e-5e26-a70c-c25f11359448', 'd1962402-4148-5a80-b691-75d24e750af1',  4,  9,  6, 0, 1, 150.00, 0, 0, 0, 0,  0,  0.00, 1, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002525', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', 'c30ccf9b-cb5c-55cb-9266-d50ec530797d', 'd1962402-4148-5a80-b691-75d24e750af1',  5, 26, 20, 2, 1, 130.00, 4, 0, 29, 0,  8,  7.25, 0, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002526', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', 'd1b49b26-555f-569a-87eb-f55a7443c614', 'd1962402-4148-5a80-b691-75d24e750af1',  6,  1,  2, 0, 0,  50.00, 4, 0, 39, 2,  6,  9.75, 0, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002527', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', '480c03c5-ea83-5913-8a4b-947fc3bf5a28', 'd1962402-4148-5a80-b691-75d24e750af1',  7, 29, 17, 2, 2, 170.59, 2, 0, 26, 1,  3, 13.00, 0, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002528', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', 'cbdf43c9-cbd8-5235-936c-14d31366433c', 'd1962402-4148-5a80-b691-75d24e750af1', null, 0,  0, 0, 0,   0.00, 2, 0, 30, 0,  1, 15.00, 0, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002529', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', '2b2f93bb-fe9d-5b14-abb3-6a5fe6c1a9c8', 'd1962402-4148-5a80-b691-75d24e750af1', null, 0,  0, 0, 0,   0.00, 4, 0, 40, 0,  6, 10.00, 0, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002530', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', 'a8bcd523-2f54-5dbe-bc14-55c5d83c4bf7', 'd1962402-4148-5a80-b691-75d24e750af1', null, 0,  0, 0, 0,   0.00, 4, 0, 58, 1,  8, 14.50, 0, 0, 0, '2026-06-13T15:00:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240002531', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000025', 'b218001e-c822-58e7-ab99-da490578ae53', 'd1962402-4148-5a80-b691-75d24e750af1', null, 0,  0, 0, 0,   0.00, 0, 0, 0, 0,  0,  0.00, 1, 0, 0, '2026-06-13T15:00:00');


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
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000241', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000024', 'c07ce930-7239-56c7-a87c-8dfab62436c5', '1303eab5-3486-5a12-ae69-0648c95de9f1', 1, 12, 13, 2, 0, 92.31, 0, 0, 0, 0, 0, 0, 1, 0, 0, '2026-06-13T14:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000242', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000024', '3ea57ec9-dd66-5321-8669-ec767c467f61', '1303eab5-3486-5a12-ae69-0648c95de9f1', 2, 95, 46, 4, 10, 206.52, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-13T14:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000243', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000024', '3313c4ab-7f84-51a6-a9db-707f3b4f0983', '1303eab5-3486-5a12-ae69-0648c95de9f1', 3, 48, 28, 5, 3, 171.43, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-13T14:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000244', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000024', 'f6d907f4-f8bb-52aa-99ae-772bbf4b652a', '1303eab5-3486-5a12-ae69-0648c95de9f1', 4, 36, 16, 5, 2, 225.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-13T14:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000245', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000024', '8f502ba1-ed08-5dd7-b9a1-9eeafda52406', '1303eab5-3486-5a12-ae69-0648c95de9f1', 5, 18, 7, 1, 2, 257.14, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-13T14:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000246', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000024', 'f772a481-aac3-5e96-bdee-6f6466852b92', '1303eab5-3486-5a12-ae69-0648c95de9f1', 6, 35, 11, 5, 2, 318.18, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-13T14:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000254', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000024', 'c8f284a8-e738-59e4-b7b5-ace9a37f6a2b', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 1, 26, 22, 3, 1, 118.18, 0, 0, 0, 0, 0, 0, 1, 0, 0, '2026-06-13T14:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000255', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000024', '7f40be31-fc73-5139-a38d-5194608282e1', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 2, 84, 25, 5, 10, 336.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-13T14:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000256', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000024', 'e0b867ba-e046-579b-854b-4bf09ce97592', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 3, 39, 23, 1, 3, 169.57, 2, 0, 44, 0, 2, 22.00, 0, 0, 0, '2026-06-13T14:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000257', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000024', '7c3bef67-21bb-5f49-b72f-29484f10aa3c', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 4, 13, 13, 0, 1, 100.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-13T14:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000258', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000024', '3a6cb1d7-9e68-5074-8653-b57573a9f9eb', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 5, 0, 1, 0, 0, 0.00, 4, 0, 55, 1, 4, 13.75, 0, 0, 0, '2026-06-13T14:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000259', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000024', '1259d056-9bad-51ef-8ab7-caf13adcbff6', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 6, 10, 8, 0, 1, 125.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2026-06-13T14:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000260', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000024', '0746cd79-5361-5ef8-ad53-8df4ee43b5bc', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 7, 0, 1, 0, 0, 0.00, 1, 0, 8, 0, 3, 8.00, 1, 0, 0, '2026-06-13T14:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000261', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000024', '2541f929-1c7b-5ec4-8e9d-6f8ae8f22ff8', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 8, 15, 10, 1, 1, 150.00, 4, 0, 23, 2, 13, 5.75, 1, 0, 0, '2026-06-13T14:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000262', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000024', 'd07905cb-9b4f-594a-972d-ceedba4bf8a6', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 9, 6, 5, 0, 1, 120.00, 4, 0, 55, 1, 7, 13.75, 1, 0, 0, '2026-06-13T14:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000263', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000024', '16ec489b-ec1f-537d-bf0e-431af7a9e9f8', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 10, 18, 11, 2, 1, 163.64, 4, 0, 49, 0, 10, 12.25, 0, 0, 0, '2026-06-13T14:30:00'),
  ('b8d8f8d2-7a8d-4a0d-9f8d-24d240000264', '8a9b4c2d-1f2e-4d3c-8a9b-24d240000024', '3e1e44a2-bac8-5ece-8a5c-8c42201bd2be', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 11, 1, 3, 0, 0, 33.33, 1, 0, 15, 0, 1, 15.00, 0, 0, 0, '2026-06-13T14:30:00');

-- Match 26: Chambal Ghariyals vs Indore Pink Panthers
insert into venues (id, venue_name, city, country, created_at)
values
  ('6d2f4b21-7c5e-4a4a-9f31-24e71f0d2401', 'Daly College Ground', 'Indore', 'India', '2026-06-14T09:30:00')
on conflict (venue_name) do update set
  city = excluded.city,
  country = excluded.country,
  created_at = excluded.created_at
;

update teams set team_name = 'Chambal Ghariyals' where id = '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e';
update players set player_name = 'Atharv Joshi' where id = 'e934d378-43e4-5740-a2a1-abeda43b917e';
update players set player_name = 'Siddarth Patidar' where id = '21662ce5-2368-571f-8d64-26d735145aa5';
update players set player_name = 'Aayaam Verma' where id = '86a3bdf2-0579-543c-bd84-12d083001309';
update players set player_name = 'Gautam Raghuwanshi' where id = '33e1f887-5e0a-513d-b17e-d50a5f9eae6f';
update players set player_name = 'Apurve Dwivedi' where id = '1a2a261a-eab8-5945-805f-ab56e7ee4265';
update players set player_name = 'Mayur Patel' where id = '661efd97-7f59-5db8-a791-fa9a2779d9cc';

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

insert into players (id, player_name, team_id, role, batting_style, bowling_style, created_at)
values
  ('b1507fce-9244-5c38-bf11-cfc4aa6461d8', 'Karan Tahliyani', '582e73b3-b982-5677-b88b-d940deb2e79c', 'Batter', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('a7bc20aa-56e2-5c55-aac4-f670c0555a8c', 'Saransh Bhargava', '582e73b3-b982-5677-b88b-d940deb2e79c', 'Batter', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('e934d378-43e4-5740-a2a1-abeda43b917e', 'Atharv Joshi', '582e73b3-b982-5677-b88b-d940deb2e79c', 'Wicketkeeper', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('21662ce5-2368-571f-8d64-26d735145aa5', 'Siddarth Patidar', '582e73b3-b982-5677-b88b-d940deb2e79c', 'Wicketkeeper', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('0908684a-9fca-5132-9ab2-a0b60545dad4', 'Mehfooz Patel', '582e73b3-b982-5677-b88b-d940deb2e79c', 'Wicketkeeper', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('f56a747c-cd41-5456-ab5d-60a273526bf4', 'Venkatesh Iyer', '582e73b3-b982-5677-b88b-d940deb2e79c', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('9b8ce6e3-bb3b-56d0-8930-9c503e517e4d', 'Anvesh Chawla', '582e73b3-b982-5677-b88b-d940deb2e79c', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('86a3bdf2-0579-543c-bd84-12d083001309', 'Aayaam Verma', '582e73b3-b982-5677-b88b-d940deb2e79c', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('d4a25b3f-0333-564f-bc8b-8e57a3b41a99', 'Saransh Surana', '582e73b3-b982-5677-b88b-d940deb2e79c', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('64e22a56-f1ff-59a6-91b3-6b88e9d0cdeb', 'Shubham Rathore', '582e73b3-b982-5677-b88b-d940deb2e79c', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('a981d5c5-3b3b-523b-9407-aaf99cc9eeb7', 'Lucky Mishra', '582e73b3-b982-5677-b88b-d940deb2e79c', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('931345fe-8b9c-57fd-bb11-04cbf011a5c6', 'Sidhant Agrawal', '582e73b3-b982-5677-b88b-d940deb2e79c', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('8c118ea4-e9c1-5620-a56e-885ee57dbd4a', 'Shivam Shukla', '582e73b3-b982-5677-b88b-d940deb2e79c', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('c8d836da-3c55-5fa1-b68a-2989f45aab44', 'Roshan Kewat', '582e73b3-b982-5677-b88b-d940deb2e79c', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('0fc9b647-05ac-5f19-aefc-a3e704037c4e', 'Akash Rajawat', '582e73b3-b982-5677-b88b-d940deb2e79c', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('d52da864-1c4f-53e1-b7b4-94fc1879d773', 'Vishnu Bhardwaj', '582e73b3-b982-5677-b88b-d940deb2e79c', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('3313c4ab-7f84-51a6-a9db-707f3b4f0983', 'Kuldeep Gehi', '1303eab5-3486-5a12-ae69-0648c95de9f1', 'Wicketkeeper', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('8f502ba1-ed08-5dd7-b9a1-9eeafda52406', 'Vikas Sharma', '1303eab5-3486-5a12-ae69-0648c95de9f1', 'Wicketkeeper', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('fb5bccb7-881d-5ed5-9fb7-521747fc08cb', 'Varun Tiwari', '1303eab5-3486-5a12-ae69-0648c95de9f1', 'Wicketkeeper', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('3ea57ec9-dd66-5321-8669-ec767c467f61', 'Parth Chaudhary', '1303eab5-3486-5a12-ae69-0648c95de9f1', 'Batter', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('c07ce930-7239-56c7-a87c-8dfab62436c5', 'Kartik Parihar', '1303eab5-3486-5a12-ae69-0648c95de9f1', 'Batter', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('999836e6-f267-56b5-82fc-d874737ec447', 'Vandit Joshi', '1303eab5-3486-5a12-ae69-0648c95de9f1', 'Batter', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('d6b5b3f7-4583-59e6-89a1-9b9f5e883ba2', 'Saumy Pandey', '1303eab5-3486-5a12-ae69-0648c95de9f1', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('cfbc5a3c-7efa-5f50-b9a4-0bf3f2e2fa2a', 'Akash Singh', '1303eab5-3486-5a12-ae69-0648c95de9f1', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('b199ea13-ead3-59fd-8f86-530506d3227a', 'Ishan Afridi', '1303eab5-3486-5a12-ae69-0648c95de9f1', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('9f47f49c-29f6-5aaf-b21e-047fc3b72985', 'Anubhav Agrawal', '1303eab5-3486-5a12-ae69-0648c95de9f1', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('f772a481-aac3-5e96-bdee-6f6466852b92', 'Arpit Patel', '1303eab5-3486-5a12-ae69-0648c95de9f1', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('687036d9-a074-5868-a9fd-310d8907a3ea', 'Anil Maurya', '1303eab5-3486-5a12-ae69-0648c95de9f1', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('f16fa647-c5f7-5d19-ac61-bba3be832560', 'Tushar Verma', '1303eab5-3486-5a12-ae69-0648c95de9f1', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('4f062956-019c-5a34-82e6-2b4508a34d17', 'Varun Shinde', '1303eab5-3486-5a12-ae69-0648c95de9f1', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('f6d907f4-f8bb-52aa-99ae-772bbf4b652a', 'Rajat Patidar', '1303eab5-3486-5a12-ae69-0648c95de9f1', 'Batter', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('40c90b46-0444-56dd-a8db-9fc2cef21a1b', 'Mangesh Yadav', '1303eab5-3486-5a12-ae69-0648c95de9f1', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('7c3bef67-21bb-5f49-b72f-29484f10aa3c', 'Parth Goswami', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 'Batter', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('7f40be31-fc73-5139-a38d-5194608282e1', 'Abhishek Pathak', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 'Batter', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('3d2781b2-a98d-53e3-96a7-7640cf6ee944', 'Rudransh Singh', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 'Batter', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('c8f284a8-e738-59e4-b7b5-ace9a37f6a2b', 'Harsh Gawali', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 'Wicketkeeper', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('449bf9a5-34b1-52c1-9b27-9378f96cf184', 'Kushagra Wadhwa', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 'Wicketkeeper', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('e0b867ba-e046-579b-854b-4bf09ce97592', 'Shvang Kumar', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('3a6cb1d7-9e68-5074-8653-b57573a9f9eb', 'Vikrant Bhadoriya', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('2541f929-1c7b-5ec4-8e9d-6f8ae8f22ff8', 'Anant Dubey', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('660e82ef-f58e-562f-983e-53fc4a2d6b32', 'Aman Jain', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('1259d056-9bad-51ef-8ab7-caf13adcbff6', 'Gautam Joshi', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('0746cd79-5361-5ef8-ad53-8df4ee43b5bc', 'Bhumesh Muzalda', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('d07905cb-9b4f-594a-972d-ceedba4bf8a6', 'Kuldeep Sen', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('16ec489b-ec1f-537d-bf0e-431af7a9e9f8', 'Omkarnath Singh', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('0e149403-3793-5acd-a209-daa0b036cfd5', 'Harshit Parsai', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('3dbfaf13-b0d2-5a9b-94ae-81c16fe26b47', 'Yash Patidar', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('3e1e44a2-bac8-5ece-8a5c-8c42201bd2be', 'Milan Shivhare', '4812e53a-a933-5ecf-a1ec-eb43f09bf2ff', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('fab398ff-2405-564f-8d25-4e33023b20e6', 'Arpit Gaud', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', 'Batter', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('c92621ac-3bf1-5f82-b55e-215425cbb283', 'Akarsh Singh Parihar', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', 'Batter', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('925def19-3968-5442-b573-223adaf5a693', 'Prince Wadhwani', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', 'Batter', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('af9615ee-2603-5400-92a5-834a5d2719e9', 'Ajay Rohera', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', 'Wicketkeeper', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('e9ab0e02-e7e6-5595-b7d0-8bb2891e2c4a', 'Abhishek Bhandari', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', 'Wicketkeeper', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('4d98b52f-c702-5ecb-9124-a36c23e956bc', 'Puneet Datey', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('29993758-c857-5658-9114-cc74a26c1880', 'Ritik Tada', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('bb5c157d-7607-5723-9023-d11cc790cec7', 'Nayan Raj Mewada', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('e02a6367-53de-5119-baf1-4affd88d2850', 'Akshat Dwivedi', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('1f44fb2f-bd66-5467-bf4d-085daeb7c176', 'Rahul Batham', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('14819b05-062e-56b6-a956-bc5711eb6673', 'Sanjog Nijjar', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('431edc70-c312-5536-a1ca-aab18576774f', 'Vedant Awasthi', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('0bc71b97-5af4-586d-96fb-ecbaa7affaab', 'Pankaj Patel', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('03029869-5b08-58a5-8ba2-6af1ed546d6a', 'Akshay Sharma', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('7f3d49e1-bb8e-5a9a-b450-58ecbd064607', 'Aayam Sardana', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('182f840e-6561-57f1-9ee9-ef9386fa72d3', 'Mihir Hirwani', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('7a0298b6-de41-5113-9b49-7f1c5691ee5a', 'Ritwik Diwan', '834605bb-cc4a-5b89-88c7-218cbb32d6ab', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('26fe523a-8080-5d6b-91df-2a56855d6b82', 'Ojaswa Yadav', '2e16f308-a4d9-590a-9823-1489edc087df', 'Batter', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('4c5420f4-0540-53d4-ba92-5a185793cff3', 'Shubham Kushwah', '2e16f308-a4d9-590a-9823-1489edc087df', 'Batter', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('aab476d8-1b1e-5e64-b131-f8a20a926547', 'Soham Patwardhan', '2e16f308-a4d9-590a-9823-1489edc087df', 'Batter', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('8acb0d9d-2348-5e81-b225-c4b61ab10274', 'Darshan Rathore', '2e16f308-a4d9-590a-9823-1489edc087df', 'Batter', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('76c8afae-d578-5f7d-a434-bff3e9426dc8', 'Chanchal Rathore', '2e16f308-a4d9-590a-9823-1489edc087df', 'Wicketkeeper', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('c9704649-b025-5ae3-a7e1-58959be7b68c', 'Yash Dubey', '2e16f308-a4d9-590a-9823-1489edc087df', 'Wicketkeeper', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('d58207e1-c9a0-5d95-a068-5c1ef03e6086', 'Madhav Tiwari', '2e16f308-a4d9-590a-9823-1489edc087df', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('f37d1d1d-bd57-559c-9e29-7bebccc95480', 'Aryan Pandey', '2e16f308-a4d9-590a-9823-1489edc087df', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('17ec0eb7-e6f6-5367-9484-40316d13e11d', 'Ankur Singh Chauhan', '2e16f308-a4d9-590a-9823-1489edc087df', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('5f9d6003-67e6-5524-b959-57d064eb9ac2', 'Rishi Miglani', '2e16f308-a4d9-590a-9823-1489edc087df', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('07f64c0c-c68f-5b8a-9ba5-efaf48a27ceb', 'Harshwardhan Hardia', '2e16f308-a4d9-590a-9823-1489edc087df', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('27d217d2-3af4-5405-a088-c7ef5ad6ac41', 'Gajendra Goswami', '2e16f308-a4d9-590a-9823-1489edc087df', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('e81c782b-8204-50d9-9e14-c0968343fe65', 'Adheer Pratap Singh', '2e16f308-a4d9-590a-9823-1489edc087df', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('23350497-ca69-525f-b620-d61b88cb8670', 'Aayush Mankar', '2e16f308-a4d9-590a-9823-1489edc087df', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('6ff44d93-aa39-5b93-9d9e-4f4ee94696d2', 'Masoom Raza Khan', '2e16f308-a4d9-590a-9823-1489edc087df', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('04be1900-80cc-5f43-a46d-d1f0f514299e', 'Naveen Nagle', '2e16f308-a4d9-590a-9823-1489edc087df', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('f398a1ab-b968-5027-b072-70586c71d93f', 'Vishesh Mudgal', '2e16f308-a4d9-590a-9823-1489edc087df', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('c1ba6d40-d4f7-5671-97d7-da99594292a3', 'Anand Singh Bais', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', 'Batter', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('930b10f7-a3a0-5f30-b2cc-34baf62ace88', 'Abhishek Mavi', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', 'Batter', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('1772b0ea-ba22-5cd7-87e7-056db6e41141', 'Ayaan Sreeraj', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', 'Batter', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('b3959799-7ce4-5e1d-bedb-0612b04f822b', 'Himanshu Mantri', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', 'Wicketkeeper', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('8f2e9484-5216-5a56-9937-4c7fdf41c8d1', 'Pranit Patidar', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', 'Wicketkeeper', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('f7ac72c3-f544-5a78-b5b5-d57f962c6811', 'Saransh Jain', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('58201413-0f11-5f9f-9c43-5c1ce756ccf4', 'Kanishk Dubey', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('b0f804d9-8900-5473-8e3b-598a35cfd424', 'Shantanu Raghuvanshi', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('b5b53032-9576-5eb8-933d-3ac8a9884f57', 'Prarabdh Mishra', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('cfae1e19-cece-5fcb-9ca0-c6b8ea455378', 'Pushkar Vishwakarma', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('8c2ac304-10da-5dbc-b8e4-db6753b7c2a8', 'Dharmesh Patel', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('d15a9fe5-8630-5bd5-a764-7aebea809a9b', 'Shivansh Chaturvedi', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('2e12d9e8-1f67-5425-96e2-550942f69d50', 'Shashank Patidar', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('e3731702-dacf-5e6a-9e4c-55ee74432723', 'Kumar Kartikeya', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('a4ef4c65-66ea-53eb-b3f6-49e455e0a0a4', 'Kartik Rajoriya', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('c2df7539-be90-5fcc-b9ee-bbaf45ea25c8', 'Parush Mandal', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('a2f37dda-00a0-556f-8c5d-8dfe0e16f418', 'Devendra Singh Katheit', '92ad1deb-7d7a-59bd-b2fe-f35e2fa56ada', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('c3abcf6b-af87-50dd-b6cd-bef5ba923ff4', 'Ankush Singh', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 'Batter', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('810363ec-7c2f-59ec-b81f-071000960904', 'Rohit Kumar Gupta', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 'Batter', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('bdd646e4-e7c4-51c1-a3bf-f1bac631a751', 'Shubham Sharma', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('bfd18390-21b9-5c61-8765-373789c7f2f2', 'Aman Bhadoria', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('33e1f887-5e0a-513d-b17e-d50a5f9eae6f', 'Gautam Raghuwanshi', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('6d6158a0-64c1-5235-b5f3-55f601773dfd', 'Harsh Dixit', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('8f53ea6e-5db4-5b51-beec-3cf622142bf7', 'Tripuresh Singh', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('4787b00e-afcc-5f5d-8a98-f5d1b96283a1', 'Karan Tiwari', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 'Wicketkeeper', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('84742574-8090-541e-b3ea-45031a5eaad5', 'Diyanshu Yadav', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('1a2a261a-eab8-5945-805f-ab56e7ee4265', 'Apurve Dwivedi', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 'Wicketkeeper', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('4beced42-4683-5cd7-a3d4-eafb40a735c1', 'Avesh Khan', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('59efe8ae-f3df-5200-b756-93fd814d31c6', 'Akshay Singh', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('661efd97-7f59-5db8-a791-fa9a2779d9cc', 'Mayur Patel', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('8f1f6e57-aae3-54b2-b8e1-846e81517c05', 'Piyush Patel', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('f25b9fd7-d8e1-5eeb-877b-84bd2138026c', 'Yash Kumar Lodhi', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('29b93c79-f1bc-5d03-ac0c-11d631feaed0', 'Madhur Seth', '3c1f7337-b13d-5c07-9c5f-41b3e6c4e25e', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('14285295-0308-5eed-abb1-b4c02962a013', 'Akshat Raghuwanshi', 'd1962402-4148-5a80-b691-75d24e750af1', 'Batter', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('480c03c5-ea83-5913-8a4b-947fc3bf5a28', 'Atharva Mahajan', 'd1962402-4148-5a80-b691-75d24e750af1', 'Batter', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('98f0ac74-9b0a-56a2-a9a0-254195bcc80a', 'Sagar Pratap Singh', 'd1962402-4148-5a80-b691-75d24e750af1', 'Batter', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('26ed4478-2b30-5de3-ba83-96749866d006', 'Arham Aqueel', 'd1962402-4148-5a80-b691-75d24e750af1', 'Batter', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('c1c0d96d-ac8e-5e26-a70c-c25f11359448', 'Anant Verma', 'd1962402-4148-5a80-b691-75d24e750af1', 'Wicketkeeper', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('b218001e-c822-58e7-ab99-da490578ae53', 'Jaydev Singh', 'd1962402-4148-5a80-b691-75d24e750af1', 'Wicketkeeper', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('c30ccf9b-cb5c-55cb-9266-d50ec530797d', 'Sagar Solanki', 'd1962402-4148-5a80-b691-75d24e750af1', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('8ec8ffda-bfdc-54de-89d4-85e3d75f1ab3', 'Prithviraj Tomar', 'd1962402-4148-5a80-b691-75d24e750af1', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('d1b49b26-555f-569a-87eb-f55a7443c614', 'Ankit Singh Kushwah', 'd1962402-4148-5a80-b691-75d24e750af1', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('a4edd760-ef34-5814-bb32-3e3a238042e2', 'Naveen Singh Chauhan', 'd1962402-4148-5a80-b691-75d24e750af1', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('a8bcd523-2f54-5dbe-bc14-55c5d83c4bf7', 'Ramveer Singh Gurjar', 'd1962402-4148-5a80-b691-75d24e750af1', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('2b2f93bb-fe9d-5b14-abb3-6a5fe6c1a9c8', 'Ashwin Das', 'd1962402-4148-5a80-b691-75d24e750af1', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('cbdf43c9-cbd8-5235-936c-14d31366433c', 'Rohit Rajawat', 'd1962402-4148-5a80-b691-75d24e750af1', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('170f726a-b896-5d70-a271-3ad3ec5eeab4', 'Prabhanshu Shukla', 'd1962402-4148-5a80-b691-75d24e750af1', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('f66e071a-cbc5-55b9-a19e-f985cc89bc54', 'Ritesh Shakya', 'd1962402-4148-5a80-b691-75d24e750af1', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('d08027f6-3fd4-56aa-a805-39c6005846c7', 'Radhakrishna Dwivedi', 'd1962402-4148-5a80-b691-75d24e750af1', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('bdfb9f70-ac54-5c21-b013-cc0c4ad44b45', 'Aniket Verma', '89c8bea7-a025-55f9-8858-3b1220253648', 'Batter', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('c7022cce-a30e-54e0-972e-b076a0dee0c0', 'Ansh Bagadia', '89c8bea7-a025-55f9-8858-3b1220253648', 'Batter', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('15915c22-37bb-5f32-8ffe-ebd791791ed5', 'Suraj Yadav', '89c8bea7-a025-55f9-8858-3b1220253648', 'Batter', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('d602bbdc-ef2a-53d4-a240-3c727a368bb4', 'Anchit Thakur', '89c8bea7-a025-55f9-8858-3b1220253648', 'Wicketkeeper', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('a652e185-c0c1-5361-9b36-14f575b0c276', 'Rahul Chandrol', '89c8bea7-a025-55f9-8858-3b1220253648', 'Wicketkeeper', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('e6d242cb-20f9-5d54-9009-e30b9805001f', 'Kunal Rai', '89c8bea7-a025-55f9-8858-3b1220253648', 'Wicketkeeper', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('8055fbcb-c7f0-5042-af57-3bd8eac90b16', 'Arshad Khan', '89c8bea7-a025-55f9-8858-3b1220253648', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('e8d4cbc5-c3e3-5276-ac3b-a3c363258fb3', 'Kamal Tripathi', '89c8bea7-a025-55f9-8858-3b1220253648', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('a1a052ca-de3c-5bc8-811f-fb5b9c0ca160', 'Pranjal Puri', '89c8bea7-a025-55f9-8858-3b1220253648', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('df7c6a07-1ed8-5d13-b601-f52736f8d7d6', 'Himanshu Shinde', '89c8bea7-a025-55f9-8858-3b1220253648', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('fcb64b16-e1c9-5810-8b52-311c6dc0dab0', 'Tanishq Yadav', '89c8bea7-a025-55f9-8858-3b1220253648', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('332c919b-7eac-5035-8014-dcc5dce42255', 'Ajay Mishra', '89c8bea7-a025-55f9-8858-3b1220253648', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('175f38b8-8402-57e3-a9ac-296f10ea624a', 'Pawan Nirwani', '89c8bea7-a025-55f9-8858-3b1220253648', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('8b2e24fd-e479-578d-928a-40a1ff1cf63e', 'Amol Kasture', '89c8bea7-a025-55f9-8858-3b1220253648', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('eb5862bd-322f-583b-a91a-728e1aa1d5ba', 'Yuvraj Nema', '89c8bea7-a025-55f9-8858-3b1220253648', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('3d0ebbab-1221-5ab5-a086-dcb55c9653b1', 'Anurag Malwiya', '89c8bea7-a025-55f9-8858-3b1220253648', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('c2af755b-5e2b-552e-84d5-f15701bf9248', 'Manish Kumar', '89c8bea7-a025-55f9-8858-3b1220253648', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('b4fc481b-9d0c-5ffb-9bd7-576c9bbd0252', 'Saksham Purohit', '42c007fa-6d22-56b0-981b-fae8db3c0483', 'Wicketkeeper', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('b5bd61ff-5683-51bb-b5f9-4c60259e25c5', 'Rakesh Thakur', '42c007fa-6d22-56b0-981b-fae8db3c0483', 'Wicketkeeper', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('d2fda9b6-adf3-536b-b8d5-10529664d2c1', 'Pankaj Sharma', '42c007fa-6d22-56b0-981b-fae8db3c0483', 'Batter', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('5c41a2db-95b8-5fda-94cb-baf02e8545d3', 'Ansh Yadav', '42c007fa-6d22-56b0-981b-fae8db3c0483', 'Batter', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('580812e1-bbb3-5071-8e0b-bc7ce717c1e2', 'Rishabh Chauhan', '42c007fa-6d22-56b0-981b-fae8db3c0483', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('0fedfcd7-31fe-5be9-9e65-58daaf7d89e1', 'Akhil Nigote', '42c007fa-6d22-56b0-981b-fae8db3c0483', 'Batter', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('fe7efb2f-9244-58c6-a3fd-55f32427a875', 'Ashutosh Sharma', '42c007fa-6d22-56b0-981b-fae8db3c0483', 'Batter', 'Right-hand bat', 'Right-arm medium', '2026-01-01T10:00:00'),
  ('760c9582-173c-5107-8472-55496ef09cef', 'Parth Sahani', '42c007fa-6d22-56b0-981b-fae8db3c0483', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('8a5aad69-90e1-5713-b7f7-5bf83631cbc1', 'Prashant Kasde', '42c007fa-6d22-56b0-981b-fae8db3c0483', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('3d68aabb-51d3-51d6-9aa3-44c84c72caea', 'Aditya Mishra', '42c007fa-6d22-56b0-981b-fae8db3c0483', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('827fbd94-bf19-51e7-b3d8-24bca42f8d9b', 'Harshwardhan Singh', '42c007fa-6d22-56b0-981b-fae8db3c0483', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('d1aba495-c7db-5b97-850b-60e778095755', 'Aryan Deshmukh', '42c007fa-6d22-56b0-981b-fae8db3c0483', 'All-rounder', 'Left-hand bat', 'Right-arm offbreak', '2026-01-01T10:00:00'),
  ('75d0d91b-b3b6-5f3c-88af-7db4e964d45c', 'Ishan Chaudhary', '42c007fa-6d22-56b0-981b-fae8db3c0483', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('d98dae83-73f6-5b91-a61d-c3988fe29777', 'Vineet Rawat', '42c007fa-6d22-56b0-981b-fae8db3c0483', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00'),
  ('17b7067e-ff1f-5a30-955b-b01d8a27702a', 'Vivek Sharma', '42c007fa-6d22-56b0-981b-fae8db3c0483', 'Bowler', 'Right-hand bat', 'Left-arm fast', '2026-01-01T10:00:00')
on conflict (id) do nothing
;

-- Style updates from user-supplied roster
update players set batting_style = 'Right-hand bat' where id = 'b4fc481b-9d0c-5ffb-9bd7-576c9bbd0252'; -- Saksham Purohit
update players set batting_style = 'Right-hand bat' where id = 'b5bd61ff-5683-51bb-b5f9-4c60259e25c5'; -- Rakesh Thakur
update players set batting_style = 'Left-hand bat' where id = 'd2fda9b6-adf3-536b-b8d5-10529664d2c1'; -- Pankaj Sharma
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm offbreak' where id = '5c41a2db-95b8-5fda-94cb-baf02e8545d3'; -- Ansh Yadav
update players set batting_style = 'Right-hand bat', bowling_style = 'Left-arm orthodox spin' where id = '580812e1-bbb3-5071-8e0b-bc7ce717c1e2'; -- Rishabh Chauhan
update players set batting_style = 'Right-hand bat' where id = '0fedfcd7-31fe-5be9-9e65-58daaf7d89e1'; -- Akhil Nigote
update players set batting_style = 'Right-hand bat' where id = 'fe7efb2f-9244-58c6-a3fd-55f32427a875'; -- Ashutosh Sharma
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm orthodox spin' where id = '760c9582-173c-5107-8472-55496ef09cef'; -- Parth Sahani
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm wrist spin' where id = '8a5aad69-90e1-5713-b7f7-5bf83631cbc1'; -- Prashant Kasde
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm orthodox spin' where id = '3d68aabb-51d3-51d6-9aa3-44c84c72caea'; -- Aditya Mishra
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '827fbd94-bf19-51e7-b3d8-24bca42f8d9b'; -- Harshwardhan Singh
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = 'd1aba495-c7db-5b97-850b-60e778095755'; -- Aryan Deshmukh
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '75d0d91b-b3b6-5f3c-88af-7db4e964d45c'; -- Ishan Chaudhary
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = 'd98dae83-73f6-5b91-a61d-c3988fe29777'; -- Vineet Rawat
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm medium fast' where id = '17b7067e-ff1f-5a30-955b-b01d8a27702a'; -- Vivek Sharma
update players set batting_style = 'Left-hand bat' where id = '3313c4ab-7f84-51a6-a9db-707f3b4f0983'; -- Kuldeep Gehi
update players set batting_style = 'Right-hand bat' where id = '8f502ba1-ed08-5dd7-b9a1-9eeafda52406'; -- Vikas Sharma
update players set batting_style = 'Right-hand bat' where id = 'fb5bccb7-881d-5ed5-9fb7-521747fc08cb'; -- Varun Tiwari
update players set batting_style = 'Right-hand bat' where id = '3ea57ec9-dd66-5321-8669-ec767c467f61'; -- Parth Chaudhary
update players set batting_style = 'Left-hand bat', bowling_style = 'Right-arm offbreak' where id = 'c07ce930-7239-56c7-a87c-8dfab62436c5'; -- Kartik Parihar
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm orthodox spin' where id = '999836e6-f267-56b5-82fc-d874737ec447'; -- Vandit Joshi
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm orthodox spin' where id = 'd6b5b3f7-4583-59e6-89a1-9b9f5e883ba2'; -- Saumy Pandey
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = 'cfbc5a3c-7efa-5f50-b9a4-0bf3f2e2fa2a'; -- Akash Singh
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = 'b199ea13-ead3-59fd-8f86-530506d3227a'; -- Ishan Afridi
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '9f47f49c-29f6-5aaf-b21e-047fc3b72985'; -- Anubhav Agrawal
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm offbreak' where id = 'f772a481-aac3-5e96-bdee-6f6466852b92'; -- Arpit Patel
update players set batting_style = 'Right-hand bat' where id = '687036d9-a074-5868-a9fd-310d8907a3ea'; -- Anil Maurya
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm offbreak' where id = 'f16fa647-c5f7-5d19-ac61-bba3be832560'; -- Tushar Verma
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium' where id = '4f062956-019c-5a34-82e6-2b4508a34d17'; -- Varun Shinde
update players set batting_style = 'Right-hand bat' where id = 'f6d907f4-f8bb-52aa-99ae-772bbf4b652a'; -- Rajat Patidar
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm medium fast' where id = '40c90b46-0444-56dd-a8db-9fc2cef21a1b'; -- Mangesh Yadav
update players set batting_style = 'Right-hand bat' where id = 'bdfb9f70-ac54-5c21-b013-cc0c4ad44b45'; -- Aniket Verma
update players set batting_style = 'Left-hand bat' where id = 'c7022cce-a30e-54e0-972e-b076a0dee0c0'; -- Ansh Bagadia
update players set batting_style = 'Right-hand bat' where id = '15915c22-37bb-5f32-8ffe-ebd791791ed5'; -- Suraj Yadav
update players set batting_style = 'Right-hand bat' where id = 'd602bbdc-ef2a-53d4-a240-3c727a368bb4'; -- Anchit Thakur
update players set batting_style = 'Right-hand bat' where id = 'a652e185-c0c1-5361-9b36-14f575b0c276'; -- Rahul Chandrol
update players set batting_style = 'Right-hand bat' where id = 'e6d242cb-20f9-5d54-9009-e30b9805001f'; -- Kunal Rai
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm offbreak' where id = 'e8d4cbc5-c3e3-5276-ac3b-a3c363258fb3'; -- Kamal Tripathi
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = 'a1a052ca-de3c-5bc8-811f-fb5b9c0ca160'; -- Pranjal Puri
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm offbreak' where id = 'df7c6a07-1ed8-5d13-b601-f52736f8d7d6'; -- Himanshu Shinde
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm legbreak' where id = 'fcb64b16-e1c9-5810-8b52-311c6dc0dab0'; -- Tanishq Yadav
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '332c919b-7eac-5035-8014-dcc5dce42255'; -- Ajay Mishra
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm orthodox spin' where id = '175f38b8-8402-57e3-a9ac-296f10ea624a'; -- Pawan Nirwani
update players set batting_style = 'Right-hand bat', bowling_style = 'Left-arm orthodox spin' where id = '8b2e24fd-e479-578d-928a-40a1ff1cf63e'; -- Amol Kasture
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm legbreak' where id = 'eb5862bd-322f-583b-a91a-728e1aa1d5ba'; -- Yuvraj Nema
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '3d0ebbab-1221-5ab5-a086-dcb55c9653b1'; -- Anurag Malwiya
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = 'c2af755b-5e2b-552e-84d5-f15701bf9248'; -- Manish Kumar
update players set batting_style = 'Left-hand bat' where id = '26fe523a-8080-5d6b-91df-2a56855d6b82'; -- Ojaswa Yadav
update players set batting_style = 'Left-hand bat', bowling_style = 'Right-arm offbreak' where id = '4c5420f4-0540-53d4-ba92-5a185793cff3'; -- Shubham Kushwah
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm orthodox spin / Right-arm offbreak' where id = 'aab476d8-1b1e-5e64-b131-f8a20a926547'; -- Soham Patwardhan
update players set batting_style = 'Right-hand bat' where id = '8acb0d9d-2348-5e81-b225-c4b61ab10274'; -- Darshan Rathore
update players set batting_style = 'Right-hand bat' where id = '76c8afae-d578-5f7d-a434-bff3e9426dc8'; -- Chanchal Rathore
update players set batting_style = 'Right-hand bat' where id = 'c9704649-b025-5ae3-a7e1-58959be7b68c'; -- Yash Dubey
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = 'd58207e1-c9a0-5d95-a068-5c1ef03e6086'; -- Madhav Tiwari
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = 'f37d1d1d-bd57-559c-9e29-7bebccc95480'; -- Aryan Pandey
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '17ec0eb7-e6f6-5367-9484-40316d13e11d'; -- Ankur Singh Chauhan
update players set batting_style = 'Right-hand bat', bowling_style = 'Left-arm orthodox spin' where id = '5f9d6003-67e6-5524-b959-57d064eb9ac2'; -- Rishi Miglani
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm medium fast' where id = '07f64c0c-c68f-5b8a-9ba5-efaf48a27ceb'; -- Harshwardhan Hardia
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm medium fast' where id = '27d217d2-3af4-5405-a088-c7ef5ad6ac41'; -- Gajendra Goswami
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm offbreak' where id = 'e81c782b-8204-50d9-9e14-c0968343fe65'; -- Adheer Pratap Singh
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm legbreak' where id = '23350497-ca69-525f-b620-d61b88cb8670'; -- Aayush Mankar
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm orthodox spin' where id = '6ff44d93-aa39-5b93-9d9e-4f4ee94696d2'; -- Masoom Raza Khan
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm medium fast' where id = '04be1900-80cc-5f43-a46d-d1f0f514299e'; -- Naveen Nagle
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = 'f398a1ab-b968-5027-b072-70586c71d93f'; -- Vishesh Mudgal
update players set batting_style = 'Left-hand bat', bowling_style = 'Right-arm legbreak' where id = 'c3abcf6b-af87-50dd-b6cd-bef5ba923ff4'; -- Ankush Singh
update players set batting_style = 'Right-hand bat' where id = '810363ec-7c2f-59ec-b81f-071000960904'; -- Rohit Kumar Gupta
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm offbreak' where id = 'bdd646e4-e7c4-51c1-a3bf-f1bac631a751'; -- Shubham Sharma
update players set batting_style = 'Right-hand bat', bowling_style = 'Left-arm orthodox spin' where id = 'bfd18390-21b9-5c61-8765-373789c7f2f2'; -- Aman Bhadoria
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm orthodox spin' where id = '33e1f887-5e0a-513d-b17e-d50a5f9eae6f'; -- Gautam Raghuwanshi
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '6d6158a0-64c1-5235-b5f3-55f601773dfd'; -- Harsh Dixit
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '8f53ea6e-5db4-5b51-beec-3cf622142bf7'; -- Tripuresh Singh
update players set batting_style = 'Right-hand bat' where id = '4787b00e-afcc-5f5d-8a98-f5d1b96283a1'; -- Karan Tiwari
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm orthodox spin' where id = '84742574-8090-541e-b3ea-45031a5eaad5'; -- Diyanshu Yadav
update players set batting_style = 'Right-hand bat' where id = '1a2a261a-eab8-5945-805f-ab56e7ee4265'; -- Apurve Dwivedi
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '4beced42-4683-5cd7-a3d4-eafb40a735c1'; -- Avesh Khan
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '59efe8ae-f3df-5200-b756-93fd814d31c6'; -- Akshay Singh
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm legbreak' where id = '661efd97-7f59-5db8-a791-fa9a2779d9cc'; -- Mayur Patel
update players set batting_style = 'Right-hand bat', bowling_style = 'Left-arm medium fast' where id = '8f1f6e57-aae3-54b2-b8e1-846e81517c05'; -- Piyush Patel
update players set batting_style = 'Right-hand bat', bowling_style = 'Left-arm wrist spin' where id = 'f25b9fd7-d8e1-5eeb-877b-84bd2138026c'; -- Yash Kumar Lodhi
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '29b93c79-f1bc-5d03-ac0c-11d631feaed0'; -- Madhur Seth
update players set batting_style = 'Right-hand bat' where id = 'b1507fce-9244-5c38-bf11-cfc4aa6461d8'; -- Karan Tahliyani
update players set batting_style = 'Left-hand bat' where id = 'e934d378-43e4-5740-a2a1-abeda43b917e'; -- Atharv Joshi
update players set batting_style = 'Right-hand bat' where id = '21662ce5-2368-571f-8d64-26d735145aa5'; -- Siddarth Patidar
update players set batting_style = 'Left-hand bat', bowling_style = 'Right-arm medium fast' where id = 'f56a747c-cd41-5456-ab5d-60a273526bf4'; -- Venkatesh Iyer
update players set batting_style = 'Left-hand bat', bowling_style = 'Right-arm medium fast' where id = '9b8ce6e3-bb3b-56d0-8930-9c503e517e4d'; -- Anvesh Chawla
update players set batting_style = 'Left-hand bat' where id = '86a3bdf2-0579-543c-bd84-12d083001309'; -- Aayaam Verma
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = 'd4a25b3f-0333-564f-bc8b-8e57a3b41a99'; -- Saransh Surana
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium' where id = '8c118ea4-e9c1-5620-a56e-885ee57dbd4a'; -- Shivam Shukla
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = 'c8d836da-3c55-5fa1-b68a-2989f45aab44'; -- Roshan Kewat
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm orthodox spin' where id = '0fc9b647-05ac-5f19-aefc-a3e704037c4e'; -- Akash Rajawat
update players set batting_style = 'Right-hand bat', bowling_style = 'Left-arm orthodox spin' where id = 'd52da864-1c4f-53e1-b7b4-94fc1879d773'; -- Vishnu Bhardwaj
update players set batting_style = 'Right-hand bat' where id = 'fab398ff-2405-564f-8d25-4e33023b20e6'; -- Arpit Gaud
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm offbreak' where id = 'c92621ac-3bf1-5f82-b55e-215425cbb283'; -- Akarsh Singh Parihar
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm offbreak' where id = '925def19-3968-5442-b573-223adaf5a693'; -- Prince Wadhwani
update players set batting_style = 'Right-hand bat' where id = 'af9615ee-2603-5400-92a5-834a5d2719e9'; -- Ajay Rohera
update players set batting_style = 'Right-hand bat' where id = 'e9ab0e02-e7e6-5595-b7d0-8bb2891e2c4a'; -- Abhishek Bhandari
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '4d98b52f-c702-5ecb-9124-a36c23e956bc'; -- Puneet Datey
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '29993758-c857-5658-9114-cc74a26c1880'; -- Ritik Tada
update players set batting_style = 'Right-hand bat', bowling_style = 'Left-arm orthodox spin' where id = 'bb5c157d-7607-5723-9023-d11cc790cec7'; -- Nayan Raj Mewada
update players set batting_style = 'Left-hand bat', bowling_style = 'Right-arm medium fast' where id = 'e02a6367-53de-5119-baf1-4affd88d2850'; -- Akshat Dwivedi
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '1f44fb2f-bd66-5467-bf4d-085daeb7c176'; -- Rahul Batham
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '14819b05-062e-56b6-a956-bc5711eb6673'; -- Sanjog Nijjar
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm offbreak' where id = '431edc70-c312-5536-a1ca-aab18576774f'; -- Vedant Awasthi
update players set batting_style = 'Right-hand bat', bowling_style = 'Left-arm medium fast' where id = '0bc71b97-5af4-586d-96fb-ecbaa7affaab'; -- Pankaj Patel
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '03029869-5b08-58a5-8ba2-6af1ed546d6a'; -- Akshay Sharma
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm legbreak' where id = '7f3d49e1-bb8e-5a9a-b450-58ecbd064607'; -- Aayam Sardana
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm legbreak' where id = '182f840e-6561-57f1-9ee9-ef9386fa72d3'; -- Mihir Hirwani
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '7a0298b6-de41-5113-9b49-7f1c5691ee5a'; -- Ritwik Diwan
update players set batting_style = 'Right-hand bat' where id = '14285295-0308-5eed-abb1-b4c02962a013'; -- Akshat Raghuwanshi
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm wrist spin' where id = '480c03c5-ea83-5913-8a4b-947fc3bf5a28'; -- Atharva Mahajan
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '98f0ac74-9b0a-56a2-a9a0-254195bcc80a'; -- Sagar Pratap Singh
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm orthodox spin' where id = '26ed4478-2b30-5de3-ba83-96749866d006'; -- Arham Aqueel
update players set batting_style = 'Right-hand bat' where id = 'c1c0d96d-ac8e-5e26-a70c-c25f11359448'; -- Anant Verma
update players set batting_style = 'Right-hand bat' where id = 'b218001e-c822-58e7-ab99-da490578ae53'; -- Jaydev Singh
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm orthodox spin' where id = 'c30ccf9b-cb5c-55cb-9266-d50ec530797d'; -- Sagar Solanki
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm offbreak' where id = '8ec8ffda-bfdc-54de-89d4-85e3d75f1ab3'; -- Prithviraj Tomar
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = 'd1b49b26-555f-569a-87eb-f55a7443c614'; -- Ankit Singh Kushwah
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = 'a4edd760-ef34-5814-bb32-3e3a238042e2'; -- Naveen Singh Chauhan
update players set batting_style = 'Right-hand bat', bowling_style = 'Left-arm medium fast' where id = 'a8bcd523-2f54-5dbe-bc14-55c5d83c4bf7'; -- Ramveer Singh Gurjar
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '2b2f93bb-fe9d-5b14-abb3-6a5fe6c1a9c8'; -- Ashwin Das
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm offbreak' where id = 'cbdf43c9-cbd8-5235-936c-14d31366433c'; -- Rohit Rajawat
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium' where id = '170f726a-b896-5d70-a271-3ad3ec5eeab4'; -- Prabhanshu Shukla
update players set bowling_style = 'Left-arm medium fast' where id = 'f66e071a-cbc5-55b9-a19e-f985cc89bc54'; -- Ritesh Shakya
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm medium fast' where id = 'd08027f6-3fd4-56aa-a805-39c6005846c7'; -- Radhakrishna Dwivedi
update players set batting_style = 'Right-hand bat' where id = '7c3bef67-21bb-5f49-b72f-29484f10aa3c'; -- Parth Goswami
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm offbreak' where id = '7f40be31-fc73-5139-a38d-5194608282e1'; -- Abhishek Pathak
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm legbreak' where id = '3d2781b2-a98d-53e3-96a7-7640cf6ee944'; -- Rudransh Singh
update players set batting_style = 'Right-hand bat' where id = 'c8f284a8-e738-59e4-b7b5-ace9a37f6a2b'; -- Harsh Gawali
update players set batting_style = 'Right-hand bat' where id = '449bf9a5-34b1-52c1-9b27-9378f96cf184'; -- Kushagra Wadhwa
update players set batting_style = 'Right-hand bat', bowling_style = 'Left-arm wrist spin' where id = 'e0b867ba-e046-579b-854b-4bf09ce97592'; -- Shvang Kumar
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '3a6cb1d7-9e68-5074-8653-b57573a9f9eb'; -- Vikrant Bhadoriya
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '2541f929-1c7b-5ec4-8e9d-6f8ae8f22ff8'; -- Anant Dubey
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm offbreak' where id = '660e82ef-f58e-562f-983e-53fc4a2d6b32'; -- Aman Jain
update players set bowling_style = 'Right-arm offbreak' where id = '1259d056-9bad-51ef-8ab7-caf13adcbff6'; -- Gautam Joshi
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm orthodox spin' where id = '0746cd79-5361-5ef8-ad53-8df4ee43b5bc'; -- Bhumesh Muzalda
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = 'd07905cb-9b4f-594a-972d-ceedba4bf8a6'; -- Kuldeep Sen
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '16ec489b-ec1f-537d-bf0e-431af7a9e9f8'; -- Omkarnath Singh
update players set batting_style = 'Right-hand bat' where id = '0e149403-3793-5acd-a209-daa0b036cfd5'; -- Harshit Parsai
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm medium fast' where id = '3dbfaf13-b0d2-5a9b-94ae-81c16fe26b47'; -- Yash Patidar
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm legbreak' where id = '3e1e44a2-bac8-5ece-8a5c-8c42201bd2be'; -- Milan Shivhare
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm offbreak' where id = 'c1ba6d40-d4f7-5671-97d7-da99594292a3'; -- Anand Singh Bais
update players set batting_style = 'Right-hand bat' where id = '930b10f7-a3a0-5f30-b2cc-34baf62ace88'; -- Abhishek Mavi
update players set batting_style = 'Left-hand bat' where id = 'b3959799-7ce4-5e1d-bedb-0612b04f822b'; -- Himanshu Mantri
update players set batting_style = 'Right-hand bat' where id = '8f2e9484-5216-5a56-9937-4c7fdf41c8d1'; -- Pranit Patidar
update players set batting_style = 'Left-hand bat', bowling_style = 'Right-arm offbreak' where id = 'f7ac72c3-f544-5a78-b5b5-d57f962c6811'; -- Saransh Jain
update players set batting_style = 'Right-hand bat' where id = '58201413-0f11-5f9f-9c43-5c1ce756ccf4'; -- Kanishk Dubey
update players set batting_style = 'Right-hand bat' where id = 'b0f804d9-8900-5473-8e3b-598a35cfd424'; -- Shantanu Raghuvanshi
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm legbreak' where id = 'b5b53032-9576-5eb8-933d-3ac8a9884f57'; -- Prarabdh Mishra
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = 'cfae1e19-cece-5fcb-9ca0-c6b8ea455378'; -- Pushkar Vishwakarma
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '8c2ac304-10da-5dbc-b8e4-db6753b7c2a8'; -- Dharmesh Patel
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm orthodox spin' where id = 'd15a9fe5-8630-5bd5-a764-7aebea809a9b'; -- Shivansh Chaturvedi
update players set batting_style = 'Right-hand bat', bowling_style = 'Left-arm orthodox spin' where id = 'e3731702-dacf-5e6a-9e4c-55ee74432723'; -- Kumar Kartikeya
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = 'a4ef4c65-66ea-53eb-b3f6-49e455e0a0a4'; -- Kartik Rajoriya
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = 'c2df7539-be90-5fcc-b9ee-bbaf45ea25c8'; -- Parush Mandal
