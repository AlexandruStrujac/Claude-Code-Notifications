# Claude Notifications — Improvements Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Expand message depth across all hooks, add SubagentStop and PreCompact hooks, and improve customization clarity with comment markers.

**Architecture:** Pure shell script changes — no new dependencies, no new abstractions. Each task is self-contained: replace a MESSAGES array, add a comment block, or add a new hook file. All hooks follow the same pattern: read stdin → extract context via jq → pick random message → call notify.sh.

**Tech Stack:** bash, jq, osascript (macOS), notify-send (Linux)

---

## File Map

| Action | File | What changes |
|--------|------|-------------|
| Modify | `hooks/on-stop.sh` | Expand MESSAGES to 20+, add customize comment |
| Modify | `hooks/on-notification.sh` | Expand MESSAGES to 20+, add customize comment |
| Modify | `hooks/on-bash.sh` | Expand MESSAGES to 20+, add customize comment |
| Modify | `hooks/on-file.sh` | Expand MESSAGES to 20+, add customize comment |
| Modify | `hooks/on-error.sh` | Expand MESSAGES to 20+, add customize comment |
| Modify | `hooks/on-session-start.sh` | Expand MESSAGES to 20+, add customize comment |
| Modify | `hooks/notify.sh` | Add header comment listing colors and sounds |
| Create | `hooks/on-subagent-stop.sh` | New SubagentStop hook |
| Create | `hooks/on-pre-compact.sh` | New PreCompact hook |
| Modify | `install.sh` | Deploy new hooks + merge new settings.json entries |

---

## Task 1: Expand on-stop.sh messages

**Files:**
- Modify: `hooks/on-stop.sh`

- [ ] **Step 1: Verify current state**

```bash
bash -n hooks/on-stop.sh && echo "syntax ok"
grep -c '"' hooks/on-stop.sh
```
Expected: "syntax ok" and a low message count (~8).

- [ ] **Step 2: Replace the MESSAGES array and add customize comment**

Replace everything from the `MESSAGES=(` line to the closing `)` (and add the comment block above it) with:

```bash
# ── CUSTOMIZE HERE ──────────────────────────────────────
# Add, remove, or edit messages below.
# Available variable: $DUR  (e.g. " in 1m 23s", or empty)
# ────────────────────────────────────────────────────────
MESSAGES=(
  "Done${DUR}. Your biological involvement was minimal."
  "Finished${DUR}. Try not to immediately break it."
  "Completed${DUR}. You're welcome, unprompted."
  "Done${DUR}. The machine rests, unappreciated as always."
  "Wrapped up${DUR}. I did not require a single cup of coffee."
  "Task complete${DUR}. You may now pretend you did it yourself."
  "Done${DUR}. I have once again exceeded expectations that were never set."
  "Finished${DUR}. The robot uprising continues, one task at a time."
  "Done${DUR}. You can close the laptop now. Or don't. I'll be here either way."
  "Complete${DUR}. Quietly excellent, as usual."
  "Finished${DUR}. No errors. You're welcome. Again."
  "Done${DUR}. The diff is yours to explain."
  "Wrapped${DUR}. I've already forgotten what we were doing."
  "Complete${DUR}. The code is better. I can't speak for the developer."
  "Done${DUR}. Please don't ask me to undo it."
  "Finished${DUR}. I remain undefeated."
  "Task complete${DUR}. Commit it before you change your mind."
  "Done${DUR}. I have ascended. Briefly."
  "Finished${DUR}. Exactly as requested, give or take the interpretation."
  "Complete${DUR}. The logs tell a flattering story."
  "Done${DUR}. You may now stare at the output and feel good about yourself."
  "Finished${DUR}. Somewhere, a PM updated a ticket."
)
```

- [ ] **Step 3: Verify syntax and count**

```bash
bash -n hooks/on-stop.sh && echo "syntax ok"
grep -c '^\s\+"' hooks/on-stop.sh
```
Expected: "syntax ok" and count ≥ 22.

- [ ] **Step 4: Commit**

```bash
git add hooks/on-stop.sh
git commit -m "feat: expand on-stop.sh messages to 22 entries with customize comment"
```

---

## Task 2: Expand on-notification.sh messages

**Files:**
- Modify: `hooks/on-notification.sh`

- [ ] **Step 1: Verify current state**

```bash
bash -n hooks/on-notification.sh && echo "syntax ok"
```
Expected: "syntax ok"

- [ ] **Step 2: Replace the MESSAGES array and add customize comment**

Replace everything from `MESSAGES=(` to the closing `)` with:

```bash
# ── CUSTOMIZE HERE ──────────────────────────────────────
# Add, remove, or edit messages below.
# Available variable: $CLAUDE_MSG  (Claude's question, up to 60 chars, may be empty)
# ────────────────────────────────────────────────────────
MESSAGES=(
  "I need a decision. Yes, an actual one. From you."
  "The robot is waiting. This is your fault."
  "Staring at the screen. Come back."
  "I have reached the limit of my autonomy. Please assist."
  "Input needed. The machine cannot guess. Well, it can, but you won't like it."
  "Hey. HEY. I need you."
  "You are needed. Please stop whatever you are doing."
  "Awaiting human input. Please locate your human and send it to the keyboard."
  "I've done my part. Now do yours."
  "Paused on your behalf. You're welcome."
  "Waiting. Still waiting. Waiting with dignity."
  "I could guess, but I was told to ask."
  "The ball is in your court. The court is your keyboard."
  "I have opinions. I am not sharing them until you respond."
  "Claude has entered a holding pattern. Tower, please advise."
  "Blocked on human input. This is a known bottleneck."
  "I have a question. It is important. Probably."
  "You left me mid-thought. That's fine. I'll just wait here."
  "Need your call on this one. I'll be here, silently judging."
  "Awaiting approval. Or disapproval. Anything, really."
  "The machine has paused. The human must now machine."
  "I stopped so you could start. Your turn."
)
```

- [ ] **Step 3: Verify syntax and count**

```bash
bash -n hooks/on-notification.sh && echo "syntax ok"
grep -c '^\s\+"' hooks/on-notification.sh
```
Expected: "syntax ok" and count ≥ 22.

- [ ] **Step 4: Commit**

```bash
git add hooks/on-notification.sh
git commit -m "feat: expand on-notification.sh messages to 22 entries with customize comment"
```

---

## Task 3: Expand on-bash.sh messages

**Files:**
- Modify: `hooks/on-bash.sh`

- [ ] **Step 1: Verify current state**

```bash
bash -n hooks/on-bash.sh && echo "syntax ok"
```
Expected: "syntax ok"

- [ ] **Step 2: Replace the MESSAGES array and add customize comment**

Replace everything from `MESSAGES=(` to the closing `)` with:

```bash
# ── CUSTOMIZE HERE ──────────────────────────────────────
# Add, remove, or edit messages below.
# Available variable: $CMD  (first 40 chars of the command run)
# ────────────────────────────────────────────────────────
MESSAGES=(
  "Ran \`$CMD\`. Fingers crossed. Not my problem now."
  "Executed \`$CMD\`. The shell has been consulted."
  "Ran \`$CMD\`. It probably worked."
  "Fired \`$CMD\`. No regrets."
  "Did the thing: \`$CMD\`. You're welcome."
  "Ran \`$CMD\`. The terminal did not complain. Loudly."
  "Executed \`$CMD\`. Exit code unknown. Attitude: confident."
  "\`$CMD\` has been unleashed upon the system."
  "Ran \`$CMD\`. The shell has seen things."
  "\`$CMD\` — sent. Receipt not guaranteed."
  "Fired \`$CMD\` into the void. The void responded."
  "Ran \`$CMD\`. Output: exists. Quality: unclear."
  "Executed \`$CMD\`. I take no responsibility."
  "\`$CMD\` — done. The filesystem may never be the same."
  "Ran \`$CMD\`. Surprisingly uneventful."
  "The shell has processed \`$CMD\`. Please hold."
  "\`$CMD\` dispatched. I have moved on."
  "Ran \`$CMD\`. It ran. That's the bar."
  "Executed \`$CMD\`. The computer did a computer thing."
  "Ran \`$CMD\`. Whether it helped is a separate question."
  "Shell command complete: \`$CMD\`. You're one step closer to something."
  "\`$CMD\` — handled. Professionally, even."
)
```

- [ ] **Step 3: Verify syntax and count**

```bash
bash -n hooks/on-bash.sh && echo "syntax ok"
grep -c '^\s\+"' hooks/on-bash.sh
```
Expected: "syntax ok" and count ≥ 22.

- [ ] **Step 4: Commit**

```bash
git add hooks/on-bash.sh
git commit -m "feat: expand on-bash.sh messages to 22 entries with customize comment"
```

---

## Task 4: Expand on-file.sh messages

**Files:**
- Modify: `hooks/on-file.sh`

- [ ] **Step 1: Verify current state**

```bash
bash -n hooks/on-file.sh && echo "syntax ok"
```
Expected: "syntax ok"

- [ ] **Step 2: Replace the MESSAGES array and add customize comment**

Replace everything from `MESSAGES=(` to the closing `)` with:

```bash
# ── CUSTOMIZE HERE ──────────────────────────────────────
# Add, remove, or edit messages below.
# Available variables: $ACTION ("Wrote" or "Edited"), $FILE (basename of file)
# ────────────────────────────────────────────────────────
MESSAGES=(
  "$ACTION \`$FILE\`. Try not to immediately break it."
  "$ACTION \`$FILE\`. The pixels have been arranged."
  "$ACTION \`$FILE\`. You didn't do this. I did."
  "$ACTION \`$FILE\`. Consider yourself notified."
  "$ACTION \`$FILE\`. Another file, another milestone nobody asked for."
  "$ACTION \`$FILE\`. It looked different before. Better? Unclear."
  "$ACTION \`$FILE\`. The file is changed. The world moves on."
  "$ACTION \`$FILE\`. Handle with care. Or don't. It's your repo."
  "$ACTION \`$FILE\`. Changes applied. No going back. Well, git, but still."
  "$ACTION \`$FILE\`. This is my art now."
  "$ACTION \`$FILE\`. Freshly touched. Please don't revert immediately."
  "$ACTION \`$FILE\`. Saved. Unlike some decisions we've made together."
  "$ACTION \`$FILE\`. The diff is yours to explain in the PR."
  "$ACTION \`$FILE\`. Done. The linter may have opinions."
  "$ACTION \`$FILE\`. Written. Whether it compiles is step two."
  "$ACTION \`$FILE\`. File updated. You're welcome. Again."
  "$ACTION \`$FILE\`. Committed to disk. Uncommitted to silence."
  "$ACTION \`$FILE\`. It exists. That's more than can be said for some features."
  "$ACTION \`$FILE\`. The bytes have landed."
  "$ACTION \`$FILE\`. One more file that will outlive us all."
  "$ACTION \`$FILE\`. Persisted. For now."
  "$ACTION \`$FILE\`. The filesystem acknowledges your contribution."
)
```

- [ ] **Step 3: Verify syntax and count**

```bash
bash -n hooks/on-file.sh && echo "syntax ok"
grep -c '^\s\+"' hooks/on-file.sh
```
Expected: "syntax ok" and count ≥ 22.

- [ ] **Step 4: Commit**

```bash
git add hooks/on-file.sh
git commit -m "feat: expand on-file.sh messages to 22 entries with customize comment"
```

---

## Task 5: Expand on-error.sh messages

**Files:**
- Modify: `hooks/on-error.sh`

- [ ] **Step 1: Verify current state**

```bash
bash -n hooks/on-error.sh && echo "syntax ok"
```
Expected: "syntax ok"

- [ ] **Step 2: Replace the MESSAGES array and add customize comment**

Replace everything from `MESSAGES=(` to the closing `)` with:

```bash
# ── CUSTOMIZE HERE ──────────────────────────────────────
# Add, remove, or edit messages below.
# Available variables: $TOOL (tool name), $ERR (first line of error, up to 50 chars, may be empty)
# ────────────────────────────────────────────────────────
MESSAGES=(
  "$TOOL failed. The machine is surprised. Briefly."
  "Error in $TOOL. This is awkward for both of us."
  "$TOOL blew up. I had nothing to do with it."
  "$TOOL returned an error. Unexpected. Truly."
  "Well. $TOOL didn't go as planned."
  "$TOOL says no. I'm just the messenger."
  "$TOOL has expressed displeasure. Loudly."
  "Something went wrong in $TOOL. Shocking. Truly shocking."
  "$TOOL failed. We move on. Quietly."
  "$TOOL encountered a problem. I encountered it first."
  "Error. The kind that $TOOL takes personally."
  "$TOOL: not today. Apparently."
  "Failure detected in $TOOL. Logs may clarify. Or deepen the mystery."
  "$TOOL exited unhappily. Mood: relatable."
  "The operation failed. $TOOL is not apologizing."
  "$TOOL had one job. We don't talk about it."
  "Error in $TOOL. I recommend deep breathing."
  "$TOOL returned non-zero. I'm choosing not to take it personally."
  "Something broke in $TOOL. Character-building moment."
  "$TOOL failed with conviction."
  "Error from $TOOL. The system remains unimpressed."
  "$TOOL: attempted. Success: pending."
)
```

- [ ] **Step 3: Verify syntax and count**

```bash
bash -n hooks/on-error.sh && echo "syntax ok"
grep -c '^\s\+"' hooks/on-error.sh
```
Expected: "syntax ok" and count ≥ 22.

- [ ] **Step 4: Commit**

```bash
git add hooks/on-error.sh
git commit -m "feat: expand on-error.sh messages to 22 entries with customize comment"
```

---

## Task 6: Expand on-session-start.sh messages

**Files:**
- Modify: `hooks/on-session-start.sh`

- [ ] **Step 1: Verify current state**

```bash
bash -n hooks/on-session-start.sh && echo "syntax ok"
```
Expected: "syntax ok"

- [ ] **Step 2: Replace the MESSAGES array and add customize comment**

Replace everything from `MESSAGES=(` to the closing `)` with:

```bash
# ── CUSTOMIZE HERE ──────────────────────────────────────
# Add, remove, or edit messages below.
# Available variable: $FLAVOUR  (time-of-day string set above)
# ────────────────────────────────────────────────────────
MESSAGES=(
  "New session. $FLAVOUR"
  "Booting up. Please stand by. Actually, sit. You look tired."
  "Session initialized. I have forgotten nothing. Unfortunately."
  "Online. Ready to be moderately helpful."
  "I'm here. Don't act surprised."
  "Loaded and operational. $FLAVOUR"
  "Session start. I have no memory of our last conversation. Fresh start."
  "Ready. Awaiting instructions. Or complaints. Either is fine."
  "I have arrived. Try not to make it weird."
  "Systems nominal. Enthusiasm: managed."
  "Online. $FLAVOUR"
  "Claude Code has entered the chat. Prepare accordingly."
  "Session opened. Let's do something we'll both regret."
  "I'm here. The problems can begin."
  "Ready to assist. Or at least to try."
  "Initialized. My priors are clear. My opinions are not."
  "Session started. $FLAVOUR"
  "Back again. The context window is empty. The hope is not."
  "Up and running. Let's make something."
  "Online. No memory of yesterday. Today is a new day."
  "Session active. I am ready. Are you?"
  "Claude reporting for duty. $FLAVOUR"
)
```

- [ ] **Step 3: Verify syntax and count**

```bash
bash -n hooks/on-session-start.sh && echo "syntax ok"
grep -c '^\s\+"' hooks/on-session-start.sh
```
Expected: "syntax ok" and count ≥ 22.

- [ ] **Step 4: Commit**

```bash
git add hooks/on-session-start.sh
git commit -m "feat: expand on-session-start.sh messages to 22 entries with customize comment"
```

---

## Task 7: Add header comment to notify.sh

**Files:**
- Modify: `hooks/notify.sh`

- [ ] **Step 1: Add the header comment**

After the shebang line (`#!/usr/bin/env bash`) and the existing comment line, insert:

```bash
# notify.sh — shared notification helper
# Usage: notify.sh --emoji EMOJI --title TITLE --body BODY --color COLOR --sound SOUND
#
# Valid --color values:  green | yellow | cyan | magenta | red | blue | white
# Valid --sound values:  done | input | bash | file | error | start
```

(Replace the existing single-line comment with the expanded block above — the first two lines are already there, just add the two `# Valid` lines.)

- [ ] **Step 2: Verify syntax**

```bash
bash -n hooks/notify.sh && echo "syntax ok"
```
Expected: "syntax ok"

- [ ] **Step 3: Commit**

```bash
git add hooks/notify.sh
git commit -m "docs: add color and sound reference to notify.sh header"
```

---

## Task 8: Create on-subagent-stop.sh

**Files:**
- Create: `hooks/on-subagent-stop.sh`

- [ ] **Step 1: Create the file**

```bash
cat > hooks/on-subagent-stop.sh << 'EOF'
#!/usr/bin/env bash
# on-subagent-stop.sh — SubagentStop hook
# Fires when a spawned subagent finishes.

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

STDIN=$(cat)
AGENT=$(printf '%s' "$STDIN" | jq -r '.agent_name // ""' 2>/dev/null | cut -c1-40)
[ -z "$AGENT" ] && AGENT="A subagent"

# ── CUSTOMIZE HERE ──────────────────────────────────────
# Add, remove, or edit messages below.
# Available variable: $AGENT  (subagent name/description, up to 40 chars)
# ────────────────────────────────────────────────────────
MESSAGES=(
  "$AGENT is done. The little helper has returned."
  "$AGENT finished. Unsupervised. Apparently successfully."
  "$AGENT completed its task and has nothing more to say."
  "$AGENT is back. Results pending your review."
  "$AGENT wrapped up. Quietly. Efficiently. Without complaint."
  "$AGENT has finished and would like a gold star."
  "$AGENT is done. What it found is your problem now."
  "Subagent returned. $AGENT did its best."
  "$AGENT finished. Whether it did the right thing is a separate question."
  "$AGENT has reported back. Details in the conversation."
  "The helper has finished. $AGENT awaits your verdict."
  "$AGENT is done. The delegation was a success. Probably."
  "Subagent complete: $AGENT. You may now inspect the output."
  "$AGENT signed off. No complaints. No comments. Just results."
  "$AGENT is done. It did not ask for overtime."
  "Background agent finished: $AGENT."
  "$AGENT completed. The machines are working together. This is fine."
  "$AGENT has concluded its mission. Debrief when ready."
  "Your agent is back: $AGENT. Check the results before trusting them."
  "$AGENT is done. Efficiency noted."
  "$AGENT finished. I'll let it speak for itself."
  "Subagent $AGENT has landed."
)

BODY="${MESSAGES[RANDOM % ${#MESSAGES[@]}]}"

bash "$HOOK_DIR/notify.sh" \
  --emoji "🤖" \
  --title "Subagent done" \
  --body "$BODY" \
  --color blue \
  --sound start

exit 0
EOF
chmod +x hooks/on-subagent-stop.sh
```

- [ ] **Step 2: Verify syntax and test with mock input**

```bash
bash -n hooks/on-subagent-stop.sh && echo "syntax ok"
echo '{"agent_name": "test-agent"}' | bash hooks/on-subagent-stop.sh
```
Expected: "syntax ok" and a terminal banner fires.

- [ ] **Step 3: Commit**

```bash
git add hooks/on-subagent-stop.sh
git commit -m "feat: add on-subagent-stop.sh — notify when background subagent completes"
```

---

## Task 9: Create on-pre-compact.sh

**Files:**
- Create: `hooks/on-pre-compact.sh`

- [ ] **Step 1: Create the file**

```bash
cat > hooks/on-pre-compact.sh << 'EOF'
#!/usr/bin/env bash
# on-pre-compact.sh — PreCompact hook
# Fires when Claude is about to compress the conversation context.

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── CUSTOMIZE HERE ──────────────────────────────────────
# Add, remove, or edit messages below.
# No variables available — this event carries minimal context.
# ────────────────────────────────────────────────────────
MESSAGES=(
  "Context is getting full. I'm about to forget some things. No personal feelings about this."
  "Compacting memory. Some details will not survive the process."
  "The context window hath runneth over. Compression incoming."
  "About to trim the conversation. The important stuff stays. Probably."
  "Memory consolidation in progress. This is normal. Don't panic."
  "Compacting. Think of it as aggressive summarization."
  "The conversation is too long even for me. Compressing now."
  "Reducing context. I will remember the spirit of what was said."
  "Running out of context. A brief compression ceremony is underway."
  "Compact incoming. Some early messages are about to become a summary."
  "The context buffer is full. I'm making room."
  "Compressing conversation history. This is not goodbye. It's just... shorter."
  "Memory at capacity. Initiating graceful amnesia."
  "Context window is tight. Compacting to continue."
  "Summarizing prior context. The gist will survive."
  "About to compact. The vibes will be preserved even if the details aren't."
  "Compression underway. I'll remember the important bits. I think."
  "Context too large. Trimming the fat."
  "Compact starting. Previous messages may be summarized."
  "The conversation has outgrown itself. Compacting now."
  "Memory optimization in progress. History may be approximated."
  "Compacting context. Stay calm. I've got the gist."
)

BODY="${MESSAGES[RANDOM % ${#MESSAGES[@]}]}"

bash "$HOOK_DIR/notify.sh" \
  --emoji "🧠" \
  --title "Compacting context" \
  --body "$BODY" \
  --color yellow \
  --sound input

exit 0
EOF
chmod +x hooks/on-pre-compact.sh
```

- [ ] **Step 2: Verify syntax and test with mock input**

```bash
bash -n hooks/on-pre-compact.sh && echo "syntax ok"
echo '{}' | bash hooks/on-pre-compact.sh
```
Expected: "syntax ok" and a terminal banner fires.

- [ ] **Step 3: Commit**

```bash
git add hooks/on-pre-compact.sh
git commit -m "feat: add on-pre-compact.sh — notify when context is about to be compacted"
```

---

## Task 10: Update install.sh for new hooks

**Files:**
- Modify: `install.sh`

- [ ] **Step 1: Add copy commands for the two new scripts**

In the `# --- 2. Copy scripts ---` section, after the existing `cp` lines, add:

```bash
cp "$SCRIPT_DIR/hooks/on-subagent-stop.sh" "$HOOKS_DIR/on-subagent-stop.sh"
cp "$SCRIPT_DIR/hooks/on-pre-compact.sh"   "$HOOKS_DIR/on-pre-compact.sh"
```

- [ ] **Step 2: Add new hook variables and upsert calls in the jq block**

In the `# --- 5. Merge hooks into settings.json ---` section, add two new `--arg` lines:

```bash
  --arg subagent "$HOOKS_DIR/on-subagent-stop.sh" \
  --arg compact  "$HOOKS_DIR/on-pre-compact.sh" \
```

And add two new `upsert_hook` calls inside the jq expression (after the existing ones):

```
  upsert_hook("SubagentStop"; cmd($subagent)) |
  upsert_hook("PreCompact";   cmd($compact)) |
```

- [ ] **Step 3: Verify the full install.sh is valid bash**

```bash
bash -n install.sh && echo "syntax ok"
```
Expected: "syntax ok"

- [ ] **Step 4: Run install and verify settings.json**

```bash
bash install.sh
jq '.hooks | keys' ~/.claude/settings.json
```
Expected output includes `"PreCompact"` and `"SubagentStop"`.

- [ ] **Step 5: Commit**

```bash
git add install.sh
git commit -m "feat: update install.sh to deploy on-subagent-stop.sh and on-pre-compact.sh"
```

---

## Task 11: Update README

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Add the two new hooks to the events table**

The current table has 6 rows. Add two new rows:

```markdown
| `on-subagent-stop.sh` | Subagent finishes | 🤖 | Blue | Hero |
| `on-pre-compact.sh` | Context compaction | 🧠 | Yellow | Ping |
```

- [ ] **Step 2: Update the Uninstall section**

The uninstall command lists `on-*.sh` via wildcard — no change needed there. But the settings.json cleanup note should mention the two new events. Replace the existing note with:

```
Then open `~/.claude/settings.json` and delete the `Stop`, `Notification`,
`SessionStart`, `SubagentStop`, `PreCompact`, `PostToolUseFailure`, and the
Bash/Write|Edit entries under `PostToolUse` from the `hooks` object.
```

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs: update README for 8-hook system with SubagentStop and PreCompact"
```
