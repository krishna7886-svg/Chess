# CHESS NEXUS – SYSTEM ARCHITECTURE

**System Architecture Document**  
**Version:** 1.0.0  
**Classification:** Production Master Specification  

---

## 1. Architectural Philosophy & Overview

CHESS NEXUS is architected as an enterprise-grade, offline-capable, cross-platform competitive chess ecosystem. The system decouples presentation from chess calculation, networking, and intelligence engines.

```mermaid
graph TD
    subgraph Client [Flutter Cross-Platform Client (iOS / Android)]
        UI[Presentation Layer - Riverpod / GoRouter]
        EngineIsolate[Stockfish UCI Engine Isolate]
        LocalDB[Drift / SQLite Database]
        AudioService[Low-Latency Audio & Haptics]
        VoiceService[English & Telugu Speech/TTS Engine]
    end

    subgraph Backend [FastAPI Production Backend]
        APIGateway[FastAPI Gateway / Auth Middleware]
        WSHub[WebSocket Match Hub]
        Matchmaker[Redis Matchmaking Queue]
        RatingEngine[Glicko-2 Rating Engine]
        AntiCheat[Anti-Cheat Statistical Engine]
    end

    subgraph Data [Data & Storage Layer]
        Postgres[(PostgreSQL 16 - Users / Matches / Tournaments)]
        RedisCache[(Redis 7 - Live Board State & Clock Sync)]
    end

    subgraph AI [External Intelligence]
        Gemini[Google Gemini API - AI Coach & Commentary]
    end

    UI <--> EngineIsolate
    UI <--> LocalDB
    UI <--> AudioService
    UI <--> VoiceService
    UI <==>|WSS / Authoritative Moves| WSHub
    UI <==>|HTTPS REST API| APIGateway
    WSHub <--> RedisCache
    WSHub <--> Postgres
    Matchmaker <--> RedisCache
    APIGateway <--> RatingEngine
    APIGateway <--> AntiCheat
    APIGateway <--> Gemini
```

---

## 2. Flutter Client Architecture (`mobile/`)

### 2.1 Layered Feature-First Structure
The Flutter codebase follows the **Clean Architecture / Feature-Driven** structure:
- **`app/`**: Global application configuration, theme initialization (`AppTheme`), route table (`app_router.dart`), and environment bootstrap.
- **`core/`**: Platform utilities, cryptographic helpers, secure storage (`FlutterSecureStorage`), audio player, haptic feedback, network client (`Dio` interceptors), and reusable atomic UI tokens.
- **`features/`**:
  - `presentation/`: Widgets, screen states, animations, Riverpod providers (`StateNotifierProvider`, `NotifierProvider`).
  - `domain/`: Pure Dart business logic, value objects, domain entities, repository interfaces.
  - `data/`: Drift SQLite DAO, API remote data sources, local caches, DTO mappers.

### 2.2 Board Rendering Engine
The chessboard is rendered using Flutter's high-performance layout system:
- `CustomPainter` renders 64 board squares with hardware-accelerated shaders (`Skia` / `Impeller`).
- `RepaintBoundary` isolates the board canvas so piece drag gestures and coordinate highlights do not trigger rebuilds of the clock, move log, or status bars.
- Piece movement uses smooth interpolated animations with spring physics (`Curves.easeOutCubic`) capped at 150ms for competitive responsiveness.
- Touch interactions support both **Tap-to-Select / Tap-to-Move** and **Continuous Drag-and-Drop** with magnetic snap-to-square.

### 2.3 Stockfish Engine Isolate
The Stockfish 16 engine communicates via standard Universal Chess Interface (UCI) protocols:
- Stockfish runs on a background OS thread or Dart `Isolate` to guarantee that search trees of depth 20+ never drop a single frame on the main 120Hz UI thread.
- Asynchronous channels stream real-time Multi-PV lines, best move pointers, and centipawn evaluations back to Riverpod state providers.

---

## 3. Backend Architecture (`backend/`)

### 3.1 Python FastAPI & Async WebSockets
- **FastAPI** handles RESTful endpoints for authentication, profile management, leaderboards, tournament registrations, and PGN export.
- **Async WebSockets** (`/ws/match/{match_id}`) maintain real-time bi-directional game channels with sub-20ms latency.
- **Authoritative Move Validation**: Every client move is validated server-side using a high-speed C-backed Python chess engine (`python-chess`). If a move is illegal, the server transmits an authoritative board state sync error and rejects the action.
- **Clock Authority**: The backend records monotonic timestamps (`time.monotonic_ns()`) for every move reception. Client clocks are strictly synchronized views; server time is absolute.

### 3.2 Redis & Real-Time Match State
- Active games are cached in Redis as serialized FEN, move history SAN lists, and player clocks.
- Redis Pub/Sub distributes move broadcasts across horizontally scaled backend worker containers.
- Matchmaking pools use Redis sorted sets (`ZSET`) partitioned by rating brackets and time controls.

### 3.3 Database Layer (PostgreSQL)
- Relational schema storing users, Elo/Glicko-2 ratings, match histories with full PGN strings, tournament brackets, puzzle progression, and social graphs.
- Migrations managed via Alembic with automated rollback safety.

---

## 4. AI Coach & Intelligence Integration

- **Dual-Engine Architecture:**
  - **Stockfish:** Computes exact tactical evaluations, depth searches, multi-PV candidate lines, and blunder margins.
  - **Google Gemini API:** Ingests the FEN, move SAN, Stockfish evaluation delta, and player profile to generate human-readable, pedagogically sound chess coaching in English and Telugu.
- **Prompt Isolation & Security:**
  - API keys reside exclusively on the FastAPI server inside encrypted environment variables; keys are never bundled in mobile APK/IPA packages.
  - Output is strictly sanitized before delivery to the client.

---

## 5. Offline Resiliency & Data Sync

1. **Local-First Gameplay:** Users can play unlimited offline games against Stockfish or local pass-and-play opponents with zero internet access.
2. **Local PGN Storage:** Games played offline are saved immediately to local Drift/SQLite storage.
3. **Optimistic Sync:** When connectivity is restored, the mobile client synchronizes completed local records and offline puzzle ratings with the cloud backend via idempotent batch endpoints.

