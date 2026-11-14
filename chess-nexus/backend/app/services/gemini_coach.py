import os
import json
import logging
import asyncio
from typing import Dict, Any, Optional
import chess
from app.core.config import settings

logger = logging.getLogger(__name__)

class GeminiAICoach:
    """
    Grandmaster AI Coach powered by Google Gemini API with instant offline fallback.
    Provides pedagogical, tactical, and strategic chess guidance in English and Telugu.
    """

    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key or settings.GEMINI_API_KEY
        self.client = None
        # Only initialize if explicitly provided and not in offline test mode
        if self.api_key and os.getenv("OFFLINE_MODE") != "1":
            try:
                from google import genai
                self.client = genai.Client(api_key=self.api_key)
            except Exception as e:
                logger.warning(f"Could not initialize GenAI client: {e}")

    async def explain_position(
        self,
        fen: str,
        move_history_san: list[str],
        evaluation_cp: int,
        best_move_uci: str,
        language: str = "en"
    ) -> Dict[str, Any]:
        """
        Generates tactical position commentary and instructional tips.
        Supports 'en' (English) and 'te' (Telugu).
        """
        board = chess.Board(fen)
        turn_str = "White" if board.turn == chess.WHITE else "Black"
        
        # Verify best move legality
        best_move_san = ""
        try:
            m = chess.Move.from_uci(best_move_uci)
            if m in board.legal_moves:
                best_move_san = board.san(m)
        except Exception:
            best_move_san = best_move_uci

        # If Gemini client is available and not in offline test mode, call Gemini
        if self.client and os.getenv("OFFLINE_MODE") != "1":
            try:
                prompt = f"""
                You are CHESS NEXUS Grandmaster Coach, a world-class chess mentor.
                Position FEN: {fen}
                Turn to move: {turn_str}
                Stockfish evaluation (centipawns): {evaluation_cp}
                Best calculated engine move: {best_move_san}
                Recent moves: {' '.join(move_history_san[-6:]) if move_history_san else 'Starting position'}
                Target language: {'Telugu (తెలుగు)' if language == 'te' else 'English'}

                Task:
                Explain the current critical imbalances, threats, and tactical motifs. 
                Explain WHY the best move ({best_move_san}) is recommended.
                Keep it concise (2-4 sentences), encouraging, and instructional.
                Return purely a JSON object with:
                {{
                    "theme": "Short tactical theme",
                    "explanation": "Clear instructional explanation in the target language",
                    "training_tip": "One actionable advice for improvement"
                }}
                """
                # Run with timeout to prevent network hang in sandboxed environments
                loop = asyncio.get_event_loop()
                response = await asyncio.wait_for(
                    loop.run_in_executor(
                        None,
                        lambda: self.client.models.generate_content(
                            model='gemini-2.5-flash',
                            contents=prompt
                        )
                    ),
                    timeout=3.0
                )
                raw_text = response.text.strip()
                if raw_text.startswith("```json"):
                    raw_text = raw_text[7:-3].strip()
                elif raw_text.startswith("```"):
                    raw_text = raw_text[3:-3].strip()
                data = json.loads(raw_text)
                data["best_move_san"] = best_move_san
                data["evaluation_cp"] = evaluation_cp
                return data
            except Exception as ex:
                logger.info(f"Using rule-based pedagogical fallback: {ex}")

        # Deterministic instant pedagogical fallback
        return self._generate_rule_based_explanation(
            board=board,
            turn=turn_str,
            evaluation_cp=evaluation_cp,
            best_move_san=best_move_san,
            language=language
        )

    def _generate_rule_based_explanation(
        self,
        board: chess.Board,
        turn: str,
        evaluation_cp: int,
        best_move_san: str,
        language: str
    ) -> Dict[str, Any]:
        """Provides verified instant chess pedagogical heuristics."""
        is_check = board.is_check()
        
        if language == "te":
            if is_check:
                theme = "కింగ్ పై దాడి (Check)"
                explanation = f"{turn} రాజు ప్రస్తుతం చెక్ లో ఉన్నాడు. రాజును కాపాడటానికి {best_move_san} మూవ్ ఉత్తమం."
                tip = "ఎల్లప్పుడూ ప్రత్యర్థి చెక్స్ మరియు క్యాప్చర్లను ముందుగా గమనించండి."
            elif abs(evaluation_cp) > 300:
                leader = "వైట్" if evaluation_cp > 0 else "బ్లాక్"
                theme = "మెటీరియల్ ఆధిపత్యం"
                explanation = f"{leader} గణనీయమైన మెటీరియల్ ఆధిక్యంలో ఉంది. ప్రత్యర్థి పీసులను ఎక్స్ఛేంజ్ చేసి ఎండ్‌గేమ్‌కు వెళ్లడం ఉత్తమ వ్యూహం."
                tip = "ఆధిక్యంలో ఉన్నప్పుడు పీసెస్ ఎక్స్ఛేంజ్ చేయండి, పాన్స్ కాదు."
            else:
                theme = "సెంట్రల్ కంట్రోల్ & డెవలప్‌మెంట్"
                explanation = f"ఈ పొజిషన్ చాలా సమానంగా ఉంది. {best_move_san} ఆడటం ద్వారా బోర్డు మధ్యభాగాన్ని నియంత్రించవచ్చు."
                tip = "మైనర్ పీసులను చురుకైన చతురస్రాలకు తరలించండి."
        else:
            if is_check:
                theme = "King Under Direct Check"
                explanation = f"{turn}'s King is in check. Defending the monarch with {best_move_san} neutralizes the immediate tactical threat."
                tip = "Calculate all forcing responses (checks, captures, threats) before committing."
            elif abs(evaluation_cp) > 300:
                leader = "White" if evaluation_cp > 0 else "Black"
                theme = "Decisive Advantage & Conversion"
                explanation = f"{leader} holds a decisive positional and material edge. Playing {best_move_san} consolidates control towards a winning endgame."
                tip = "When ahead in material, trade pieces—not pawns—to simplify the win."
            else:
                theme = "Strategic Tension & Center Control"
                explanation = f"The position is balanced with active maneuvering space. The move {best_move_san} stakes claim over vital central squares."
                tip = "Improve your least active piece and ensure King safety before launching an attack."

        return {
            "theme": theme,
            "explanation": explanation,
            "training_tip": tip,
            "best_move_san": best_move_san,
            "evaluation_cp": evaluation_cp
        }
