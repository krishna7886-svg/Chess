# CHESS NEXUS – COMPREHENSIVE SECURITY & FAIR PLAY PLAN

**Document Version:** 1.0.0  
**Security Classification:** Enterprise Level  

---

## 1. Security Architecture & Threat Modeling

### 1.1 Credential & Token Protection
- **Mobile Storage:** Auth tokens (JWT access & refresh tokens) are stored strictly inside hardware-backed secure storage:
  - **Android:** Android Keystore with `EncryptedSharedPreferences`.
  - **iOS:** iOS Keychain Services with `kSecAttrAccessibleAfterFirstUnlock`.
- **Password Hashing:** Passwords hashed using **Argon2id** (time cost = 3, memory cost = 65536 KiB, parallelism = 4) with cryptographically secure random per-user salts.
- **TLS Enforcement:** All transport layers enforce **TLS 1.3** with strict certificate pinning options in mobile production builds. Plaintext HTTP/WS connections are rejected.

### 1.2 Anti-Cheat & Fair Play Engine
1. **Engine Detection Heuristics:**
   - Evaluates player moves against Stockfish Top-1 and Top-3 recommendations across varying depths.
   - Calculates Centipawn Loss Average (ACPL) and Move Accuracy Percentage.
   - Tracks move timing variance (distribution of time per move): automated bots display unnatural timing uniformity compared to human pauses during tactical decisions.
2. **Multi-Signal Verification:**
   - Accounts are never banned solely on a single game's evaluation.
   - A multi-tier flag triggers a human arbiter review queue when a player's accuracy exceeds 98% across 5 consecutive rated matches with abnormal move timing distributions.
3. **Client-Side Integrity:**
   - Flutter release builds compiled in AOT mode with code obfuscation (`--obfuscate --split-debug-info`).
   - Root / Jailbreak detection checks surface warning banners and isolate competitive rated ladders to verified environments.

### 1.3 Input Sanitization & Rate Limiting
- **Server-Side Validation:** Every FEN, SAN, and PGN payload is parsed with a strict whitelist grammar.
- **WebSocket Rate Limiting:** Rate limit of max 5 events/second per connection to prevent denial-of-service flooding.
- **REST API Rate Limiting:** Enforced via Redis Token Bucket algorithm (100 requests/minute per authenticated user, 20 requests/minute for unauthenticated endpoints).

### 1.4 Privacy & Compliance
- **Zero Sensitive Data Logging:** Passwords, private keys, auth headers, and IP addresses are excluded from application logs.
- **GDPR / CCPA Compliance:**
  - Automated endpoint for full account deletion (`DELETE /api/v1/users/me`).
  - Automated endpoint for PGN data export (`GET /api/v1/users/me/export`).

