#!/usr/bin/env bash
# CHESS NEXUS - Automated iOS Release Packaging Pipeline
# Must be executed on a macOS runner with Xcode and CocoaPods configured

set -euo pipefail

echo "=========================================================="
echo "   CHESS NEXUS - iOS PRODUCTION RELEASE ARCHIVE & IPA"
echo "=========================================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MOBILE_DIR="$SCRIPT_DIR/../../mobile"
OUTPUT_DIR="$SCRIPT_DIR/../../releases/ios"
SYMBOLS_DIR="$OUTPUT_DIR/symbols"

mkdir -p "$OUTPUT_DIR"
mkdir -p "$SYMBOLS_DIR"

cd "$MOBILE_DIR"

# 1. Fetch Flutter packages and CocoaPods
echo ""
echo "[1/5] Fetching Flutter packages and installing CocoaPods..."
flutter pub get
cd ios
pod install --repo-update
cd ..

# 2. Run unit and widget tests
echo ""
echo "[2/5] Running automated Flutter tests..."
flutter test

# 3. Create ExportOptions.plist if not present
EXPORT_OPTIONS="$MOBILE_DIR/ios/ExportOptions.plist"
if [ ! -f "$EXPORT_OPTIONS" ]; then
    cat <<EOF > "$EXPORT_OPTIONS"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>${APPLE_TEAM_ID:-NEXUSTEAMID}</string>
    <key>uploadBitcode</key>
    <false/>
    <key>compileBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>signingStyle</key>
    <string>manual</string>
</dict>
</plist>
EOF
fi

# 4. Build iOS Release IPA Archive with obfuscation and symbol splitting
echo ""
echo "[3/5] Building iOS IPA archive with symbol splitting..."
flutter build ipa --release \
    --export-options-plist="$EXPORT_OPTIONS" \
    --obfuscate \
    --split-debug-info="$SYMBOLS_DIR"

# 5. Copy artifacts to releases/ios and calculate checksums
echo ""
echo "[4/5] Copying release artifacts and generating SHA256 checksums..."
IPA_SRC="$MOBILE_DIR/build/ios/ipa/chess_nexus.ipa"
if [ -f "$IPA_SRC" ]; then
    cp "$IPA_SRC" "$OUTPUT_DIR/chess-nexus-release.ipa"
    shasum -a 256 "$OUTPUT_DIR/chess-nexus-release.ipa" > "$OUTPUT_DIR/chess-nexus-release.ipa.sha256"
    echo "Generated: chess-nexus-release.ipa"
    cat "$OUTPUT_DIR/chess-nexus-release.ipa.sha256"
fi

echo ""
echo "[5/5] iOS release build pipeline completed."
echo "Artifacts located in: $OUTPUT_DIR"

