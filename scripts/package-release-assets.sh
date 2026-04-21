#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-}"

if [[ -z "$VERSION" ]]; then
  echo "Usage: $0 <version-or-tag>" >&2
  exit 1
fi

mkdir -p release
rm -f release/*

cp scripts/install-claude-code.sh release/install-claude-code.sh
cp scripts/install-cursor.sh release/install-cursor.sh
cp scripts/install-codex.sh release/install-codex.sh
cp scripts/install-opencode.sh release/install-opencode.sh
cp scripts/install-all.sh release/install-all.sh
chmod +x release/install-claude-code.sh
chmod +x release/install-cursor.sh release/install-codex.sh release/install-opencode.sh release/install-all.sh

for platform in claude-code cursor codex opencode; do
  if [[ ! -d "dist/$platform" ]]; then
    echo "Missing built platform bundle: dist/$platform" >&2
    exit 1
  fi

  tar -czf "release/pluxx-plugin-${platform}-${VERSION}.tar.gz" -C dist "$platform"
  tar -czf "release/pluxx-plugin-${platform}-latest.tar.gz" -C dist "$platform"
done

shasum -a 256 release/*.tar.gz > release/SHA256SUMS.txt
