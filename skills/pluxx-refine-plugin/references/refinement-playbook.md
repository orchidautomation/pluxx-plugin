# Refinement Playbook

Refinement should correct a named product weakness, not produce generic prose churn.

## Choose The Smallest Pass

| Symptom | Preferred pass | Expected artifact |
| --- | --- | --- |
| Skills lack product nouns, setup facts, or documented boundaries | prepare context | Bounded authoritative context for later passes |
| Skills mirror individual MCP tools or split one user job across folders | taxonomy | Job-shaped skill map and routing descriptions |
| Shared setup, credentials, or safety language is generic or inaccurate | instructions | Correct shared operator contract |
| The scaffold seems plausible but quality is uncertain | review | Findings-first report before edits |
| One host loses required intent | host translation review | Source-shape recommendation, then targeted edit |

Do not run every pass by default. A healthy taxonomy does not benefit from a taxonomy rewrite simply because the command exists.

## Context Selection

- Prefer the product's maintained website, official docs, and checked-in source documentation.
- Include only context needed to name workflows, constraints, and user language.
- Do not ingest raw private transcripts, secrets, auth files, browser data, or unrelated repositories.
- When source material conflicts, name the conflict and keep claims conservative.
- Inspect `pluxx agent prompt <pass>` before execution when wording, scope, or runner behavior matters.

## Taxonomy Test

A strong public skill represents a coherent user job with a clear entry condition, ordered workflow, safety boundary, and verifiable output.

Weak grouping:

- `list-projects`
- `get-project`
- `create-project`
- `update-project`

Stronger grouping:

- `project-operations`: inspect project state, choose the intended mutation, perform it, and verify the result

Keep skills separate when they have different authorization boundaries, proof requirements, audiences, or failure recovery. Merge them when they always load together to complete one job and splitting forces the agent to reconstruct the same workflow every time.

## Ownership And Edit Boundaries

- Edit root source skills, references, assets, scripts, and `INSTRUCTIONS.md`.
- Treat `dist/` as generated evidence, not an editing surface.
- Preserve Pluxx-managed markers and user-owned custom sections.
- Keep deterministic checks in the CLI or scripts; use prose for judgment, routing, and interpretation.
- A removed upstream tool with custom notes is a maintenance decision before it is a taxonomy cleanup.

## Stop And Route

- If `doctor` or `lint` fails, stop semantic refinement and route to verification.
- If a sync is required to reflect changed MCP tools, route to maintenance first.
- If the source already expresses the product accurately, record “no semantic change” instead of rewriting for style.
- After source quality is sound, route to verification. Publishing is not the automatic next step.

## Refinement Report

Return the weakness, evidence, selected pass, source files changed, managed/custom boundaries preserved, validation results, and intentionally unchanged areas. Distinguish an agent suggestion from a validated source improvement.
