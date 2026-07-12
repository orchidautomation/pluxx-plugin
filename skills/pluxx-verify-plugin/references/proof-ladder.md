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

## Common Gaps

- Build passes, host cannot see plugin: install, verify, then reload.
- Install exists, consumer doctor fails: inspect missing runtime payload or generated host config.
- Local stdio plugin looks like “skills only”: verify `passthrough`, installed user configuration, and the executable entrypoint.
- Behavioral run is flaky: record the MCP path once and replay the tape before changing workflow instructions.
- Codex commands are absent: current Pluxx translates command intent through skills, `AGENTS.md`, and generated routing metadata because plugin slash-command parity is not documented.
