---
description: Prove installed-host behavior with real workflow smoke cases
argument-hint: "[targets optional]"
agent: behavioral-tester
subtask: true
---

Use the Pluxx behavioral proof workflow.

Arguments: $ARGUMENTS

## What To Do

1. Use the `pluxx-behavioral-proof` skill.
2. Treat the argument as the target host subset when present.
3. Prefer `pluxx test --install --trust --behavioral --target <platforms...>` when the plugin is ready for installed-host proof.
4. If behavioral cases are missing or weak, define the smallest useful `.pluxx/behavioral-smoke.json` cases first.
5. Return source, install, and behavior results separately.
