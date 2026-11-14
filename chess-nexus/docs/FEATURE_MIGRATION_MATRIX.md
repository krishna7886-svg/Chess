# CHESS NEXUS – FEATURE MIGRATION MATRIX

**Document Version:** 1.0.0  
**Status:** Architecture Decision Record (ADR)  

---

## 1. Migration Strategy Matrix

| Legacy Feature | Existing Source | Target Subsystem in CHESS NEXUS | Migration Strategy | Rationale & Architectural Gain |
| :--- | :--- | :--- | :--- | :--- |
| **Chessboard Rendering** | `index.html` (DOM `div.board`) | `lib/features/gameplay/presentation/widgets/nexus_board.dart` | **Replace** with Flutter CustomPainter + RepaintBoundary | Eliminates DOM thrashing; ensures 60/120 FPS hardware-accelerated animations and drag gestures. |
| **Piece Graphics** | Root PNG files (`*B.png`, `*W.png`) | `assets/pieces/classic/` & `assets/pieces/vector/` | **Preserve + Augment** | Preserves original visual aesthetic while adding scalable SVG pieces for modern Retina/OLED mobile screens. |
| **Sound Effects** | `Sounds/*.mp3` | `lib/core/services/audio_service.dart` | **Preserve + Modernize** | Integrates low-latency sound pool with volume dampening, audio focus management, and synchronized haptics. |
| **Chess Rules State** | `index.html` (Custom JS arrays) | `lib/features/chess_engine/domain/models/chess_game.dart` | **Replace** with strict, tested Chess Engine | Full FEN/PGN/SAN support, en passant, underpromotion, threefold repetition, 50-move rule, and insufficient material. |
| **AI Opponent** | `index.html`, `AI/index.html` (JS Minimax) | `lib/features/chess_engine/services/stockfish_engine.dart` | **Replace** with native Stockfish UCI isolate | Sub-millisecond true engine evaluation up to 3500+ ELO, zero UI-thread blocking, multi-PV analysis. |
| **Evaluation Bar** | `index.html:174`, `AI/index.html:149` | `lib/features/analysis/presentation/widgets/eval_bar.dart` | **Refactor & Calibrate** | Stockfish centipawn $\to$ win probability sigmoid curve: $W = \frac{100}{1 + 10^{-cp / 400}}$. |
| **Move Classification** | `AI/index.html:1400` | `lib/features/analysis/domain/move_classifier.dart` | **Replace** with Win-Rate Loss Model | Replaces arbitrary material steps with international standards: Brilliant, Best, Excellent, Good, Inaccuracy, Mistake, Blunder. |
| **Annotation Arrows** | `AI/index.html` (Canvas 2D) | `lib/features/gameplay/presentation/widgets/board_overlay_painter.dart` | **Refactor** for Mobile Gestures | Right-click mouse replaced with touch gestures (tap-drag with secondary touch or analysis mode toggle). |
| **Opening Explorer** | `index.html:325` (Static JS Dict) | `lib/features/openings/data/opening_repository.dart` | **Replace** with SQLite ECO Tree | Supports move transpositions, master game win percentages, and opening taxonomy across all 500 ECO codes. |
| **Voice Recognition** | `voice/index4.html` (Web Speech API) | `lib/features/coach/services/voice_service.dart` | **Replace** with Native Cross-Platform STT | Eliminates browser dependency; adds English and Telugu phonetic parsing; supports offline command recognition. |
| **Voice Announcements** | `voice/index4.html` (SpeechSynthesis) | `lib/core/services/tts_service.dart` | **Replace** with Native TTS engine | Natural spoken voice with speed and pitch control, native accent matching, and Telugu support. |
| **Multiplayer / Online** | `voice/index4.html` (PeerJS P2P) | `backend/app/services/match_service.py` (FastAPI + Redis + WS) | **Replace** with Authoritative Server | Server validates every move; prevents tampering; handles clock synchronization, reconnection, and matchmaking queues. |
| **Ratings System** | `AI/index.html:1063` (Basic Elo formula) | `backend/app/services/rating_service.py` (Glicko-2) | **Replace** with Glicko-2 | Tracks Rating ($R$), Rating Deviation ($RD$), and Volatility ($\sigma$) across Bullet, Blitz, Rapid, and Classical. |
| **Rice & Board Demo** | `2powerN.html` | `lib/features/academy/lessons/wheat_and_chessboard.dart` | **Archive & Integrate** | Adapted into Academy interactive chess history and mathematical puzzle lesson. |

---

## 2. Architecture Sign-Off
All legacy assets and useful concepts have been mapped to their production-grade counterparts in the modern `chess-nexus` ecosystem.

