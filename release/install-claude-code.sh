#!/usr/bin/env bash
set -euo pipefail

REPO="${PLUXX_PLUGIN_REPO:-orchidautomation/pluxx-plugin}"
REF="${PLUXX_PLUGIN_REF:-main}"
REPO_NAME="${REPO##*/}"
PLUGIN_NAME="${PLUXX_PLUGIN_NAME:-pluxx}"
MARKETPLACE_NAME="${PLUXX_CLAUDE_MARKETPLACE_NAME:-pluxx-plugin-source}"
INSTALL_ROOT="${PLUXX_CLAUDE_MARKETPLACE_DIR:-$HOME/.claude/plugins/data/$MARKETPLACE_NAME}"
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

need_cmd bash
need_cmd claude
need_cmd curl
need_cmd find
need_cmd grep
need_cmd mktemp
need_cmd rm
need_cmd sed
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

echo "Building ${PLUGIN_NAME} for Claude Code ..."
(cd "$SOURCE_ROOT" && run_pluxx build --target claude-code)

BUNDLE_DIR="$SOURCE_ROOT/dist/claude-code"
PLUGIN_MANIFEST="$BUNDLE_DIR/.claude-plugin/plugin.json"

if [[ ! -f "$PLUGIN_MANIFEST" ]]; then
  echo "Built source is missing a Claude plugin manifest." >&2
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
      "version": "${VERSION:-0.1.1}",
      "author": {
        "name": "Orchid Automation"
      },
      "license": "MIT",
      "homepage": "https://github.com/${REPO}"
    }
  ]
}
JSON

if claude plugin marketplace list --json | grep -q "\"name\": \"$MARKETPLACE_NAME\""; then
  claude plugin marketplace update "$MARKETPLACE_NAME" >/dev/null
else
  claude plugin marketplace add "$INSTALL_ROOT" >/dev/null
fi

claude plugin uninstall "${PLUGIN_NAME}@${MARKETPLACE_NAME}" --scope user >/dev/null 2>&1 || true
claude plugin install "${PLUGIN_NAME}@${MARKETPLACE_NAME}" --scope user

echo
echo "Installed ${PLUGIN_NAME}@${MARKETPLACE_NAME} from ${REPO}@${REF}."
echo "If Claude is already open, run /reload-plugins."
