# CHESS NEXUS — Beyond the Board

[![CI/CD Pipeline](https://github.com/chess-nexus/chess-nexus/actions/workflows/build_and_release.yml/badge.svg)](https://github.com/chess-nexus/chess-nexus/actions/workflows/build_and_release.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.19+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Python](https://img.shields.io/badge/Python-3.11+-3776AB?logo=python&logoColor=white)](https://python.org)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.111+-009688?logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com)
[![Stockfish](https://img.shields.io/badge/Stockfish-16.1_GPLv3-black?logo=chess&logoColor=white)](https://stockfishchess.org)
[![Gemini](https://img.shields.io/badge/Google_Gemini-1.5_Pro-4285F4?logo=google&logoColor=white)](https://ai.google.dev)
[![License: Proprietary / GPLv3](https://img.shields.io/badge/License-Proprietary%20%2F%20GPLv3-gold.svg)](#licensing--attribution)

---

## 🏆 Product Vision & Creative Direction

**CHESS NEXUS** is an original, international-quality competitive chess platform engineered from the ground up for **Android and iOS**, powered by a high-concurrency Python FastAPI backend, Stockfish 16.1 UCI engine, and Google Gemini AI Coach.

### Locked Creative Visual Identity
- **Obsidian (`#080B0A`):** Core application canvas; eliminates OLED battery drain and creates high-contrast luxury depth.
- **Deep Forest (`#111A16`):** Elevated cards, modals, and navigation surfaces.
- **Emerald (`#19382B`):** Dark board squares, active borders, and primary status indicators.
- **Mint Accent (`#A6D6B5`):** Interactive highlights, evaluation gains, primary action buttons, and verified badges.
- **Champagne (`#C6A66B`):** Grandmaster titles, Glicko-2 rating badges, trophies, and premium accents.
- **Ivory (`#EAE8DF`):** Light board squares and editorial typography.
- **Secondary Text (`#9CA99F`):** Muted metadata, move timestamps, and algebraic board coordinates.

---

## 📂 Project Organization

```
chess-nexus/
├── .github/
│   └── workflows/
│       └── build_and_release.yml    # Multi-platform CI/CD (Android APK/AAB, iOS IPA, pytest)
├── assets/                          # Canonical preserved assets
│   ├── pieces/classic/              # 12 preserved high-resolution chess piece PNGs
│   └── sounds/                      # 5 preserved acoustic audio effects (move, capture, etc.)
├── backend/                         # High-performance FastAPI backend
│   ├── app/
│   │   ├── api/v1/                  # REST API endpoints (auth, matches, coach, tournaments)
│   │   ├── core/                    # Security (Argon2id, JWT), App Config
│   │   ├── db/                      # SQLAlchemy models & Async Engine
│   │   ├── services/                # python-chess validator, Glicko-2, Telugu/English voice parser, Gemini
│   │   ├── websockets/              # Live match hub & bidirectional WebSocket framing
│   │   └── main.py                  # FastAPI application entrypoint
│   ├── tests/                       # Authoritative test suite (25/25 passing tests)
│   └── requirements.txt             # Python dependencies
├── mobile/                          # Production Flutter application (Android & iOS)
│   ├── android/                     # Android app project, manifest, gradle, permissions
│   ├── ios/                         # iOS Runner project, Info.plist, Podfile
│   ├── assets/                      # Bundled mobile assets (pieces & audio)
│   ├── lib/
│   │   ├── app/                     # App entry, GoRouter with nested navigation, AppTheme tokens
│   │   ├── core/                    # Audio, Haptics, Constants
│   │   └── features/
│   │       ├── home/                # Editorial Home Screen
│   │       ├── gameplay/            # Battle Arena, NexusBoard CustomPainter, Dual Clocks
│   │       ├── academy/             # Tactics Academy, Puzzle Rush
│   │       ├── competition/         # Masters Tour, Brackets, Leaderboards
│   │       ├── analysis/            # Stockfish Analysis Studio, EvalGauge, Gemini Coach
│   │       ├── profile/             # Glicko-2 Radar, Achievements, History
│   │       ├── game_vault/          # PGN Manager, Repertoire, Saved Studies
│   │       ├── settings/            # Board/Piece selector, Telugu/English, GPLv3 compliance
│   │       └── chess_engine/        # Stockfish isolate bridge, Move models
│   ├── test/                        # Flutter unit and domain model test suite
│   └── pubspec.yaml                 # Flutter dependencies and asset configuration
├── ENVIRONMENT_AUDIT.md             # Development environment, SDKs, and device audit
├── BUILD_GUIDE.md                   # Complete build, compile, and deployment instructions
├── TEST_RESULTS.md                  # Test matrix and verified results for 25 test cases
├── RELEASE_STATUS.md                # Platform release readiness and manifest report
├── docs/                            # Complete Master Architecture Documentation (11 Documents)
│   ├── AUDIT_REPORT.md              # Phase Zero audit of legacy web codebase
│   ├── FEATURE_INVENTORY.md         # Audit of legacy vs target features
│   ├── BUG_TRACKER.md               # Catalog of legacy bugs (BUG-001 - BUG-012) & fixes
│   ├── ASSET_INVENTORY.md           # Checksums and specifications for pieces and audio
│   ├── FEATURE_MIGRATION_MATRIX.md  # Architectural Decision Records (ADRs)
│   ├── ARCHITECTURE.md              # System design and component interactions
│   ├── DATABASE_DESIGN.md           # PostgreSQL & Drift SQLite relational schemas
│   ├── API_SPECIFICATION.md         # RESTful endpoints & WebSocket protocol
│   ├── SECURITY_PLAN.md             # Cryptography, auth, anti-cheat heuristics
│   ├── TEST_STRATEGY.md             # Test pyramid, Perft benchmarks, test matrix
│   └── RELEASE_PLAN.md              # Store submission, signing, CI/CD specifications
├── infrastructure/
│   ├── docker/                      # Multi-stage Dockerfile and docker-compose.yml
│   └── scripts/                     # Automated build scripts (build_android.ps1, build_ios.sh)
└── releases/                        # Release manifest, checksums, and notes
    ├── RELEASE_MANIFEST.json
    └── RELEASE_NOTES_v1.0.0.md
```

---

## 🎨 Google Stitch Design System

The application UI was created and synchronized using **Google Stitch**:
- **Stitch Project ID:** `6489208356638713360`
- **Design System Asset ID:** `fc34d6789ed4483ea4913fae71aec34f`
- **Generated Core Screens:**
  1. *Editorial Home:* `projects/6489208356638713360/screens/156aa12628fa4d918bd7765ded5f600a`
  2. *Battle Arena Live Match:* `projects/6489208356638713360/screens/58e6ef98869d4afd9fff04d14a4f1bae`
  3. *Tactics Academy:* `projects/6489208356638713360/screens/7b47be98fa324b00b72bd1bb23a3bd85`
  4. *Analysis Studio & Coach:* `projects/6489208356638713360/screens/e85c84ed471c4bb587ef8e3e7d2a28e7`
  5. *Competition & Tour:* `projects/6489208356638713360/screens/ed575404c43f4255a33fa81658ece257`

---

## 🛠️ Phase Zero Audit & Bug Remediation

During the repository audit of the legacy web prototype, 12 critical architectural bugs were cataloged and resolved in CHESS NEXUS:
- **BUG-001 (FIDE Castling Rights):** Fixed King moving through check and unverified rook paths.
- **BUG-002 (En Passant Capture):** Restored missing en passant mechanics and target square tracking.
- **BUG-003 (Pawn Underpromotion):** Replaced hardcoded Queen promotion with interactive promotion selector (`Q`, `R`, `B`, `N`).
- **BUG-004 (Duplicate Codebase Collision):** Fixed colliding JavaScript functions (`movePiece`, `updateGameStatus`).
- **BUG-005 (Missing Audio Files):** Resolved broken references to missing `checkmate.wav` and `game-end.wav`.
- **BUG-006 (Minimax UI Freeze):** Replaced synchronous single-threaded minimax with asynchronous Stockfish UCI isolate.
- **BUG-007 (Unauthenticated PeerJS):** Replaced unencrypted P2P connections with authenticated JWT WebSocket server hub.
- **BUG-008 (Lack of Clock Verification):** Implemented authoritative server monotonic clock timers.
- **BUG-009 (Phonetic Voice Drift):** Engineered bilingual English & Telugu phonetic intent parser with Levenshtein fuzzy matching.
- **BUG-010 (Memory Leak on Audio Re-trigger):** Reused managed AudioPlayers pool with hardware focus.
- **BUG-011 (Stalemate & 50-Move Draw Omission):** Complete python-chess authoritative draw detection.
- **BUG-012 (Rating Inflation):** Transitioned from naive Elo to calibrated FIDE Glicko-2 engine with volatility scoring.

---

## 🚀 Getting Started & Local Development

### 1. Prerequisites
- **Python:** 3.11 or newer
- **Flutter:** 3.19.0 or newer (Dart 3.3+)
- **PostgreSQL:** 16+ (or use bundled Docker Compose)
- **Redis:** 7+ (or use bundled Docker Compose)

### 2. Backend Startup
```bash
cd chess-nexus/backend

# Create virtual environment
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run backend tests
pytest tests/ -v

# Start FastAPI development server
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```
Swagger API docs will be live at: `http://localhost:8000/docs`

### 3. Docker Deployment (One-Click Stack)
```bash
cd chess-nexus/infrastructure/docker
docker-compose up -d --build
```
This launches:
- `chess-nexus-backend` on port `8000`
- `chess-nexus-postgres` on port `5432`
- `chess-nexus-redis` on port `6379`

### 4. Mobile Application Startup
```bash
cd chess-nexus/mobile

# Get Flutter dependencies
flutter pub get

# Run mobile unit tests
flutter test

# Launch on connected Android/iOS device or simulator
flutter run
```

---

## 📱 Release Packaging Pipelines

### Android (APK & Play Store AAB)
Run the automated PowerShell packaging pipeline:
```powershell
.\chess-nexus\infrastructure\scripts\build_android.ps1
```
Or directly with the Flutter CLI:
```bash
# Split-per-ABI Release APKs
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=symbols/

# Google Play Store App Bundle (AAB)
flutter build appbundle --release --obfuscate --split-debug-info=symbols/
```
Output artifacts are saved to: `chess-nexus/releases/android/`

### iOS (Apple App Store Signed IPA)
Run the automated macOS build script:
```bash
chmod +x ./chess-nexus/infrastructure/scripts/build_ios.sh
./chess-nexus/infrastructure/scripts/build_ios.sh
```
Or build the Xcode IPA archive directly:
```bash
flutter build ipa --release --export-options-plist=ios/ExportOptions.plist --obfuscate --split-debug-info=symbols/
```
Output artifacts are saved to: `chess-nexus/releases/ios/`

---

## 🔒 Security & Architecture Standards

1. **Authentication:** Password hashing via **Argon2id** (memory cost 65536, time cost 3, parallelism 4); asymmetric JWT authorization tokens with short lifespan (15 min access, 7 day refresh).
2. **Authoritative Engine:** Moves are never trusted from client input. Every ply is validated against the backend `python-chess` state machine.
3. **Anti-Cheat Heuristics:** Glicko-2 engine calculates move execution time standard deviation and Stockfish correlation index ($>95\%$ correlation flags review).
4. **Resilient Offline Architecture:** If disconnected from the server, the app gracefully degrades to local Stockfish analysis and rule-based heuristic coach.

---

## 📜 Licensing & Attribution

- **Application Code & Backend:** Proprietary © 2026 CHESS NEXUS Team. All rights reserved.
- **Stockfish Chess Engine:** Licensed under the [GNU General Public License v3 (GPLv3)](https://www.gnu.org/licenses/gpl-3.0.html). The complete Stockfish engine source code is available at [https://github.com/official-stockfish/Stockfish](https://github.com/official-stockfish/Stockfish).
- **Google Gemini API:** Powered by Google Gemini 1.5 Pro via Google AI SDK.

