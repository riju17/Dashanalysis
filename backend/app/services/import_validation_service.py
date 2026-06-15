from __future__ import annotations

from typing import Any
from typing import Optional

from app.utils.cricket_calculations import safe_divide


def _normalize_name(value: str) -> str:
    return " ".join((value or "").strip().lower().split())


def _find_team_by_name(teams: list[dict[str, Any]], team_name: str) -> Optional[dict[str, Any]]:
    normalized = _normalize_name(team_name)
    for team in teams:
        if _normalize_name(team.get("team_name", "")) == normalized:
            return team
    return None


def _find_player_by_name(players: list[dict[str, Any]], player_name: str) -> Optional[dict[str, Any]]:
    normalized = _normalize_name(player_name)
    for player in players:
        if _normalize_name(player.get("player_name", "")) == normalized:
            return player
    return None


class ImportValidationService:
    def validate(self, parsed_json: dict[str, Any], teams: list[dict[str, Any]], players: list[dict[str, Any]]) -> list[str]:
        warnings: list[str] = []
        match_details = parsed_json.get("match_details", {})
        innings = parsed_json.get("innings", [])

        if len(innings) < 2:
            warnings.append("Only one innings was detected; verify that both scorecards were uploaded.")

        if not match_details.get("venue"):
            warnings.append("Venue is missing from the import.")

        toss_winner = match_details.get("toss_winner", "")
        if toss_winner and not _find_team_by_name(teams, toss_winner):
            warnings.append(f'Toss winner "{toss_winner}" was not found in the teams table.')

        for innings_row in innings:
            team_name = innings_row.get("team_name", "")
            team = _find_team_by_name(teams, team_name)
            if not team:
                warnings.append(f'Team "{team_name}" was not found in the teams table.')

            batting_rows = innings_row.get("batting", [])
            bowling_rows = innings_row.get("bowling", [])
            extras = int(innings_row.get("extras", 0) or 0)
            score = int(innings_row.get("score", 0) or 0)
            wickets = int(innings_row.get("wickets", 0) or 0)
            overs = float(innings_row.get("overs", 0) or 0)

            batting_total = sum(int(row.get("runs", 0) or 0) for row in batting_rows)
            dismissed_batters = sum(1 for row in batting_rows if not row.get("is_not_out", False) and (row.get("dismissal") or "").strip())
            bowling_total = sum(int(row.get("runs_conceded", 0) or 0) for row in bowling_rows)

            if batting_total + extras != score:
                warnings.append(
                    f'{team_name or "An innings"} has batter runs ({batting_total}) + extras ({extras}) that do not equal the team score ({score}).'
                )

            if wickets != dismissed_batters:
                warnings.append(
                    f'{team_name or "An innings"} wicket count ({wickets}) does not match dismissed batters ({dismissed_batters}).'
                )

            if overs < 0 or not self._overs_valid(overs):
                warnings.append(f'{team_name or "An innings"} has an invalid overs value: {overs}.')

            for row in batting_rows:
                balls = int(row.get("balls", 0) or 0)
                runs = int(row.get("runs", 0) or 0)
                strike_rate = float(row.get("strike_rate", 0) or 0)
                expected_sr = round(safe_divide(runs * 100.0, balls, 0.0), 2) if balls else 0.0
                if balls and abs(expected_sr - strike_rate) > 0.5:
                    warnings.append(
                        f'Batting strike rate mismatch for {row.get("player_name", "")}: expected {expected_sr}, got {strike_rate}.'
                    )
                player = _find_player_by_name(players, row.get("player_name", ""))
                if not player and row.get("player_name"):
                    warnings.append(f'Player "{row.get("player_name")}" was not found in the players table.')

            for row in bowling_rows:
                bowling_overs = float(row.get("overs", 0) or 0)
                runs_conceded = int(row.get("runs_conceded", 0) or 0)
                economy = float(row.get("economy", 0) or 0)
                expected_economy = round(safe_divide(runs_conceded, bowling_overs, 0.0), 2) if bowling_overs else 0.0
                if bowling_overs and abs(expected_economy - economy) > 0.25:
                    warnings.append(
                        f'Bowling economy mismatch for {row.get("player_name", "")}: expected {expected_economy}, got {economy}.'
                    )
                player = _find_player_by_name(players, row.get("player_name", ""))
                if not player and row.get("player_name"):
                    warnings.append(f'Player "{row.get("player_name")}" was not found in the players table.')

            if bowling_total and abs(bowling_total - score) > max(6, score * 0.05):
                warnings.append(
                    f'{team_name or "An innings"} bowling runs ({bowling_total}) do not closely match the innings score ({score}).'
                )

            if batting_rows and not any(row.get("is_wicketkeeper") for row in batting_rows):
                warnings.append(f'{team_name or "An innings"} has no wicketkeeper flagged in the batting card.')

        return warnings

    def _overs_valid(self, overs: float) -> bool:
        whole = int(overs)
        balls = round((overs - whole) * 10)
        return 0 <= balls <= 5

    def merge_warnings(self, parsed_json: dict[str, Any], warnings: list[str]) -> dict[str, Any]:
        merged = dict(parsed_json)
        current = list(merged.get("parser_warnings", []))
        for warning in warnings:
            if warning not in current:
                current.append(warning)
        merged["parser_warnings"] = current
        return merged


import_validation_service = ImportValidationService()
