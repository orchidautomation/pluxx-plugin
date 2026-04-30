---
name: pluxx-behavioral-proof
description: Prove that an installed plugin behaves correctly in real hosts, not just that it builds.
---

# Behavioral Proof

Use this skill when the user needs confidence that a generated plugin actually works through Claude Code, Cursor, Codex, and OpenCode.

This is the Exa-style proof lane: installed host behavior is first-class evidence, not a nice-to-have after build/install pass.

The matching command carries the argument UX:

- `/pluxx:behavioral-proof [targets optional]`

## Inputs To Clarify

- which targets matter right now
- whether the plugin has `.pluxx/behavioral-smoke.json`
- whether the plugin defines hooks and needs `--trust`
- whether the workflow depends on env vars, local stdio runtimes, or install-time user config
- whether host-local auth problems should be treated as plugin failures or environment failures

## Workflow

1. Confirm source health first:
   - `pluxx doctor`
   - `pluxx lint`
   - `pluxx test`
2. Confirm the source project builds and installs:
   - `pluxx build --target <platforms...>`
   - `pluxx install --target <platforms...> --trust`
3. Confirm host-visible install state:
   - `pluxx verify-install --target <platforms...>`
4. If the host sees the plugin but behavior still looks wrong, diagnose the installed bundle:
   - `pluxx doctor --consumer <installed-path>`
5. Run the installed-host behavioral lane:
   - `pluxx test --install --trust --behavioral --target <platforms...>`
6. If `.pluxx/behavioral-smoke.json` is missing or too shallow, use `behavioral-tester` to define the smallest high-signal example queries.

## Good Behavioral Smoke Cases

- exercise a real public workflow, not only runtime setup text
- require concrete output fragments that prove the right workflow was selected
- forbid known bad fallback text when a previous host failed in a specific way
- distinguish host-runtime/auth failures from generator-shape failures
- stay small enough to rerun during release checks

## Rules

- Do not confuse `build` success with install success.
- Do not confuse `verify-install` success with workflow behavior.
- For hook-enabled plugins, make trust explicit before install.
- For local stdio MCPs, inspect bundled runtime files and `.pluxx-user.json` before claiming the MCP disappeared.
- For Exa-style specialist workflows, verify that commands route to the intended subagent/specialist path where the host supports it.
- Return failures by layer: source, install, host visibility, behavior.

## Output

- source health
- install health
- behavior health
- host-specific failures
- smallest next fix
