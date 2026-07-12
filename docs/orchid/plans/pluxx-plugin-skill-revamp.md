---
title: Pluxx Plugin Skill Revamp
date: 2026-07-11
artifact_readiness: implementation-ready
origin: docs/orchid/requirements/pluxx-plugin-skill-revamp.md
---

# Problem Frame

The plugin is built with Pluxx, but its 11 public skills overlap heavily and use weak trigger descriptions. The source also predates current CLI behavior and the current Agent Skills guidance around intent-first descriptions, coherent units, progressive disclosure, and eval-driven iteration.

## Decisions

1. Publish seven job-shaped skills: `pluxx-guide`, `pluxx-create-plugin`, `pluxx-refine-plugin`, `pluxx-maintain-plugin`, `pluxx-verify-plugin`, `pluxx-translate-hosts`, and `pluxx-publish-plugin`.
2. Fold runtime bootstrap and broad troubleshooting into `pluxx-guide`; fold import, migration, blank initialization, and autopilot into `pluxx-create-plugin`; fold structural/install/behavioral proof into `pluxx-verify-plugin`; fold proof-pack work into `pluxx-publish-plugin`.
3. Keep six explicit commands for parameterized workflows. Broad help remains skill-routed rather than adding a generic command.
4. Add references only where conditional detail would otherwise bloat the skill body.
5. Add `evals/evals.json` and `evals/eval_queries.json` to every public skill.
6. Bump the plugin to `0.2.0` because the public workflow taxonomy changes materially.

## Implementation Units

### U1. Public skill taxonomy

- Files: `skills/*/SKILL.md`, skill-local `references/`, skill-local `evals/`
- Requirements: R2, R3, R4, R5
- Approach: Replace the old 11-skill set with the seven decided user jobs. Use imperative descriptions and procedural bodies with explicit safety boundaries and outputs.
- Test scenarios:
  1. Every folder name matches frontmatter `name` and satisfies the Agent Skills naming rules.
  2. Every description identifies both capability and trigger intent and is below 1,024 characters.
  3. Every skill has 2-3 realistic output evals plus at least eight positive and eight near-miss negative trigger queries.
  4. Conditional references are linked directly from `SKILL.md` and remain one level deep.

### U2. Commands and shared routing

- Files: `commands/*.md`, `INSTRUCTIONS.md`, `README.md`
- Requirements: R6, R7
- Approach: Mirror create/refine/maintain/verify/translate/publish as explicit commands, document the seven-job decision tree, and keep Codex routing honest.
- Test scenarios:
  1. Every command names an existing skill.
  2. No shared instruction references a removed skill or command.
  3. CLI examples match Pluxx `0.1.31` help and official command-decision-tree documentation.

### U3. Pluxx metadata and behavioral contract

- Files: `pluxx.config.ts`, `.pluxx/behavioral-smoke.json`, `AGENTS.md`
- Requirements: R1, R7
- Approach: Bump metadata to `0.2.0`, update default prompts, and replace smoke cases with the new workflow taxonomy.
- Test scenarios:
  1. Config validation passes with all four configured targets.
  2. Behavioral smoke JSON parses and every case maps to a public workflow.
  3. Repo instructions identify source-of-truth, validation, and release boundaries.

### U4. Generated targets and release readiness

- Files: `dist/`, dry-run publish output only
- Requirements: R8, R9
- Approach: Run Pluxx validation, lint, eval, build, and test; validate source skills with `skills-ref`; inspect generated targets; run a non-publishing GitHub release dry run and record external authentication separately from artifact planning.
- Test scenarios:
  1. `pluxx validate`, `pluxx lint`, and `pluxx test` return zero errors.
  2. Every source skill passes `skills-ref validate`.
  3. Generated Claude Code, Cursor, Codex, and OpenCode bundles contain the seven skills and six commands or their documented translated equivalents.
  4. Release planning for `0.2.0` produces the expected asset graph without upload and reports whether GitHub authentication is ready.

## Risks

- Existing users may refer to removed skill names. Mitigate with README migration notes and command/workflow mapping.
- The separate Pluxx repository may continue to advertise 17 skills. Record this as follow-up work rather than editing another repo implicitly.
- Cross-host generated output may surface expected translation warnings. Treat warnings as documented compatibility behavior unless they become errors or silently omit required source intent.

## Validation Status

- Pluxx CLI `0.1.31` matches npm `latest`.
- `pluxx validate`, `pluxx lint`, `pluxx test`, JSON checks, shell syntax, and all seven `skills-ref` validations pass.
- The core-four build contains seven skills, six commands or the documented Codex routing equivalent, all skill-local resources, and version `0.2.0` manifests.
- The Codex plugin is installed and `pluxx verify-install --target codex` passes.
- The GitHub release dry-run produced the complete `0.2.0` asset plan, but local `gh` authentication is invalid. A real release remains blocked until GitHub CLI authentication is repaired and the publish command is explicitly approved.
- Output-quality and trigger eval fixtures are committed, but live behavioral runs were not executed because they would invoke installed host CLIs and were not required for source/build completion.
