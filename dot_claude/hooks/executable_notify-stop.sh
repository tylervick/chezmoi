#!/usr/bin/env bash
# Stop hook — play a short sound when Claude finishes a turn.
# No-op if afplay is unavailable (e.g. non-macOS). Always exits 0.
set -uo pipefail

cat >/dev/null 2>&1 || true   # drain the hook's JSON payload on stdin

if command -v afplay >/dev/null 2>&1; then
  afplay /System/Library/Sounds/Glass.aiff >/dev/null 2>&1 &
fi

exit 0
