---
title: Pluxx Plugin Skill Revamp Requirements
date: 2026-07-11
status: approved-by-request
---

# Product Contract

The Pluxx plugin must guide users through the current Pluxx CLI without exposing a fragmented skill for every CLI stage. It must remain a real Pluxx source project, compile through the released CLI, and follow the Agent Skills specification and creation guidance.

## Requirements

- R1: Verify the locally installed Pluxx CLI against the official npm `latest` tag and upgrade only when stale.
- R2: Replace overlapping public skills with a small, job-shaped workflow surface covering broad guidance/setup, creation, refinement, maintenance, verification, host translation, and publishing.
- R3: Make every skill discoverable through an imperative, intent-first `description` that includes concrete trigger contexts and remains below 1,024 characters.
- R4: Keep each `SKILL.md` concise and self-contained; move conditional technical detail into one-level `references/` resources.
- R5: Add realistic output-quality evals plus at least eight positive and eight near-miss negative trigger queries for every public skill.
- R6: Keep explicit commands aligned with parameterized public workflows while preserving honest Codex degradation into skills and routing guidance.
- R7: Update shared instructions, README, plugin metadata, and behavioral smoke cases to use the same workflow taxonomy.
- R8: Rebuild all configured targets through Pluxx and validate source skills plus generated host bundles.
- R9: Do not publish releases, install host bundles, or edit the separate `orchidautomation/pluxx` repository without explicit approval.

## Scope Boundary

This change updates `orchidautomation/pluxx-plugin`. The upstream Pluxx repository currently documents a legacy 17-skill surface; aligning that repository is a separate follow-up because it is a different codebase and PR lifecycle.
