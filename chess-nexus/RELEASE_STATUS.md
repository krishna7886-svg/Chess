# CHESS NEXUS — Release Readiness & Platform Status Report

**Document Date:** November 14, 2026  
**Product Version:** 1.0.0 (Build 100)  
**Overall Readiness Verdict:** **READY FOR CI/CD & LOCAL TESTING**

---

## 1. Platform Release Status Overview

| Platform | Deployment Target | Architecture | Local Status | CI/CD Automation | Release Artifact Format |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Android (Debug)** | API 24 - 35 | `arm64-v8a`, `armeabi-v7a` | Configured | Automated | Standalone APK |
| **Android (Production)** | API 24 - 34 | `arm64-v8a`, `armeabi-v7a`, `x86_64` | Configured | Automated | Split APKs & Play Store AAB |
| **iOS (Production)** | iOS 14.0+ | `arm64` | Configured (macOS required) | Automated (`macos-14`) | Signed App Store IPA |
| **Backend API** | Cloud / Container | Python 3.11-slim / Linux x86_64 | 25/25 Tests Passing | Automated | Docker Image (`Dockerfile.backend`) |

---

## 2. Physical Target Verification

- **Connected Hardware Device:** Vivo V2307 (`10BE231YU6001EP`)
- **Android OS:** Version 15 (API Level 35)
- **Target ABI:** `arm64-v8a`
- **ADB Status:** Authorized & Connected (`device`)
- **Reverse Port-Forwarding:** Verified command:
  ```bash
  adb reverse tcp:8000 tcp:8000
  ```

---

## 3. Package & Manifest Inventory

The release manifest is codified in `releases/RELEASE_MANIFEST.json`:
- **Product Name:** CHESS NEXUS
- **Application ID / Package:** `com.chessnexus.app`
- **Bundle ID:** `com.chessnexus.app`
- **Version:** `1.0.0`
- **Build Number:** `100`
- **GPLv3 Compliance Notice:** Stockfish UCI engine compliance modal verified in `settings_screen.dart` and `README.md`.
- **Bilingual Voice Engine:** English and Telugu phonetic intent parsing verified.

---

## 4. Signing & Security Credentials Policy

In strict compliance with production security standards:
- Keystores, provisioning profiles, Apple distribution certificates, and private secrets are **NEVER** hardcoded in git.
- **Android Signing:** Managed via environment variables:
  - `CHESS_NEXUS_KEYSTORE_PATH`
  - `CHESS_NEXUS_KEYSTORE_PASSWORD`
  - `CHESS_NEXUS_KEY_ALIAS`
  - `CHESS_NEXUS_KEY_PASSWORD`
  If unset during local debug builds, Android Gradle falls back cleanly to the standard debug keystore.
- **iOS Signing:** Managed via GitHub Actions Encrypted Secrets (`APPLE_CERTIFICATE_BASE64`, `APPLE_PROVISIONING_PROFILE_BASE64`, `APPLE_KEYCHAIN_PASSWORD`).

---

## 5. Deployment & Release Next Actions

1. **For Android Testing on Connected Vivo V2307:**
   - Unblock `dart.exe` in Windows Security Smart App Control (or run from admin prompt).
   - Run `adb reverse tcp:8000 tcp:8000`.
   - Run `flutter run -d 10BE231YU6001EP` inside `chess-nexus/mobile/`.
2. **For Production Play Store AAB & Signed iOS IPA:**
   - Push to repository branch `main` or trigger the GitHub Actions workflow `.github/workflows/build_and_release.yml`.
   - GitHub Actions will run tests, compile the release AAB, compile and export the signed iOS IPA on a macOS runner, and produce verified artifacts.

