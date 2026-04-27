#!/usr/bin/env bash
set -euo pipefail

if command -v pluxx >/dev/null 2>&1; then
  VERSION="$(pluxx --version 2>/dev/null || true)"
  if [[ -n "${VERSION}" ]]; then
    echo "Pluxx runtime available: ${VERSION}"
  else
    echo "Pluxx runtime available on PATH."
  fi
  exit 0
fi

if command -v npx >/dev/null 2>&1; then
  echo "Pluxx runtime is not installed globally. The plugin can fall back to npx."
  echo "If you want the smoother operator path, run /pluxx:bootstrap-runtime."
  exit 0
fi

echo "Pluxx runtime is missing. Install Node first, then run /pluxx:bootstrap-runtime." >&2
