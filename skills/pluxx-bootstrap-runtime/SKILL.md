---
name: pluxx-bootstrap-runtime
description: Install, upgrade, or validate the local Pluxx CLI runtime before running deeper workflows.
---

# Bootstrap Runtime

Use this skill when the machine is missing `pluxx`, is on a stale version, or when a user wants the smoothest local operator path instead of relying on `npx` every time.

## Inputs To Clarify

- whether Node/npm is available on the machine
- whether the user wants a global install or a zero-install fallback
- whether a specific Pluxx version matters for the current task
- whether the host plugin is already installed and just missing the underlying runtime
- whether the workflow needs a CLI feature introduced after the installed version, such as `discover-mcp` / `init --from-installed-mcp`

## Workflow

1. Detect the current runtime:
   - `pluxx --version`
   - or `pluxx version --json`
2. If `pluxx` is missing, explain the best install path:
   - `npm install -g @orchid-labs/pluxx@latest`
3. If `pluxx` is present but stale, prefer:
   - `pluxx upgrade`
   - or `pluxx upgrade --version x.y.z`
   - require a new enough version when the user wants installed-MCP discovery
4. Explain when `npx @orchid-labs/pluxx` is the better fallback:
   - ephemeral use
   - no global install desired
   - locked-down machine
5. After bootstrapping, recommend the next sensible workflow:
   - import
   - migrate
   - build/install
   - behavioral proof

## Decision Points

- Prefer `pluxx upgrade` when the CLI already exists and just needs to catch up.
- If `pluxx discover-mcp` or `pluxx init --from-installed-mcp` is unknown, the machine is on an old CLI. Upgrade before continuing the import workflow.
- Prefer `npm install -g @orchid-labs/pluxx@latest` when the user wants a stable operator path they will reuse often.
- Prefer `npx @orchid-labs/pluxx` when the machine is locked down or the user only needs a one-off run.

## Rules

- Do not hide the difference between a global install and an `npx` fallback.
- Prefer `pluxx upgrade` over repeating raw npm commands when the CLI already exists.
- If Node/npm is missing, say that clearly instead of pretending Pluxx can self-install without it.

## Failure Modes To Call Out

- Node missing
- npm missing or broken
- `pluxx` on PATH but stale
- `npx` available but blocked by network or package resolution
- host plugin installed successfully but unable to execute the underlying CLI

## Output

- Say whether `pluxx` is already available.
- Return the exact next command.
- Explain whether global install or `npx` is the better fit.
