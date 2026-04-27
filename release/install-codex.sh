#!/usr/bin/env bash
set -euo pipefail

REPO="${PLUXX_PLUGIN_REPO:-orchidautomation/pluxx-plugin}"
REF="${PLUXX_PLUGIN_REF:-main}"
REPO_NAME="${REPO##*/}"
PLUGIN_NAME="${PLUXX_PLUGIN_NAME:-pluxx}"
INSTALL_DIR="${PLUXX_CODEX_INSTALL_DIR:-$HOME/.codex/plugins/$PLUGIN_NAME}"
MARKETPLACE_PATH="${PLUXX_CODEX_MARKETPLACE_PATH:-$HOME/.agents/plugins/marketplace.json}"
MARKETPLACE_NAME="${PLUXX_CODEX_MARKETPLACE_NAME:-pluxx-source}"
MARKETPLACE_DISPLAY_NAME="${PLUXX_CODEX_MARKETPLACE_DISPLAY_NAME:-Pluxx Source}"
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
need_cmd node
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

echo "Building ${PLUGIN_NAME} for Codex ..."
(cd "$SOURCE_ROOT" && run_pluxx build --target codex)

BUNDLE_DIR="$SOURCE_ROOT/dist/codex"
PLUGIN_MANIFEST="$BUNDLE_DIR/.codex-plugin/plugin.json"

if [[ ! -f "$PLUGIN_MANIFEST" ]]; then
  echo "Built source is missing a Codex plugin manifest." >&2
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
    path: './.codex/plugins/' + pluginName,
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

echo "Installed $PLUGIN_NAME to $INSTALL_DIR from ${REPO}@${REF}"
echo "Updated Codex marketplace catalog at $MARKETPLACE_PATH"
echo "If Codex is already open, restart it so the plugin is picked up."
