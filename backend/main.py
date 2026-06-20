from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.routes_dashboard import router as dashboard_router
from app.api.routes_matches import router as matches_router
from app.api.routes_imports import router as imports_router
from app.api.routes_players import router as players_router
from app.api.routes_predictions import router as predictions_router
from app.api.routes_reports import router as reports_router
from app.api.routes_teams import router as teams_router
from app.api.routes_venues import router as venues_router
from app.core.config import settings

app = FastAPI()
# app = FastAPI(
#     title=settings.app_name,
#     version="1.0.0",
#     description="StatStrike Match Intelligence Engine backend API",
# )
@app.get("/")
def root():
    return {
        "message": "DashAnalysis API is running",
        "docs": "/docs"
    }
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins,
    allow_origin_regex=settings.allowed_origin_regex,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health_check():
    return {
        "status": "ok",
        "service": settings.app_name,
        "environment": settings.app_env,
    }


app.include_router(teams_router, prefix="/teams", tags=["Teams"])
app.include_router(venues_router, prefix="/venues", tags=["Venues"])
app.include_router(players_router, prefix="/players", tags=["Players"])
app.include_router(matches_router, prefix="/matches", tags=["Matches"])
app.include_router(imports_router, prefix="/imports", tags=["Imports"])
app.include_router(dashboard_router, prefix="/analytics", tags=["Analytics"])
app.include_router(predictions_router, prefix="/prediction", tags=["Prediction"])
app.include_router(reports_router, prefix="/reports", tags=["Reports"])
