#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/pluxx-version.sh"

PLUXX_REPO_DIR="${PLUXX_REPO_DIR:-./pluxx-cli}"
PLUXX_REPOSITORY="https://github.com/orchidautomation/pluxx.git"
PLUXX_CLONE_ATTEMPTS="${PLUXX_CLONE_ATTEMPTS:-2}"
PLUXX_CLONE_LOW_SPEED_TIME="${PLUXX_CLONE_LOW_SPEED_TIME:-30}"

if [[ ! "$PLUXX_CLONE_ATTEMPTS" =~ ^[1-9][0-9]*$ ]]; then
  echo "PLUXX_CLONE_ATTEMPTS must be a positive integer." >&2
  exit 1
fi

if [[ ! "$PLUXX_CLONE_LOW_SPEED_TIME" =~ ^[1-9][0-9]*$ ]]; then
  echo "PLUXX_CLONE_LOW_SPEED_TIME must be a positive integer." >&2
  exit 1
fi

if [[ ! -d "$PLUXX_REPO_DIR/.git" ]]; then
  if [[ -e "$PLUXX_REPO_DIR" ]]; then
    echo "Expected $PLUXX_REPO_DIR to be absent or a Pluxx git checkout." >&2
    exit 1
  fi

  clone_attempt=1
  until git \
    -c http.lowSpeedLimit=1 \
    -c "http.lowSpeedTime=${PLUXX_CLONE_LOW_SPEED_TIME}" \
    clone --depth 1 --branch "$PLUXX_TAG" "$PLUXX_REPOSITORY" "$PLUXX_REPO_DIR"; do
    if (( clone_attempt >= PLUXX_CLONE_ATTEMPTS )); then
      echo "Failed to clone pinned Pluxx after ${PLUXX_CLONE_ATTEMPTS} attempt(s)." >&2
      exit 1
    fi
    clone_attempt=$((clone_attempt + 1))
    echo "Retrying pinned Pluxx clone (${clone_attempt}/${PLUXX_CLONE_ATTEMPTS})..." >&2
  done
fi

ACTUAL_COMMIT="$(git -C "$PLUXX_REPO_DIR" rev-parse HEAD)"
if [[ "$ACTUAL_COMMIT" != "$PLUXX_COMMIT" ]]; then
  echo "Pluxx checkout mismatch: expected $PLUXX_TAG at $PLUXX_COMMIT, found $ACTUAL_COMMIT." >&2
  echo "Use a separate checkout at the pinned tag or remove the stale generated checkout." >&2
  exit 1
fi

echo "Using Pluxx ${PLUXX_VERSION} at ${PLUXX_COMMIT} from ${PLUXX_REPO_DIR}"
