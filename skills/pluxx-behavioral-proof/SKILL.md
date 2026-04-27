---
name: pluxx-behavioral-proof
description: Run or explain the installed headless proof path so a plugin is tested for behavior, not just structure.
---

# Pluxx Behavioral Proof

Use this skill when the user wants the strongest answer to: "does the plugin actually work in the host?"

## Inputs To Clarify

- which hosts matter for this pass
- whether the plugin defines hook commands and needs `--trust`
- whether there are canonical example queries already checked into `.pluxx/behavioral-smoke.json`
- whether the user is debugging source behavior or installed behavior

## Workflow

1. Start with `behavioral-tester` when the host supports specialist agents.
2. Pair behavioral proof with structural install proof:
   - `pluxx verify-install --target <platforms...>`
3. Run the installed headless proof path:
   - `pluxx test --install --trust --behavioral`
4. Narrow the target subset when the user only cares about one host.
5. If the user already has a concrete example query, prefer:
   - `pluxx test --install --trust --behavioral --behavioral-prompt "..."`
6. Summarize:
   - which hosts passed
   - which hosts failed
   - whether the issue is install-state, workflow behavior, auth, or host-runtime noise

## Decision Points

- If a host is failing to see the plugin at all, route first to `pluxx-verify-install`.
- If the workflow is subtle, use real example prompts rather than generic smoke probes.
- If one host is noisy, do not assume the workflow definition is wrong until you isolate whether the issue is host-local.

## Rules

- Do not confuse build success with behavioral proof.
- Do not skip `--trust` when the plugin defines hook commands.
- Prefer real example queries over generic smoke checks when the workflow is subtle.
- If the result is only locally credible, say so.

## Failure Modes To Call Out

- install-state healthy but workflow behavior wrong
- context blowups or host-specific agent/runtime limits
- MCP auth missing for one host
- plugin technically works but flattens the intended subagent behavior

## Output

- Return the exact behavioral proof command.
- Call out the supporting `verify-install` step.
- Make the next debugging or release step obvious.
