#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
hook_path="$(git -C "$repo_root" rev-parse --git-path hooks/pre-commit)"

mkdir -p "$(dirname "$hook_path")"

cat >"$hook_path" <<EOF
#!/usr/bin/env bash
set -euo pipefail

"$repo_root/scripts/validate.sh"
EOF

chmod +x "$hook_path"
echo "Installed pre-commit hook at $hook_path"
