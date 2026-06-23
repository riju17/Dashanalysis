# StatStrike Match Intelligence Engine

StatStrike is a futuristic cricket intelligence platform for analysts, coaches, academies, franchises, and tournament operators. It supports manual completed-match entry and instantly generates team insight, player impact, venue behaviour, toss analysis, opponent strategy, win probability, and report-ready notes.

## Stack

- Frontend: Next.js, React, TypeScript, TailwindCSS, Framer Motion, Recharts
- Backend: FastAPI, Pandas, NumPy, Scikit-learn, XGBoost-ready architecture
- Database: Supabase PostgreSQL, Supabase Auth, Supabase Storage-ready
- Deployment: Vercel for frontend, Render/Railway/Fly.io for backend, Supabase for database

## Folder Structure

- `frontend/` — Next.js application, UI system, analytics pages, and client API layer
- `backend/` — FastAPI application, analytics services, prediction engine, and report generator
- `supabase/schema.sql` — Database schema, indexes, and summary views
- `supabase/seed.sql` — Seed data for teams, venues, players, matches, and player stats
- `supabase/seed_match_24.sql` — Standalone seed for MPt20 match 24

## Local Setup

### 1) Supabase

1. Create a new Supabase project.
2. Run `supabase/schema.sql` in the SQL editor.
3. Run `supabase/seed.sql` to load sample data.
4. Run `supabase/seed_match_24.sql` if you want the Match 24 import fixture.
5. Copy the project URL and keys into environment files.

### 2) Backend

Create `backend/.env` from `backend/.env.example` and set:

- `SUPABASE_URL`
- `SUPABASE_SERVICE_KEY`
- `SUPABASE_ANON_KEY`
- `APP_NAME`
- `APP_ENV`
- `ALLOWED_ORIGINS`

Backend data access is now **Supabase-first**:

- If Supabase keys are present, the API reads and writes the Supabase tables first.
- If Supabase is unavailable, the app falls back to the in-memory sample store.
- For production deployment, run the Supabase schema and seed scripts before starting the backend.

### Auto Match Import

The Match Entry module now includes an **Auto Import** tab with three import paths:

- Upload multiple scorecard screenshots
- Paste a public scorecard URL
- Upload a scorecard PDF or image

Workflow:

1. Upload or paste the scorecard source.
2. The backend extracts raw text with OCR or scraping.
3. The parser converts the text into structured innings JSON.
4. The review screen lets you edit team names, player names, scores, wickets, overs, batting rows, bowling rows, and fall of wickets.
5. Save only after confirmation; the backend validates again before writing to Supabase or the local fallback store.

The import pipeline uses optional OCR engines in this order:

- PaddleOCR or EasyOCR if installed
- pytesseract as fallback
- OpenCV preprocessing before OCR
- PyMuPDF for PDF rendering and OCR fallback

Install and run:

```bash
cd backend
pip install -r requirements.txt
python -m uvicorn main:app --reload --port 8000
```

### 3) Frontend

Create `frontend/.env.local` from `frontend/.env.example` and set:

- `BACKEND_URL`
- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`

Install and run:

```bash
cd frontend
npm install
npm run dev
```

If you are already inside `backend/`, go up one level first:

```bash
cd ..
cd frontend
npm install
npm run dev
```

## Key Pages

- `frontend/src/app/dashboard/page.tsx` — Broadcast-style overview with KPI cards and charts
- `frontend/src/app/add-match/page.tsx` — Multi-step completed-match entry
- `frontend/src/app/teams/page.tsx` — Team analytics and coach notes
- `frontend/src/app/players/page.tsx` — Player impact analysis
- `frontend/src/app/venues/page.tsx` — Venue behaviour intelligence
- `frontend/src/app/toss/page.tsx` — Toss conversion analysis
- `frontend/src/app/opponent-strategy/page.tsx` — Matchup planning and strategy engine
- `frontend/src/app/prediction/page.tsx` — Rule-based win probability
- `frontend/src/app/tournament/page.tsx` — Tournament dashboard and points table
- `frontend/src/app/data-manager/page.tsx` — Match record management
- `frontend/src/app/admin/page.tsx` — Teams, players, venues, and theme controls
- `frontend/src/app/reports/page.tsx` — Match report generation

## Backend API

Health:

- `GET /health`

Teams:

- `GET /teams`
- `POST /teams`
- `GET /teams/{team_id}`
- `PUT /teams/{team_id}`

Venues:

- `GET /venues`
- `POST /venues`

Players:

- `GET /players`
- `POST /players`
- `GET /players/team/{team_id}`

Matches:

- `GET /matches`
- `POST /matches`
- `GET /matches/{match_id}`
- `DELETE /matches/{match_id}`
- `POST /matches/{match_id}/player-stats`
- `GET /matches/{match_id}/player-stats`

Analytics:

- `GET /analytics/dashboard`
- `GET /analytics/team/{team_id}`
- `GET /analytics/player/{player_id}`
- `GET /analytics/venue/{venue_id}`
- `GET /analytics/toss`
- `GET /analytics/head-to-head/{team_a_id}/{team_b_id}`
- `GET /analytics/opponent-strategy/{our_team_id}/{opponent_team_id}/{venue_id}`

Prediction:

- `POST /prediction/win-probability`

Reports:

- `POST /reports/match/{match_id}`
- `GET /reports/{report_id}`

Imports:

- `POST /imports/screenshot`
- `POST /imports/url`
- `POST /imports/pdf`
- `POST /imports/confirm`
- `GET /imports/{import_id}`

## Analytics Logic

The backend computes:

- Win/loss percentages
- Bat-first and chase conversion rates
- Toss conversion percentage
- Venue par score and safe score
- Head-to-head records
- Batting, bowling, and all-rounder impact
- Team strength score
- Rule-based win probability
- Natural-language analyst insights

Core formulas are implemented in `backend/app/utils/cricket_calculations.py`.

## Authentication and Roles

Supabase Auth is the intended auth provider. The backend currently supports role gating via the `X-User-Role` header:

- `Admin` — full access
- `Analyst` — add matches, stats, analytics, and reports
- `Viewer` — read-only

## Theme System

The 10-team color system is defined in `frontend/src/config/teamThemes.ts`. Each team includes:

- primary, secondary, accent colors
- gradient
- glow
- dark background
- ring gradient

## Deployment

### Frontend on Vercel

1. Import the `frontend/` directory into Vercel.
2. Set `BACKEND_URL`, `NEXT_PUBLIC_SUPABASE_URL`, and `NEXT_PUBLIC_SUPABASE_ANON_KEY`.
3. Deploy.

### Backend on Render/Railway/Fly.io

1. Create a Python web service from `backend/`.
2. Install `backend/requirements.txt`.
3. Set `SUPABASE_URL`, `SUPABASE_SERVICE_KEY`, and `SUPABASE_ANON_KEY`.
4. Start with `uvicorn main:app --host 0.0.0.0 --port 8000`.

### Supabase

1. Run `supabase/schema.sql`.
2. Run `supabase/seed.sql`.
3. Ensure `match_imports` is created by the schema and available in Supabase.
4. Enable Supabase Auth.
5. Add RLS policies as needed for production access control.

## Future Roadmap

- Ball-by-ball analysis
- Wagon wheel module
- Pitch map module
- Shot zone module
- Bowling heat map module
- Video tagging module
- AI strategy assistant
- ML training pipeline
- Automated PDF reports
- Live scoring integration

Placeholders for these modules live in `backend/app/future/`.

## Notes

- The frontend falls back to local demo data if the backend is unavailable.
- The backend also ships with an in-memory sample store so the API works locally even before connecting to Supabase.
- This MVP is structured for extension, not just for demo screenshots.
# Dashanalysis
