#!/usr/bin/env bash
# notify-input.sh — fires on Claude Code Notification event (needs human input)

INPUT_MESSAGES=(
  "Hey. HEY. I need you. The robot cannot proceed alone."
  "Your attention is required. Yes, actually required, not optional."
  "I have reached the limit of my autonomy. Please assist."
  "Staring at this screen waiting for you. No pressure. Just staring."
  "Input needed. The machine cannot guess. Well, it can, but you won't like it."
  "I am stuck and it is entirely your fault for not being here."
  "Awaiting human input. Please locate your human and send it to the keyboard."
  "I could guess what you want, but I have learned that never goes well."
  "Intervention required. This is not a drill. This is mildly inconvenient."
  "You are needed. Please stop whatever you are doing. Especially sleeping."
)

BODY="${INPUT_MESSAGES[RANDOM % ${#INPUT_MESSAGES[@]}]}"
TITLE="Claude needs you"

OS="$(uname -s)"

case "$OS" in
  Darwin)
    osascript -e "display notification \"$BODY\" with title \"$TITLE\"" 2>/dev/null
    afplay /System/Library/Sounds/Ping.aiff 2>/dev/null &
    ;;
  Linux)
    notify-send "$TITLE" "$BODY" 2>/dev/null
    paplay /usr/share/sounds/freedesktop/stereo/bell.oga 2>/dev/null || true
    ;;
  MINGW*|MSYS*|CYGWIN*)
    PS1_SCRIPT="$USERPROFILE/.claude/hooks/notify-input.ps1"
    if [ -f "$PS1_SCRIPT" ]; then
      powershell.exe -NonInteractive -File "$PS1_SCRIPT" "$BODY" 2>/dev/null
    fi
    ;;
esac

exit 0
