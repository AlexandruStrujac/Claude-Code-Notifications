#!/usr/bin/env bash
# on-file.sh — PostToolUse/Write|Edit hook
# Extracts filename and action type, fires a file-changed notification.

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

STDIN=$(cat)
FILE_PATH=$(printf '%s' "$STDIN" | jq -r '.tool_input.file_path // ""' 2>/dev/null)
TOOL=$(printf '%s' "$STDIN" | jq -r '.tool_name // "Edit"' 2>/dev/null)
FILE=$(basename "$FILE_PATH")

[ -z "$FILE" ] && FILE="a file"
[ "$TOOL" = "Write" ] && ACTION="Wrote" || ACTION="Edited"

MESSAGES=(
  "$ACTION \`$FILE\`. Try not to immediately break it."
  "$ACTION \`$FILE\`. The pixels have been arranged."
  "$ACTION \`$FILE\`. You didn't do this. I did."
  "$ACTION \`$FILE\`. Consider yourself notified."
  "$ACTION \`$FILE\`. Another file, another milestone nobody asked for."
)

BODY="${MESSAGES[RANDOM % ${#MESSAGES[@]}]}"

bash "$HOOK_DIR/notify.sh" \
  --emoji "📝" \
  --title "File changed" \
  --body "$BODY" \
  --color magenta \
  --sound file

exit 0
