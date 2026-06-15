from __future__ import annotations

import re
from typing import Any
from typing import Optional


TEAM_SCORE_RE = re.compile(
    r"^(?P<team>.+?)\s+(?P<score>\d+)\s*/\s*(?P<wickets>\d+)\s*\((?P<overs>\d+(?:\.\d+)?)\s*ov(?:ers)?\b",
    re.IGNORECASE,
)
SCORE_ONLY_RE = re.compile(r"^(?P<score>\d+)\s*/\s*(?P<wickets>\d+)\s*\((?P<overs>\d+(?:\.\d+)?)\s*ov\b", re.IGNORECASE)
BAT_ROW_RE = re.compile(
    r"^(?P<name>.+?)\s+(?P<dismissal>.+?)\s+(?P<runs>\d+)\s+(?P<balls>\d+)\s+(?P<dots>\d+)\s+(?P<fours>\d+)\s+(?P<sixes>\d+)\s+(?P<strike_rate>\d+(?:\.\d+)?)$",
    re.IGNORECASE,
)
BOWL_ROW_RE = re.compile(
    r"^(?P<name>.+?)\s+(?P<overs>\d+(?:\.\d+)?)\s+(?P<maidens>\d+)\s+(?P<runs_conceded>\d+)\s+(?P<wickets>\d+)\s+(?P<dots>\d+)\s+(?P<wides>\d+)\s+(?P<no_balls>\d+)\s+(?P<economy>\d+(?:\.\d+)?)$",
    re.IGNORECASE,
)
FOW_ROW_RE = re.compile(
    r"(?P<score>\d+)\s*-\s*(?P<wicket_number>\d+)\s*\((?P<player_out>[^,]+),\s*(?P<over>\d+(?:\.\d+)?)\s*ov\)",
    re.IGNORECASE,
)
MATCH_NUMBER_RE = re.compile(r"match\s*(?:no\.?|number|#)\s*(?P<number>\d+)", re.IGNORECASE)
TOSS_RE = re.compile(r"(?P<winner>.+?)\s+won the toss and (?:chose|elected) to (?P<decision>bat|bowl)", re.IGNORECASE)
RESULT_RUNS_RE = re.compile(r"(?P<winner>.+?) won by (?P<margin>\d+) runs?", re.IGNORECASE)
RESULT_WICKETS_RE = re.compile(r"(?P<winner>.+?) won by (?P<margin>\d+) wickets?", re.IGNORECASE)
PLAYER_OF_MATCH_RE = re.compile(r"(?:player of the match|player of match|mom)[:\s-]+(?P<name>.+)", re.IGNORECASE)
DATE_RE = re.compile(r"\b(?P<date>\d{1,2}\s+[A-Za-z]+\s+\d{4}|[A-Za-z]+\s+\d{1,2},\s+\d{4}|\d{4}-\d{2}-\d{2})\b")
TIME_RE = re.compile(r"\b(?P<time>\d{1,2}:\d{2}(?::\d{2})?(?:\s*[AP]M)?)\b", re.IGNORECASE)


def _clean_name(value: str) -> str:
    value = re.sub(r"\s+", " ", value).strip()
    value = re.sub(r"\((?:c|wk)\)", "", value, flags=re.IGNORECASE)
    return re.sub(r"\s+", " ", value).strip(" -")


def _safe_int(value: Any, default: int = 0) -> int:
    try:
        return int(float(value)) if value is not None else default
    except Exception:
        return default


def _safe_float(value: Any, default: float = 0.0) -> float:
    try:
        return float(value) if value is not None else default
    except Exception:
        return default


def _normalize_lines(raw_text: str) -> list[str]:
    lines = [re.sub(r"\s+", " ", line).strip() for line in raw_text.splitlines()]
    return [line for line in lines if line]


def _extract_labeled_value(lines: list[str], label: str) -> str:
    label_lower = label.lower()
    for index, line in enumerate(lines):
        normalized = line.lower()
        if normalized.startswith(f"{label_lower}:"):
            return line.split(":", 1)[1].strip()
        if normalized == label_lower or normalized == label_lower.replace(" ", ""):
            for candidate in lines[index + 1 : index + 4]:
                candidate_lower = candidate.lower()
                if candidate and not candidate_lower.startswith(("batter", "bowler", "extras", "total", "fall of wickets", "yet to bat")):
                    return candidate
    return ""


def _extract_list_after_label(lines: list[str], label: str) -> list[str]:
    value = _extract_labeled_value(lines, label)
    if not value:
        for line in lines:
            if line.lower().startswith(label.lower()):
                value = line.split(":", 1)[-1].strip() if ":" in line else ""
                break
    if not value:
        return []
    value = value.replace("•", ",")
    return [item.strip(" ,") for item in re.split(r",|/|\|", value) if item.strip(" ,")]


def _parse_extras(line: str) -> tuple[int, dict[str, int]]:
    match = re.search(r"extras\s+(?P<extras>\d+)(?:\s*\((?P<breakdown>.+)\))?", line, re.IGNORECASE)
    if not match:
        return 0, {}
    extras = _safe_int(match.group("extras"))
    breakdown: dict[str, int] = {}
    details = match.group("breakdown") or ""
    for part in details.split(","):
        if not part.strip():
            continue
        if " " not in part:
            continue
        key, raw_value = part.strip().split(" ", 1)
        breakdown[key.strip().lower()] = _safe_int(raw_value)
    return extras, breakdown


def _parse_batting_row(line: str) -> Optional[dict[str, Any]]:
    match = BAT_ROW_RE.match(line)
    if not match:
        return None
    name = match.group("name").strip()
    return {
        "player_name": _clean_name(name),
        "dismissal": match.group("dismissal").strip(),
        "runs": _safe_int(match.group("runs")),
        "balls": _safe_int(match.group("balls")),
        "dots": _safe_int(match.group("dots")),
        "fours": _safe_int(match.group("fours")),
        "sixes": _safe_int(match.group("sixes")),
        "strike_rate": round(_safe_float(match.group("strike_rate")), 2),
        "is_not_out": "not out" in match.group("dismissal").lower(),
        "is_captain": "(c)" in name.lower(),
        "is_wicketkeeper": "(wk)" in name.lower(),
    }


def _parse_bowling_row(line: str) -> Optional[dict[str, Any]]:
    match = BOWL_ROW_RE.match(line)
    if not match:
        return None
    return {
        "player_name": _clean_name(match.group("name")),
        "overs": round(_safe_float(match.group("overs")), 1),
        "maidens": _safe_int(match.group("maidens")),
        "runs_conceded": _safe_int(match.group("runs_conceded")),
        "wickets": _safe_int(match.group("wickets")),
        "dots": _safe_int(match.group("dots")),
        "wides": _safe_int(match.group("wides")),
        "no_balls": _safe_int(match.group("no_balls")),
        "economy": round(_safe_float(match.group("economy")), 2),
    }


def _parse_fow_entries(text: str) -> list[dict[str, Any]]:
    rows = []
    for match in FOW_ROW_RE.finditer(text):
        rows.append(
            {
                "score": _safe_int(match.group("score")),
                "wicket_number": _safe_int(match.group("wicket_number")),
                "player_out": match.group("player_out").strip(),
                "over": round(_safe_float(match.group("over")), 1),
            }
        )
    return rows


def _parse_score_header(line: str) -> Optional[dict[str, Any]]:
    match = TEAM_SCORE_RE.match(line)
    if match:
        return {
            "team_name": _clean_name(match.group("team")),
            "score": _safe_int(match.group("score")),
            "wickets": _safe_int(match.group("wickets")),
            "overs": round(_safe_float(match.group("overs")), 1),
        }
    match = SCORE_ONLY_RE.match(line)
    if match:
        return {
            "team_name": "",
            "score": _safe_int(match.group("score")),
            "wickets": _safe_int(match.group("wickets")),
            "overs": round(_safe_float(match.group("overs")), 1),
        }
    return None


def _find_innings_headers(lines: list[str]) -> list[dict[str, Any]]:
    headers: list[dict[str, Any]] = []
    for index, line in enumerate(lines):
        parsed = _parse_score_header(line)
        if parsed:
            parsed["line_index"] = index
            headers.append(parsed)
            continue
        if line.isupper() and index + 1 < len(lines):
            next_line = lines[index + 1]
            parsed_next = _parse_score_header(next_line)
            if parsed_next and not parsed_next["team_name"]:
                parsed_next["team_name"] = _clean_name(line)
                parsed_next["line_index"] = index
                headers.append(parsed_next)
    unique_headers: list[dict[str, Any]] = []
    seen_indexes: set[int] = set()
    for header in headers:
        index = int(header["line_index"])
        if index in seen_indexes:
            continue
        seen_indexes.add(index)
        unique_headers.append(header)
    return unique_headers


def _parse_innings_block(
    lines: list[str],
    header: dict[str, Any],
    next_header_index: Optional[int] = None,
) -> dict[str, Any]:
    start_index = int(header["line_index"])
    block_lines = lines[start_index + 1 : next_header_index] if next_header_index is not None else lines[start_index + 1 :]
    innings = {
        "team_name": header["team_name"],
        "score": header["score"],
        "wickets": header["wickets"],
        "overs": header["overs"],
        "run_rate": round(_safe_float(header["score"]) / header["overs"], 2) if header["overs"] else 0.0,
        "extras": 0,
        "extras_breakdown": {},
        "batting": [],
        "bowling": [],
        "fall_of_wickets": [],
        "yet_to_bat": [],
    }

    section = "batting"
    batting_order = 1
    for line in block_lines:
        upper = line.upper()
        if "BATTER" == upper or upper.startswith("BATTER "):
            section = "batting"
            continue
        if "BOWLER" == upper or upper.startswith("BOWLER "):
            section = "bowling"
            continue
        if "FALL OF WICKETS" in upper:
            section = "fow"
            innings["fall_of_wickets"].extend(_parse_fow_entries(line))
            continue
        if upper.startswith("YET TO BAT") or upper.startswith("DID NOT BAT"):
            section = "yet_to_bat"
            values = line.split(":", 1)[1].strip() if ":" in line else ""
            if values:
                innings["yet_to_bat"].extend([item.strip() for item in values.split(",") if item.strip()])
            continue
        if upper.startswith("EXTRAS"):
            innings["extras"], innings["extras_breakdown"] = _parse_extras(line)
            continue
        if upper.startswith("TOTAL"):
            score_match = re.search(r"TOTAL\s+(?P<score>\d+)", line, re.IGNORECASE)
            wickets_match = re.search(r"\((?P<wickets>\d+)\s*wkt", line, re.IGNORECASE)
            overs_match = re.search(r"(?P<overs>\d+(?:\.\d+)?)\s*ov", line, re.IGNORECASE)
            if score_match:
                innings["score"] = _safe_int(score_match.group("score"))
            if wickets_match:
                innings["wickets"] = _safe_int(wickets_match.group("wickets"))
            if overs_match:
                innings["overs"] = round(_safe_float(overs_match.group("overs")), 1)
            innings["run_rate"] = round(_safe_float(innings["score"]) / innings["overs"], 2) if innings["overs"] else innings["run_rate"]
            continue

        batting_row = _parse_batting_row(line)
        if section == "batting" and batting_row:
            batting_row["batting_position"] = batting_order
            batting_order += 1
            innings["batting"].append(batting_row)
            continue

        bowling_row = _parse_bowling_row(line)
        if section == "bowling" and bowling_row:
            innings["bowling"].append(bowling_row)
            continue

        if section == "fow":
            innings["fall_of_wickets"].extend(_parse_fow_entries(line))
            continue

        if section == "yet_to_bat" and line and not line.isupper():
            innings["yet_to_bat"].extend([item.strip() for item in line.split(",") if item.strip()])

    innings["yet_to_bat"] = [item for item in innings["yet_to_bat"] if item]
    return innings


def parse_scorecard_text(raw_text: str) -> dict[str, Any]:
    lines = _normalize_lines(raw_text)
    match_details = {
        "venue": _extract_labeled_value(lines, "venue"),
        "city": "",
        "match_date": _extract_labeled_value(lines, "date"),
        "match_time": _extract_labeled_value(lines, "time"),
        "toss_winner": "",
        "toss_decision": "",
        "player_of_match": "",
        "umpires": _extract_list_after_label(lines, "umpires"),
        "match_number": None,
    }

    match_number_match = MATCH_NUMBER_RE.search(raw_text)
    if match_number_match:
        match_details["match_number"] = _safe_int(match_number_match.group("number"))

    venue_text = match_details["venue"]
    if venue_text and "," in venue_text:
        venue_parts = [part.strip() for part in venue_text.split(",") if part.strip()]
        if len(venue_parts) >= 2:
            match_details["city"] = venue_parts[-1]
            match_details["venue"] = ", ".join(venue_parts[:-1])

    for line in lines:
        toss_match = TOSS_RE.search(line)
        if toss_match:
            match_details["toss_winner"] = _clean_name(toss_match.group("winner"))
            match_details["toss_decision"] = toss_match.group("decision").lower()
            break

    player_of_match = _extract_labeled_value(lines, "player of the match") or _extract_labeled_value(lines, "player of match")
    if not player_of_match:
        for line in lines:
            pom_match = PLAYER_OF_MATCH_RE.search(line)
            if pom_match:
                player_of_match = pom_match.group("name")
                break
    match_details["player_of_match"] = _clean_name(player_of_match)

    headers = _find_innings_headers(lines)
    innings: list[dict[str, Any]] = []
    for index, header in enumerate(headers):
        next_index = int(headers[index + 1]["line_index"]) if index + 1 < len(headers) else None
        innings.append(_parse_innings_block(lines, header, next_index))

    if len(innings) < 2:
        inferred_scores = [line for line in lines if _parse_score_header(line)]
        if len(inferred_scores) >= 2 and len(innings) < 2:
            match_details["venue"] = match_details["venue"] or ""

    result = {
        "winner": "",
        "loser": "",
        "result_type": "",
        "margin_runs": 0,
        "margin_wickets": 0,
    }

    if len(innings) >= 2:
        first, second = innings[0], innings[1]
        if first["score"] >= second["score"]:
            result = {
                "winner": first["team_name"],
                "loser": second["team_name"],
                "result_type": "runs",
                "margin_runs": max(0, first["score"] - second["score"]),
                "margin_wickets": 0,
            }
        else:
            wickets_margin = max(1, min(10, 10 - _safe_int(second["wickets"])))
            result = {
                "winner": second["team_name"],
                "loser": first["team_name"],
                "result_type": "wickets",
                "margin_runs": 0,
                "margin_wickets": wickets_margin,
            }

    explicit_result = ""
    for line in lines:
        if "won by" in line.lower():
            explicit_result = line
            run_match = RESULT_RUNS_RE.search(line)
            wicket_match = RESULT_WICKETS_RE.search(line)
            if run_match:
                result["winner"] = _clean_name(run_match.group("winner"))
                result["result_type"] = "runs"
                result["margin_runs"] = _safe_int(run_match.group("margin"))
            elif wicket_match:
                result["winner"] = _clean_name(wicket_match.group("winner"))
                result["result_type"] = "wickets"
                result["margin_wickets"] = _safe_int(wicket_match.group("margin"))
            break

    if not innings:
        warnings = ["No innings blocks could be parsed from the scorecard text."]
    else:
        warnings = []
    if not match_details["venue"]:
        warnings.append("Venue could not be confidently extracted.")
    if not match_details["player_of_match"]:
        warnings.append("Player of the match could not be confidently extracted.")
    if not match_details["toss_winner"]:
        warnings.append("Toss details could not be confidently extracted.")
    if not explicit_result:
        warnings.append("Result line not found; result was inferred from the innings scores.")

    confidence = 0.2
    confidence += 0.12 if match_details["venue"] else 0.0
    confidence += 0.08 if match_details["match_date"] else 0.0
    confidence += 0.08 if match_details["match_time"] else 0.0
    confidence += 0.1 if match_details["toss_winner"] else 0.0
    confidence += 0.08 if match_details["player_of_match"] else 0.0
    confidence += 0.18 if len(innings) >= 1 else 0.0
    confidence += 0.16 if len(innings) >= 2 else 0.0
    confidence += 0.05 if any(innings and innings[0]["batting"]) else 0.0
    confidence += 0.05 if any(innings and innings[0]["bowling"]) else 0.0
    confidence = round(min(confidence, 0.98), 3)

    return {
        "match_details": match_details,
        "innings": innings[:2],
        "result": result,
        "parser_warnings": warnings,
        "confidence_score": confidence,
    }
