from __future__ import annotations

from datetime import datetime
from pathlib import Path
from typing import Any
from typing import Optional
from uuid import UUID

from fastapi import HTTPException, UploadFile, status

from app.data.store import store
from app.services.import_validation_service import import_validation_service
from app.services.ocr_service import ocr_service
from app.services.report_service import report_service
from app.services.scorecard_parser import parse_scorecard_text
from app.services.scorecard_scraper import scorecard_scraper
from app.utils.cricket_calculations import derive_match_result


TEAM_THEME_FALLBACKS = [
    ("#7C3AED", "#A855F7", "#22D3EE"),
    ("#EF4444", "#F97316", "#FDE047"),
    ("#0EA5E9", "#14B8A6", "#22C55E"),
    ("#1D4ED8", "#6366F1", "#38BDF8"),
    ("#8B5CF6", "#C084FC", "#F472B6"),
    ("#F43F5E", "#FB7185", "#F97316"),
    ("#10B981", "#34D399", "#F59E0B"),
    ("#0284C7", "#38BDF8", "#60A5FA"),
    ("#7C2D12", "#EA580C", "#F59E0B"),
    ("#0F172A", "#2563EB", "#22D3EE"),
]


def _normalize_name(value: str) -> str:
    return " ".join((value or "").strip().lower().split())


class ImportService:
    async def import_from_screenshots(self, files: list[UploadFile]) -> dict[str, Any]:
        if not files:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="At least one screenshot is required.")
        text_chunks: list[str] = []
        warnings: list[str] = []
        confidence_scores: list[float] = []
        for file in files:
            content = await file.read()
            result = ocr_service.extract_text_from_image_bytes(content, filename=file.filename)
            text_chunks.append(f"--- {file.filename or 'screenshot'} ---\n{result.text}")
            warnings.extend(result.warnings)
            confidence_scores.append(result.confidence)
        raw_text = "\n\n".join(text_chunks).strip()
        return self._create_import_session("screenshot", raw_text, warnings, confidence_scores)

    async def import_from_pdf(self, file: UploadFile) -> dict[str, Any]:
        content = await file.read()
        result = ocr_service.extract_text_from_pdf_bytes(content, filename=file.filename)
        raw_text = result.text.strip()
        warnings = list(result.warnings)
        return self._create_import_session("pdf", raw_text, warnings, [result.confidence])

    def import_from_url(self, url: str) -> dict[str, Any]:
        scrape_result = scorecard_scraper.scrape(url)
        return self._create_import_session("url", scrape_result.raw_text, scrape_result.warnings, [0.9 if scrape_result.raw_text else 0.0])

    def get_import(self, import_id: str):
        record = store.get("match_imports", import_id)
        if not record:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Import session not found")
        return record

    def confirm_import(self, import_id: str, parsed_json: dict[str, Any]) -> dict[str, Any]:
        record = self.get_import(import_id)
        teams = store.list("teams")
        players = store.list("players")

        parsed_json = self._normalize_parsed_json(parsed_json)
        warnings = import_validation_service.validate(parsed_json, teams, players)
        parsed_json = import_validation_service.merge_warnings(parsed_json, warnings)

        if not parsed_json.get("innings") or len(parsed_json.get("innings", [])) < 1:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="At least one innings is required to save the match.")

        match_details = parsed_json["match_details"]
        innings = parsed_json["innings"]
        first_innings = innings[0]
        second_innings = innings[1] if len(innings) > 1 else {}

        team_a = self._create_or_find_team(first_innings.get("team_name", "Team A"))
        team_b_name = second_innings.get("team_name") or self._infer_opponent_team_name(team_a["id"], teams)
        team_b = self._create_or_find_team(team_b_name or "Team B")

        venue = self._create_or_find_venue(match_details.get("venue", ""), match_details.get("city", ""))
        match_number = match_details.get("match_number") or self._next_match_number()
        winner_name = parsed_json.get("result", {}).get("winner") or ""
        loser_name = parsed_json.get("result", {}).get("loser") or ""
        winner_team = self._create_or_find_team(winner_name) if winner_name else None
        loser_team = self._create_or_find_team(loser_name) if loser_name else None

        toss_winner = self._create_or_find_team(match_details.get("toss_winner", "")) if match_details.get("toss_winner") else None
        player_of_match = self._create_or_find_player(
            match_details.get("player_of_match", ""),
            winner_team["id"] if winner_team else team_a["id"],
        ) if match_details.get("player_of_match") else None

        result_payload = self._result_payload(first_innings, second_innings, parsed_json.get("result", {}), team_a["id"], team_b["id"])
        match_payload = {
            "match_date": self._parse_date(match_details.get("match_date")),
            "season": "2026",
            "tournament": "MPt20",
            "match_number": match_number,
            "team_a_id": team_a["id"],
            "team_b_id": team_b["id"],
            "venue_id": venue["id"],
            "toss_winner_id": toss_winner["id"] if toss_winner else None,
            "toss_decision": match_details.get("toss_decision") or None,
            "bat_first_team_id": team_a["id"],
            "bowl_first_team_id": team_b["id"],
            "first_innings_score": first_innings.get("score", 0),
            "first_innings_wickets": first_innings.get("wickets", 0),
            "first_innings_overs": first_innings.get("overs", 0.0),
            "second_innings_score": second_innings.get("score", 0),
            "second_innings_wickets": second_innings.get("wickets", 0),
            "second_innings_overs": second_innings.get("overs", 0.0),
            "winner_id": winner_team["id"] if winner_team else result_payload.get("winner_id"),
            "loser_id": loser_team["id"] if loser_team else result_payload.get("loser_id"),
            "result_type": result_payload.get("result_type"),
            "margin_runs": result_payload.get("margin_runs"),
            "margin_wickets": result_payload.get("margin_wickets"),
            "player_of_match_id": player_of_match["id"] if player_of_match else None,
            "notes": self._compose_notes(match_details, parsed_json),
        }

        if match_details.get("match_time"):
            match_payload["notes"] = f"{match_payload['notes']} | Match time: {match_details['match_time']}" if match_payload["notes"] else f"Match time: {match_details['match_time']}"

        match = store.insert("matches", match_payload)
        stats_rows = self._build_player_stats(match["id"], parsed_json, team_a, team_b)
        if stats_rows:
            store.append_player_stats(match["id"], stats_rows)

        import_update = store.update(
            "match_imports",
            record["id"],
            {
                "import_type": record.get("import_type"),
                "raw_text": record.get("raw_text", ""),
                "parsed_json": parsed_json,
                "confidence_score": parsed_json.get("confidence_score", record.get("confidence_score", 0.0)),
                "status": "confirmed",
            },
        )

        report = report_service.generate_match_report(match["id"])
        return {
            "import_record": import_update or record,
            "match": match,
            "report": report,
            "warnings": parsed_json.get("parser_warnings", []),
        }

    def _create_import_session(self, import_type: str, raw_text: str, warnings: list[str], confidence_scores: list[float]) -> dict[str, Any]:
        parsed_json = parse_scorecard_text(raw_text or "")
        parsed_json = self._normalize_parsed_json(parsed_json)

        teams = store.list("teams")
        players = store.list("players")
        validation_warnings = import_validation_service.validate(parsed_json, teams, players)
        parsed_json = import_validation_service.merge_warnings(parsed_json, warnings + validation_warnings)

        if not parsed_json["match_details"].get("match_number"):
            parsed_json["match_details"]["match_number"] = self._next_match_number()

        confidence_values = [score for score in confidence_scores if isinstance(score, (int, float))]
        if confidence_values:
            parsed_json["confidence_score"] = round((parsed_json.get("confidence_score", 0.0) + sum(confidence_values) / len(confidence_values)) / 2, 3)

        record = store.insert(
            "match_imports",
            {
                "import_type": import_type,
                "raw_text": raw_text,
                "parsed_json": parsed_json,
                "confidence_score": parsed_json.get("confidence_score", 0.0),
                "status": "review_pending",
            },
        )
        return record

    def _normalize_parsed_json(self, parsed_json: dict[str, Any]) -> dict[str, Any]:
        match_details = dict(parsed_json.get("match_details", {}))
        innings: list[dict[str, Any]] = []
        for innings_row in parsed_json.get("innings", []):
            batting = [dict(row) for row in innings_row.get("batting", [])]
            bowling = [dict(row) for row in innings_row.get("bowling", [])]
            innings.append(
                {
                    "team_name": innings_row.get("team_name", ""),
                    "score": int(innings_row.get("score", 0) or 0),
                    "wickets": int(innings_row.get("wickets", 0) or 0),
                    "overs": float(innings_row.get("overs", 0) or 0),
                    "run_rate": float(innings_row.get("run_rate", 0) or 0),
                    "extras": int(innings_row.get("extras", 0) or 0),
                    "extras_breakdown": dict(innings_row.get("extras_breakdown", {}) or {}),
                    "batting": batting,
                    "bowling": bowling,
                    "fall_of_wickets": [dict(row) for row in innings_row.get("fall_of_wickets", [])],
                    "yet_to_bat": list(innings_row.get("yet_to_bat", []) or []),
                }
            )
        return {
            "match_details": {
                "venue": match_details.get("venue", ""),
                "city": match_details.get("city", ""),
                "match_date": match_details.get("match_date", ""),
                "match_time": match_details.get("match_time", ""),
                "toss_winner": match_details.get("toss_winner", ""),
                "toss_decision": match_details.get("toss_decision", ""),
                "player_of_match": match_details.get("player_of_match", ""),
                "umpires": list(match_details.get("umpires", []) or []),
                "match_number": match_details.get("match_number"),
            },
            "innings": innings[:2],
            "result": {
                "winner": parsed_json.get("result", {}).get("winner", ""),
                "loser": parsed_json.get("result", {}).get("loser", ""),
                "result_type": parsed_json.get("result", {}).get("result_type", ""),
                "margin_runs": int(parsed_json.get("result", {}).get("margin_runs", 0) or 0),
                "margin_wickets": int(parsed_json.get("result", {}).get("margin_wickets", 0) or 0),
            },
            "parser_warnings": list(parsed_json.get("parser_warnings", []) or []),
            "confidence_score": float(parsed_json.get("confidence_score", 0.0) or 0.0),
        }

    def _build_player_stats(self, match_id: str, parsed_json: dict[str, Any], team_a: dict[str, Any], team_b: dict[str, Any]) -> list[dict[str, Any]]:
        innings = parsed_json.get("innings", [])
        if not innings:
            return []

        team_lookup = {team_a["id"]: team_a, team_b["id"]: team_b}
        team_name_to_id = {
            _normalize_name(team_a["team_name"]): team_a["id"],
            _normalize_name(team_b["team_name"]): team_b["id"],
        }
        combined_rows: dict[tuple[str, str], dict[str, Any]] = {}

        for innings_index, innings_row in enumerate(innings[:2]):
            batting_team_id = team_name_to_id.get(_normalize_name(innings_row.get("team_name", "")), team_a["id"])
            bowling_team_id = team_b["id"] if batting_team_id == team_a["id"] else team_a["id"]
            batting_team = team_lookup[batting_team_id]
            bowling_team = team_lookup[bowling_team_id]

            for batting_index, batting_row in enumerate(innings_row.get("batting", []), start=1):
                player = self._create_or_find_player(batting_row.get("player_name", ""), batting_team_id)
                key = (batting_team_id, _normalize_name(batting_row.get("player_name", "")))
                row = combined_rows.setdefault(
                    key,
                    {
                        "match_id": match_id,
                        "player_id": player["id"],
                        "team_id": batting_team_id,
                        "batting_position": batting_index,
                        "runs": 0,
                        "balls": 0,
                        "fours": 0,
                        "sixes": 0,
                        "strike_rate": 0.0,
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
                row.update(
                    {
                        "batting_position": batting_index,
                        "runs": int(batting_row.get("runs", 0) or 0),
                        "balls": int(batting_row.get("balls", 0) or 0),
                        "fours": int(batting_row.get("fours", 0) or 0),
                        "sixes": int(batting_row.get("sixes", 0) or 0),
                        "strike_rate": float(batting_row.get("strike_rate", 0) or 0),
                    }
                )

            for bowling_row in innings_row.get("bowling", []):
                player = self._create_or_find_player(bowling_row.get("player_name", ""), bowling_team_id)
                key = (bowling_team_id, _normalize_name(bowling_row.get("player_name", "")))
                row = combined_rows.setdefault(
                    key,
                    {
                        "match_id": match_id,
                        "player_id": player["id"],
                        "team_id": bowling_team_id,
                        "batting_position": None,
                        "runs": 0,
                        "balls": 0,
                        "fours": 0,
                        "sixes": 0,
                        "strike_rate": 0.0,
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
                row.update(
                    {
                        "overs": float(bowling_row.get("overs", 0) or 0),
                        "maidens": int(bowling_row.get("maidens", 0) or 0),
                        "runs_conceded": int(bowling_row.get("runs_conceded", 0) or 0),
                        "wickets": int(bowling_row.get("wickets", 0) or 0),
                        "dot_balls": int(bowling_row.get("dots", 0) or 0),
                        "economy": float(bowling_row.get("economy", 0) or 0),
                    }
                )

        return list(combined_rows.values())

    def _create_or_find_team(self, team_name: str) -> dict[str, Any]:
        normalized = _normalize_name(team_name)
        existing = next((team for team in store.list("teams") if _normalize_name(team.get("team_name", "")) == normalized), None)
        if existing:
            return existing
        index = len(store.list("teams")) % len(TEAM_THEME_FALLBACKS)
        primary, secondary, accent = TEAM_THEME_FALLBACKS[index]
        return store.insert(
            "teams",
            {
                "team_name": team_name,
                "short_name": "".join(part[0] for part in team_name.split()[:3]).upper(),
                "primary_color": primary,
                "secondary_color": secondary,
                "accent_color": accent,
                "logo_url": None,
            },
        )

    def _create_or_find_venue(self, venue_name: str, city: str = "") -> dict[str, Any]:
        normalized = _normalize_name(venue_name)
        existing = next((venue for venue in store.list("venues") if _normalize_name(venue.get("venue_name", "")) == normalized), None)
        if existing:
            return existing
        return store.insert(
            "venues",
            {
                "venue_name": venue_name or "Unknown Venue",
                "city": city or None,
                "country": "India" if city else None,
            },
        )

    def _create_or_find_player(self, player_name: str, team_id: str) -> dict[str, Any]:
        normalized = _normalize_name(player_name)
        existing = next(
            (
                player
                for player in store.list("players")
                if _normalize_name(player.get("player_name", "")) == normalized and str(player.get("team_id")) == str(team_id)
            ),
            None,
        )
        if existing:
            return existing

        role = "All-rounder"
        team_players = store.filter("players", team_id=team_id)
        if not team_players:
            role = "Batter"
        return store.insert(
            "players",
            {
                "player_name": player_name,
                "team_id": team_id,
                "role": role,
                "batting_style": "Right-hand bat",
                "bowling_style": "Right-arm medium",
            },
        )

    def _result_payload(self, first_innings: dict[str, Any], second_innings: dict[str, Any], result: dict[str, Any], team_a_id: str, team_b_id: str):
        if first_innings.get("score", 0) > second_innings.get("score", 0):
            return {
                "winner_id": team_a_id,
                "loser_id": team_b_id,
                "result_type": "runs",
                "margin_runs": first_innings.get("score", 0) - second_innings.get("score", 0),
                "margin_wickets": None,
            }
        if second_innings.get("score", 0) > first_innings.get("score", 0):
            wickets_margin = max(1, min(10, 10 - int(second_innings.get("wickets", 0) or 0)))
            return {
                "winner_id": team_b_id,
                "loser_id": team_a_id,
                "result_type": "wickets",
                "margin_runs": None,
                "margin_wickets": wickets_margin,
            }
        return {
            "winner_id": team_a_id,
            "loser_id": team_b_id,
            "result_type": result.get("result_type") or "runs",
            "margin_runs": result.get("margin_runs"),
            "margin_wickets": result.get("margin_wickets"),
        }

    def _compose_notes(self, match_details: dict[str, Any], parsed_json: dict[str, Any]) -> str:
        notes = [
            f"Auto-imported from {match_details.get('venue', 'scorecard')}",
            f"Confidence: {parsed_json.get('confidence_score', 0.0):.2f}",
        ]
        if match_details.get("toss_winner"):
            notes.append(f"Toss: {match_details['toss_winner']} chose {match_details.get('toss_decision', 'unknown')}")
        if parsed_json.get("parser_warnings"):
            notes.append(f"Warnings: {len(parsed_json['parser_warnings'])}")
        return " | ".join(notes)

    def _infer_opponent_team_name(self, team_id: str, teams: list[dict[str, Any]]) -> str:
        if len(teams) >= 2:
            for team in teams:
                if str(team.get("id")) != str(team_id):
                    return team.get("team_name", "")
        return "Team B"

    def _parse_date(self, value: Optional[str]) -> Optional[str]:
        if not value:
            return None
        for fmt in ("%Y-%m-%d", "%d %B %Y", "%B %d, %Y"):
            try:
                return datetime.strptime(value, fmt).date().isoformat()
            except Exception:
                continue
        return value

    def _next_match_number(self) -> int:
        matches = store.list("matches")
        if not matches:
            return 1
        numbers = [int(match.get("match_number", 0) or 0) for match in matches]
        return max(numbers) + 1 if numbers else 1


import_service = ImportService()
