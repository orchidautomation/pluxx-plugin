# Release Checklist

## Before Preview

- Confirm `pluxx.config.ts` version and repository metadata.
- Confirm the requested targets exist in `dist/` and were rebuilt from current source.
- Confirm `doctor`, `lint`, and `test` results.
- Record whether installed-state or behavioral proof also ran.
- Inspect Git status and intentional generated changes.

## Before Upload

- Review the exact dry-run plan.
- Confirm the version and npm tag.
- Confirm the GitHub repository and release tag.
- Confirm installers reference the intended release channel.
- Confirm checksums and release manifest cover every uploaded artifact.
- Confirm screenshots and proof notes do not overstate host parity or verification depth.
- Obtain explicit approval for the external publish action.

## After Upload

- Verify the release/tag URL and asset list.
- Verify one public installer path without mutating a host when possible.
- Report host reload/restart requirements and hook trust.
- Distinguish published source, published artifacts, and actual installation proof.
