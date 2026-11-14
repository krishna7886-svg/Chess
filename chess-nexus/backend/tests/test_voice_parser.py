import pytest
import chess
from app.services.voice_parser import VoiceCommandParser

def test_english_pawn_move():
    board = chess.Board()
    res = VoiceCommandParser.parse_intent("play e 4", board)
    assert res["intent"] == "move"
    assert res["uci"] == "e2e4"
    assert res["san"] == "e4"
    assert not res["ambiguous"]

def test_english_homophone_knight():
    board = chess.Board()
    # "night to f three" -> Nf3
    res = VoiceCommandParser.parse_intent("night to f three", board)
    assert res["intent"] == "move"
    assert res["uci"] == "g1f3"
    assert res["san"] == "Nf3"

def test_castling_intent():
    board = chess.Board("rnbqk2r/pppp1ppp/5n2/2b1p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 4 4")
    res = VoiceCommandParser.parse_intent("castle kingside", board)
    assert res["intent"] == "move"
    assert res["uci"] == "e1g1"
    assert res["san"] == "O-O"

def test_telugu_system_commands():
    board = chess.Board()
    res_undo = VoiceCommandParser.parse_intent("నా మూవ్ రద్దు చేయి", board)
    assert res_undo["intent"] == "undo"

    res_resign = VoiceCommandParser.parse_intent("నేను రాజీనామా చేస్తున్నాను", board)
    assert res_resign["intent"] == "resign"

    res_explain = VoiceCommandParser.parse_intent("ఈ పొజిషన్ వివరించు", board)
    assert res_explain["intent"] == "explain"

