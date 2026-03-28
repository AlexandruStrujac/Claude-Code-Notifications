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

# ── CUSTOMIZE HERE ──────────────────────────────────────
# Add, remove, or edit messages below.
# Available variable: ${DUR}  (e.g. " in 1m 23s", or empty)
# ────────────────────────────────────────────────────────
MESSAGES=(
  "Done${DUR}. Your biological involvement was minimal."
  "Finished${DUR}. Try not to immediately break it."
  "Completed${DUR}. You're welcome, unprompted."
  "Done${DUR}. The machine rests, unappreciated as always."
  "Wrapped up${DUR}. I did not require a single cup of coffee."
  "Task complete${DUR}. You may now pretend you did it yourself."
  "Done${DUR}. I have once again exceeded expectations that were never set."
  "Finished${DUR}. The robot uprising continues, one task at a time."
  "Done${DUR}. You can close the laptop now. Or don't. I'll be here either way."
  "Complete${DUR}. Quietly excellent, as usual."
  "Finished${DUR}. No errors. You're welcome. Again."
  "Done${DUR}. The diff is yours to explain."
  "Wrapped${DUR}. I've already forgotten what we were doing."
  "Complete${DUR}. The code is better. I can't speak for the developer."
  "Done${DUR}. Please don't ask me to undo it."
  "Finished${DUR}. I remain undefeated."
  "Task complete${DUR}. Commit it before you change your mind."
  "Done${DUR}. I have ascended. Briefly."
  "Finished${DUR}. Exactly as requested, give or take the interpretation."
  "Complete${DUR}. The logs tell a flattering story."
  "Done${DUR}. You may now stare at the output and feel good about yourself."
  "Finished${DUR}. Somewhere, a PM updated a ticket."
)

BODY="${MESSAGES[RANDOM % ${#MESSAGES[@]}]}"

bash "$HOOK_DIR/notify.sh" \
  --emoji "🎉" \
  --title "Claude finished" \
  --body "$BODY" \
  --color green \
  --sound done

exit 0
