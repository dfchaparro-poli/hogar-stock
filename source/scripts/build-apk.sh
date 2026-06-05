#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RELEASE_DIR="$(cd "$PROJECT_DIR/.." && pwd)/release"

cd "$PROJECT_DIR"

flutter clean
flutter pub get
flutter build apk --release

VERSION_LINE="$(grep '^version:' pubspec.yaml)"
VERSION_FULL="${VERSION_LINE#version: }"
VERSION_NAME="${VERSION_FULL%%+*}"

mkdir -p "$RELEASE_DIR"
cp "$PROJECT_DIR/build/app/outputs/flutter-apk/app-release.apk" \
  "$RELEASE_DIR/HogarStock-v${VERSION_NAME}.apk"

echo "APK generado en: $RELEASE_DIR/HogarStock-v${VERSION_NAME}.apk"
