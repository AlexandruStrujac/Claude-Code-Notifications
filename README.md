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
