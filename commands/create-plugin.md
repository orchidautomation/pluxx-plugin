---
description: Create a Pluxx source project from an MCP, blank project, or existing host plugin
argument-hint: "[installed-host:name | mcp-url | stdio-command | plugin-path]"
---

Use the `pluxx-create-plugin` skill.

Arguments: $ARGUMENTS

Treat the argument as the source. Discover an already-configured MCP before reconstructing it, use `migrate` for a host-native plugin, and use `autopilot` only when the user wants the one-shot path. Prefer a dry-run when the source or generated impact is unclear. Return the chosen path, generated source, validation result, and next step.
