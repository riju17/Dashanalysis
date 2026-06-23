from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.routes_access import router as access_router
from app.api.routes_admin import router as admin_router
from app.api.routes_reports import router as reports_router
from app.api.routes_tournament_scoped import router as tournament_scoped_router
from app.api.routes_tournaments import router as tournaments_router
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


app.include_router(tournaments_router, prefix="/tournaments", tags=["Tournaments"])
app.include_router(tournament_scoped_router, tags=["Tournament Scoped"])
app.include_router(access_router, tags=["Access"])
app.include_router(admin_router, prefix="/admin", tags=["Admin"])
app.include_router(reports_router, prefix="/reports", tags=["Reports"])
