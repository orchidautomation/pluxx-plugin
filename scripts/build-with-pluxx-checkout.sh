#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUXX_REPO_DIR="${PLUXX_REPO_DIR:-./pluxx-cli}"
PLUXX_BIN="$PLUXX_REPO_DIR/bin/pluxx.js"

"$SCRIPT_DIR/prepare-pluxx-checkout.sh"

(
  cd "$PLUXX_REPO_DIR"
  bun install --frozen-lockfile
  bun run build
)

node "$PLUXX_BIN" validate
node "$PLUXX_BIN" doctor
node "$PLUXX_BIN" lint
"$SCRIPT_DIR/validate-source-skills.sh"
node "$PLUXX_BIN" test --target claude-code cursor codex opencode
node "$PLUXX_BIN" build
node "$SCRIPT_DIR/test-opencode-top-level-wrapper.mjs"
