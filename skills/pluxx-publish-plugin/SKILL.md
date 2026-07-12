---
name: pluxx-publish-plugin
description: Use this skill when a user wants to package, preview, or publish a Pluxx release, including GitHub Releases, npm, installers, checksums, screenshots, proof notes, or install links. Require verification and explicit approval before upload.
---

# Publish A Pluxx Plugin

Turn verified source into honest, reproducible release artifacts.

## Workflow

1. Confirm the requested path: dry-run, GitHub Release, npm, or both.
2. Read [references/release-checklist.md](references/release-checklist.md) before any real publish or when public proof claims are part of the release.
3. Use `release-operator` for the release path or `proof-publisher` for public proof assets when the host supports specialists.
4. Verify the project with `pluxx doctor`, `pluxx lint`, and `pluxx test`.
5. Confirm the working tree, version, tag, repository, generated targets, and strongest completed proof layer.
6. Preview first:
   - `pluxx publish --dry-run`
   - add `--github-release`, `--npm`, `--version <x.y.z>`, or `--tag <name>` to match the intended path
   - use `--allow-dirty` only for an intentional local or CI plan, never to hide unknown changes
7. Package proof assets only from completed evidence: install links, screenshots, behavior notes, reload instructions, and host caveats.
8. Upload only after explicit approval. Run the exact reviewed publish command.
9. Report bundles, installers, checksums, manifest, tags, URLs, and any remaining distribution caveats.

## Release Truth

- Raw `main` installer links work after the installer files are pushed.
- `releases/latest/download/...` works only after a tagged GitHub release exists.
- A release must not claim behavioral proof when only source or build checks ran.
- Expected host translations belong in release notes when they affect user expectations.
- Publishing is an external side effect; never infer approval from a request to review or prepare artifacts.

## Output

Return the release mode, version, verification evidence, exact publish action, generated artifacts, public install paths, and blockers or follow-up.
