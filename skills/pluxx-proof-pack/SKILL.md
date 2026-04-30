---
name: pluxx-proof-pack
description: Package install links, screenshots, behavioral proof, and release notes for sharing a Pluxx plugin.
---

# Proof Pack

Use this skill when the user wants to share, launch, or hand off a plugin after it is technically healthy.

This workflow turns local proof into an understandable install and demo surface.

The matching command carries the argument UX:

- `/pluxx:proof-pack [release-scope optional]`

## Inputs To Clarify

- whether the user wants raw `main` install links, GitHub release links, or both
- whether the plugin already passed structural, install, and behavioral proof
- which hosts should be presented publicly
- whether screenshots, demo prompts, or proof notes need to be updated
- whether a tag or release has already been cut

## Workflow

1. Check proof status:
   - `pluxx doctor`
   - `pluxx lint`
   - `pluxx test --install --trust --behavioral --target <platforms...>`
2. If proof is incomplete, route to `pluxx-behavioral-proof` or `pluxx-prove-plugin` before packaging.
3. Build the public install surface:
   - current-main curl links for source-first installs
   - latest-release curl links for stable release installs
   - host-specific reload/restart notes
   - trust notes for hooks
4. Package evidence:
   - what source project was built
   - what targets passed
   - what behavioral smoke cases proved
   - what warnings are expected host translation caveats
5. If the user is publishing, route through:
   - `pluxx publish`
   - or `pluxx publish --github-release` when release assets should be attached

## Public Proof Standards

- Make hook trust explicit when installers run local hooks.
- Distinguish raw `main` installers from `releases/latest/download/...` installers.
- Say which version of the Pluxx CLI was used.
- Show the exact behavioral command when claiming real behavior proof.
- Keep host caveats honest rather than hiding them behind green checks.

## Rules

- Do not package proof before the plugin has passed the relevant proof lane.
- Do not imply `latest` release links work before a tag/release exists.
- Do not publish generated bundles by hand when `pluxx publish` can produce the release artifacts.
- Keep install instructions short enough for a first-time user to follow.

## Output

- install links by host
- proof summary by layer
- screenshots or assets that need updating
- release blockers, if any
