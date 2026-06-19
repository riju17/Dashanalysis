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
from app.services.import_service import import_service


class ImportDismissalBackfillTests(unittest.TestCase):
    def setUp(self):
        store.reset()

    def test_backfill_dismissal_from_import_payload(self):
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
        venue = store.insert(
            "venues",
            {
                "venue_name": "Test Ground",
                "city": "Indore",
                "country": "India",
            },
        )
        player = store.insert(
            "players",
            {
                "player_name": "Opening Batter",
                "team_id": alpha["id"],
                "role": "Batter",
                "batting_style": "Right-hand bat",
                "bowling_style": "Right-arm medium",
            },
        )
        store.insert(
            "matches",
            {
                "id": "match-1",
                "match_date": "2026-06-19",
                "season": "2026",
                "tournament": "MPt20",
                "match_number": 34,
                "team_a_id": alpha["id"],
                "team_b_id": beta["id"],
                "venue_id": venue["id"],
            },
        )
        stat_row = store.insert(
            "player_match_stats",
            {
                "id": "stat-1",
                "match_id": "match-1",
                "player_id": player["id"],
                "team_id": alpha["id"],
                "batting_position": 1,
                "dismissal": None,
                "runs": 12,
                "balls": 10,
                "fours": 1,
                "sixes": 0,
                "strike_rate": 120.0,
                "overs": 0,
                "maidens": 0,
                "runs_conceded": 0,
                "wickets": 0,
                "dot_balls": 0,
                "economy": 0,
                "catches": 0,
                "runouts": 0,
                "stumpings": 0,
            },
        )
        store.insert(
            "match_imports",
            {
                "id": "import-1",
                "match_id": "match-1",
                "import_type": "url",
                "raw_text": "sample",
                "parsed_json": {
                    "match_details": {"match_number": 34},
                    "innings": [
                        {
                            "team_name": "Alpha",
                            "batting": [
                                {
                                    "player_name": "Opening Batter",
                                    "dismissal": "c Keeper b Quick",
                                }
                            ],
                        }
                    ],
                },
                "confidence_score": 0.9,
                "status": "confirmed",
            },
        )

        result = import_service.backfill_dismissals("match-1")
        refreshed = store.get("player_match_stats", stat_row["id"])

        self.assertEqual(result["processed_imports"], 1)
        self.assertEqual(result["matched_imports"], 1)
        self.assertEqual(result["updated_rows"], 1)
        self.assertEqual(refreshed["dismissal"], "c Keeper b Quick")


if __name__ == "__main__":
    unittest.main()
