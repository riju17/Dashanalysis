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
        store.insert(
            "player_match_stats",
            {
                "id": "stat-2",
                "match_id": "match-2",
                "player_id": beta_bowler["id"],
                "team_id": beta["id"],
                "overs": 4.0,
                "maidens": 0,
                "runs_conceded": 22,
                "wickets": 2,
                "dot_balls": 9,
                "economy": 5.5,
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

    def test_bowling_report_supports_spinner_subcategories(self):
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
        fast_bowler = store.insert(
            "players",
            {
                "player_name": "Fast Bowler",
                "team_id": alpha["id"],
                "role": "Bowler",
                "batting_style": "Right-hand bat",
                "bowling_style": "Right-arm medium fast",
            },
        )
        leg_spinner = store.insert(
            "players",
            {
                "player_name": "Leg Spinner",
                "team_id": alpha["id"],
                "role": "Bowler",
                "batting_style": "Right-hand bat",
                "bowling_style": "Right-arm leg break",
            },
        )
        off_spinner = store.insert(
            "players",
            {
                "player_name": "Off Spinner",
                "team_id": alpha["id"],
                "role": "Bowler",
                "batting_style": "Left-hand bat",
                "bowling_style": "Left-arm orthodox spin",
            },
        )
        right_arm_off_spinner = store.insert(
            "players",
            {
                "player_name": "Right Arm Off Spinner",
                "team_id": alpha["id"],
                "role": "Bowler",
                "batting_style": "Right-hand bat",
                "bowling_style": "Right-arm off break",
            },
        )
        chinaman = store.insert(
            "players",
            {
                "player_name": "Chinaman",
                "team_id": alpha["id"],
                "role": "Bowler",
                "batting_style": "Right-hand bat",
                "bowling_style": "Left-arm wrist spin",
            },
        )
        store.insert(
            "matches",
            {
                "id": "spin-match-1",
                "match_date": "2026-06-13",
                "season": "2026",
                "tournament": "MPt20",
                "match_number": 19,
                "team_a_id": alpha["id"],
                "team_b_id": beta["id"],
                "venue_id": holkar["id"],
            },
        )
        for index, player in enumerate([fast_bowler, leg_spinner, off_spinner, right_arm_off_spinner, chinaman], start=1):
            store.insert(
                "player_match_stats",
                {
                    "id": f"spin-stat-{index}",
                    "match_id": "spin-match-1",
                    "player_id": player["id"],
                    "team_id": alpha["id"],
                    "overs": 4.0,
                    "maidens": 0,
                    "runs_conceded": 16 + index,
                    "wickets": 1,
                    "dot_balls": 6 + index,
                    "economy": 4.0 + index / 10,
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

        spinners_report = analytics_service.player_performance_report(
            mode="bowling",
            style="Spinners",
            venue_id=str(holkar["id"]),
            include_venue=True,
        )
        self.assertEqual(
            {row["player_name"] for row in spinners_report["rows"]},
            {"Leg Spinner", "Off Spinner", "Right Arm Off Spinner", "Chinaman"},
        )
        self.assertEqual(len(spinners_report["rows"]), 4)
        self.assertNotIn("Fast Bowler", {row["player_name"] for row in spinners_report["rows"]})

        right_arm_leg_report = analytics_service.player_performance_report(
            mode="bowling",
            style="Right arm leg spin",
            venue_id=str(holkar["id"]),
            include_venue=True,
        )
        self.assertEqual(len(right_arm_leg_report["rows"]), 1)
        self.assertEqual(right_arm_leg_report["rows"][0]["player_name"], "Leg Spinner")
        self.assertEqual(right_arm_leg_report["rows"][0]["bowling_style_code"], "RALS")

        left_arm_spin_report = analytics_service.player_performance_report(
            mode="bowling",
            style="Left arm spin",
            venue_id=str(holkar["id"]),
            include_venue=True,
        )
        self.assertEqual(len(left_arm_spin_report["rows"]), 1)
        self.assertEqual(left_arm_spin_report["rows"][0]["player_name"], "Off Spinner")
        self.assertEqual(left_arm_spin_report["rows"][0]["bowling_style_code"], "LAOS")

        right_arm_off_spin_report = analytics_service.player_performance_report(
            mode="bowling",
            style="Right arm off spin",
            venue_id=str(holkar["id"]),
            include_venue=True,
        )
        self.assertEqual(len(right_arm_off_spin_report["rows"]), 1)
        self.assertEqual(right_arm_off_spin_report["rows"][0]["player_name"], "Right Arm Off Spinner")
        self.assertEqual(right_arm_off_spin_report["rows"][0]["bowling_style_code"], "RAOS")

        cm_report = analytics_service.player_performance_report(
            mode="bowling",
            style="CM",
            venue_id=str(holkar["id"]),
            include_venue=True,
        )
        self.assertEqual(len(cm_report["rows"]), 1)
        self.assertEqual(cm_report["rows"][0]["player_name"], "Chinaman")
        self.assertEqual(cm_report["rows"][0]["bowling_style_code"], "LCM")

    def test_bowling_report_zero_results_include_style_diagnostics(self):
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
        right_arm_off_spinner = store.insert(
            "players",
            {
                "player_name": "Right Arm Off Spinner",
                "team_id": alpha["id"],
                "role": "Bowler",
                "batting_style": "Right-hand bat",
                "bowling_style": "Right-arm offspin",
            },
        )
        store.insert(
            "matches",
            {
                "id": "diag-match-1",
                "match_date": "2026-06-13",
                "season": "2026",
                "tournament": "MPt20",
                "match_number": 20,
                "team_a_id": alpha["id"],
                "team_b_id": beta["id"],
                "venue_id": holkar["id"],
            },
        )
        store.insert(
            "player_match_stats",
            {
                "id": "diag-stat-1",
                "match_id": "diag-match-1",
                "player_id": right_arm_off_spinner["id"],
                "team_id": alpha["id"],
                "overs": 4.0,
                "maidens": 0,
                "runs_conceded": 19,
                "wickets": 2,
                "dot_balls": 11,
                "economy": 4.75,
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
            style="Left arm spin",
            venue_id=str(holkar["id"]),
            include_venue=True,
        )

        self.assertEqual(report["rows"], [])
        self.assertIn("0 players matched the selected bowling style.", report["summary"])
        self.assertIn(
            "Diagnostic: 'Left arm spin' maps to bowling style codes LALS, LAOS, LAS.",
            report["summary"],
        )
        self.assertIn(
            "Diagnostic: 1 bowling players remained after venue/team filters. Available codes: RAOS (1).",
            report["summary"],
        )
        self.assertIn(
            "Observed bowling_style values after filters: Right-arm offspin (1).",
            report["summary"],
        )

    def test_bowling_report_supports_compact_spinner_codes(self):
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
        compact_players = [
            ("compact-left-arm", "Compact Left Arm", "LAOS"),
            ("compact-leg-spin", "Compact Leg Spin", "LALS"),
            ("compact-chinaman", "Compact Chinaman", "LCM"),
            ("compact-off-spin", "Compact Off Spin", "RAOS"),
        ]

        for index, (player_id, name, bowling_style) in enumerate(compact_players, start=1):
            player = store.insert(
                "players",
                {
                    "id": player_id,
                    "player_name": name,
                    "team_id": alpha["id"],
                    "role": "Bowler",
                    "batting_style": "Right-hand bat",
                    "bowling_style": bowling_style,
                },
            )
            store.insert(
                "matches",
                {
                    "id": f"compact-match-{index}",
                    "match_date": f"2026-06-{index:02d}",
                    "season": "2026",
                    "tournament": "MPt20",
                    "match_number": 30 + index,
                    "team_a_id": alpha["id"],
                    "team_b_id": beta["id"],
                    "venue_id": holkar["id"],
                },
            )
            store.insert(
                "player_match_stats",
                {
                    "id": f"compact-stat-{index}",
                    "match_id": f"compact-match-{index}",
                    "player_id": player["id"],
                    "team_id": alpha["id"],
                    "overs": 4.0,
                    "maidens": 0,
                    "runs_conceded": 20 + index,
                    "wickets": 1,
                    "dot_balls": 10,
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

        left_arm_spin_report = analytics_service.player_performance_report(
            mode="bowling",
            style="Left arm spin",
            venue_id=str(holkar["id"]),
            include_venue=True,
        )
        self.assertEqual(
            {row["player_name"] for row in left_arm_spin_report["rows"]},
            {"Compact Left Arm", "Compact Leg Spin"},
        )

        cm_report = analytics_service.player_performance_report(
            mode="bowling",
            style="CM",
            venue_id=str(holkar["id"]),
            include_venue=True,
        )
        self.assertEqual(
            {row["player_name"] for row in cm_report["rows"]},
            {"Compact Chinaman"},
        )

        right_arm_off_spin_report = analytics_service.player_performance_report(
            mode="bowling",
            style="Right arm off spin",
            venue_id=str(holkar["id"]),
            include_venue=True,
        )
        self.assertEqual(
            {row["player_name"] for row in right_arm_off_spin_report["rows"]},
            {"Compact Off Spin"},
        )

    def test_bowling_report_supports_canonical_style_string_selection(self):
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
        players = [
            ("right-arm-offbreak", "Right Arm Offbreak", "Right-arm offbreak"),
            ("left-arm-orthodox", "Left Arm Orthodox", "Left-arm orthodox spin"),
            ("left-arm-wrist", "Left Arm Wrist", "Left-arm wrist spin"),
        ]

        for index, (player_id, name, bowling_style) in enumerate(players, start=1):
            player = store.insert(
                "players",
                {
                    "id": player_id,
                    "player_name": name,
                    "team_id": alpha["id"],
                    "role": "Bowler",
                    "batting_style": "Right-hand bat",
                    "bowling_style": bowling_style,
                },
            )
            store.insert(
                "matches",
                {
                    "id": f"canonical-style-match-{index}",
                    "match_date": f"2026-06-{index:02d}",
                    "season": "2026",
                    "tournament": "MPt20",
                    "match_number": 40 + index,
                    "team_a_id": alpha["id"],
                    "team_b_id": beta["id"],
                    "venue_id": holkar["id"],
                },
            )
            store.insert(
                "player_match_stats",
                {
                    "id": f"canonical-style-stat-{index}",
                    "match_id": f"canonical-style-match-{index}",
                    "player_id": player["id"],
                    "team_id": alpha["id"],
                    "overs": 4.0,
                    "maidens": 0,
                    "runs_conceded": 18 + index,
                    "wickets": 1,
                    "dot_balls": 10,
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

        offbreak_report = analytics_service.player_performance_report(
            mode="bowling",
            style="Right-arm offbreak",
            venue_id=str(holkar["id"]),
            include_venue=True,
        )
        self.assertEqual(
            {row["player_name"] for row in offbreak_report["rows"]},
            {"Right Arm Offbreak"},
        )

        orthodox_report = analytics_service.player_performance_report(
            mode="bowling",
            style="Left-arm orthodox spin",
            venue_id=str(holkar["id"]),
            include_venue=True,
        )
        self.assertEqual(
            {row["player_name"] for row in orthodox_report["rows"]},
            {"Left Arm Orthodox"},
        )

        wrist_report = analytics_service.player_performance_report(
            mode="bowling",
            style="Left-arm wrist spin",
            venue_id=str(holkar["id"]),
            include_venue=True,
        )
        self.assertEqual(
            {row["player_name"] for row in wrist_report["rows"]},
            {"Left Arm Wrist"},
        )

    def test_bowling_report_supports_canonical_fast_style_string_selection(self):
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
        players = [
            ("left-arm-medium-fast", "Left Arm Seamer", "Left-arm medium fast"),
            ("right-arm-medium-fast", "Right Arm Seamer", "Right-arm medium fast"),
        ]

        for index, (player_id, name, bowling_style) in enumerate(players, start=1):
            player = store.insert(
                "players",
                {
                    "id": player_id,
                    "player_name": name,
                    "team_id": alpha["id"],
                    "role": "Bowler",
                    "batting_style": "Right-hand bat",
                    "bowling_style": bowling_style,
                },
            )
            store.insert(
                "matches",
                {
                    "id": f"canonical-fast-match-{index}",
                    "match_date": f"2026-06-1{index}",
                    "season": "2026",
                    "tournament": "MPt20",
                    "match_number": 60 + index,
                    "team_a_id": alpha["id"],
                    "team_b_id": beta["id"],
                    "venue_id": holkar["id"],
                },
            )
            store.insert(
                "player_match_stats",
                {
                    "id": f"canonical-fast-stat-{index}",
                    "match_id": f"canonical-fast-match-{index}",
                    "player_id": player["id"],
                    "team_id": alpha["id"],
                    "overs": 4.0,
                    "maidens": 0,
                    "runs_conceded": 22 + index,
                    "wickets": 2,
                    "dot_balls": 11,
                    "economy": 5.5,
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

        left_arm_report = analytics_service.player_performance_report(
            mode="bowling",
            style="Left-arm medium fast",
            venue_id=str(holkar["id"]),
            include_venue=True,
        )
        self.assertEqual(
            {row["player_name"] for row in left_arm_report["rows"]},
            {"Left Arm Seamer"},
        )

        right_arm_report = analytics_service.player_performance_report(
            mode="bowling",
            style="Right-arm medium fast",
            venue_id=str(holkar["id"]),
            include_venue=True,
        )
        self.assertEqual(
            {row["player_name"] for row in right_arm_report["rows"]},
            {"Right Arm Seamer"},
        )

    def test_batting_report_supports_batting_style_aliases(self):
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
        left_hander = store.insert(
            "players",
            {
                "player_name": "Left Hander",
                "team_id": alpha["id"],
                "role": "Batter",
                "batting_style": "Left-hand bat",
                "bowling_style": "Left-arm orthodox spin",
            },
        )
        right_hander = store.insert(
            "players",
            {
                "player_name": "Right Hander",
                "team_id": alpha["id"],
                "role": "Batter",
                "batting_style": "Right-hand bat",
                "bowling_style": "Right-arm medium fast",
            },
        )
        store.insert(
            "matches",
            {
                "id": "batting-alias-match-1",
                "match_date": "2026-06-20",
                "season": "2026",
                "tournament": "MPt20",
                "match_number": 51,
                "team_a_id": alpha["id"],
                "team_b_id": beta["id"],
                "venue_id": holkar["id"],
            },
        )
        for index, player in enumerate([left_hander, right_hander], start=1):
            store.insert(
                "player_match_stats",
                {
                    "id": f"batting-alias-stat-{index}",
                    "match_id": "batting-alias-match-1",
                    "player_id": player["id"],
                    "team_id": alpha["id"],
                    "runs": 25 + index,
                    "balls": 20,
                    "fours": 3,
                    "sixes": 1,
                    "strike_rate": 130.0,
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

        lhb_report = analytics_service.player_performance_report(
            mode="batting",
            style="LHB",
            venue_id=str(holkar["id"]),
            include_venue=True,
        )
        self.assertEqual(
            {row["player_name"] for row in lhb_report["rows"]},
            {"Left Hander"},
        )

        rhb_report = analytics_service.player_performance_report(
            mode="batting",
            style="RHB",
            venue_id=str(holkar["id"]),
            include_venue=True,
        )
        self.assertEqual(
            {row["player_name"] for row in rhb_report["rows"]},
            {"Right Hander"},
        )

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

    def test_standings_nrr_uses_ball_based_run_rates(self):
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
                "bat_first_team_id": alpha["id"],
                "bowl_first_team_id": beta["id"],
                "first_innings_score": 200,
                "first_innings_wickets": 5,
                "first_innings_overs": 20.0,
                "second_innings_score": 150,
                "second_innings_wickets": 8,
                "second_innings_overs": 20.0,
                "winner_id": alpha["id"],
                "loser_id": beta["id"],
                "result_type": "runs",
                "margin_runs": 50,
                "margin_wickets": None,
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
                "bat_first_team_id": beta["id"],
                "bowl_first_team_id": alpha["id"],
                "first_innings_score": 180,
                "first_innings_wickets": 7,
                "first_innings_overs": 20.0,
                "second_innings_score": 181,
                "second_innings_wickets": 6,
                "second_innings_overs": 19.3,
                "winner_id": alpha["id"],
                "loser_id": beta["id"],
                "result_type": "wickets",
                "margin_runs": None,
                "margin_wickets": 4,
            },
        )

        standings = analytics_service.standings()

        self.assertEqual(len(standings), 2)
        self.assertEqual(standings[0]["team_name"], "Alpha")
        self.assertEqual(standings[0]["played"], 2)
        self.assertEqual(standings[0]["points"], 4)
        self.assertEqual(standings[0]["nrr"], "1.3956")
        self.assertEqual(standings[1]["team_name"], "Beta")
        self.assertEqual(standings[1]["nrr"], "-1.3956")

    def test_player_summary_includes_bowling_runs_and_dot_balls(self):
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
        player = store.insert(
            "players",
            {
                "player_name": "Alpha Bowler",
                "team_id": alpha["id"],
                "role": "Bowler",
                "batting_style": "Right-hand bat",
                "bowling_style": "Right-arm fast",
            },
        )
        store.insert(
            "player_match_stats",
            {
                "id": "stat-bowling-summary-1",
                "match_id": "match-bowling-summary-1",
                "player_id": player["id"],
                "team_id": alpha["id"],
                "overs": 4.0,
                "maidens": 1,
                "runs_conceded": 24,
                "wickets": 2,
                "dot_balls": 10,
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

        summary = analytics_service.player_summary(str(player["id"]))

        self.assertEqual(summary["bowling"]["runs_conceded"], 24)
        self.assertEqual(summary["bowling"]["dot_balls"], 10)
        self.assertEqual(summary["bowling"]["wickets"], 2)
        self.assertEqual(summary["bowling"]["overs"], 4.0)


if __name__ == "__main__":
    unittest.main()
