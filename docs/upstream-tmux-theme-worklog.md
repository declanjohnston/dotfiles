# Upstream tmux / theme / pills — iteration worklog

Companion to `docs/upstream-review-2026-04.md`. Focused on the **pills + tmux status scripts** subset (items #5 and #6 of that doc's Top Picks table) because (a) it's the area the user is opinionated about, (b) this fork is ~80% there already, and (c) iterating means implementing and reverting repeatedly.

Authored 2026-04-13.

---

## Current state of this fork (baseline — verify before changing)

- **Theme:** Catppuccin Mocha via plugin `catppuccin/tmux#v2.1.3` (`tmux/.tmux.conf:208`)
- **Theme variables:** sourced from `~/dotfiles/theme/generated/tmux-colors.conf` (`.tmux.conf:13`) — exposes `@thm_*`
- **Pills (status-right):** flowing single-tone powerline pills with rounded caps `` / ``
  - Order: directory (lavender) → cpu (peach) → ram (teal) → load (green) → network (sapphire) → battery (separate) → gpu (yellow, conditional on nvidia-smi)
  - Icons: Material Design nerd-font (`󰘚 󰍛 󰾥 󰖩 󰢮`)
  - Definition: `.tmux.conf:247-285`
- **Session pill:** stock catppuccin (static). `update_session_status.sh` currently reshuffles pane borders for the `agents` session.
- **Agents session widgets:** `agents_status_vscode.sh` (Claude usage pills, hardcoded Macchiato colors)
- **Prefix:** `C-a` (`.tmux.conf:9`) — **do not change**
- **Clipboard:** OSC 52 (`.tmux.conf:88-89`) — **do not change**

### Status scripts inventory

Already present in `tmux/scripts/`:
`battery_status.sh`, `cpu_status.sh`, `ram_status.sh`, `gpu_status.sh`, `load_status.sh`,
`network_status.sh`, `claude_code_status.sh`, `agents_count.sh`, `agents_cache_refresh.sh`,
`agents_status_vscode.sh`, `update_session_status.sh`, `pm2_status.sh`, `pm2_status_wrapper.sh`,
`utils.sh`, `dracula.sh` (+ `backup/{catppuccin,dracula}.sh`)

Already present in `tools/`: `copy-last-output`

---

## Known rough edges in current config (independent of upstream)

1. **Duplicate status-right branches** — `.tmux.conf:247-262` (local) and `.tmux.conf:264-280` (SSH) are byte-for-byte identical. Collapse to one.
2. **Static session pill** — no visual feedback for prefix-press or copy-mode.
3. **Stale `agents_cache_refresh.sh`** — no error handling, no opus/sonnet fields, 60s TTL, no Linux credentials fallback. See diff vs upstream in "Upgrades" below.

---

## Upstream deltas worth trying

### A. Theme / pill styling (5 items)

| # | What | Source | LoC | Risk |
|---|---|---|---|---|
| A1 | Dynamic session pill (orange default / green on prefix / blue in copy-mode) via sed-patching `status-format[0]` | `upstream:tmux/scripts/update_session_status.sh` (commit `ea58cff`) | ~15 | Low — isolated to `update_session_status.sh` |
| A2 | Crab icon 🦀 replacing session icon when in the `agents` session | same file | 2 | Low |
| A3 | Two-tone pill rendering (lighter outer cap holding icon + accent inner holding value) | `upstream:tmux/scripts/agents_status_bar.sh` lines 42-53 | ~12 | Medium — different visual style than current single-tone. Try on agents session only first. |
| A4 | Vibrant mocha variant: `ok-base` gray `#45475a` → blue `#89b4fa` | `upstream:tmux/catppuccin-mocha-vibrant.sh` | 1 line | Trivial — edit `theme/generated/tmux-colors.conf` |
| A5 | Claude-metric nerd-font icon set (clock, calendar, brain, lightning, package, timer-sand) | `upstream:tmux/scripts/agents_status_bar.sh:15-20` | 6 glyphs | Low, cosmetic |

### B. New scripts worth porting

| # | What | Source | LoC | Notes |
|---|---|---|---|---|
| B1 | `ssh_status.sh` — `<client-ip> <ping-ms>ms`, auto-hides off-SSH | `upstream:tmux/scripts/ssh_status.sh` | 24 | Drop-in |
| B2 | `pk_claude_metric.sh` — plain-text single-metric reader (`pk_claude_metric.sh opus` → `42`) | `upstream:tmux/scripts/pk_claude_metric.sh` | 52 | Replaces inline jq parsing in `agents_status_vscode.sh` |
| B3 | `tools/check_limits.py` — hits `api.anthropic.com/account/usage` (primary data source for all Claude usage widgets) | `upstream:tools/check_limits.py` | 126 | Needs `ANTHROPIC_API_KEY` or existing OAuth creds |
| B4 | `agents_status_bar.sh` — upstream's replacement for `agents_status_vscode.sh` with opus/sonnet/credits/reset pills + two-tone rendering | `upstream:tmux/scripts/agents_status_bar.sh` | 60 | Renamed via `ea58cff`. Only adopt alongside A1/A3. |
| B5 | `weather_status.sh` — wttr.in, 30-min cache | `upstream:tmux/scripts/weather_status.sh` | 26 | Optional fluff |

### C. In-place upgrades (same filename, better content)

| # | What | Diff against upstream |
|---|---|---|
| C1 | `tmux/scripts/agents_cache_refresh.sh` | Add `EMPTY_CACHE` constant, Linux credentials fallback (`~/.claude/.credentials.json`), API-error handling (keep last-good cache instead of zeroing), new `opus`/`sonnet` fields from `.seven_day_opus.utilization` / `.seven_day_sonnet.utilization`, TTL 60s→120s |
| C2 | `tmux/scripts/update_session_status.sh` | Whole new approach (sed-patch `status-format[0]`). Requires adopting A1+A2+B4 together or none at all. |

---

## Suggested iteration order

Low-friction wins first. Each step is revertable as a single commit.

1. **Dedupe `.tmux.conf:247-280`** — not upstream-related, just housekeeping.
2. **C1: refresh `agents_cache_refresh.sh`** — pure bugfix + new data, no visual change. Test by `cat /tmp/claude_usage_cache.json`.
3. **B3: add `check_limits.py`** — standalone tool, no tmux impact. Verify it fetches.
4. **A4: flip `ok-base` to blue** — 1-line edit. If you like it, keep.
5. **A1+A2: dynamic session pill + crab icon** — replace `update_session_status.sh` body. Highest-value visual upgrade, contained.
6. **B1: `ssh_status.sh`** — add pill to status-right conditional on `$SSH_CLIENT`. No-op locally.
7. **(Experimental) A3/A5/B2/B4/C2: two-tone pills for agents session only** — biggest visual departure. Best done on a branch you can revert wholesale.
8. **Skip:** B5 (weather) unless you want it.

Commands per step:

```bash
# Before each step
git checkout -b tmux/<step-name>

# Port the file(s)
git show upstream/main:<path> > <path>
# or hand-merge for C1/C2

# Reload & test
tmux source-file ~/.tmux.conf
# Click around: prefix, copy-mode (prefix+[), open agents session (F11), ssh in, etc.

# If good: commit and merge
git commit -am "<subject>"; git checkout main; git merge --ff-only tmux/<step-name>

# If bad: nuke and move on
git checkout main; git branch -D tmux/<step-name>
```

---

## Orientation commands (for a fresh agent picking this up)

```bash
# Confirm upstream remote exists
git remote -v | grep upstream || git remote add upstream https://github.com/vmasrani/dotfiles.git
git fetch upstream

# Inspect any upstream file without checking it out
git show upstream/main:<path>

# Diff your version against upstream's
diff tmux/scripts/<file> <(git show upstream/main:tmux/scripts/<file>)

# Reload tmux config without restart
tmux source-file ~/.tmux.conf
```

Key upstream commits referenced here:
- `ea58cff` — replace `agents_status_vscode` with status-format injection approach
- `8dae886` — fix agents session pill to respond to prefix key color change
- `99cbef2` — fix agents session usage widgets lost on tmux config reload
- `0d9acfe` — fix usage widgets showing 0% when API is rate-limited
- `781d135` — add credits label to usage widget pill
- `e79ab6c` — switch tmux status bar to powerkit with hex accent colors

---

## Known issues — circle back

- **Yank broken inside the F11 agents session popup.** Known nested-tmux + OSC 52 passthrough quirk. tmux has `set-clipboard on` and `allow-passthrough` at the outer layer, but `display-popup -E "tmux attach-session -t agents"` creates a nested client that may not propagate OSC 52 through the popup. Investigate: iTerm2's "Applications in terminal may access clipboard", explicit `copy-pipe` target that wraps OSC 52 manually, or switching the F11 binding from `attach-session` to `switch-client -t agents` (loses popup framing but avoids nesting).

## Worklog (append as you iterate)

Format: `YYYY-MM-DD | step-id | outcome | notes`

```
2026-04-13 | (initial doc)   | —       | baseline captured; no changes applied yet
2026-04-14 | A1              | skipped | doesn't apply — existing pill already dynamic (green default / red prefix); upstream path is powerkit migration, not a small tweak
2026-04-14 | A4              | skipped | no clean translation; upstream `ok-base` is a semantic from their own theme abstraction, this fork uses raw `@thm_*` tokens
2026-04-14 | A3 (two-tone)   | KEPT    | applied hand-rolled (not powerkit) to local+SSH status-right pills; kept catppuccin plugin. Lighter shades computed as 25% white-mix. Battery stays single-tone (dynamic color).
2026-04-14 | dedupe+drop dir | KEPT    | dropped the directory pill (redundant, shown elsewhere) while we were in there; CPU now starts the flow via `set -g`. SSH/local branches still duplicated but simpler now.
2026-04-14 | C1              | KEPT    | agents_cache_refresh.sh upgraded wholesale from upstream: TTL 60→120s, Linux ~/.claude/.credentials.json fallback (critical — macOS-only keychain was silently failing on CoreWeave, pills were all green-zeros), API-error handling (touch cache instead of overwriting with zeros), new opus/sonnet fields, credits formula uses API's pre-computed utilization.
2026-04-14 | B2              | KEPT    | imported pk_claude_metric.sh from upstream. Linux-adjusted: added plain `date -d` as first branch before the macOS-only `gdate`/`date -j -f` fallbacks so the `reset` metric works on CoreWeave.
2026-04-14 | B4              | KEPT    | added agents_status_bar.sh (6 two-tone pills: 5h, 7d, opus, sonnet, credits, reset) replacing agents_status_vscode.sh reference in update_session_status.sh. Fixed Macchiato→Mocha base color bug (#24273a→#181825). Old renderer preserved as agents_status_vscode.sh for easy revert.
```

When you try a step, append a line. If you revert, note the reason so next-time-you doesn't re-try the same failed approach.
