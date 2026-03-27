#!/usr/bin/env bash
# on-error.sh — PostToolUseFailure hook
# Extracts tool name and error snippet, fires a failure notification.

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

STDIN=$(cat)
TOOL=$(printf '%s' "$STDIN" | jq -r '.tool_name // "Tool"' 2>/dev/null)
ERR=$(printf '%s' "$STDIN" | jq -r '.tool_response // ""' 2>/dev/null | head -1 | cut -c1-50)

MESSAGES=(
  "$TOOL failed. The machine is surprised. Briefly."
  "Error in $TOOL. This is awkward for both of us."
  "$TOOL blew up. I had nothing to do with it."
  "$TOOL returned an error. Unexpected. Truly."
  "Well. $TOOL didn't go as planned."
)

BASE="${MESSAGES[RANDOM % ${#MESSAGES[@]}]}"
[ -n "$ERR" ] && BODY="$BASE — $ERR" || BODY="$BASE"

bash "$HOOK_DIR/notify.sh" \
  --emoji "💀" \
  --title "Something broke" \
  --body "$BODY" \
  --color red \
  --sound error

exit 0
