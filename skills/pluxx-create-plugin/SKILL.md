---
name: pluxx-create-plugin
description: Use this skill when a user wants to create a Pluxx project from a raw or installed MCP, local stdio command, blank project, or existing Claude Code, Cursor, Codex, or OpenCode plugin, including the one-shot autopilot path.
---

# Create A Pluxx Plugin

Create the smallest deterministic source project before semantic refinement.

## Workflow

1. Identify the source:
   - already configured MCP: run `pluxx discover-mcp`, then use `pluxx init --from-installed-mcp <host:name> --yes`
   - remote HTTP or SSE MCP: use `pluxx init --from-mcp <url> --yes`
   - local stdio MCP: pass the complete executable command to `--from-mcp`
   - host-native plugin: use `pluxx migrate <path>`
   - no existing source: hand off `pluxx init <name>` to an interactive terminal; plain init rejects non-interactive execution
2. Read [references/source-selection.md](references/source-selection.md) when transport, credentials, local runtimes, or autopilot choices are not obvious.
3. Use `import-architect` for unfamiliar MCP/runtime shape or `migration-operator` for host-native conversion when the host supports specialists.
4. Collect only the missing project choices: name, display name, source, target hosts, credential scheme, and whether to use the manual or one-shot path.
5. Prefer `--dry-run` when source detection, target selection, or generated file impact is uncertain.
6. Use workflow grouping and the core four unless the user asks for a narrower target set.
7. Run `pluxx doctor`, `pluxx lint`, and `pluxx test` after the source scaffold exists.
8. Route a valid but generic scaffold to `pluxx-refine-plugin`; route failed validation to `pluxx-verify-plugin`.

## One-Shot Path

Use `pluxx autopilot --from-mcp <source> --runner <runner> --mode standard --yes` when the user explicitly prefers speed over inspecting each stage. Add `--install --install-target <host> --trust` only after the user requests a local install and the hook commands have been reviewed.

## Safety

- Never copy literal credential values into source files or output.
- Prefer env variable names and platform-managed runtime configuration.
- Treat generated `dist/` as output; make fixes in the source project.

## Output

Report the chosen path, generated source files, configured targets, credential shape without values, validation result, and the next refinement or proof step.
