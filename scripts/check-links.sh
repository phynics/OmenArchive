#!/usr/bin/env bash
set -euo pipefail

archive_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if command -v node >/dev/null 2>&1; then
  exec node "${archive_root}/scripts/check-links.mjs"
else
  echo "Error: Node.js is required to run the documentation link checker." >&2
  exit 1
fi
