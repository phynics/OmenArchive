#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
package_root="${OMEN_ARCHIVE_KIT_ROOT:-${repo_root}/OmenArchiveKit}"

echo "Running Ruby archive validation."
ruby_status=0
ruby "${repo_root}/scripts/validator.rb" || ruby_status=$?

if [[ ! -f "${package_root}/Package.swift" ]]; then
    echo "Swift shadow validation skipped: OmenArchiveKit is unavailable at ${package_root}."
    exit "${ruby_status}"
fi

package_root="$(cd "${package_root}" && pwd)"
echo "Running Swift archive validation from ${package_root}."
swift_status=0
swift run --package-path "${package_root}" omen-archive validate "${repo_root}" || swift_status=$?

if [[ "${ruby_status}" -ne 0 || "${swift_status}" -ne 0 ]]; then
    echo "One or more independent validators failed: Ruby=${ruby_status}, Swift=${swift_status}." >&2
    echo "Their diagnostics are intentionally not treated as structurally equivalent." >&2
    exit 1
fi

echo "Both independent validators accepted the archive."
