---
name: pluxx-translate-hosts
description: Review preserve, translate, degrade, and drop behavior across Claude Code, Cursor, Codex, and OpenCode.
---

# Translate Hosts

Use this skill when the user needs to understand how a Pluxx source project maps into the core four.

The goal is not to promise fake parity. The goal is to preserve author intent and explain where each host gets a native surface, a translated equivalent, a weaker equivalent, or no honest equivalent.

The matching command carries the argument UX:

- `/pluxx:translate-hosts [surface-or-target optional]`

## Inputs To Clarify

- whether the user wants a full core-four review or one target
- whether the focus is skills, commands, agents, hooks, permissions, runtime, or distribution
- whether the source was imported from MCP, migrated from one host, or hand-authored
- whether the plugin is meant to be public, internal, or only a local operator pack

## Workflow

1. Run or inspect current validation output:
   - `pluxx lint`
   - `pluxx build --target claude-code cursor codex opencode`
2. Ask `host-translator` to review the highest-risk surface:
   - commands and argument UX
   - specialist agents/subagents
   - hooks and trust behavior
   - permissions and `allowed-tools` intent
   - MCP/auth/runtime materialization
3. Explain the mapping by bucket:
   - instructions
   - skills
   - commands
   - agents
   - hooks
   - permissions
   - runtime
   - distribution
4. For every important caveat, classify it as:
   - preserve
   - translate
   - degrade
   - drop
5. Recommend the best source-shape fix when a degraded host could be improved by moving intent to commands, agents, permissions, hooks, or runtime config.

## Current Core-Four Taste

- Put reusable workflow meaning in skills.
- Promote repeated parameterized entrypoints into commands with `argument-hint`.
- Use `arguments` on skills when Claude-style argument UX helps.
- Promote isolated research, review, migration, proof, or release work into agents/subagents.
- Use `agent` and `subtask` on command frontmatter when one command clearly maps to one specialist.
- Treat hooks as portable intent, not portable syntax.
- Treat permissions as portable allow/ask/deny intent, then let Pluxx re-express it per host.
- Explain Codex command and hook degradation honestly.
- Explain OpenCode code-first runtime generation honestly.

## Rules

- Do not flatten host-specific nuance into "supported everywhere."
- Do not overfit to Claude-only frontmatter when a portable agent or permission surface is better.
- Do not hand-edit generated `dist/` as the fix; fix the source project.
- Prefer improving source authoring shape over adding target-specific hacks.

## Output

- concise preserve/translate/degrade/drop matrix
- highest-value source-shape fix
- target-specific caveats users need to know before publishing
