# Source Selection

Choose the source lane before choosing refinement depth or installation behavior.

| Starting point | Preferred path | Main risk to check |
| --- | --- | --- |
| MCP already configured in a host | `discover-mcp`, then `init --from-installed-mcp` | Sensitive discovery output and selector collisions |
| Remote HTTP or SSE MCP | `init --from-mcp <url> --yes` | Source authentication versus runtime authentication |
| Local stdio MCP | `init --from-mcp <complete-command> --yes` | Executable entrypoint and project-relative payload |
| Existing host-native plugin | `migrate <path>` | Degraded or dropped host-specific surfaces |
| No source yet | interactive `init <name>` | Plain init requires an interactive terminal |

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

### Authentication Decision

| Credential shape | Model it as | Boundary |
| --- | --- | --- |
| Public endpoint | no auth | Do not invent an auth requirement. |
| Bearer token | bearer auth with an environment reference | Store only the variable name, never the token. |
| Vendor-specific header | header auth with the documented header name and environment reference | Keep the literal value out of config and output. |
| Host supplies credentials at runtime | platform runtime auth | Confirm every intended target can support the contract. |
| Interactive OAuth is required | OAuth wrapper/runtime flow | A `401` or `403` alone does not prove OAuth; verify the server's documented scheme. |

Keep import-time source access and installed runtime access separate. A credential that lets Pluxx inspect an MCP during creation is not automatically the credential contract that every generated host should use.

Approve MCP tools only after reviewing the discovered tool list and only when the user explicitly wants that trust boundary. Do not add `--approve-mcp-tools` as a convenience default.

## Local Stdio MCP

Pass the executable command, not only the package name. If it points at project-relative files such as `./build/index.js`, verify that Pluxx inferred the containing runtime directory into `passthrough` so installed bundles include the executable payload.

Before calling the scaffold portable, confirm:

- the command names a real executable or package binary, not merely a package that happens to contain one
- every project-relative argument resolves from the intended runtime directory
- the required runtime directory is included in `passthrough`
- installed configuration anchors paths to the generated plugin location rather than the source checkout's current working directory
- environment variable names are declared without copying their values

If import works from the source checkout but the installed host cannot start the server, treat it as a runtime payload or path problem and route to verification.

## Existing Host Plugin

Use `pluxx migrate <path>`. Inspect the migration report for preserved, translated, degraded, and dropped surfaces before editing the generated source.

## Manual Versus Autopilot

- Default to `init` when the user wants inspectable stages or the source shape is uncertain.
- Use `autopilot` when a raw MCP URL or complete local command and the desired targets are clear and the user wants import, refinement, verification, and optional installation in one flow.
- An installed MCP selector is an `init --from-installed-mcp` lane, not an autopilot source flag. Import it first, then run bounded agent passes and verification if semantic refinement is wanted.
- Use `quick` for a deterministic light pass, `standard` for the normal path, and `thorough` only when richer context and agent refinement justify the extra work.

Autopilot runners are `claude`, `cursor`, `codex`, and `opencode`. Choose the locally available host runner the user wants to perform semantic passes; it is independent of the generated targets. Select the core four with `--targets claude-code,cursor,codex,opencode`. `--install-target` selects one configured host, so ask which host to install when the request is ambiguous.

Autopilot does not weaken install or hook trust boundaries. Add installation only when explicitly requested, and review bundled hook commands before using `--trust`.

For an installed-MCP lane, keep the stages explicit. Import with `pluxx init --from-installed-mcp <host:name> --yes --targets claude-code,cursor,codex,opencode`; add `--approve-mcp-tools` only after the requested tool-list review. Then validate and build, preview installation with `pluxx install --dry-run --json`, install the selected host with `pluxx install --target <host> --trust` after hook review, and prove it with `pluxx verify-install --target <host>`.

The OAuth wrapper flag is for browser-interactive remote MCP introspection; it is not a generic fix for a local stdio process that performs its own login flow. For installed stdio, preserve the discovered command and configuration references, document any external login/bootstrap step, inspect the maintained MCP metadata plus each generated target runtime, and behaviorally test the installed hosts that must support the flow.

## Common Failures

- **Plain init in automation:** `pluxx init <name>` rejects non-interactive execution. Use an interactive terminal or provide an explicit MCP source with `--yes`.
- **Package name is not an executable:** inspect package metadata or the working host configuration and pass the complete stdio command.
- **Placeholder-looking credentials:** stop before scaffolding if the source contains a literal example token or unresolved placeholder. Ask only for the intended environment variable name.
- **Unexpected `401` or `403`:** distinguish endpoint, header name, bearer format, OAuth, and platform runtime auth before retrying.
- **Existing host config collides by name:** use the host-qualified selector returned by discovery.
- **Migrated feature lacks parity:** keep the migration report's preserved, translated, degraded, and dropped classifications; do not silently rewrite “dropped” as “supported.”

## Creation Evidence

Report the chosen source lane, transport, credential shape without values, target hosts, generated source path, runtime payload assumptions, and the results of `doctor`, `lint`, and `test`. A created scaffold is not yet proof of installed visibility or real workflow behavior.
