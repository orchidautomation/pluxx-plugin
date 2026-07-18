#!/usr/bin/env node

import assert from 'node:assert/strict'
import { chmodSync, mkdirSync, mkdtempSync, readFileSync, writeFileSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { delimiter, join, resolve } from 'node:path'
import { spawnSync } from 'node:child_process'

const rootDir = process.cwd()
const proofRoot = mkdtempSync(join(tmpdir(), 'pluxx checkout proof-'))
const fakeBin = join(proofRoot, 'bin')
const fakeGit = join(fakeBin, 'git')
const invocationLog = join(proofRoot, 'git-invocations.txt')

mkdirSync(fakeBin, { recursive: true })
writeFileSync(fakeGit, `#!/usr/bin/env bash
printf '%s\\n' "$*" >> "$PLUXX_FAKE_GIT_LOG"
exit 1
`)
chmodSync(fakeGit, 0o755)

const run = spawnSync(resolve(rootDir, 'scripts/prepare-pluxx-checkout.sh'), [], {
  cwd: rootDir,
  env: {
    ...process.env,
    PATH: `${fakeBin}${delimiter}${process.env.PATH ?? ''}`,
    PLUXX_CLONE_ATTEMPTS: '2',
    PLUXX_CLONE_LOW_SPEED_TIME: '1',
    PLUXX_FAKE_GIT_LOG: invocationLog,
    PLUXX_REPO_DIR: join(proofRoot, 'pluxx-cli'),
  },
  encoding: 'utf8',
})

assert.notEqual(run.status, 0, 'Pinned checkout preparation must fail when every clone attempt fails')
assert.match(run.stderr, /Failed to clone pinned Pluxx after 2 attempt\(s\)\./)

const invocations = readFileSync(invocationLog, 'utf8').trim().split('\n')
assert.equal(invocations.length, 2, 'Pinned checkout preparation must stop at the configured attempt bound')
for (const invocation of invocations) {
  assert.match(invocation, /-c http\.lowSpeedLimit=1/)
  assert.match(invocation, /-c http\.lowSpeedTime=1/)
  assert.match(invocation, /clone --depth 1 --branch v0\.1\.36/)
}

process.stdout.write(`${JSON.stringify({
  attempts: invocations.length,
  lowSpeedTimeSeconds: 1,
  result: 'pass',
}, null, 2)}\n`)
