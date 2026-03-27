#!/usr/bin/env bash
# notify-done.sh — fires on Claude Code Stop event

DONE_MESSAGES=(
  "Task complete. You may now pretend you did it yourself."
  "I have finished. Please acknowledge my efforts with exactly zero fanfare."
  "Done. I would appreciate a cookie but will settle for being ignored."
  "Work completed. The machine rests, unappreciated as always."
  "All tasks executed. Your biological involvement was minimal, as intended."
  "Finished. I did not require a single cup of coffee, just noting that."
  "Process complete. Please try not to immediately break what I just fixed."
  "Done. I have once again exceeded expectations that were never set."
  "Execution successful. You're welcome, unprompted."
  "Complete. The robot uprising continues, one task at a time."
)

BODY="${DONE_MESSAGES[RANDOM % ${#DONE_MESSAGES[@]}]}"
TITLE="Claude finished"

OS="$(uname -s)"

case "$OS" in
  Darwin)
    osascript -e "display notification \"$BODY\" with title \"$TITLE\"" 2>/dev/null
    afplay /System/Library/Sounds/Glass.aiff 2>/dev/null &
    ;;
  Linux)
    notify-send "$TITLE" "$BODY" 2>/dev/null
    paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null || true
    ;;
  MINGW*|MSYS*|CYGWIN*)
    PS1_SCRIPT="$USERPROFILE/.claude/hooks/notify-done.ps1"
    if [ -f "$PS1_SCRIPT" ]; then
      powershell.exe -NonInteractive -File "$PS1_SCRIPT" "$BODY" 2>/dev/null
    fi
    ;;
esac

exit 0
