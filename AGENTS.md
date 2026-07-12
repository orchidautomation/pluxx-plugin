# Repo Agent Instructions

## Product Context

- Purpose: Guide operators through the current `@orchid-labs/pluxx` CLI and compile one maintained source project into honest host-native plugins.
- Primary users: MCP owners, plugin authors, and host-agent users working in Claude Code, Cursor, Codex, or OpenCode.
- Production surface: Source skills, commands, agents, instructions, and assets compile through `pluxx build` into `dist/` and release bundles.

## Source Of Truth

- Edit the source project at the repo root; never hand-edit `dist/` as the fix.
- Use the installed `pluxx` CLI when available, then fall back to `npx @orchid-labs/pluxx`.
- Keep public workflows job-shaped. Internal CLI steps may compose inside a skill instead of becoming separate public skills.
- Keep credentials and machine-local runtime configuration out of version control.

## Workflow

- Use Linear as the source of truth for scoped work.
- Keep implementation work on task branches or worktrees, not directly on main.
- Link PRs back to Linear issue keys.
- Store durable agent artifacts under docs/orchid/.
- Keep temporary/raw agent outputs in .agent-artifacts/.

## Artifact Map

- Brainstorms and PRDs: docs/orchid/brainstorms, docs/orchid/requirements
- Implementation plans: docs/orchid/plans
- To-dos and handoffs: docs/orchid/todos
- Reviews and QA evidence: docs/orchid/reviews, docs/orchid/qa
- Work history and provenance summaries: docs/orchid/history
- Visual plans and recaps: docs/orchid/visual-plans, docs/orchid/visual-recaps
- Durable decisions and reusable lessons: docs/orchid/decisions, docs/orchid/solutions

## Validation

- Required checks: `pluxx validate`, `pluxx lint`, `pluxx test`, and `skills-ref validate` for every source skill.
- Manual QA: Inspect all four generated targets and verify skill resources, commands, agents, and instructions are present in the expected host-native surfaces.
- Deployment/release proof: Run `pluxx publish --github-release --version <version> --allow-dirty --dry-run`; only publish or install when explicitly requested.

## Privacy And Safety

- Do not commit secrets, raw private transcripts, auth files, cookies, API tokens, or browser session data.
- Keep temporary/raw agent outputs in .agent-artifacts/.
