# Failure Diagnosis

Repair the first failed proof layer. Avoid reinstalling or rewriting skills when the evidence points elsewhere.

| Symptom | Likely layer | Smallest grounded action |
| --- | --- | --- |
| Config cannot load | config | Fix the first schema/import error in source, then rerun `pluxx validate`. |
| Doctor reports missing paths or runtime assumptions | source/consumer | Correct source paths or inspect the specified consumer bundle; do not patch generated output as the durable fix. |
| Lint fails for one target | host rules | Fix the source surface or document an intentional supported translation, then rebuild. |
| Eval is skipped because MCP metadata is absent | scaffold quality | Record not applicable unless the project is expected to be MCP-derived. |
| Build passes but host cannot see the plugin | installed state | Install only with approval, then run `verify-install` before restarting the host. |
| Consumer path is unknown or unreadable | consumer | Resolve the actual built/installed root and rerun `doctor --consumer <path>`. |
| Installed symlink or version is stale | installed state | Apply the exact repair from `verify-install`, commonly rerunning the intended install. |
| Codex still exposes an old plugin cache | installed state | Use Codex Plugins refresh when available, otherwise restart or reinstall as the verifier directs. |
| Codex skills exist but companion agents are missing | companion state | Run `pluxx codex apply --consumer "<path>" --agents-only`, then restart Codex and verify again. |
| Hook-dependent behavior is absent | trust/host config | Review hook commands, confirm the install used explicit trust, and confirm the host enables the required hook feature. |
| Generated `.mcp.json` is absent | runtime | Decide whether the plugin actually declares an MCP runtime; absence can be informational for skills-only plugins. |
| Behavioral result is flaky or protocol-dependent | behavior/MCP | Record with `pluxx mcp proxy --from-mcp <source> --record <tape.json>`, replay with `pluxx mcp proxy --replay <tape.json>`, then isolate workflow wording from protocol variance. |

## Codex-Specific Checks

- Generated skills and instructions live in the plugin bundle; custom agent registration can require install-managed companion state outside it.
- Use the install path reported by `pluxx verify-install --target codex` as the consumer path for agent-only repair. If no path is reported, resolve the configured Codex plugin install before applying companion state.
- For hook behavior, verify both explicit trust and the active Codex hooks feature/configuration. A bundled hook is not proof it executed.
- Refresh/restart is a final visibility step after state is current, not a substitute for inspecting a stale path or version.

## Claims To Avoid

- Do not call an informational eval skip a quality pass.
- Do not call a generated folder an installation.
- Do not call a present installation current until its path/version and companion state are checked.
- Do not call a successful prompt load proof that the underlying MCP action works.
- Do not recommend `--trust` before reviewing the commands it authorizes.
- Do not call an intermittent behavioral failure resolved from one lucky pass. State the acceptance cases and repeat count; if no stability criterion was agreed, report single-run evidence only.

## Failure Report

Return the first failed layer, exact command and target, concise error, likely cause supported by evidence, smallest repair, whether it mutates local state, and the command that will prove the repair.
