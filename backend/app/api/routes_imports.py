from __future__ import annotations

from typing import Any

from fastapi import APIRouter, Depends, HTTPException, Request, status

from app.api.deps import require_role
from app.models.schemas import ImportConfirmResponse, MatchImportResponse
from app.services.import_service import import_service


router = APIRouter()

try:
    import multipart  # type: ignore  # noqa: F401
    MULTIPART_AVAILABLE = True
except Exception:  # pragma: no cover - optional dependency
    MULTIPART_AVAILABLE = False


if MULTIPART_AVAILABLE:
    from fastapi import File, UploadFile

    @router.post("/screenshot", response_model=MatchImportResponse, status_code=status.HTTP_201_CREATED)
    async def import_screenshots(files: list[UploadFile] = File(...), x_user_role: str = Depends(require_role)):
        return await import_service.import_from_screenshots(files)

    @router.post("/pdf", response_model=MatchImportResponse, status_code=status.HTTP_201_CREATED)
    async def import_pdf(file: UploadFile = File(...), x_user_role: str = Depends(require_role)):
        return await import_service.import_from_pdf(file)
else:
    @router.post("/screenshot", response_model=MatchImportResponse, status_code=status.HTTP_503_SERVICE_UNAVAILABLE)
    async def import_screenshots(x_user_role: str = Depends(require_role)):
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="python-multipart is not installed. Install backend dependencies and restart the backend.",
        )

    @router.post("/pdf", response_model=MatchImportResponse, status_code=status.HTTP_503_SERVICE_UNAVAILABLE)
    async def import_pdf(x_user_role: str = Depends(require_role)):
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="python-multipart is not installed. Install backend dependencies and restart the backend.",
        )


@router.post("/url", response_model=MatchImportResponse, status_code=status.HTTP_201_CREATED)
async def import_from_url(request: Request, x_user_role: str = Depends(require_role)):
    payload = await request.json()
    url = payload.get("url") or payload.get("payload", {}).get("url")
    if not url:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="url is required")
    return import_service.import_from_url(str(url))


@router.post("/confirm", response_model=ImportConfirmResponse)
async def confirm_import(request: Request, x_user_role: str = Depends(require_role)):
    payload = await request.json()
    import_id = payload.get("import_id") or payload.get("payload", {}).get("import_id")
    parsed_json = payload.get("parsed_json") or payload.get("payload", {}).get("parsed_json")
    if not import_id or not parsed_json:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="import_id and parsed_json are required")
    return import_service.confirm_import(str(import_id), parsed_json)


@router.get("/{import_id}", response_model=MatchImportResponse)
def get_import(import_id: str):
    record = import_service.get_import(import_id)
    if not record:
        raise HTTPException(status_code=404, detail="Import session not found")
    return record
