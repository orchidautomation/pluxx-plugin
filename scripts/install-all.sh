#!/usr/bin/env bash
set -euo pipefail

REPO="${PLUXX_PLUGIN_REPO:-orchidautomation/pluxx-plugin}"
TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

for script in install-claude-code.sh install-cursor.sh install-codex.sh install-opencode.sh; do
  curl -fsSL "https://github.com/${REPO}/releases/latest/download/${script}" -o "$TMP_DIR/${script}"
  chmod +x "$TMP_DIR/${script}"
  "$TMP_DIR/${script}"
done

echo
echo "Installed Pluxx across Claude Code, Cursor, Codex, and OpenCode."
