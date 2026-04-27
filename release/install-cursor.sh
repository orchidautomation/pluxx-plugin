#!/usr/bin/env bash
set -euo pipefail

REPO="${PLUXX_PLUGIN_REPO:-orchidautomation/pluxx-plugin}"
REF="${PLUXX_PLUGIN_REF:-main}"
REPO_NAME="${REPO##*/}"
PLUGIN_NAME="${PLUXX_PLUGIN_NAME:-pluxx}"
INSTALL_DIR="${PLUXX_CURSOR_INSTALL_DIR:-$HOME/.cursor/plugins/local/$PLUGIN_NAME}"
ARCHIVE_URL="${PLUXX_PLUGIN_ARCHIVE_URL:-https://codeload.github.com/${REPO}/tar.gz/${REF}}"

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

run_pluxx() {
  if command -v pluxx >/dev/null 2>&1; then
    pluxx "$@"
    return
  fi

  if command -v npx >/dev/null 2>&1; then
    npx -y @orchid-labs/pluxx@latest "$@"
    return
  fi

  echo "Pluxx runtime is unavailable." >&2
  echo "Install it with: npm install -g @orchid-labs/pluxx@latest" >&2
  echo "Or install Node/npm so the npx fallback can run." >&2
  exit 1
}

need_cmd curl
need_cmd find
need_cmd mktemp
need_cmd rm
need_cmd tar

TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

echo "Downloading ${REPO}@${REF} source ..."
ARCHIVE_PATH="$TMP_DIR/${REPO_NAME}.tar.gz"
curl -fsSL "$ARCHIVE_URL" -o "$ARCHIVE_PATH"
tar -xzf "$ARCHIVE_PATH" -C "$TMP_DIR"

SOURCE_ROOT="$(find "$TMP_DIR" -mindepth 1 -maxdepth 1 -type d -name "${REPO_NAME}-*" | head -n1)"
if [[ -z "$SOURCE_ROOT" ]]; then
  echo "Could not locate extracted ${REPO_NAME} source." >&2
  exit 1
fi

echo "Building ${PLUGIN_NAME} for Cursor ..."
(cd "$SOURCE_ROOT" && run_pluxx build --target cursor)

BUNDLE_DIR="$SOURCE_ROOT/dist/cursor"
PLUGIN_MANIFEST="$BUNDLE_DIR/.cursor-plugin/plugin.json"

if [[ ! -f "$PLUGIN_MANIFEST" ]]; then
  echo "Built source is missing a Cursor plugin manifest." >&2
  exit 1
fi

mkdir -p "$(dirname "$INSTALL_DIR")"
rm -rf "$INSTALL_DIR"
cp -R "$BUNDLE_DIR" "$INSTALL_DIR"

echo "Installed $PLUGIN_NAME to $INSTALL_DIR from ${REPO}@${REF}"
echo "If Cursor is already open, restart or reload it so the plugin is picked up."
