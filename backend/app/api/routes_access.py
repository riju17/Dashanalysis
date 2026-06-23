from __future__ import annotations

from fastapi import APIRouter, Depends

from app.api.deps import get_current_user
from app.models.schemas import AccessKeyRedemptionRequest, AccessKeyRedemptionResponse, UserAccessSummaryResponse
from app.services.tournament_service import _list_access_rows, redeem_access_key


router = APIRouter()


@router.post("/redeem", response_model=AccessKeyRedemptionResponse)
def redeem_tournament_access(payload: AccessKeyRedemptionRequest, user=Depends(get_current_user)):
    return redeem_access_key(payload.access_key, user)


@router.get("/me/access", response_model=UserAccessSummaryResponse)
def get_my_access(user=Depends(get_current_user)):
    return {
        "user_id": user.id,
        "email": user.email,
        "tournaments": _list_access_rows(user.id, include_inactive=True),
    }
