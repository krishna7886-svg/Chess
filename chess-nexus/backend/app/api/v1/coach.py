from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional, List
import chess
from app.services.gemini_coach import GeminiAICoach
from app.services.voice_parser import VoiceCommandParser

router = APIRouter(prefix="/coach", tags=["AI Coach"])
coach = GeminiAICoach()

class ExplainPositionRequest(BaseModel):
    fen: str
    move_history_san: Optional[List[str]] = []
    evaluation_cp: Optional[int] = 0
    best_move_uci: Optional[str] = "e2e4"
    language: Optional[str] = "en"  # "en" or "te"

class VoiceParseRequest(BaseModel):
    fen: str
    transcript: str

@router.post("/explain-position")
async def explain_position_endpoint(req: ExplainPositionRequest):
    try:
        chess.Board(req.fen)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid FEN string")

    explanation = await coach.explain_position(
        fen=req.fen,
        move_history_san=req.move_history_san or [],
        evaluation_cp=req.evaluation_cp or 0,
        best_move_uci=req.best_move_uci or "e2e4",
        language=req.language or "en"
    )
    return explanation

@router.post("/parse-voice")
async def parse_voice_endpoint(req: VoiceParseRequest):
    try:
        board = chess.Board(req.fen)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid FEN string")

    result = VoiceCommandParser.parse_intent(req.transcript, board)
    return result

