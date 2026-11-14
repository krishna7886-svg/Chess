# CHESS NEXUS – FEATURE INVENTORY

**Document Version:** 1.0.0  
**Status:** Approved Specification Baseline  

---

## 1. Legacy Feature Inventory

| ID | Feature Name | Source File | Description in Legacy | Deficiencies Identified | Production Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **LEG-01** | 64-Square Board UI | `index.html` | Flexbox/CSS grid 8x8 squares | Rebuilds full DOM every move; no gesture/drag smoothness | **Replace** with Flutter CustomPainter + Interactive Board |
| **LEG-02** | Move Generation & Legality | `index.html` | Custom JS piece movement check | Missing en passant, underpromotion, 3-fold repetition, 50-move rule | **Replace** with strict, tested Chess Rules Engine |
| **LEG-03** | Local Two-Player (Pass & Play) | `index.html`, `AI/index.html` | Alternating turns on single screen | No clock pause confirmation, no board flip option on turn | **Preserve & Enhance** with orientation flip, clocks, sound |
| **LEG-04** | Minimax Computer Opponent | `index.html`, `AI/index.html` | Alpha-Beta minimax (depth 1-4) | Blocks UI thread; weak tactical depth; no blunder generation | **Replace** with Stockfish UCI background isolate |
| **LEG-05** | Opening Book Identification | `index.html`, `AI/index.html` | Static dictionary of ~50 PGN strings | Fragile exact matching; fails on move transposition | **Replace** with full ECO Opening Tree Database |
| **LEG-06** | Advantage / Evaluation Bar | `index.html`, `AI/index.html` | CSS height based on material diff | Material-only or shallow eval; inaccurate for tactical lines | **Replace** with Stockfish Centipawn & Win% Curve |
| **LEG-07** | Sound Effects | `Sounds/*.mp3` | HTML5 `Audio()` playback | Missing checkmate and game-end audio references; latency on mobile | **Preserve & Modernize** with native low-latency audio |
| **LEG-08** | Basic Chess Clock | `index.html`, `voice/index4.html` | `setInterval` timer decrement | Drifts on backgrounding; lacks Fischer increments | **Replace** with monotonic timestamp-based authoritative clock |
| **LEG-09** | Move Annotation & Arrows | `AI/index.html` | HTML5 2D Canvas right-click arrows | Mouse-only; no mobile gesture support | **Refactor** into touch gestures (two-finger drag, tap-hold) |
| **LEG-10** | Move Quality Classification | `AI/index.html` | Inaccuracy / Mistake / Blunder tags | Arbitrary static score delta | **Replace** with Stockfish win-percentage loss classification |
| **LEG-11** | Speech Recognition Moves | `voice/*.html` | `webkitSpeechRecognition` loop | English only; browser lock-in; homophone errors | **Replace** with Native STT + English/Telugu Intent Engine |
| **LEG-12** | Voice Move Announcement (TTS) | `voice/*.html` | `SpeechSynthesisUtterance` | Hardcoded robotic voice; breaks on backgrounding | **Replace** with Native TTS with multi-lingual audio voices |
| **LEG-13** | WebRTC Multiplayer | `voice/index4.html` | PeerJS direct browser-to-browser | Zero authentication; unverified move injection; no reconnect | **Replace** with FastAPI WebSocket + Redis Authoritative Server |
| **LEG-14** | Wheat-and-Chessboard Demo | `2powerN.html` | Exponential doubling algorithm | Standalone calculation script | **Archive** as Academy lesson content |

---

## 2. CHESS NEXUS Target Feature Inventory

### Group A: Authentication & Onboarding
- **FEAT-A01:** Guest Quick Play (instant zero-friction play, UUID token).
- **FEAT-A02:** Secure Email/Password Authentication (Argon2id, JWT access/refresh).
- **FEAT-A03:** OAuth Social Login (Google & Apple Sign-In).
- **FEAT-A04:** Interactive Onboarding Flow (skill assessment, rating calibration, board preferences).
- **FEAT-A05:** Runtime Permissions Manager (Audio, Microphone, Notifications).

### Group B: Home & Editorial
- **FEAT-B01:** Editorial Dashboard (daily featured game, Grandmaster quotes, daily tactical puzzle).
- **FEAT-B02:** Player Identity Badge (rating, tier, avatar, streak counters).
- **FEAT-B03:** Active Match Restoration (one-tap jump back into ongoing live or AI matches).
- **FEAT-B04:** Quick Match Launchers (Bullet 1+0, Blitz 3+2, Rapid 10+0, Classical 30+0).

### Group C: Battle Arena & Gameplay
- **FEAT-C01:** 60/120 FPS High-Performance Chessboard (Obsidian/Emerald/Ivory theme, drag-and-drop, tap-tap).
- **FEAT-C02:** Real-Time Multiplayer (FastAPI, Redis pub/sub, WebSockets, authoritative clock synchronization).
- **FEAT-C03:** Smart Reconnection Handling (exponential backoff, 60-second grace window, move sync).
- **FEAT-C04:** Private Rooms & Deep Link Challenges (custom room codes, shareable URLs).
- **FEAT-C05:** AI Arena (Stockfish difficulty levels 1 through 20, personalized AI bot personalities).
- **FEAT-C06:** Full Chess Rule Legality (En passant, castling rights, underpromotion dialog, 3-fold repetition, 50-move rule, insufficient material).
- **FEAT-C07:** Sound & Haptic Feedback System (tactile haptics on piece drop, capture, check, victory).

### Group D: Academy & Training
- **FEAT-D01:** Interactive Tactics Trainer (thousands of curated puzzles with rating progression).
- **FEAT-D02:** Puzzle Rush (Survival mode and 3-minute / 5-minute speed blitz puzzles).
- **FEAT-D03:** Master Class Lessons (Beginner fundamentals to Grandmaster endgames).
- **FEAT-D04:** Interactive Opening Explorer (ECO tree, master move frequency, win/draw rates).
- **FEAT-D05:** Endgame Practice Suite (Lucena, Philidor, Queen vs Pawn, Knight & Bishop mate).

### Group E: Competition & Tournaments
- **FEAT-E01:** Swiss & Arena System Tournaments (automated pairings, tiebreaks, round timer).
- **FEAT-E02:** Global & Regional Leaderboards (Bullet, Blitz, Rapid, Classical, Puzzle Elo).
- **FEAT-E03:** Spectator Mode (real-time live board streaming with multi-threaded move broadcast).

### Group F: Intelligence & AI Coach
- **FEAT-F01:** Stockfish Multi-PV Analysis Studio (engine evaluation bar, best lines, depth control).
- **FEAT-F02:** Full Game Report & Accuracy Score (Move classifications: Brilliant, Great, Best, Excellent, Good, Inaccuracy, Mistake, Blunder, Missed Win).
- **FEAT-F03:** Gemini AI Coach (contextual LLM commentary, position explanations in English and Telugu).
- **FEAT-F04:** Voice Coach & Voice Gameplay (spoken move recognition in English and Telugu, verbal commentary).

### Group G: Social & Game Vault
- **FEAT-G01:** Game Vault (Cloud and local SQLite PGN archive, searchable by opponent, opening, date, result).
- **FEAT-G02:** PGN Import / Export (FEN/PGN clipboard copy, file import/export).
- **FEAT-G03:** Social System (friend requests, online presence, challenge invitations, player blocking/reporting).

### Group H: System & Customization
- **FEAT-H01:** Board Themes (Classic Obsidian, Deep Emerald, Royal Midnight, Tournament Wood).
- **FEAT-H02:** Piece Themes (Classic Nexus, Modern Minimalist, Vector Neo, Traditional Staunton).
- **FEAT-H03:** Multi-Lingual Localization (English, Telugu, Hindi, Spanish).
- **FEAT-H04:** Accessibility Support (screen reader descriptions, high contrast, reduced motion).

