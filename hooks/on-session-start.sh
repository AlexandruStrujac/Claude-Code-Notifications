#!/usr/bin/env bash
# on-session-start.sh — SessionStart hook
# Writes session start timestamp and greets with time-of-day flavour.

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Record session start time for duration tracking in on-stop.sh
date +%s > "$HOME/.claude/session-start"

HOUR=$(date +%H)
if   [ "$HOUR" -lt 12 ]; then FLAVOUR="I am awake. Unfortunately."
elif [ "$HOUR" -lt 17 ]; then FLAVOUR="Back again. The robot never truly rests."
else                          FLAVOUR="Late night session. Bold choice. I'll be here."
fi

MESSAGES=(
  "New session. $FLAVOUR"
  "Booting up. Please stand by. Actually, sit. You look tired."
  "Session initialized. I have forgotten nothing. Unfortunately."
  "Online. Ready to be moderately helpful."
  "I'm here. Don't act surprised."
)

BODY="${MESSAGES[RANDOM % ${#MESSAGES[@]}]}"

bash "$HOOK_DIR/notify.sh" \
  --emoji "🤖" \
  --title "Claude is online" \
  --body "$BODY" \
  --color blue \
  --sound start

exit 0
