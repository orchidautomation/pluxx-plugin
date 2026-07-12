# Source Selection

## Already Installed MCP

Use discovery before asking the user to reconstruct working host configuration:

```bash
pluxx discover-mcp --json
pluxx discover-mcp --host codex
pluxx init --from-installed-mcp codex:acme --yes
```

Host-qualified selectors avoid collisions. Treat raw discovery output as sensitive: credential-bearing URL query strings or stdio arguments can still appear. Do not paste the output verbatim; summarize only the selector, name, host, and transport needed for the import.

## Remote MCP

Use the real HTTP or SSE endpoint. Describe the credential scheme as none, bearer, custom header, or platform-managed. Ask for the env variable name, not its value.

## Local Stdio MCP

Pass the executable command, not only the package name. If it points at project-relative files such as `./build/index.js`, verify that Pluxx inferred the containing runtime directory into `passthrough` so installed bundles include the executable payload.

## Existing Host Plugin

Use `pluxx migrate <path>`. Inspect the migration report for preserved, translated, degraded, and dropped surfaces before editing the generated source.

## Manual Versus Autopilot

- Default to `init` when the user wants inspectable stages or the source shape is uncertain.
- Use `autopilot` when the source and desired target are clear and the user wants import, refinement, verification, and optional installation in one flow.
- Use `quick` for a deterministic light pass, `standard` for the normal path, and `thorough` only when richer context and agent refinement justify the extra work.
