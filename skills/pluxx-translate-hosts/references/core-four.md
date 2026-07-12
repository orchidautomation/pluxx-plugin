# Core-Four Baseline

This is a routing baseline, not a substitute for current build output.

| Bucket | Claude Code | Cursor | Codex | OpenCode |
| --- | --- | --- | --- | --- |
| Instructions | preserve | preserve | preserve | translate |
| Skills | preserve | preserve | preserve | preserve |
| Commands | preserve | preserve | degrade | preserve |
| Agents | preserve | translate | translate | preserve |
| Hooks | preserve | preserve | translate | translate |
| Permissions | translate | translate | translate | preserve |
| Runtime | target-specific | target-specific | target-specific | target-specific |
| Distribution | translate | preserve | preserve | translate |

## Evidence Sequence

1. Inspect the source config, shared instructions, and the bucket-specific source files.
2. Run `pluxx lint` and build only the requested targets.
3. Inspect the native target files that carry the intent; do not infer parity from a successful build alone.
4. Classify the result as preserve, translate, degrade, or drop and cite the inspected surface.
5. If required intent weakens, recommend a source-shape fix and rebuild. Never make the generated target the source of truth.

Typical native evidence includes:

| Host | Inspect for evidence |
| --- | --- |
| Claude Code | plugin manifest, skills, commands, agents, hooks, settings/runtime files |
| Cursor | plugin manifest, rules/instructions, skills, commands, agents, hooks, MCP/runtime configuration |
| Codex | plugin manifest, `AGENTS.md`, skills, generated routing metadata, companion-agent/install guidance |
| OpenCode | plugin/config code, instructions, skills, commands, agents, hooks/runtime registration |

## Important Caveats

- Codex command intent degrades into skills, `AGENTS.md` routing, and generated command metadata because plugin-packaged slash-command parity is not currently documented.
- Codex custom agents require install-managed companion registration outside the plugin bundle.
- Codex permission enforcement lives in approvals, sandboxing, hooks, and active config rather than plugin-local skill frontmatter alone.
- Cursor agent and permission intent spans native agent files, hooks, CLI configuration, and generated notes.
- OpenCode instructions, hooks, and distribution are native but code/config driven rather than manifest-identical to Claude Code.
- Hooks and local runtime commands always require trust review in the host where they will execute.

## Source-Shape Fixes

| Portability problem | Prefer in source |
| --- | --- |
| Command has no faithful Codex slash-command surface | Put the complete user job and trigger in a skill; use shared routing as the entry point. |
| Custom agent is not plugin-native in a target | Keep the reusable procedure in a skill and document or install the companion registration honestly. |
| Hook API differs by host | Express portable policy in instructions, keep execution in a reviewed helper script, and require host trust/configuration. |
| Permission models differ | Declare canonical allow/ask/deny intent, then verify actual enforcement in each host. |
| Runtime depends on source cwd | Use environment references, include required payload through `passthrough`, and anchor installed paths to the plugin root. |
| Distribution layout differs | Generate host-native installers/manifests and document reload or companion steps per host. |

## Classification Language

- **Preserve:** “The source intent appears on a faithful native surface in this target.”
- **Translate:** “The same intent is represented through a different native surface.”
- **Degrade:** “A weaker but usable form remains; these capabilities or ergonomics are missing.”
- **Drop:** “No truthful target representation was generated.”

Report the exact file or manifest field inspected, important lint/build warnings, and whether the classification is current evidence or only this baseline.

## Output Matrix

| Bucket | Claude Code | Cursor | Codex | OpenCode | Evidence/source fix |
| --- | --- | --- | --- | --- | --- |
| relevant bucket | classification | classification | classification | classification | inspected file plus smallest fix |

Include only buckets and targets in scope. A compact evidence-backed matrix is more useful than claiming universal parity.
