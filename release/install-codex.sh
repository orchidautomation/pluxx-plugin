#!/usr/bin/env bash
set -Eeuo pipefail

REPO="${PLUXX_PLUGIN_REPO:-orchidautomation/pluxx-plugin}"
PLUGIN_NAME="${PLUXX_PLUGIN_NAME:-pluxx}"
BUNDLE_URL="${PLUXX_CODEX_BUNDLE_URL:-https://github.com/${REPO}/releases/download/v0.2.2/pluxx-codex-latest.tar.gz}"
INSTALL_DIR="${PLUXX_CODEX_INSTALL_DIR:-$HOME/.codex/plugins/$PLUGIN_NAME}"
MARKETPLACE_PATH="${PLUXX_CODEX_MARKETPLACE_PATH:-$HOME/.agents/plugins/marketplace.json}"
BUNDLE_PATH="${PLUXX_CODEX_BUNDLE_PATH:-}"
MARKETPLACE_NAME="${PLUXX_CODEX_MARKETPLACE_NAME:-$PLUGIN_NAME-local}"
MARKETPLACE_DISPLAY_NAME="${PLUXX_CODEX_MARKETPLACE_DISPLAY_NAME:-Pluxx Local}"

PLUXX_TX_PLATFORM="codex"
PLUXX_TX_STAGE=""
PLUXX_TX_BACKUP=""
PLUXX_TX_SWAPPED=0
PLUXX_TX_SWAP_STARTED=0
PLUXX_TX_COMMITTED=0
PLUXX_TX_HAD_INSTALL=0
PLUXX_TX_LOCK=""
PLUXX_TX_OWNERSHIP_PATH=""
PLUXX_TX_OWNED_ROOT=""
PLUXX_TX_OWNED_PATHS=()
PLUXX_TX_OWNED_BACKUPS=()
PLUXX_TX_OWNED_EXISTED=()

pluxx_tx_backup_owned_path() {
  local owned_path="$1"
  if [[ -z "$PLUXX_TX_OWNED_ROOT" ]]; then
    PLUXX_TX_OWNED_ROOT="$TMP_DIR/pluxx-owned-state"
    mkdir -p "$PLUXX_TX_OWNED_ROOT"
  fi
  local index="${#PLUXX_TX_OWNED_PATHS[@]}"
  local backup_path="$PLUXX_TX_OWNED_ROOT/$index"
  PLUXX_TX_OWNED_PATHS+=("$owned_path")
  PLUXX_TX_OWNED_BACKUPS+=("$backup_path")
  if [[ -e "$owned_path" || -L "$owned_path" ]]; then
    cp -R "$owned_path" "$backup_path"
    PLUXX_TX_OWNED_EXISTED+=("1")
  else
    PLUXX_TX_OWNED_EXISTED+=("0")
  fi
}

pluxx_tx_restore_owned_paths() {
  local count="${#PLUXX_TX_OWNED_PATHS[@]}"
  local index
  for ((index=count - 1; index>=0; index--)); do
    local owned_path="${PLUXX_TX_OWNED_PATHS[$index]}"
    rm -rf "$owned_path"
    if [[ "${PLUXX_TX_OWNED_EXISTED[$index]}" == "1" ]]; then
      mkdir -p "$(dirname "$owned_path")"
      cp -R "${PLUXX_TX_OWNED_BACKUPS[$index]}" "$owned_path"
    fi
  done
}

pluxx_tx_discard_owned_paths() {
  [[ -z "$PLUXX_TX_OWNED_ROOT" ]] || rm -rf "$PLUXX_TX_OWNED_ROOT"
  PLUXX_TX_OWNED_ROOT=""
  PLUXX_TX_OWNED_PATHS=()
  PLUXX_TX_OWNED_BACKUPS=()
  PLUXX_TX_OWNED_EXISTED=()
}

pluxx_tx_cleanup() {
  if [[ "$PLUXX_TX_COMMITTED" == "1" ]]; then
    [[ -z "$PLUXX_TX_BACKUP" ]] || rm -rf "$PLUXX_TX_BACKUP"
  elif [[ "$PLUXX_TX_SWAP_STARTED" == "1" ]]; then
    if [[ "$PLUXX_TX_HAD_INSTALL" == "1" && ( -e "$PLUXX_TX_BACKUP" || -L "$PLUXX_TX_BACKUP" ) ]]; then
      rm -rf "$INSTALL_DIR"
      mv "$PLUXX_TX_BACKUP" "$INSTALL_DIR"
    elif [[ "$PLUXX_TX_HAD_INSTALL" == "0" && ! -e "$PLUXX_TX_STAGE" && ! -L "$PLUXX_TX_STAGE" ]]; then
      rm -rf "$INSTALL_DIR"
    fi
    pluxx_tx_restore_owned_paths
  fi
  [[ -z "$PLUXX_TX_STAGE" ]] || rm -rf "$PLUXX_TX_STAGE"
  pluxx_tx_discard_owned_paths
  [[ -z "$PLUXX_TX_LOCK" ]] || rm -rf "$PLUXX_TX_LOCK"
}

pluxx_begin_install_transaction() {
  local bundle_dir="$1"
  local nonce="$$-$RANDOM"
  PLUXX_TX_STAGE="$(dirname "$INSTALL_DIR")/.$PLUGIN_NAME.pluxx-stage-$nonce"
  PLUXX_TX_BACKUP="$(dirname "$INSTALL_DIR")/.$PLUGIN_NAME.pluxx-backup-$nonce"
  local lock_root="${PLUXX_INSTALL_LOCK_ROOT:-$HOME/.pluxx/install-locks}"
  local lock_path="$lock_root/$PLUGIN_NAME-$PLUXX_TX_PLATFORM.lock"
  mkdir -p "$lock_root"
  trap '' HUP INT TERM
  if ! mkdir "$lock_path"; then
    trap 'exit 129' HUP
    trap 'exit 130' INT
    trap 'exit 143' TERM
    echo "Another install transaction is active for $INSTALL_DIR. If no installer is running, inspect and remove $lock_path before retrying." >&2
    exit 1
  fi
  PLUXX_TX_LOCK="$lock_path"
  trap 'exit 129' HUP
  trap 'exit 130' INT
  trap 'exit 143' TERM
  local ownership_path_file="$TMP_DIR/pluxx-ownership-path"
  export INSTALL_DIR PLUGIN_NAME PLUXX_TX_PLATFORM PLUXX_TX_STAGE PLUXX_TX_BACKUP
  export PLUXX_TX_OWNERSHIP_PATH_FILE="$ownership_path_file"
  export PLUXX_BUNDLE_DIR="$bundle_dir"
  node <<'NODE'
const crypto = require('crypto')
const fs = require('fs')
const path = require('path')
const installDir = process.env.INSTALL_DIR
const pluginName = process.env.PLUGIN_NAME
const platform = process.env.PLUXX_TX_PLATFORM
const stage = process.env.PLUXX_TX_STAGE
const home = path.resolve(process.env.HOME)
const resolvedInstallDir = path.resolve(installDir)
const conventionalRoots = [path.join('.claude', 'plugins'), path.join('.cursor', 'plugins'), path.join('.codex', 'plugins'), path.join('.config', 'opencode')].map((value) => path.join(home, value))
const ownershipRoot = conventionalRoots.some((root) => resolvedInstallDir === root || resolvedInstallDir.startsWith(root + path.sep))
  ? path.join(home, '.pluxx/install-ownership')
  : path.join(path.dirname(resolvedInstallDir), '.pluxx-install-ownership')
const ownershipPath = path.join(ownershipRoot, pluginName, platform + '.json')
const hash = (value) => crypto.createHash('sha256').update(value).digest('hex')
const walk = (root) => {
  if (!fs.existsSync(root)) return []
  const result = []
  const visit = (dir) => {
    for (const entry of fs.readdirSync(dir, { withFileTypes: true }).sort((a, b) => a.name.localeCompare(b.name))) {
      const filepath = path.join(dir, entry.name)
      const relativePath = path.relative(root, filepath).replace(/\\/g, '/')
      const stats = fs.lstatSync(filepath)
      if (stats.isSymbolicLink()) result.push({ path: relativePath, kind: 'symlink', sha256: hash(fs.readlinkSync(filepath)) })
      else if (stats.isDirectory()) visit(filepath)
      else if (stats.isFile()) result.push({ path: relativePath, kind: 'file', sha256: hash(fs.readFileSync(filepath)) })
    }
  }
  visit(root)
  return result
}
const refuseUnownedInstall = (reason) => {
  throw new Error('Refusing to replace unowned install at ' + installDir + ': ' + reason + '. Move it aside or uninstall it manually, then retry.')
}
const manifestRelativePathByPlatform = {
  'claude-code': '.claude-plugin/plugin.json',
  cursor: '.cursor-plugin/plugin.json',
  codex: '.codex-plugin/plugin.json',
  opencode: 'package.json',
}
const readJson = (filepath, label) => {
  if (!fs.existsSync(filepath)) refuseUnownedInstall('missing ' + label)
  try {
    return JSON.parse(fs.readFileSync(filepath, 'utf8'))
  } catch {
    refuseUnownedInstall('malformed ' + label)
  }
}
const identityName = (manifest) => {
  if (!manifest || typeof manifest !== 'object') return undefined
  return typeof manifest.name === 'string' && manifest.name.trim() !== '' ? manifest.name.trim() : undefined
}
const assertTrustedLegacyInstall = () => {
  const manifestRelativePath = manifestRelativePathByPlatform[platform]
  if (!manifestRelativePath) refuseUnownedInstall('unsupported platform ' + platform)
  const installedManifest = readJson(path.join(installDir, manifestRelativePath), 'installed host manifest')
  const candidateManifest = readJson(path.join(process.env.PLUXX_BUNDLE_DIR, manifestRelativePath), 'candidate host manifest')
  const installedName = identityName(installedManifest)
  const candidateName = identityName(candidateManifest)
  if (!installedName || !candidateName || installedName !== candidateName) {
    refuseUnownedInstall('installed host manifest identity does not match candidate bundle')
  }
}
if (fs.existsSync(installDir)) {
  if (!fs.existsSync(ownershipPath)) {
    const legacy = walk(installDir)
    if (!legacy.every((entry) => entry.path === '.pluxx-user.json')) {
      assertTrustedLegacyInstall()
    }
  } else {
    const record = JSON.parse(fs.readFileSync(ownershipPath, 'utf8'))
    if (record.schema !== 'pluxx.install-ownership.v1' || record.pluginName !== pluginName || record.platform !== platform || path.resolve(record.installPath) !== path.resolve(installDir) || !Array.isArray(record.entries)) {
      throw new Error('Invalid install ownership record: ' + ownershipPath)
    }
    const expected = new Map(record.entries.map((entry) => [entry.path, entry]))
    const actual = new Map(walk(installDir).map((entry) => [entry.path, entry]))
    for (const [entryPath, entry] of expected) {
      const current = actual.get(entryPath)
      if (!current || current.kind !== entry.kind || current.sha256 !== entry.sha256) throw new Error('Refusing to replace modified installed file: ' + entryPath)
    }
    for (const entryPath of actual.keys()) if (!expected.has(entryPath)) throw new Error('Refusing to replace unowned installed file: ' + entryPath)
  }
}
fs.cpSync(process.env.PLUXX_BUNDLE_DIR, stage, { recursive: true })
fs.writeFileSync(process.env.PLUXX_TX_OWNERSHIP_PATH_FILE, ownershipPath)
NODE
  PLUXX_TX_OWNERSHIP_PATH="$(<"$ownership_path_file")"
  pluxx_tx_backup_owned_path "$PLUXX_TX_OWNERSHIP_PATH"
}

pluxx_swap_install_transaction() {
  if [[ -e "$INSTALL_DIR" || -L "$INSTALL_DIR" ]]; then PLUXX_TX_HAD_INSTALL=1; fi
  PLUXX_TX_SWAP_STARTED=1
  if [[ "$PLUXX_TX_HAD_INSTALL" == "1" ]]; then mv "$INSTALL_DIR" "$PLUXX_TX_BACKUP"; fi
  mv "$PLUXX_TX_STAGE" "$INSTALL_DIR"
  PLUXX_TX_SWAPPED=1
}

pluxx_commit_install_transaction() {
  export INSTALL_DIR PLUGIN_NAME PLUXX_TX_PLATFORM
  node <<'NODE'
const crypto = require('crypto')
const fs = require('fs')
const path = require('path')
const root = path.resolve(process.env.INSTALL_DIR)
const runtimeCandidatePath = path.join(root, '.pluxx-runtime-ref.json')
let runtimeCandidate
if (fs.existsSync(runtimeCandidatePath)) {
  runtimeCandidate = JSON.parse(fs.readFileSync(runtimeCandidatePath, 'utf8'))
  fs.rmSync(runtimeCandidatePath, { force: true })
}
const hash = (value) => crypto.createHash('sha256').update(value).digest('hex')
const entries = []
const visit = (dir) => {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true }).sort((a, b) => a.name.localeCompare(b.name))) {
    const filepath = path.join(dir, entry.name)
    const relativePath = path.relative(root, filepath).replace(/\\/g, '/')
    const stats = fs.lstatSync(filepath)
    if (stats.isSymbolicLink()) entries.push({ path: relativePath, kind: 'symlink', sha256: hash(fs.readlinkSync(filepath)) })
    else if (stats.isDirectory()) visit(filepath)
    else if (stats.isFile()) entries.push({ path: relativePath, kind: 'file', sha256: hash(fs.readFileSync(filepath)) })
  }
}
visit(root)
const home = path.resolve(process.env.HOME)
const conventionalRoots = [path.join('.claude', 'plugins'), path.join('.cursor', 'plugins'), path.join('.codex', 'plugins'), path.join('.config', 'opencode')].map((value) => path.join(home, value))
const ownershipRoot = conventionalRoots.some((managedRoot) => root === managedRoot || root.startsWith(managedRoot + path.sep))
  ? path.join(home, '.pluxx/install-ownership')
  : path.join(path.dirname(root), '.pluxx-install-ownership')
const ownershipPath = path.join(ownershipRoot, process.env.PLUGIN_NAME, process.env.PLUXX_TX_PLATFORM + '.json')
fs.mkdirSync(path.dirname(ownershipPath), { recursive: true })
const temporary = ownershipPath + '.tmp-' + process.pid + '-' + crypto.randomBytes(5).toString('hex')
fs.writeFileSync(temporary, JSON.stringify({
  schema: 'pluxx.install-ownership.v1',
  pluginName: process.env.PLUGIN_NAME,
  platform: process.env.PLUXX_TX_PLATFORM,
  installPath: root,
  kind: 'copy',
  entries,
}, null, 2) + '\n', { mode: 0o600 })
fs.renameSync(temporary, ownershipPath)

const commitRuntimeReference = () => {
  const runtimeRefPath = (storeRoot) => path.join(
    storeRoot,
    'refs',
    process.env.PLUGIN_NAME,
    process.env.PLUXX_TX_PLATFORM + '-' + hash(root).slice(0, 16) + '.json',
  )
  if (!runtimeCandidate) {
    const configuredStoreRoot = process.env.PLUXX_RUNTIME_STORE_ROOT || path.join(path.resolve(process.env.HOME), '.pluxx/runtimes')
    if (!fs.existsSync(configuredStoreRoot)) return
    const storeRoot = fs.realpathSync(configuredStoreRoot)
    const staleRef = runtimeRefPath(storeRoot)
    fs.rmSync(staleRef, { force: true })
    return
  }
  if (runtimeCandidate.schema !== 'pluxx.shared-native-runtime-ref-candidate.v1'
    || typeof runtimeCandidate.storeRoot !== 'string'
    || !/^[a-f0-9]{64}$/.test(runtimeCandidate.fingerprint)
    || typeof runtimeCandidate.runtimeEntry !== 'string'
    || typeof runtimeCandidate.leasePath !== 'string') {
    throw new Error('Invalid committed shared runtime reference candidate.')
  }
  const storeRoot = fs.realpathSync(runtimeCandidate.storeRoot)
  const expectedEntry = path.join(storeRoot, 'entries', runtimeCandidate.fingerprint, 'current')
  if (path.resolve(runtimeCandidate.runtimeEntry) !== expectedEntry) {
    throw new Error('Shared runtime reference points outside its fingerprint entry.')
  }
  const expectedLeaseRoot = path.join(storeRoot, 'leases', runtimeCandidate.fingerprint)
  const resolvedLeasePath = path.resolve(runtimeCandidate.leasePath)
  if (!resolvedLeasePath.startsWith(expectedLeaseRoot + path.sep)) {
    throw new Error('Shared runtime lease points outside its fingerprint lease root.')
  }
  const refRoot = path.join(storeRoot, 'refs')
  const refPath = runtimeRefPath(storeRoot)
  fs.mkdirSync(path.dirname(refPath), { recursive: true, mode: 0o700 })
  const ref = {
    schema: 'pluxx.shared-native-runtime-ref.v1',
    pluginName: process.env.PLUGIN_NAME,
    platform: process.env.PLUXX_TX_PLATFORM,
    installPath: root,
    runtimeEntry: expectedEntry,
    fingerprint: runtimeCandidate.fingerprint,
    updatedAt: new Date().toISOString(),
  }
  const temporaryRef = refPath + '.tmp-' + process.pid + '-' + crypto.randomBytes(5).toString('hex')
  fs.writeFileSync(temporaryRef, JSON.stringify(ref, null, 2) + '\n', { mode: 0o600 })
  fs.renameSync(temporaryRef, refPath)
  try { fs.rmSync(resolvedLeasePath, { force: true }) } catch (error) {
    console.error('Warning: could not remove committed shared runtime lease: ' + error.message)
  }

  try {
  const liveFingerprints = new Set()
  const graceMs = Math.max(0, Number(process.env.PLUXX_RUNTIME_GC_GRACE_SECONDS || 604800) * 1000)
  const makeWritable = (filepath) => {
    if (!fs.existsSync(filepath)) return
    const stats = fs.lstatSync(filepath)
    if (stats.isSymbolicLink()) return
    fs.chmodSync(filepath, stats.isDirectory() ? 0o700 : (stats.mode | 0o600))
    if (stats.isDirectory()) for (const entry of fs.readdirSync(filepath)) makeWritable(path.join(filepath, entry))
  }
  const removeTree = (filepath) => {
    makeWritable(filepath)
    fs.rmSync(filepath, { recursive: true, force: true, maxRetries: 5, retryDelay: 50 })
  }
  const visitRefs = (directory) => {
    if (!fs.existsSync(directory)) return
    for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
      const filepath = path.join(directory, entry.name)
      if (entry.isDirectory()) visitRefs(filepath)
      else if (entry.isFile() && entry.name.endsWith('.json')) {
        try {
          const candidate = JSON.parse(fs.readFileSync(filepath, 'utf8'))
          if (candidate.schema !== 'pluxx.shared-native-runtime-ref.v1'
            || typeof candidate.installPath !== 'string') {
            fs.rmSync(filepath, { force: true })
          } else if (!fs.existsSync(candidate.installPath)) {
            const updatedAt = Date.parse(candidate.updatedAt || '')
            if (Number.isFinite(updatedAt) && Date.now() - updatedAt < graceMs && /^[a-f0-9]{64}$/.test(candidate.fingerprint)) {
              liveFingerprints.add(candidate.fingerprint)
            } else {
              fs.rmSync(filepath, { force: true })
            }
          } else if (/^[a-f0-9]{64}$/.test(candidate.fingerprint)) {
            liveFingerprints.add(candidate.fingerprint)
          }
        } catch { fs.rmSync(filepath, { force: true }) }
      }
    }
  }
  visitRefs(refRoot)

  const leasesRoot = path.join(storeRoot, 'leases')
  if (fs.existsSync(leasesRoot)) {
    for (const fingerprintEntry of fs.readdirSync(leasesRoot, { withFileTypes: true })) {
      if (!fingerprintEntry.isDirectory() || !/^[a-f0-9]{64}$/.test(fingerprintEntry.name)) continue
      const fingerprintLeaseRoot = path.join(leasesRoot, fingerprintEntry.name)
      for (const leaseEntry of fs.readdirSync(fingerprintLeaseRoot, { withFileTypes: true })) {
        if (!leaseEntry.isFile() || !leaseEntry.name.endsWith('.json')) continue
        const leaseFile = path.join(fingerprintLeaseRoot, leaseEntry.name)
        try {
          const lease = JSON.parse(fs.readFileSync(leaseFile, 'utf8'))
          if (lease.schema === 'pluxx.shared-native-runtime-lease.v1'
            && lease.fingerprint === fingerprintEntry.name
            && Number.isInteger(lease.ownerPid)
            && lease.ownerPid > 0) {
            try { process.kill(lease.ownerPid, 0); liveFingerprints.add(fingerprintEntry.name); continue } catch (error) {
              if (error && error.code === 'EPERM') { liveFingerprints.add(fingerprintEntry.name); continue }
            }
          }
        } catch {}
        fs.rmSync(leaseFile, { force: true })
      }
    }
  }

  const fingerprintHasLiveLease = (fingerprint) => {
    const leaseRoot = path.join(leasesRoot, fingerprint)
    if (!fs.existsSync(leaseRoot)) return false
    for (const leaseEntry of fs.readdirSync(leaseRoot, { withFileTypes: true })) {
      if (!leaseEntry.isFile() || !leaseEntry.name.endsWith('.json')) continue
      try {
        const lease = JSON.parse(fs.readFileSync(path.join(leaseRoot, leaseEntry.name), 'utf8'))
        if (lease.schema !== 'pluxx.shared-native-runtime-lease.v1'
          || lease.fingerprint !== fingerprint
          || !Number.isInteger(lease.ownerPid)
          || lease.ownerPid <= 0) continue
        try { process.kill(lease.ownerPid, 0); return true } catch (error) {
          if (error && error.code === 'EPERM') return true
        }
      } catch {}
    }
    return false
  }
  const fingerprintHasLiveRef = (directory, fingerprint) => {
    if (!fs.existsSync(directory)) return false
    for (const refEntry of fs.readdirSync(directory, { withFileTypes: true })) {
      const refFile = path.join(directory, refEntry.name)
      if (refEntry.isDirectory()) {
        if (fingerprintHasLiveRef(refFile, fingerprint)) return true
        continue
      }
      if (!refEntry.isFile() || !refEntry.name.endsWith('.json')) continue
      try {
        const candidate = JSON.parse(fs.readFileSync(refFile, 'utf8'))
        if (candidate.schema !== 'pluxx.shared-native-runtime-ref.v1'
          || candidate.fingerprint !== fingerprint
          || typeof candidate.installPath !== 'string') continue
        if (fs.existsSync(candidate.installPath)) return true
        const updatedAt = Date.parse(candidate.updatedAt || '')
        if (Number.isFinite(updatedAt) && Date.now() - updatedAt < graceMs) return true
      } catch {}
    }
    return false
  }

  const entriesRoot = path.join(storeRoot, 'entries')
  if (fs.existsSync(entriesRoot)) {
    for (const entry of fs.readdirSync(entriesRoot, { withFileTypes: true })) {
      const filepath = path.join(entriesRoot, entry.name)
      if (!entry.isDirectory()) continue
      if (!liveFingerprints.has(entry.name)) {
        if (fs.existsSync(path.join(storeRoot, 'locks', entry.name + '.lock'))) continue
        // Check the handoff in lease-then-ref order: ref publication precedes lease removal.
        if (fingerprintHasLiveLease(entry.name) || fingerprintHasLiveRef(refRoot, entry.name)) continue
        if (Date.now() - fs.statSync(filepath).mtimeMs >= graceMs) removeTree(filepath)
        continue
      }
      const generationsRoot = path.join(filepath, 'generations')
      let currentGeneration
      try { currentGeneration = path.resolve(filepath, fs.readlinkSync(path.join(filepath, 'current'))) } catch {}
      if (!fs.existsSync(generationsRoot)) continue
      for (const generation of fs.readdirSync(generationsRoot, { withFileTypes: true })) {
        const generationPath = path.join(generationsRoot, generation.name)
        if (!generation.isDirectory() || generationPath === currentGeneration) continue
        if (Date.now() - fs.statSync(generationPath).mtimeMs >= graceMs) removeTree(generationPath)
      }
    }
  }
  } catch (error) {
    console.error('Warning: could not prune shared runtime store: ' + error.message)
  }
}

commitRuntimeReference()
NODE
}

pluxx_discard_install_transaction() {
  PLUXX_TX_SWAP_STARTED=0
  PLUXX_TX_SWAPPED=0
  PLUXX_TX_HAD_INSTALL=0
  PLUXX_TX_STAGE=""
  if ! rm -rf "$PLUXX_TX_BACKUP"; then echo "Warning: could not remove install backup $PLUXX_TX_BACKUP" >&2; fi
  pluxx_tx_discard_owned_paths
  if ! rm -rf "$PLUXX_TX_LOCK"; then echo "Warning: could not remove install lock $PLUXX_TX_LOCK" >&2; fi
  PLUXX_TX_LOCK=""
  PLUXX_TX_COMMITTED=0
}

pluxx_finalize_install_transaction() {
  pluxx_commit_install_transaction
  PLUXX_TX_COMMITTED=1
  pluxx_discard_install_transaction
}
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM


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
  pluxx_tx_cleanup
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

BUNDLE_ARCHIVE="$TMP_DIR/pluxx-codex.tar.gz"

if [[ -n "$BUNDLE_PATH" ]]; then
  cp "$BUNDLE_PATH" "$BUNDLE_ARCHIVE"
else
  need_cmd curl
  curl -fsSL --connect-timeout 10 --max-time 120 --retry 3 --retry-all-errors --retry-delay 1 "$BUNDLE_URL" -o "$BUNDLE_ARCHIVE"
fi


RELEASE_BASE_URL="${PLUXX_RELEASE_BASE_URL:-https://github.com/${REPO}/releases/download/v0.2.2}"
RELEASE_MANIFEST_PATH="${PLUXX_RELEASE_MANIFEST_PATH:-}"
RELEASE_CHECKSUMS_PATH="${PLUXX_RELEASE_CHECKSUMS_PATH:-}"

if [[ -n "$BUNDLE_PATH" ]]; then
  LOCAL_RELEASE_DIR="$(dirname "$BUNDLE_PATH")"
  RELEASE_MANIFEST_PATH="${RELEASE_MANIFEST_PATH:-$LOCAL_RELEASE_DIR/release-manifest.json}"
  RELEASE_CHECKSUMS_PATH="${RELEASE_CHECKSUMS_PATH:-$LOCAL_RELEASE_DIR/SHA256SUMS.txt}"
fi

RELEASE_MANIFEST="$TMP_DIR/release-manifest.json"
RELEASE_CHECKSUMS="$TMP_DIR/SHA256SUMS.txt"

if [[ -n "$RELEASE_MANIFEST_PATH" ]]; then
  cp "$RELEASE_MANIFEST_PATH" "$RELEASE_MANIFEST"
else
  curl -fsSL --connect-timeout 10 --max-time 120 --retry 3 --retry-all-errors --retry-delay 1 "$RELEASE_BASE_URL/release-manifest.json" -o "$RELEASE_MANIFEST"
fi

if [[ -n "$RELEASE_CHECKSUMS_PATH" ]]; then
  cp "$RELEASE_CHECKSUMS_PATH" "$RELEASE_CHECKSUMS"
else
  curl -fsSL --connect-timeout 10 --max-time 120 --retry 3 --retry-all-errors --retry-delay 1 "$RELEASE_BASE_URL/SHA256SUMS.txt" -o "$RELEASE_CHECKSUMS"
fi

verify_release_asset() {
  local filepath="$1"
  local asset_name="$2"
  PLUXX_VERIFY_FILE="$filepath" PLUXX_VERIFY_NAME="$asset_name" PLUXX_VERIFY_SUMS="$RELEASE_CHECKSUMS" node <<'NODE'
const crypto = require('crypto')
const fs = require('fs')

const filepath = process.env.PLUXX_VERIFY_FILE
const assetName = process.env.PLUXX_VERIFY_NAME
const sumsPath = process.env.PLUXX_VERIFY_SUMS
const lines = fs.readFileSync(sumsPath, 'utf8').split(/\r?\n/)
const match = lines.map((line) => line.match(/^([a-f0-9]{64})  (.+)$/)).find((entry) => entry && entry[2] === assetName)
if (!match) throw new Error('Release checksum inventory does not include ' + assetName)
const actual = crypto.createHash('sha256').update(fs.readFileSync(filepath)).digest('hex')
if (actual !== match[1]) throw new Error('Checksum mismatch for ' + assetName)
NODE
}

verify_release_asset "$RELEASE_MANIFEST" "release-manifest.json"
verify_release_asset "$BUNDLE_ARCHIVE" "pluxx-codex-latest.tar.gz"

PLUXX_RELEASE_MANIFEST="$RELEASE_MANIFEST" PLUXX_EXPECTED_PLUGIN="$PLUGIN_NAME" PLUXX_EXPECTED_PLATFORM="codex" PLUXX_EXPECTED_VERSION="0.2.2" node <<'NODE'
const fs = require('fs')
const manifest = JSON.parse(fs.readFileSync(process.env.PLUXX_RELEASE_MANIFEST, 'utf8'))
const expectedPlugin = process.env.PLUXX_EXPECTED_PLUGIN
const expectedPlatform = process.env.PLUXX_EXPECTED_PLATFORM
const expectedVersion = process.env.PLUXX_EXPECTED_VERSION
if (manifest.version !== 1) throw new Error('Unsupported release manifest version')
if (manifest.plugin?.name !== expectedPlugin) throw new Error('Release manifest plugin identity mismatch')
if (manifest.plugin?.version !== expectedVersion) throw new Error('Release manifest version mismatch')
const archive = manifest.assets?.archives?.find((entry) => entry.platform === expectedPlatform)
if (!archive || archive.latestAsset !== 'pluxx-codex-latest.tar.gz') {
  throw new Error('Release manifest archive identity mismatch for ' + expectedPlatform)
}
NODE

while IFS= read -r archive_entry; do
  normalized="${archive_entry#./}"
  case "$normalized" in
    ""|/*|..|../*|*/..|*/../*|*\*)
      echo "Unsafe archive path rejected: $archive_entry" >&2
      exit 1
      ;;
  esac
done < <(tar -tzf "$BUNDLE_ARCHIVE")

while IFS= read -r archive_detail; do
  case "${archive_detail:0:1}" in
    -|d) ;;
    *)
      echo "Unsafe archive member type rejected: $archive_detail" >&2
      exit 1
      ;;
  esac
done < <(tar -tvzf "$BUNDLE_ARCHIVE")

tar -xzf "$BUNDLE_ARCHIVE" -C "$TMP_DIR"

BUNDLE_DIR="$TMP_DIR/codex"
PLUGIN_MANIFEST="$BUNDLE_DIR/.codex-plugin/plugin.json"

if [[ ! -f "$PLUGIN_MANIFEST" ]]; then
  echo "Downloaded bundle does not contain a Codex plugin manifest." >&2
  exit 1
fi

mkdir -p "$(dirname "$INSTALL_DIR")"

pluxx_begin_install_transaction "$BUNDLE_DIR"


export PLUXX_INSTALL_DIR="$PLUXX_TX_STAGE"
export PLUXX_RUNTIME_ROOT="$INSTALL_DIR"

node <<'NODE'
const fs = require('fs')
const path = require('path')

const installDir = process.env.PLUXX_INSTALL_DIR
const runtimeRoot = process.env.PLUXX_RUNTIME_ROOT || installDir

if (installDir) {
  const materializeInstalledStdioPath = (value) => {
    if (typeof value !== 'string') return value

    const normalized = value.replace(/\\/g, '/')
    const rootRef = normalized.match(/^\$\{(?:CLAUDE_PLUGIN_ROOT|CURSOR_PLUGIN_ROOT|PLUGIN_ROOT)\}[\\/](.+)$/)

    if (rootRef) {
      return path.resolve(runtimeRoot, rootRef[1])
    }

    if (normalized.startsWith('./') || normalized.startsWith('../')) {
      return path.resolve(runtimeRoot, normalized)
    }

    return value
  }

  for (const relativePath of ['.mcp.json', 'mcp.json']) {
    const filepath = path.join(installDir, relativePath)
    if (!fs.existsSync(filepath)) continue

    const payload = JSON.parse(fs.readFileSync(filepath, 'utf8'))
    let changed = false

    for (const server of Object.values(payload.mcpServers || {})) {
      if (!server || typeof server !== 'object') continue

      if (typeof server.command === 'string') {
        const nextCommand = materializeInstalledStdioPath(server.command)
        changed ||= nextCommand !== server.command
        server.command = nextCommand
      }

      if (Array.isArray(server.args)) {
        const nextArgs = server.args.map(materializeInstalledStdioPath)
        changed ||= nextArgs.some((value, index) => value !== server.args[index])
        server.args = nextArgs
      }
    }

    if (changed) {
      fs.writeFileSync(filepath, JSON.stringify(payload, null, 2) + '\n')
    }
  }
}
NODE


if [[ -f "$PLUXX_TX_STAGE/.pluxx-runtime.json" || -f "$PLUXX_TX_STAGE/scripts/bootstrap-runtime.sh" ]]; then
  export PLUXX_RUNTIME_CANDIDATE_ROOT="$PLUXX_TX_STAGE"
  export PLUXX_RUNTIME_STORE_ROOT="${PLUXX_RUNTIME_STORE_ROOT:-$HOME/.pluxx/runtimes}"
  export PLUGIN_NAME PLUXX_TX_PLATFORM

  node <<'NODE'
const crypto = require('crypto')
const childProcess = require('child_process')
const fs = require('fs')
const path = require('path')

const candidateRoot = process.env.PLUXX_RUNTIME_CANDIDATE_ROOT
const pluginName = process.env.PLUGIN_NAME || 'unknown-plugin'
const installerPlatform = process.env.PLUXX_TX_PLATFORM || 'unknown-platform'
const contractVersion = 'pluxx.shared-native-runtime.v1'
if (!candidateRoot || !process.env.PLUXX_RUNTIME_STORE_ROOT) process.exit(2)

const configPath = path.join(candidateRoot, '.pluxx-runtime.json')
let bootstrapRelativePath = 'scripts/bootstrap-runtime.sh'
const bootstrapFailure = (status) => {
  const error = new Error('Runtime bootstrap failed with exit status ' + status + '.')
  error.exitStatus = status || 1
  return error
}
process.on('uncaughtException', (error) => {
  console.error(error && error.stack ? error.stack : String(error))
  process.exitCode = Number.isInteger(error && error.exitStatus) ? error.exitStatus : 1
})
const bootstrapLocal = () => {
  console.log('Preparing local plugin runtime dependencies...')
  const result = childProcess.spawnSync('bash', [path.join(candidateRoot, bootstrapRelativePath)], {
    cwd: candidateRoot,
    env: process.env,
    stdio: 'inherit',
  })
  if (result.error) throw result.error
  if (result.status !== 0) throw bootstrapFailure(result.status)
}

if (!fs.existsSync(configPath)) {
  bootstrapLocal()
  process.exit(0)
}

const config = JSON.parse(fs.readFileSync(configPath, 'utf8'))
const isSafeRelativePath = (value) => typeof value === 'string'
  && value.length > 0
  && !path.isAbsolute(value)
  && !value.replace(/\\/g, '/').split('/').includes('..')
if (config.schema !== 'pluxx.shared-runtime-config.v1'
  || config.namespace !== pluginName
  || !isSafeRelativePath(config.bootstrap)
  || !isSafeRelativePath(config.output)
  || path.normalize(config.output) === '.'
  || !Array.isArray(config.inputs)
  || config.inputs.length === 0
  || !config.inputs.every(isSafeRelativePath)) {
  throw new Error('Invalid .pluxx-runtime.json shared runtime contract.')
}
const hasDeclaredLockfile = config.inputs.some((relativePath) => {
  const basename = path.basename(relativePath).toLowerCase()
  return basename === 'bun.lockb' || /(?:^|[-_.])(lock|lockfile|shrinkwrap)(?:[-_.]|$)/.test(basename)
})
if (!hasDeclaredLockfile) {
  console.error('Shared runtime inputs do not declare a deterministic lockfile; preparing runtime in the host bundle instead.')
  bootstrapRelativePath = config.bootstrap
  bootstrapLocal()
  process.exit(0)
}
const resolvedOutput = path.resolve(candidateRoot, config.output)
for (const runtimeInput of [config.bootstrap, ...config.inputs]) {
  const resolvedInput = path.resolve(candidateRoot, runtimeInput)
  const relativeToOutput = path.relative(resolvedOutput, resolvedInput)
  if (relativeToOutput === '' || (!relativeToOutput.startsWith('..') && !path.isAbsolute(relativeToOutput))) {
    throw new Error('Shared runtime output must not contain its bootstrap or declared inputs.')
  }
}
bootstrapRelativePath = config.bootstrap

const inputPaths = [...new Set([config.bootstrap, ...config.inputs])].sort()
const digest = crypto.createHash('sha256')
digest.update(contractVersion + '\0' + process.platform + '\0' + process.arch + '\0' + (process.versions.modules || 'unknown-node-abi') + '\0')
digest.update(JSON.stringify(config) + '\0')
for (const relativePath of inputPaths) {
  const filepath = path.resolve(candidateRoot, relativePath)
  const relative = path.relative(candidateRoot, filepath)
  const stats = fs.lstatSync(filepath)
  if (relative.startsWith('..') || !stats.isFile() || stats.isSymbolicLink()) {
    throw new Error('Shared runtime input must be a regular file inside the bundle: ' + relativePath)
  }
  digest.update(relativePath + '\0')
  digest.update(fs.readFileSync(filepath))
  digest.update('\0')
}

const fingerprint = digest.digest('hex')
fs.mkdirSync(process.env.PLUXX_RUNTIME_STORE_ROOT, { recursive: true, mode: 0o700 })
fs.chmodSync(process.env.PLUXX_RUNTIME_STORE_ROOT, 0o700)
const storeRoot = fs.realpathSync(process.env.PLUXX_RUNTIME_STORE_ROOT)
const entryRoot = path.join(storeRoot, 'entries', fingerprint)
const generationsRoot = path.join(entryRoot, 'generations')
const currentPath = path.join(entryRoot, 'current')
const lockPath = path.join(storeRoot, 'locks', fingerprint + '.lock')
const stageRoot = path.join(storeRoot, 'staging', fingerprint + '-' + process.pid + '-' + crypto.randomBytes(6).toString('hex'))
const makeTreeWritable = (filepath) => {
  if (!fs.existsSync(filepath)) return
  const stats = fs.lstatSync(filepath)
  if (stats.isSymbolicLink()) return
  fs.chmodSync(filepath, stats.isDirectory() ? 0o700 : (stats.mode | 0o600))
  if (stats.isDirectory()) for (const entry of fs.readdirSync(filepath)) makeTreeWritable(path.join(filepath, entry))
}
const removeTree = (filepath) => {
  makeTreeWritable(filepath)
  fs.rmSync(filepath, { recursive: true, force: true, maxRetries: 5, retryDelay: 50 })
}
for (const directory of [path.dirname(entryRoot), generationsRoot, path.dirname(lockPath), path.dirname(stageRoot)]) {
  fs.mkdirSync(directory, { recursive: true, mode: 0o700 })
}

const sleep = (milliseconds) => Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, milliseconds)
const processAlive = (pid) => {
  try { process.kill(pid, 0); return true } catch (error) { return error && error.code === 'EPERM' }
}
let ownedLockNonce
const releaseLock = () => {
  if (!ownedLockNonce) return
  try {
    const owner = JSON.parse(fs.readFileSync(path.join(lockPath, 'owner.json'), 'utf8'))
    if (owner.nonce === ownedLockNonce) removeTree(lockPath)
  } catch {}
  ownedLockNonce = undefined
}
const acquireLock = () => {
  const timeoutMs = Math.max(0, Number(process.env.PLUXX_RUNTIME_LOCK_TIMEOUT_SECONDS || 120) * 1000)
  const started = Date.now()
  while (true) {
    const candidateLock = lockPath + '.candidate-' + process.pid + '-' + crypto.randomBytes(4).toString('hex')
    try {
      const nonce = crypto.randomBytes(16).toString('hex')
      fs.mkdirSync(candidateLock, { mode: 0o700 })
      fs.writeFileSync(path.join(candidateLock, 'owner.json'), JSON.stringify({ pid: process.pid, nonce, startedAt: new Date().toISOString() }) + '\n', { mode: 0o600 })
      fs.renameSync(candidateLock, lockPath)
      ownedLockNonce = nonce
      return true
    } catch (error) {
      removeTree(candidateLock)
      if (!error || !['EEXIST', 'ENOTEMPTY'].includes(error.code)) throw error
      let stale = false
      try {
        const owner = JSON.parse(fs.readFileSync(path.join(lockPath, 'owner.json'), 'utf8'))
        stale = !Number.isInteger(owner.pid) || owner.pid <= 0 || !processAlive(owner.pid)
      } catch {
        try { stale = Date.now() - fs.statSync(lockPath).mtimeMs > 2000 } catch { stale = true }
      }
      if (stale) {
        const recoveryLock = lockPath + '.recovery'
        let recoveryAcquired = false
        let staleLockRemoved = false
        try {
          fs.mkdirSync(recoveryLock, { mode: 0o700 })
          recoveryAcquired = true
          let stillStale = false
          try {
            const owner = JSON.parse(fs.readFileSync(path.join(lockPath, 'owner.json'), 'utf8'))
            stillStale = !Number.isInteger(owner.pid) || owner.pid <= 0 || !processAlive(owner.pid)
          } catch {
            try { stillStale = Date.now() - fs.statSync(lockPath).mtimeMs > 2000 } catch { stillStale = false }
          }
          if (stillStale) {
            removeTree(lockPath)
            staleLockRemoved = true
          }
        } catch (recoveryError) {
          if (!recoveryError || recoveryError.code !== 'EEXIST') throw recoveryError
        } finally {
          if (recoveryAcquired) try { fs.rmdirSync(recoveryLock) } catch {}
        }
        if (staleLockRemoved) continue
      }
      if (Date.now() - started >= timeoutMs) return false
      sleep(250)
    }
  }
}

const outputWithin = (root, filepath) => {
  const relative = path.relative(root, filepath)
  return relative === '' || (!relative.startsWith('..') && !path.isAbsolute(relative))
}
const collectMetadata = (root) => {
  const entries = []
  const visit = (directory) => {
    for (const entry of fs.readdirSync(directory, { withFileTypes: true }).sort((a, b) => a.name.localeCompare(b.name))) {
      const filepath = path.join(directory, entry.name)
      const relativePath = path.relative(root, filepath).replace(/\\/g, '/')
      const stats = fs.lstatSync(filepath)
      if (stats.isSymbolicLink()) {
        const resolved = fs.realpathSync(filepath)
        if (!outputWithin(root, resolved)) throw new Error('Shared runtime symlink escapes its output: ' + relativePath)
        entries.push({ path: relativePath, kind: 'symlink', target: fs.readlinkSync(filepath) })
      } else if (stats.isDirectory()) {
        visit(filepath)
      } else if (stats.isFile()) {
        entries.push({ path: relativePath, kind: 'file', size: stats.size, mtimeMs: stats.mtimeMs, mode: stats.mode & 0o777 })
      } else {
        throw new Error('Unsupported shared runtime entry: ' + relativePath)
      }
    }
  }
  visit(root)
  return entries
}
const harden = (root) => {
  const visit = (directory) => {
    for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
      const filepath = path.join(directory, entry.name)
      const stats = fs.lstatSync(filepath)
      if (stats.isSymbolicLink()) continue
      if (stats.isDirectory()) { visit(filepath); fs.chmodSync(filepath, stats.mode & ~0o222) }
      else if (stats.isFile()) fs.chmodSync(filepath, stats.mode & ~0o222)
    }
  }
  visit(root)
  fs.chmodSync(root, fs.statSync(root).mode & ~0o222)
}
const readCurrentGeneration = () => {
  try {
    if (!fs.lstatSync(currentPath).isSymbolicLink()) return undefined
    const target = fs.readlinkSync(currentPath)
    const generation = path.resolve(entryRoot, target)
    if (!outputWithin(generationsRoot, generation) || generation === generationsRoot) return undefined
    const manifest = JSON.parse(fs.readFileSync(path.join(generation, 'manifest.json'), 'utf8'))
    const outputRoot = path.join(generation, config.output)
    const outputStats = fs.lstatSync(outputRoot)
    if (!outputStats.isDirectory() || outputStats.isSymbolicLink()) return undefined
    if (manifest.schema !== contractVersion
      || manifest.fingerprint !== fingerprint
      || manifest.namespace !== pluginName
      || manifest.platform !== process.platform
      || manifest.arch !== process.arch
      || manifest.nodeAbi !== (process.versions.modules || 'unknown-node-abi')
      || JSON.stringify(collectMetadata(outputRoot)) !== JSON.stringify(manifest.entries)) return undefined
    return generation
  } catch { return undefined }
}
const buildGeneration = (repairing) => {
  console.log((repairing ? 'Repairing incomplete Pluxx native runtime ' : 'Preparing shared Pluxx native runtime ') + fingerprint + '.')
  removeTree(stageRoot)
  fs.cpSync(candidateRoot, stageRoot, { recursive: true })
  const stageOutput = path.join(stageRoot, config.output)
  fs.rmSync(stageOutput, { recursive: true, force: true })
  const bootstrapPath = path.join(stageRoot, config.bootstrap)
  const result = childProcess.spawnSync('bash', [bootstrapPath], { cwd: stageRoot, env: process.env, stdio: 'inherit' })
  if (result.error) throw result.error
  if (result.status !== 0) throw bootstrapFailure(result.status)
  const outputStats = fs.lstatSync(stageOutput)
  if (!outputStats.isDirectory() || outputStats.isSymbolicLink()) throw new Error('Shared runtime bootstrap did not create the configured output directory.')
  collectMetadata(stageOutput)
  const generation = path.join(generationsRoot, Date.now() + '-' + process.pid + '-' + crypto.randomBytes(5).toString('hex'))
  fs.mkdirSync(generation, { recursive: true, mode: 0o700 })
  const generationOutput = path.join(generation, config.output)
  fs.mkdirSync(path.dirname(generationOutput), { recursive: true })
  fs.renameSync(stageOutput, generationOutput)
  harden(generationOutput)
  const manifest = {
    schema: contractVersion,
    fingerprint,
    namespace: pluginName,
    platform: process.platform,
    arch: process.arch,
    nodeAbi: process.versions.modules || 'unknown-node-abi',
    preparedBy: installerPlatform,
    entries: collectMetadata(generationOutput),
    createdAt: new Date().toISOString(),
  }
  fs.writeFileSync(path.join(generation, 'manifest.json'), JSON.stringify(manifest, null, 2) + '\n', { mode: 0o444 })
  const nextCurrent = path.join(entryRoot, '.current-' + process.pid + '-' + crypto.randomBytes(5).toString('hex'))
  fs.symlinkSync(path.relative(entryRoot, generation), nextCurrent, 'dir')
  fs.renameSync(nextCurrent, currentPath)
  removeTree(stageRoot)
  return generation
}

if (!acquireLock()) {
  console.error('Could not acquire shared runtime lock for ' + fingerprint + '; preparing runtime in the host bundle instead.')
  bootstrapLocal()
  process.exit(0)
}

try {
  let generation = readCurrentGeneration()
  if (generation) console.log('Reusing prepared Pluxx native runtime ' + fingerprint + '.')
  else generation = buildGeneration(fs.existsSync(currentPath))

  const candidateOutput = path.join(candidateRoot, config.output)
  fs.rmSync(candidateOutput, { recursive: true, force: true })
  let leasePath
  try {
    if (process.env.PLUXX_RUNTIME_DISABLE_LINK === '1') throw new Error('shared runtime linking is disabled')
    fs.mkdirSync(path.dirname(candidateOutput), { recursive: true })
    fs.symlinkSync(path.join(entryRoot, 'current', config.output), candidateOutput, 'dir')
    const leaseRoot = path.join(storeRoot, 'leases', fingerprint)
    fs.mkdirSync(leaseRoot, { recursive: true, mode: 0o700 })
    leasePath = path.join(leaseRoot, process.ppid + '-' + crypto.randomBytes(6).toString('hex') + '.json')
    fs.writeFileSync(leasePath, JSON.stringify({
      schema: 'pluxx.shared-native-runtime-lease.v1',
      fingerprint,
      ownerPid: process.ppid,
      createdAt: new Date().toISOString(),
    }) + '\n', { mode: 0o600, flag: 'wx' })
    fs.writeFileSync(path.join(candidateRoot, '.pluxx-runtime-ref.json'), JSON.stringify({
      schema: 'pluxx.shared-native-runtime-ref-candidate.v1',
      storeRoot,
      fingerprint,
      runtimeEntry: path.join(entryRoot, 'current'),
      leasePath,
    }, null, 2) + '\n', { mode: 0o600 })
  } catch (error) {
    console.error('Could not link the shared runtime; preparing runtime in the host bundle instead: ' + error.message)
    if (leasePath) fs.rmSync(leasePath, { force: true })
    fs.rmSync(candidateOutput, { recursive: true, force: true })
    bootstrapLocal()
  }
} finally {
  removeTree(stageRoot)
  releaseLock()
}
NODE
fi

CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
CODEX_CONFIG_PATH="${PLUXX_CODEX_CONFIG_PATH:-$CODEX_HOME_DIR/config.toml}"
pluxx_tx_backup_owned_path "$CODEX_HOME_DIR/agents/$PLUGIN_NAME"
pluxx_tx_backup_owned_path "$CODEX_HOME_DIR/pluxx/agent-installs/$PLUGIN_NAME.json"
pluxx_tx_backup_owned_path "$CODEX_HOME_DIR/plugins/cache/local-plugins/$PLUGIN_NAME"
pluxx_tx_backup_owned_path "$CODEX_CONFIG_PATH"
pluxx_tx_backup_owned_path "$MARKETPLACE_PATH"
pluxx_swap_install_transaction

export PLUXX_INSTALL_DIR="$INSTALL_DIR"
export PLUXX_CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
export PLUGIN_NAME

node <<'NODE'
const crypto = require('crypto')
const fs = require('fs')
const path = require('path')

const installDir = process.env.PLUXX_INSTALL_DIR
const codexHome = process.env.PLUXX_CODEX_HOME_DIR
const pluginName = process.env.PLUGIN_NAME
if (!installDir || !codexHome || !pluginName) process.exit(0)
if (!/^[A-Za-z0-9][A-Za-z0-9._-]*$/.test(pluginName)) {
  throw new Error('Cannot register Codex agents for an invalid plugin name.')
}

fs.rmSync(path.join(codexHome, 'plugins/cache/local-plugins', pluginName), {
  recursive: true,
  force: true,
})

const sourceRoot = path.join(installDir, '.codex/agents')
const globalAgentRoot = path.join(codexHome, 'agents')
const agentRoot = path.join(globalAgentRoot, pluginName)
const ownershipPath = path.join(codexHome, 'pluxx/agent-installs', pluginName + '.json')
const ownershipSchema = 'pluxx.codex-agent-install.v1'

const walkToml = (root) => {
  if (!fs.existsSync(root)) return []
  const files = []
  for (const entry of fs.readdirSync(root, { withFileTypes: true })) {
    const filepath = path.join(root, entry.name)
    if (entry.isDirectory()) files.push(...walkToml(filepath))
    else if (entry.isFile() && entry.name.endsWith('.toml')) files.push(filepath)
  }
  return files.sort()
}

const hash = (content) => crypto.createHash('sha256').update(content).digest('hex')
const readString = (content, key) => {
  const match = content.match(new RegExp('^\\s*' + key + '\\s*=\\s*("(?:\\\\.|[^"\\\\])*")', 'm'))
  if (!match) return undefined
  try { return JSON.parse(match[1]) } catch { return undefined }
}
const hasAssignment = (content, key) => new RegExp('^\\s*' + key + '\\s*=', 'm').test(content)
const safeRelative = (value) => {
  if (typeof value !== 'string' || !value || path.isAbsolute(value)) return false
  const normalized = value.replace(/\\/g, '/')
  return normalized !== '..' && !normalized.startsWith('../') && !normalized.includes('/../')
}
const resolveAgentPath = (relativePath) => {
  if (!safeRelative(relativePath)) throw new Error('Unsafe Codex agent ownership path: ' + relativePath)
  const filepath = path.resolve(agentRoot, relativePath)
  if (filepath === agentRoot || !filepath.startsWith(agentRoot + path.sep)) {
    throw new Error('Unsafe Codex agent ownership path: ' + relativePath)
  }
  return filepath
}

const agents = []
const sourceNames = new Set()
for (const sourcePath of walkToml(sourceRoot)) {
  const content = fs.readFileSync(sourcePath, 'utf8')
  const name = readString(content, 'name')
  const description = readString(content, 'description')
  if (!name || !description || !hasAssignment(content, 'developer_instructions')) {
    throw new Error('Invalid Codex custom agent at ' + sourcePath + ': name, description, and developer_instructions are required.')
  }
  if (sourceNames.has(name)) throw new Error('Duplicate bundled Codex agent name: ' + name)
  sourceNames.add(name)
  const relativePath = path.relative(sourceRoot, sourcePath).replace(/\\/g, '/')
  agents.push({ name, relativePath, content, sha256: hash(content) })
}

let previous = { schema: ownershipSchema, pluginName, agents: [] }
if (fs.existsSync(ownershipPath)) {
  previous = JSON.parse(fs.readFileSync(ownershipPath, 'utf8'))
  if (previous.schema !== ownershipSchema || previous.pluginName !== pluginName || !Array.isArray(previous.agents)) {
    throw new Error('Invalid Codex agent ownership record: ' + ownershipPath)
  }
  for (const agent of previous.agents) {
    if (!agent || typeof agent.name !== 'string' || !safeRelative(agent.relativePath) || !/^[a-f0-9]{64}$/.test(agent.sha256 || '')) {
      throw new Error('Invalid Codex agent ownership entry: ' + ownershipPath)
    }
  }
}

const replaceableOwnedPaths = new Set()
for (const agent of previous.agents) {
  const ownedPath = resolveAgentPath(agent.relativePath)
  if (!fs.existsSync(ownedPath)) continue
  if (hash(fs.readFileSync(ownedPath, 'utf8')) === agent.sha256) {
    replaceableOwnedPaths.add(ownedPath)
  }
}

const expectedPaths = new Map(agents.map((agent) => [agent.name, resolveAgentPath(agent.relativePath)]))
for (const filepath of walkToml(globalAgentRoot)) {
  if (replaceableOwnedPaths.has(filepath)) continue
  const name = readString(fs.readFileSync(filepath, 'utf8'), 'name')
  const expectedPath = expectedPaths.get(name)
  if (expectedPath && filepath !== expectedPath) {
    throw new Error('Codex agent name collision for "' + name + '": ' + filepath)
  }
}

const previousByPath = new Map(previous.agents.map((agent) => [agent.relativePath, agent]))
for (const agent of agents) {
  const destination = resolveAgentPath(agent.relativePath)
  if (fs.existsSync(destination)) {
    const currentHash = hash(fs.readFileSync(destination, 'utf8'))
    const owned = previousByPath.get(agent.relativePath)
    if (currentHash !== agent.sha256 && (!owned || owned.sha256 !== currentHash)) {
      throw new Error('Refusing to replace modified or unowned Codex agent "' + agent.name + '" at ' + destination)
    }
  }
  fs.mkdirSync(path.dirname(destination), { recursive: true })
  fs.writeFileSync(destination, agent.content)
}

const nextPaths = new Set(agents.map((agent) => agent.relativePath))
let removed = 0
for (const owned of previous.agents) {
  if (nextPaths.has(owned.relativePath)) continue
  const destination = resolveAgentPath(owned.relativePath)
  if (!fs.existsSync(destination)) continue
  if (hash(fs.readFileSync(destination, 'utf8')) === owned.sha256) {
    fs.rmSync(destination, { force: true })
    removed += 1
  } else {
    console.warn('Preserved user-modified Codex agent at ' + destination)
  }
}

if (agents.length > 0) {
  fs.mkdirSync(path.dirname(ownershipPath), { recursive: true })
  fs.writeFileSync(ownershipPath, JSON.stringify({
    schema: ownershipSchema,
    pluginName,
    agents: agents.map(({ name, relativePath, sha256 }) => ({ name, relativePath, sha256 })),
  }, null, 2) + '\n')
} else {
  fs.rmSync(ownershipPath, { force: true })
}

if (agents.length > 0 || removed > 0) {
  console.log('Registered ' + agents.length + ' Codex custom agent(s) under ' + agentRoot + (removed ? '; removed ' + removed + ' stale owned registration(s)' : ''))
}
NODE


export PLUXX_INSTALL_DIR="$INSTALL_DIR"

trap - ERR
set +e
node <<'NODE'
const fs = require('fs')
const path = require('path')

const installDir = process.env.PLUXX_INSTALL_DIR
if (!installDir) process.exit(0)

const manifestPath = path.join(installDir, '.codex-plugin/plugin.json')
const standardHooksPath = path.join(installDir, 'hooks/hooks.json')
let hasPluginHooks = fs.existsSync(standardHooksPath)

if (fs.existsSync(manifestPath)) {
  try {
    const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'))
    const manifestHooks = manifest.hooks
    hasPluginHooks ||= typeof manifestHooks === 'string' && manifestHooks.trim().length > 0
    hasPluginHooks ||= Array.isArray(manifestHooks) && manifestHooks.length > 0
    hasPluginHooks ||= manifestHooks && typeof manifestHooks === 'object' && Object.keys(manifestHooks).length > 0
    hasPluginHooks ||= manifestHooks === true
  } catch {}
}

process.exit(hasPluginHooks ? 0 : 2)
NODE
PLUXX_CODEX_BUNDLE_HAS_HOOKS="$?"
set -e
trap rollback_install ERR

if [[ "$PLUXX_CODEX_BUNDLE_HAS_HOOKS" == "0" ]]; then
  CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
  CODEX_CONFIG_PATH="${PLUXX_CODEX_CONFIG_PATH:-$CODEX_HOME_DIR/config.toml}"
  PLUXX_CODEX_HOOKS_MODE="${PLUXX_CODEX_ENABLE_PLUGIN_HOOKS:-prompt}"

  export CODEX_CONFIG_PATH
  if node <<'NODE'
const fs = require('fs')
const filepath = process.env.CODEX_CONFIG_PATH

function stripTomlComment(line) {
  let quote = null
  let escaped = false
  for (let index = 0; index < line.length; index += 1) {
    const char = line[index]
    if (escaped) {
      escaped = false
      continue
    }
    if (quote && char === '\\') {
      escaped = true
      continue
    }
    if (char === '"' || char === "'") {
      quote = quote === char ? null : quote || char
      continue
    }
    if (!quote && char === '#') return line.slice(0, index)
  }
  return line
}

function isTomlTrue(rawValue) {
  return /^true\b/i.test(rawValue.trim())
}

let text = ''
try {
  text = fs.readFileSync(filepath, 'utf8')
} catch {
  process.exit(1)
}
const lines = text.split(/\r?\n/)
let tableName = ''
for (const line of lines) {
  const trimmed = stripTomlComment(line).trim()
  if (!trimmed) continue
  const tableMatch = trimmed.match(/^\[([^\]]+)\]$/)
  if (tableMatch) {
    tableName = tableMatch[1].trim()
    continue
  }
  if (tableName === '') {
    const dottedMatch = trimmed.match(/^features\.hooks\s*=\s*(.+)$/)
    if (dottedMatch && isTomlTrue(dottedMatch[1])) process.exit(0)
    const inlineMatch = trimmed.match(/^features\s*=\s*(.+)$/)
    if (inlineMatch && /\bhooks\s*=\s*true\b/i.test(inlineMatch[1])) process.exit(0)
  }
  if (tableName !== 'features') continue
  const match = trimmed.match(/^hooks\s*=\s*(.+)$/)
  if (match && isTomlTrue(match[1])) process.exit(0)
}
process.exit(1)
NODE
  then
    echo "Codex plugin-bundled hooks already enabled in $CODEX_CONFIG_PATH."
  else
    PLUXX_ENABLE_CODEX_HOOKS="0"
    case "$PLUXX_CODEX_HOOKS_MODE" in
      1|true|TRUE|yes|YES|always|ALWAYS)
        PLUXX_ENABLE_CODEX_HOOKS="1"
        ;;
      0|false|FALSE|no|NO|never|NEVER|skip|SKIP)
        PLUXX_ENABLE_CODEX_HOOKS="0"
        ;;
      *)
        if [[ -r /dev/tty ]]; then
          echo "This Codex plugin bundle includes startup hooks." >/dev/tty
          echo "Codex requires [features].hooks = true before plugin-bundled hooks can run." >/dev/tty
          read -r -p "Enable Codex plugin-bundled hooks in $CODEX_CONFIG_PATH now? [Y/n] " PLUXX_CODEX_HOOKS_REPLY </dev/tty
          case "$PLUXX_CODEX_HOOKS_REPLY" in
            n|N|no|NO)
              PLUXX_ENABLE_CODEX_HOOKS="0"
              ;;
            *)
              PLUXX_ENABLE_CODEX_HOOKS="1"
              ;;
          esac
        fi
        ;;
    esac

    if [[ "$PLUXX_ENABLE_CODEX_HOOKS" == "1" ]]; then
      mkdir -p "$(dirname "$CODEX_CONFIG_PATH")"
      node <<'NODE'
const fs = require('fs')
const path = require('path')

const filepath = process.env.CODEX_CONFIG_PATH

function stripTomlComment(line) {
  let quote = null
  let escaped = false
  for (let index = 0; index < line.length; index += 1) {
    const char = line[index]
    if (escaped) {
      escaped = false
      continue
    }
    if (quote && char === '\\') {
      escaped = true
      continue
    }
    if (char === '"' || char === "'") {
      quote = quote === char ? null : quote || char
      continue
    }
    if (!quote && char === '#') return line.slice(0, index)
  }
  return line
}

let text = ''
try {
  text = fs.readFileSync(filepath, 'utf8')
} catch {}

const lines = text.split(/\r?\n/)
if (lines.length === 1 && lines[0] === '') lines.pop()

let start = -1
let end = lines.length
let firstTopLevelFeaturesDotted = -1
let topLevelPluginHooksDotted = -1
let topLevelInlineFeatures = -1
let tableName = ''
for (let index = 0; index < lines.length; index += 1) {
  const trimmed = stripTomlComment(lines[index]).trim()
  const tableMatch = trimmed.match(/^\[([^\]]+)\]$/)
  if (tableMatch) tableName = tableMatch[1].trim()

  if (trimmed === '[features]') {
    start = index
    break
  }

  if (tableName === '') {
    if (/^features\.[A-Za-z0-9_-]+\s*=/.test(trimmed) && firstTopLevelFeaturesDotted < 0) {
      firstTopLevelFeaturesDotted = index
    }
    if (/^features\.hooks\s*=/.test(trimmed)) {
      topLevelPluginHooksDotted = index
    }
    if (/^features\s*=\s*\{/.test(trimmed)) {
      topLevelInlineFeatures = index
    }
  }
}

if (start >= 0) {
  for (let index = start + 1; index < lines.length; index += 1) {
    if (/^\s*\[[^\]]+\]/.test(stripTomlComment(lines[index]))) {
      end = index
      break
    }
  }

  let updated = false
  for (let index = start + 1; index < end; index += 1) {
    if (/^hooks\s*=/.test(stripTomlComment(lines[index]).trim())) {
      lines[index] = 'hooks = true'
      updated = true
    }
  }
  if (!updated) lines.splice(start + 1, 0, 'hooks = true')
} else if (topLevelPluginHooksDotted >= 0) {
  lines[topLevelPluginHooksDotted] = 'features.hooks = true'
} else if (firstTopLevelFeaturesDotted >= 0) {
  lines.splice(firstTopLevelFeaturesDotted + 1, 0, 'features.hooks = true')
} else if (topLevelInlineFeatures >= 0 && lines[topLevelInlineFeatures].includes('}')) {
  if (/\bhooks\s*=/.test(lines[topLevelInlineFeatures])) {
    lines[topLevelInlineFeatures] = lines[topLevelInlineFeatures].replace(
      /\bhooks\s*=\s*(true|false)\b/i,
      'hooks = true',
    )
  } else {
    lines[topLevelInlineFeatures] = lines[topLevelInlineFeatures].replace(/}/, ', hooks = true }')
  }
} else {
  if (lines.length > 0 && lines[lines.length - 1] !== '') lines.push('')
  lines.push('[features]', 'hooks = true')
}

fs.mkdirSync(path.dirname(filepath), { recursive: true })
fs.writeFileSync(filepath, lines.join('\n') + '\n')
NODE
      echo "Enabled Codex plugin-bundled hooks in $CODEX_CONFIG_PATH."
      echo "Restart or refresh Codex before relying on plugin startup hooks."
    else
      echo "Codex plugin-bundled hooks are not enabled. Startup hooks from this plugin will not run until you add this to $CODEX_CONFIG_PATH:" >&2
      echo "[features]" >&2
      echo "hooks = true" >&2
      echo "Then restart or refresh Codex before relying on plugin startup hooks." >&2
      echo "Set PLUXX_CODEX_ENABLE_PLUGIN_HOOKS=1 before running this installer to enable it noninteractively." >&2
    fi
  fi
fi


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
pluxx_finalize_install_transaction

echo "Installed $PLUGIN_NAME to $INSTALL_DIR"
echo "Updated Codex marketplace catalog at $MARKETPLACE_PATH"
echo "If Codex is already open, use Plugins > Refresh if that action is available in your current UI, or restart Codex so the plugin is picked up."
