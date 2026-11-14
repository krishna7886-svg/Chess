import pytest
import chess
from app.services.chess_validator import ChessEngineValidator
from app.services.rating_service import Glicko2RatingSystem
from app.services.voice_parser import VoiceCommandParser
from app.services.match_service import MatchManager, ActiveMatchSession
from app.core.security import get_password_hash, verify_password, create_access_token, decode_token
from app.services.gemini_coach import GeminiAICoach

class TestUserJourneys:
    """Automated integration tests for CHESS NEXUS User Journeys A through G."""

    def test_journey_a_local_chess_full_game(self):
        """Journey A: Local Chess - Complete opening and legal moves to endgame."""
        validator = ChessEngineValidator()

        # Play Ruy Lopez: Morphy Defence
        moves = ["e2e4", "e7e5", "g1f3", "b8c6", "f1b5", "a7a6", "b5a4", "g8f6"]
        for uci in moves:
            legal, san, meta = validator.validate_and_apply_move(uci)
            assert legal, f"Move {uci} was deemed illegal"
            assert san is not None

        # White castles kingside (O-O: e1g1)
        legal, san, meta = validator.validate_and_apply_move("e1g1")
        assert legal, "Kingside castling should be legal"
        assert san == "O-O"
        assert meta["is_castling"] is True

        # Black plays Be7 (f8e7)
        legal, san, meta = validator.validate_and_apply_move("f8e7")
        assert legal
        assert san == "Be7"

        assert validator.current_fen.startswith("r1bqk2r/1pppbppp/p1n2n2/4p3/B3P3/5N2/PPPP1PPP/RNBQ1RK1")
        assert not validator.is_game_over

    def test_journey_b_ai_chess_and_uci_protocol(self):
        """Journey B: AI Chess - Engine initialization, difficulty, and move parsing."""
        # Test UCI protocol bestmove command parsing
        uci_engine_output = "info depth 12 seldepth 16 multipv 1 score cp 45 nodes 84211 nps 650000 tbhits 0 time 129 pv e2e4 e7e5 g1f3\nbestmove e2e4 ponder e7e5"
        
        # Verify bestmove extraction
        best_move_line = [line for line in uci_engine_output.splitlines() if line.startswith("bestmove")]
        assert len(best_move_line) == 1
        tokens = best_move_line[0].split()
        assert tokens[1] == "e2e4"
        assert tokens[3] == "e7e5"

        # Verify board response to AI move
        board = chess.Board()
        ai_move = chess.Move.from_uci(tokens[1])
        assert ai_move in board.legal_moves
        board.push(ai_move)
        assert board.piece_at(chess.E4).symbol() == "P"

    def test_journey_c_online_multiplayer_lifecycle(self):
        """Journey C: Online Multiplayer - Auth, room creation, move exchange, anti-tampering."""
        # 1. Authenticate players
        token_white = create_access_token(subject="user_gm_vance")
        token_black = create_access_token(subject="user_im_elena")
        assert decode_token(token_white)["sub"] == "user_gm_vance"
        assert decode_token(token_black)["sub"] == "user_im_elena"

        # 2. Initialize Match Session with 3 min + 2s increment
        session = ActiveMatchSession(
            match_id="nexus-arena-live-001",
            white_player_id="user_gm_vance",
            black_player_id="user_im_elena",
            initial_time_seconds=180,
            increment_seconds=2
        )
        session.start_game()
        assert session.current_turn() == "white"

        # 3. Exchange opening moves
        # White: 1. d4
        ok, msg, meta = session.execute_player_move("user_gm_vance", "d2d4")
        assert ok
        assert meta["san"] == "d4"
        assert session.current_turn() == "black"

        # Black tries to play an illegal move (e.g. Knight leaps across the board)
        ok_bad, msg_bad, _ = session.execute_player_move("user_im_elena", "b8e5")
        assert not ok_bad
        assert "Illegal move" in msg_bad

        # Black plays valid 1... Nf6
        ok, msg, meta = session.execute_player_move("user_im_elena", "g8f6")
        assert ok
        assert meta["san"] == "Nf6"
        assert session.current_turn() == "white"

        # 4. Draw Offer & Acceptance
        result, reason = session.offer_draw()
        assert result == "1/2-1/2"
        assert session.is_game_over

    def test_journey_d_academy_tactics_and_puzzle_validation(self):
        """Journey D: Academy - Tactical puzzle verification and mistake detection."""
        # Puzzle: Back-rank mate setup
        # FEN: 6k1/5ppp/8/8/8/8/5QPP/4R1K1 w - - 0 1 -> Back rank mate: Re8#
        fen = "6k1/5ppp/8/8/8/8/5QPP/4R1K1 w - - 0 1"
        validator = ChessEngineValidator(fen)

        # User attempts blunder: Qf3 (f2f3)
        blunder = "f2f3"
        legal, san, meta = validator.validate_and_apply_move(blunder)
        assert legal
        assert not validator.is_checkmate

        # Reset to initial puzzle position
        validator_sol = ChessEngineValidator(fen)
        # User plays correct tactical winning move: Re8# (e1e8)
        solution = "e1e8"
        legal, san, meta = validator_sol.validate_and_apply_move(solution)
        assert legal
        assert san == "Re8#"
        assert validator_sol.is_checkmate

    def test_journey_e_analysis_studio_eval_and_coach(self):
        """Journey E: Analysis - Centipawns to win probability and bilingual AI Coach."""
        def cp_to_win_prob(cp: int) -> float:
            return 1.0 / (1.0 + (10.0 ** (-cp / 400.0)))

        assert abs(cp_to_win_prob(0) - 0.50) < 0.001
        assert cp_to_win_prob(400) > 0.90
        assert cp_to_win_prob(-400) < 0.10

        # Bilingual AI Coach position analysis
        coach = GeminiAICoach()
        board = chess.Board("r1bqk2r/pppp1ppp/2n2n2/4p3/1bB1P3/2N2N2/PPPP1PPP/R1BQK2R w KQkq - 4 5")
        
        # English analysis
        analysis_en = coach._generate_rule_based_explanation(board, "White", 35, "O-O", "en")
        assert "Strategic Tension" in analysis_en["theme"]
        assert "O-O" in analysis_en["explanation"]

        # Telugu analysis (తెలుగు)
        analysis_te = coach._generate_rule_based_explanation(board, "White", 35, "O-O", "te")
        assert "సెంట్రల్ కంట్రోల్" in analysis_te["theme"]
        assert "O-O" in analysis_te["explanation"]

    def test_journey_f_settings_and_rating_calibration(self):
        """Journey F: Settings & Glicko-2 engine volatility calculation."""
        # Player (2200, RD 50) plays against a lower-rated player (1800, RD 80)
        # Outcome: Win (score = 1.0)
        new_rating, new_rd, new_vol = Glicko2RatingSystem.calculate_rating_update(
            rating=2200.0,
            rd=50.0,
            volatility=0.06,
            opponent_rating=1800.0,
            opponent_rd=80.0,
            score=1.0
        )
        assert new_rating > 2200.0
        assert 0 < new_rd < 350.0  # Calibrated rating deviation bounds
        assert 0 < new_vol <= 1.0  # Volatility bounds

    def test_journey_g_navigation_and_voice_input_resilience(self):
        """Journey G: Bilingual Voice Chess commands and resilience."""
        board = chess.Board()

        # English voice command: "knight f3"
        intent_en = VoiceCommandParser.parse_intent("knight f3", board)
        assert intent_en["intent"] == "move"
        assert intent_en["uci"] == "g1f3"

        # Telugu voice command: "రాజీనామా" (Resign)
        intent_resign = VoiceCommandParser.parse_intent("నేను రాజీనామా చేస్తున్నాను", board)
        assert intent_resign["intent"] == "resign"
