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

1. discover an already-installed MCP when the user has configured it in Claude Code, Cursor, Codex, or OpenCode
2. import an MCP into a deterministic scaffold
3. migrate an existing single-host plugin when needed
4. refine the scaffold until it reads like a real product instead of raw MCP glue
5. prove the scaffold structurally and behaviorally across the hosts that matter
6. optionally sync later after the MCP changes
7. bootstrap or upgrade the Pluxx runtime when the machine is stale or missing it
8. publish when the plugin is actually ready to distribute

For local stdio MCPs, treat runtime bundling and install-time config as
first-class concerns:

- if the MCP command points at project-relative runtime files such as
  `./build/index.js`, make sure those runtime folders are bundled into the
  generated plugin source
- current Pluxx imports auto-infer `passthrough` for these local stdio runtimes,
  but the operator should still verify that result instead of assuming it
- if the generated plugin seems to keep only skills plus `check-env.sh`, the MCP
  may still be present but the install-time config may not have materialized yet
- `pluxx doctor --consumer <installed-path>` is the right next step when the
  installed host state feels incomplete

For already-installed MCPs, prefer the discovery path before asking the user to
reconstruct a URL, stdio command, env vars, or host config from memory:

- run `pluxx discover-mcp` to list MCP servers already configured in Claude
  Code, Cursor, Codex, and OpenCode
- if the user knows the host, narrow it with `pluxx discover-mcp --host codex`
  or `pluxx discover-mcp --host cursor opencode`
- import with `pluxx init --from-installed-mcp <host:name> --yes`
- use the host-qualified selector when names overlap, for example
  `codex:prospeo` or `opencode:exa`
- treat discovery warnings about redacted literal secrets as expected safety
  behavior; ask for env var names, not raw secret values

### Main Workflows

- `pluxx-import-mcp`
  Use when the user wants to scaffold a plugin from an already-installed MCP, a remote MCP URL, or a local stdio MCP command.

- `pluxx-migrate-plugin`
  Use when the user already has a Claude Code, Cursor, Codex, or OpenCode plugin and wants to bring it into Pluxx.

- `pluxx-bootstrap-runtime`
  Use when the machine is missing `pluxx`, is stale, or the user wants a smoother operator path than ad hoc `npx` usage.

- `pluxx-refine-plugin`
  Use when the first scaffold exists, but it still needs context prep, workflow shaping, better instructions, translation honesty, or findings-first review.

- `pluxx-prove-plugin`
  Use when the user wants to validate, build, install, verify, and behaviorally prove the scaffold instead of stopping at source-level confidence.

- `pluxx-sync-mcp`
  Use when an existing MCP-derived scaffold needs to be refreshed safely.

- `pluxx-autopilot`
  Use when the user wants the one-shot import, refine, and verification path.

- `pluxx-publish-plugin`
  Use when the user wants to package the current plugin for release distribution, install links, screenshots, and shareable proof assets.

### Explicit Commands

- `/pluxx:import-mcp`
  Explicit entrypoint for turning an installed MCP, MCP URL, or stdio command into a first-pass Pluxx scaffold.

- `/pluxx:migrate-plugin`
  Explicit entrypoint for bringing an existing host-native plugin into a maintained Pluxx source project.

- `/pluxx:bootstrap-runtime`
  Explicit entrypoint for installing, upgrading, or checking the Pluxx CLI runtime.

- `/pluxx:refine-plugin`
  Explicit entrypoint for taking a structurally valid scaffold and making it read and translate like a serious product.

- `/pluxx:prove-plugin`
  Explicit entrypoint for turning source confidence into install, verify, and behavioral proof across the hosts that matter.

- `/pluxx:sync-mcp`
  Explicit entrypoint for refreshing an existing scaffold from its MCP source.

- `/pluxx:autopilot`
  Explicit entrypoint for the one-shot import, refine, and verification path.

- `/pluxx:publish-plugin`
  Explicit entrypoint for packaging the current plugin for release distribution and shareable proof assets.

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
- When importing and the user mentions an MCP already working in Claude Code,
  Cursor, Codex, or OpenCode, run discovery first instead of asking them to
  manually re-enter host config.
- When importing, call out auth shape clearly: none, bearer, custom header, or platform-managed runtime auth.
- When refining a scaffold, preserve mixed-ownership boundaries and custom-note blocks.
- Do not silently rewrite auth wiring, target configuration, or generated platform outputs unless the user explicitly asks.
- Before shipping, run `pluxx doctor`, `pluxx lint`, and `pluxx test`.
- Before claiming a workflow is really healthy, prefer the `pluxx-prove-plugin` path rather than isolated structural checks.
- Before telling the user a local install is healthy, prefer `pluxx verify-install` and `pluxx doctor --consumer` inside the proof path.
- When a local stdio import feels like “skills only” after install, check two
  things before concluding the MCP was lost:
  - whether project-relative runtime folders were bundled through `passthrough`
  - whether required install-time config materialized into `.pluxx-user.json`
- When the user asks about “core four support,” handle that inside `pluxx-refine-plugin` instead of vague compatibility claims.
- When the user is preparing to share or launch the plugin, handle proof-packaging inside `pluxx-publish-plugin`.
- When the user asks for curl install links, distinguish between:
  - raw `main` installer links under `release/` that work immediately after push
  - `releases/latest/download/...` links that only work after a tagged GitHub release exists
- Findings come before summaries when the user asks for a review.

### What Good Looks Like

A good Pluxx result should leave the user with:

- a valid `pluxx.config.ts`
- a useful `INSTRUCTIONS.md`
- a small set of product-shaped public workflows rather than a command-per-step maze
- passing `doctor`, `lint`, and `test`
- generated target bundles under `dist/`
- verified installed host state when local install was requested
- behavioral proof when the workflow nuance warranted it
- release-ready artifacts when the user asked to publish

### Notes

- `pluxx autopilot` is the one-shot path.
- `pluxx init` plus manual refinement is usually the easier path to inspect and debug.
- `pluxx migrate` is the bridge when the user already invested heavily in one host.
- `pluxx refine` is not a real CLI command; the plugin-level refinement journey composes context prep, taxonomy shaping, instruction rewriting, translation review, and scaffold review.
- `pluxx prove` is not a real CLI command; the plugin-level proof journey composes validate, build, install, verify-install, consumer diagnosis, and behavioral proof.
- `pluxx publish` is the packaging and release path after the scaffold is healthy.
- For OAuth-first MCPs, import auth and runtime auth may differ. Do not assume a bearer import token is the correct long-term runtime auth shape.
