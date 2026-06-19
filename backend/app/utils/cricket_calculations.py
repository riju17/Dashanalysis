from __future__ import annotations

from math import isnan
from typing import Dict, Optional, Union


def safe_divide(numerator: float, denominator: float, default: float = 0.0) -> float:
    if denominator in (0, 0.0, None):
        return default
    result = numerator / denominator
    if result != result or result == float("inf") or result == float("-inf"):
        return default
    return result


def clamp(value: float, minimum: float = 0.0, maximum: float = 100.0) -> float:
    return max(minimum, min(maximum, value))


def percentage(part: float, whole: float) -> float:
    return safe_divide(part * 100.0, whole, 0.0)


def batting_impact(runs: float, strike_rate: float, fours: int, sixes: int) -> float:
    return runs + (strike_rate * 0.2) + (fours * 2) + (sixes * 3)


def bowling_impact(wickets: int, dot_balls: int, economy: float) -> float:
    return (wickets * 25) + (dot_balls * 1.5) - (economy * 3)


def all_rounder_index(batting_score: float, bowling_score: float) -> float:
    return batting_score + bowling_score


def team_strength_score(
    win_percentage: float,
    recent_form_index: float,
    batting_strength: float,
    bowling_strength: float,
) -> float:
    return (
        win_percentage * 0.35
        + recent_form_index * 0.25
        + batting_strength * 0.20
        + bowling_strength * 0.20
    )


def parse_overs_to_balls(overs: float) -> int:
    whole_overs = int(overs or 0)
    fractional = round(((overs or 0) - whole_overs) * 10)
    if fractional < 0:
        fractional = 0
    carry, balls = divmod(fractional, 6)
    return ((whole_overs + carry) * 6) + balls


def balls_to_overs(balls: int) -> float:
    whole_overs = balls // 6
    remaining_balls = balls % 6
    return float(f"{whole_overs}.{remaining_balls}")


def derive_match_result(
    first_innings_score: Optional[int],
    second_innings_score: Optional[int],
    first_innings_wickets: Optional[int] = None,
    second_innings_wickets: Optional[int] = None,
    bat_first_team_id: Optional[str] = None,
    bowl_first_team_id: Optional[str] = None,
    current_result_type: Optional[str] = None,
    current_margin_runs: Optional[int] = None,
    current_margin_wickets: Optional[int] = None,
) -> Dict[str, Union[int, str, None]]:
    if first_innings_score is None or second_innings_score is None:
        return {
            "result_type": current_result_type,
            "margin_runs": current_margin_runs,
            "margin_wickets": current_margin_wickets,
        }

    if first_innings_score > second_innings_score:
        return {
            "result_type": "runs",
            "margin_runs": first_innings_score - second_innings_score,
            "margin_wickets": None,
            "winner_id": bat_first_team_id,
            "loser_id": bowl_first_team_id,
        }

    if second_innings_score > first_innings_score:
        wickets_lost = int(second_innings_wickets or 0)
        wickets_margin = max(1, min(10, 10 - wickets_lost))
        return {
            "result_type": "wickets",
            "margin_runs": None,
            "margin_wickets": wickets_margin,
            "winner_id": bowl_first_team_id,
            "loser_id": bat_first_team_id,
        }

    return {
        "result_type": current_result_type or "runs",
        "margin_runs": 0,
        "margin_wickets": 0,
    }
