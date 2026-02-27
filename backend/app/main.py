from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from backend.app.api.buildings import router
from backend.app.core.config import OVERTURE_RELEASE

app = FastAPI(title="Overture Buildings Explorer")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(router)

@app.get("/api/health")
async def health():
    return {"status": "ok", "overture_release": OVERTURE_RELEASE}
