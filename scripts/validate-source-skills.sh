#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/pluxx-version.sh"

for skill_dir in skills/*; do
  [[ -d "$skill_dir" ]] || continue
  npx --yes "skills-ref@${SKILLS_REF_VERSION}" validate "$skill_dir"
done
