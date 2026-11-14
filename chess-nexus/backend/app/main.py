from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from app.core.config import settings
from app.db.session import engine, Base
from app.api.v1.auth import router as auth_router
from app.api.v1.matches import router as match_router
from app.api.v1.coach import router as coach_router
from app.api.v1.tournaments import router as tournament_router
from app.api.v1.puzzles import router as puzzle_router
from app.websockets.match_hub import match_hub

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Initialize DB tables on startup
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield
    # Cleanup on shutdown
    await engine.dispose()

app = FastAPI(
    title=settings.PROJECT_NAME,
    version="1.0.0",
    description="CHESS NEXUS – Production Cross-Platform Chess Platform Backend",
    lifespan=lifespan
)

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount REST API Routers
app.include_router(auth_router, prefix=settings.API_V1_STR)
app.include_router(match_router, prefix=settings.API_V1_STR)
app.include_router(coach_router, prefix=settings.API_V1_STR)
app.include_router(tournament_router, prefix=settings.API_V1_STR)
app.include_router(puzzle_router, prefix=settings.API_V1_STR)

# Mount Real-Time Match WebSocket
@app.websocket("/ws/match/{match_id}")
async def match_websocket_endpoint(websocket: WebSocket, match_id: str):
    await match_hub.connect(match_id, websocket)
    try:
        while True:
            data = await websocket.receive_text()
            await match_hub.handle_client_message(match_id, websocket, data)
    except WebSocketDisconnect:
        match_hub.disconnect(match_id, websocket)

@app.get("/health")
async def health_check():
    return {"status": "ok", "service": "chess-nexus-backend", "version": "1.0.0"}

