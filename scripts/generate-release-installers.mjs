#!/usr/bin/env node

import { execFileSync, spawnSync } from 'node:child_process'
import { copyFileSync, existsSync, mkdirSync, readFileSync } from 'node:fs'
import { basename, join, resolve } from 'node:path'
import { pathToFileURL } from 'node:url'

const rootDir = process.cwd()
const pluxxRepoDir = resolve(process.env.PLUXX_REPO_DIR ?? './pluxx-cli')
const pluxxModulePath = join(pluxxRepoDir, 'src/index.ts')
const tsxApiPath = join(pluxxRepoDir, 'node_modules/tsx/dist/esm/api/index.mjs')

if (!existsSync(pluxxModulePath) || !existsSync(tsxApiPath)) {
  throw new Error(`Prepare the pinned Pluxx checkout and install its dependencies first: missing ${pluxxModulePath} or ${tsxApiPath}`)
}

execFileSync(join(rootDir, 'scripts/prepare-pluxx-checkout.sh'), {
  cwd: rootDir,
  env: { ...process.env, PLUXX_REPO_DIR: pluxxRepoDir },
  stdio: 'inherit',
})

const configSource = readFileSync(join(rootDir, 'pluxx.config.ts'), 'utf8')
  .replace("import { definePlugin } from 'pluxx'", 'const definePlugin = (config) => config')
const configModule = await import(`data:text/javascript;base64,${Buffer.from(configSource).toString('base64')}`)
const config = configModule.default
const { tsImport } = await import(pathToFileURL(tsxApiPath).href)
const { runPublish } = await tsImport(pluxxModulePath, import.meta.url)
const releaseDir = join(rootDir, 'release')
const checkedInInstallers = new Set([
  'install-all.sh',
  'install-claude-code.sh',
  'install-codex.sh',
  'install-cursor.sh',
  'install-opencode.sh',
])

mkdirSync(releaseDir, { recursive: true })

let publishedFiles = []
let releaseCreated = false

function result(status, stdout = '', stderr = '') {
  return { status, stdout, stderr }
}

function runCommand(command, args, options = {}) {
  if (command !== 'gh') {
    const run = spawnSync(command, args, {
      cwd: options.cwd,
      encoding: 'utf8',
    })
    return result(run.status ?? 1, run.stdout ?? '', run.stderr ?? '')
  }

  if (args[0] === 'auth' && args[1] === 'status') return result(0, 'offline generation')

  if (args[0] === 'release' && args[1] === 'view') {
    if (!releaseCreated) return result(1, '', 'release not found')
    return result(0, JSON.stringify({
      tagName: `v${config.version}`,
      assets: publishedFiles.map((filepath) => ({ name: basename(filepath) })),
    }))
  }

  if (args[0] === 'release' && args[1] === 'create') {
    publishedFiles = args.filter((value) => value.startsWith('/') && existsSync(value))
    for (const filepath of publishedFiles) {
      const name = basename(filepath)
      if (checkedInInstallers.has(name)) copyFileSync(filepath, join(releaseDir, name))
    }
    releaseCreated = true
    return result(0, `Generated ${checkedInInstallers.size} checked-in installers without remote mutation.`)
  }

  if (args[0] === 'release' && args[1] === 'download') {
    const destination = args[args.indexOf('--dir') + 1]
    mkdirSync(destination, { recursive: true })
    for (const filepath of publishedFiles) copyFileSync(filepath, join(destination, basename(filepath)))
    return result(0)
  }

  return result(1, '', `Unsupported offline gh command: gh ${args.join(' ')}`)
}

const publish = runPublish(config, {
  rootDir,
  version: config.version,
  allowDirty: true,
  requestedChannels: ['github-release'],
  runCommand,
})

if (!publish.ok || !publish.execution?.githubRelease?.verified) {
  throw new Error(`Offline Pluxx release generation failed: ${JSON.stringify(publish.execution)}`)
}

for (const name of checkedInInstallers) {
  if (!existsSync(join(releaseDir, name))) throw new Error(`Pluxx did not generate ${name}`)
}

process.stdout.write(`Generated checked-in release installers for pluxx@${config.version} with pinned Pluxx ${pluxxRepoDir}.\n`)
