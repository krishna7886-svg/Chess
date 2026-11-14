import uuid
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from typing import Optional, List
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.db.session import get_db
from app.db.models import Match
from app.services.match_service import MatchManager

router = APIRouter(prefix="/matches", tags=["Matches"])

class CreateMatchRequest(BaseModel):
    white_player_id: str
    black_player_id: str
    time_control: str = "blitz_3_2"
    initial_time_seconds: int = 180
    increment_seconds: int = 2

class MatchResponse(BaseModel):
    match_id: str
    white_player_id: str
    black_player_id: str
    time_control: str
    status: str
    initial_time_seconds: int
    increment_seconds: int
    fen: str

@router.post("/create", response_model=MatchResponse, status_code=status.HTTP_201_CREATED)
async def create_match(req: CreateMatchRequest, db: AsyncSession = Depends(get_db)):
    match_id = str(uuid.uuid4())
    match_record = Match(
        id=match_id,
        white_player_id=req.white_player_id,
        black_player_id=req.black_player_id,
        time_control=req.time_control,
        initial_time_seconds=req.initial_time_seconds,
        increment_seconds=req.increment_seconds,
        status="in_progress"
    )
    db.add(match_record)
    await db.commit()

    session = MatchManager.get_or_create_session(
        match_id=match_id,
        white_player_id=req.white_player_id,
        black_player_id=req.black_player_id,
        initial_time_seconds=req.initial_time_seconds,
        increment_seconds=req.increment_seconds
    )

    return MatchResponse(
        match_id=match_id,
        white_player_id=req.white_player_id,
        black_player_id=req.black_player_id,
        time_control=req.time_control,
        status="in_progress",
        initial_time_seconds=req.initial_time_seconds,
        increment_seconds=req.increment_seconds,
        fen=session.engine.current_fen
    )

@router.get("/{match_id}")
async def get_match_status(match_id: str):
    session = MatchManager.get_session(match_id)
    if not session:
        raise HTTPException(status_code=404, detail="Match not found")

    w_time, b_time = session.get_clocks()
    return {
        "match_id": match_id,
        "fen": session.engine.current_fen,
        "turn": session.current_turn(),
        "white_time_ms": w_time,
        "black_time_ms": b_time,
        "is_game_over": session.is_game_over,
        "result": session.result,
        "termination_reason": session.termination_reason,
        "moves_san": session.move_history_san
    }

