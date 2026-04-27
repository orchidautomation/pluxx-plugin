---
name: pluxx-translate-hosts
description: Review how the current scaffold preserves, translates, degrades, or drops behavior across the core four.
---

# Pluxx Translate Hosts

Use this skill when the user wants the truth about cross-host quality, not a vague “supports Claude/Cursor/Codex/OpenCode” claim.

## Inputs To Clarify

- whether the user wants a whole-plugin view or a single-surface view
- whether the current concern is commands, agents, hooks, permissions, runtime, or distribution
- whether the question is “does it work?” or “does it feel native?”

## Workflow

1. Start with `host-translator` when the host supports specialist agents.
2. Inspect the current source of truth:
   - `pluxx.config.ts`
   - `INSTRUCTIONS.md`
   - `skills/`
   - `commands/`
   - `agents/`
3. Run structural checks when needed:
   - `pluxx doctor`
   - `pluxx lint`
4. Return the preserve / translate / degrade / drop story for:
   - instructions
   - skills
   - commands
   - agents
   - hooks
   - permissions
   - runtime
   - distribution
5. Recommend the smallest next improvement that would make the plugin feel more native.

## Decision Points

- If structural checks are failing, fix those before debating translation nuance.
- If a host-specific workflow bug already exists, prefer behavioral proof over abstract translation commentary.
- When the plugin is good enough, say so directly instead of manufacturing work.

## Rules

- Be honest about host gaps.
- Distinguish “works” from “feels native.”
- Prefer the current core-four matrix language instead of inventing new labels.

## What Good Translation Review Usually Surfaces

- where commands are truly native vs only guided
- whether subagents are preserved or flattened
- where permissions and hooks still feel like translations rather than first-class surfaces
- whether distribution/install feels polished enough to claim externally

## Output

- Return the translation truth clearly.
- Call out the highest-leverage weak spot.
- Recommend the next implementation step.
