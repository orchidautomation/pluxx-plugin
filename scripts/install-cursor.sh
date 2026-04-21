#!/usr/bin/env bash
set -euo pipefail

REPO="${PLUXX_PLUGIN_REPO:-orchidautomation/pluxx-plugin}"
PLUGIN_NAME="${PLUXX_PLUGIN_NAME:-pluxx}"
BUNDLE_URL="${PLUXX_CURSOR_BUNDLE_URL:-https://github.com/${REPO}/releases/latest/download/pluxx-plugin-cursor-latest.tar.gz}"
INSTALL_DIR="${PLUXX_CURSOR_INSTALL_DIR:-$HOME/.cursor/plugins/local/$PLUGIN_NAME}"
BUNDLE_PATH="${PLUXX_CURSOR_BUNDLE_PATH:-}"

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

need_cmd tar
need_cmd mktemp

TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

BUNDLE_ARCHIVE="$TMP_DIR/pluxx-plugin-cursor.tar.gz"

if [[ -n "$BUNDLE_PATH" ]]; then
  cp "$BUNDLE_PATH" "$BUNDLE_ARCHIVE"
else
  need_cmd curl
  curl -fsSL "$BUNDLE_URL" -o "$BUNDLE_ARCHIVE"
fi

tar -xzf "$BUNDLE_ARCHIVE" -C "$TMP_DIR"

BUNDLE_DIR="$TMP_DIR/cursor"
PLUGIN_MANIFEST="$BUNDLE_DIR/.cursor-plugin/plugin.json"

if [[ ! -f "$PLUGIN_MANIFEST" ]]; then
  echo "Downloaded bundle does not contain a Cursor plugin manifest." >&2
  exit 1
fi

mkdir -p "$(dirname "$INSTALL_DIR")"
rm -rf "$INSTALL_DIR"
cp -R "$BUNDLE_DIR" "$INSTALL_DIR"

echo "Installed $PLUGIN_NAME to $INSTALL_DIR"
echo "If Cursor is already open, restart or reload it so the plugin is picked up."
