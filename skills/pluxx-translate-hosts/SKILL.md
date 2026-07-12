---
name: pluxx-translate-hosts
description: Use this skill when a user asks what a Pluxx source preserves, translates, degrades, or drops across Claude Code, Cursor, Codex, and OpenCode. Audit the relevant compiler buckets and recommend source-shape fixes.
---

# Translate Across Hosts

Describe host truth without promising fake parity.

## Workflow

1. Identify the target hosts and compiler buckets in scope.
2. Run `pluxx lint` and `pluxx build --target <hosts...>` when current output is required.
3. Read [references/core-four.md](references/core-four.md) for the baseline mapping, then confirm important claims against current Pluxx output.
4. Classify each relevant surface:
   - preserve: the host has a faithful native surface
   - translate: Pluxx re-expresses the same intent through another native form
   - degrade: a weaker but honest equivalent remains
   - drop: no truthful target surface exists
5. Review only the buckets the user needs: instructions, skills, commands, agents, hooks, permissions, runtime, and distribution.
6. Recommend a source-shape fix when moving intent into skills, instructions, agents, scripts, or runtime configuration improves portability.
7. After any source change, run `pluxx validate`, `skills-ref validate` for changed skills, and rebuild; never patch target output as the durable fix.

## Output

Return a concise host-by-bucket matrix, the evidence used, target-specific caveats, and the highest-value source-shape improvement.
