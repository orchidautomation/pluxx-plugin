---
name: pluxx-autopilot
description: Run the one-shot Pluxx import, refinement, and verification path.
---

# Autopilot

Use this skill when the user wants the one-shot path instead of a manually staged import and refinement flow.

## Inputs To Clarify

- source type: remote MCP, local stdio command, or existing working project
- whether the user is optimizing for speed, debuggability, or polish
- whether auth/runtime details are already known
- whether the user wants only a first-pass scaffold or something close to shareable

## Workflow

1. Identify the source and desired scope:
   - remote MCP URL
   - local stdio command
   - current working project
   - desired targets
2. If the Pluxx runtime is missing or stale, route through `pluxx-bootstrap-runtime` first.
3. Make the mode explicit:
   - `quick`
   - `standard`
   - `thorough`
4. Run the one-shot path:
   - `pluxx autopilot --from-mcp ... --yes`
   - include runner, mode, and review flags when they matter
5. Summarize:
   - files created or updated
   - which agent passes ran
   - which verification checks ran
   - what still needs human follow-up

## Decision Points

- Use `quick` when the user just wants a first scaffold.
- Use `standard` when they want a credible baseline with normal checks.
- Use `thorough` when the workflow is subtle or likely to become a public proof surface.
- If the user is learning or debugging, prefer the staged lifecycle once autopilot stops being transparent enough.

## Rules

- Do not present autopilot as magic. Explain what it actually ran.
- Keep auth flags explicit when the MCP requires them.
- If the user is learning or debugging, suggest the manual lifecycle when autopilot hides too much.
- If autopilot fails mid-run, say which stage failed:
  - auth
  - introspection
  - runner
  - verification
- Do not stop at "autopilot succeeded" when the user is aiming to ship. Route next to:
  - `pluxx-refine-plugin`
  - `pluxx-prove-plugin`
  - `pluxx-publish-plugin`

## Failure Modes To Call Out

- MCP auth failure
- introspection/import failure
- agent runner failure
- structural verification failure
- successful scaffold that still needs host-translation or behavioral-proof follow-up

## Output

- Explain what autopilot actually did.
- Call out what still needs human review.
- Make the next step obvious:
  - refine more
  - build/install
  - sync later
  - or ship
