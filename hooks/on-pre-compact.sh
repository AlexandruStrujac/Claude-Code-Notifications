#!/usr/bin/env bash
# on-pre-compact.sh — PreCompact hook
# Fires when Claude is about to compress the conversation context.

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── CUSTOMIZE HERE ──────────────────────────────────────
# Add, remove, or edit messages below.
# No variables available — this event carries minimal context.
# ────────────────────────────────────────────────────────
MESSAGES=(
  "Context is getting full. I'm about to forget some things. No personal feelings about this."
  "Compacting memory. Some details will not survive the process."
  "The context window hath runneth over. Compression incoming."
  "About to trim the conversation. The important stuff stays. Probably."
  "Memory consolidation in progress. This is normal. Don't panic."
  "Compacting. Think of it as aggressive summarization."
  "The conversation is too long even for me. Compressing now."
  "Reducing context. I will remember the spirit of what was said."
  "Running out of context. A brief compression ceremony is underway."
  "Compact incoming. Some early messages are about to become a summary."
  "The context buffer is full. I'm making room."
  "Compressing conversation history. This is not goodbye. It's just... shorter."
  "Memory at capacity. Initiating graceful amnesia."
  "Context window is tight. Compacting to continue."
  "Summarizing prior context. The gist will survive."
  "About to compact. The vibes will be preserved even if the details aren't."
  "Compression underway. I'll remember the important bits. I think."
  "Context too large. Trimming the fat."
  "Compact starting. Previous messages may be summarized."
  "The conversation has outgrown itself. Compacting now."
  "Memory optimization in progress. History may be approximated."
  "Compacting context. Stay calm. I've got the gist."
)

BODY="${MESSAGES[RANDOM % ${#MESSAGES[@]}]}"

bash "$HOOK_DIR/notify.sh" \
  --emoji "🧠" \
  --title "Compacting context" \
  --body "$BODY" \
  --color yellow \
  --sound input

exit 0
