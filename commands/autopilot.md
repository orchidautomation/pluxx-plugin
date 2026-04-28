---
description: Run the one-shot Pluxx import, refinement, and verification path
argument-hint: "[mcp-source | installed-host:name | existing project context]"
---

Use the Pluxx autopilot workflow.

Arguments: $ARGUMENTS

## What To Do

1. Use the `pluxx-autopilot` skill.
2. Treat the first argument as the MCP source or installed-host selector when one is provided.
3. If the user only knows the MCP is already installed in Claude Code, Cursor, Codex, or OpenCode, run `pluxx discover-mcp` and use `pluxx-import-mcp` with `pluxx init --from-installed-mcp ... --yes` before deeper refinement.
4. Prefer `pluxx autopilot --from-mcp ... --yes` only when there is an explicit URL or stdio command.
5. Make the mode, review behavior, and verification behavior explicit.
6. Summarize what autopilot changed, what it skipped, and what still needs human follow-up.

Return the important created or updated files, the refinement passes that ran, and the verification result.
