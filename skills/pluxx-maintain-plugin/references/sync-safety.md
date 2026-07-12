# Sync Safety

`pluxx sync` reconciles an MCP-derived scaffold with its canonical source. Treat its dry-run as a change plan, not ceremonial output.

## Preconditions

- `.pluxx/mcp.json` exists, parses, and identifies the intended source.
- The working tree is clean or the sync is isolated from unrelated edits.
- Any `--from-mcp <source>` override is intentional and recorded.
- The current taxonomy and custom sections are understood before upstream tools disappear or rename.

If metadata is missing or corrupt, do not reconstruct it from memory while applying a sync. Restore the tracked metadata from version control or rerun the appropriate creation/import flow, then preview again.

## Interpret The Preview

| Category | Meaning | Required review |
| --- | --- | --- |
| added | New managed source surface | Confirm its user job and whether taxonomy should absorb it. |
| updated | Existing managed content changed | Inspect the diff and custom boundaries. |
| removed | Upstream surface no longer exists | Check for stranded workflows, links, and user notes. |
| preserved | Pluxx retained meaningful custom content | Decide whether to keep, relocate, or retire it explicitly. |
| renamed | Upstream identity changed and content was transferred | Confirm the match is semantically correct and links still resolve. |
| warning | Pluxx could not make a fully safe deterministic choice | Do not apply while deletion, rename, ownership, source identity, or runtime behavior remains ambiguous. Explicitly resolve or accept only informational warnings with a recorded rationale and rollback path. |

A dry-run executes reconciliation against a temporary copy. Its report predicts file effects without applying them to the working project.

## Ownership Behavior

- Meaningful custom content can cause a removed managed file to be preserved instead of deleted.
- Rename handling can transfer custom content to the renamed surface; inspect the result rather than assuming name similarity proves semantic equivalence.
- The operator owns the decision for custom notes: keep them on a still-valid workflow, relocate them to the correct renamed/current workflow, or retire them explicitly. Resolve duplication, partial transfer, and conflicting notes before applying a shipping decision.
- `.pluxx/taxonomy.json` persists workflow grouping decisions across syncs.
- When the scaffold changes, saved agent prompt-pack outputs can become stale or invalidated. Regenerate only the affected refinement inputs after reviewing the deterministic sync.
- Use version control for rollback. Do not manually reverse a partially understood sync inside generated `dist/` output.

## Runtime Changes

A changed stdio command, package binary, runtime directory, project-relative argument, environment contract, or passthrough payload changes installed behavior even if source validation passes. Rebuild and inspect every configured generated target. After each approved host install/update in scope, run `pluxx verify-install --target <host>`. If output is still incoherent, run `pluxx doctor --consumer <built-or-installed-path>`.

## Follow-Up Routing

- New or renamed tools change user-job grouping: route to refinement.
- Source structure, build, or consumer output fails: route to verification.
- Installed host still points at an old bundle or runtime: verify installed state and apply the reported repair.
- Only deterministic managed content changed and all checks pass: report the sync without inventing a semantic rewrite.

## Sync Report

Record the source identity, whether it was overridden, exact preview category counts, preserved or transferred custom content and its decision owner, warnings, taxonomy/agent-pack invalidation, validation results, target hosts, and the smallest remaining refinement or install-proof step.
