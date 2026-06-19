from __future__ import annotations

import csv
import io
import json
import re
import textwrap
from typing import Any

import fitz
from fastapi.responses import Response

from app.utils.cricket_calculations import balls_to_overs, parse_overs_to_balls, percentage


PAGE_WIDTH = 595
PAGE_HEIGHT = 842
MARGIN_X = 40
MARGIN_TOP = 42
MARGIN_BOTTOM = 42
CONTENT_WIDTH = PAGE_WIDTH - (MARGIN_X * 2)
TITLE_COLOR = (0.10, 0.45, 0.82)
TEXT_COLOR = (0.12, 0.16, 0.22)
MUTED_COLOR = (0.43, 0.48, 0.55)
TABLE_HEADER_FILL = (0.90, 0.94, 0.99)
TABLE_BORDER = (0.80, 0.84, 0.90)
CARD_FILL = (0.97, 0.98, 1.0)
CARD_BORDER = (0.86, 0.89, 0.94)


def _safe_filename(value: str, extension: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "-", value.lower()).strip("-")
    return f"{slug or 'report'}.{extension}"


def _stringify(value: Any) -> str:
    if value is None:
        return ""
    if isinstance(value, (dict, list, tuple)):
        return json.dumps(value, ensure_ascii=False)
    return str(value)


def _match_report_payload(report: dict[str, Any]) -> dict[str, Any]:
    payload = report.get("report_json") if isinstance(report.get("report_json"), dict) else report
    return payload if isinstance(payload, dict) else {}


def _match_report_title(report: dict[str, Any]) -> str:
    title = report.get("report_title")
    if isinstance(title, str) and title.strip():
        return title
    return "Match Report"


def _performance_report_title(report: dict[str, Any]) -> str:
    title = report.get("report_title")
    if isinstance(title, str) and title.strip():
        return title
    return "Player Performance Report"


def _performance_report_mode(report: dict[str, Any]) -> str:
    filters = report.get("filters") or {}
    mode = str(filters.get("mode") or "").strip().lower()
    return mode if mode in {"batting", "bowling"} else "batting"


def _performance_style_value(report: dict[str, Any]) -> str:
    filters = report.get("filters") or {}
    style = str(filters.get("style") or "").strip()
    if style.lower() == "all":
        return "All Batting Styles" if _performance_report_mode(report) == "batting" else "All Bowlers"
    return style or "All"


def _best_match_label(best_match: dict[str, Any]) -> str:
    match_number = best_match.get("match_number")
    opponent = best_match.get("opponent_team_name") or "Unknown opponent"
    venue = best_match.get("venue_name") or "Unknown venue"
    if match_number is None:
        return f"vs {opponent} at {venue}"
    return f"Match {match_number} vs {opponent} at {venue}"


def _section_rows(value: Any, prefix: str) -> list[tuple[str, str]]:
    rows: list[tuple[str, str]] = []
    if isinstance(value, dict):
        if not value:
            rows.append((prefix, "{}"))
        for key, nested in value.items():
            child_prefix = f"{prefix}.{key}" if prefix else str(key)
            rows.extend(_section_rows(nested, child_prefix))
        return rows
    if isinstance(value, list):
        if not value:
            rows.append((prefix, "[]"))
        for index, nested in enumerate(value, 1):
            child_prefix = f"{prefix}[{index}]"
            rows.extend(_section_rows(nested, child_prefix))
        return rows
    rows.append((prefix, _stringify(value)))
    return rows


def _csv_from_match_report(report: dict[str, Any]) -> str:
    payload = _match_report_payload(report)
    buffer = io.StringIO()
    writer = csv.writer(buffer)
    writer.writerow(["Report Title", _match_report_title(report)])
    writer.writerow(["Match ID", _stringify(report.get("match_id"))])
    writer.writerow([])
    writer.writerow(["Section", "Item", "Value"])
    for key, value in payload.items():
        for item, item_value in _section_rows(value, key.replace("_", " ").title()):
            writer.writerow([key.replace("_", " ").title(), item, item_value])
    return buffer.getvalue()


def _performance_report_rows(report: dict[str, Any]) -> tuple[list[str], list[list[Any]]]:
    mode = _performance_report_mode(report)
    if mode == "bowling":
        headers = [
            "Player",
            "Team",
            "Style",
            "Mts",
            "O",
            "Mdns",
            "Runs",
            "Wkts",
            "Dots",
            "Eco",
            "Best M",
            "Score",
        ]
        rows: list[list[Any]] = []
        for row in report.get("rows") or []:
            rows.append(
                [
                    row.get("player_name", ""),
                    row.get("team_name", ""),
                    row.get("bowling_style_code") or "OTHERS",
                    row.get("matches_played", 0),
                    row.get("overs", 0),
                    row.get("maidens", 0),
                    row.get("runs_conceded", 0),
                    row.get("wickets", 0),
                    row.get("dot_balls", 0),
                    row.get("economy", 0),
                    _best_match_label(row.get("best_match") or {}),
                    row.get("best_score", 0),
                ]
            )
        return headers, rows

    headers = [
        "Player",
        "Team",
        "Style",
        "Mts",
        "Runs",
        "Balls",
        "4s",
        "6s",
        "SR",
        "Best M",
        "Score",
    ]
    rows = []
    for row in report.get("rows") or []:
        rows.append(
            [
                row.get("player_name", ""),
                row.get("team_name", ""),
                row.get("batting_style") or "Unknown",
                row.get("matches_played", 0),
                row.get("runs", 0),
                row.get("balls", 0),
                row.get("fours", 0),
                row.get("sixes", 0),
                row.get("strike_rate", 0),
                _best_match_label(row.get("best_match") or {}),
                row.get("best_score", 0),
            ]
        )
    return headers, rows


def _performance_total_headers(mode: str) -> list[str]:
    if mode == "bowling":
        return ["Team", "Players", "Mts", "O", "Mdns", "Runs", "Wkts", "Dots", "Eco"]
    return ["Team", "Players", "Mts", "Runs", "Balls", "4s", "6s", "SR"]


def _performance_total_values(total: dict[str, Any], mode: str) -> list[Any]:
    team_name = total.get("team_name") or total.get("label") or "Total"
    if mode == "bowling":
        return [
            team_name,
            total.get("players_count", 0),
            total.get("matches_played", 0),
            total.get("overs", 0),
            total.get("maidens", 0),
            total.get("runs_conceded", 0),
            total.get("wickets", 0),
            total.get("dot_balls", 0),
            total.get("economy", 0),
        ]
    return [
        team_name,
        total.get("players_count", 0),
        total.get("matches_played", 0),
        total.get("runs", 0),
        total.get("balls", 0),
        total.get("fours", 0),
        total.get("sixes", 0),
        total.get("strike_rate", 0),
    ]


def _derive_performance_totals(report: dict[str, Any]) -> tuple[list[dict[str, Any]], dict[str, Any] | None]:
    mode = _performance_report_mode(report)
    rows = list(report.get("rows") or [])
    grouped: dict[str, list[dict[str, Any]]] = {}
    for row in rows:
        team_id = str(row.get("team_id") or row.get("team_name") or "unknown")
        grouped.setdefault(team_id, []).append(row)

    team_totals = list(report.get("team_totals") or [])
    if not team_totals and grouped:
        for team_id, team_rows in grouped.items():
            sample = team_rows[0]
            team_name = sample.get("team_name") or "Unknown team"
            if mode == "bowling":
                overs_balls = int(
                    sum(
                        int(row.get("overs_balls", 0) or parse_overs_to_balls(float(row.get("overs", 0) or 0)))
                        for row in team_rows
                    )
                )
                total = {
                    "label": team_name,
                    "team_id": sample.get("team_id"),
                    "team_name": team_name,
                    "players_count": len(team_rows),
                    "matches_played": int(sum(int(row.get("matches_played", 0) or 0) for row in team_rows)),
                    "overs_balls": overs_balls,
                    "overs": balls_to_overs(overs_balls),
                    "maidens": int(sum(int(row.get("maidens", 0) or 0) for row in team_rows)),
                    "runs_conceded": int(sum(int(row.get("runs_conceded", 0) or 0) for row in team_rows)),
                    "wickets": int(sum(int(row.get("wickets", 0) or 0) for row in team_rows)),
                    "dot_balls": int(sum(int(row.get("dot_balls", 0) or 0) for row in team_rows)),
                }
                total["economy"] = round(total["runs_conceded"] / (overs_balls / 6), 2) if overs_balls else 0.0
            else:
                total_runs = int(sum(int(row.get("runs", 0) or 0) for row in team_rows))
                total_balls = int(sum(int(row.get("balls", 0) or 0) for row in team_rows))
                total = {
                    "label": team_name,
                    "team_id": sample.get("team_id"),
                    "team_name": team_name,
                    "players_count": len(team_rows),
                    "matches_played": int(sum(int(row.get("matches_played", 0) or 0) for row in team_rows)),
                    "overs_balls": 0,
                    "overs": 0.0,
                    "maidens": 0,
                    "runs_conceded": 0,
                    "wickets": 0,
                    "dot_balls": 0,
                    "runs": total_runs,
                    "balls": total_balls,
                    "fours": int(sum(int(row.get("fours", 0) or 0) for row in team_rows)),
                    "sixes": int(sum(int(row.get("sixes", 0) or 0) for row in team_rows)),
                }
                total["strike_rate"] = round(percentage(total_runs, total_balls), 2) if total_balls else 0.0
            team_totals.append(total)

    overall_total = report.get("overall_total")
    if not overall_total and rows:
        total_rows = rows
        if mode == "bowling":
            overs_balls = int(
                sum(int(row.get("overs_balls", 0) or parse_overs_to_balls(float(row.get("overs", 0) or 0))) for row in total_rows)
            )
            overall_total = {
                "label": "Overall Total",
                "team_name": "Overall Total",
                "players_count": len(total_rows),
                "matches_played": int(sum(int(row.get("matches_played", 0) or 0) for row in total_rows)),
                "overs_balls": overs_balls,
                "overs": balls_to_overs(overs_balls),
                "maidens": int(sum(int(row.get("maidens", 0) or 0) for row in total_rows)),
                "runs_conceded": int(sum(int(row.get("runs_conceded", 0) or 0) for row in total_rows)),
                "wickets": int(sum(int(row.get("wickets", 0) or 0) for row in total_rows)),
                "dot_balls": int(sum(int(row.get("dot_balls", 0) or 0) for row in total_rows)),
            }
            overall_total["economy"] = round(overall_total["runs_conceded"] / (overs_balls / 6), 2) if overs_balls else 0.0
        else:
            total_runs = int(sum(int(row.get("runs", 0) or 0) for row in total_rows))
            total_balls = int(sum(int(row.get("balls", 0) or 0) for row in total_rows))
            overall_total = {
                "label": "Overall Total",
                "team_name": "Overall Total",
                "players_count": len(total_rows),
                "matches_played": int(sum(int(row.get("matches_played", 0) or 0) for row in total_rows)),
                "overs_balls": 0,
                "overs": 0.0,
                "maidens": 0,
                "runs_conceded": 0,
                "wickets": 0,
                "dot_balls": 0,
                "runs": total_runs,
                "balls": total_balls,
                "fours": int(sum(int(row.get("fours", 0) or 0) for row in total_rows)),
                "sixes": int(sum(int(row.get("sixes", 0) or 0) for row in total_rows)),
            }
            overall_total["strike_rate"] = round(percentage(total_runs, total_balls), 2) if total_balls else 0.0

    return team_totals, overall_total


def _csv_from_performance_report(report: dict[str, Any]) -> str:
    buffer = io.StringIO()
    writer = csv.writer(buffer)
    filters = report.get("filters") or {}
    team_totals, overall_total = _derive_performance_totals(report)

    writer.writerow(["Report Title", _performance_report_title(report)])
    writer.writerow(["Mode", str(filters.get("mode") or "").title()])
    writer.writerow(["Style", _performance_style_value(report)])
    if filters.get("use_venue_filter"):
        writer.writerow(["Venue", filters.get("venue_name") or "Selected venue"])
    team_names = filters.get("team_names") or []
    if team_names:
        writer.writerow(["Teams", ", ".join(team_names)])
    writer.writerow([])

    summary = report.get("summary") or []
    if summary:
        writer.writerow(["Summary", "Item", "Value"])
        for index, line in enumerate(summary, 1):
            writer.writerow(["Summary", index, line])
        writer.writerow([])

    headers, rows = _performance_report_rows(report)
    writer.writerow(["Players"])
    writer.writerow(headers)
    writer.writerows(rows)
    writer.writerow([])
    writer.writerow(["Team Totals"])
    team_headers = _performance_total_headers(_performance_report_mode(report))
    writer.writerow(team_headers)
    for total in team_totals:
        writer.writerow(_performance_total_values(total, _performance_report_mode(report)))
    if overall_total:
        writer.writerow([])
        writer.writerow(["Overall Total"])
        writer.writerow(team_headers)
        writer.writerow(_performance_total_values(overall_total, _performance_report_mode(report)))
    return buffer.getvalue()


def _wrap_lines(text: str, max_chars: int) -> list[str]:
    wrapped = textwrap.wrap(text, width=max_chars)
    return wrapped or [""]


def _render_title(page: fitz.Page, title: str, subtitle: str | None = None) -> int:
    page.insert_text((MARGIN_X, 58), title, fontsize=20, fontname="helv", color=TITLE_COLOR)
    y = 58 + 22
    if subtitle:
        page.insert_text((MARGIN_X, y), subtitle, fontsize=10, fontname="helv", color=MUTED_COLOR)
        y += 16
    return y + 10


def _render_cards(page: fitz.Page, y: int, items: list[tuple[str, str]]) -> int:
    if not items:
        return y
    gap = 12
    card_width = (CONTENT_WIDTH - gap) / 2
    card_height = 34
    index = 0
    while index < len(items):
        left = items[index]
        right = items[index + 1] if index + 1 < len(items) else None
        for column, item in enumerate((left, right)):
            if item is None:
                continue
            x = MARGIN_X + column * (card_width + gap)
            rect = fitz.Rect(x, y, x + card_width, y + card_height)
            page.draw_rect(rect, color=CARD_BORDER, fill=CARD_FILL, width=0.8)
            label, value = item
            page.insert_textbox(
                fitz.Rect(x + 10, y + 4, x + card_width - 10, y + 14),
                label.upper(),
                fontsize=7,
                fontname="helv",
                color=MUTED_COLOR,
            )
            page.insert_textbox(
                fitz.Rect(x + 10, y + 15, x + card_width - 10, y + card_height - 4),
                value,
                fontsize=10,
                fontname="helv",
                color=TEXT_COLOR,
            )
        y += card_height + 10
        index += 2
    return y


def _estimate_row_height(values: list[str], widths: list[float], font_size: int = 9) -> int:
    max_lines = 1
    for value, width in zip(values, widths):
        max_chars = max(10, int(width / (font_size * 0.55)))
        max_lines = max(max_lines, len(_wrap_lines(value, max_chars)))
    return max(20, (max_lines * (font_size + 2)) + 6)


def _draw_table_header(page: fitz.Page, y: int, headers: list[str], widths: list[float]) -> int:
    x = MARGIN_X
    header_height = 24
    for header, width in zip(headers, widths):
        rect = fitz.Rect(x, y, x + width, y + header_height)
        page.draw_rect(rect, color=TABLE_BORDER, fill=TABLE_HEADER_FILL, width=0.8)
        page.insert_textbox(
            fitz.Rect(x + 6, y + 4, x + width - 6, y + header_height - 4),
            header,
            fontsize=8,
            fontname="helv",
            color=TEXT_COLOR,
        )
        x += width
    return y + header_height


def _draw_table_row(page: fitz.Page, y: int, values: list[Any], widths: list[float]) -> int:
    string_values = [_stringify(value) for value in values]
    row_height = _estimate_row_height(string_values, widths)
    x = MARGIN_X
    for value, width in zip(string_values, widths):
        rect = fitz.Rect(x, y, x + width, y + row_height)
        page.draw_rect(rect, color=TABLE_BORDER, width=0.6)
        max_chars = max(10, int(width / 4.9))
        text = "\n".join(_wrap_lines(value, max_chars))
        page.insert_textbox(
            fitz.Rect(x + 5, y + 3, x + width - 5, y + row_height - 3),
            text,
            fontsize=8.5,
            fontname="helv",
            color=TEXT_COLOR,
        )
        x += width
    return y + row_height


def _performance_pdf(report: dict[str, Any]) -> bytes:
    mode = _performance_report_mode(report)
    headers, rows = _performance_report_rows(report)
    filters = report.get("filters") or {}
    title = _performance_report_title(report)
    team_totals, overall_total = _derive_performance_totals(report)

    doc = fitz.open()
    page = doc.new_page(width=PAGE_WIDTH, height=PAGE_HEIGHT)
    y = _render_title(page, title, "Presentation-ready export with mode-specific columns.")
    metadata_line = " | ".join(
        [
            f"Mode: {str(filters.get('mode') or '').title()}",
            f"Style: {_performance_style_value(report)}",
            f"Venue: {filters.get('venue_name') or ('All venues' if not filters.get('use_venue_filter') else 'Selected venue')}",
            f"Players: {len(rows)}",
        ]
    )
    page.insert_text((MARGIN_X, y), metadata_line, fontsize=9.5, fontname="helv", color=TEXT_COLOR)
    y += 16
    card_items = [
        ("Mode", str(filters.get("mode") or "").title()),
        ("Style", _performance_style_value(report)),
        ("Venue", filters.get("venue_name") or ("All venues" if not filters.get("use_venue_filter") else "Selected venue")),
        ("Players", str(len(rows))),
    ]
    y = _render_cards(page, y, card_items)

    summary = report.get("summary") or []
    if summary:
        page.insert_text((MARGIN_X, y), "Summary", fontsize=12, fontname="helv", color=TITLE_COLOR)
        y += 16
        for item in summary:
            bullet = f"- {item}"
            lines = _wrap_lines(bullet, 96)
            for line in lines:
                page.insert_text((MARGIN_X + 12, y), line, fontsize=9.5, fontname="helv", color=TEXT_COLOR)
                y += 12
        y += 6

    table_title = "Bowling Performance" if mode == "bowling" else "Batting Performance"
    page.insert_text((MARGIN_X, y), table_title, fontsize=12, fontname="helv", color=TITLE_COLOR)
    y += 8

    widths = _performance_table_widths(mode)
    y = _draw_table_header(page, y, headers, widths)
    y += 2
    for row in rows:
        if y + 32 > PAGE_HEIGHT - MARGIN_BOTTOM:
            page = doc.new_page(width=PAGE_WIDTH, height=PAGE_HEIGHT)
            y = _render_title(page, title, "Continued")
            y = _draw_table_header(page, y, headers, widths)
            y += 2
        y = _draw_table_row(page, y, row, widths)

    if team_totals:
        if y + 30 > PAGE_HEIGHT - MARGIN_BOTTOM:
            page = doc.new_page(width=PAGE_WIDTH, height=PAGE_HEIGHT)
            y = _render_title(page, title, "Continued")
        y += 10
        page.insert_text((MARGIN_X, y), "Team Totals", fontsize=12, fontname="helv", color=TITLE_COLOR)
        y += 8
        total_headers = _performance_total_headers(mode)
        total_widths = _performance_total_widths(mode)
        y = _draw_table_header(page, y, total_headers, total_widths)
        y += 2
        for total in team_totals:
            if y + 28 > PAGE_HEIGHT - MARGIN_BOTTOM:
                page = doc.new_page(width=PAGE_WIDTH, height=PAGE_HEIGHT)
                y = _render_title(page, title, "Continued")
                page.insert_text((MARGIN_X, y), "Team Totals", fontsize=12, fontname="helv", color=TITLE_COLOR)
                y += 8
                y = _draw_table_header(page, y, total_headers, total_widths)
                y += 2
            y = _draw_table_row(page, y, _performance_total_values(total, mode), total_widths)

    if overall_total:
        if y + 30 > PAGE_HEIGHT - MARGIN_BOTTOM:
            page = doc.new_page(width=PAGE_WIDTH, height=PAGE_HEIGHT)
            y = _render_title(page, title, "Continued")
        y += 10
        page.insert_text((MARGIN_X, y), "Overall Total", fontsize=12, fontname="helv", color=TITLE_COLOR)
        y += 8
        total_headers = _performance_total_headers(mode)
        total_widths = _performance_total_widths(mode)
        y = _draw_table_header(page, y, total_headers, total_widths)
        y += 2
        y = _draw_table_row(page, y, _performance_total_values(overall_total, mode), total_widths)

    return doc.tobytes()


def _performance_table_widths(mode: str) -> list[float]:
    if mode == "bowling":
        return [68, 54, 34, 32, 28, 30, 36, 30, 30, 30, 107, 36]
    return [68, 54, 58, 32, 40, 38, 28, 28, 32, 107, 30]


def _performance_total_widths(mode: str) -> list[float]:
    if mode == "bowling":
        return [98, 44, 36, 42, 42, 52, 42, 42, 42]
    return [98, 44, 36, 48, 48, 42, 42, 44]


def _match_pdf(report: dict[str, Any]) -> bytes:
    title = _match_report_title(report)
    payload = _match_report_payload(report)
    doc = fitz.open()
    page = doc.new_page(width=PAGE_WIDTH, height=PAGE_HEIGHT)
    y = _render_title(page, title, "Structured match summary export.")

    cards: list[tuple[str, str]] = []
    if payload.get("match_summary"):
        cards.append(("Match Summary", _stringify(payload.get("match_summary"))))
    if payload.get("player_impact"):
        player_impact = payload["player_impact"]
        if isinstance(player_impact, dict):
            player_name = player_impact.get("player", {}).get("player_name") if isinstance(player_impact.get("player"), dict) else None
            cards.append(("Player Impact", player_name or "Detailed player impact available"))
    if payload.get("strategy_notes"):
        cards.append(("Strategy Notes", "Venue and matchup recommendations included"))
    y = _render_cards(page, y, cards)

    sections: list[tuple[str, list[str]]] = []
    if payload.get("match_summary"):
        sections.append(("Match Summary", _wrap_lines(_stringify(payload.get("match_summary")), 96)))
    if payload.get("key_turning_points"):
        sections.append(("Key Turning Points", [f"{index}. {point}" for index, point in enumerate(payload["key_turning_points"], 1)]))
    team_insights = payload.get("team_insights")
    if isinstance(team_insights, dict) and team_insights:
        team_lines: list[str] = []
        for team_name, insights in team_insights.items():
            team_lines.append(team_name)
            for insight in insights or []:
                team_lines.append(f"  - {insight}")
        sections.append(("Team Insights", team_lines))
    if payload.get("strategy_notes"):
        strategy_lines = [f"{key.replace('_', ' ').title()}: {_stringify(value)}" for key, value in payload["strategy_notes"].items()]
        sections.append(("Strategy Notes", strategy_lines))
    if payload.get("player_impact"):
        sections.append(("Player Impact", _section_text_lines(payload["player_impact"])))

    for heading, lines in sections:
        if y + 24 > PAGE_HEIGHT - MARGIN_BOTTOM:
            page = doc.new_page(width=PAGE_WIDTH, height=PAGE_HEIGHT)
            y = _render_title(page, title, "Continued")
        page.insert_text((MARGIN_X, y), heading, fontsize=12, fontname="helv", color=TITLE_COLOR)
        y += 15
        for line in lines:
            wrapped = _wrap_lines(line, 96)
            for wrapped_line in wrapped:
                if y + 12 > PAGE_HEIGHT - MARGIN_BOTTOM:
                    page = doc.new_page(width=PAGE_WIDTH, height=PAGE_HEIGHT)
                    y = _render_title(page, title, "Continued")
                    page.insert_text((MARGIN_X, y), heading, fontsize=12, fontname="helv", color=TITLE_COLOR)
                    y += 15
                page.insert_text((MARGIN_X + 12, y), wrapped_line, fontsize=9.5, fontname="helv", color=TEXT_COLOR)
                y += 12
        y += 6
    return doc.tobytes()


def _section_text_lines(value: Any) -> list[str]:
    lines: list[str] = []
    if isinstance(value, dict):
        for key, nested in value.items():
            if isinstance(nested, (dict, list)):
                lines.append(f"{key}:")
                for child_key, child_value in _section_rows(nested, ""):
                    prefix = f"  - {child_key}: " if child_key else "  - "
                    lines.append(f"{prefix}{child_value}".rstrip())
            else:
                lines.append(f"{key}: {_stringify(nested)}")
    elif isinstance(value, list):
        for index, item in enumerate(value, 1):
            lines.append(f"{index}. {_stringify(item)}")
    else:
        lines.append(_stringify(value))
    return lines


class ReportExportService:
    def export_match_report(self, report: dict[str, Any], export_format: str) -> Response:
        title = _match_report_title(report)
        if export_format == "csv":
            csv_text = _csv_from_match_report(report)
            return Response(
                content=csv_text.encode("utf-8"),
                media_type="text/csv",
                headers={"Content-Disposition": f'attachment; filename="{_safe_filename(title, "csv")}"'},
            )

        pdf_bytes = _match_pdf(report)
        return Response(
            content=pdf_bytes,
            media_type="application/pdf",
            headers={"Content-Disposition": f'attachment; filename="{_safe_filename(title, "pdf")}"'},
        )

    def export_performance_report(self, report: dict[str, Any], export_format: str) -> Response:
        title = _performance_report_title(report)
        if export_format == "csv":
            csv_text = _csv_from_performance_report(report)
            return Response(
                content=csv_text.encode("utf-8"),
                media_type="text/csv",
                headers={"Content-Disposition": f'attachment; filename="{_safe_filename(title, "csv")}"'},
            )

        pdf_bytes = _performance_pdf(report)
        return Response(
            content=pdf_bytes,
            media_type="application/pdf",
            headers={"Content-Disposition": f'attachment; filename="{_safe_filename(title, "pdf")}"'},
        )


report_export_service = ReportExportService()
