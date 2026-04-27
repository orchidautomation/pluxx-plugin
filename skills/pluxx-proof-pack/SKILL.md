---
name: pluxx-proof-pack
description: Package install links, screenshots, proof notes, and demo-facing assets around a healthy plugin.
---

# Pluxx Proof Pack

Use this skill when the plugin is working technically and the user now needs a shareable proof surface for other teams.

## Inputs To Clarify

- whether the proof is for docs, a blog post, a launch thread, or direct outreach
- whether direct install links exist already
- whether screenshots or host recordings are already captured
- whether the audience is technical, GTM, or executive

## Workflow

1. Start with `proof-publisher` when the host supports specialist agents.
2. Confirm the plugin is actually healthy enough to package:
   - `pluxx doctor`
   - `pluxx lint`
   - `pluxx test`
3. Identify the public proof assets:
   - install links
   - screenshots
   - proof note
   - docs/example page
   - blog/demo page
4. If release artifacts matter, involve `release-operator`.
5. Summarize:
   - what is already ready to share
   - what still looks internal or weak
   - what should be tightened before outreach

## Decision Points

- If the plugin is still failing behavioral proof, do not package it as a success story yet.
- If install friction is still high, prioritize direct install links before polishing narrative.
- If the repo has no tagged release yet, prefer raw `main` installer links instead of dead `releases/latest/download/...` links.
- If the user is reaching out to a real team, tailor the proof around the problem Pluxx solves, not internal compiler pride.

## Rules

- Do not package “proof” before the plugin is actually credible.
- Prefer direct install paths over vague repo browsing when sharing externally.
- Keep the proof story aligned with what the plugin really does today.

## What A Good Proof Pack Usually Includes

- direct install paths
- raw-source install paths when the repo is pushed but not released yet
- one or two clear workflow screenshots
- a proof note with live host coverage
- repo or example source links
- a short explanation of why the plugin matters for the target team

## Output

- Return the shareable proof pack.
- Call out missing screenshots, install links, or behavior proof if relevant.
- Make the next release or outreach step obvious.
