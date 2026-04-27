---
name: pluxx-review-scaffold
description: Critically review a Pluxx scaffold before shipping.
---

# Pluxx Review Scaffold

Use this skill when the goal is to review a scaffold, not to rewrite it blindly.

## Inputs To Clarify

- whether the review is pre-import, pre-install, or pre-release
- whether the user wants findings on workflow quality, host fit, or both
- whether the scaffold was imported from raw MCP or migrated from a host-native plugin

## Workflow

1. Refresh the agent pack:
   - `pluxx agent prepare`
2. Generate or run the review prompt:
   - `pluxx agent prompt review`
   - or `pluxx agent run review --runner codex`
3. Inspect:
   - `INSTRUCTIONS.md`
   - `skills/*/SKILL.md`
   - any relevant docs/site context in `.pluxx/agent/context.md`
4. If needed, run:
   - `pluxx doctor`
   - `pluxx lint`
   - `pluxx test`

## Decision Points

- When the problem is obvious from the generated content, do not waste time on a full test pass before returning findings.
- When the scaffold is structurally healthy but still feels wrong, focus on taxonomy, instruction clarity, and host translation truth.
- Route to `pluxx-translate-hosts` when the main question is parity rather than general quality.

## Rules

- Findings first, ordered by severity.
- Focus on bad grouping, missing setup guidance, weak examples, and product/category mismatches.
- Keep recommendations inside Pluxx-managed boundaries unless the user explicitly asks for deeper refactors.
- If there are no findings, say that directly and note residual risks.

## What Strong Findings Usually Cover

- weak workflow grouping
- auth or setup instructions that would confuse a real operator
- overclaiming native parity across the core four
- missing proof steps such as install verification or behavioral smoke
- workflows that read like raw tool dumps instead of product surfaces

## Output

- Return concrete findings tied to files.
- Keep summaries brief after the findings.
