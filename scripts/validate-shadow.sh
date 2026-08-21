#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
package_root="${OMEN_ARCHIVE_KIT_ROOT:-${repo_root}/../OmenArchiveKit}"
omen_core_root="${OMEN_CORE_ROOT:-${package_root}/../OmenCore}"

echo "Running Ruby archive validation."
ruby_status=0
"${repo_root}/scripts/validate.sh" || ruby_status=$?

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "Swift shadow validation skipped by policy on this host (Linux verification is deferred)."
    exit "${ruby_status}"
fi

if [[ ! -f "${package_root}/Package.swift" ]]; then
    echo "Swift shadow validation skipped: OmenArchiveKit is unavailable at ${package_root}."
    exit "${ruby_status}"
fi

if [[ ! -d "${omen_core_root}" ]]; then
    echo "Swift shadow validation skipped: OmenCore is unavailable at ${omen_core_root}."
    exit "${ruby_status}"
fi

package_root="$(cd "${package_root}" && pwd)"
echo "Running Swift archive validation from ${package_root}."
swift_status=0
swift run --package-path "${package_root}" omen-archive validate "${repo_root}" || swift_status=$?

if [[ "${ruby_status}" -ne "${swift_status}" ]]; then
    echo "Ruby/Swift archive validation mismatch: Ruby=${ruby_status}, Swift=${swift_status}." >&2
    exit 1
fi

if [[ "${ruby_status}" -ne 0 ]]; then
    echo "Ruby and Swift archive validation failed with matching status ${ruby_status}." >&2
    exit "${ruby_status}"
fi

echo "Ruby and Swift archive validation outcomes match."
