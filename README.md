# Pluxx Plugin

Official first-party Pluxx plugin source for Claude Code, Cursor, Codex, and OpenCode.

This repository is the canonical Pluxx source project for the Pluxx plugin itself. It contains the maintained cross-host source files:

- `pluxx.config.ts`
- `INSTRUCTIONS.md`
- `skills/`
- `commands/`
- `assets/`

Generated host bundles are build artifacts and are not checked into this repository.

## What This Plugin Does

The Pluxx plugin gives host-native skills and command entrypoints for the main Pluxx workflows:

- import an MCP into a Pluxx project
- migrate an existing host-native plugin into Pluxx
- validate a scaffold
- refine taxonomy
- rewrite instructions
- review a scaffold
- build and install host bundles
- sync an MCP-derived scaffold

## Build

Build this plugin with the Pluxx CLI:

```bash
pluxx build
```

Or target a subset of hosts:

```bash
pluxx build --target claude-code cursor codex opencode
```

## Local Proof

For the strongest deterministic local proof:

```bash
pluxx test --install --target claude-code cursor codex opencode
```

## Notes

- This repository holds the official plugin source, not the Pluxx compiler/engine.
- The Pluxx CLI/package lives in the main project: [orchidautomation/pluxx](https://github.com/orchidautomation/pluxx)
- A future `pluxx-plugins` repository can serve as a broader gallery or registry. This repository is intentionally first-party and singular.
