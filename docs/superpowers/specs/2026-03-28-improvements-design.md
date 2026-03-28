# Claude Notifications — Improvements Design
**Date:** 2026-03-28
**Status:** Approved

---

## Goal

Make the project more valuable as both a personal daily-use tool and an open source-ready
distribution — without adding complexity. Three areas of improvement: message depth,
hook coverage, and customization clarity.

---

## 1. Message Expansion

**What:** Expand the `MESSAGES=(...)` array in all 6 existing hook scripts from ~5–8 entries
to 20+ per hook.

**Tone:** More varied — dry, absurd, self-aware — while always weaving in real context
(filename, command, duration, error snippet) via the variables already extracted in each script.

**Scope:** Content-only change. No structural edits to any existing script.

**Affected files:**
- `hooks/on-stop.sh`
- `hooks/on-notification.sh`
- `hooks/on-bash.sh`
- `hooks/on-file.sh`
- `hooks/on-error.sh`
- `hooks/on-session-start.sh`

---

## 2. New Hooks

### `on-subagent-stop.sh`
- **Event:** `SubagentStop`
- **Context extracted:** subagent identity/description if available in stdin JSON
- **Messages:** "your little helper is done" style, ~20 entries
- **Color:** Blue | **Sound:** Hero (mirrors session-start — agent lifecycle event)

### `on-pre-compact.sh`
- **Event:** `PreCompact`
- **Context extracted:** none required (event carries minimal data)
- **Messages:** Short punchy lines about memory loss / context compression, ~20 entries
- **Color:** Yellow | **Sound:** Ping (heads-up, not an error)

Both scripts follow the identical structure of existing hooks:
1. Read stdin
2. Extract context via `jq`
3. Pick `MESSAGES[RANDOM % ${#MESSAGES[@]}]`
4. Call `notify.sh` with emoji, title, body, color, sound

**`install.sh` changes:**
- Copy both new scripts to `~/.claude/hooks/`
- Merge `SubagentStop` and `PreCompact` entries into `~/.claude/settings.json`

---

## 3. Customization Clarity

**What:** Add a comment block to every `on-*.sh` script immediately above the `MESSAGES`
array, marking it as the customization zone and listing available variables.

**Format:**
```bash
# ── CUSTOMIZE HERE ──────────────────────────────────────
# Add, remove, or edit messages below.
# Each entry can use: $VAR1, $VAR2  (hook-specific)
# ────────────────────────────────────────────────────────
```

Each hook lists only the variables it actually extracts — no false affordances.

**`notify.sh` change:** Add a brief header comment listing all valid `--color` and `--sound`
values, so anyone wanting to tweak those knows the options without reading the case statement.

---

## Out of Scope

- Config file / CLI configurator
- Message packs / themes
- `PreToolUse` hook (too noisy for every tool call)
- Any changes to `notify.sh` display logic
