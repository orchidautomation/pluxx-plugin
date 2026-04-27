# Pluxx Plugin

Official first-party Pluxx plugin source for Claude Code, Cursor, Codex, and OpenCode.

See [docs/ultimate-pluxx-plugin.md](./docs/ultimate-pluxx-plugin.md) for the
target shape of the first-party plugin and the gap between the current helper
pack and the higher-bar multi-agent control plane we want to build.

The goal is not just to expose raw CLI commands inside another host. The
first-party Pluxx plugin should set the bar for:

- import and migration specialists
- host translation review
- installed behavioral proof
- runtime bootstrap and upgrade
- proof-packaging and release operators

## Get The Plugin

If you are trying to install the plugin and do **not** care about the source repo, use the release assets directly:

- [Latest release page](https://github.com/orchidautomation/pluxx-plugin/releases/latest)
- [Download Claude Code bundle](https://github.com/orchidautomation/pluxx-plugin/releases/latest/download/pluxx-claude-code-latest.tar.gz)
- [Download Cursor bundle](https://github.com/orchidautomation/pluxx-plugin/releases/latest/download/pluxx-cursor-latest.tar.gz)
- [Download Codex bundle](https://github.com/orchidautomation/pluxx-plugin/releases/latest/download/pluxx-codex-latest.tar.gz)
- [Download OpenCode bundle](https://github.com/orchidautomation/pluxx-plugin/releases/latest/download/pluxx-opencode-latest.tar.gz)
- [Download Claude installer script](https://github.com/orchidautomation/pluxx-plugin/releases/latest/download/install-claude-code.sh)
- [Download Cursor installer script](https://github.com/orchidautomation/pluxx-plugin/releases/latest/download/install-cursor.sh)
- [Download Codex installer script](https://github.com/orchidautomation/pluxx-plugin/releases/latest/download/install-codex.sh)
- [Download OpenCode installer script](https://github.com/orchidautomation/pluxx-plugin/releases/latest/download/install-opencode.sh)
- [Download core-four installer script](https://github.com/orchidautomation/pluxx-plugin/releases/latest/download/install-all.sh)

This repository's file list is the **source project**. The installable bundles live under **Releases**, not in the root file tree.

### Fastest Claude Code Install

If you want the plugin in Claude Code user scope right now:

```bash
curl -fsSL https://github.com/orchidautomation/pluxx-plugin/releases/latest/download/install-claude-code.sh | bash
```

That script:

1. downloads the latest Claude bundle
2. creates a local Claude marketplace
3. installs the `pluxx` plugin into your Claude Code user scope

If Claude is already open, run `/reload-plugins` after install.

### Fastest Cursor Install

```bash
curl -fsSL https://github.com/orchidautomation/pluxx-plugin/releases/latest/download/install-cursor.sh | bash
```

### Fastest Codex Install

```bash
curl -fsSL https://github.com/orchidautomation/pluxx-plugin/releases/latest/download/install-codex.sh | bash
```

### Fastest OpenCode Install

```bash
curl -fsSL https://github.com/orchidautomation/pluxx-plugin/releases/latest/download/install-opencode.sh | bash
```

### Install Across The Core Four

```bash
curl -fsSL https://github.com/orchidautomation/pluxx-plugin/releases/latest/download/install-all.sh | bash
```

## Source vs Download

- Want to **use/install** the plugin: go to [Releases](https://github.com/orchidautomation/pluxx-plugin/releases/latest)
- Want to **edit/maintain** the plugin: use this repository source directly

This repository is the canonical Pluxx source project for the Pluxx plugin itself. It contains the maintained cross-host source files:

- `pluxx.config.ts`
- `INSTRUCTIONS.md`
- `skills/`
- `commands/`
- `assets/`

Generated host bundles are build artifacts and are not checked into this repository.

## Where The Built Bundles Live

This repository is source-first, so `dist/` is not committed.

Built platform bundles are published as release assets:

- `pluxx-claude-code-v<version>.tar.gz`
- `pluxx-cursor-v<version>.tar.gz`
- `pluxx-codex-v<version>.tar.gz`
- `pluxx-opencode-v<version>.tar.gz`
- `pluxx-claude-code-latest.tar.gz`
- `pluxx-cursor-latest.tar.gz`
- `pluxx-codex-latest.tar.gz`
- `pluxx-opencode-latest.tar.gz`
- `install-claude-code.sh`
- `install-cursor.sh`
- `install-codex.sh`
- `install-opencode.sh`
- `install-all.sh`
- `release-manifest.json`
- `SHA256SUMS.txt`

Download them from the repository's Releases page after each tagged release.

## What This Plugin Does

The Pluxx plugin gives host-native skills and command entrypoints for the main Pluxx workflows:

- import an MCP into a Pluxx project
- migrate an existing host-native plugin into Pluxx
- bootstrap or upgrade the underlying Pluxx runtime
- validate a scaffold
- prepare richer website/docs/local context
- refine taxonomy
- rewrite instructions
- review a scaffold
- review host translation quality across the core four
- build and install host bundles
- verify installed host state
- run installed behavioral proof with example queries
- sync an MCP-derived scaffold
- run the one-shot autopilot path
- package a public proof pack
- publish a plugin release

## Build Locally

Build this plugin with a local Pluxx checkout:

```bash
PLUXX_REPO_DIR=../pluxx ./scripts/build-with-pluxx-checkout.sh
```

Or invoke the CLI directly:

```bash
bun --cwd ../pluxx run build
node ../pluxx/bin/pluxx.js build
```

Or target a subset of hosts:

```bash
bun --cwd ../pluxx run build
node ../pluxx/bin/pluxx.js build --target claude-code cursor codex opencode
```

## CI And Release Automation

- `.github/workflows/ci.yml` validates the source project, uploads `dist/`, and dry-runs the core `pluxx publish --github-release` path
- `.github/workflows/release.yml` builds the core-four bundles and calls core `pluxx publish --github-release` on tags

## Local Proof

For the strongest deterministic local proof:

```bash
bun --cwd ../pluxx run build
node ../pluxx/bin/pluxx.js test --install --trust --behavioral --target claude-code cursor codex opencode
```

That behavioral lane reads this repo's installed example queries from
`.pluxx/behavioral-smoke.json`, so the plugin proves not just that bundles build
and install, but that the installed workflows respond credibly in the hosts.

## Notes

- This repository holds the official plugin source, not the Pluxx compiler/engine.
- The Pluxx CLI/package lives in the main project: [orchidautomation/pluxx](https://github.com/orchidautomation/pluxx)
- A future `pluxx-plugins` repository can serve as a broader gallery or registry. This repository is intentionally first-party and singular.
