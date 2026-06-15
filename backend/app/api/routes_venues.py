from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, status

from app.api.deps import require_role
from app.data.store import store
from app.models.schemas import VenueCreate, VenueResponse
from app.services.analytics_service import analytics_service
from app.services.validation_service import validate_venue_payload


router = APIRouter()


@router.get("", response_model=list[VenueResponse])
def list_venues():
    return store.list("venues")


@router.post("", response_model=VenueResponse, status_code=status.HTTP_201_CREATED)
def create_venue(payload: VenueCreate, x_user_role: str = Depends(require_role)):
    validate_venue_payload(payload.model_dump())
    return store.insert("venues", payload.model_dump())


@router.get("/{venue_id}")
def get_venue(venue_id: str):
    venue = store.get("venues", venue_id)
    if not venue:
        raise HTTPException(status_code=404, detail="Venue not found")
    return venue


@router.get("/{venue_id}/analytics")
def venue_analytics(venue_id: str):
    return analytics_service.venue_summary(venue_id)
