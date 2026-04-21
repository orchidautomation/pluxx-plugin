#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-}"

if [[ -z "$VERSION" ]]; then
  echo "Usage: $0 <version-or-tag>" >&2
  exit 1
fi

mkdir -p release
rm -f release/*

for platform in claude-code cursor codex opencode; do
  if [[ ! -d "dist/$platform" ]]; then
    echo "Missing built platform bundle: dist/$platform" >&2
    exit 1
  fi

  tar -czf "release/pluxx-plugin-${platform}-${VERSION}.tar.gz" -C dist "$platform"
  tar -czf "release/pluxx-plugin-${platform}-latest.tar.gz" -C dist "$platform"
done

shasum -a 256 release/*.tar.gz > release/SHA256SUMS.txt
