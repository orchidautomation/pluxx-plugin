# Pluxx

Use Pluxx to maintain one plugin source project and compile honest native bundles for Claude Code, Cursor, Codex, and OpenCode.

The plugin is an operator layer over the `@orchid-labs/pluxx` CLI. It does not replace the CLI runtime.

## Route By User Job

| User intent | Skill | Explicit command where supported |
| --- | --- | --- |
| Choose a command, install or upgrade Pluxx, or troubleshoot an unclear failure | `pluxx-guide` | Use the skill directly |
| Create from an MCP, blank source, or existing host plugin | `pluxx-create-plugin` | `/pluxx:create-plugin` |
| Improve context, taxonomy, instructions, examples, or scaffold quality | `pluxx-refine-plugin` | `/pluxx:refine-plugin` |
| Refresh an MCP-derived project after upstream changes | `pluxx-maintain-plugin` | `/pluxx:maintain-plugin` |
| Validate, build, install, verify, debug, or behaviorally prove | `pluxx-verify-plugin` | `/pluxx:verify-plugin` |
| Audit preserve, translate, degrade, and drop behavior | `pluxx-translate-hosts` | `/pluxx:translate-hosts` |
| Package, preview, or publish a release | `pluxx-publish-plugin` | `/pluxx:publish-plugin` |

In Codex, use `@pluxx` and select the matching skill. Codex reserves `/` for native commands, so Pluxx preserves command intent through skills, `AGENTS.md`, and generated command metadata.

## Resolve The CLI

Treat `pluxx ...` as the logical command.

1. Use `pluxx` on `PATH` when present.
2. Fall back to `npx @orchid-labs/pluxx`.
3. Check the global version with `pluxx --version`.
4. Compare against `npm view @orchid-labs/pluxx version` only when freshness matters.
5. Upgrade a stale global install with `pluxx upgrade`.

The published runtime requires Node 18 or newer.

## Core Decision Tree

### Create

- Raw remote or stdio MCP: `pluxx init --from-mcp <source> --yes`
- MCP already configured in a host: `pluxx discover-mcp`, then `pluxx init --from-installed-mcp <host:name> --yes`
- Existing Claude Code, Cursor, Codex, or OpenCode plugin: `pluxx migrate <path>`
- Blank source project: run `pluxx init <name>` in an interactive terminal; plain init rejects non-interactive execution
- One-shot path: `pluxx autopilot --from-mcp <source> --runner <runner> --mode standard --yes`

Prefer discovery over asking a user to reconstruct working host configuration, but treat raw discovery output as sensitive because credential-bearing URL query strings or stdio arguments can still appear. Summarize only the selector, name, host, and transport. For local stdio MCPs, pass the real executable command and verify that project-relative runtime payloads are included through `passthrough`.

### Refine

Use semantic refinement only after deterministic source checks pass.

```bash
pluxx agent prepare --website <url> --docs <url>
pluxx agent run taxonomy --runner codex
pluxx agent run instructions --runner codex
pluxx agent run review --runner codex --no-verify
```

Run only the passes the scaffold needs. Keep skills job-shaped, descriptions intent-first, and shared instructions operational.

### Maintain

Preview an MCP refresh before applying it:

```bash
pluxx sync --dry-run --json
pluxx sync
```

Preserve mixed-ownership Markdown and call out custom notes stranded by removed tools or workflows.

### Verify

Use the proof ladder:

```bash
pluxx validate
pluxx doctor
pluxx lint
pluxx eval
pluxx test --target claude-code cursor codex opencode
```

Add installed-state proof only when requested:

```bash
pluxx test --install --trust --target codex
pluxx verify-install --target codex
```

Add real workflow proof only when needed:

```bash
pluxx test --install --trust --behavioral --target codex
```

When output remains unhealthy, use `pluxx doctor --consumer <path>`. For nondeterministic MCP failures, record with `pluxx mcp proxy --from-mcp <source> --record <tape.json>` and replay with `pluxx mcp proxy --replay <tape.json>`.

Never call a build installed, an install behaviorally proven, or a translated surface fully preserved.

### Translate

Review the compiler buckets that matter: instructions, skills, commands, agents, hooks, permissions, runtime, and distribution. Classify each as preserve, translate, degrade, or drop.

Current important caveats:

- Codex command intent degrades to skills and generated routing surfaces.
- Codex custom agents require install-managed companion registration.
- Hook and permission intent is expressed differently by every host.
- OpenCode uses native code/config-driven surfaces where other hosts may use manifests.

Fix portability issues in the source project, then rebuild. Do not patch `dist/` as the durable solution.

### Publish

Verify first and preview every release:

```bash
pluxx publish --dry-run
pluxx publish --github-release --version <x.y.z>
pluxx publish --npm --version <x.y.z> --tag latest
```

Publishing is an external action. Upload only after explicit approval. Keep release claims limited to the strongest completed proof layer.

## Operating Rules

- Prefer read-only checks or `--dry-run` before writes, installs, and publishes.
- Keep credentials and machine-local runtime configuration out of source and responses.
- Edit source files at the project root; rebuild generated targets through Pluxx.
- Preserve user-authored sections during sync and refinement.
- Review hook commands before passing `--trust`.
- Use the core four by default unless the user requests a narrower target set.
- Findings come before summaries when the user asks for review.

## Good Result

A strong Pluxx result leaves the user with a valid `pluxx.config.ts`, concise workflow skills, useful `INSTRUCTIONS.md`, passing deterministic checks, generated target bundles, honest host caveats, and installed or behavioral proof only when requested and completed.
