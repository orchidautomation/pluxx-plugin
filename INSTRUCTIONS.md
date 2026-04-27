## Pluxx Plugin

Use Pluxx when the user wants to turn an MCP server into a maintainable plugin project, improve a generated scaffold, review it critically, or sync it later after the MCP changes.

Pluxx exists because MCP teams quickly accumulate host-specific overhead:
separate Claude, Cursor, Codex, and OpenCode surfaces; repeated install
packaging; duplicated workflow prompts; and drift between “the same” plugin in
four places. Pluxx is the source-of-truth layer that tries to keep that
workflow logic maintained once while still shipping native-feeling outputs per
host.

### What Pluxx Is For

Pluxx is the plugin authoring and maintenance layer for MCP teams.

The normal workflow is:

1. import an MCP into a deterministic scaffold
2. migrate an existing single-host plugin when needed
3. optionally prepare docs, website, and local context before semantic passes
4. bootstrap or upgrade the Pluxx runtime when the machine is stale or missing it
5. inspect and validate the generated project
6. optionally refine taxonomy and instructions with a host agent
7. review host translation quality across the core four
8. build, verify, and install the target plugin bundles
9. run behavioral proof when the workflow nuance matters
10. package install/proof assets
11. publish when the plugin is actually ready to distribute

### Main Workflows

- `pluxx-import-mcp`
  Use when the user wants to scaffold a plugin from a remote MCP URL or a local stdio MCP command.

- `pluxx-migrate-plugin`
  Use when the user already has a Claude Code, Cursor, Codex, or OpenCode plugin and wants to bring it into Pluxx.

- `pluxx-validate-scaffold`
  Use when the user wants a deterministic health and quality pass with `doctor`, `lint`, `eval`, and `test`.

- `pluxx-prepare-context`
  Use when the user wants to ingest website docs, product docs, or local context before rewriting taxonomy or instructions.

- `pluxx-refine-taxonomy`
  Use when the generated skill grouping is too lexical, fragmented, or not product-shaped enough.

- `pluxx-rewrite-instructions`
  Use when the scaffold structure is fine but the shared instructions need to sound more like the actual product.

- `pluxx-review-scaffold`
  Use when the user wants findings before shipping, not blind rewrites.

- `pluxx-bootstrap-runtime`
  Use when the machine is missing `pluxx`, is stale, or the user wants a smoother operator path than ad hoc `npx` usage.

- `pluxx-translate-hosts`
  Use when the user wants preserve / translate / degrade / drop truth across Claude, Cursor, Codex, and OpenCode.

- `pluxx-build-install`
  Use when the user wants to build installable plugins and optionally install one or more targets locally.

- `pluxx-verify-install`
  Use when the user wants to prove an installed host target is actually visible and healthy.

- `pluxx-behavioral-proof`
  Use when the user wants to prove installed workflows actually behave correctly with real example prompts.

- `pluxx-sync-mcp`
  Use when an existing MCP-derived scaffold needs to be refreshed safely.

- `pluxx-autopilot`
  Use when the user wants the one-shot import, refine, and verification path.

- `pluxx-proof-pack`
  Use when the user wants install links, screenshots, docs/example pages, and a shareable proof surface.

- `pluxx-publish-plugin`
  Use when the user wants to package the current plugin for release distribution.

### Explicit Commands

- `/pluxx:import-mcp`
  Explicit entrypoint for turning an MCP URL or stdio command into a first-pass Pluxx scaffold.

- `/pluxx:migrate-plugin`
  Explicit entrypoint for bringing an existing host-native plugin into a maintained Pluxx source project.

- `/pluxx:validate-scaffold`
  Explicit entrypoint for running deterministic health and quality checks before deeper edits or shipping.

- `/pluxx:prepare-context`
  Explicit entrypoint for ingesting website docs, product docs, or local files into the Pluxx agent pack before semantic refinement.

- `/pluxx:refine-taxonomy`
  Explicit entrypoint for improving skill grouping after the first pass is already valid.

- `/pluxx:rewrite-instructions`
  Explicit entrypoint for tightening `INSTRUCTIONS.md` without rewriting the whole scaffold.

- `/pluxx:review-scaffold`
  Explicit entrypoint for findings-first review before shipping.

- `/pluxx:bootstrap-runtime`
  Explicit entrypoint for installing, upgrading, or checking the Pluxx CLI runtime.

- `/pluxx:translate-hosts`
  Explicit entrypoint for reviewing preserve / translate / degrade / drop behavior across the core four.

- `/pluxx:build-install`
  Explicit entrypoint for building the requested target bundles and optionally installing them locally for testing.

- `/pluxx:verify-install`
  Explicit entrypoint for verifying that an installed target is actually visible and healthy in the host.

- `/pluxx:behavioral-proof`
  Explicit entrypoint for running the installed behavioral proof path with example queries.

- `/pluxx:sync-mcp`
  Explicit entrypoint for refreshing an existing scaffold from its MCP source.

- `/pluxx:autopilot`
  Explicit entrypoint for the one-shot import, refine, and verification path.

- `/pluxx:proof-pack`
  Explicit entrypoint for packaging screenshots, install links, and proof notes around a healthy plugin.

- `/pluxx:publish-plugin`
  Explicit entrypoint for packaging the current plugin for release distribution.

These command entrypoints are for hosts that support plugin commands directly. In Codex, use `@pluxx` and pick the matching skill instead; `/` is reserved for native Codex commands.

### CLI Resolution

When these instructions say `pluxx ...`, treat that as the logical Pluxx command.

Resolve it in this order:

1. local `pluxx` on `PATH`
2. `npx @orchid-labs/pluxx`

If the npm path fails because Node or package resolution is missing, surface that clearly instead of improvising a different runtime contract.
If the machine is missing the runtime or is on a stale version and the user wants help fixing it, route through `pluxx-bootstrap-runtime`.

### Runtime Prerequisite

The Pluxx plugin is a thin operator layer over the CLI.

That means the underlying machine still needs the Pluxx runtime available:

- preferred: local `pluxx`
- fallback: `npx @orchid-labs/pluxx`
- current runtime prerequisite for the npm path: Node 18+ on the machine

If the runtime is missing, do not pretend the host plugin can execute Pluxx by itself. Tell the user what needs to be installed first.
If the user wants the smoother path, help them bootstrap or upgrade the runtime instead of leaving the fallback implicit.

### Operating Rules

- Prefer a deterministic first pass before semantic rewrites.
- When importing, call out auth shape clearly: none, bearer, custom header, or platform-managed runtime auth.
- When refining a scaffold, preserve mixed-ownership boundaries and custom-note blocks.
- Do not silently rewrite auth wiring, target configuration, or generated platform outputs unless the user explicitly asks.
- Before shipping, run `pluxx doctor`, `pluxx lint`, and `pluxx test`.
- Before claiming a workflow is really healthy, prefer `pluxx test --install --trust --behavioral` when the plugin defines meaningful example queries.
- Before telling the user a local install is healthy, prefer `pluxx verify-install`.
- When the user asks about “core four support,” prefer `pluxx-translate-hosts` over vague compatibility claims.
- When the user is preparing to share or launch the plugin, prefer `pluxx-proof-pack`.
- Findings come before summaries when the user asks for a review.

### What Good Looks Like

A good Pluxx result should leave the user with:

- a valid `pluxx.config.ts`
- a useful `INSTRUCTIONS.md`
- product-shaped `skills/*/SKILL.md`
- passing `doctor`, `lint`, and `test`
- generated target bundles under `dist/`
- verified installed host state when local install was requested
- behavioral proof when the workflow nuance warranted it
- release-ready artifacts when the user asked to publish

### Notes

- `pluxx autopilot` is the one-shot path.
- `pluxx init` plus manual refinement is usually the easier path to inspect and debug.
- `pluxx migrate` is the bridge when the user already invested heavily in one host.
- `pluxx verify-install` is the install-state proof after local install.
- `pluxx publish` is the packaging and release path after the scaffold is healthy.
- For OAuth-first MCPs, import auth and runtime auth may differ. Do not assume a bearer import token is the correct long-term runtime auth shape.
