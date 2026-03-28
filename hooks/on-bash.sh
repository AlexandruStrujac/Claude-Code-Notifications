#!/usr/bin/env bash
# on-bash.sh — PostToolUse/Bash hook
# Extracts the command that was run and fires a notification.

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

STDIN=$(cat)
CMD=$(printf '%s' "$STDIN" | jq -r '.tool_input.command // ""' 2>/dev/null | head -1 | cut -c1-40)

[ -z "$CMD" ] && CMD="a command"

# ── CUSTOMIZE HERE ──────────────────────────────────────
# Add, remove, or edit messages below.
# Available variable: $CMD  (first 40 chars of the command run)
# ────────────────────────────────────────────────────────
MESSAGES=(
  "Ran \`$CMD\`. Fingers crossed. Not my problem now."
  "Executed \`$CMD\`. The shell has been consulted."
  "Ran \`$CMD\`. It probably worked."
  "Fired \`$CMD\`. No regrets."
  "Did the thing: \`$CMD\`. You're welcome."
  "Ran \`$CMD\`. The terminal did not complain. Loudly."
  "Executed \`$CMD\`. Exit code unknown. Attitude: confident."
  "\`$CMD\` has been unleashed upon the system."
  "Ran \`$CMD\`. The shell has seen things."
  "\`$CMD\` — sent. Receipt not guaranteed."
  "Fired \`$CMD\` into the void. The void responded."
  "Ran \`$CMD\`. Output: exists. Quality: unclear."
  "Executed \`$CMD\`. I take no responsibility."
  "\`$CMD\` — done. The filesystem may never be the same."
  "Ran \`$CMD\`. Surprisingly uneventful."
  "The shell has processed \`$CMD\`. Please hold."
  "\`$CMD\` dispatched. I have moved on."
  "Ran \`$CMD\`. It ran. That's the bar."
  "Executed \`$CMD\`. The computer did a computer thing."
  "Ran \`$CMD\`. Whether it helped is a separate question."
  "Shell command complete: \`$CMD\`. You're one step closer to something."
  "\`$CMD\` — handled. Professionally, even."
)

BODY="${MESSAGES[RANDOM % ${#MESSAGES[@]}]}"

bash "$HOOK_DIR/notify.sh" \
  --emoji "⚡" \
  --title "Command ran" \
  --body "$BODY" \
  --color cyan \
  --sound bash

exit 0
