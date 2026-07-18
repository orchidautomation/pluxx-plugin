#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/pluxx-version.sh"

PLUXX_REPO_DIR="${PLUXX_REPO_DIR:-./pluxx-cli}"
PLUXX_REPOSITORY="https://github.com/orchidautomation/pluxx.git"

if [[ ! -d "$PLUXX_REPO_DIR/.git" ]]; then
  if [[ -e "$PLUXX_REPO_DIR" ]]; then
    echo "Expected $PLUXX_REPO_DIR to be absent or a Pluxx git checkout." >&2
    exit 1
  fi

  git clone --depth 1 --branch "$PLUXX_TAG" "$PLUXX_REPOSITORY" "$PLUXX_REPO_DIR"
fi

ACTUAL_COMMIT="$(git -C "$PLUXX_REPO_DIR" rev-parse HEAD)"
if [[ "$ACTUAL_COMMIT" != "$PLUXX_COMMIT" ]]; then
  echo "Pluxx checkout mismatch: expected $PLUXX_TAG at $PLUXX_COMMIT, found $ACTUAL_COMMIT." >&2
  echo "Use a separate checkout at the pinned tag or remove the stale generated checkout." >&2
  exit 1
fi

echo "Using Pluxx ${PLUXX_VERSION} at ${PLUXX_COMMIT} from ${PLUXX_REPO_DIR}"
