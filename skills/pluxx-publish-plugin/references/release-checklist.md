# Release Checklist

## Choose One Release Path

- **Package-only dry run:** prove artifact planning without external mutation.
- **GitHub Release:** create a versioned tag/release and upload archives, installers, manifest, checksums, and approved proof assets.
- **npm:** publish the configured package/version/tag after npm authentication and package inspection.
- **Both:** preview the combined plan and define which failure should stop the second channel.
- **Tag-triggered CI:** push the intended tag and let the repository workflow publish. Do not also run a competing local publish for the same version.

Distinguish local `pluxx publish` from a GitHub Actions workflow triggered by a tag. Inspect the repository workflow before deciding which mechanism owns the release.

## Before Preview

- Confirm `pluxx.config.ts` version and repository metadata.
- Confirm the requested targets exist in `dist/` and were rebuilt from current source.
- Confirm `validate`, `doctor`, `lint`, `skills-ref validate` for every source skill, and `test` results.
- Record whether installed-state or behavioral proof also ran.
- Inspect Git status and intentional generated changes.
- Confirm the version is new, the intended tag does not already exist, and local HEAD is the commit meant to ship.

## Before Upload

- Review the exact dry-run plan.
- Confirm the version and npm dist-tag; the publish flag `--tag` applies only to npm.
- Confirm the GitHub repository and version-derived GitHub release tag, such as `v0.2.1`; do not infer GitHub identity from the npm dist-tag.
- Confirm installers reference the intended release channel.
- Confirm checksums and release manifest cover every uploaded artifact.
- Confirm screenshots and proof notes do not overstate host parity or verification depth.
- Obtain explicit approval for the external publish action.

Required product surfaces are release gates. If a configured companion agent, runtime payload, installer, or promised host workflow is missing or failing, stop the release and repair it. An optional proof layer that was not run may instead limit the release claim, provided the unproven behavior is not presented as verified and no known failure is being hidden.

A known intermittent failure in a genuinely optional, non-promised smoke case does not automatically block artifact publication, but it requires an explicit release-owner decision, scoped disclosure, and removal of any proof claim it undermines. Never turn a known failure into “not run” by omitting the case from the report.

The publish preflight should account for artifact existence, Git cleanliness, npm authentication when used, GitHub authentication when used, and repository identity. `--allow-dirty` is acceptable for an intentional dry-run or controlled CI context, not as a way to conceal unknown changes.

## Artifact Inventory

Confirm the dry-run accounts for every intended target archive plus:

- platform installer scripts or entrypoints
- release manifest and target/version metadata
- checksums covering every uploaded artifact
- npm package contents when npm is selected
- optional screenshots or proof notes that correspond to completed evidence
- install URLs that match the chosen release channel

## After Upload

- Verify the release/tag through the public API or release URL and compare the asset list to the reviewed plan.
- Fetch or inspect one public installer path without executing it when possible.
- Confirm published checksums match the uploaded bytes or the release manifest's expected hashes.
- Report host reload/restart requirements and hook trust.
- Distinguish published source, published artifacts, and actual installation proof.

## Recovery

| Failure | Safe response |
| --- | --- |
| GitHub or npm auth is invalid | Stop before upload, repair the named account/session, rerun the dry-run and preflight. |
| Working tree is unexpectedly dirty | Identify the files and decide whether they belong in the release; do not hide them with `--allow-dirty`. |
| Version or tag already exists | Stop and choose an intentional new version or documented recovery; do not silently overwrite release history. |
| Tag-triggered workflow fails | Inspect the failed job and existing tag/release state before retrying. |
| Only some assets upload | Inventory public state, preserve evidence, and choose an explicit repair; do not claim release completion. |
| Public installer or checksum fails | Treat the release as incomplete and correct the artifact path or release contents with a documented action. |

Never unpublish, delete a tag, replace public assets, or republish a version without explicit approval and an understood recovery plan.

## Release Report

Return the release owner (local CLI or CI), version/tag, shipping commit, proof depth, exact reviewed action, artifact inventory, public verification results, and any partial-state or reload caveat.
