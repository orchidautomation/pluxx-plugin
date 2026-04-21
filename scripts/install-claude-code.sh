#!/usr/bin/env bash
set -euo pipefail

REPO="${PLUXX_PLUGIN_REPO:-orchidautomation/pluxx-plugin}"
PLUGIN_NAME="${PLUXX_PLUGIN_NAME:-pluxx}"
MARKETPLACE_NAME="${PLUXX_CLAUDE_MARKETPLACE_NAME:-pluxx-plugin-releases}"
BUNDLE_URL="${PLUXX_CLAUDE_BUNDLE_URL:-https://github.com/${REPO}/releases/latest/download/pluxx-plugin-claude-code-latest.tar.gz}"
INSTALL_ROOT="${PLUXX_CLAUDE_MARKETPLACE_DIR:-$HOME/.claude/plugins/data/$MARKETPLACE_NAME}"
SKIP_INSTALL="${PLUXX_CLAUDE_SKIP_INSTALL:-0}"
BUNDLE_PATH="${PLUXX_CLAUDE_BUNDLE_PATH:-}"

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

need_cmd tar
need_cmd mktemp
need_cmd grep
need_cmd sed

if [[ "$SKIP_INSTALL" != "1" ]]; then
  need_cmd curl
  need_cmd claude
fi

TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

BUNDLE_ARCHIVE="$TMP_DIR/pluxx-plugin-claude-code.tar.gz"

if [[ -n "$BUNDLE_PATH" ]]; then
  cp "$BUNDLE_PATH" "$BUNDLE_ARCHIVE"
else
  curl -fsSL "$BUNDLE_URL" -o "$BUNDLE_ARCHIVE"
fi

tar -xzf "$BUNDLE_ARCHIVE" -C "$TMP_DIR"

BUNDLE_DIR="$TMP_DIR/claude-code"
PLUGIN_MANIFEST="$BUNDLE_DIR/.claude-plugin/plugin.json"

if [[ ! -f "$PLUGIN_MANIFEST" ]]; then
  echo "Downloaded bundle does not contain a Claude plugin manifest." >&2
  exit 1
fi

VERSION="$(grep -E '"version"' "$PLUGIN_MANIFEST" | head -n1 | sed -E 's/.*"version"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/')"
DESCRIPTION="$(grep -E '"description"' "$PLUGIN_MANIFEST" | head -n1 | sed -E 's/.*"description"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/')"

mkdir -p "$INSTALL_ROOT/.claude-plugin" "$INSTALL_ROOT/plugins"
rm -rf "$INSTALL_ROOT/plugins/$PLUGIN_NAME"
cp -R "$BUNDLE_DIR" "$INSTALL_ROOT/plugins/$PLUGIN_NAME"

cat > "$INSTALL_ROOT/.claude-plugin/marketplace.json" <<JSON
{
  "name": "$MARKETPLACE_NAME",
  "owner": {
    "name": "Orchid Automation"
  },
  "plugins": [
    {
      "name": "$PLUGIN_NAME",
      "source": "./plugins/$PLUGIN_NAME",
      "description": "${DESCRIPTION:-Official Pluxx plugin for Claude Code, Cursor, Codex, and OpenCode.}",
      "version": "${VERSION:-0.1.0}",
      "author": {
        "name": "Orchid Automation"
      },
      "license": "MIT",
      "homepage": "https://github.com/orchidautomation/pluxx-plugin/releases/latest"
    }
  ]
}
JSON

if [[ "$SKIP_INSTALL" == "1" ]]; then
  echo "Prepared Claude marketplace at: $INSTALL_ROOT"
  echo "Plugin bundle is at: $INSTALL_ROOT/plugins/$PLUGIN_NAME"
  exit 0
fi

if claude plugin marketplace list --json | grep -q "\"name\": \"$MARKETPLACE_NAME\""; then
  claude plugin marketplace update "$MARKETPLACE_NAME" >/dev/null
else
  claude plugin marketplace add "$INSTALL_ROOT" >/dev/null
fi

claude plugin uninstall "${PLUGIN_NAME}@${MARKETPLACE_NAME}" --scope user >/dev/null 2>&1 || true
claude plugin install "${PLUGIN_NAME}@${MARKETPLACE_NAME}" --scope user

echo
echo "Installed ${PLUGIN_NAME}@${MARKETPLACE_NAME} into Claude Code user scope."
echo "If Claude is already open, run /reload-plugins in the active session."
