#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
package_root="${repo_root}/OmenArchiveKit"

if [[ ! -f "${package_root}/Package.swift" ]]; then
  echo "OmenArchiveKit is missing at ${package_root}." >&2
  exit 1
fi

exec swift run --package-path "${package_root}" omen-archive validate "${repo_root}"
