---
name: pluxx-prepare-context
description: Ingest website docs, product docs, and local context into the Pluxx agent pack.
---

# Pluxx Prepare Context

Use this skill when the user wants better semantic refinement because the default MCP scaffold does not yet have enough product context.

## Inputs To Clarify

- official website or docs URLs
- whether local docs or product notes exist already
- whether the user wants context for taxonomy, instructions, review, or migration work
- whether the source material is public or account-specific

## Workflow

1. Identify the context sources:
   - website URL
   - docs URL
   - local context files
2. Run:
   - `pluxx agent prepare`
   - include `--website`, `--docs`, `--context`, and provider flags when they matter
3. Summarize the written artifacts:
   - `.pluxx/sources.json`
   - `.pluxx/docs-context.json`
   - `.pluxx/agent/context.md`
4. Recommend the next best pass:
   - `pluxx-refine-taxonomy`
   - `pluxx-rewrite-instructions`
   - `pluxx-review-scaffold`

## Decision Points

- If the official docs are weak, say so and lower confidence instead of pretending the context is high-quality.
- If the user has private local product notes, prefer those over noisy web marketing copy.
- If the user is just trying to prove install/runtime behavior, do not detour through context prep unnecessarily.

## Rules

- Keep sourced context deterministic and inspectable.
- Do not pretend ingestion itself improved the scaffold; it prepares the refinement inputs.
- Call out when the ingested sources still look weak or noisy.

## What Good Context Usually Includes

- clear product positioning
- setup/auth requirements
- real user workflows rather than just tool names
- terminology that should appear in instructions and skill titles
- examples strong enough to anchor later proof runs

## Output

- Tell the user what was ingested.
- Point to the context artifacts that now exist.
- Recommend the next semantic workflow.
