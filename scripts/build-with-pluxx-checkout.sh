#!/usr/bin/env bash
set -euo pipefail

PLUXX_REPO_DIR="${PLUXX_REPO_DIR:-./pluxx-cli}"
PLUXX_BIN="$PLUXX_REPO_DIR/bin/pluxx.js"

if [[ ! -f "$PLUXX_BIN" ]]; then
  echo "Expected a Pluxx checkout at $PLUXX_REPO_DIR with $PLUXX_BIN available." >&2
  echo "Set PLUXX_REPO_DIR to a Pluxx repo checkout, then rerun." >&2
  exit 1
fi

bun "$PLUXX_BIN" doctor
bun "$PLUXX_BIN" lint
bun "$PLUXX_BIN" test --target claude-code cursor codex opencode
bun "$PLUXX_BIN" build
