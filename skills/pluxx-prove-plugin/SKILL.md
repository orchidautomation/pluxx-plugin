---
name: pluxx-prove-plugin
description: Prove a scaffold structurally, install it, and check real workflow behavior.
---

# Prove Plugin

Use this skill when the user wants more than source confidence. This is the
proof journey for a plugin that should be trusted in real hosts.

This workflow intentionally combines:

- deterministic validation
- build/install
- installed-state verification
- consumer diagnosis
- behavioral proof with real example queries

## Inputs To Clarify

- which hosts matter right now
- whether the user wants source-only proof or real local install proof
- whether the plugin defines hooks and therefore needs `--trust`
- whether the plugin depends on install-time secrets or a local stdio runtime
- whether the user cares about behavior, not just structure

## Workflow

1. Start with deterministic trust:
   - `pluxx doctor`
   - `pluxx lint`
   - `pluxx eval`
   - `pluxx test`
2. Build the requested targets:
   - `pluxx build`
   - or `pluxx build --target <platforms...>`
3. If local proof matters, install:
   - `pluxx install --target <platforms...>`
   - add `--trust` when hook-enabled installs require it
4. Verify installed host state:
   - `pluxx verify-install --target <platforms...>`
5. If the install still looks wrong, diagnose the consumer bundle:
   - `pluxx doctor --consumer <installed-path>`
6. If the workflow nuance matters, run behavioral proof:
   - `pluxx test --install --trust --behavioral --target <platforms...>`
7. Return:
   - what passed structurally
   - what installed successfully
   - what the host can actually see
   - what the real behavior looked like

## Decision Points

- If the plugin came from a local stdio MCP, check bundled runtime files and
  `.pluxx-user.json` before concluding the MCP was lost.
- If the host cannot see the plugin at all, stay on install diagnosis before
  talking about workflow behavior.
- If one host is noisy but others are fine, avoid inflating that into a total
  plugin failure.

## Rules

- Do not confuse build success with install success.
- Do not confuse install success with behavioral success.
- Findings come before reassurance.
- When behavioral proof exists, treat it as first-class evidence, not an
  optional flourish.

## Failure Modes To Call Out

- deterministic checks fail before install
- install succeeds but host reload/trust was skipped
- plugin looks present but MCP/runtime wiring is incomplete
- plugin looks like “skills only” because local runtime files or
  `.pluxx-user.json` are missing
- behavior still degrades even though build/install are clean

## Output

- Return the proof state clearly:
  - source health
  - install health
  - behavior health
- Explain the smallest sensible next step:
  - reload
  - trust hooks
  - reinstall
  - refine more
  - or publish
