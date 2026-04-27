---
description: "Package install links, screenshots, proof notes, and release-facing demo assets for a plugin"
argument-hint: "[release context optional]"
---

Use the Pluxx proof packaging workflow.

Arguments: $ARGUMENTS

## What To Do

1. Use the `pluxx-proof-pack` skill.
2. Identify the strongest install path and proof artifacts.
3. Package the public-facing pieces:
   - install links
   - screenshots
   - proof note
   - repo/demo/docs surfaces
4. Prefer raw `main` installer links when the repo is pushed but no tagged release exists yet.
5. Call out anything still missing before the plugin is shareable externally.
