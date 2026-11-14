# CHESS NEXUS – API & PROTOCOL SPECIFICATION

**Document Version:** 1.0.0  
**Transport Protocols:** HTTPS (REST) & WSS (WebSockets)  
**Authentication:** Bearer JWT (Access Token 15m, Refresh Token 30d)  

---

## 1. RESTful API Endpoints

### 1.1 Authentication (`/api/v1/auth`)
- **`POST /api/v1/auth/register`**
  - **Request:** `{ "username": "alex", "email": "alex@nexus.com", "password": "SecurePassword123!" }`
  - **Response 201:** `{ "user": { "id": "...", "username": "alex" }, "access_token": "...", "refresh_token": "..." }`
- **`POST /api/v1/auth/login`**
  - **Request:** `{ "username_or_email": "alex", "password": "SecurePassword123!" }`
  - **Response 200:** Tokens & User Profile.
- **`POST /api/v1/auth/guest`**
  - **Request:** `{ "device_id": "uuid-v4-client" }`
  - **Response 200:** Temporary guest token with seamless conversion to full account.
- **`POST /api/v1/auth/refresh`**
  - **Request:** `{ "refresh_token": "..." }`
  - **Response 200:** New access token.

### 1.2 Matchmaking & Games (`/api/v1/matches`)
- **`POST /api/v1/matches/seek`**
  - **Request:** `{ "time_control": "blitz_3_2", "rated": true }`
  - **Response 200:** `{ "ticket_id": "...", "status": "queued" }`
- **`GET /api/v1/matches/{match_id}`**
  - **Response 200:** Current match metadata, PGN, players, clocks, and status.
- **`POST /api/v1/matches/private/create`**
  - **Request:** `{ "time_control": "rapid_10_0", "color_preference": "random" }`
  - **Response 201:** `{ "room_code": "NEXUS-8492", "invite_url": "https://chessnexus.app/join/NEXUS-8492" }`
- **`POST /api/v1/matches/private/join`**
  - **Request:** `{ "room_code": "NEXUS-8492" }`
  - **Response 200:** `{ "match_id": "..." }`

### 1.3 AI Coach & Analysis (`/api/v1/coach`)
- **`POST /api/v1/coach/explain-position`**
  - **Request:**
    ```json
    {
      "fen": "r1bqk2r/pppp1ppp/2n2n2/2b1p3/2B1P3/2NP1N2/PPP2PPP/R1BQK2R b KQkq - 0 5",
      "language": "te", // "en" or "te" (Telugu)
      "player_color": "white"
    }
    ```
  - **Response 200:**
    ```json
    {
      "tactical_theme": "Italian Game - Giuoco Piano",
      "explanation": "ఈ పొజిషన్‌లో వైట్ బిషప్ మరియు నైట్ సెంటర్‌ను నియంత్రిస్తున్నాయి. బ్లాక్ d6 లేదా O-O చేయవచ్చు.",
      "best_move_san": "O-O",
      "evaluation_centipawns": 15
    }
    ```

---

## 2. WebSocket Real-Time Match Protocol (`/ws/match/{match_id}`)

### 2.1 Connection Handshake
- Client connects to `wss://api.chessnexus.app/ws/match/{match_id}?token={JWT_TOKEN}`.
- Server validates JWT, confirms match participation (Player White, Player Black, or Spectator), and sends full match state:
  ```json
  {
    "type": "match_sync",
    "match_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "fen": "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1",
    "turn": "black",
    "white_time_ms": 180000,
    "black_time_ms": 180000,
    "move_history": ["e4"],
    "server_timestamp_ms": 1731602400000
  }
  ```

### 2.2 Client Inbound Events
- **Move Submission:**
  ```json
  {
    "type": "move",
    "from": "e7",
    "to": "e5",
    "promotion": null,
    "client_timestamp_ms": 1731602401200
  }
  ```
- **Offer / Accept Draw:**
  ```json
  { "type": "draw_offer" }
  { "type": "draw_accept" }
  ```
- **Resignation:**
  ```json
  { "type": "resign" }
  ```

### 2.3 Server Outbound Events
- **Move Acknowledgement & Broadcast:**
  ```json
  {
    "type": "move_played",
    "san": "e5",
    "from": "e7",
    "to": "e5",
    "fen": "rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq e6 0 2",
    "turn": "white",
    "white_time_ms": 180000,
    "black_time_ms": 178800,
    "is_check": false,
    "is_game_over": false
  }
  ```
- **Rejection of Illegal Move:**
  ```json
  {
    "type": "move_rejected",
    "reason": "Illegal move: King is in check",
    "authoritative_fen": "..."
  }
  ```
- **Match Conclusion:**
  ```json
  {
    "type": "game_over",
    "result": "1-0",
    "reason": "checkmate",
    "winner_id": "...",
    "white_rating_new": 1532.4,
    "white_rating_delta": 14.2,
    "black_rating_new": 1485.6,
    "black_rating_delta": -14.2
  }
  ```

