# CHESS NEXUS – AUTOMATED TEST STRATEGY

**Document Version:** 1.0.0  
**Test Frameworks:** `package:test`, `flutter_test`, `pytest`, `pytest-asyncio`, `mockito`  

---

## 1. Test Pyramid & Coverage Objectives

| Level | Scope | Framework | Coverage Target | Key Verification Areas |
| :--- | :--- | :--- | :--- | :--- |
| **Unit Tests** | Dart Models, Engine Rules, Rating Calculations, Phonetic Parser | `flutter_test`, `test` | $\ge 90\%$ | Legal moves, en passant, castling, stalemate, checkmate, threefold repetition, 50-move rule, Glicko-2 math. |
| **Widget Tests** | Flutter UI Widgets, Board, Clocks, Modals | `flutter_test` | $\ge 80\%$ | Tap interactions, drag-and-drop piece snapping, promotion dialog, timer format, error banners. |
| **Integration Tests** | Backend API, WebSocket Handshake, Redis Pub/Sub, DB Migrations | `pytest`, `pytest-asyncio` | $\ge 85\%$ | Auth cycle, match creation, WebSocket move exchange, clock forfeit trigger, reconnection flow. |
| **E2E Tests** | Full User Journey from Launch to Match Completion | `integration_test` | Critical Paths | Onboarding $\to$ Quick Match $\to$ Move Sequence $\to$ Checkmate $\to$ Rematch $\to$ PGN Save. |

---

## 2. Chess Rules Legality Test Suite

The test suite validates official FIDE rules using known benchmark positions:

1. **Perft (Performance Test) Benchmark:**
   - Initial Position `rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1`:
     - Depth 1: 20 moves.
     - Depth 2: 400 moves.
     - Depth 3: 8,902 moves.
     - Depth 4: 197,281 moves.
   - Position 2 (Kiwipete) `r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq -`:
     - Depth 1: 48 moves.
     - Depth 2: 2,039 moves.
2. **Special Pawn Moves:**
   - White En Passant: `4k3/8/8/3Pp3/8/8/8/4K3 w - e6 0 1` $\to$ move `d5e6` must capture pawn on `e5`.
   - Black En Passant: `4k3/8/8/8/3pP3/8/8/4K3 b - e3 0 1` $\to$ move `d4e3` must capture pawn on `e4`.
   - Underpromotion: Pawn promotion to Rook, Bishop, Knight, Queen.
3. **Castling Rights & Pin Invalidation:**
   - Castling through check must be rejected.
   - Castling out of check must be rejected.
   - Castling after King or Rook moves must be rejected.
4. **Draw Conditions:**
   - Threefold repetition matching position, side to move, castling rights, and en passant availability.
   - 50-move rule (no pawn move, no capture in 50 full moves).
   - Insufficient material: K vs K, K+B vs K, K+N vs K, K+B vs K+B (same color bishops).

---

## 3. Automated Test Execution Commands

```bash
# Run Flutter Unit & Widget Tests
cd mobile && flutter test --coverage

# Run Python Backend Integration & API Tests
cd backend && pytest --asyncio-mode=auto -v tests/
```

