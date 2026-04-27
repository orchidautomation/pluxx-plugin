---
name: pluxx-import-mcp
description: Import an MCP into a Pluxx project and validate the first pass.
---

# Pluxx Import MCP

Use this skill when the task is: bring an MCP server into Pluxx, generate the initial scaffold, and prove it works.

## Inputs To Clarify

- remote URL vs local stdio command
- auth shape at import time
- whether the user wants the first scaffold only or a more refined first impression
- whether the MCP is simple enough for direct import or would benefit from context prep immediately after

## Workflow

1. Identify the MCP source:
   - remote HTTP/SSE URL
   - local stdio command
   - auth requirements, especially env vars or custom headers
2. Start with `import-architect` when the host supports specialist agents.
3. Prefer a deterministic first pass:
   - use `pluxx init --from-mcp ... --yes`
   - include `--display-name`, `--targets`, `--grouping`, and auth flags when needed
   - include `--approve-mcp-tools` when the user wants the imported MCP tools preapproved in canonical permissions
4. If there is supporting context, prepare the agent pack:
   - `pluxx agent prepare --website ... --docs ...`
5. Show the user what was generated:
   - `pluxx.config.ts`
   - `INSTRUCTIONS.md`
   - `skills/*/SKILL.md`
   - `.pluxx/mcp.json`
6. Validate immediately:
   - `pluxx doctor`
   - `pluxx lint`
   - `pluxx test --target claude-code cursor codex opencode`

## Decision Points

- Use `--dry-run --json` first when the user wants a preview or when the auth story is risky.
- Prefer a plain deterministic import before semantic refinement if the user is debugging runtime/auth.
- If the import succeeds but the workflows read lexically, route next to taxonomy and instruction shaping instead of pretending the first scaffold is final.

## Rules

- Use `--dry-run --json` first when you need to preview changes or explain the plan before writing files.
- Keep the first scaffold deterministic. Do not jump straight into semantic rewrites before the plugin builds and tests.
- When auth is custom-header based, pass explicit `--auth-type header --auth-header ... --auth-template ...` flags.
- If the user wants MCP tool calls preapproved in the generated plugin, prefer `--approve-mcp-tools` during import instead of hand-editing permissions later.
- After import, summarize the generated file tree and any warnings that remain.
- Make the next shaping pass obvious:
  - `pluxx-refine-taxonomy`
  - `pluxx-rewrite-instructions`
  - `pluxx-translate-hosts`

## Failure Modes To Call Out

- auth/import failure
- MCP introspection failure
- noisy or overly lexical generated workflows
- installable output okay but weak native translation expectations

## Output

- Tell the user whether the MCP imported successfully.
- Call out the generated plugin structure and the important files.
- State whether Claude, Cursor, Codex, and OpenCode passed or what failed.
