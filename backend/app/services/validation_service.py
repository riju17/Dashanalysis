from __future__ import annotations

from typing import Optional

from fastapi import HTTPException, status

from app.data.store import store


def _raise(message: str):
    raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=message)


def validate_team_payload(payload: dict, team_id: Optional[str] = None, tournament_id: Optional[str] = None):
    team_name = (payload.get("team_name") or "").strip()
    if not team_name:
        _raise("team_name is required")
    for team in store.list("teams"):
        if tournament_id and str(team.get("tournament_id")) != str(tournament_id):
            continue
        if team["team_name"].lower() == team_name.lower() and team["id"] != team_id:
            _raise("Duplicate team name")


def validate_venue_payload(payload: dict, venue_id: Optional[str] = None, tournament_id: Optional[str] = None):
    venue_name = (payload.get("venue_name") or "").strip()
    if not venue_name:
        _raise("venue_name is required")
    for venue in store.list("venues"):
        if tournament_id and str(venue.get("tournament_id")) != str(tournament_id):
            continue
        if venue["venue_name"].lower() == venue_name.lower() and venue["id"] != venue_id:
            _raise("Duplicate venue name")


def validate_player_payload(payload: dict, tournament_id: Optional[str] = None):
    if not (payload.get("player_name") or "").strip():
        _raise("player_name is required")
    if not payload.get("team_id"):
        _raise("team_id is required")
    team = store.get("teams", str(payload["team_id"]))
    if not team:
        _raise("team_id does not exist")
    if tournament_id and str(team.get("tournament_id")) != str(tournament_id):
        _raise("team_id does not belong to the selected tournament")


def validate_match_payload(payload: dict, tournament_id: Optional[str] = None):
    if not payload.get("team_a_id") or not payload.get("team_b_id"):
        _raise("Both team_a_id and team_b_id are required")
    if str(payload["team_a_id"]) == str(payload["team_b_id"]):
        _raise("team_a_id and team_b_id must be different")
    team_a = store.get("teams", str(payload["team_a_id"]))
    team_b = store.get("teams", str(payload["team_b_id"]))
    if not team_a or not team_b:
        _raise("Team ids must exist")
    if tournament_id and (
        str(team_a.get("tournament_id")) != str(tournament_id)
        or str(team_b.get("tournament_id")) != str(tournament_id)
    ):
        _raise("Team ids must belong to the selected tournament")
    venue = store.get("venues", str(payload["venue_id"]))
    if not venue:
        _raise("venue_id must exist")
    if tournament_id and str(venue.get("tournament_id")) != str(tournament_id):
        _raise("venue_id must belong to the selected tournament")
