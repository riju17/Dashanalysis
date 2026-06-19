from __future__ import annotations

import sys
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

BACKEND = Path(__file__).resolve().parents[1]
if str(BACKEND) not in sys.path:
    sys.path.insert(0, str(BACKEND))

from app.data.store import store
from app.services.analytics_service import analytics_service


class PlayerPerformanceReportTests(unittest.TestCase):
    def setUp(self):
        store.reset()

    def test_bowling_report_filters_by_venue_and_style(self):
        alpha = store.insert(
            "teams",
            {
                "team_name": "Alpha",
                "short_name": "ALP",
                "primary_color": "#111111",
                "secondary_color": "#222222",
                "accent_color": "#333333",
                "logo_url": None,
            },
        )
        beta = store.insert(
            "teams",
            {
                "team_name": "Beta",
                "short_name": "BET",
                "primary_color": "#444444",
                "secondary_color": "#555555",
                "accent_color": "#666666",
                "logo_url": None,
            },
        )
        holkar = store.insert(
            "venues",
            {
                "venue_name": "Holkar Stadium",
                "city": "Indore",
                "country": "India",
            },
        )
        other_venue = store.insert(
            "venues",
            {
                "venue_name": "Other Ground",
                "city": "Bhopal",
                "country": "India",
            },
        )
        bowler = store.insert(
            "players",
            {
                "player_name": "Fast Bowler",
                "team_id": alpha["id"],
                "role": "Bowler",
                "batting_style": "Right-hand bat",
                "bowling_style": "Right-arm medium fast",
            },
        )
        spinner = store.insert(
            "players",
            {
                "player_name": "Spinner",
                "team_id": alpha["id"],
                "role": "Bowler",
                "batting_style": "Right-hand bat",
                "bowling_style": "Left-arm orthodox spin",
            },
        )
        non_bowler = store.insert(
            "players",
            {
                "player_name": "Did Not Bowl",
                "team_id": beta["id"],
                "role": "Batter",
                "batting_style": "Left-hand bat",
                "bowling_style": "Right-arm fast",
            },
        )
        store.insert(
            "matches",
            {
                "id": "match-1",
                "match_date": "2026-06-10",
                "season": "2026",
                "tournament": "MPt20",
                "match_number": 15,
                "team_a_id": alpha["id"],
                "team_b_id": beta["id"],
                "venue_id": holkar["id"],
            },
        )
        store.insert(
            "matches",
            {
                "id": "match-2",
                "match_date": "2026-06-11",
                "season": "2026",
                "tournament": "MPt20",
                "match_number": 16,
                "team_a_id": alpha["id"],
                "team_b_id": beta["id"],
                "venue_id": holkar["id"],
            },
        )
        store.insert(
            "matches",
            {
                "id": "match-3",
                "match_date": "2026-06-12",
                "season": "2026",
                "tournament": "MPt20",
                "match_number": 17,
                "team_a_id": alpha["id"],
                "team_b_id": beta["id"],
                "venue_id": other_venue["id"],
            },
        )
        store.insert(
            "player_match_stats",
            {
                "id": "stat-1",
                "match_id": "match-1",
                "player_id": bowler["id"],
                "team_id": alpha["id"],
                "overs": 4.0,
                "maidens": 1,
                "runs_conceded": 28,
                "wickets": 2,
                "dot_balls": 10,
                "economy": 7.0,
                "runs": 0,
                "balls": 0,
                "fours": 0,
                "sixes": 0,
                "strike_rate": 0.0,
                "catches": 0,
                "runouts": 0,
                "stumpings": 0,
            },
        )
        store.insert(
            "player_match_stats",
            {
                "id": "stat-2",
                "match_id": "match-2",
                "player_id": bowler["id"],
                "team_id": alpha["id"],
                "overs": 3.0,
                "maidens": 0,
                "runs_conceded": 18,
                "wickets": 1,
                "dot_balls": 9,
                "economy": 6.0,
                "runs": 0,
                "balls": 0,
                "fours": 0,
                "sixes": 0,
                "strike_rate": 0.0,
                "catches": 0,
                "runouts": 0,
                "stumpings": 0,
            },
        )
        store.insert(
            "player_match_stats",
            {
                "id": "stat-3",
                "match_id": "match-3",
                "player_id": bowler["id"],
                "team_id": alpha["id"],
                "overs": 4.0,
                "maidens": 0,
                "runs_conceded": 30,
                "wickets": 1,
                "dot_balls": 8,
                "economy": 7.5,
                "runs": 0,
                "balls": 0,
                "fours": 0,
                "sixes": 0,
                "strike_rate": 0.0,
                "catches": 0,
                "runouts": 0,
                "stumpings": 0,
            },
        )
        store.insert(
            "player_match_stats",
            {
                "id": "stat-4",
                "match_id": "match-1",
                "player_id": spinner["id"],
                "team_id": alpha["id"],
                "overs": 4.0,
                "maidens": 0,
                "runs_conceded": 20,
                "wickets": 4,
                "dot_balls": 14,
                "economy": 5.0,
                "runs": 0,
                "balls": 0,
                "fours": 0,
                "sixes": 0,
                "strike_rate": 0.0,
                "catches": 0,
                "runouts": 0,
                "stumpings": 0,
            },
        )
        store.insert(
            "player_match_stats",
            {
                "id": "stat-5",
                "match_id": "match-1",
                "player_id": non_bowler["id"],
                "team_id": beta["id"],
                "overs": 0.0,
                "maidens": 0,
                "runs_conceded": 0,
                "wickets": 0,
                "dot_balls": 0,
                "economy": 0.0,
                "runs": 14,
                "balls": 12,
                "fours": 2,
                "sixes": 0,
                "strike_rate": 116.67,
                "catches": 0,
                "runouts": 0,
                "stumpings": 0,
            },
        )

        report = analytics_service.player_performance_report(
            mode="bowling",
            style="Fast bowler",
            venue_id=str(holkar["id"]),
            include_venue=True,
        )

        self.assertEqual(report["filters"]["venue_name"], "Holkar Stadium")
        self.assertIn("Holkar Stadium", report["report_title"])
        self.assertEqual(len(report["rows"]), 1)

        row = report["rows"][0]
        self.assertEqual(row["player_name"], "Fast Bowler")
        self.assertEqual(row["team_name"], "Alpha")
        self.assertEqual(row["bowling_style_code"], "RAMF")
        self.assertEqual(row["matches_played"], 2)
        self.assertEqual(row["overs"], 7.0)
        self.assertEqual(row["wickets"], 3)
        self.assertEqual(row["dot_balls"], 19)
        self.assertEqual(row["runs_conceded"], 46)
        self.assertAlmostEqual(row["economy"], 6.57, places=2)
        self.assertEqual(row["best_match"]["match_number"], 15)
        self.assertEqual(row["best_match"]["venue_name"], "Holkar Stadium")
        self.assertAlmostEqual(row["best_score"], 44.0, places=2)
        self.assertEqual(len(report["team_totals"]), 1)
        self.assertEqual(report["team_totals"][0]["team_name"], "Alpha")
        self.assertEqual(report["team_totals"][0]["players_count"], 1)
        self.assertEqual(report["team_totals"][0]["matches_played"], 2)
        self.assertEqual(report["team_totals"][0]["overs_balls"], 42)
        self.assertEqual(report["overall_total"]["team_name"], "Overall Total")
        self.assertEqual(report["overall_total"]["matches_played"], 2)
        self.assertEqual(report["overall_total"]["wickets"], 3)

        all_bowlers_report = analytics_service.player_performance_report(
            mode="bowling",
            style="All",
            venue_id=str(holkar["id"]),
            include_venue=True,
        )
        self.assertEqual(len(all_bowlers_report["rows"]), 2)
        self.assertEqual({row["player_name"] for row in all_bowlers_report["rows"]}, {"Fast Bowler", "Spinner"})
        self.assertNotIn("Did Not Bowl", {row["player_name"] for row in all_bowlers_report["rows"]})

    def test_bowling_report_can_filter_selected_teams(self):
        alpha = store.insert(
            "teams",
            {
                "team_name": "Alpha",
                "short_name": "ALP",
                "primary_color": "#111111",
                "secondary_color": "#222222",
                "accent_color": "#333333",
                "logo_url": None,
            },
        )
        beta = store.insert(
            "teams",
            {
                "team_name": "Beta",
                "short_name": "BET",
                "primary_color": "#444444",
                "secondary_color": "#555555",
                "accent_color": "#666666",
                "logo_url": None,
            },
        )
        holkar = store.insert(
            "venues",
            {
                "venue_name": "Holkar Stadium",
                "city": "Indore",
                "country": "India",
            },
        )
        alpha_bowler = store.insert(
            "players",
            {
                "player_name": "Alpha Fast Bowler",
                "team_id": alpha["id"],
                "role": "Bowler",
                "batting_style": "Right-hand bat",
                "bowling_style": "Right-arm fast",
            },
        )
        beta_bowler = store.insert(
            "players",
            {
                "player_name": "Beta Spinner",
                "team_id": beta["id"],
                "role": "Bowler",
                "batting_style": "Left-hand bat",
                "bowling_style": "Left-arm orthodox spin",
            },
        )
        store.insert(
            "matches",
            {
                "id": "match-1",
                "match_date": "2026-06-10",
                "season": "2026",
                "tournament": "MPt20",
                "match_number": 15,
                "team_a_id": alpha["id"],
                "team_b_id": beta["id"],
                "venue_id": holkar["id"],
            },
        )
        store.insert(
            "player_match_stats",
            {
                "id": "stat-1",
                "match_id": "match-1",
                "player_id": alpha_bowler["id"],
                "team_id": alpha["id"],
                "overs": 4.0,
                "maidens": 1,
                "runs_conceded": 24,
                "wickets": 2,
                "dot_balls": 11,
                "economy": 6.0,
                "runs": 0,
                "balls": 0,
                "fours": 0,
                "sixes": 0,
                "strike_rate": 0.0,
                "catches": 0,
                "runouts": 0,
                "stumpings": 0,
            },
        )
        alpha_spinner = store.insert(
            "players",
            {
                "player_name": "Alpha Spinner",
                "team_id": alpha["id"],
                "role": "Bowler",
                "batting_style": "Right-hand bat",
                "bowling_style": "Left-arm orthodox spin",
            },
        )
        store.insert(
            "player_match_stats",
            {
                "id": "stat-2",
                "match_id": "match-1",
                "player_id": beta_bowler["id"],
                "team_id": beta["id"],
                "overs": 4.0,
                "maidens": 0,
                "runs_conceded": 30,
                "wickets": 1,
                "dot_balls": 8,
                "economy": 7.5,
                "runs": 0,
                "balls": 0,
                "fours": 0,
                "sixes": 0,
                "strike_rate": 0.0,
                "catches": 0,
                "runouts": 0,
                "stumpings": 0,
            },
        )
        store.insert(
            "player_match_stats",
            {
                "id": "stat-3",
                "match_id": "match-1",
                "player_id": alpha_spinner["id"],
                "team_id": alpha["id"],
                "overs": 2.0,
                "maidens": 0,
                "runs_conceded": 10,
                "wickets": 1,
                "dot_balls": 6,
                "economy": 5.0,
                "runs": 0,
                "balls": 0,
                "fours": 0,
                "sixes": 0,
                "strike_rate": 0.0,
                "catches": 0,
                "runouts": 0,
                "stumpings": 0,
            },
        )

        report = analytics_service.player_performance_report(
            mode="bowling",
            style="All",
            venue_id=str(holkar["id"]),
            include_venue=True,
            team_ids=[str(alpha["id"])],
        )

        self.assertEqual(report["filters"]["team_names"], ["Alpha"])
        self.assertEqual(len(report["rows"]), 2)
        self.assertEqual(report["rows"][0]["player_name"], "Alpha Fast Bowler")
        self.assertEqual(len(report["team_totals"]), 1)
        self.assertEqual(report["team_totals"][0]["team_name"], "Alpha")
        self.assertEqual(report["team_totals"][0]["matches_played"], 1)
        self.assertEqual(report["team_totals"][0]["wickets"], 3)
        self.assertEqual(report["overall_total"]["matches_played"], 1)
        self.assertEqual(report["overall_total"]["wickets"], 3)

    def test_bowling_report_normalizes_six_balls_to_one_over(self):
        alpha = store.insert(
            "teams",
            {
                "team_name": "Alpha",
                "short_name": "ALP",
                "primary_color": "#111111",
                "secondary_color": "#222222",
                "accent_color": "#333333",
                "logo_url": None,
            },
        )
        beta = store.insert(
            "teams",
            {
                "team_name": "Beta",
                "short_name": "BET",
                "primary_color": "#444444",
                "secondary_color": "#555555",
                "accent_color": "#666666",
                "logo_url": None,
            },
        )
        holkar = store.insert(
            "venues",
            {
                "venue_name": "Holkar Stadium",
                "city": "Indore",
                "country": "India",
            },
        )
        bowler = store.insert(
            "players",
            {
                "player_name": "Death Over Bowler",
                "team_id": alpha["id"],
                "role": "Bowler",
                "batting_style": "Right-hand bat",
                "bowling_style": "Right-arm fast",
            },
        )
        store.insert(
            "matches",
            {
                "id": "match-6balls",
                "match_date": "2026-06-12",
                "season": "2026",
                "tournament": "MPt20",
                "match_number": 18,
                "team_a_id": alpha["id"],
                "team_b_id": beta["id"],
                "venue_id": holkar["id"],
            },
        )
        store.insert(
            "player_match_stats",
            {
                "id": "stat-6balls",
                "match_id": "match-6balls",
                "player_id": bowler["id"],
                "team_id": alpha["id"],
                "overs": 0.6,
                "maidens": 0,
                "runs_conceded": 6,
                "wickets": 1,
                "dot_balls": 4,
                "economy": 6.0,
                "runs": 0,
                "balls": 0,
                "fours": 0,
                "sixes": 0,
                "strike_rate": 0.0,
                "catches": 0,
                "runouts": 0,
                "stumpings": 0,
            },
        )

        report = analytics_service.player_performance_report(
            mode="bowling",
            style="All",
            venue_id=str(holkar["id"]),
            include_venue=True,
        )

        self.assertEqual(len(report["rows"]), 1)
        self.assertEqual(report["rows"][0]["overs_balls"], 6)
        self.assertEqual(report["rows"][0]["overs"], 1.0)
        self.assertAlmostEqual(report["rows"][0]["economy"], 6.0, places=2)
        self.assertEqual(report["overall_total"]["overs_balls"], 6)
        self.assertEqual(report["overall_total"]["overs"], 1.0)

    def test_batting_report_supports_all_style_filter(self):
        alpha = store.insert(
            "teams",
            {
                "team_name": "Alpha",
                "short_name": "ALP",
                "primary_color": "#111111",
                "secondary_color": "#222222",
                "accent_color": "#333333",
                "logo_url": None,
            },
        )
        beta = store.insert(
            "teams",
            {
                "team_name": "Beta",
                "short_name": "BET",
                "primary_color": "#444444",
                "secondary_color": "#555555",
                "accent_color": "#666666",
                "logo_url": None,
            },
        )
        holkar = store.insert(
            "venues",
            {
                "venue_name": "Holkar Stadium",
                "city": "Indore",
                "country": "India",
            },
        )
        batter = store.insert(
            "players",
            {
                "player_name": "Top Order",
                "team_id": alpha["id"],
                "role": "Batter",
                "batting_style": "Right-hand bat",
                "bowling_style": "Right-arm medium",
            },
        )
        all_rounder = store.insert(
            "players",
            {
                "player_name": "Left Hander",
                "team_id": alpha["id"],
                "role": "All-rounder",
                "batting_style": "Left-hand bat",
                "bowling_style": "Left-arm orthodox spin",
            },
        )
        did_not_bat = store.insert(
            "players",
            {
                "player_name": "No Batting Chance",
                "team_id": beta["id"],
                "role": "Bowler",
                "batting_style": "Right-hand bat",
                "bowling_style": "Right-arm medium",
            },
        )
        store.insert(
            "matches",
            {
                "id": "bat-match-1",
                "match_date": "2026-06-10",
                "season": "2026",
                "tournament": "MPt20",
                "match_number": 21,
                "team_a_id": alpha["id"],
                "team_b_id": beta["id"],
                "venue_id": holkar["id"],
            },
        )
        store.insert(
            "matches",
            {
                "id": "bat-match-2",
                "match_date": "2026-06-11",
                "season": "2026",
                "tournament": "MPt20",
                "match_number": 22,
                "team_a_id": alpha["id"],
                "team_b_id": beta["id"],
                "venue_id": holkar["id"],
            },
        )
        store.insert(
            "player_match_stats",
            {
                "id": "bat-stat-1",
                "match_id": "bat-match-1",
                "player_id": batter["id"],
                "team_id": alpha["id"],
                "runs": 41,
                "balls": 29,
                "fours": 5,
                "sixes": 1,
                "strike_rate": 141.38,
                "overs": 0.0,
                "maidens": 0,
                "runs_conceded": 0,
                "wickets": 0,
                "dot_balls": 0,
                "economy": 0.0,
                "catches": 0,
                "runouts": 0,
                "stumpings": 0,
            },
        )
        store.insert(
            "player_match_stats",
            {
                "id": "bat-stat-2",
                "match_id": "bat-match-2",
                "player_id": all_rounder["id"],
                "team_id": alpha["id"],
                "runs": 28,
                "balls": 22,
                "fours": 3,
                "sixes": 0,
                "strike_rate": 127.27,
                "overs": 0.0,
                "maidens": 0,
                "runs_conceded": 0,
                "wickets": 0,
                "dot_balls": 0,
                "economy": 0.0,
                "catches": 0,
                "runouts": 0,
                "stumpings": 0,
            },
        )
        store.insert(
            "player_match_stats",
            {
                "id": "bat-stat-3",
                "match_id": "bat-match-1",
                "player_id": did_not_bat["id"],
                "team_id": beta["id"],
                "runs": 0,
                "balls": 0,
                "fours": 0,
                "sixes": 0,
                "strike_rate": 0.0,
                "overs": 2.0,
                "maidens": 0,
                "runs_conceded": 12,
                "wickets": 1,
                "dot_balls": 4,
                "economy": 6.0,
                "catches": 0,
                "runouts": 0,
                "stumpings": 0,
            },
        )

        report = analytics_service.player_performance_report(
            mode="batting",
            style="All",
            venue_id=str(holkar["id"]),
            include_venue=True,
        )

        self.assertEqual(report["filters"]["venue_name"], "Holkar Stadium")
        self.assertIn("All Batting Styles", report["report_title"])
        self.assertEqual(len(report["rows"]), 2)
        self.assertEqual({row["player_name"] for row in report["rows"]}, {"Top Order", "Left Hander"})
        self.assertTrue(all(row["best_match"]["venue_name"] == "Holkar Stadium" for row in report["rows"]))
        self.assertNotIn("No Batting Chance", {row["player_name"] for row in report["rows"]})


if __name__ == "__main__":
    unittest.main()
