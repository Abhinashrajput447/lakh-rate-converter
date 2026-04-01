#!/usr/bin/env bash
set -euo pipefail

# Runs the Flutter app in Chrome from the correct project root.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

flutter run -d chrome
	--web-hostname=127.0.0.1 \
	--web-port=5000
