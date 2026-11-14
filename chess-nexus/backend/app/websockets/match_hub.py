import json
import logging
from typing import Dict, Set
from fastapi import WebSocket, WebSocketDisconnect
from app.services.match_service import MatchManager

logger = logging.getLogger(__name__)

class MatchHub:
    """
    Manages live WebSocket channels for multiplayer match synchronization.
    Handles player reconnections, move broadcasts, and clock heartbeat syncs.
    """

    def __init__(self):
        # match_id -> set of active WebSockets
        self.active_rooms: Dict[str, Set[WebSocket]] = {}

    async def connect(self, match_id: str, websocket: WebSocket):
        await websocket.accept()
        if match_id not in self.active_rooms:
            self.active_rooms[match_id] = set()
        self.active_rooms[match_id].add(websocket)
        logger.info(f"Client connected to match {match_id}. Room size: {len(self.active_rooms[match_id])}")

    def disconnect(self, match_id: str, websocket: WebSocket):
        if match_id in self.active_rooms:
            self.active_rooms[match_id].discard(websocket)
            if not self.active_rooms[match_id]:
                del self.active_rooms[match_id]
        logger.info(f"Client disconnected from match {match_id}")

    async def broadcast_to_room(self, match_id: str, message: dict):
        if match_id in self.active_rooms:
            payload = json.dumps(message)
            disconnected = set()
            for ws in self.active_rooms[match_id]:
                try:
                    await ws.send_text(payload)
                except Exception as e:
                    logger.warning(f"Error sending message to websocket: {e}")
                    disconnected.add(ws)
            for dead_ws in disconnected:
                self.disconnect(match_id, dead_ws)

    async def handle_client_message(self, match_id: str, websocket: WebSocket, data: str):
        try:
            msg = json.loads(data)
        except json.JSONDecodeError:
            await websocket.send_text(json.dumps({"type": "error", "message": "Invalid JSON format"}))
            return

        msg_type = msg.get("type")
        player_id = msg.get("player_id", "guest")
        session = MatchManager.get_or_create_session(match_id)

        if msg_type == "sync_request":
            w_time, b_time = session.get_clocks()
            await websocket.send_text(json.dumps({
                "type": "match_sync",
                "match_id": match_id,
                "fen": session.engine.current_fen,
                "turn": session.current_turn(),
                "white_time_ms": w_time,
                "black_time_ms": b_time,
                "moves": session.move_history_san,
                "is_game_over": session.is_game_over,
                "result": session.result,
                "termination_reason": session.termination_reason
            }))

        elif msg_type == "move":
            uci = msg.get("uci")
            if not uci:
                await websocket.send_text(json.dumps({"type": "move_rejected", "reason": "Missing uci parameter"}))
                return

            success, reason, meta = session.execute_player_move(player_id, uci)
            if success:
                w_time, b_time = session.get_clocks()
                broadcast_payload = {
                    "type": "move_played",
                    "match_id": match_id,
                    "uci": uci,
                    "san": meta["san"],
                    "fen": meta["fen_after"],
                    "turn": session.current_turn(),
                    "white_time_ms": w_time,
                    "black_time_ms": b_time,
                    "is_check": meta["is_check"],
                    "is_game_over": meta["is_game_over"],
                    "result": meta.get("result"),
                    "termination_reason": meta.get("termination_reason")
                }
                await self.broadcast_to_room(match_id, broadcast_payload)
            else:
                await websocket.send_text(json.dumps({
                    "type": "move_rejected",
                    "reason": reason,
                    "authoritative_fen": session.engine.current_fen
                }))

        elif msg_type == "resign":
            result, reason = session.resign(player_id)
            await self.broadcast_to_room(match_id, {
                "type": "game_over",
                "match_id": match_id,
                "result": result,
                "termination_reason": reason,
                "resigned_by": player_id
            })

        elif msg_type == "draw_offer":
            await self.broadcast_to_room(match_id, {
                "type": "draw_offered",
                "match_id": match_id,
                "by_player_id": player_id
            })

        elif msg_type == "draw_accept":
            result, reason = session.offer_draw()
            await self.broadcast_to_room(match_id, {
                "type": "game_over",
                "match_id": match_id,
                "result": result,
                "termination_reason": reason
            })

match_hub = MatchHub()

