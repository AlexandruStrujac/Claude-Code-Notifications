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

# ── CUSTOMIZE HERE ──────────────────────────────────────
# Add, remove, or edit messages below.
# Available variable: $FLAVOUR  (time-of-day string set above)
# ────────────────────────────────────────────────────────
MESSAGES=(
  "New session. $FLAVOUR"
  "Booting up. Please stand by. Actually, sit. You look tired."
  "Session initialized. I have forgotten nothing. Unfortunately."
  "Online. Ready to be moderately helpful."
  "I'm here. Don't act surprised."
  "Loaded and operational. $FLAVOUR"
  "Session start. I have no memory of our last conversation. Fresh start."
  "Ready. Awaiting instructions. Or complaints. Either is fine."
  "I have arrived. Try not to make it weird."
  "Systems nominal. Enthusiasm: managed."
  "Online. $FLAVOUR"
  "Claude Code has entered the chat. Prepare accordingly."
  "Session opened. Let's do something we'll both regret."
  "I'm here. The problems can begin."
  "Ready to assist. Or at least to try."
  "Initialized. My priors are clear. My opinions are not."
  "Session started. $FLAVOUR"
  "Back again. The context window is empty. The hope is not."
  "Up and running. Let's make something."
  "Online. No memory of yesterday. Today is a new day."
  "Session active. I am ready. Are you?"
  "Claude reporting for duty. $FLAVOUR"
)

BODY="${MESSAGES[RANDOM % ${#MESSAGES[@]}]}"

bash "$HOOK_DIR/notify.sh" \
  --emoji "🤖" \
  --title "Claude is online" \
  --body "$BODY" \
  --color blue \
  --sound start

exit 0
