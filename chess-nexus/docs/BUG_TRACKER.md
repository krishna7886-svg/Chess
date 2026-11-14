# CHESS NEXUS – BUG TRACKER & DEFECT ANALYSIS

**Document Version:** 1.0.0  
**Status:** Resolved in Modern Architecture  

---

## 1. Defect Classification Scheme
- **Critical (P0):** Game-breaking rule violation, security vulnerability, data loss, or application crash.
- **High (P1):** Major functional omission, UI freeze, or multiplayer synchronization failure.
- **Medium (P2):** Inaccurate game state calculation, audio missing, or sub-optimal UX.
- **Low (P3):** Cosmetic styling discrepancy, minor timing drift, or non-critical error logging.

---

## 2. Legacy Codebase Defect Registry

| Bug ID | Severity | File / Location | Description | Root Cause | Modern Architecture Resolution |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **BUG-001** | **Critical (P0)** | `index.html:487, 655` | Impossible Underpromotion | Pawns reaching 8th rank hardcoded to Queen (`'Q'`). Impossible to promote to Knight, Rook, or Bishop. | Implemented custom Flutter `PromotionDialog` modal with promotion piece selector integrated into FEN state machine. |
| **BUG-002** | **Critical (P0)** | `index.html:436-494` | Missing En Passant | En passant is omitted from legal move generation and target state tracking. | Complete FEN en passant square tracking and validation in authoritative engine. |
| **BUG-003** | **Critical (P0)** | `voice/index4.html:448` | Client-Trust Multiplayer Attack | Any connected peer can send invalid moves over PeerJS data channel; client executes without verification. | Authoritative FastAPI server rejects moves not in legal moveset; maintains single source of truth. |
| **BUG-004** | **High (P1)** | `index.html:568-590` | UI Freeze on AI Turn | Synchronous `minimax` calculation on main JavaScript thread blocks render loop for up to 3000ms. | Stockfish UCI engine running inside dedicated background Dart Worker / Flutter Isolate. |
| **BUG-005** | **High (P1)** | `index.html:604-605` | 404 Missing Audio Files | `checkmate.wav` and `game-end.wav` are declared but do not exist in the filesystem, causing silent runtime failures. | Bundled high-fidelity verified WAV/MP3 assets in `assets/sounds/` and verified with test suite. |
| **BUG-006** | **High (P1)** | `index.html:436 & 615` | Duplicate Function Overwrite | `movePiece` and `updateGameStatus` are defined twice in the same global scope. | Modular Dart classes with strict encapsulation, single responsibility, and sound null safety. |
| **BUG-007** | **High (P1)** | `index.html:563` | Timer Drift on Inactivity | `setInterval` timer loses synchronization when browser tab is suspended or throttled by OS. | Monotonic server timestamp diffs + monotonic local stopwatch calibration. |
| **BUG-008** | **Medium (P2)** | `AI/index.html:1400` | Inaccurate Move Classification | Moves classified by simple static material heuristics; sacrifices are mislabeled as blunders. | Classification based on Stockfish centipawn loss and win-probability sigmoid curves. |
| **BUG-009** | **Medium (P2)** | `voice/index4.html:1052` | English Homophone Collisions | Speech recognition misinterprets "to" as "two", "see" as "c", and lacks Telugu phonetic vocabulary. | Dual-layer phoneme normalizer + context-aware grammar matching for English & Telugu. |
| **BUG-010** | **Medium (P2)** | `index.html:325` | Opening Transposition Failure | Openings dictionary requires exact move-order string matching; transpositions fail to match. | Polyglot Zobrist hash tree lookup for opening recognition regardless of transposition. |
| **BUG-011** | **Low (P3)** | `index.html:100` | Non-Responsive Board Sizing | Hardcoded `vmin` units overflow on small landscape displays and foldables. | Responsive `LayoutBuilder` with adaptive aspect-ratio scaling for phones and tablets. |
| **BUG-012** | **Low (P3)** | `AI/index.html:167` | Non-Scalable Bitmaps | Low-resolution piece images pixelate on modern Quad-HD / Retina mobile displays. | High-resolution crisp vector SVG pieces and 4x density PNG fallback suites. |

| **BUG-013** | **Critical (P0)** | `mobile/lib/app/router/app_router.dart:108` | Flutter 3.22+ Deprecated NavigationBar Theme Tokens | `MaterialStateProperty` and `MaterialState.selected` deprecated in Flutter 3.22/3.24. | Migrated to `WidgetStateProperty` and `WidgetState.selected` with zero warnings. |
| **BUG-014** | **High (P1)** | `mobile/lib/core/constants/api_constants.dart:1` | Android Emulator Localhost Routing Loop | Hardcoded `localhost:8000` inaccessible inside Android emulator loopback. | Implemented dynamic host resolution (`10.0.2.2:8000` for Android emulator, `127.0.0.1` for desktop/reverse-tether, `api.chessnexus.app` for production). |
| **BUG-015** | **High (P1)** | Windows Environment | Smart App Control (SAC) Block on Unsigned Dart Bootstrap Executable | Windows 11 Smart App Control blocks unsigned `dart.exe` extracted from raw git clone engine cache. | Documented exact SAC exclusion configuration, verified 100% syntax compliance via AST validator, and configured GitHub Actions CI/CD build runner. |
| **BUG-016** | **Medium (P2)** | `mobile/assets/` | Asset Path Resolution in Sub-packages | Bundled assets resided only in top-level `assets/`, causing missing asset bundles during standalone `mobile/` packaging. | Copied complete 12 classic high-res pieces and 5 acoustic sounds directly into `mobile/assets/` and registered in `pubspec.yaml`. |
