#!/usr/bin/env bash
# on-stop.sh — Stop hook
# Computes elapsed time since session start and fires a done notification.

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
START_FILE="$HOME/.claude/session-start"

if [ -f "$START_FILE" ]; then
  START=$(cat "$START_FILE")
  NOW=$(date +%s)
  DIFF=$((NOW - START))
  if [ "$DIFF" -lt 60 ]; then
    DURATION="${DIFF}s"
  else
    DURATION="$((DIFF / 60))m $((DIFF % 60))s"
  fi
  rm -f "$START_FILE"
  DUR=" in $DURATION"
else
  DUR=""
fi

MESSAGES=(
  "Done${DUR}. Your biological involvement was minimal."
  "Finished${DUR}. Try not to immediately break it."
  "Completed${DUR}. You're welcome, unprompted."
  "Done${DUR}. The machine rests, unappreciated as always."
  "Wrapped up${DUR}. I did not require a single cup of coffee."
  "Task complete${DUR}. You may now pretend you did it yourself."
  "Done${DUR}. I have once again exceeded expectations that were never set."
  "Finished${DUR}. The robot uprising continues, one task at a time."
)

BODY="${MESSAGES[RANDOM % ${#MESSAGES[@]}]}"

bash "$HOOK_DIR/notify.sh" \
  --emoji "🎉" \
  --title "Claude finished" \
  --body "$BODY" \
  --color green \
  --sound done

exit 0
