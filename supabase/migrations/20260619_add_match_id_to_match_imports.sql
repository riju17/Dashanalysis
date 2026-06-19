alter table if exists match_imports
add column if not exists match_id uuid references matches(id) on delete set null;
