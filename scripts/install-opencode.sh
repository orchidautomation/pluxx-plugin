#!/usr/bin/env bash
set -euo pipefail

REPO="${PLUXX_PLUGIN_REPO:-orchidautomation/pluxx-plugin}"
PLUGIN_NAME="${PLUXX_PLUGIN_NAME:-pluxx}"
BUNDLE_URL="${PLUXX_OPENCODE_BUNDLE_URL:-https://github.com/${REPO}/releases/latest/download/pluxx-plugin-opencode-latest.tar.gz}"
PLUGIN_ROOT_DIR="${PLUXX_OPENCODE_PLUGIN_ROOT_DIR:-$HOME/.config/opencode/plugins}"
INSTALL_DIR="${PLUXX_OPENCODE_INSTALL_DIR:-$PLUGIN_ROOT_DIR/$PLUGIN_NAME}"
ENTRY_PATH="${PLUXX_OPENCODE_ENTRY_PATH:-$PLUGIN_ROOT_DIR/$PLUGIN_NAME.ts}"
SKILLS_ROOT="${PLUXX_OPENCODE_SKILLS_ROOT:-$HOME/.config/opencode/skills}"
BUNDLE_PATH="${PLUXX_OPENCODE_BUNDLE_PATH:-}"

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

BUNDLE_ARCHIVE="$TMP_DIR/pluxx-plugin-opencode.tar.gz"

if [[ -n "$BUNDLE_PATH" ]]; then
  cp "$BUNDLE_PATH" "$BUNDLE_ARCHIVE"
else
  need_cmd curl
  curl -fsSL "$BUNDLE_URL" -o "$BUNDLE_ARCHIVE"
fi

tar -xzf "$BUNDLE_ARCHIVE" -C "$TMP_DIR"

BUNDLE_DIR="$TMP_DIR/opencode"
PLUGIN_PACKAGE="$BUNDLE_DIR/package.json"

if [[ ! -f "$PLUGIN_PACKAGE" ]]; then
  echo "Downloaded bundle does not contain an OpenCode package.json." >&2
  exit 1
fi

mkdir -p "$(dirname "$INSTALL_DIR")" "$SKILLS_ROOT"
rm -rf "$INSTALL_DIR"
cp -R "$BUNDLE_DIR" "$INSTALL_DIR"

export ENTRY_PATH
export PLUGIN_NAME

node <<'NODE'
const fs = require('fs')

const entryPath = process.env.ENTRY_PATH
const pluginName = process.env.PLUGIN_NAME
const exportName = pluginName
  .split(/[^A-Za-z0-9]+/)
  .filter(Boolean)
  .map((segment) => segment.charAt(0).toUpperCase() + segment.slice(1))
  .join('')

const content = [
  'import type { Plugin } from "@opencode-ai/plugin"',
  'import { join } from "path"',
  '',
  `import * as PluginModule from "./${pluginName}/index.ts"`,
  '',
  '// OpenCode auto-loads plugin files placed directly in ~/.config/opencode/plugins.',
  '// Proxy into the installed Pluxx bundle while preserving its expected root.',
  'const pluginFactory = Object.values(PluginModule).find((value): value is Plugin => typeof value === "function")',
  '',
  'if (!pluginFactory) {',
  `  throw new Error("OpenCode plugin bundle for ${pluginName} did not export a plugin function.")`,
  '}',
  '',
  `export const ${exportName}: Plugin = async (context) =>`,
  '  pluginFactory({',
  '    ...context,',
  `    directory: join(context.directory, "${pluginName}"),`,
  '  })',
  '',
].join('\n')

fs.writeFileSync(entryPath, content)
NODE

if [[ -d "$INSTALL_DIR/skills" ]]; then
  for skill_dir in "$INSTALL_DIR"/skills/*; do
    [[ -d "$skill_dir" ]] || continue
    skill_name="$(basename "$skill_dir")"
    installed_skill_dir="$SKILLS_ROOT/${PLUGIN_NAME}-${skill_name}"
    rm -rf "$installed_skill_dir"
    cp -R "$skill_dir" "$installed_skill_dir"

    export SKILL_PATH="$installed_skill_dir/SKILL.md"
    export SKILL_NAME="$skill_name"
    export PLUGIN_NAME

    node <<'NODE'
const fs = require('fs')

const filepath = process.env.SKILL_PATH
const pluginName = process.env.PLUGIN_NAME
const fallbackName = process.env.SKILL_NAME

if (!fs.existsSync(filepath)) process.exit(0)

const content = fs.readFileSync(filepath, 'utf8')
const match = content.match(/^---\n([\s\S]*?)\n---\n?/)
const namespacedName = `${pluginName}/${fallbackName}`

if (!match) {
  fs.writeFileSync(filepath, `---\nname: ${namespacedName}\n---\n\n${content}`)
  process.exit(0)
}

const frontmatter = match[1]
const nameMatch = frontmatter.match(/^name:\s*(.+)$/m)
const existingName = nameMatch ? nameMatch[1].trim().replace(/^['"]|['"]$/g, '') : fallbackName
const nextName = existingName.startsWith(`${pluginName}/`) ? existingName : `${pluginName}/${existingName}`
const nextFrontmatter = nameMatch
  ? frontmatter.replace(/^name:\s*.+$/m, `name: ${nextName}`)
  : `name: ${nextName}\n${frontmatter}`

fs.writeFileSync(
  filepath,
  `${content.slice(0, match.index)}---\n${nextFrontmatter}\n---\n${content.slice(match[0].length)}`,
)
NODE
  done
fi

echo "Installed $PLUGIN_NAME plugin code to $INSTALL_DIR"
echo "Installed OpenCode wrapper at $ENTRY_PATH"
echo "Synced namespaced skills into $SKILLS_ROOT"
echo "If OpenCode is already open, restart or reload it so the plugin is picked up."
