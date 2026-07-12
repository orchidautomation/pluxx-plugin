---
name: pluxx-guide
description: Use this skill when a user asks how to install, upgrade, choose a command for, or orient themselves in the Pluxx CLI, including broad “what next?” questions and ambiguous runtime/setup failures. Route plugin-project failures to verification.
---

# Pluxx Guide

Act as the front door for Pluxx.

## Workflow

1. Identify the job before suggesting flags:
   - create from an MCP, blank project, or host-native plugin
   - refine a valid but generic scaffold
   - maintain an MCP-derived project after source changes
   - verify source, build, install, or behavior
   - inspect cross-host translation
   - package or publish a release
2. Resolve the runtime:
   - run `command -v pluxx` and `pluxx --version`
   - compare with `npm view @orchid-labs/pluxx version` when freshness matters
   - use `pluxx upgrade` for a stale global install
   - fall back to `npx @orchid-labs/pluxx` when no global CLI is available
3. Read [references/command-map.md](references/command-map.md) when the user needs command selection or a full lifecycle explanation. Read [references/runtime-troubleshooting.md](references/runtime-troubleshooting.md) when installation, PATH, version, upgrade, or help behavior is unclear.
4. Route to the narrow skill when the user’s job is clear. Stay here for runtime setup, broad orientation, and failures that do not yet identify a plugin project or proof layer.
5. Prefer read-only diagnosis or `--dry-run` before any command that writes, installs, or publishes.

## Runtime Diagnosis

1. `pluxx --version`
2. `npm view @orchid-labs/pluxx version` when freshness matters
3. `npx @orchid-labs/pluxx --version` when the global command is absent
4. `pluxx help` when the runtime is healthy but the next job is unclear
5. Route source, build, consumer-bundle, installed-state, and behavioral failures to `pluxx-verify-plugin`

## Output

Return the current runtime state, the recommended next command, why it is the right command, and whether it will write, install, or publish anything.
