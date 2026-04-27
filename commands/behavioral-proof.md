---
description: "Prove an installed plugin actually behaves correctly across the core four"
argument-hint: "[targets or prompt optional]"
---

Use the Pluxx behavioral proof workflow.

Arguments: $ARGUMENTS

## What To Do

1. Use the `pluxx-behavioral-proof` skill.
2. Explain the strongest installed-proof path:
   - `pluxx test --install --trust --behavioral`
3. Narrow the targets when the user only cares about one or two hosts.
4. Pair behavioral proof with:
   - `pluxx verify-install`
5. Return the exact proof command, the expected signals, and the likely failure modes.
