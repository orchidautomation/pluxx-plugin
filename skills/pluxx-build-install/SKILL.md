---
name: pluxx-build-install
description: Build installable plugins from a Pluxx scaffold and optionally install one.
---

# Pluxx Build Install

Use this skill when the user is ready to turn the current Pluxx source project into host-native bundles and test one or more targets locally.

## Inputs To Clarify

- whether the user wants source-proof only or true local installs
- which hosts matter now
- whether the plugin defines hooks and therefore needs `--trust`
- whether the user wants deterministic proof only or behavior proof too

## Workflow

1. Prefer `pluxx test --install` when the user wants the strongest deterministic local proof in one command.
2. Otherwise, if the scaffold has changed materially, validate first:
   - `pluxx doctor`
   - `pluxx lint`
   - `pluxx test`
3. Build the requested targets:
   - `pluxx build`
   - or `pluxx build --target <platforms...>`
4. Install only when the user wants local testing:
   - `pluxx install --target <platforms...>`
   - add `--trust` when the plugin defines hook commands and the user has opted in
5. If a host still looks wrong after install, use:
   - `pluxx doctor --consumer <installed-path>`
6. If the user needs stronger proof than build/install state, route to:
   - `pluxx-behavioral-proof`
7. Tell the user what was built and what was installed.

## Decision Points

- If the user just changed docs or instructions, a target subset may be enough.
- If the user changed runtime, hooks, permissions, or agents, prefer the full core-four build.
- If installed state is all the user asked for, stop at `verify-install`; if they care about real workflows, route further to behavioral proof.

## Rules

- Prefer target subsets when the user only cares about one host.
- Do not hide trust requirements for hook-enabled installs.
- Remind the user about host-specific reload steps when they matter.
- Never hand-edit `dist/`; rebuild instead.

## Failure Modes To Call Out

- source passes but host install fails
- install works but host reload was skipped
- trust-gated hooks blocked one or more installs
- one host builds while another exposes a generator regression

## Output

- Say which targets were built.
- Say which targets were installed.
- Call out any remaining manual reload, trust, or behavioral-proof steps.
