#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "XcodeGen is not installed."
  echo "Install it on macOS with:"
  echo "  brew install xcodegen"
  exit 1
fi

echo "Generating WarrantyVault.xcodeproj with XcodeGen..."
xcodegen generate
echo "Done: $ROOT_DIR/WarrantyVault.xcodeproj"
