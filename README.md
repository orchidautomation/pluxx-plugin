# Pluxx Plugin

Use the Pluxx CLI from Claude Code, Cursor, Codex, or OpenCode without memorizing every authoring, verification, and release command.

Pluxx keeps one maintained plugin source project and compiles native bundles for the core four. This repository is itself a Pluxx source project: edit the root source and rebuild `dist/` with Pluxx.

## Install The Plugin

### Claude Code

```bash
curl -fsSL https://github.com/orchidautomation/pluxx-plugin/releases/latest/download/install-claude-code.sh | bash
```

Run `/reload-plugins` afterward.

### Cursor

```bash
curl -fsSL https://github.com/orchidautomation/pluxx-plugin/releases/latest/download/install-cursor.sh | bash
```

Reload the window or restart Cursor.

### Codex

```bash
curl -fsSL https://github.com/orchidautomation/pluxx-plugin/releases/latest/download/install-codex.sh | bash
```

Use Plugins → Refresh when available, otherwise restart Codex.

### OpenCode

```bash
curl -fsSL https://github.com/orchidautomation/pluxx-plugin/releases/latest/download/install-opencode.sh | bash
```

Reload or restart OpenCode.

## Install The CLI

The plugin operates the CLI; the machine still needs Pluxx.

```bash
npm install -g @orchid-labs/pluxx
pluxx --version
```

Or use the no-install fallback:

```bash
npx @orchid-labs/pluxx --version
```

Upgrade a global install with `pluxx upgrade`. The published CLI supports Node 18 and newer.

Plain `pluxx init <name>` is interactive. Run it in a real terminal; for headless creation, use the explicit MCP import paths with `--yes`.

## Seven Core Workflows

| Workflow | Use it for |
| --- | --- |
| `pluxx-guide` | CLI setup, upgrades, command selection, and broad troubleshooting |
| `pluxx-create-plugin` | MCP import, installed-MCP discovery, blank initialization, migration, and autopilot |
| `pluxx-refine-plugin` | Context preparation, taxonomy, instructions, examples, and scaffold review |
| `pluxx-maintain-plugin` | Safe MCP sync and drift handling while preserving custom work |
| `pluxx-verify-plugin` | Validation, build, install, consumer diagnosis, installed-state, and behavioral proof |
| `pluxx-translate-hosts` | Preserve/translate/degrade/drop truth across the core four |
| `pluxx-publish-plugin` | Dry-run release plans, installers, checksums, proof assets, GitHub Releases, and npm |

In Claude Code, Cursor, and OpenCode, parameterized workflows also compile into explicit commands. In Codex, use `@pluxx` and the matching skill because plugin-packaged slash-command parity is not currently documented.

## Common Requests

Create from an installed MCP:

> Use Pluxx to discover the MCP already configured in Codex, create one core-four source project, and validate the first pass.

Create from a remote MCP:

> Use Pluxx to scaffold https://example.com/mcp. Show me the deterministic result before running semantic refinement.

Refine a generic scaffold:

> Use Pluxx to prepare the product docs, collapse tool-shaped skills into user workflows, rewrite the shared instructions, and re-test the project.

Maintain after an MCP change:

> Preview a Pluxx sync, preserve our custom sections, apply it if safe, and tell me whether taxonomy needs another pass.

Prove installed behavior:

> Use Pluxx to validate, build, install, verify, and behaviorally test this plugin in Codex. Report each proof layer separately.

Audit host translation:

> Compare commands, agents, hooks, and permissions across the core four using preserve, translate, degrade, and drop.

Prepare a release without publishing:

> Dry-run a GitHub release for version 0.2.0, including installers and checksums, but do not upload anything.

## CLI Decision Tree

```text
raw MCP or stdio command
  -> pluxx init --from-mcp <source> --yes

MCP already configured in a host
  -> pluxx discover-mcp
  -> pluxx init --from-installed-mcp <host:name> --yes

existing host-native plugin
  -> pluxx migrate <path>

fast one-shot path
  -> pluxx autopilot --from-mcp <source> --runner codex --mode standard --yes

existing MCP-derived project changed
  -> pluxx sync --dry-run --json
  -> pluxx sync
```

Manual verification path:

```bash
pluxx validate
pluxx doctor
pluxx lint
pluxx eval
pluxx test --target claude-code cursor codex opencode
```

Installed proof adds:

```bash
pluxx test --install --trust --target codex
pluxx verify-install --target codex
```

## Source Layout

```text
pluxx.config.ts       canonical plugin metadata and targets
INSTRUCTIONS.md       shared host guidance
skills/               Agent Skills source, references, and evals
commands/             explicit parameterized entrypoints
agents/               specialist agent definitions
scripts/              runtime and maintainer helpers
assets/               icon and screenshots
.pluxx/               Pluxx behavioral configuration
dist/                 generated host-native bundles
release/              generated release installers and archives
```

Agent Skills follow the open specification: every folder has `SKILL.md`, optional resources live beside it, descriptions carry discovery intent, and eval fixtures live under `evals/`.

## Develop This Plugin

Use a current Pluxx CLI, then run:

```bash
pluxx validate
pluxx lint
pluxx test
pluxx build
```

Validate each source skill with:

```bash
npx --yes skills-ref validate skills/<skill-name>
```

Preview release packaging without uploading:

```bash
pluxx publish --github-release --version 0.2.0 --allow-dirty --dry-run
```

Do not hand-edit `dist/`; it is regenerated from source.

## Migration From The 0.1 Workflow Surface

| Previous workflow | Current workflow |
| --- | --- |
| `pluxx-bootstrap-runtime` | `pluxx-guide` |
| `pluxx-import-mcp`, `pluxx-migrate-plugin`, `pluxx-autopilot` | `pluxx-create-plugin` |
| `pluxx-refine-plugin` | `pluxx-refine-plugin` |
| `pluxx-sync-mcp` | `pluxx-maintain-plugin` |
| `pluxx-prove-plugin`, `pluxx-behavioral-proof` | `pluxx-verify-plugin` |
| `pluxx-translate-hosts` | `pluxx-translate-hosts` |
| `pluxx-proof-pack`, `pluxx-publish-plugin` | `pluxx-publish-plugin` |

The CLI commands remain available. The change is the plugin’s public skill taxonomy: users select a coherent job instead of loading several adjacent micro-skills.

## Links

- [Pluxx source](https://github.com/orchidautomation/pluxx)
- [Pluxx documentation](https://docs.pluxx.dev)
- [Agent Skills specification](https://agentskills.io/specification)
- [Agent Skills creation guidance](https://agentskills.io/skill-creation/best-practices)

## License

MIT
