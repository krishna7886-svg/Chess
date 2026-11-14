import re
from typing import Optional, Dict, Any, List
import chess

class VoiceCommandParser:
    """
    Bi-lingual (English & Telugu) Chess Voice Intent & Command Parser.
    Handles homophone correction, disambiguation, and chess intent extraction.
    """

    ENGLISH_HOMOPHONES = {
        "one": "1", "won": "1", "first": "1",
        "two": "2", "too": "2", "to": "2", "second": "2",
        "three": "3", "tree": "3", "third": "3",
        "four": "4", "for": "4", "fore": "4", "fourth": "4",
        "five": "5", "fifth": "5",
        "six": "6", "sixth": "6",
        "seven": "7", "seventh": "7",
        "eight": "8", "ate": "8", "eighth": "8",
        "see": "c", "sea": "c",
        "bee": "b", "be": "b",
        "gee": "g",
        "ay": "a", "hey": "a",
        "dee": "d",
        "eff": "f",
        "aitch": "h",
        "knight": "n", "night": "n",
        "bishop": "b",
        "rook": "r",
        "queen": "q",
        "king": "k",
        "pawn": "p",
        "takes": "x", "captures": "x", "kills": "x"
    }

    TELUGU_KEYWORDS = {
        # Castling
        "కింగ్ సైడ్ కాసిల్": "castle_kingside",
        "రాజు వైపు కోట": "castle_kingside",
        "క్వీన్ సైడ్ కాసిల్": "castle_queenside",
        "రాణి వైపు కోట": "castle_queenside",
        # Actions
        "ఆడు": "play",
        "వెళ్ళు": "move",
        "తీసుకో": "take",
        "చంపు": "capture",
        "రద్దు చేయి": "undo",
        "వెనక్కి": "undo",
        "వివరించు": "explain",
        "విశ్లేషించు": "analyze",
        "లీగల్ మూవ్స్": "show_legal",
        "సాధ్యమయ్యే మూవ్స్": "show_legal",
        "రాజీనామా": "resign",
        "ఓటమి": "resign",
        # Pieces in Telugu
        "రాజు": "k",
        "రాణి": "q",
        "ఏనుగు": "r",
        "గుర్రం": "n",
        "మంత్రి": "b",
        "బంటు": "p"
    }

    @classmethod
    def clean_and_normalize(cls, raw_transcript: str) -> str:
        text = raw_transcript.lower().strip()
        # Remove filler punctuation
        text = re.sub(r"[,\.\?!;]", " ", text)
        words = text.split()
        normalized_words = []
        for w in words:
            if w in cls.ENGLISH_HOMOPHONES:
                normalized_words.append(cls.ENGLISH_HOMOPHONES[w])
            else:
                normalized_words.append(w)
        return " ".join(normalized_words)

    @classmethod
    def parse_intent(cls, raw_transcript: str, board: chess.Board) -> Dict[str, Any]:
        """
        Interprets spoken audio transcript and matches against active chess board legality.
        Returns:
            {
                "intent": "move" | "undo" | "explain" | "show_legal" | "resign" | "unknown",
                "uci": "e2e4" (if move),
                "san": "e4",
                "ambiguous": True/False,
                "candidate_moves": [...],
                "confidence": 0.0 - 1.0,
                "message": "Spoken description"
            }
        """
        raw_text = raw_transcript.strip().lower()

        # 1. System & Utility Intent Recognition (Telugu & English)
        if any(k in raw_text for k in ["undo", "takeback", "రద్దు చేయి", "వెనక్కి"]):
            return {"intent": "undo", "confidence": 0.95, "message": "Undoing last move"}

        if any(k in raw_text for k in ["resign", "forfeit", "surrender", "రాజీనామా", "ఓటమి ఒప్పుకో"]):
            return {"intent": "resign", "confidence": 0.98, "message": "Player resigns match"}

        if any(k in raw_text for k in ["explain", "coach", "analysis", "వివరించు", "సలహా", "విశ్లేషించు"]):
            return {"intent": "explain", "confidence": 0.92, "message": "Requesting GM Coach explanation"}

        if any(k in raw_text for k in ["legal", "valid moves", "show moves", "లీగల్ మూవ్స్"]):
            return {"intent": "show_legal", "confidence": 0.90, "message": "Displaying legal candidate moves"}

        # 2. Castling Command
        if any(k in raw_text for k in ["castle kingside", "short castle", "castle king side", "రాజు వైపు కోట", "o-o"]):
            uci_castle = "e1g1" if board.turn == chess.WHITE else "e8g8"
            move = chess.Move.from_uci(uci_castle)
            if move in board.legal_moves:
                return {
                    "intent": "move",
                    "uci": uci_castle,
                    "san": "O-O",
                    "ambiguous": False,
                    "confidence": 0.98,
                    "message": "Kingside castling executed"
                }

        if any(k in raw_text for k in ["castle queenside", "long castle", "castle queen side", "రాణి వైపు కోట", "o-o-o"]):
            uci_castle = "e1c1" if board.turn == chess.WHITE else "e8c8"
            move = chess.Move.from_uci(uci_castle)
            if move in board.legal_moves:
                return {
                    "intent": "move",
                    "uci": uci_castle,
                    "san": "O-O-O",
                    "ambiguous": False,
                    "confidence": 0.98,
                    "message": "Queenside castling executed"
                }

        # 3. Piece Move Interpretation
        cleaned = cls.clean_and_normalize(raw_text)
        # Check for standard target square match (e.g. e4, f3, d5, c6)
        square_match = re.search(r"([a-h][1-8])", cleaned.replace(" ", ""))
        if not square_match:
            # Check for space separated square (e.g. "e 4")
            square_match = re.search(r"([a-h])\s*([1-8])", cleaned)
            if square_match:
                target_sq_str = square_match.group(1) + square_match.group(2)
            else:
                return {
                    "intent": "unknown",
                    "confidence": 0.0,
                    "message": f"Could not identify target square from: '{raw_transcript}'"
                }
        else:
            target_sq_str = square_match.group(1)

        target_square = chess.parse_square(target_sq_str)

        # Detect intended piece type
        piece_symbol = None
        for word in cleaned.split():
            if word in ["n", "knight", "గుర్రం"]:
                piece_symbol = chess.KNIGHT
            elif word in ["b", "bishop", "మంత్రి"]:
                piece_symbol = chess.BISHOP
            elif word in ["r", "rook", "ఏనుగు"]:
                piece_symbol = chess.ROOK
            elif word in ["q", "queen", "రాణి"]:
                piece_symbol = chess.QUEEN
            elif word in ["k", "king", "రాజు"]:
                piece_symbol = chess.KING

        # Scan all legal moves ending on the target square
        candidate_moves = [m for m in board.legal_moves if m.to_square == target_square]

        if piece_symbol:
            candidate_moves = [m for m in candidate_moves if board.piece_at(m.from_square).piece_type == piece_symbol]
        else:
            # If no piece mentioned and pawn move exists, prefer pawn
            pawn_candidates = [m for m in candidate_moves if board.piece_at(m.from_square).piece_type == chess.PAWN]
            if len(pawn_candidates) == 1:
                candidate_moves = pawn_candidates

        # Disambiguate if multiple candidates
        if len(candidate_moves) == 1:
            chosen = candidate_moves[0]
            san = board.san(chosen)
            return {
                "intent": "move",
                "uci": chosen.uci(),
                "san": san,
                "ambiguous": False,
                "confidence": 0.95,
                "message": f"Move {san} confirmed"
            }
        elif len(candidate_moves) > 1:
            san_candidates = [board.san(m) for m in candidate_moves]
            return {
                "intent": "move",
                "ambiguous": True,
                "candidate_moves": [m.uci() for m in candidate_moves],
                "candidate_sans": san_candidates,
                "confidence": 0.60,
                "message": f"Multiple pieces can move to {target_sq_str}: {', '.join(san_candidates)}. Please specify origin file or piece."
            }

        return {
            "intent": "unknown",
            "confidence": 0.1,
            "message": f"No legal move found to {target_sq_str} in current position"
        }

