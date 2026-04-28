---
description: Import an MCP into a Pluxx plugin project
argument-hint: "[installed-host:name | mcp-url | stdio-command]"
---

Use the Pluxx MCP import workflow.

Arguments: $ARGUMENTS

## What To Do

1. Use the `pluxx-import-mcp` skill.
2. Treat the first argument as the MCP source or selector:
   - installed MCP selector, e.g. `codex:exa`
   - remote HTTP/SSE URL
   - local stdio command
3. If the user says the MCP is already installed or working in Claude Code, Cursor, Codex, or OpenCode:
   - run `pluxx discover-mcp`
   - narrow with `--host` when they named the host
   - import with `pluxx init --from-installed-mcp <host:name> --yes`
4. If auth details are missing, ask only for the auth shape and env var names, not raw secret values.
5. Prefer a deterministic first pass with:
   - `pluxx init --from-installed-mcp ... --yes` for discovered host config
   - `pluxx init --from-mcp ... --yes` for raw URL/stdio sources
6. If the user wants imported MCP tool calls preapproved, include `--approve-mcp-tools`.
7. After import, summarize the generated scaffold and run:
   - `pluxx doctor`
   - `pluxx lint`
   - `pluxx test --target claude-code cursor codex opencode`

Return the important generated files, any quality warnings, and whether validation passed.
