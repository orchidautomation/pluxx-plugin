# Pluxx Proof Ladder

| Layer | Command | What it proves |
| --- | --- | --- |
| Config | `pluxx validate` | The project config can load and satisfies the schema. |
| Source health | `pluxx doctor` | Paths, metadata, runtime assumptions, and project structure are coherent. |
| Host rules | `pluxx lint` | Skills and cross-host metadata satisfy target-specific rules. |
| Scaffold quality | `pluxx eval` | MCP-derived taxonomy and prompt-pack quality meet available heuristics. |
| Build smoke | `pluxx test --target <hosts...>` | Config, lint, eval, compilation, and target artifact smoke checks pass together. |
| Consumer health | `pluxx doctor --consumer <path>` | A built or installed bundle is coherent from the consumer side. |
| Installed state | `pluxx verify-install --target <host>` | The host-visible plugin location and required companion state are present and current. |
| Behavior | `pluxx test --install --trust --behavioral` | Installed workflows respond to the configured example prompts in real host CLIs. |

Run the ladder from the lowest unproven layer upward. A higher layer can depend on lower layers, but it does not erase their warnings. Stop at the first failure, diagnose it, and rerun that layer before making broader claims.

`pluxx eval` can report an informational skip when no MCP metadata is available. Record that as “not applicable/not evaluated,” not a pass and not automatically a project failure.

## Common Gaps

- Build passes, host cannot see plugin: install, verify, then reload.
- Install exists, consumer doctor fails: inspect missing runtime payload or generated host config.
- Local stdio plugin looks like “skills only”: verify `passthrough`, installed user configuration, and the executable entrypoint.
- Behavioral run is flaky: record with `pluxx mcp proxy --from-mcp <source> --record <tape.json>` and replay with `pluxx mcp proxy --replay <tape.json>` before changing workflow instructions.
- Codex commands are absent: current Pluxx translates command intent through skills, `AGENTS.md`, and generated routing metadata because plugin slash-command parity is not documented.

## Evidence Table

For each requested target, report:

| Layer | Result | Evidence | Caveat or next step |
| --- | --- | --- | --- |
| Config/source | pass, fail, or not run | command and concise result | first actionable error |
| Build/consumer | pass, fail, or not run | target artifact inspected | translation warnings |
| Installed state | pass, fail, or not run | resolved installed path/version | reload or repair needed |
| Behavior | pass, fail, skipped, or not run | named smoke case/host CLI | nondeterminism or missing case |

Never collapse “build passed” into “the host can use it,” or “install verified” into “the workflow behaves correctly.”
