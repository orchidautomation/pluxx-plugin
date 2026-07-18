#!/usr/bin/env bash
set -euo pipefail

for skill_dir in skills/*; do
  [[ -d "$skill_dir" ]] || continue
  npx --yes skills-ref validate "$skill_dir"
done
