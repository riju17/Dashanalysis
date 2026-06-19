from __future__ import annotations

import sys
import unittest
from pathlib import Path

import fitz


ROOT = Path(__file__).resolve().parents[2]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

BACKEND = Path(__file__).resolve().parents[1]
if str(BACKEND) not in sys.path:
    sys.path.insert(0, str(BACKEND))

from app.services.report_export_service import report_export_service


class ReportExportServiceTests(unittest.TestCase):
    def test_match_report_exports_csv_and_pdf(self):
        report = {
            "report_title": "Alpha vs Beta Match Intelligence Report",
            "report_json": {
                "match_summary": "Alpha beat Beta by 12 runs.",
                "key_turning_points": ["Powerplay collapse", "Death overs control"],
                "strategy_notes": {"batting": "Build innings", "bowling": "Attack stumps"},
            },
        }

        csv_response = report_export_service.export_match_report(report, "csv")
        self.assertEqual(csv_response.media_type, "text/csv")
        self.assertIn("alpha-vs-beta-match-intelligence-report.csv", csv_response.headers["content-disposition"])
        csv_text = csv_response.body.decode("utf-8")
        self.assertIn("Report Title", csv_text)
        self.assertIn("Alpha vs Beta Match Intelligence Report", csv_text)
        self.assertIn("Key Turning Points[1]", csv_text)

        pdf_response = report_export_service.export_match_report(report, "pdf")
        self.assertEqual(pdf_response.media_type, "application/pdf")
        self.assertIn("alpha-vs-beta-match-intelligence-report.pdf", pdf_response.headers["content-disposition"])
        pdf_doc = fitz.open(stream=pdf_response.body, filetype="pdf")
        extracted = "\n".join(page.get_text() for page in pdf_doc)
        self.assertIn("Alpha vs Beta Match Intelligence Report", extracted)
        self.assertIn("Match Summary", extracted)

    def test_performance_report_exports_csv_and_pdf(self):
        report = {
            "report_title": "Fast Bowler Bowling Performance Report",
            "filters": {"mode": "bowling", "style": "Fast bowler", "use_venue_filter": True, "venue_name": "Holkar Stadium"},
            "summary": ["1 players matched all bowling styles."],
            "rows": [
                {
                    "player_name": "Fast Bowler",
                    "team_name": "Alpha",
                    "bowling_style_code": "RAMF",
                    "matches_played": 2,
                    "overs": 7.0,
                    "maidens": 1,
                    "runs_conceded": 46,
                    "wickets": 3,
                    "dot_balls": 19,
                    "economy": 6.57,
                    "runs": 0,
                    "balls": 0,
                    "fours": 0,
                    "sixes": 0,
                    "strike_rate": 0.0,
                    "best_match": {
                        "match_number": 15,
                        "opponent_team_name": "Beta",
                        "venue_name": "Holkar Stadium",
                    },
                    "best_score": 44.0,
                }
            ],
        }

        csv_response = report_export_service.export_performance_report(report, "csv")
        self.assertEqual(csv_response.media_type, "text/csv")
        csv_text = csv_response.body.decode("utf-8")
        self.assertIn("Fast Bowler", csv_text)
        self.assertIn("RAMF", csv_text)
        self.assertIn("Holkar Stadium", csv_text)
        self.assertIn("Team Totals", csv_text)
        self.assertIn("Overall Total", csv_text)
        self.assertNotIn(",4s,", csv_text)
        self.assertNotIn(",6s,", csv_text)

        pdf_response = report_export_service.export_performance_report(report, "pdf")
        self.assertEqual(pdf_response.media_type, "application/pdf")
        pdf_doc = fitz.open(stream=pdf_response.body, filetype="pdf")
        extracted = "\n".join(page.get_text() for page in pdf_doc)
        self.assertIn("Fast Bowler Bowling Performance Report", extracted)
        self.assertIn("Fast Bowler", extracted)
        self.assertIn("Holkar Stadium", extracted)
        self.assertIn("Team Totals", extracted)
        self.assertIn("Overall Total", extracted)


if __name__ == "__main__":
    unittest.main()
