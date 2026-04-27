---
name: pluxx-migrate-plugin
description: Bring an existing Claude, Cursor, Codex, or OpenCode plugin into Pluxx.
---

# Pluxx Migrate Plugin

Use this skill when the user already has a host-native plugin and wants to convert it into a canonical Pluxx project instead of rewriting it by hand.

## Inputs To Clarify

- which host the source plugin belongs to
- whether the source plugin includes helper runtimes, hooks, or auth files
- whether the user wants a faithful baseline or immediate multi-host polish
- whether they care more about preservation or cleanup
- whether the source plugin depends on a project-relative local runtime such as `./build/index.js`

## Workflow

1. Identify the source plugin:
   - local path
   - current host shape
   - any local runtime folders or auth assumptions
2. Start with `migration-operator` when the host supports specialist agents.
3. Run the migration:
   - `pluxx migrate <plugin-path>`
4. Inspect the generated source project:
   - `pluxx.config.ts`
   - `INSTRUCTIONS.md`
   - `skills/*/SKILL.md`
   - `.pluxx/mcp.json`
   - inferred `passthrough`
   - `userConfig`
5. Validate the migrated baseline:
   - `pluxx doctor`
   - `pluxx lint`
   - `pluxx eval`
   - `pluxx test`

## Decision Points

- If the migration reveals a lot of host-specific nuance, do not oversell immediate parity.
- If the migrated project is structurally sound but awkward, route next to `pluxx-refine-plugin`.
- If the user wants to know exactly what got weaker or changed, handle that inside `pluxx-refine-plugin`.
- If the user says the installed result looks like “skills only,” check the migrated runtime bundling and install-time config path before assuming the migration dropped the MCP.

## Rules

- Preserve the migrated project as the new source of truth instead of editing the old host-native plugin directly.
- Call out any host-native semantics that were translated, degraded, or dropped.
- Do not promise perfect parity when the source host used surfaces the other targets do not support directly.
- If the source plugin includes local runtimes or helper folders, verify they were carried into the Pluxx project correctly.
- For local stdio runtimes, verify that runtime folders are actually bundled via `passthrough`, not just referenced in config.
- If install-time secrets are required, call out where they must materialize and whether the installed bundle now contains `.pluxx-user.json`.
- Route to `pluxx-refine-plugin` when the user needs the preserve / translate / degrade / drop truth before shipping.

## Failure Modes To Call Out

- missing files from the source plugin
- partially translated host-native semantics
- carried runtime/auth assumptions that no longer fit the new source project
- structurally passing migration that still needs a lot of workflow cleanup
- local runtime references preserved in config but not actually bundled for installable targets

## Output

- Explain what was imported successfully.
- Call out any translation caveats.
- State whether the migrated runtime/auth wiring looks ready for installed targets, not just source-level validation.
- State whether the migrated project now validates and builds cleanly.
