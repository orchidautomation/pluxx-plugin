---
name: pluxx-verify-plugin
description: Use this skill when a user wants to validate, lint, evaluate, build, test, install, verify, troubleshoot, or behaviorally prove a Pluxx plugin. Separate source, build, installed-state, and real workflow evidence.
---

# Verify A Pluxx Plugin

Prove only what the completed checks support.

## Workflow

1. Identify the requested proof layer and target hosts.
2. Read [references/proof-ladder.md](references/proof-ladder.md) when the user asks whether a plugin is “working,” when installed state is involved, or when a lower check passes but the host still fails.
3. Read [references/failure-diagnosis.md](references/failure-diagnosis.md) when a check fails, a host cannot see a passing build, Codex companion state is stale, or behavioral results are inconsistent.
4. Use `install-verifier` for host visibility or `behavioral-tester` for real example-query proof when the host supports specialists.
5. Start with source proof:
   - `pluxx validate`
   - `pluxx doctor --json`
   - `pluxx lint`
   - `skills-ref validate skills/<name>` for every source skill in scope
   - `pluxx eval`
6. Run `pluxx test --target <hosts...>` for deterministic build and smoke proof.
7. Install only when requested. Review hook commands first, then use `pluxx test --install --trust --target <hosts...>` or the narrower `pluxx install` flow.
8. Run `pluxx verify-install --target <host>` and follow its specific repair guidance before suggesting a host reload.
9. For real workflow proof, define or inspect `.pluxx/behavioral-smoke.json`, then run `pluxx test --install --trust --behavioral --target <hosts...>`.
10. When built or installed output still looks wrong, run `pluxx doctor --consumer <path>`.
11. When MCP behavior is nondeterministic, record with `pluxx mcp proxy --from-mcp <source> --record <tape.json>` and replay with `pluxx mcp proxy --replay <tape.json>` to isolate the protocol path.

## Evidence Rules

- Separate source, build, install, and behavior results.
- Treat expected host-translation warnings as caveats, not failures, unless required intent is missing.
- Do not claim host visibility from `build` alone.
- Do not claim workflow behavior from `verify-install` alone.
- Do not trust local hooks without reviewing the bundled commands.

## Output

Return a layer-by-layer proof table, commands run, targets covered, warnings, failures, and the smallest repair or next-proof step.
