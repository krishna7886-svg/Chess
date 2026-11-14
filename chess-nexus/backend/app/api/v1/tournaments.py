from fastapi import APIRouter
from typing import List, Dict, Any

router = APIRouter(prefix="/tournaments", tags=["Tournaments"])

MOCK_TOURNAMENTS: List[Dict[str, Any]] = [
    {
        "id": "tour-blitz-01",
        "name": "Grandmaster Blitz Invitational",
        "format": "Swiss",
        "time_control": "3+2 Blitz",
        "total_rounds": 7,
        "current_round": 4,
        "status": "live",
        "spectators": 2840,
        "prize_pool": "$25,000 USD",
        "standings": [
            {"rank": 1, "title": "GM", "name": "Magnus Carlsen", "flag": "🇳🇴", "rating": 2882, "score": "3.5 / 4.0", "sb": 14.5},
            {"rank": 2, "title": "GM", "name": "Hikaru Nakamura", "flag": "🇺🇸", "rating": 2875, "score": "3.5 / 4.0", "sb": 13.8},
            {"rank": 3, "title": "GM", "name": "Alireza Firouzja", "flag": "🇫🇷", "rating": 2811, "score": "3.0 / 4.0", "sb": 12.2},
            {"rank": 4, "title": "GM", "name": "Gukesh D", "flag": "🇮🇳", "rating": 2798, "score": "3.0 / 4.0", "sb": 11.5},
            {"rank": 5, "title": "IM", "name": "Nikolai Vance", "flag": "🇳🇴", "rating": 2045, "score": "2.5 / 4.0", "sb": 9.0}
        ]
    },
    {
        "id": "tour-arena-02",
        "name": "Midnight Bullet Arena",
        "format": "Arena",
        "time_control": "1+0 Bullet",
        "total_rounds": 1,
        "current_round": 1,
        "status": "upcoming",
        "spectators": 482,
        "prize_pool": "$5,000 USD",
        "standings": []
    }
]

@router.get("/")
async def list_tournaments():
    return {"tournaments": MOCK_TOURNAMENTS}

@router.get("/{tournament_id}")
async def get_tournament(tournament_id: str):
    for t in MOCK_TOURNAMENTS:
        if t["id"] == tournament_id:
            return t
    return MOCK_TOURNAMENTS[0]

