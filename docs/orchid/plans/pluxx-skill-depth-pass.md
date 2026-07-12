---
title: Pluxx Skill Depth Pass
date: 2026-07-12
artifact_readiness: implementation-ready
origin: user review after v0.2.0
---

# Problem Frame

The seven public Pluxx skills have clear job boundaries, but several rely on an operator already knowing the CLI's failure modes and ownership rules. The second pass should improve decisions, recovery, and proof without turning every `SKILL.md` into an exhaustive manual.

## Decisions

1. Keep the seven-skill public taxonomy unchanged.
2. Keep each `SKILL.md` as a short routing and execution contract.
3. Put conditional detail in directly linked, one-level-deep references.
4. Do not add wrapper scripts for behavior already implemented deterministically by the Pluxx CLI.
5. Ground guidance in Pluxx `0.1.31`, including sync ownership, install repair, publish checks, and current core-four translation behavior.
6. Bump the plugin patch version to `0.2.1` because the compiled guidance changes after the `0.2.0` release.

## Implementation Units

### U1. Decisions and safety

- Expand creation source/auth/runtime choices.
- Add runtime troubleshooting to the guide.
- Add sync preview interpretation and recovery guidance.

### U2. Quality and proof

- Add a refinement symptom-to-pass playbook.
- Expand the proof ladder and add failure diagnosis.
- Expand host translation evidence and source-shape guidance.

### U3. Release operations

- Expand release modes, artifact checks, public verification, and recovery paths.
- Strengthen eval expectations without increasing the public skill count.

### U4. Validation

- Run `pluxx validate`, `pluxx lint`, and `pluxx test` for all four targets.
- Run `skills-ref validate` for every source skill.
- Inspect generated core-four resources and version metadata.
- Forward-test representative create, maintain, and verify/publish decisions with fresh agents.

## Stop Conditions

- Do not publish or install as part of this pass.
- Do not edit `dist/` directly; regenerate it through Pluxx.
- Do not broaden into new public workflows unless evaluation shows a real routing gap.

## Validation Status

- `pluxx validate`, `pluxx lint`, and `pluxx test --target claude-code cursor codex opencode` pass for `0.2.1`.
- All seven source skills pass `skills-ref validate`; eval JSON, Pluxx JSON, shell syntax, and `git diff --check` pass.
- Each generated target contains seven skills and nine reference files with `0.2.1` manifest metadata.
- Fresh-agent forward tests covered installed-MCP creation, sync preservation/runtime drift, and proof/release boundaries. Reported CLI and safety ambiguities were corrected and the final regression found no blockers.
- The GitHub Release dry-run produced the complete `0.2.1` asset plan without upload; GitHub authentication and repository resolution pass when run with keyring/network access.
- The installed Codex plugin remains released `0.2.0`; `verify-install` correctly reports it stale against this unreleased `0.2.1` branch. Update it only after the branch is reviewed and released.
