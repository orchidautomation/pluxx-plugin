---
name: pluxx-rewrite-instructions
description: Rewrite INSTRUCTIONS.md so a Pluxx scaffold explains itself clearly.
---

# Pluxx Rewrite Instructions

Use this skill when the scaffold structure is fine but the shared instructions need to sound more like the actual MCP product.

## Inputs To Clarify

- what the product actually helps users do
- what setup or auth caveats must be surfaced early
- whether the user wants a terse operator voice or a more guided onboarding voice
- whether the current instructions are weak because they are too generic or because the source context is still incomplete

## Workflow

1. Refresh context:
   - `pluxx agent prepare`
   - include `--website`, `--docs`, and local context files when they clarify the product
2. Generate or run the instructions prompt:
   - `pluxx agent prompt instructions`
   - or `pluxx agent run instructions --runner codex`
3. Limit edits to the generated block in `INSTRUCTIONS.md`.
4. Re-run:
   - `pluxx lint`
   - `pluxx test`

## Decision Points

- If the product story is still fuzzy, route first to `pluxx-prepare-context` instead of inventing copy.
- If the instructions are fine but the skill grouping is wrong, route to `pluxx-refine-taxonomy` instead of overloading the instruction rewrite.
- If the real issue is cross-host nuance, route next to `pluxx-translate-hosts`.

## Rules

- Keep the output concise and operational.
- Make setup/auth caveats explicit when they affect tool usage.
- Use branded product-facing language and avoid raw MCP server/tool naming unless technically required.
- Clarify setup/admin/account/runtime boundaries so agents know where each skill belongs.
- Explain what the plugin is for, how the skills should be used, and what the host agent must not do.
- Do not rewrite custom sections unless the user explicitly asks.

## Failure Modes To Avoid

- copying raw MCP language into product-facing instructions
- burying critical auth/setup caveats too late
- promising host behaviors the generated plugin cannot actually preserve
- bloating `INSTRUCTIONS.md` when the real problem belongs in individual skills

## Output

- Summarize the instruction changes.
- Mention any setup/auth caveats that still need manual confirmation.
