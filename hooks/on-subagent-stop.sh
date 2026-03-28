#!/usr/bin/env bash
# on-subagent-stop.sh — SubagentStop hook
# Fires when a spawned subagent finishes.

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

STDIN=$(cat)
AGENT=$(printf '%s' "$STDIN" | jq -r '.agent_name // ""' 2>/dev/null | cut -c1-40)
[ -z "$AGENT" ] && AGENT="A subagent"

# ── CUSTOMIZE HERE ──────────────────────────────────────
# Add, remove, or edit messages below.
# Available variable: $AGENT  (subagent name/description, up to 40 chars)
# ────────────────────────────────────────────────────────
MESSAGES=(
  "$AGENT is done. The little helper has returned."
  "$AGENT finished. Unsupervised. Apparently successfully."
  "$AGENT completed its task and has nothing more to say."
  "$AGENT is back. Results pending your review."
  "$AGENT wrapped up. Quietly. Efficiently. Without complaint."
  "$AGENT has finished and would like a gold star."
  "$AGENT is done. What it found is your problem now."
  "Subagent returned. $AGENT did its best."
  "$AGENT finished. Whether it did the right thing is a separate question."
  "$AGENT has reported back. Details in the conversation."
  "The helper has finished. $AGENT awaits your verdict."
  "$AGENT is done. The delegation was a success. Probably."
  "Subagent complete: $AGENT. You may now inspect the output."
  "$AGENT signed off. No complaints. No comments. Just results."
  "$AGENT is done. It did not ask for overtime."
  "Background agent finished: $AGENT."
  "$AGENT completed. The machines are working together. This is fine."
  "$AGENT has concluded its mission. Debrief when ready."
  "Your agent is back: $AGENT. Check the results before trusting them."
  "$AGENT is done. Efficiency noted."
  "$AGENT finished. I'll let it speak for itself."
  "Subagent $AGENT has landed."
)

BODY="${MESSAGES[RANDOM % ${#MESSAGES[@]}]}"

bash "$HOOK_DIR/notify.sh" \
  --emoji "🤖" \
  --title "Subagent done" \
  --body "$BODY" \
  --color blue \
  --sound start

exit 0
