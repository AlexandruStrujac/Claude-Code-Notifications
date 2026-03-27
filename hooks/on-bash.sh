#!/usr/bin/env bash
# on-bash.sh — PostToolUse/Bash hook
# Extracts the command that was run and fires a notification.

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

STDIN=$(cat)
CMD=$(printf '%s' "$STDIN" | jq -r '.tool_input.command // ""' 2>/dev/null | head -1 | cut -c1-40)

[ -z "$CMD" ] && CMD="a command"

MESSAGES=(
  "Ran \`$CMD\`. Fingers crossed. Not my problem now."
  "Executed \`$CMD\`. The shell has been consulted."
  "Ran \`$CMD\`. It probably worked."
  "Fired \`$CMD\`. No regrets."
  "Did the thing: \`$CMD\`. You're welcome."
)

BODY="${MESSAGES[RANDOM % ${#MESSAGES[@]}]}"

bash "$HOOK_DIR/notify.sh" \
  --emoji "⚡" \
  --title "Command ran" \
  --body "$BODY" \
  --color cyan \
  --sound bash

exit 0
