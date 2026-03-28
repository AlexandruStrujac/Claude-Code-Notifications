# 🔔 Claude Code Notifications

> Native OS notifications and terminal banners for every [Claude Code](https://claude.ai/code) event — with personality.

![macOS](https://img.shields.io/badge/macOS-supported-brightgreen?logo=apple)
![Linux](https://img.shields.io/badge/Linux-supported-brightgreen?logo=linux)
![Shell](https://img.shields.io/badge/shell-bash-blue?logo=gnubash)
![License](https://img.shields.io/github/license/AlexandruStrujac/Claude-Code-Notifications)

Stop tabbing back to check if Claude is done. Get a popup, a sound, and a dry one-liner — every time something happens.

---

## What it looks like

Every event fires a **colored terminal banner** and a **native OS notification** with sound:

```
╔══════════════════════════════════════════════════╗
║ 🎉  Claude finished                              ║
║  Done in 1m 12s. You may now pretend you did it. ║
╚══════════════════════════════════════════════════╝
```

```
╔══════════════════════════════════════════════════╗
║ 📝  File changed                                 ║
║  Edited `App.tsx`. The diff is yours to explain. ║
╚══════════════════════════════════════════════════╝
```

```
╔══════════════════════════════════════════════════╗
║ 💀  Something broke                              ║
║  Read failed. File not found.                    ║
╚══════════════════════════════════════════════════╝
```

---

## Events covered

| Hook | Trigger | Emoji | Color | Sound |
|------|---------|-------|-------|-------|
| `on-session-start.sh` | New Claude Code session | 🤖 | Blue | Hero |
| `on-stop.sh` | Claude finishes a task | 🎉 | Green | Glass |
| `on-notification.sh` | Claude needs your input | 👀 | Yellow | Ping |
| `on-bash.sh` | Shell command executed | ⚡ | Cyan | Tink |
| `on-file.sh` | File written or edited | 📝 | Magenta | Pop |
| `on-error.sh` | Tool failure | 💀 | Red | Basso |
| `on-subagent-stop.sh` | Background subagent finished | 🤖 | Blue | Glass |
| `on-pre-compact.sh` | Context about to be compacted | 🧠 | Yellow | Ping |

Each notification includes **real context** — the filename, command, duration, or error — woven into a randomly picked dry one-liner from a pool of 22.

---

## Install

**Requires:** [Claude Code](https://claude.ai/code) and `jq`

```bash
# macOS
brew install jq

# Linux
sudo apt install jq
```

```bash
git clone https://github.com/AlexandruStrujac/Claude-Code-Notifications.git
cd Claude-Code-Notifications
bash install.sh
```

Then **restart Claude Code** to activate. That's it.

The installer:
- Copies all hook scripts to `~/.claude/hooks/`
- Merges hook entries into `~/.claude/settings.json` without touching your other settings
- Is safe to re-run — idempotent by design

---

## Platform support

| Platform | Notifications | Sound |
|----------|--------------|-------|
| macOS | `osascript` — works out of the box | `afplay` system sounds |
| Linux | `notify-send` — requires `libnotify-bin` | `paplay` — requires `pulseaudio-utils` |
| Windows (Git Bash / MSYS2) | Hooks skip gracefully unless you add a `notify.ps1` helper | — |

---

## Customizing messages

Every hook script has a clearly marked section at the top:

```bash
# ── CUSTOMIZE HERE ──────────────────────────────────────
# Add, remove, or edit messages below.
# Available variable: $CMD  (first 40 chars of the command run)
# ────────────────────────────────────────────────────────
MESSAGES=(
  "Ran \`$CMD\`. Fingers crossed. Not my problem now."
  "Executed \`$CMD\`. The shell has been consulted."
  ...
)
```

Edit any `on-*.sh` in `~/.claude/hooks/` — one message is picked at random each time the hook fires. Each hook documents which variables are available (e.g. `$CMD`, `$FILE`, `$TOOL`, `$DUR`).

---

## How it works

`notify.sh` is the shared display helper. Each `on-*.sh` hook:

1. Receives the JSON payload Claude Code sends on `stdin`
2. Extracts relevant context via `jq` (filename, command, duration, error snippet)
3. Picks a random message and inserts the context
4. Calls `notify.sh` with emoji, title, body, color, and sound

---

## Uninstall

```bash
rm ~/.claude/hooks/notify.sh
rm ~/.claude/hooks/on-*.sh
```

Then open `~/.claude/settings.json` and remove the `Stop`, `Notification`, `SessionStart`, `SubagentStop`, `PreCompact`, `PostToolUseFailure`, and `Bash`/`Write|Edit` entries from the `hooks` object.

---

## Contributing

Pull requests are welcome. If you write a great set of messages, open a PR — the funnier the better.
