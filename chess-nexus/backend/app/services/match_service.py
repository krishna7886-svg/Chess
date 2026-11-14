import time
from typing import Dict, Any, Optional, Tuple
from app.services.chess_validator import ChessEngineValidator

class ActiveMatchSession:
    """
    In-memory / Redis cache match session with authoritative timing and state validation.
    """

    def __init__(
        self,
        match_id: str,
        white_player_id: str,
        black_player_id: str,
        initial_time_seconds: int,
        increment_seconds: int = 0
    ):
        self.match_id = match_id
        self.white_player_id = white_player_id
        self.black_player_id = black_player_id
        self.initial_time_seconds = initial_time_seconds
        self.increment_seconds = increment_seconds
        
        self.engine = ChessEngineValidator()
        self.move_history_san: list[str] = []
        self.move_history_uci: list[str] = []
        
        # Milliseconds clock balance
        self.white_time_ms = initial_time_seconds * 1000
        self.black_time_ms = initial_time_seconds * 1000
        self.increment_ms = increment_seconds * 1000
        
        self.last_move_timestamp_ms: Optional[int] = None
        self.is_game_over = False
        self.result: Optional[str] = None
        self.termination_reason: Optional[str] = None

    def start_game(self) -> None:
        self.last_move_timestamp_ms = int(time.time() * 1000)

    def current_turn(self) -> str:
        return self.engine.turn

    def get_clocks(self) -> Tuple[int, int]:
        """Returns (white_time_ms, black_time_ms) accounting for live elapsed time."""
        if self.is_game_over or self.last_move_timestamp_ms is None:
            return max(0, self.white_time_ms), max(0, self.black_time_ms)

        elapsed = int(time.time() * 1000) - self.last_move_timestamp_ms
        if self.current_turn() == "white":
            live_white = self.white_time_ms - elapsed
            return max(0, live_white), self.black_time_ms
        else:
            live_black = self.black_time_ms - elapsed
            return self.white_time_ms, max(0, live_black)

    def check_timeout(self) -> Optional[str]:
        """Returns loser color if a clock expired ('white' or 'black')."""
        w_time, b_time = self.get_clocks()
        if w_time <= 0:
            self.is_game_over = True
            self.result = "0-1"
            self.termination_reason = "timeout"
            return "white"
        if b_time <= 0:
            self.is_game_over = True
            self.result = "1-0"
            self.termination_reason = "timeout"
            return "black"
        return None

    def execute_player_move(self, player_id: str, uci_move: str) -> Tuple[bool, str, Dict[str, Any]]:
        """
        Validates player turn, checks timeouts, validates chess move,
        deducts elapsed time, adds Fischer increment, and switches turns.
        """
        if self.is_game_over:
            return False, "Match is already completed", {}

        # Check for timeout before move
        timeout_loser = self.check_timeout()
        if timeout_loser:
            return False, f"Time forfeit by {timeout_loser}", {}

        # Validate player turn
        expected_player = self.white_player_id if self.current_turn() == "white" else self.black_player_id
        if player_id != expected_player:
            return False, "Not your turn", {}

        # Deduct time from active player
        now_ms = int(time.time() * 1000)
        if self.last_move_timestamp_ms is not None:
            elapsed = now_ms - self.last_move_timestamp_ms
            if self.current_turn() == "white":
                self.white_time_ms = max(0, self.white_time_ms - elapsed) + self.increment_ms
            else:
                self.black_time_ms = max(0, self.black_time_ms - elapsed) + self.increment_ms

        self.last_move_timestamp_ms = now_ms

        # Validate & push chess move
        success, san, meta = self.engine.validate_and_apply_move(uci_move)
        if not success:
            return False, "Illegal move", {}

        self.move_history_san.append(san)
        self.move_history_uci.append(uci_move)

        # Check game end states
        if self.engine.is_game_over:
            self.is_game_over = True
            res, reason = self.engine.get_game_result()
            self.result = res
            self.termination_reason = reason

        meta["white_time_ms"] = self.white_time_ms
        meta["black_time_ms"] = self.black_time_ms
        meta["is_game_over"] = self.is_game_over
        meta["result"] = self.result
        meta["termination_reason"] = self.termination_reason
        return True, "Move applied successfully", meta

    def resign(self, player_id: str) -> Tuple[str, str]:
        self.is_game_over = True
        self.termination_reason = "resignation"
        if player_id == self.white_player_id:
            self.result = "0-1"
            return "0-1", "White resigned"
        else:
            self.result = "1-0"
            return "1-0", "Black resigned"

    def offer_draw(self) -> Tuple[str, str]:
        self.is_game_over = True
        self.result = "1/2-1/2"
        self.termination_reason = "agreement"
        return "1/2-1/2", "Draw agreed"

class MatchManager:
    """Singleton session registry for live matches."""
    _sessions: Dict[str, ActiveMatchSession] = {}

    @classmethod
    def get_or_create_session(
        cls,
        match_id: str,
        white_player_id: str = "guest_w",
        black_player_id: str = "guest_b",
        initial_time_seconds: int = 600,
        increment_seconds: int = 0
    ) -> ActiveMatchSession:
        if match_id not in cls._sessions:
            session = ActiveMatchSession(
                match_id=match_id,
                white_player_id=white_player_id,
                black_player_id=black_player_id,
                initial_time_seconds=initial_time_seconds,
                increment_seconds=increment_seconds
            )
            session.start_game()
            cls._sessions[match_id] = session
        return cls._sessions[match_id]

    @classmethod
    def get_session(cls, match_id: str) -> Optional[ActiveMatchSession]:
        return cls._sessions.get(match_id)

    @classmethod
    def remove_session(cls, match_id: str) -> None:
        cls._sessions.pop(match_id, None)

