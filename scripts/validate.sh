#!/usr/bin/env bash
set -euo pipefail

archive_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
package_root="${OMEN_ARCHIVE_KIT_ROOT:-${archive_root}/../OmenArchiveKit}"

if [[ ! -f "${package_root}/Package.swift" ]]; then
  echo "OmenArchiveKit not found at ${package_root}." >&2
  echo "Set OMEN_ARCHIVE_KIT_ROOT to an OmenArchiveKit checkout, or clone" >&2
  echo "https://github.com/phynics/OmenArchiveKit next to this repository." >&2
  exit 1
fi

package_root="$(cd "${package_root}" && pwd)"

echo "Validating ${archive_root} with OmenArchiveKit at ${package_root}."
exec swift run --package-path "${package_root}" omen-archive validate "${archive_root}"
