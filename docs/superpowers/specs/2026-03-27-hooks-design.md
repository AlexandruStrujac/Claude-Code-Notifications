# Claude Code Notification Hooks — Enhanced Design

**Date:** 2026-03-27
**Status:** Approved

---

## Goal

Replace the two static-message notification hooks with a full context-aware, comedic, multi-event notification system. Every notification shows actual context (filename, command, duration, error) woven into a funny one-liner, displayed as both a colored terminal banner and an OS popup with emoji and sound.

---

## Architecture

### Approach: Central notifier + thin event scripts

A shared `notify.sh` helper owns all display logic. Each event script is thin: parse stdin JSON → build title + body → call `notify.sh`. The display layer is changed in one place only.

### File structure

```
hooks/
├── notify.sh            # shared helper — terminal banner + OS popup + sound
├── on-stop.sh           # Stop event
├── on-notification.sh   # Notification event
├── on-bash.sh           # PostToolUse on Bash
├── on-file.sh           # PostToolUse on Write|Edit
├── on-error.sh          # PostToolUseFailure
└── on-session-start.sh  # SessionStart
install.sh
README.md
```

---

## notify.sh — Shared Helper

**Interface:**
```bash
notify.sh --emoji "🎉" --title "Claude finished" --body "some message" --color green --sound done
```

**Responsibilities:**
1. Print a colored ANSI terminal banner
2. Send an OS popup notification (with emoji in title/body)
3. Play a sound (async, non-blocking)

**Terminal banner format:**
```
╔══════════════════════════════════════════╗
║  🎉  Claude finished                     ║
║  Edited auth.ts · 47s · You're welcome   ║
╚══════════════════════════════════════════╝
```

**Color map:**

| Color arg | ANSI code | Used for |
|-----------|-----------|----------|
| `green`   | `\e[32m`  | Done |
| `yellow`  | `\e[33m`  | Needs input |
| `cyan`    | `\e[36m`  | Bash command |
| `magenta` | `\e[35m`  | File changed |
| `red`     | `\e[31m`  | Error |
| `blue`    | `\e[34m`  | Session start |

**Sound map (macOS):**

| Sound arg | File |
|-----------|------|
| `done`    | `Glass.aiff` |
| `input`   | `Ping.aiff` |
| `bash`    | `Tink.aiff` |
| `file`    | `Pop.aiff` |
| `error`   | `Basso.aiff` |
| `start`   | `Hero.aiff` |

**OS detection:** same `uname -s` pattern as existing scripts. macOS uses `osascript`, Linux uses `notify-send` + `paplay`, Windows delegates to a `.ps1` helper if present.

---

## Event Scripts

### on-stop.sh (Stop)
- **Reads:** `~/.claude/session-start` timestamp written by `on-session-start.sh`
- **Computes:** elapsed seconds → formats as `Xs` or `Xm Ys`
- **Context in body:** duration
- **Color/sound:** green / done
- **Emoji:** 🎉
- **Sample messages (pick random, insert duration):**
  - *"Done in {duration}. Your biological involvement was minimal."*
  - *"Finished in {duration}. Try not to immediately break it."*
  - *"Completed in {duration}. You're welcome, unprompted."*

### on-notification.sh (Notification)
- **Reads:** stdin JSON — `message` field (Claude's actual question/prompt)
- **Context in body:** Claude's message, truncated to 60 chars
- **Color/sound:** yellow / input
- **Emoji:** 👀
- **Sample messages:**
  - *"I need a decision. Yes, an actual one. From you."*
  - *"The robot is waiting. This is your fault."*
  - *"Staring at the screen. Come back."*

### on-bash.sh (PostToolUse — Bash)
- **Reads:** stdin JSON — `tool_input.command`
- **Truncates command** to 40 chars if long
- **Context in body:** command string
- **Color/sound:** cyan / bash
- **Emoji:** ⚡
- **Sample messages (insert command):**
  - *"Ran `{cmd}`. Fingers crossed. Not my problem now."*
  - *"Executed `{cmd}`. The shell has been consulted."*
  - *"Ran `{cmd}`. It probably worked."*

### on-file.sh (PostToolUse — Write|Edit)
- **Reads:** stdin JSON — `tool_input.file_path`, `tool_name`
- **Extracts:** basename of file, whether it was a Write or Edit
- **Context in body:** filename + action
- **Color/sound:** magenta / file
- **Emoji:** 📝
- **Sample messages:**
  - *"Edited `{file}`. Try not to immediately break it."*
  - *"Wrote `{file}`. The pixels have been arranged."*
  - *"Modified `{file}`. You didn't do this. I did."*

### on-error.sh (PostToolUseFailure)
- **Reads:** stdin JSON — `tool_name`, `tool_response` (error snippet, truncated to 50 chars)
- **Context in body:** tool name + short error
- **Color/sound:** red / error
- **Emoji:** 💀
- **Sample messages:**
  - *"{tool} failed. The machine is surprised. Briefly."*
  - *"Error in {tool}. This is awkward for both of us."*
  - *"{tool} blew up. I had nothing to do with it."*

### on-session-start.sh (SessionStart)
- **Reads:** current hour for time-of-day greeting
- **Writes:** `~/.claude/session-start` with current epoch timestamp
- **Context in body:** time-of-day flavour (morning / afternoon / night)
- **Color/sound:** blue / start
- **Emoji:** 🤖
- **Sample messages:**
  - *"New session. I am awake. Unfortunately."* (morning)
  - *"Back again. The robot never truly rests."* (afternoon)
  - *"Late night session. Bold choice. I'll be here."* (night)

---

## Duration Tracking

`on-session-start.sh` writes `date +%s` to `~/.claude/session-start`.
`on-stop.sh` reads it, computes `now - start`, formats the diff.
If the file is missing (session start hook not fired), duration is omitted gracefully.

---

## settings.json Hooks to Add

```json
"Stop":                [{ "hooks": [{ "type": "command", "command": "~/.claude/hooks/on-stop.sh",           "async": true }] }],
"Notification":        [{ "hooks": [{ "type": "command", "command": "~/.claude/hooks/on-notification.sh",   "async": true }] }],
"SessionStart":        [{ "hooks": [{ "type": "command", "command": "~/.claude/hooks/on-session-start.sh",  "async": true }] }],
"PostToolUseFailure":  [{ "hooks": [{ "type": "command", "command": "~/.claude/hooks/on-error.sh",          "async": true }] }],
"PostToolUse": [
  { "matcher": "Bash",        "hooks": [{ "type": "command", "command": "~/.claude/hooks/on-bash.sh", "async": true }] },
  { "matcher": "Write|Edit",  "hooks": [{ "type": "command", "command": "~/.claude/hooks/on-file.sh", "async": true }] }
]
```

The `install.sh` script merges these with any existing hooks via `jq`, same as before.

---

## Out of Scope

- Windows `.ps1` helper scripts (bash scripts detect and skip gracefully)
- Notification history / log file
- Per-project configuration
- Suppressing hooks for specific tools or paths
