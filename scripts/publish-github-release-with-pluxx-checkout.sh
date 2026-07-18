#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUXX_REPO_DIR="${PLUXX_REPO_DIR:-./pluxx-cli}"
PLUXX_BIN="$PLUXX_REPO_DIR/bin/pluxx.js"
VERSION="${1:-}"

"$SCRIPT_DIR/prepare-pluxx-checkout.sh"

if [[ -z "$VERSION" ]]; then
  echo "Usage: $0 <version> [extra pluxx publish args...]" >&2
  exit 1
fi

shift

(
  cd "$PLUXX_REPO_DIR"
  bun install --frozen-lockfile
  bun run build
)

bun "$PLUXX_BIN" publish --github-release --allow-dirty --version "$VERSION" "$@"
