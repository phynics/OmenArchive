#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARCHIVE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

OUTPUT_DIR="${1:-$ARCHIVE_ROOT/dist/docs}"
HOSTING_BASE_PATH="${2:-}"

echo "Building DocC documentation catalog..."
mkdir -p "$OUTPUT_DIR"

DOCC_ARGS=(
  convert "$ARCHIVE_ROOT/docs/mechanics.docc"
  --fallback-display-name "OmenMechanics"
  --fallback-bundle-identifier "me.atkn.omen.mechanics"
  --output-path "$OUTPUT_DIR"
  --transform-for-static-hosting
)

if [ -n "$HOSTING_BASE_PATH" ] && [ "$HOSTING_BASE_PATH" != "/" ]; then
  DOCC_ARGS+=(--hosting-base-path "$HOSTING_BASE_PATH")
fi

xcrun docc "${DOCC_ARGS[@]}"

# Provide 404 fallback for GitHub Pages SPA client-side routing
cp "$OUTPUT_DIR/index.html" "$OUTPUT_DIR/404.html"

# Redirect root index.html to /documentation/index/ so the root Pages URL opens the catalog
REDIRECT_TARGET="documentation/index/"
cat > "$OUTPUT_DIR/index.html" <<EOF
<!doctype html>
<html lang="en-US">
<head>
  <meta charset="utf-8">
  <title>OmenArchive Mechanics Documentation</title>
  <meta http-equiv="refresh" content="0; url=${REDIRECT_TARGET}">
  <script>window.location.replace("${REDIRECT_TARGET}" + window.location.search + window.location.hash);</script>
</head>
<body>
  <p>Redirecting to <a href="${REDIRECT_TARGET}">OmenArchive Mechanics Documentation</a>...</p>
</body>
</html>
EOF

echo "Documentation successfully built at: $OUTPUT_DIR"
