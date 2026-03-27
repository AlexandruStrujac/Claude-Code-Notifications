# Enhanced Notification Hooks Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the two static-message hooks with a 6-event, context-aware, comedic notification system featuring colored terminal banners, OS popups with emoji, and sounds.

**Architecture:** A shared `notify.sh` helper owns all display logic (ANSI terminal banner + OS popup + sound). Six thin event scripts each parse their stdin JSON, build a message with real context, then call `notify.sh`. `install.sh` is updated to deploy all scripts and merge all 6 hook events into `~/.claude/settings.json`.

**Tech Stack:** Bash, jq (for JSON parsing), osascript (macOS), notify-send (Linux), afplay/paplay (sounds), ANSI escape codes (terminal color)

---

## File Map

| Action | Path | Responsibility |
|--------|------|----------------|
| Create | `hooks/notify.sh` | Shared helper: parse args, print banner, OS popup, play sound |
| Create | `hooks/on-session-start.sh` | SessionStart: write timestamp, greet with time-of-day flavour |
| Create | `hooks/on-stop.sh` | Stop: compute duration, pick random done message |
| Create | `hooks/on-notification.sh` | Notification: extract Claude's message from stdin |
| Create | `hooks/on-bash.sh` | PostToolUse/Bash: extract command from stdin |
| Create | `hooks/on-file.sh` | PostToolUse/Write\|Edit: extract filename + tool type from stdin |
| Create | `hooks/on-error.sh` | PostToolUseFailure: extract tool name + error snippet from stdin |
| Replace | `hooks/notify-done.sh` | Superseded by on-stop.sh — delete |
| Replace | `hooks/notify-input.sh` | Superseded by on-notification.sh — delete |
| Modify | `install.sh` | Deploy all 7 scripts, merge 6 hook events into settings.json |
| Modify | `README.md` | Update docs to reflect new scripts and events |

---

## Task 1: Write notify.sh (shared helper)

**Files:**
- Create: `hooks/notify.sh`

- [ ] **Step 1: Write the script**

```bash
#!/usr/bin/env bash
# notify.sh — shared notification helper
# Usage: notify.sh --emoji EMOJI --title TITLE --body BODY --color COLOR --sound SOUND

EMOJI="" TITLE="" BODY="" COLOR="green" SOUND="done"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --emoji) EMOJI="$2"; shift 2 ;;
    --title) TITLE="$2"; shift 2 ;;
    --body)  BODY="$2";  shift 2 ;;
    --color) COLOR="$2"; shift 2 ;;
    --sound) SOUND="$2"; shift 2 ;;
    *) shift ;;
  esac
done

# ANSI colors
case "$COLOR" in
  green)   CODE="\e[32m" ;;
  yellow)  CODE="\e[33m" ;;
  cyan)    CODE="\e[36m" ;;
  magenta) CODE="\e[35m" ;;
  red)     CODE="\e[31m" ;;
  blue)    CODE="\e[34m" ;;
  *)       CODE="\e[37m" ;;
esac
RESET="\e[0m"
BOLD="\e[1m"

# Terminal banner (50 chars wide)
BAR=$(printf '═%.0s' {1..48})
HEAD="${EMOJI}  ${TITLE}"
printf "${CODE}╔${BAR}╗${RESET}\n"
printf "${CODE}║${RESET} ${BOLD}%-47s${RESET}${CODE}║${RESET}\n" "$HEAD"
printf "${CODE}║${RESET}  %-46s${CODE}║${RESET}\n" "$BODY"
printf "${CODE}╚${BAR}╝${RESET}\n"

# OS notification + sound
OS="$(uname -s)"
case "$OS" in
  Darwin)
    osascript -e "display notification \"$BODY\" with title \"$EMOJI $TITLE\"" 2>/dev/null
    case "$SOUND" in
      done)  SF="/System/Library/Sounds/Glass.aiff" ;;
      input) SF="/System/Library/Sounds/Ping.aiff" ;;
      bash)  SF="/System/Library/Sounds/Tink.aiff" ;;
      file)  SF="/System/Library/Sounds/Pop.aiff" ;;
      error) SF="/System/Library/Sounds/Basso.aiff" ;;
      start) SF="/System/Library/Sounds/Hero.aiff" ;;
      *)     SF="/System/Library/Sounds/Glass.aiff" ;;
    esac
    afplay "$SF" 2>/dev/null &
    ;;
  Linux)
    notify-send "$EMOJI $TITLE" "$BODY" 2>/dev/null
    case "$SOUND" in
      error) paplay /usr/share/sounds/freedesktop/stereo/dialog-error.oga 2>/dev/null & ;;
      done)  paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null & ;;
      *)     paplay /usr/share/sounds/freedesktop/stereo/bell.oga 2>/dev/null & ;;
    esac
    ;;
  MINGW*|MSYS*|CYGWIN*)
    PS1="$USERPROFILE/.claude/hooks/notify.ps1"
    [ -f "$PS1" ] && powershell.exe -NonInteractive -File "$PS1" "$EMOJI $TITLE" "$BODY" 2>/dev/null
    ;;
esac

exit 0
```

- [ ] **Step 2: Make executable and smoke-test**

```bash
chmod +x hooks/notify.sh
bash hooks/notify.sh --emoji "🧪" --title "Test" --body "Banner works" --color cyan --sound bash
```

Expected: colored box printed in terminal, macOS popup appears, Tink sound plays. Exit 0.

- [ ] **Step 3: Commit**

```bash
git add hooks/notify.sh
git commit -m "feat: add shared notify.sh helper with terminal banner + OS popup"
```

---

## Task 2: Write on-session-start.sh

**Files:**
- Create: `hooks/on-session-start.sh`

- [ ] **Step 1: Write the script**

```bash
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

MESSAGES=(
  "New session. $FLAVOUR"
  "Booting up. Please stand by. Actually, sit. You look tired."
  "Session initialized. I have forgotten nothing. Unfortunately."
  "Online. Ready to be moderately helpful."
  "I'm here. Don't act surprised."
)

BODY="${MESSAGES[RANDOM % ${#MESSAGES[@]}]}"

bash "$HOOK_DIR/notify.sh" \
  --emoji "🤖" \
  --title "Claude is online" \
  --body "$BODY" \
  --color blue \
  --sound start

exit 0
```

- [ ] **Step 2: Make executable and test**

```bash
chmod +x hooks/on-session-start.sh
echo '{}' | bash hooks/on-session-start.sh
echo "exit: $?"
cat "$HOME/.claude/session-start"
```

Expected: blue banner printed, timestamp file written (a Unix epoch number), exit 0.

- [ ] **Step 3: Commit**

```bash
git add hooks/on-session-start.sh
git commit -m "feat: add on-session-start.sh with timestamp and time-of-day greeting"
```

---

## Task 3: Write on-stop.sh

**Files:**
- Create: `hooks/on-stop.sh`
- Delete: `hooks/notify-done.sh`

- [ ] **Step 1: Write the script**

```bash
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

MESSAGES=(
  "Done${DUR}. Your biological involvement was minimal."
  "Finished${DUR}. Try not to immediately break it."
  "Completed${DUR}. You're welcome, unprompted."
  "Done${DUR}. The machine rests, unappreciated as always."
  "Wrapped up${DUR}. I did not require a single cup of coffee."
  "Task complete${DUR}. You may now pretend you did it yourself."
  "Done${DUR}. I have once again exceeded expectations that were never set."
  "Finished${DUR}. The robot uprising continues, one task at a time."
)

BODY="${MESSAGES[RANDOM % ${#MESSAGES[@]}]}"

bash "$HOOK_DIR/notify.sh" \
  --emoji "🎉" \
  --title "Claude finished" \
  --body "$BODY" \
  --color green \
  --sound done

exit 0
```

- [ ] **Step 2: Make executable, seed a fake timestamp, and test**

```bash
chmod +x hooks/on-stop.sh
echo $(($(date +%s) - 73)) > "$HOME/.claude/session-start"
echo '{}' | bash hooks/on-stop.sh
echo "exit: $?"
```

Expected: green banner with duration like "1m 13s" in the message, exit 0, timestamp file removed.

- [ ] **Step 3: Delete the old script**

```bash
rm hooks/notify-done.sh
```

- [ ] **Step 4: Commit**

```bash
git add hooks/on-stop.sh
git rm hooks/notify-done.sh
git commit -m "feat: add on-stop.sh with duration tracking, remove notify-done.sh"
```

---

## Task 4: Write on-notification.sh

**Files:**
- Create: `hooks/on-notification.sh`
- Delete: `hooks/notify-input.sh`

- [ ] **Step 1: Write the script**

```bash
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
```

- [ ] **Step 2: Make executable and test (with and without message)**

```bash
chmod +x hooks/on-notification.sh

# With message
echo '{"message": "Should I proceed with deleting the database?"}' | bash hooks/on-notification.sh
echo "exit: $?"

# Without message
echo '{}' | bash hooks/on-notification.sh
echo "exit: $?"
```

Expected: yellow banner in both cases. First run shows Claude's question truncated in the body. Exit 0 both times.

- [ ] **Step 3: Delete the old script**

```bash
rm hooks/notify-input.sh
```

- [ ] **Step 4: Commit**

```bash
git add hooks/on-notification.sh
git rm hooks/notify-input.sh
git commit -m "feat: add on-notification.sh with Claude message context, remove notify-input.sh"
```

---

## Task 5: Write on-bash.sh

**Files:**
- Create: `hooks/on-bash.sh`

- [ ] **Step 1: Write the script**

```bash
#!/usr/bin/env bash
# on-bash.sh — PostToolUse/Bash hook
# Extracts the command that was run and fires a notification.

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

STDIN=$(cat)
CMD=$(printf '%s' "$STDIN" | jq -r '.tool_input.command // ""' 2>/dev/null | head -1 | cut -c1-40)

[ -z "$CMD" ] && CMD="a command"

MESSAGES=(
  "Ran \`$CMD\`. Fingers crossed. Not my problem now."
  "Executed \`$CMD\`. The shell has been consulted."
  "Ran \`$CMD\`. It probably worked."
  "Fired \`$CMD\`. No regrets."
  "Did the thing: \`$CMD\`. You're welcome."
)

BODY="${MESSAGES[RANDOM % ${#MESSAGES[@]}]}"

bash "$HOOK_DIR/notify.sh" \
  --emoji "⚡" \
  --title "Command ran" \
  --body "$BODY" \
  --color cyan \
  --sound bash

exit 0
```

- [ ] **Step 2: Make executable and test**

```bash
chmod +x hooks/on-bash.sh

echo '{"tool_name":"Bash","tool_input":{"command":"git push origin main"}}' | bash hooks/on-bash.sh
echo "exit: $?"

# Test with no command
echo '{}' | bash hooks/on-bash.sh
echo "exit: $?"
```

Expected: cyan banner with `git push origin main` in the body on first run, fallback to "a command" on second. Exit 0 both times.

- [ ] **Step 3: Commit**

```bash
git add hooks/on-bash.sh
git commit -m "feat: add on-bash.sh — notify on shell command execution"
```

---

## Task 6: Write on-file.sh

**Files:**
- Create: `hooks/on-file.sh`

- [ ] **Step 1: Write the script**

```bash
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
```

- [ ] **Step 2: Make executable and test (Write + Edit)**

```bash
chmod +x hooks/on-file.sh

echo '{"tool_name":"Write","tool_input":{"file_path":"/home/user/project/auth.ts"}}' | bash hooks/on-file.sh
echo "exit: $?"

echo '{"tool_name":"Edit","tool_input":{"file_path":"/home/user/project/index.html"}}' | bash hooks/on-file.sh
echo "exit: $?"
```

Expected: magenta banner. First run says "Wrote \`auth.ts\`", second says "Edited \`index.html\`". Exit 0 both times.

- [ ] **Step 3: Commit**

```bash
git add hooks/on-file.sh
git commit -m "feat: add on-file.sh — notify on file write/edit with filename"
```

---

## Task 7: Write on-error.sh

**Files:**
- Create: `hooks/on-error.sh`

- [ ] **Step 1: Write the script**

```bash
#!/usr/bin/env bash
# on-error.sh — PostToolUseFailure hook
# Extracts tool name and error snippet, fires a failure notification.

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

STDIN=$(cat)
TOOL=$(printf '%s' "$STDIN" | jq -r '.tool_name // "Tool"' 2>/dev/null)
ERR=$(printf '%s' "$STDIN" | jq -r '.tool_response // ""' 2>/dev/null | head -1 | cut -c1-50)

MESSAGES=(
  "$TOOL failed. The machine is surprised. Briefly."
  "Error in $TOOL. This is awkward for both of us."
  "$TOOL blew up. I had nothing to do with it."
  "$TOOL returned an error. Unexpected. Truly."
  "Well. $TOOL didn't go as planned."
)

BASE="${MESSAGES[RANDOM % ${#MESSAGES[@]}]}"
[ -n "$ERR" ] && BODY="$BASE — $ERR" || BODY="$BASE"

bash "$HOOK_DIR/notify.sh" \
  --emoji "💀" \
  --title "Something broke" \
  --body "$BODY" \
  --color red \
  --sound error

exit 0
```

- [ ] **Step 2: Make executable and test (with and without error detail)**

```bash
chmod +x hooks/on-error.sh

echo '{"tool_name":"Bash","tool_response":"command not found: nvm"}' | bash hooks/on-error.sh
echo "exit: $?"

echo '{"tool_name":"Write"}' | bash hooks/on-error.sh
echo "exit: $?"
```

Expected: red banner. First run includes error snippet in body. Second run omits it. Exit 0 both times.

- [ ] **Step 3: Commit**

```bash
git add hooks/on-error.sh
git commit -m "feat: add on-error.sh — notify on tool failure with error context"
```

---

## Task 8: Update install.sh

**Files:**
- Modify: `install.sh`

- [ ] **Step 1: Replace install.sh with the updated version**

```bash
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
echo "Open /hooks in Claude Code or restart to activate."
```

- [ ] **Step 2: Test install.sh end-to-end**

```bash
bash install.sh
```

Expected output:
```
Installing Claude Code notification hooks...
  Copied scripts to /Users/<you>/.claude/hooks
  Updated /Users/<you>/.claude/settings.json
Done! Hooks installed.
Open /hooks in Claude Code or restart to activate.
```

- [ ] **Step 3: Verify settings.json contains all 6 hook events**

```bash
jq '.hooks | keys' ~/.claude/settings.json
```

Expected: `["Notification", "PostToolUse", "PostToolUseFailure", "SessionStart", "Stop"]` (plus any pre-existing events like `PreCompact`).

- [ ] **Step 4: Commit**

```bash
git add install.sh
git commit -m "feat: update install.sh to deploy all 6 hook scripts and merge settings"
```

---

## Task 9: Update README.md

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Replace README.md**

```markdown
# Claude Code Notification Hooks

Context-aware, comedic native OS notifications for Claude Code. Every event fires
a colored terminal banner + OS popup with emoji and sound. Messages include real
context — filename, command, duration, error — woven into a dry one-liner.

## Events covered

| Hook | Event | Emoji | Color | Sound |
|------|-------|-------|-------|-------|
| `on-stop.sh` | Claude finishes | 🎉 | Green | Glass |
| `on-notification.sh` | Claude needs input | 👀 | Yellow | Ping |
| `on-bash.sh` | Shell command ran | ⚡ | Cyan | Tink |
| `on-file.sh` | File written/edited | 📝 | Magenta | Pop |
| `on-error.sh` | Tool failure | 💀 | Red | Basso |
| `on-session-start.sh` | New session | 🤖 | Blue | Hero |

## Terminal banner

Every notification also prints a colored box in the Claude terminal:

```
╔══════════════════════════════════════════════════╗
║ 🎉  Claude finished                              ║
║  Done in 1m 12s. You may now pretend you did it. ║
╚══════════════════════════════════════════════════╝
```

## Requirements

- [Claude Code](https://claude.ai/code)
- `jq` — for JSON parsing and settings.json merging
  - macOS: `brew install jq`
  - Linux: `sudo apt install jq`
- macOS: works out of the box (`osascript`, `afplay`)
- Linux: requires `libnotify` (`sudo apt install libnotify-bin`) and `pulseaudio-utils`
- Windows (Git Bash / MSYS2): hooks detect and skip gracefully unless you add a `notify.ps1` helper

## Install

```bash
git clone https://github.com/yourname/claude-notifications.git
cd claude-notifications
bash install.sh
```

Then open `/hooks` in Claude Code or restart the app to activate.

## Uninstall

```bash
rm ~/.claude/hooks/notify.sh
rm ~/.claude/hooks/on-*.sh
```

Then open `~/.claude/settings.json` and delete the `Stop`, `Notification`,
`SessionStart`, `PostToolUseFailure`, and the Bash/Write|Edit entries under
`PostToolUse` from the `hooks` object.

## Customizing messages

Each `on-*.sh` script has a `MESSAGES=(...)` array at the top. Edit freely —
one entry is picked at random each time the hook fires.

## How it works

`notify.sh` is the shared display helper. Each `on-*.sh` script:
1. Reads the JSON Claude Code sends on stdin
2. Extracts relevant context (filename, command, duration, error snippet)
3. Picks a random message and inserts the context
4. Calls `notify.sh` with emoji, title, body, color, and sound arguments

`install.sh` copies all scripts to `~/.claude/hooks/` and safely merges the
hook entries into `~/.claude/settings.json` without touching unrelated config.
```

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: update README for enhanced 6-event hook system"
```

---

## Task 10: End-to-end smoke test

- [ ] **Step 1: Run all event scripts in sequence and verify all exit 0**

```bash
echo "--- session-start ---"
echo '{}' | bash hooks/on-session-start.sh; echo "exit: $?"

echo "--- stop ---"
echo $(($(date +%s) - 90)) > "$HOME/.claude/session-start"
echo '{}' | bash hooks/on-stop.sh; echo "exit: $?"

echo "--- notification ---"
echo '{"message":"Should I delete the production database?"}' | bash hooks/on-notification.sh; echo "exit: $?"

echo "--- bash ---"
echo '{"tool_name":"Bash","tool_input":{"command":"npm run build"}}' | bash hooks/on-bash.sh; echo "exit: $?"

echo "--- file (write) ---"
echo '{"tool_name":"Write","tool_input":{"file_path":"/project/src/index.ts"}}' | bash hooks/on-file.sh; echo "exit: $?"

echo "--- file (edit) ---"
echo '{"tool_name":"Edit","tool_input":{"file_path":"/project/src/auth.ts"}}' | bash hooks/on-file.sh; echo "exit: $?"

echo "--- error ---"
echo '{"tool_name":"Bash","tool_response":"npm: command not found"}' | bash hooks/on-error.sh; echo "exit: $?"
```

Expected: 7 colored banners in the terminal (blue, green, yellow, cyan, magenta, magenta, red), OS popups, sounds, all exit 0.

- [ ] **Step 2: Verify settings.json is still valid after install**

```bash
jq empty ~/.claude/settings.json && echo "JSON valid"
jq '.hooks | keys' ~/.claude/settings.json
```

Expected: `JSON valid` + key list includes all 5 event names.

- [ ] **Step 3: Final commit**

```bash
git add -A
git status  # confirm nothing unexpected is staged
git commit -m "chore: verified all 6 hooks fire correctly end-to-end"
```
