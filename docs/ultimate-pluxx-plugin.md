# Ultimate Pluxx Plugin

This document defines the current north star for the first-party Pluxx plugin as of version `0.2.0`.

## Product Promise

The plugin should feel like the native operating layer for the Pluxx CLI, not a command manual copied into a plugin shell.

It should help an operator:

- choose the right Pluxx path without memorizing the CLI
- create one maintained source project from an MCP or host-native plugin
- refine a valid scaffold into user-shaped workflows
- refresh upstream MCP changes without losing custom work
- prove source, build, installed-state, and behavior separately
- explain honest host translation across the core four
- package or publish only evidence-backed release claims

## Public Workflow Surface

Expose seven job-shaped skills:

1. `pluxx-guide`
   CLI installation, upgrades, command selection, orientation, and ambiguous runtime/setup failures.
2. `pluxx-create-plugin`
   Installed-MCP discovery, raw MCP import, local stdio setup, blank interactive initialization, host-plugin migration, and autopilot.
3. `pluxx-refine-plugin`
   Context preparation, taxonomy, shared instructions, examples, and findings-first scaffold review.
4. `pluxx-maintain-plugin`
   Sync preview, upstream refresh, custom-section preservation, and drift explanation.
5. `pluxx-verify-plugin`
   Config, doctor, lint, eval, build, install, consumer diagnosis, installed-state verification, MCP record/replay, and behavioral proof.
6. `pluxx-translate-hosts`
   Preserve, translate, degrade, and drop analysis for instructions, skills, commands, agents, hooks, permissions, runtime, and distribution.
7. `pluxx-publish-plugin`
   Release dry-runs, archives, installers, checksums, manifests, proof assets, GitHub Releases, and npm publishing.

Parameter-bearing work compiles into six explicit commands: create, refine, maintain, verify, translate, and publish. The general guide remains skill-routed. Codex receives skills plus generated routing metadata because plugin-packaged slash-command parity is not currently documented.

## Specialist Layer

Keep narrow specialists underneath the public jobs:

- `import-architect` and `migration-operator` support creation
- `taxonomy-shaper`, `instruction-editor`, and `host-translator` support refinement and translation
- `install-verifier` and `behavioral-tester` support proof
- `release-operator` and `proof-publisher` support distribution

Specialists should not become additional public skills unless they represent a repeated user job with its own reliable trigger boundary.

## Deterministic Versus Agentic Work

Keep these deterministic:

- config validation
- source doctoring and linting
- scaffold evaluation
- target compilation
- install and consumer checks
- MCP tape record/replay
- release manifests, archives, installers, and checksums

Use agentic work for:

- product-context synthesis
- workflow taxonomy
- instruction rewriting
- host translation review
- findings-first scaffold critique
- realistic behavioral cases and proof interpretation
- public proof narrative constrained by completed evidence

## Agent Skills Quality Bar

Every public skill must:

- use an intent-first `description` that fits the strictest core-host display limit
- own one coherent job and avoid trigger collision with adjacent skills
- keep essential procedure in `SKILL.md`
- move conditional detail into directly linked, one-level `references/`
- include 2–3 realistic output-quality evals
- include at least eight positive and eight near-miss negative trigger queries
- preserve user work and state external side effects explicitly

Treat raw MCP discovery output as sensitive. It may include credential-bearing URL query strings or stdio arguments; summarize only the selector, name, host, and transport needed for the workflow.

## Proof Contract

Report the strongest completed layer, never the hoped-for layer:

```text
config -> source health -> host lint -> scaffold quality -> build smoke
       -> consumer health -> installed state -> real behavior
```

A successful build does not prove installation. A successful install does not prove workflow behavior. Expected host translation warnings are caveats unless required intent is missing.

## Compiler Contract

The root source project is canonical. `dist/` is generated and must be rebuilt through Pluxx.

The core-four story must remain honest:

- skills are the semantic center
- commands degrade in Codex today
- agents translate into host-native or install-managed companion surfaces
- hooks and permissions use different enforcement surfaces by host
- OpenCode is often code/config driven where other hosts are manifest driven

Prefer source-shape improvements over hand-edited target patches.

## Release Contract

Before publishing:

- validate, lint, test, and rebuild current source
- inspect working-tree, repository, version, and tag state
- preview the exact publish plan
- ensure proof claims match completed evidence
- obtain explicit approval for upload
- verify GitHub or npm authentication

Raw `main` installer links and tagged `releases/latest/download/...` links are different channels. Do not imply a tagged release exists until it does.

## Success Criteria

The plugin is ready when:

- seven skills and six commands compile across the core four
- source skills pass the Agent Skills validator
- references, evals, and UI metadata survive compilation
- deterministic Pluxx tests pass with only documented translation warnings
- installed-state verification passes for the requested host
- no stale legacy workflow files or metadata leak into generated bundles
- README, shared instructions, and this north star use the same taxonomy
