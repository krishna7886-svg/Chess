import pytest
import chess
from app.services.chess_validator import ChessEngineValidator
from app.services.rating_service import Glicko2RatingSystem
from app.services.voice_parser import VoiceCommandParser
from app.services.match_service import MatchManager, ActiveMatchSession
from app.core.security import get_password_hash, verify_password, create_access_token, create_refresh_token, decode_token
from app.services.gemini_coach import GeminiAICoach

def test_security_jwt_cycle():
    password = "GrandmasterPassword2026!"
    hashed = get_password_hash(password)
    assert verify_password(password, hashed)
    assert not verify_password("WrongPassword", hashed)

    token = create_access_token(subject="user_12345")
    payload = decode_token(token)
    assert payload.get("sub") == "user_12345"
    assert payload.get("type") == "access"

def test_active_match_session_flow():
    session = ActiveMatchSession(
        match_id="test-match-999",
        white_player_id="player_white",
        black_player_id="player_black",
        initial_time_seconds=300,
        increment_seconds=2
    )
    session.start_game()
    assert session.current_turn() == "white"

    # White plays e4 (e2e4)
    ok_w, msg_w, meta_w = session.execute_player_move("player_white", "e2e4")
    assert ok_w
    assert meta_w["san"] == "e4"
    assert session.current_turn() == "black"

    # Attempting to move out of turn (White plays again) must be rejected
    ok_illegal, msg_illegal, _ = session.execute_player_move("player_white", "g1f3")
    assert not ok_illegal
    assert "Not your turn" in msg_illegal

    # Black plays e5 (e7e5)
    ok_b, msg_b, meta_b = session.execute_player_move("player_black", "e7e5")
    assert ok_b
    assert meta_b["san"] == "e5"
    assert session.current_turn() == "white"

def test_match_resignation():
    session = ActiveMatchSession(
        match_id="test-match-resign",
        white_player_id="player_white",
        black_player_id="player_black",
        initial_time_seconds=180
    )
    result, reason = session.resign("player_black")
    assert result == "1-0"
    assert reason == "Black resigned"
    assert session.is_game_over

def test_match_draw_agreement():
    session = ActiveMatchSession(
        match_id="test-match-draw",
        white_player_id="player_white",
        black_player_id="player_black",
        initial_time_seconds=180
    )
    result, reason = session.offer_draw()
    assert result == "1/2-1/2"
    assert reason == "Draw agreed"
    assert session.is_game_over

def test_coach_pedagogical_rules():
    coach = GeminiAICoach()
    board = chess.Board("rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1")
    exp_te = coach._generate_rule_based_explanation(board, "Black", 20, "e7e5", "te")
    assert "theme" in exp_te
    assert "e7e5" in exp_te["explanation"]
    assert "best_move_san" in exp_te

    exp_en = coach._generate_rule_based_explanation(board, "Black", 20, "e7e5", "en")
    assert "Center Control" in exp_en["theme"]
    assert "e7e5" in exp_en["explanation"]

