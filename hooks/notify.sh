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
  green)   CODE="\033[32m" ;;
  yellow)  CODE="\033[33m" ;;
  cyan)    CODE="\033[36m" ;;
  magenta) CODE="\033[35m" ;;
  red)     CODE="\033[31m" ;;
  blue)    CODE="\033[34m" ;;
  *)       CODE="\033[37m" ;;
esac
RESET="\033[0m"
BOLD="\033[1m"

# Terminal banner (50 chars wide)
BAR=$(printf '═%.0s' {1..48})
printf "${CODE}╔${BAR}╗${RESET}\n"
printf "${CODE}║${RESET} ${BOLD}%s  %-$((45 - ${#TITLE}))s${RESET}${CODE}║${RESET}\n" "$EMOJI" "$TITLE"
printf "${CODE}║${RESET}  %-46s${CODE}║${RESET}\n" "$BODY"
printf "${CODE}╚${BAR}╝${RESET}\n"

# OS notification + sound
OS="$(uname -s)"
case "$OS" in
  Darwin)
    SAFE_BODY=$(printf '%s' "$BODY"  | sed 's/\\/\\\\/g; s/"/\\"/g')
    SAFE_TITLE=$(printf '%s' "$TITLE" | sed 's/\\/\\\\/g; s/"/\\"/g')
    osascript -e "display notification \"$SAFE_BODY\" with title \"$EMOJI $SAFE_TITLE\"" 2>/dev/null
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
    NOTIFY_PS1="$USERPROFILE/.claude/hooks/notify.ps1"
    [ -f "$NOTIFY_PS1" ] && powershell.exe -NonInteractive -File "$NOTIFY_PS1" "$EMOJI $TITLE" "$BODY" 2>/dev/null
    ;;
esac

exit 0
