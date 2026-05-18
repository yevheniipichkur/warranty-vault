#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This script must run on macOS with Xcode."
  echo "Current OS: $(uname -s)"
  echo "Use GitHub Actions macOS runner with .github/workflows/build-ipa.yml to build an IPA."
  exit 2
fi

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "xcodebuild was not found. Install Xcode from the Mac App Store or Apple Developer downloads, then run:"
  echo "  sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
  exit 3
fi

if ! command -v xcrun >/dev/null 2>&1; then
  echo "xcrun was not found. Check your Xcode command line tools installation."
  exit 3
fi

if [[ ! -d "WarrantyVault.xcodeproj" ]]; then
  ./Scripts/generate_project.sh
fi

SCHEME="${SCHEME:-WarrantyVault}"
PROJECT="${PROJECT:-WarrantyVault.xcodeproj}"
CONFIGURATION="${CONFIGURATION:-Release}"
SIMULATOR_DESTINATION="${SIMULATOR_DESTINATION:-platform=iOS Simulator,name=iPhone 16}"
ARCHIVE_PATH="${ARCHIVE_PATH:-build/archive/WarrantyVault.xcarchive}"
EXPORT_PATH="${EXPORT_PATH:-build/ipa}"
EXPORT_OPTIONS="${EXPORT_OPTIONS:-ExportOptions.plist}"
EXPORT_METHOD="${EXPORT_METHOD:-development}"
BUNDLE_ID_VALUE="${BUNDLE_ID:-com.yourname.warrantyvault}"

mkdir -p build/logs build/archive "$EXPORT_PATH"

echo "Xcode version:"
xcodebuild -version
echo "xcrun version:"
xcrun --version

BUILD_SETTINGS=()
BUILD_SETTINGS+=(APP_BUNDLE_ID="$BUNDLE_ID_VALUE")

if [[ -n "${APPLE_TEAM_ID:-}" ]]; then
  BUILD_SETTINGS+=(DEVELOPMENT_TEAM="$APPLE_TEAM_ID")
fi

echo "Running unit tests on simulator..."
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "$SIMULATOR_DESTINATION" \
  -derivedDataPath build/DerivedData \
  CODE_SIGNING_ALLOWED=NO \
  "${BUILD_SETTINGS[@]}" \
  clean test | tee build/logs/test.log

if [[ ! -f "$EXPORT_OPTIONS" ]]; then
  if [[ -z "${APPLE_TEAM_ID:-}" || -z "${PROVISIONING_PROFILE_NAME:-}" ]]; then
    echo "Missing $EXPORT_OPTIONS and signing values."
    echo "Create ExportOptions.plist from ExportOptions.plist.example, or set:"
    echo "  APPLE_TEAM_ID, BUNDLE_ID, PROVISIONING_PROFILE_NAME, EXPORT_METHOD"
    exit 4
  fi

  GENERATED_EXPORT_OPTIONS="build/ExportOptions.generated.plist"
  cat > "$GENERATED_EXPORT_OPTIONS" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "https://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key>
  <string>${EXPORT_METHOD}</string>
  <key>teamID</key>
  <string>${APPLE_TEAM_ID}</string>
  <key>signingStyle</key>
  <string>manual</string>
  <key>provisioningProfiles</key>
  <dict>
    <key>${BUNDLE_ID_VALUE}</key>
    <string>${PROVISIONING_PROFILE_NAME}</string>
    <key>${BUNDLE_ID_VALUE}.liveactivity</key>
    <string>${LIVE_ACTIVITY_PROVISIONING_PROFILE_NAME:-$PROVISIONING_PROFILE_NAME}</string>
  </dict>
  <key>compileBitcode</key>
  <false/>
</dict>
</plist>
EOF
  EXPORT_OPTIONS="$GENERATED_EXPORT_OPTIONS"
fi

ARCHIVE_SETTINGS=("${BUILD_SETTINGS[@]}")
if [[ -n "${PROVISIONING_PROFILE_NAME:-}" ]]; then
  ARCHIVE_SETTINGS+=(CODE_SIGN_STYLE=Manual)
  ARCHIVE_SETTINGS+=(APP_PROVISIONING_PROFILE_SPECIFIER="$PROVISIONING_PROFILE_NAME")
  ARCHIVE_SETTINGS+=(LIVE_ACTIVITY_PROVISIONING_PROFILE_SPECIFIER="${LIVE_ACTIVITY_PROVISIONING_PROFILE_NAME:-$PROVISIONING_PROFILE_NAME}")
fi

echo "Archiving for generic iOS device..."
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE_PATH" \
  "${ARCHIVE_SETTINGS[@]}" \
  clean archive | tee build/logs/archive.log

echo "Exporting IPA..."
xcodebuild \
  -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS" | tee build/logs/export.log

IPA_PATH="$(find "$EXPORT_PATH" -name "*.ipa" -print -quit)"
if [[ -z "$IPA_PATH" ]]; then
  echo "Archive export finished, but no .ipa was found in $EXPORT_PATH."
  exit 5
fi

echo "IPA created:"
echo "  $ROOT_DIR/$IPA_PATH"
