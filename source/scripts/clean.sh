#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RELEASE_DIR="$(cd "$PROJECT_DIR/.." && pwd)/release"

cd "$PROJECT_DIR"

flutter clean
find "$RELEASE_DIR" -maxdepth 1 -type f -name 'HogarStock-v*.apk' -delete

echo "Build y APKs de release limpiados."
