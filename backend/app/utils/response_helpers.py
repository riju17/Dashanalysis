from __future__ import annotations


def ok(data=None, message: str = "Success"):
    return {"success": True, "message": message, "data": data}


def fail(message: str, detail=None):
    return {"success": False, "message": message, "detail": detail}
