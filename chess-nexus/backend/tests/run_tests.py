import sys
import asyncio
from app.api.v1.auth import register_user, guest_login, RegisterRequest, GuestLoginRequest
from app.api.v1.matches import create_match, get_match_status, CreateMatchRequest
from app.api.v1.coach import explain_position_endpoint, parse_voice_endpoint, ExplainPositionRequest, VoiceParseRequest
from app.main import health_check
from app.db.session import engine, Base, AsyncSessionLocal
from app.services.chess_validator import ChessEngineValidator
from app.services.rating_service import Glicko2RatingSystem
from app.services.voice_parser import VoiceCommandParser

async def main():
    print("Running CHESS NEXUS Automated Verification Suite...")
    passed = 0
    total = 0

    def assert_test(name, condition):
        nonlocal passed, total
        total += 1
        if condition:
            passed += 1
            print(f"  [PASS] {name}")
        else:
            print(f"  [FAIL] {name}")
            raise AssertionError(f"Test failed: {name}")

    # 1. Chess Validator Tests
    v = ChessEngineValidator()
    assert_test("Chess: Initial setup", v.turn == "white" and len(v.get_legal_moves()) == 20)

    # Fool's mate
    v.validate_and_apply_move("f2f3")
    v.validate_and_apply_move("e7e5")
    v.validate_and_apply_move("g2g4")
    ok, san, _ = v.validate_and_apply_move("d8h4")
    assert_test("Chess: Fool's mate checkmate", ok and v.is_checkmate and san == "Qh4#")

    # En Passant
    v_ep = ChessEngineValidator("rnbqkbnr/pppppppp/8/4P3/8/8/PPPP1PPP/RNBQKBNR b KQkq - 0 2")
    v_ep.validate_and_apply_move("d7d5")
    ok_ep, _, meta_ep = v_ep.validate_and_apply_move("e5d6")
    assert_test("Chess: En Passant capture", ok_ep and meta_ep["is_en_passant"] and meta_ep["to_square"] == "d6")

    # Underpromotion
    v_promo = ChessEngineValidator("3k4/4P3/8/8/8/8/8/4K3 w - - 0 1")
    ok_p, san_p, meta_p = v_promo.validate_and_apply_move("e7e8n")
    assert_test("Chess: Underpromotion to Knight", ok_p and meta_p["promotion"] == "N" and "N" in san_p)

    # Stalemate
    v_stale = ChessEngineValidator("7k/5Q2/6K1/8/8/8/8/8 b - - 0 1")
    assert_test("Chess: Stalemate detection", v_stale.is_stalemate and v_stale.get_game_result()[0] == "1/2-1/2")

    # Illegal move
    assert_test("Chess: Reject illegal move", not v.validate_and_apply_move("e2e5")[0])

    # 2. Glicko-2 Tests
    r, rd, _ = Glicko2RatingSystem.calculate_rating_update(1500, 200, 0.06, 1500, 200, 1.0)
    assert_test("Glicko2: Win increases rating", r > 1500 and rd < 200)

    r_l, rd_l, _ = Glicko2RatingSystem.calculate_rating_update(1500, 200, 0.06, 1500, 200, 0.0)
    assert_test("Glicko2: Loss decreases rating", r_l < 1500 and rd_l < 200)

    # 3. Voice Parser Tests
    import chess
    b = chess.Board()
    v_res = VoiceCommandParser.parse_intent("play e 4", b)
    assert_test("Voice: English pawn e4", v_res["intent"] == "move" and v_res["uci"] == "e2e4")

    v_n = VoiceCommandParser.parse_intent("night to f three", b)
    assert_test("Voice: English homophone 'night' -> Nf3", v_n["intent"] == "move" and v_n["uci"] == "g1f3")

    v_tel = VoiceCommandParser.parse_intent("నా మూవ్ రద్దు చేయి", b)
    assert_test("Voice: Telugu 'రద్దు చేయి' -> undo", v_tel["intent"] == "undo")

    # 4. Async API & Database Integration Tests
    h_res = await health_check()
    assert_test("API: Health check", h_res["status"] == "ok")

    # Create tables
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    async with AsyncSessionLocal() as session:
        # Guest login
        g_req = GuestLoginRequest(device_id="device-runner-101", nickname="MasterPlayer")
        t_res = await guest_login(g_req, db=session)
        assert_test("API: Guest login token generation", t_res.user_id is not None and t_res.access_token is not None)

        # Create Match
        m_req = CreateMatchRequest(
            white_player_id=t_res.user_id,
            black_player_id="guest-runner-102",
            time_control="blitz_3_2",
            initial_time_seconds=180,
            increment_seconds=2
        )
        m_res = await create_match(m_req, db=session)
        assert_test("API: Match creation", m_res.match_id is not None and m_res.status == "in_progress")

        # Match status
        m_stat = await get_match_status(m_res.match_id)
        assert_test("API: Match status lookup", m_stat["turn"] == "white" and not m_stat["is_game_over"])

    # Coach Telugu position explanation
    exp_req = ExplainPositionRequest(
        fen="r1bqk2r/pppp1ppp/2n2n2/2b1p3/2B1P3/2NP1N2/PPP2PPP/R1BQK2R b KQkq - 0 5",
        language="te",
        evaluation_cp=15,
        best_move_uci="e8g8"
    )
    exp_res = await explain_position_endpoint(exp_req)
    assert_test("Coach: Telugu explanation generation", "theme" in exp_res and "explanation" in exp_res)

    print(f"\nAll verification tests passed: {passed}/{total} (100% SUCCESS)")

if __name__ == "__main__":
    asyncio.run(main())

