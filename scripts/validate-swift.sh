#!/usr/bin/env bash
set -euo pipefail

archive_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
package_root="${OMEN_ARCHIVE_KIT_ROOT:-${archive_root}/../OmenArchiveKit}"
omen_core_root="${OMEN_CORE_ROOT:-${package_root}/../OmenCore}"

if [[ ! -f "${package_root}/Package.swift" ]]; then
  echo "Swift archive validator unavailable at ${package_root}; Ruby validation remains authoritative."
  exit 0
fi

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Swift archive validator found, but this host is not macOS; skipping by policy (Linux verification is deferred)."
  exit 0
fi

if [[ ! -d "${omen_core_root}" ]]; then
  echo "Swift archive validator found at ${package_root}, but its local OmenCore dependency is unavailable at ${omen_core_root}; skipping."
  exit 0
fi

package_root="$(cd "${package_root}" && pwd)"
archive_root="$(cd "${archive_root}" && pwd)"

echo "Validating ${archive_root} with OmenArchiveKit at ${package_root}."
exec swift run --package-path "${package_root}" omen-archive validate "${archive_root}"
