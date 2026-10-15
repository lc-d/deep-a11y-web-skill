#!/bin/bash
# Runs a Lighthouse accessibility-only audit against a URL and condenses the result to the
# failing audits (id, title, description, and up to a few offending nodes).
#
# Pinned to Lighthouse 12 (supports Node 18.16+, so it runs on this skill's Node 20 baseline);
# unpinned `npx lighthouse` resolves to 13.x, which requires Node 22.19+.
#
# stdout = condensed JSON, stderr = human logs.
set -euo pipefail

MAX_AUDITS=30
MAX_ITEMS_PER_AUDIT=10

fail() {
  local type="$1" msg="$2" suggestion="$3"
  jq -n --arg type "$type" --arg msg "$msg" --arg suggestion "$suggestion" \
    '{success: false, error: {type: $type, message: $msg, suggestion: $suggestion, retryable: false}}'
  exit 1
}

command -v jq >/dev/null 2>&1 || fail "missing_dependency" "jq is required" "Install: brew install jq (or apt-get install jq)"
command -v npx >/dev/null 2>&1 || fail "missing_dependency" "Node.js/npx is required" "Install Node.js 20+: https://nodejs.org"

NODE_MAJOR=$(node -e "console.log(process.versions.node.split('.')[0])")
[ "$NODE_MAJOR" -ge 20 ] || fail "unsupported_runtime" "Node ${NODE_MAJOR} detected; this skill requires Node 20+" "Install/switch to Node 20+, e.g.: nvm install 20 && nvm use 20"

URL="${1:-}"
[ -n "$URL" ] || fail "invalid_input" "No URL provided" "Usage: $0 <url> [output.json]"

OUT_RAW="${2:-}"
CLEANUP_RAW=0
if [ -z "$OUT_RAW" ]; then
  OUT_RAW="$(mktemp -t lighthouse-XXXXXX).json"
  CLEANUP_RAW=1
fi

LH_PKG="lighthouse@12"

LH_VIEWPORT="${LH_VIEWPORT:-desktop}"
if [ "$LH_VIEWPORT" = "mobile" ]; then
  LH_VIEWPORT_FLAGS=(--form-factor=mobile --screenEmulation.mobile --screenEmulation.width=320 --screenEmulation.height=640 --screenEmulation.deviceScaleFactor=2)
else
  LH_VIEWPORT_FLAGS=(--preset=desktop)
fi

echo "Running $LH_PKG against $URL" >&2
if ! npx --yes "$LH_PKG" "$URL" \
      --only-categories=accessibility \
      "${LH_VIEWPORT_FLAGS[@]}" \
      --output=json \
      --output-path="$OUT_RAW" \
      --chrome-flags="--headless=new --no-sandbox" \
      --quiet >&2; then
  fail "audit_failed" "Lighthouse could not complete the audit" "Confirm the URL is reachable and Chrome is installed"
fi

[ -s "$OUT_RAW" ] || fail "audit_failed" "Lighthouse produced no output" "Re-run manually to see the underlying error: npx $LH_PKG \"$URL\" --only-categories=accessibility --view"

RESULT=$(jq --argjson maxAudits "$MAX_AUDITS" --argjson maxItems "$MAX_ITEMS_PER_AUDIT" '
  {
    success: true,
    url: .finalDisplayedUrl,
    fetchTime: .fetchTime,
    lighthouseVersion: .lighthouseVersion,
    score: (.categories.accessibility.score * 100),
    failingAudits: [
      .audits[]
      | select(.score != null and .score < 1)
      | {
          id: .id,
          title: .title,
          description: .description,
          score: .score,
          items: [
            (.details.items // [])[]
            | {
                selector: (.node.selector // .node.snippet // "n/a"),
                snippet: (.node.snippet // null),
                nodeLabel: (.node.nodeLabel // null)
              }
          ] | .[0:$maxItems]
        }
    ] | .[0:$maxAudits],
    notApplicableCount: [.audits[] | select(.scoreDisplayMode == "notApplicable")] | length,
    manualCheckCount: [.audits[] | select(.scoreDisplayMode == "manual")] | length
  }
' "$OUT_RAW")

echo "$RESULT"

if [ "$CLEANUP_RAW" -eq 1 ]; then
  rm -f "$OUT_RAW"
else
  echo "Raw Lighthouse report saved to $OUT_RAW" >&2
fi
