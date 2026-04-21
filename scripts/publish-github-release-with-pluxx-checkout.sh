#!/usr/bin/env bash
set -euo pipefail

PLUXX_REPO_DIR="${PLUXX_REPO_DIR:-./pluxx-cli}"
PLUXX_BIN="$PLUXX_REPO_DIR/bin/pluxx.js"
VERSION="${1:-}"

if [[ ! -f "$PLUXX_BIN" ]]; then
  echo "Expected a Pluxx checkout at $PLUXX_REPO_DIR with $PLUXX_BIN available." >&2
  echo "Set PLUXX_REPO_DIR to a Pluxx repo checkout, then rerun." >&2
  exit 1
fi

if [[ -z "$VERSION" ]]; then
  echo "Usage: $0 <version> [extra pluxx publish args...]" >&2
  exit 1
fi

shift

bun "$PLUXX_BIN" publish --github-release --version "$VERSION" "$@"
