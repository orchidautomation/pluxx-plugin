---
name: pluxx-publish-plugin
description: Package the current plugin for release distribution.
---

# Publish Plugin

Use this skill when the user wants to package and distribute the current plugin instead of stopping at local builds.

## Inputs To Clarify

- whether the user wants a local dry run, a GitHub release, or the full publish path
- whether the plugin already passed structural and behavioral proof
- whether screenshots, install links, or proof notes should ship alongside the release

## Workflow

1. Confirm the project is healthy enough to publish:
   - `pluxx doctor`
   - `pluxx lint`
   - `pluxx test`
2. Start with `release-operator` when the host supports specialist agents.
3. Treat proof packaging as part of this workflow when the user needs outreach, docs, screenshots, or shareable install paths in addition to the release artifacts.
4. Run:
   - `pluxx publish`
   - include release flags when the user asks for a specific release path
5. Summarize the release outputs:
   - host bundles
   - installer scripts
   - checksums
   - release metadata

## Decision Points

- If the plugin is only structurally healthy, route first to behavioral proof.
- If the user wants shareable curl links before the first release exists, point them at the raw `main` installers under `release/`.
- If the release is technically fine but the public surface is weak, stay in this workflow and package the proof surface before outreach.
- If the user is testing the release machinery itself, make that explicit rather than overstating external readiness.

## Rules

- Do not skip validation when the scaffold changed materially.
- Be honest when the project is still only locally credible and not yet release-ready.
- If publishing is blocked, return the blockers before any release summary.

## Failure Modes To Call Out

- release path blocked by validation failures
- artifacts generated but no credible install/proof surface
- source pushed but no tagged GitHub release yet, so `releases/latest/download/...` still points at nothing
- stale versioning or tag mismatch
- plugin ready locally but not yet ready for public distribution

## Output

- Tell the user whether publish succeeded.
- List the important release artifacts.
- Call out remaining blockers or manual follow-up.
