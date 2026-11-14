# CHESS NEXUS - Automated Android Release Packaging Pipeline
# Builds optimized, obfuscated release APKs and Google Play Store AAB

param(
    [string]$KeystorePath = "$PSScriptRoot/../../mobile/android/app/nexus-release-key.jks",
    [string]$OutputDir = "$PSScriptRoot/../../releases/android"
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   CHESS NEXUS - ANDROID PRODUCTION RELEASE BUILD" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$MobileDir = Join-Path $PSScriptRoot "../../mobile"
Set-Location $MobileDir

# 1. Clean and fetch packages
Write-Host "`n[1/5] Fetching Flutter dependencies..." -ForegroundColor Green
flutter pub get

# 2. Run automated test suite
Write-Host "`n[2/5] Running automated Flutter tests..." -ForegroundColor Green
flutter test

# 3. Create releases output directory
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

$SymbolsDir = Join-Path $OutputDir "symbols"
if (-not (Test-Path $SymbolsDir)) {
    New-Item -ItemType Directory -Path $SymbolsDir -Force | Out-Null
}

# 4. Build Split-per-ABI Release APKs
Write-Host "`n[3/5] Building Release APKs (arm64-v8a, armeabi-v7a, x86_64)..." -ForegroundColor Green
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=$SymbolsDir

$ApkSourceDir = "build/app/outputs/flutter-apk"
Get-ChildItem -Path $ApkSourceDir -Filter "*.apk" | ForEach-Object {
    $Dest = Join-Path $OutputDir $_.Name
    Copy-Item $_.FullName -Destination $Dest -Force
    $Hash = (Get-FileHash $Dest -Algorithm SHA256).Hash
    Write-Host "Generated: $($_.Name) | SHA256: $Hash" -ForegroundColor Yellow
}

# 5. Build Google Play Store App Bundle (AAB)
Write-Host "`n[4/5] Building Google Play Store AAB (App Bundle)..." -ForegroundColor Green
flutter build appbundle --release --obfuscate --split-debug-info=$SymbolsDir

$AabSource = "build/app/outputs/bundle/release/app-release.aab"
if (Test-Path $AabSource) {
    $AabDest = Join-Path $OutputDir "chess-nexus-release.aab"
    Copy-Item $AabSource -Destination $AabDest -Force
    $AabHash = (Get-FileHash $AabDest -Algorithm SHA256).Hash
    Write-Host "Generated: chess-nexus-release.aab | SHA256: $AabHash" -ForegroundColor Yellow
}

Write-Host "`n[5/5] Android release build completed successfully." -ForegroundColor Cyan
Write-Host "Artifacts located in: $OutputDir" -ForegroundColor Green

