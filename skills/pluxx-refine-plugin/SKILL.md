---
name: pluxx-refine-plugin
description: Use this skill when a valid Pluxx scaffold is generic, tool-shaped, fragmented, or unclear. Apply product context, improve workflow taxonomy, rewrite shared instructions, or run a findings-first scaffold review.
---

# Refine A Pluxx Plugin

Improve semantic quality only after the deterministic scaffold is healthy.

## Workflow

1. Run `pluxx doctor` and `pluxx lint`. Fix structural errors before semantic work.
2. Identify the smallest useful refinement:
   - missing product context
   - tool-per-skill or fragmented taxonomy
   - generic or inaccurate shared instructions
   - weak examples, setup boundaries, or host framing
   - findings-first pre-ship review
3. Read [references/refinement-playbook.md](references/refinement-playbook.md) when pass selection, taxonomy grouping, source ownership, or stop conditions are unclear.
4. Use `taxonomy-shaper`, `instruction-editor`, or `host-translator` for the matching bounded pass when the host supports specialists.
5. Prepare context when needed with `pluxx agent prepare --website <url> --docs <url>`.
6. Inspect prompt packs with `pluxx agent prompt <taxonomy|instructions|review>` when the user wants control before execution.
7. Run only the required passes:
   - `pluxx agent run taxonomy --runner <runner>`
   - `pluxx agent run instructions --runner <runner>`
   - `pluxx agent run review --runner <runner> --no-verify`
8. Edit source skills and `INSTRUCTIONS.md`; never fix generated `dist/` directly.
9. Re-run `pluxx validate`, `pluxx lint`, `skills-ref validate` for changed source skills, `pluxx eval`, and `pluxx test` after the refinement.

## Quality Rules

- Group around user outcomes, not raw MCP tool names.
- Keep skill descriptions intent-first and specific enough to avoid adjacent workflow collisions.
- Preserve managed/custom ownership boundaries during rewrites.
- Prefer one coherent workflow over several micro-skills that must always load together.
- Keep `SKILL.md` lean; move conditional detail into directly linked `references/` files.
- Leave deterministic commands and fragile checks in scripts rather than re-generating them as prose.

## Output

Explain the product weakness addressed, source changes made, validation result, intentionally unchanged surfaces, and the next verification step.
