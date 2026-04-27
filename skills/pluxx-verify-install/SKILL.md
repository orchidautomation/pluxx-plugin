---
name: pluxx-verify-install
description: Verify that an installed host bundle is actually visible and healthy.
---

# Pluxx Verify Install

Use this skill when the user wants proof that the built plugin is not just present on disk, but actually visible and healthy in the target host.

## Inputs To Clarify

- which host or hosts matter right now
- whether the install came from a local checkout, a release asset, or npm-published Pluxx
- whether the plugin defines hooks and therefore needs trust
- whether the host was reloaded after install

## Workflow

1. Identify the target host or hosts.
2. Run:
   - `pluxx verify-install --target <platforms...>`
3. If the installed state still looks wrong, use deeper consumer diagnosis when needed:
   - `pluxx doctor --consumer`
4. Summarize:
   - passed targets
   - failed targets
   - warnings
   - smallest next step

## Decision Points

- If the host cannot see the plugin at all, keep the conversation on install-state, not behavior.
- If the host sees the plugin but the workflow is still weak, route next to `pluxx-behavioral-proof`.
- If a single host is noisy, avoid claiming a core-four regression without checking whether the problem is host-local.

## Rules

- Findings come before reassurance.
- Do not confuse `build` success with install success.
- If a host needs reload, trust, or reinstall, say that explicitly.

## Failure Modes To Call Out

- stale installed bundle from an older local checkout
- host reload step skipped
- trust-required hooks blocked the install
- plugin visible but MCP/runtime wiring missing
- plugin healthy on disk but not exposed in the host UI

## Output

- Return the install-state result clearly.
- Explain the smallest sensible follow-up:
  - reload host
  - trust hooks
  - reinstall
  - publish
