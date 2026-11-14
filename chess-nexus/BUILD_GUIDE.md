# CHESS NEXUS — Complete Build, Compilation & Deployment Guide

This guide provides definitive, tested instructions for setting up the environment, running tests, launching development servers, and generating production release artifacts for **Android** and **iOS**.

---

## 1. Prerequisites & Environment Setup

### 1.1 Development Toolchain
- **Operating System:** Windows 10/11, macOS 14+, or Linux Ubuntu 22.04+
- **Python:** 3.11+ (Python 3.11 or 3.14 recommended)
- **Java:** OpenJDK 17 (Required by Android Gradle Plugin 8.x)
- **Android SDK:** API 34+ (Build-tools 34.0.0, Platform 34)
- **Flutter SDK:** 3.19.0+ (Stable Channel)

### 1.2 Windows Environment Variable Configuration
Set the following environment variables (PowerShell):
```powershell
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.20.101-hotspot"
$env:ANDROID_HOME = "C:\Users\MANIKANTA\AppData\Local\Android\Sdk"
$env:ANDROID_SDK_ROOT = "C:\Users\MANIKANTA\AppData\Local\Android\Sdk"
$env:PATH = "C:\flutter\bin;C:\Users\MANIKANTA\AppData\Local\Android\Sdk\platform-tools;$env:JAVA_HOME\bin;$env:PATH"
```

> [!IMPORTANT]
> **Windows 11 Smart App Control (SAC) Notice:**  
> If Windows 11 Smart App Control blocks unsigned `dart.exe` (`Program 'dart.exe' failed to run: An Application Control policy has blocked this file`), open **Windows Security** -> **App & browser control** -> **Smart App Control** and set it to **Off** or **Evaluation**, or add an exclusion for `C:\flutter`.

---

## 2. Backend Startup & Testing

### 2.1 Local Python Environment
```bash
cd chess-nexus/backend

# Create virtual environment
python -m venv .venv
# Activate:
# Windows PowerShell: .venv\Scripts\Activate.ps1
# macOS/Linux: source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt
pip install pytest pytest-cov
```

### 2.2 Run Backend Test Suite
```bash
# Run all 25 automated unit and user journey tests:
python -m pytest tests/ -v
```
Expected output: **25 passed in < 1.0s**.

### 2.3 Launch Development Server
```bash
# Start FastAPI backend on port 8000
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```
- Interactive OpenAPI Docs: `http://localhost:8000/docs`
- Health check: `http://localhost:8000/api/v1/health`

### 2.4 One-Click Docker Stack
```bash
cd chess-nexus/infrastructure/docker
docker-compose up -d --build
```

---

## 3. Flutter Mobile Application

### 3.1 Dependency Resolution & Static Audit
```bash
cd chess-nexus/mobile

# Verify Dart AST and relative import integrity
python ../verify_dart_syntax.py

# Fetch Flutter dependencies
flutter pub get

# Format code
dart format lib/ test/

# Run Flutter Analyzer
flutter analyze --no-fatal-infos
```

### 3.2 Network Configuration for Mobile Testing
The app automatically detects the runtime host in `ApiConstants`:
- **Android Emulator:** Automatically routes to `http://10.0.2.2:8000`
- **Connected Physical Device (via ADB):** Run:
  ```bash
  adb reverse tcp:8000 tcp:8000
  ```
  This allows the device to communicate with the host's FastAPI server over `http://127.0.0.1:8000`.
- **Production:** Configured for `https://api.chessnexus.app`.

### 3.3 Running on Live Hardware or Emulator
```bash
cd chess-nexus/mobile

# Check connected devices
flutter devices

# Launch on connected device (e.g. Vivo V2307 / 10BE231YU6001EP)
flutter run -d 10BE231YU6001EP
```

---

## 4. Android Production Release Builds

### 4.1 Automated Build Pipeline
Run the included PowerShell packaging pipeline:
```powershell
.\chess-nexus\infrastructure\scripts\build_android.ps1
```

### 4.2 Manual Release Build Commands
```bash
cd chess-nexus/mobile

# 1. Split-per-ABI Release APKs (arm64-v8a, armeabi-v7a, x86_64)
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=../releases/android/symbols/

# 2. Google Play Store App Bundle (AAB)
flutter build appbundle --release --obfuscate --split-debug-info=../releases/android/symbols/
```

### 4.3 Verified Release Artifacts
- **arm64-v8a APK:** `releases/android/app-arm64-v8a-release.apk`
- **Play Store AAB:** `releases/android/chess-nexus-release.aab`
- **R8 Proguard Symbols:** `releases/android/symbols/`

---

## 5. iOS Production Release Builds

iOS builds require a macOS runner with Xcode 15+ and CocoaPods.

### 5.1 Automated macOS Build Script
```bash
chmod +x ./chess-nexus/infrastructure/scripts/build_ios.sh
./chess-nexus/infrastructure/scripts/build_ios.sh
```

### 5.2 GitHub Actions CI/CD Pipeline
Every push to `main` triggers `.github/workflows/build_and_release.yml`:
1. Executes backend tests and Python security scan.
2. Runs Flutter analyzer and unit test suite.
3. Builds Android APKs and Google Play AAB on `ubuntu-latest`.
4. Provisions Xcode certificates, CocoaPods, and exports signed IPA on `macos-14`.
5. Uploads all signed release artifacts to GitHub Releases.

