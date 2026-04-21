#!/usr/bin/env bash
set -euo pipefail

REPO="${PLUXX_PLUGIN_REPO:-orchidautomation/pluxx-plugin}"
PLUGIN_NAME="${PLUXX_PLUGIN_NAME:-pluxx}"
BUNDLE_URL="${PLUXX_CODEX_BUNDLE_URL:-https://github.com/${REPO}/releases/latest/download/pluxx-plugin-codex-latest.tar.gz}"
INSTALL_DIR="${PLUXX_CODEX_INSTALL_DIR:-$HOME/.codex/plugins/$PLUGIN_NAME}"
MARKETPLACE_PATH="${PLUXX_CODEX_MARKETPLACE_PATH:-$HOME/.agents/plugins/marketplace.json}"
BUNDLE_PATH="${PLUXX_CODEX_BUNDLE_PATH:-}"
MARKETPLACE_NAME="${PLUXX_CODEX_MARKETPLACE_NAME:-pluxx-local}"
MARKETPLACE_DISPLAY_NAME="${PLUXX_CODEX_MARKETPLACE_DISPLAY_NAME:-Pluxx Local}"

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

need_cmd tar
need_cmd mktemp
need_cmd node

TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

BUNDLE_ARCHIVE="$TMP_DIR/pluxx-plugin-codex.tar.gz"

if [[ -n "$BUNDLE_PATH" ]]; then
  cp "$BUNDLE_PATH" "$BUNDLE_ARCHIVE"
else
  need_cmd curl
  curl -fsSL "$BUNDLE_URL" -o "$BUNDLE_ARCHIVE"
fi

tar -xzf "$BUNDLE_ARCHIVE" -C "$TMP_DIR"

BUNDLE_DIR="$TMP_DIR/codex"
PLUGIN_MANIFEST="$BUNDLE_DIR/.codex-plugin/plugin.json"

if [[ ! -f "$PLUGIN_MANIFEST" ]]; then
  echo "Downloaded bundle does not contain a Codex plugin manifest." >&2
  exit 1
fi

mkdir -p "$(dirname "$INSTALL_DIR")"
rm -rf "$INSTALL_DIR"
cp -R "$BUNDLE_DIR" "$INSTALL_DIR"

mkdir -p "$(dirname "$MARKETPLACE_PATH")"

export MARKETPLACE_PATH
export PLUGIN_NAME
export MARKETPLACE_NAME
export MARKETPLACE_DISPLAY_NAME

node <<'NODE'
const fs = require('fs')
const path = require('path')

const filepath = process.env.MARKETPLACE_PATH
const pluginName = process.env.PLUGIN_NAME
const marketplaceName = process.env.MARKETPLACE_NAME
const displayName = process.env.MARKETPLACE_DISPLAY_NAME

let marketplace = {
  name: marketplaceName,
  interface: { displayName },
  plugins: [],
}

if (fs.existsSync(filepath)) {
  marketplace = JSON.parse(fs.readFileSync(filepath, 'utf8'))
  marketplace.name ||= marketplaceName
  marketplace.interface ||= { displayName }
  marketplace.plugins = Array.isArray(marketplace.plugins) ? marketplace.plugins : []
}

const nextPlugins = marketplace.plugins.filter((plugin) => plugin.name !== pluginName)
nextPlugins.push({
  name: pluginName,
  source: {
    source: 'local',
    path: `./.codex/plugins/${pluginName}`,
  },
  policy: {
    installation: 'AVAILABLE',
    authentication: 'ON_INSTALL',
  },
  category: 'Productivity',
})

fs.writeFileSync(
  filepath,
  JSON.stringify(
    {
      name: marketplace.name,
      interface: marketplace.interface,
      plugins: nextPlugins,
    },
    null,
    2,
  ) + '\n',
)
NODE

echo "Installed $PLUGIN_NAME to $INSTALL_DIR"
echo "Updated Codex marketplace catalog at $MARKETPLACE_PATH"
echo "If Codex is already open, restart it so the plugin is picked up."
