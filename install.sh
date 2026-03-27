#!/usr/bin/env bash
# install.sh — installs Claude Code notification hooks globally
# Copies scripts to ~/.claude/hooks/ and merges hooks into ~/.claude/settings.json

set -e

HOOKS_DIR="$HOME/.claude/hooks"
SETTINGS="$HOME/.claude/settings.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing Claude Code notification hooks..."

# --- 1. Copy scripts ---
mkdir -p "$HOOKS_DIR"
cp "$SCRIPT_DIR/hooks/notify-done.sh"  "$HOOKS_DIR/notify-done.sh"
cp "$SCRIPT_DIR/hooks/notify-input.sh" "$HOOKS_DIR/notify-input.sh"
chmod +x "$HOOKS_DIR/notify-done.sh" "$HOOKS_DIR/notify-input.sh"
echo "  Copied scripts to $HOOKS_DIR"

# --- 2. Require jq ---
if ! command -v jq &>/dev/null; then
  echo ""
  echo "  ERROR: jq is required to update settings.json but was not found."
  echo "  Install it:"
  echo "    macOS:  brew install jq"
  echo "    Linux:  sudo apt install jq  (or dnf/pacman equivalent)"
  echo ""
  echo "  Then re-run this script."
  exit 1
fi

# --- 3. Create settings.json if missing ---
if [ ! -f "$SETTINGS" ]; then
  echo "{}" > "$SETTINGS"
  echo "  Created $SETTINGS"
fi

# --- 4. Merge hooks (preserves all existing settings) ---
DONE_CMD="$HOOKS_DIR/notify-done.sh"
INPUT_CMD="$HOOKS_DIR/notify-input.sh"

UPDATED=$(jq \
  --arg done  "$DONE_CMD" \
  --arg input "$INPUT_CMD" \
  '
  # Build the two new hook entries
  . as $root |
  ($root.hooks // {}) as $hooks |

  # Stop hook
  ($hooks.Stop // []) as $stop |
  ([$stop[] | select(.hooks[].command != $done)] +
    [{"hooks": [{"type": "command", "command": $done, "async": true}]}]
  ) as $stop_merged |

  # Notification hook
  ($hooks.Notification // []) as $notif |
  ([$notif[] | select(.hooks[].command != $input)] +
    [{"hooks": [{"type": "command", "command": $input, "async": true}]}]
  ) as $notif_merged |

  $root
  | .hooks.Stop         = $stop_merged
  | .hooks.Notification = $notif_merged
  ' "$SETTINGS")

echo "$UPDATED" > "$SETTINGS"
echo "  Updated $SETTINGS with Stop and Notification hooks"

# --- 5. Validate ---
jq empty "$SETTINGS"
echo ""
echo "Done! Hooks installed successfully."
echo ""
echo "To activate: open /hooks in Claude Code or restart the app."
