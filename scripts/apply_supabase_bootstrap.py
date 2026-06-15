from __future__ import annotations

import os
from pathlib import Path

import psycopg2


def load_env_file(path: Path) -> dict[str, str]:
    values: dict[str, str] = {}
    if not path.exists():
        return values
    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        values[key.strip()] = value.strip().strip("'").strip('"')
    return values


def read_sql(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def main() -> None:
    root = Path(__file__).resolve().parents[1]
    file_env = load_env_file(root / "backend" / ".env")
    project_ref = os.environ.get("SUPABASE_PROJECT_REF", "rkgtrhaafvtwmrluceyh")
    password = os.environ.get("SUPABASE_DB_PASSWORD") or file_env.get("SUPABASE_DB_PASSWORD")
    if not password:
        raise SystemExit("SUPABASE_DB_PASSWORD is required.")

    conn = psycopg2.connect(
        host=f"db.{project_ref}.supabase.co",
        port=5432,
        dbname="postgres",
        user="postgres",
        password=password,
        sslmode="require",
    )
    conn.autocommit = False

    schema_sql = read_sql(root / "supabase" / "schema.sql")
    seed_sql = read_sql(root / "supabase" / "seed.sql")

    match_marker = "-- Match 24:"
    player_marker = "insert into players"
    before_match, match_and_players = seed_sql.split(match_marker, 1)
    match_section = match_marker + match_and_players
    match_part, players_part = match_section.split(player_marker, 1)
    players_section = player_marker + players_part

    with conn:
        with conn.cursor() as cursor:
            cursor.execute(schema_sql)
            cursor.execute(before_match)
            cursor.execute(players_section)
            cursor.execute(match_part)

    conn.close()
    print("Supabase schema and seed applied successfully.")


if __name__ == "__main__":
    main()
