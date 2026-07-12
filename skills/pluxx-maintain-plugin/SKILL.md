---
name: pluxx-maintain-plugin
description: Use this skill when an existing MCP-derived Pluxx project must be refreshed after its MCP, docs, runtime, or scaffold inputs change. Preview and run sync, preserve custom sections, explain drift, and route semantic changes to refinement.
---

# Maintain A Pluxx Plugin

Refresh generated source without losing user-owned work.

## Workflow

1. Confirm that `.pluxx/mcp.json` exists and the project is MCP-derived.
2. Inspect the working tree. Do not sync across unrelated uncommitted changes without isolating or preserving them.
3. Preview first:
   - `pluxx sync --dry-run --json`
   - use `--from-mcp <source>` only when the canonical source changed intentionally
4. Read [references/sync-safety.md](references/sync-safety.md) before applying sync, or whenever the preview contains removed, preserved, renamed, or warning entries.
5. Review added, updated, removed, preserved, renamed, and warning entries before applying.
6. Run `pluxx sync` after the preview is understood.
7. Inspect mixed-ownership Markdown boundaries and any custom notes attached to removed generated surfaces.
8. Run `pluxx validate`, `pluxx doctor`, `pluxx lint`, `pluxx eval`, and `pluxx test`; run `skills-ref validate` for every source skill.
9. Route changed product meaning, tool grouping, or setup behavior to `pluxx-refine-plugin`.

## Drift Rules

- Never delete preserved custom content silently.
- Call out removed MCP tools that strand a workflow or custom note.
- Treat persisted taxonomy and invalidated agent packs as explicit review work, not incidental generated noise.
- Keep source fixes in the root project and rebuild `dist/` through Pluxx.
- Treat a changed local stdio command or payload path as a runtime change that needs install verification.

## Output

Report the source used, preview summary, applied changes, preserved content, warnings, validation result, and any refinement or install-proof follow-up.
