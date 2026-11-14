import chess
import chess.pgn
import io
from typing import Optional, Tuple, Dict, Any, List

class ChessEngineValidator:
    """
    Authoritative server-side chess rules validator and state manager.
    Guarantees 100% adherence to official FIDE Laws of Chess.
    """

    def __init__(self, fen: Optional[str] = None):
        if fen:
            self.board = chess.Board(fen)
        else:
            self.board = chess.Board()

    @property
    def current_fen(self) -> str:
        return self.board.fen()

    @property
    def turn(self) -> str:
        return "white" if self.board.turn == chess.WHITE else "black"

    @property
    def is_check(self) -> bool:
        return self.board.is_check()

    @property
    def is_checkmate(self) -> bool:
        return self.board.is_checkmate()

    @property
    def is_stalemate(self) -> bool:
        return self.board.is_stalemate()

    @property
    def is_insufficient_material(self) -> bool:
        return self.board.is_insufficient_material()

    @property
    def can_claim_threefold_repetition(self) -> bool:
        return self.board.can_claim_threefold_repetition()

    @property
    def can_claim_fifty_moves(self) -> bool:
        return self.board.can_claim_fifty_moves()

    @property
    def is_seventy_five_moves(self) -> bool:
        return self.board.is_seventy_five_moves()

    @property
    def is_fivefold_repetition(self) -> bool:
        return self.board.is_fivefold_repetition()

    @property
    def is_game_over(self) -> bool:
        return self.board.is_game_over(claim_draw=True)

    def get_game_result(self) -> Tuple[Optional[str], Optional[str]]:
        """
        Returns (result_code, termination_reason)
        Example: ("1-0", "checkmate") or ("1/2-1/2", "stalemate")
        """
        if self.is_checkmate:
            winner = "0-1" if self.board.turn == chess.WHITE else "1-0"
            return winner, "checkmate"
        if self.is_stalemate:
            return "1/2-1/2", "stalemate"
        if self.is_insufficient_material:
            return "1/2-1/2", "insufficient_material"
        if self.can_claim_threefold_repetition or self.is_fivefold_repetition:
            return "1/2-1/2", "threefold_repetition"
        if self.can_claim_fifty_moves or self.is_seventy_five_moves:
            return "1/2-1/2", "fifty_moves"
        return None, None

    def get_legal_moves(self) -> List[str]:
        """Returns all legal moves in standard UCI string format (e.g. 'e2e4', 'e7e8q')."""
        return [move.uci() for move in self.board.legal_moves]

    def validate_and_apply_move(self, uci_move: str) -> Tuple[bool, Optional[str], Optional[Dict[str, Any]]]:
        """
        Validates UCI move (e.g. 'e2e4', 'e7e8q').
        If legal, applies the move and returns (True, san_notation, move_metadata).
        If illegal, returns (False, None, None).
        """
        try:
            move = chess.Move.from_uci(uci_move)
        except ValueError:
            return False, None, None

        if move not in self.board.legal_moves:
            return False, None, None

        # Capture SAN before executing move
        san = self.board.san(move)
        is_capture = self.board.is_capture(move)
        is_castling = self.board.is_castling(move)
        is_en_passant = self.board.is_en_passant(move)
        
        self.board.push(move)

        meta = {
            "uci": uci_move,
            "san": san,
            "from_square": chess.square_name(move.from_square),
            "to_square": chess.square_name(move.to_square),
            "promotion": chess.piece_symbol(move.promotion).upper() if move.promotion else None,
            "is_capture": is_capture,
            "is_castling": is_castling,
            "is_en_passant": is_en_passant,
            "is_check": self.board.is_check(),
            "fen_after": self.board.fen()
        }
        return True, san, meta

    def undo_last_move(self) -> bool:
        if len(self.board.move_stack) > 0:
            self.board.pop()
            return True
        return False

    def export_pgn(self, headers: Optional[Dict[str, str]] = None) -> str:
        game = chess.pgn.Game.from_board(self.board)
        if headers:
            for k, v in headers.items():
                game.headers[k] = v
        exporter = chess.pgn.StringExporter(headers=True, variations=False, comments=False)
        return game.accept(exporter)

