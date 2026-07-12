# Runtime Troubleshooting

Use this reference to identify which Pluxx runtime is actually executing before diagnosing a plugin project.

## Resolution Order

1. Check a global executable with `command -v pluxx` and `pluxx --version`.
2. Check the published version with `npm view @orchid-labs/pluxx version` when freshness matters.
3. Use `npx @orchid-labs/pluxx --version` when the global executable is absent or suspect.
4. Treat a source checkout as a separate development lane. A globally installed binary, an `npx` invocation, and a local repository command do not update one another.

## Diagnosis Matrix

| Symptom | Check | Smallest next step |
| --- | --- | --- |
| `pluxx` is not found | `command -v pluxx` | Use `npx @orchid-labs/pluxx` or install the package intentionally. |
| Global version is behind npm | Compare both version commands | Run `pluxx upgrade`, then confirm the resolved executable and version again. |
| Upgrade succeeds but the old version remains | `command -v -a pluxx` and inspect the active Node/npm prefix | Fix PATH or remove the stale duplicate intentionally; do not assume the first installation changed. |
| `npx` works but global Pluxx fails | Compare executable paths and versions | Continue with `npx` for the task or repair the global installation as a separate step. |
| Runtime works but the next command is unclear | `pluxx help` | Choose the user job from the command map before adding flags. |
| A project command fails | Capture command, cwd, version, and first actionable error | Route to `pluxx-verify-plugin` and identify the failed proof layer. |

## Current Help Caveat

For Pluxx `0.1.31`, prefer top-level `pluxx help` and maintained documentation for orientation. Some command-specific `--help` paths can enter normal command behavior. Do not probe a write-capable command in a real project merely to discover flags; use documentation, a disposable directory, or the command's supported `--dry-run` mode.

## Safety

- State whether the proposed command reads, writes, installs, or publishes.
- Do not combine runtime repair with project mutation until the resolved binary is known.
- Never paste tokens, credential-bearing discovery output, npm configuration, or local auth files into chat or source control.
- After an upgrade, report both the executable path and confirmed version. “Upgrade completed” is not proof that the intended binary now runs.

## Runtime Report

Return:

- resolved executable or `npx` fallback
- installed and published versions when checked
- whether multiple installations may be competing
- recommended next command and its side-effect class
- the plugin proof layer to inspect next, if the runtime itself is healthy
