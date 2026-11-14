from fastapi import APIRouter
from typing import Dict, Any, List

router = APIRouter(prefix="/puzzles", tags=["Puzzles"])

CURATED_PUZZLES: List[Dict[str, Any]] = [
    {
        "id": "puz-001",
        "title": "Grandmaster Back-Rank Deflection",
        "fen": "r4rk1/5ppp/8/8/8/8/5PPP/4R1K1 w - - 0 1",
        "rating": 2150,
        "theme": "Back Rank & Deflection",
        "solution_uci": ["e1e8"],
        "description": "White to move and deliver tactical deflection."
    },
    {
        "id": "puz-002",
        "title": "Royal Fork Opportunity",
        "fen": "r1b1k2r/pppp1ppp/2n5/4N3/2B1n3/8/PPPP1PPP/R1BQK2R w KQkq - 0 1",
        "rating": 1420,
        "theme": "Knight Fork",
        "solution_uci": ["c4f7"],
        "description": "White to move and exploit weakened f7 square."
    }
]

@router.get("/daily")
async def get_daily_puzzle():
    return CURATED_PUZZLES[0]

@router.get("/")
async def list_puzzles():
    return {"puzzles": CURATED_PUZZLES}

