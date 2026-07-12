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

## Important Caveats

- Codex command intent degrades into skills, `AGENTS.md` routing, and generated command metadata because plugin-packaged slash-command parity is not currently documented.
- Codex custom agents require install-managed companion registration outside the plugin bundle.
- Codex permission enforcement lives in approvals, sandboxing, hooks, and active config rather than plugin-local skill frontmatter alone.
- Cursor agent and permission intent spans native agent files, hooks, CLI configuration, and generated notes.
- OpenCode instructions, hooks, and distribution are native but code/config driven rather than manifest-identical to Claude Code.
- Hooks and local runtime commands always require trust review in the host where they will execute.
