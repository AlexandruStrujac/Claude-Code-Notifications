#!/usr/bin/env bash
# on-error.sh — PostToolUseFailure hook
# Extracts tool name and error snippet, fires a failure notification.

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

STDIN=$(cat)
TOOL=$(printf '%s' "$STDIN" | jq -r '.tool_name // "Tool"' 2>/dev/null)
ERR=$(printf '%s' "$STDIN" | jq -r '.tool_response // ""' 2>/dev/null | head -1 | cut -c1-50)

# ── CUSTOMIZE HERE ──────────────────────────────────────
# Add, remove, or edit messages below.
# Available variable: $TOOL (tool name)
# Note: $ERR (first line of error) is automatically appended to the message when available.
# ────────────────────────────────────────────────────────
MESSAGES=(
  "$TOOL failed. The machine is surprised. Briefly."
  "Error in $TOOL. This is awkward for both of us."
  "$TOOL blew up. I had nothing to do with it."
  "$TOOL returned an error. Unexpected. Truly."
  "Well. $TOOL didn't go as planned."
  "$TOOL says no. I'm just the messenger."
  "$TOOL has expressed displeasure. Loudly."
  "Something went wrong in $TOOL. Shocking. Truly shocking."
  "$TOOL failed. We move on. Quietly."
  "$TOOL encountered a problem. I encountered it first."
  "Error. The kind that $TOOL takes personally."
  "$TOOL: not today. Apparently."
  "Failure detected in $TOOL. Logs may clarify. Or deepen the mystery."
  "$TOOL exited unhappily. Mood: relatable."
  "The operation failed. $TOOL is not apologizing."
  "$TOOL had one job. We don't talk about it."
  "Error in $TOOL. I recommend deep breathing."
  "$TOOL returned non-zero. I'm choosing not to take it personally."
  "Something broke in $TOOL. Character-building moment."
  "$TOOL failed with conviction."
  "Error from $TOOL. The system remains unimpressed."
  "$TOOL: attempted. Success: pending."
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
