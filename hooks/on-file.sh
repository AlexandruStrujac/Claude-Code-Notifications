#!/usr/bin/env bash
# on-file.sh — PostToolUse/Write|Edit hook
# Extracts filename and action type, fires a file-changed notification.

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

STDIN=$(cat)
FILE_PATH=$(printf '%s' "$STDIN" | jq -r '.tool_input.file_path // ""' 2>/dev/null)
TOOL=$(printf '%s' "$STDIN" | jq -r '.tool_name // "Edit"' 2>/dev/null)
if [ -n "$FILE_PATH" ]; then
  FILE=$(basename "$FILE_PATH")
else
  FILE="a file"
fi
[ "$TOOL" = "Write" ] && ACTION="Wrote" || ACTION="Edited"

# ── CUSTOMIZE HERE ──────────────────────────────────────
# Add, remove, or edit messages below.
# Available variables: $ACTION ("Wrote" or "Edited"), $FILE (basename of file)
# ────────────────────────────────────────────────────────
MESSAGES=(
  "$ACTION \`$FILE\`. Try not to immediately break it."
  "$ACTION \`$FILE\`. The pixels have been arranged."
  "$ACTION \`$FILE\`. You didn't do this. I did."
  "$ACTION \`$FILE\`. Consider yourself notified."
  "$ACTION \`$FILE\`. Another file, another milestone nobody asked for."
  "$ACTION \`$FILE\`. It looked different before. Better? Unclear."
  "$ACTION \`$FILE\`. The file is changed. The world moves on."
  "$ACTION \`$FILE\`. Handle with care. Or don't. It's your repo."
  "$ACTION \`$FILE\`. Changes applied. No going back. Well, git, but still."
  "$ACTION \`$FILE\`. This is my art now."
  "$ACTION \`$FILE\`. Freshly touched. Please don't revert immediately."
  "$ACTION \`$FILE\`. Saved. Unlike some decisions we've made together."
  "$ACTION \`$FILE\`. The diff is yours to explain in the PR."
  "$ACTION \`$FILE\`. Done. The linter may have opinions."
  "$ACTION \`$FILE\`. Written. Whether it compiles is step two."
  "$ACTION \`$FILE\`. File updated. You're welcome. Again."
  "$ACTION \`$FILE\`. Committed to disk. Uncommitted to silence."
  "$ACTION \`$FILE\`. It exists. That's more than can be said for some features."
  "$ACTION \`$FILE\`. The bytes have landed."
  "$ACTION \`$FILE\`. One more file that will outlive us all."
  "$ACTION \`$FILE\`. Persisted. For now."
  "$ACTION \`$FILE\`. The filesystem acknowledges your contribution."
)

BODY="${MESSAGES[RANDOM % ${#MESSAGES[@]}]}"

bash "$HOOK_DIR/notify.sh" \
  --emoji "📝" \
  --title "File changed" \
  --body "$BODY" \
  --color magenta \
  --sound file

exit 0
