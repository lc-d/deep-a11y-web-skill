#!/bin/bash
# Orchestrates a full accessibility audit: runs Lighthouse + axe-core against one page, then
# reports the results.
#
# Usage:
#   audit.sh <url> [--viewport desktop|mobile] [--out-dir DIR]
#
# stdout = summary JSON. Full report lands in --out-dir for follow-up reading.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

command -v jq >/dev/null 2>&1 || { echo '{"success":false,"error":{"type":"missing_dependency","message":"jq is required"}}'; exit 1; }
command -v node >/dev/null 2>&1 || { echo '{"success":false,"error":{"type":"missing_dependency","message":"Node.js 20+ is required"}}'; exit 1; }

NODE_MAJOR=$(node -e "console.log(process.versions.node.split('.')[0])")
if [ "$NODE_MAJOR" -lt 20 ]; then
  echo "{\"success\":false,\"error\":{\"type\":\"unsupported_runtime\",\"message\":\"Node ${NODE_MAJOR} detected; this skill requires Node 20+\",\"suggestion\":\"Install/switch to Node 20+, e.g.: nvm install 20 && nvm use 20\"}}"
  exit 1
fi

URL=""
OUT_DIR=""
VIEWPORT="desktop"

while [ $# -gt 0 ]; do
  case "$1" in
    --out-dir) OUT_DIR="$2"; shift 2 ;;
    --viewport) VIEWPORT="$2"; shift 2 ;;
    *) URL="$1"; shift ;;
  esac
done

[ -n "$URL" ] || { echo '{"success":false,"error":{"type":"invalid_input","message":"Usage: audit.sh <url> [--viewport desktop|mobile] [--out-dir DIR]"}}'; exit 1; }
case "$VIEWPORT" in
  desktop) AXE_VIEWPORT="1280x800" ;;
  mobile) AXE_VIEWPORT="320x640" ;;
  *) echo '{"success":false,"error":{"type":"invalid_input","message":"--viewport must be desktop or mobile"}}'; exit 1 ;;
esac
[ -n "$OUT_DIR" ] || OUT_DIR="./a11y-audit-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUT_DIR"

if [ ! -d "$SCRIPT_DIR/node_modules" ]; then
  echo "Installing axe-core runner dependencies (first run only)..." >&2
  npm install --prefix "$SCRIPT_DIR" --no-audit --no-fund >&2
fi

SLUG=$(echo "$URL" | sed -E 's#^https?://##; s#[^a-zA-Z0-9]+#-#g; s#^-|-$##g')
[ -n "$SLUG" ] || SLUG="page"

LH_FILE="$OUT_DIR/${SLUG}.${VIEWPORT}.lighthouse.json"
AXE_FILE="$OUT_DIR/${SLUG}.${VIEWPORT}.axe.json"

LH_RESULT=$(LH_VIEWPORT="$VIEWPORT" "$SCRIPT_DIR/run-lighthouse.sh" "$URL" || echo '{"success":false}')
echo "$LH_RESULT" > "$LH_FILE"

AXE_RESULT=$(node "$SCRIPT_DIR/run-axe.mjs" "$URL" --viewport "$AXE_VIEWPORT" || echo '{"success":false}')
echo "$AXE_RESULT" > "$AXE_FILE"

SUMMARY=$(jq -n --arg url "$URL" --arg viewport "$VIEWPORT" --argjson lh "$LH_RESULT" --argjson axe "$AXE_RESULT" '
  {
    success: true,
    url: $url,
    viewport: $viewport,
    lighthouseScore: ($lh.score // null),
    axeViolations: ($axe.counts.violations // null),
    failed: (($lh.success // false) == false and ($axe.success // false) == false),
    topAxeRules: (
      [$axe.violations[]? | {rule: .id, impact: .impact, nodes: .nodeCount}]
      | sort_by(-.nodes)
      | .[0:10]
    ),
    topLighthouseAudits: (
      [$lh.failingAudits[]? | {audit: .id, nodes: (.items | length)}]
      | sort_by(-.nodes)
      | .[0:10]
    )
  }
')

echo "$SUMMARY" > "$OUT_DIR/${SLUG}.${VIEWPORT}.summary.json"
echo "Full report written to $OUT_DIR (${SLUG}.${VIEWPORT}.lighthouse.json / ${SLUG}.${VIEWPORT}.axe.json, plus ${SLUG}.${VIEWPORT}.summary.json)" >&2
echo "$SUMMARY"
