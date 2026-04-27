---
name: pluxx-sync-mcp
description: Refresh an MCP-derived Pluxx scaffold and preserve custom sections.
---

# Pluxx Sync MCP

Use this skill when an existing MCP-derived scaffold needs to be refreshed without losing the user’s custom notes.

## Inputs To Clarify

- whether the MCP source itself changed or only the surrounding docs/context changed
- whether the user wants a safe preview first
- whether the current scaffold has meaningful custom notes or manual edits

## Workflow

1. Preview first when the impact is unclear:
   - `pluxx sync --dry-run --json`
2. Run the real sync when safe:
   - `pluxx sync`
   - or `pluxx sync --from-mcp <override>`
3. Summarize:
   - updated files
   - preserved files
   - removed files
   - warnings
4. If the MCP changed materially, refresh the agent pack and rerun taxonomy or instructions work.
5. Verify:
   - `pluxx doctor`
   - `pluxx lint`
   - `pluxx test`

## Decision Points

- If the diff is hard to predict, insist on `--dry-run --json` first.
- If the sync removes skills or commands, call out whether preserved custom notes are now stranded.
- If the sync changes behavior materially, route next to `pluxx-translate-hosts` and `pluxx-behavioral-proof`.

## Rules

- Preserve mixed-ownership Markdown boundaries.
- Call out when old custom notes were preserved on removed skills so the user can decide whether to merge them.
- Do not silently delete user-authored content.

## Failure Modes To Call Out

- stale `.pluxx/mcp.json` metadata
- source MCP tool removals that invalidate old workflows
- preserved notes attached to deleted generated sections
- structural pass okay but taxonomy now outdated

## Output

- Explain what changed and what stayed preserved.
- Recommend follow-up refinement when the MCP’s shape changed enough to affect taxonomy or instructions.
