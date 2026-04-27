# Ultimate Pluxx Plugin

This document defines the bar for the first-party `pluxx-plugin`.

The plugin should not feel like a thin wrapper around CLI commands. It should
feel like the native operating environment for building, translating, proving,
and shipping serious multi-host plugins with Pluxx.

## Why This Exists

Pluxx is trying to solve a real product problem:

- MCPs spread across hosts quickly.
- Every host grows its own plugin surface.
- Teams accumulate separate Claude, Cursor, Codex, and OpenCode overhead.
- The workflow layer starts drifting even when the underlying MCP stays the
  same.

The first-party Pluxx plugin should make that problem obvious, then show the
best possible answer:

- one maintained source project
- host-native outputs
- agentic refinement where it helps
- deterministic proof where it matters
- release-ready packaging at the end

## What The Current Plugin Already Does Well

The current plugin already covers the core lifecycle:

- import an MCP
- migrate a native plugin
- prepare docs and website context
- refine taxonomy
- rewrite instructions
- review a scaffold
- validate a scaffold
- build and install bundles
- verify installed state
- sync an MCP-derived scaffold
- run a one-shot autopilot path
- publish plugin release assets

That is a strong baseline.

## What The Current Plugin Still Feels Like

The plugin should avoid feeling like:

- one command per internal step
- a visible skill for every sub-stage
- a CLI manual copied into a plugin shell

The public surface should instead collapse into a smaller number of user jobs,
with the specialist logic moved underneath into the agent graph.

The Exa walkthrough raised the bar. It showed that a serious plugin should also
prove:

- specialist subagent orchestration
- host-specific translation honesty
- behavioral proof, not just build/install proof
- public packaging and install UX
- migration-first credibility, not just net-new scaffolding

## Design Principles

1. Show the full Pluxx value proposition.
   The plugin should explain the problem Pluxx solves before it jumps into what
   command to run.

2. Be migration-first, not only greenfield-first.
   Most serious users will arrive with an MCP, a half-built plugin, or a
   single-host implementation that already exists.

3. Use specialists where specialists help.
   If the host supports subagents, the plugin should show a high bar for
   delegation.

4. Keep deterministic checks explicit.
   Agentic orchestration is useful, but structural trust still comes from
   `doctor`, `lint`, `eval`, `test`, `build`, `install`, and `verify-install`.

5. Treat behavioral proof as first-class.
   A bundle existing on disk is not enough. The workflow needs to actually run
   correctly inside the host.

6. Model host differences honestly.
   The plugin should make preserve / translate / degrade / drop behavior more
   visible, not less.

## Primitive Coverage Standard

The first-party Pluxx plugin should demonstrate all major Pluxx surfaces in one
place:

- `instructions`
- `skills`
- `commands`
- `agents`
- `hooks`
- `permissions`
- `runtime`
- `distribution`

`taxonomy` remains an internal shaping layer, but the plugin should still make
it obvious how taxonomy drives the user-facing outputs.

## Target User Journeys

The plugin should feel excellent for four top-level journeys:

1. Import a raw MCP into a serious plugin scaffold
2. Migrate an existing single-host plugin into Pluxx
3. Refine and prove a scaffold until it is credibly native across the core four
4. Package and ship a release with install links, screenshots, and proof

## The Ideal Specialist Agent Graph

The first-party plugin should expose a visible specialist system instead of
only broad workflow wrappers.

### Import Architect

Owns:

- MCP source inspection
- auth mapping
- runtime shape
- first-pass scaffold choices

### Migration Operator

Owns:

- native host plugin intake
- preserving real host intent
- identifying translation caveats
- establishing the new Pluxx source of truth

### Taxonomy Shaper

Owns:

- workflow grouping
- command entrypoint shape
- deciding when tool dumps should become product workflows

### Instruction Editor

Owns:

- `INSTRUCTIONS.md`
- shared product framing
- host-aware behavior guidance

### Host Translator

Owns:

- preserve / translate / degrade / drop review
- host-native surface decisions
- compatibility caveats

### Install Verifier

Owns:

- local install loops
- `verify-install`
- host-specific diagnosis when something is visible on disk but not working

### Behavioral Tester

Owns:

- headless example queries
- checking for real responses
- catching degraded behavior that deterministic build/install checks miss

### Release Operator

Owns:

- build artifacts
- release bundles
- installer scripts
- checksums
- publish flow

### Proof Publisher

Owns:

- screenshots
- proof notes
- install snippets
- demo/readme/blog packaging

## Command Surface We Should Aim For

The public command surface should stay small and workflow-driven:

- `/pluxx:bootstrap-runtime`
- `/pluxx:import-mcp`
- `/pluxx:migrate-plugin`
- `/pluxx:refine-plugin`
- `/pluxx:prove-plugin`
- `/pluxx:sync-mcp`
- `/pluxx:publish-plugin`
- `/pluxx:autopilot`

The internal stages should still exist, but as hidden specialist behavior:

- context prep
- taxonomy shaping
- instruction rewriting
- host translation review
- findings-first scaffold review
- deterministic validation
- build/install
- verify-install
- behavioral proof
- proof packaging

## Deterministic Vs Agentic Boundaries

The first-party plugin should be explicit about what stays deterministic and
what becomes agentic.

### Deterministic

- config validation
- linting
- structural tests
- build
- install
- verify-install
- publish artifact generation

### Agentic

- import shaping beyond the first deterministic pass
- taxonomy refinement
- instruction rewriting
- translation review
- proof narrative and packaging
- behavioral smoke analysis

## Behavioral Proof Standard

The Exa walkthrough proved that install/build proof is necessary but not
enough.

The first-party plugin should push a higher standard:

- installable bundle proof
- installed host visibility proof
- behavioral query proof
- host-by-host failure explanation when behavior diverges

The ideal workflow is:

1. `pluxx doctor`
2. `pluxx lint`
3. `pluxx eval`
4. `pluxx test`
5. `pluxx build`
6. `pluxx install`
7. `pluxx verify-install`
8. behavioral smoke / headless query pass

## Migration Standard

The first-party plugin should make a strong promise here:

- importing a raw MCP is supported
- migrating a real single-host plugin is equally first-class

That means the plugin should actively guide users through:

- what migrated cleanly
- what translated
- what degraded
- what needs manual review

It should not sound like migration is a niche path.

## Packaging Standard

The plugin should not stop at “the source scaffold is healthy.”

It should help users leave with:

- host bundles
- installer scripts
- release checksums
- direct install snippets
- screenshots
- a proof note or demo page

## The Delta From The Current Plugin

The current repo is strong on lifecycle coverage, but it still needs to grow
in four areas:

1. richer visible specialist-agent structure
2. first-class behavioral proof workflows
3. stronger translation-review surfaces
4. clearer public proof/demo packaging

## Concrete Hit List

### P0

1. Add a `behavioral-proof` workflow and command surface.
2. Add a `translate-hosts` workflow and command surface.
3. Add a `proof-pack` workflow and command surface.
4. Turn the current broad workflow pack into a visible specialist graph.
5. Add headless behavioral smoke ownership to the plugin repo release story.

### P1

1. Expand screenshots so the plugin demonstrates more than import/build.
2. Add a migration-first proof path to README/install docs.
3. Improve copy so the plugin explains the Pluxx problem before the commands.
4. Add explicit host-translation caveat summaries to the plugin surface.

### P2

1. Add richer release/demo asset generation helpers.
2. Add a public-facing proof checklist template for plugin authors.
3. Add deeper behavioral examples for migration-heavy workflows.

## Success Criteria

The first-party Pluxx plugin sets the bar when:

- a new user can discover the real Pluxx lifecycle from the plugin itself
- an existing plugin author can migrate rather than restart from scratch
- the plugin clearly uses subagents where the host supports them
- the plugin proves behavior, not just build/install state
- the plugin demonstrates all current major Pluxx primitives in one place
- the plugin reads like the best multi-agent plugin in the repo, not just a
  helper around the CLI
