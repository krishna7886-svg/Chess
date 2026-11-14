import pytest
from app.services.chess_validator import ChessEngineValidator

def test_initial_board_setup():
    validator = ChessEngineValidator()
    assert validator.turn == "white"
    assert not validator.is_check
    assert not validator.is_game_over
    assert len(validator.get_legal_moves()) == 20

def test_fool_mate_checkmate():
    validator = ChessEngineValidator()
    # 1. f3 e5 2. g4 Qh4#
    assert validator.validate_and_apply_move("f2f3")[0]
    assert validator.validate_and_apply_move("e7e5")[0]
    assert validator.validate_and_apply_move("g2g4")[0]
    ok, san, meta = validator.validate_and_apply_move("d8h4")
    assert ok
    assert san == "Qh4#"
    assert validator.is_checkmate
    assert validator.is_game_over
    result, reason = validator.get_game_result()
    assert result == "0-1"
    assert reason == "checkmate"

def test_en_passant_capture():
    # Setup board where white pawn is on e5, all 8 black pawns on rank 7:
    fen = "rnbqkbnr/pppppppp/8/4P3/8/8/PPPP1PPP/RNBQKBNR b KQkq - 0 2"
    validator = ChessEngineValidator(fen)
    ok, _, _ = validator.validate_and_apply_move("d7d5")
    assert ok
    # White en passant capture e5d6
    ok_ep, san, meta = validator.validate_and_apply_move("e5d6")
    assert ok_ep
    assert meta["is_en_passant"] is True
    assert meta["to_square"] == "d6"

def test_pawn_underpromotion():
    # Setup board with black king on d8, white pawn on e7, promotes to knight on e8
    fen = "3k4/4P3/8/8/8/8/8/4K3 w - - 0 1"
    validator = ChessEngineValidator(fen)
    ok, san, meta = validator.validate_and_apply_move("e7e8n")
    assert ok
    assert meta["promotion"] == "N"
    assert "N" in san

def test_stalemate_detection():
    # Classic stalemate position: Black king on h8, White Queen on f7, White King on g6
    fen = "7k/5Q2/6K1/8/8/8/8/8 b - - 0 1"
    validator = ChessEngineValidator(fen)
    assert validator.is_stalemate
    assert validator.is_game_over
    result, reason = validator.get_game_result()
    assert result == "1/2-1/2"
    assert reason == "stalemate"

def test_illegal_move_rejection():
    validator = ChessEngineValidator()
    # Attempt moving pawn from e2 to e5 on turn 1 (impossible)
    ok, san, meta = validator.validate_and_apply_move("e2e5")
    assert not ok
    assert san is None
