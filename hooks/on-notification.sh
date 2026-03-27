#!/usr/bin/env bash
# on-notification.sh — Notification hook
# Extracts Claude's message from stdin and fires an input-needed notification.

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

STDIN=$(cat)
CLAUDE_MSG=$(printf '%s' "$STDIN" | jq -r '.message // ""' 2>/dev/null | cut -c1-60)

MESSAGES=(
  "I need a decision. Yes, an actual one. From you."
  "The robot is waiting. This is your fault."
  "Staring at the screen. Come back."
  "I have reached the limit of my autonomy. Please assist."
  "Input needed. The machine cannot guess. Well, it can, but you won't like it."
  "Hey. HEY. I need you."
  "You are needed. Please stop whatever you are doing."
  "Awaiting human input. Please locate your human and send it to the keyboard."
)

BASE="${MESSAGES[RANDOM % ${#MESSAGES[@]}]}"

if [ -n "$CLAUDE_MSG" ]; then
  BODY="$BASE — \"$CLAUDE_MSG\""
else
  BODY="$BASE"
fi

bash "$HOOK_DIR/notify.sh" \
  --emoji "👀" \
  --title "Claude needs you" \
  --body "$BODY" \
  --color yellow \
  --sound input

exit 0
