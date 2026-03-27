# Claude Code Notification Hooks

Native OS notifications for Claude Code — one when Claude finishes a task, one when it needs your input. Includes sound. Includes sarcasm.

## What it does

| Hook | Event | Sound |
|------|-------|-------|
| **Claude finished** | Claude stops working | Glass (macOS) / complete (Linux) |
| **Claude needs you** | Claude is waiting for input | Ping (macOS) / bell (Linux) |

Messages are randomly picked from 10 dry, robot-flavored lines per hook.

## Requirements

- [Claude Code](https://claude.ai/code)
- `jq` — for merging into `settings.json`
  - macOS: `brew install jq`
  - Linux: `sudo apt install jq`
- macOS: notifications work out of the box via `osascript`
- Linux: requires `libnotify` (`sudo apt install libnotify-bin`)
- Windows (Git Bash / MSYS2): partially supported — see [Windows](#windows)

## Install

```bash
git clone https://github.com/yourname/claude-notifications.git
cd claude-notifications
bash install.sh
```

Then open `/hooks` in Claude Code or restart the app to activate.

## Uninstall

Remove the scripts:

```bash
rm ~/.claude/hooks/notify-done.sh ~/.claude/hooks/notify-input.sh
```

Then open `~/.claude/settings.json` and delete the `Stop` and `Notification` entries under `hooks`.

## Windows

The bash scripts detect Git Bash / MSYS2 and delegate to PowerShell helper scripts (`notify-done.ps1` / `notify-input.ps1`) if present. Those are not included here — the hooks will silently skip on Windows without them.

## Customizing messages

Edit the `DONE_MESSAGES` and `INPUT_MESSAGES` arrays at the top of each script in `~/.claude/hooks/`. One message is picked at random each time the hook fires.

## How it works

Two entries are added to `~/.claude/settings.json`:

```json
"hooks": {
  "Stop": [{
    "hooks": [{ "type": "command", "command": "~/.claude/hooks/notify-done.sh", "async": true }]
  }],
  "Notification": [{
    "hooks": [{ "type": "command", "command": "~/.claude/hooks/notify-input.sh", "async": true }]
  }]
}
```

Both run async so they never block Claude. The install script merges these with any existing hooks — it won't overwrite unrelated configuration.
