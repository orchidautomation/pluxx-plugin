---
name: pluxx-refine-plugin
description: Take a valid scaffold and turn it into a product-shaped, host-honest plugin.
---

# Refine Plugin

Use this skill when the first scaffold exists, but it still feels too lexical,
too generic, or too weak to ship as a serious plugin source.

This is the refinement journey. It intentionally bundles several internal
stages that advanced operators may think of separately:

- context preparation
- taxonomy shaping
- instruction rewriting
- host translation review
- findings-first scaffold review

## Inputs To Clarify

- whether the source is a new import, a migrated plugin, or a synced scaffold
- whether the main weakness is product framing, workflow grouping, host nuance,
  or overall quality
- whether the user wants the lightest credible pass or a stronger polish pass
- whether supporting docs, website context, or local product notes are available

## Workflow

1. Identify the real refinement target:
   - missing product context
   - weak taxonomy
   - generic instructions
   - host-translation confusion
   - broad scaffold quality concerns
2. If context is weak, prepare it first:
   - `pluxx agent prepare --website ... --docs ...`
3. Use specialist agents when the host supports them:
   - `taxonomy-shaper`
   - `instruction-editor`
   - `host-translator`
4. Tighten the scaffold as one coordinated refinement pass rather than as
   several disconnected edits.
5. Re-run the smallest useful structural checks:
   - `pluxx lint`
   - `pluxx eval`
   - `pluxx test`
6. Return:
   - what changed
   - what stayed intentionally unchanged
   - what still needs proof rather than more copywriting

## Decision Points

- If the scaffold is structurally unhealthy, do not over-refine it; route next
  to the proof path.
- If the user mainly wants preserve / translate / degrade / drop truth, lean
  harder on the host-translation review inside this workflow.
- If the main issue is install/runtime visibility, stop refining and route next
  to `pluxx-prove-plugin`.

## Rules

- Keep the visible user job simple: “make this plugin feel real,” not “pick one
  of five adjacent micro-commands.”
- Group recommendations by user job and host reality, not by file names alone.
- Do not pretend host parity where translation or degradation is the honest
  answer.
- If the scaffold already reads well, do not churn wording just to look busy.

## Failure Modes To Call Out

- context is too weak to support credible refinement
- taxonomy is product-shaped in source but still weak in a target host
- instructions improved, but the real problem is install/runtime proof
- scaffold is readable now, but still not proven

## Output

- Explain the refinement pass in workflow terms, not as a file-by-file changelog.
- Call out the core-four translation story when it matters.
- Make the next step obvious:
  - prove it
  - sync later
  - or publish
