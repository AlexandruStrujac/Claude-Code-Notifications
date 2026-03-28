#!/usr/bin/env bash
# install.sh — installs Claude Code notification hooks globally

set -e

HOOKS_DIR="$HOME/.claude/hooks"
SETTINGS="$HOME/.claude/settings.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing Claude Code notification hooks..."

# --- 1. Require jq ---
if ! command -v jq &>/dev/null; then
  echo ""
  echo "  ERROR: jq is required but was not found."
  echo "  Install it:"
  echo "    macOS:  brew install jq"
  echo "    Linux:  sudo apt install jq"
  echo ""
  exit 1
fi

# --- 2. Copy scripts ---
mkdir -p "$HOOKS_DIR"
cp "$SCRIPT_DIR/hooks/notify.sh"            "$HOOKS_DIR/notify.sh"
cp "$SCRIPT_DIR/hooks/on-stop.sh"           "$HOOKS_DIR/on-stop.sh"
cp "$SCRIPT_DIR/hooks/on-notification.sh"   "$HOOKS_DIR/on-notification.sh"
cp "$SCRIPT_DIR/hooks/on-bash.sh"           "$HOOKS_DIR/on-bash.sh"
cp "$SCRIPT_DIR/hooks/on-file.sh"           "$HOOKS_DIR/on-file.sh"
cp "$SCRIPT_DIR/hooks/on-error.sh"          "$HOOKS_DIR/on-error.sh"
cp "$SCRIPT_DIR/hooks/on-session-start.sh"  "$HOOKS_DIR/on-session-start.sh"
cp "$SCRIPT_DIR/hooks/on-subagent-stop.sh"  "$HOOKS_DIR/on-subagent-stop.sh"
cp "$SCRIPT_DIR/hooks/on-pre-compact.sh"    "$HOOKS_DIR/on-pre-compact.sh"
chmod +x "$HOOKS_DIR"/*.sh
echo "  Copied scripts to $HOOKS_DIR"

# --- 3. Remove old scripts if present ---
rm -f "$HOOKS_DIR/notify-done.sh" "$HOOKS_DIR/notify-input.sh"

# --- 4. Create settings.json if missing ---
[ ! -f "$SETTINGS" ] && echo "{}" > "$SETTINGS" && echo "  Created $SETTINGS"

# --- 5. Merge hooks into settings.json ---
UPDATED=$(jq \
  --arg stop    "$HOOKS_DIR/on-stop.sh" \
  --arg notif   "$HOOKS_DIR/on-notification.sh" \
  --arg bash    "$HOOKS_DIR/on-bash.sh" \
  --arg file    "$HOOKS_DIR/on-file.sh" \
  --arg error   "$HOOKS_DIR/on-error.sh" \
  --arg start   "$HOOKS_DIR/on-session-start.sh" \
  --arg subagent "$HOOKS_DIR/on-subagent-stop.sh" \
  --arg compact  "$HOOKS_DIR/on-pre-compact.sh" \
  '
  def upsert_hook(event; entry):
    .hooks[event] = ((.hooks[event] // []) | map(select(.hooks[0].command != entry.hooks[0].command)) + [entry]);

  def cmd(c): {"hooks": [{"type": "command", "command": c, "async": true}]};
  def cmd_match(m; c): {"matcher": m, "hooks": [{"type": "command", "command": c, "async": true}]};

  . |
  upsert_hook("Stop";         cmd($stop)) |
  upsert_hook("Notification";  cmd($notif)) |
  upsert_hook("SessionStart";  cmd($start)) |
  upsert_hook("PostToolUseFailure"; cmd($error)) |
  upsert_hook("SubagentStop"; cmd($subagent)) |
  upsert_hook("PreCompact";   cmd($compact)) |
  (.hooks.PostToolUse = (
    ((.hooks.PostToolUse // []) | map(select(.hooks[0].command != $bash and .hooks[0].command != $file))) +
    [cmd_match("Bash"; $bash), cmd_match("Write|Edit"; $file)]
  ))
  ' "$SETTINGS")

printf '%s\n' "$UPDATED" > "$SETTINGS"
echo "  Updated $SETTINGS"

# --- 6. Validate ---
jq empty "$SETTINGS"
echo ""
echo "Done! Hooks installed."
echo "Restart Claude Code to activate."
