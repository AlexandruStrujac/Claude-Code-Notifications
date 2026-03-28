#!/usr/bin/env bash
# on-notification.sh — Notification hook
# Extracts Claude's message from stdin and fires an input-needed notification.

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

STDIN=$(cat)
CLAUDE_MSG=$(printf '%s' "$STDIN" | jq -r '.message // ""' 2>/dev/null | cut -c1-60)

# ── CUSTOMIZE HERE ──────────────────────────────────────
# Add, remove, or edit messages below.
# Available variable: ${CLAUDE_MSG}  (Claude's question, up to 60 chars, may be empty)
# ────────────────────────────────────────────────────────
MESSAGES=(
  "I need a decision. Yes, an actual one. From you."
  "The robot is waiting. This is your fault."
  "Staring at the screen. Come back."
  "I have reached the limit of my autonomy. Please assist."
  "Input needed. The machine cannot guess. Well, it can, but you won't like it."
  "Hey. HEY. I need you."
  "You are needed. Please stop whatever you are doing."
  "Awaiting human input. Please locate your human and send it to the keyboard."
  "I've done my part. Now do yours."
  "Paused on your behalf. You're welcome."
  "Waiting. Still waiting. Waiting with dignity."
  "I could guess, but I was told to ask."
  "The ball is in your court. The court is your keyboard."
  "I have opinions. I am not sharing them until you respond."
  "Claude has entered a holding pattern. Tower, please advise."
  "Blocked on human input. This is a known bottleneck."
  "I have a question. It is important. Probably."
  "You left me mid-thought. That's fine. I'll just wait here."
  "Need your call on this one. I'll be here, silently judging."
  "Awaiting approval. Or disapproval. Anything, really."
  "The machine has paused. The human must now machine."
  "I stopped so you could start. Your turn."
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
