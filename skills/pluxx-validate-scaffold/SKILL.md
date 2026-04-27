---
name: pluxx-validate-scaffold
description: Run doctor, lint, eval, and test on a Pluxx scaffold.
---

# Pluxx Validate Scaffold

Use this skill when the user wants to know whether the current Pluxx project is actually healthy enough to trust.

## Inputs To Clarify

- whether the user wants source-project truth or installed-host truth
- whether they care about one host or the full core four
- whether the scaffold was imported, migrated, or edited manually since the last good run
- whether auth or runtime setup is expected to be present locally

## Workflow

1. Run the source-project checks:
   - `pluxx doctor`
   - `pluxx lint`
   - `pluxx eval`
2. Run the end-to-end verification pass:
   - `pluxx test`
3. If the user asks for a narrower target subset, scope `test` accordingly.

## Decision Points

- If the project is failing structurally, stop on `doctor` / `lint` findings before recommending semantic rewrites.
- If the project passes structurally but feels weak, call out `eval` findings separately from hard failures.
- If the user really means “is the installed plugin healthy,” route next to `pluxx-verify-install` or `pluxx-behavioral-proof`.

## Rules

- Findings come before reassurance.
- Separate structural issues from quality issues.
- Use `eval` to talk about scaffold quality, not just whether the files exist.
- If everything passes, say so directly and note any remaining soft risks.

## Failure Modes To Call Out

- broken source paths in `pluxx.config.ts`
- missing runtime requirements such as Node or host CLIs
- target-specific generator failures
- passing source checks but weak installed behavior
- auth-dependent tests that need local environment variables

## Output

- Return the important errors, warnings, and quality findings.
- Make the next recommended action obvious:
  - refine
  - build
  - install
  - or ship
