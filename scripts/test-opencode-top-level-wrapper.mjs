#!/usr/bin/env node

import assert from 'node:assert/strict'
import { execFileSync } from 'node:child_process'
import { existsSync, mkdirSync, mkdtempSync, readFileSync, realpathSync, writeFileSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { dirname, join, resolve } from 'node:path'
import { pathToFileURL } from 'node:url'

const installerPath = resolve(process.argv[2] ?? 'release/install-opencode.sh')
const installer = readFileSync(installerPath, 'utf8')
const currentWrapperMatch = installer.match(/const currentOpenCodeWrapperContent = \(\) => ("(?:\\.|[^"\\])*")\n\s+\.replaceAll/)
const legacyGeneratorMatch = [...installer.matchAll(/node <<'NODE'\n([\s\S]*?)\nNODE/g)]
  .find((match) => match[1].includes('const content = [') && match[1].includes('pluginFactory'))

assert(currentWrapperMatch || legacyGeneratorMatch, `Could not find the OpenCode wrapper generator in ${installerPath}`)

const proofRoot = mkdtempSync(join(tmpdir(), 'pluxx top-level wrapper proof-'))
const launchDirectory = join(proofRoot, 'parent launch directory')
const workspaceRoot = join(proofRoot, 'selected workspace')
const pluginRootDirectory = join(proofRoot, 'installed plugins')
const pluginRoot = join(pluginRootDirectory, 'pluxx')
const entryPath = join(pluginRootDirectory, 'pluxx.ts')
const fabricatedNestedRoot = join(workspaceRoot, 'pluxx')

mkdirSync(launchDirectory, { recursive: true })
mkdirSync(workspaceRoot, { recursive: true })
mkdirSync(pluginRoot, { recursive: true })

writeFileSync(join(pluginRoot, 'index.ts'), `
import { dirname } from 'node:path'
import { fileURLToPath } from 'node:url'

export const Pluxx = async (context) => ({
  directory: context.directory,
  worktree: context.worktree,
  pluginRoot: dirname(fileURLToPath(import.meta.url)),
})
`)

if (currentWrapperMatch) {
  const currentWrapper = JSON.parse(currentWrapperMatch[1])
    .replaceAll('__PLUXX_RUNTIME_PLUGIN_NAME__', 'pluxx')
    .replaceAll('PLUXXRUNTIMEPLUGINNAME', 'Pluxx')
  writeFileSync(entryPath, currentWrapper)
} else {
  execFileSync(process.execPath, ['--input-type=commonjs', '--eval', legacyGeneratorMatch[1]], {
    env: {
      ...process.env,
      ENTRY_PATH: entryPath,
      PLUGIN_NAME: 'pluxx',
    },
    stdio: 'pipe',
  })
}

const proofScript = `
import { pathToFileURL } from 'node:url'

const wrapper = await import(pathToFileURL(process.env.ENTRY_PATH).href)
const plugin = Object.values(wrapper).find((value) => typeof value === 'function')
if (!plugin) throw new Error('Generated top-level wrapper did not export a plugin function')
const result = await plugin({
  directory: process.env.WORKSPACE_ROOT,
  worktree: process.env.WORKSPACE_ROOT,
})
process.stdout.write(JSON.stringify(result))
`

const output = execFileSync(process.execPath, ['--input-type=module', '--eval', proofScript], {
  cwd: launchDirectory,
  env: {
    ...process.env,
    ENTRY_PATH: entryPath,
    WORKSPACE_ROOT: workspaceRoot,
  },
  encoding: 'utf8',
})

const observed = JSON.parse(output)

assert.equal(existsSync(fabricatedNestedRoot), false, 'Proof fixture must not create a synthetic nested plugin directory')
assert.equal(observed.directory, workspaceRoot, 'Top-level wrapper must preserve context.directory exactly')
assert.equal(observed.worktree, workspaceRoot, 'Top-level wrapper must preserve the selected worktree')
assert.equal(observed.pluginRoot, realpathSync(pluginRoot), 'Inner bundle must resolve its install root from import.meta.url')

process.stdout.write(`${JSON.stringify({
  installer: installerPath,
  launchDirectory,
  workspaceRoot,
  pluginRoot,
  fabricatedNestedRootExists: existsSync(fabricatedNestedRoot),
  result: 'pass',
}, null, 2)}\n`)
