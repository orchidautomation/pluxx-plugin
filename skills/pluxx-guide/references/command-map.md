# Pluxx Command Map

| User job | Default command |
| --- | --- |
| Create from a raw MCP | `pluxx init --from-mcp <source> --yes` |
| Import an MCP already configured in a host | `pluxx discover-mcp`, then `pluxx init --from-installed-mcp <host:name> --yes` |
| Convert a host-native plugin | `pluxx migrate <path>` |
| Run the one-shot path | `pluxx autopilot --from-mcp <source> --runner <runner> --mode standard --yes` |
| Prepare product context | `pluxx agent prepare --website <url> --docs <url>` |
| Refine taxonomy or instructions | `pluxx agent run <taxonomy|instructions> --runner <runner>` |
| Review a scaffold | `pluxx agent run review --runner <runner> --no-verify` |
| Refresh an MCP-derived scaffold | `pluxx sync --dry-run --json`, then `pluxx sync` |
| Check source health | `pluxx doctor`, `pluxx lint`, `pluxx eval` |
| Build and smoke test | `pluxx test --target <hosts...>` |
| Install and verify | `pluxx test --install --trust`, then `pluxx verify-install --target <host>` |
| Inspect built or installed output | `pluxx doctor --consumer <path>` |
| Record or replay MCP traffic | `pluxx mcp proxy --from-mcp <source> --record <tape>` or `pluxx mcp proxy --replay <tape>` |
| Preview a release | `pluxx publish --dry-run` |
| Publish a GitHub release | `pluxx publish --github-release --version <x.y.z>` |
| Publish npm output | `pluxx publish --npm --version <x.y.z>` |

## Proof Ladder

`validate` checks configuration, `doctor` checks project health, `lint` checks source and host rules, `eval` checks scaffold quality when MCP metadata exists, `build` compiles targets, `test` combines deterministic checks, `verify-install` checks host-visible installed state, and `--behavioral` exercises real installed workflows.

Do not call a build “installed” or an install “behaviorally proven.” Report the strongest completed layer.
