#!/usr/bin/env bash
set -euo pipefail

REPO="${PLUXX_PLUGIN_REPO:-orchidautomation/pluxx-plugin}"
TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

BASE_URL="${PLUXX_RELEASE_BASE_URL:-https://github.com/${REPO}/releases/latest/download}"
curl -fsSL --connect-timeout 10 --max-time 120 --retry 3 --retry-all-errors --retry-delay 1 "$BASE_URL/release-manifest.json" -o "$TMP_DIR/release-manifest.json"
curl -fsSL --connect-timeout 10 --max-time 120 --retry 3 --retry-all-errors --retry-delay 1 "$BASE_URL/SHA256SUMS.txt" -o "$TMP_DIR/SHA256SUMS.txt"
curl -fsSL --connect-timeout 10 --max-time 120 --retry 3 --retry-all-errors --retry-delay 1 "$BASE_URL/install.sh" -o "$TMP_DIR/install.sh"

PLUXX_VERIFY_ROOT="$TMP_DIR" PLUXX_VERIFY_SUMS="$TMP_DIR/SHA256SUMS.txt" PLUXX_EXPECTED_PLUGIN="pluxx" node <<'NODE'
const crypto = require('crypto')
const fs = require('fs')
const path = require('path')
const entries = fs.readFileSync(process.env.PLUXX_VERIFY_SUMS, 'utf8')
  .split(/\r?\n/)
  .map((line) => line.match(/^([a-f0-9]{64})  (.+)$/))
for (const name of ['release-manifest.json', 'install.sh']) {
  const match = entries.find((entry) => entry && entry[2] === name)
  if (!match) throw new Error('Release checksum inventory does not include ' + name)
  const actual = crypto.createHash('sha256').update(fs.readFileSync(path.join(process.env.PLUXX_VERIFY_ROOT, name))).digest('hex')
  if (actual !== match[1]) throw new Error('Checksum mismatch for ' + name)
}
const manifest = JSON.parse(fs.readFileSync(path.join(process.env.PLUXX_VERIFY_ROOT, 'release-manifest.json'), 'utf8'))
if (manifest.version !== 1 || manifest.plugin?.name !== process.env.PLUXX_EXPECTED_PLUGIN) {
  throw new Error('Release manifest identity mismatch')
}
NODE

bash "$TMP_DIR/install.sh" --agents "$@"
