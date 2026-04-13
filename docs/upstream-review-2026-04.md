# Upstream Review: `vmasrani/dotfiles` — April 2026

Analysis of changes in the upstream repo (`vmasrani/dotfiles`) that have **not** been merged into this fork. Produced on 2026-04-13. Intended as a dig-in backlog for cherry-picking.

---

## Orientation for future agents

### Setup

The upstream remote must be added before any of the commands below work:

```bash
git remote add upstream https://github.com/vmasrani/dotfiles.git
git fetch upstream
```

(It was added during this review session — check `git remote -v` to confirm it's still there.)

### Sync boundary

- **Last upstream commit already in this fork:** `ce7111c` — "pkl preview" (2026-01-11)
- **Upstream HEAD at time of review:** `d050ab2` — "tweaks" (2026-04-05)
- The range `ce7111c..upstream/main` contains **86 non-merge commits / 189 changed files / +19,063 / −1,155 lines**.

All commit hashes in this doc refer to upstream. To inspect any of them:

```bash
git show <hash>                          # full diff
git show --stat <hash>                   # files touched
git log <hash> -1 --format=%B            # full commit message

# See the cumulative diff for a given path:
git diff ce7111c..upstream/main -- <path>

# Check whether this fork has independently modified that path:
git log main -- <path>
```

### Cherry-pick workflow

```bash
git cherry-pick <hash>
# on conflict:
#   - resolve manually
#   - git add <resolved>
#   - git cherry-pick --continue
# if it goes sideways:
#   - git cherry-pick --abort
#   - OR  git revert HEAD  (if already committed)
```

### Key divergence points in this fork (keep these intact)

| Concern | This fork | Upstream |
|---|---|---|
| Tmux prefix | `C-a` (see `tmux/.tmux.conf:9`) | default `C-b` |
| Clipboard | OSC 52 (commit `0670a57`) | `pbcopy`/`xclip` |
| Voicemode | removed (`0be8ac7`, `9feb41d`) | still referenced in places |
| Plugin install | custom flow (`f4d55ac`) | upstream's refactor may clobber |
| Hardcoded model | removed (`2ec426c`) | upstream may reintroduce in `settings.json` |
| CoreWeave/RunPod hardening | `c0b888f`, `f860836`, `5216d5e` | upstream is more macOS-focused |

---

## Functional area report

Each section: **What / Why / Mergeability / Recommendation**. "Mergeability" reflects risk of conflict with this fork's divergence.

### 1. Claude Code config overhaul — `maintained_global_claude/`

**What:** Massive expansion. New subdirs: `agents/` (8 agents), `commands/` (5 commands), `hooks/` (pre_compact.py). Skills multiplied. `settings.json` pivoted to broad `Read/Write/Edit/Bash` + skill/context7 plugins + LSP (pyright, rust-analyzer, typescript), with `defaultMode: "plan"` and `fastMode: true`.

**New agents:** `codebase-researcher`, `context-researcher`, `modern-translation`, `plan-writer`, `spec-interviewer`, `structural-completeness-reviewer`, `test-generator`, `vault-analyst` — see `maintained_global_claude/agents/*.md`.

**New commands:** `arewedone`, `generate-tests`, `process-parallel`, `research` — see `maintained_global_claude/commands/*.md`.

**New skills:** `create-plan`, `data-visualization-techniques`, `deploy`, `design-principles`, `dotfiles-tweaker`, `explain`, `gws` (Google Workspace), `homeassistant`, `log-to-daily`, `make-release-readme`, `media-manager`, `person-profiler`, `polish`, `record-gif`, `request` — see `maintained_global_claude/skills/*/SKILL.md`.

**Key commits:**
- `1bb3ac1` — initial bulk drop of agents/commands/hooks/skills (2026-01-28)
- `3076617`, `a52f373`, `b860e1c`, `ea7ff79`, `5f66d79` — skill additions
- `d971d0f` — changed plan mode default
- `08e50cb` — enable LSP plugins + strengthen progressive disclosure defaults (2026-04-05)
- `48c068d` — settings
- `d9e1589` — overhaul progressive disclosure system for leaner context files

**Why:** Shift to AI-first workflow — agents delegating to agents, planning-before-execution.

**Mergeability:** **HARD.** Agents cross-reference each other; piecemeal import breaks internal links. This fork's `settings.json` is older/narrower. Some agents are Mac-specific.

**Recommendation:** **CONSIDER SELECTIVELY.** Import 1–2 agents that you'd actually use (e.g. `plan-writer`, `context-researcher`). Don't flip `defaultMode: "plan"` without understanding the UX shift.

---

### 2. Progressive disclosure / context system

**What:** A systematic approach to large codebases via lightweight per-directory context files. ~27 new `*-context.md` files (one per directory), top-level `dotfiles-context.md` as a map, and 6 CLI tools in `tools/`:

- `tools/ctx-index` (141 lines) — indexed map
- `tools/ctx-peek` (103) — grep-ish lookup
- `tools/ctx-stale` (164) — find stale context docs
- `tools/ctx-reset` (49)
- `tools/ctx-skip` (46) — mark dirs to skip
- `tools/ctx-tree` (31)

Updated `maintained_global_claude/CLAUDE.md` with a "3-pass protocol": `ctx-index` → `ctx-peek` → full context file.

**Key commits:**
- `41d2f2a` — added context (2026-02-27)
- `ed5544f` — added skip context
- `490b928` — add ctx-skip documentation + expand auto-skip dirs
- `246475c` — fix ctx-stale to skip all subdirectories of SKIP-marked parents
- `519d99d` — fixed ctx
- `d9e1589` — overhaul progressive disclosure system
- `0b95f2f` — update context doc to reflect API error caching behavior

**Why:** Solves "AI reads too much" — cheap navigation over 150+ files without burning 50k tokens.

**Mergeability:** **EASY.** Purely additive, self-contained scripts. Depends on `eza` + `gum` (both already installed here).

**Recommendation:** **ADOPT.** Highest ROI in the whole review — low friction, immediately useful. Adopt the tools first, then generate context files for this fork using `/research` (from the `research` command).

---

### 3. Email stack (neomutt + mtui)

**What:** Complete terminal Gmail workflow.

- `mutt/` — full neomutt setup: `muttrc` (206 lines), `accounts/gmail.muttrc`, `keys/{binds,unbinds}.muttrc`, `isync/mbsyncrc`, `msmtp/config`, `notmuch/notmuchrc`, `styles.muttrc`, `mailcap`, `powerline-fixed.muttrc`, `gmail-filters.xml`
- `mutt/scripts/` — `mailsync`, `mailsync-daemon`, `inbox-cleanup`, `mutt-trim`, `mutt-viewical`, `render-calendar-attachment.py`, `beautiful_html_render`
- `tools/mtui.py` (989 lines) + `mtui_models.py` (105) + `mtui_styles.tcss` (300) — Textual-based TUI
- `tools/mget` / `msend` / `msearch` / `mview` — CLI wrappers (191–345 lines each)

**Key commits:**
- `a58cb59` — Add neomutt email client configuration
- `4ec7839` — Modernize neomutt config with sensible defaults
- `78e3dd4` — WIP: Add email TUI with mtui and mutt config updates

**Why:** Terminal-based Gmail workflow.

**Mergeability:** **HARD.** No email infra in this fork. Requires Gmail App Password setup.

**Recommendation:** **SKIP** unless you actively want terminal email.

---

### 4. Tmux catppuccin migration + status widgets

**What:** Near-full rewrite of `tmux/.tmux.conf` (~400-line diff; old version preserved as `.tmux.conf.backup`). New themes `tmux/catppuccin-{macchiato,mocha}-vibrant.sh`. 13 new status scripts in `tmux/scripts/`:

- `battery_status.sh` (110), `cpu_status.sh` (28), `cpu_percent.sh` (4), `ram_status.sh` (43), `mem_usage.sh` (8)
- `gpu_status.sh` (55), `network_status.sh` (148), `weather_status.sh` (26), `ssh_status.sh` (24), `load_status.sh` (20)
- `claude_code_status.sh` (20), `pk_claude_metric.sh` (52) — Claude API usage widgets
- `agents_status_bar.sh` (60), `agents_count.sh`, `agents_cache_refresh.sh` (59), `update_session_status.sh` (36)

Plus `F11` agents session, mark/copy range bindings, `copy-last-output` tmux key (`Y`).

**Key commits:**
- `9602e5b` — checkpoint migration to catppuccin theme (2026-01-22)
- `7d30033` — feat(tmux): add htop-style metrics to status bar
- `e0ce0ad` — rounded corners on Catppuccin pills
- `7e0ea82` — dynamic status-bar colors
- `5fcd24f` — big UI upgrade
- `984c658` — feat(tmux): AI-powered pane titles for agents session
- `e79ab6c` — switch tmux status bar to powerkit with hex accent colors
- `99cbef2` — fix agents session usage widgets lost on tmux config reload
- `0d9acfe` — fix usage widgets showing 0% when API is rate-limited
- `781d135` — add credits label to usage widget pill

**Why:** Richer terminal UX + AI-native status widgets (Claude API usage live in tmux).

**Mergeability:** **MEDIUM.** Conflicts with this fork's `C-a` prefix, OSC 52 clipboard, and custom theme sourcing (`source-file ~/dotfiles/theme/generated/tmux-colors.conf`). Scripts need `nvidia-smi` (GPU) / `upower` (Linux battery) — will silently no-op on CoreWeave/RunPod.

**Recommendation:** **CHERRY-PICK SCRIPTS, NOT CONFIG.** Import specific scripts you want (Claude metrics, battery) into `tmux/scripts/` and wire into this fork's existing `tmux/.tmux.conf`. Do not adopt the whole tmux.conf rewrite.

---

### 5. iTerm2 SSH themes — `iterm2/ssh-themes/`

**What:** 10 iTerm2 JSON color schemes (`01-subtle-tint.json` … `10-red-alert.json`) + `switch-ssh-theme` AppleScript dispatcher that auto-applies a theme based on SSH target. Partially reverted later.

**Key commits:** `dd40614` (gruvbox dark for SSH), `34fc760` (removes ssh theme — later reversal), `e0d6817` (tmux theme selections).

**Mergeability:** **EASY on macOS, IRRELEVANT on Linux** (no iTerm2 in CoreWeave/RunPod containers).

**Recommendation:** **SKIP** for the Linux side. Maybe consider on Mac.

---

### 6. Linting system — `linters/`

**What:** Universal `lint` zsh dispatcher (147 lines) that auto-detects file type and runs the right linter (ruff / biome / shfmt / shellcheck / rustfmt / pyright). Fallback configs (`ruff.toml`, `biome.json`). `lefthook.yml` pre-commit hook.

**Key commits:**
- `dc32494` — added smarter linting (2026-04-03)
- `8a2867d` — simplify lint script with batch mode, fix infinite loop on relative paths

**Why:** One-shot lint+fix across projects; standardized configs.

**Mergeability:** **EASY.** Additive, standalone.

**Recommendation:** **ADOPT.** Clean win, no conflicts. Also import the ruff/biome/lefthook install functions from `install/install_functions.sh`.

---

### 7. Shell themes + config updates

**What:**
- `shell/themes/gruvbox-dark.zsh` (52 lines) — auto-sourced on SSH via OSC escape palette swap, works in tmux
- `shell/themes/palenight.zsh` (52 lines) — local default
- `shell/.zshrc` gained defensive guards (`[[ -f ~/file ]] && source`) and SSH-theme detection
- `shell/helper_functions.sh` gained `_clo_preexec` / `_clo_precmd` hooks for `copy-last-output` tmux integration and a `marvin()` shortcut
- `shell/.p10k.zsh` — added Mac Mini hostname detection for custom OS icon, context in left prompt
- `shell/.paths.zsh` — dedup fix, added `/opt/homebrew/sbin`
- Alias `g` changed `glow` → `mdterm`

**Key commits:**
- `e0f796c` — migrate fzf-preview and `g` alias from glow to mdterm

**Mergeability:** **EASY** for themes + guards + hooks. Alias changes need review.

**Recommendation:** **ADOPT** guards, themes, and `copy-last-output` hooks. Cherry-pick alias changes individually.

---

### 8. fzf-preview overhaul — `preview/fzf-preview.sh`

**What:** Rewrite (65 → 130 lines). Timeout protection (`preview()` wrapper), binary detection, symlink resolution (`readlink -f`), and new handlers:

- TSV, feather, JSONL/NDJSON (for ML data)
- ONNX (new `preview/onnx-preview.py`, 65 lines)
- IPYNB (Jupyter)
- HTML, DOCX/PPTX/XLSX/EPUB (via markitdown)
- PDF (via pdftotext)
- Torch previewer rewritten with rich (`torch-preview.py`, 82 lines)

Markdown switched from `glow` → `mdterm`.

**Key commits:**
- `f984eb5` — overhaul fzf-preview.sh with timeout protection, binary detection, new file types (2026-03-18)
- `6cb824b` — add onnx-preview, rewrite torch-preview with rich, enhance fzf keybindings

**Mergeability:** **EASY.** Drop-in replacement. Needs `mdterm` + `markitdown` installed.

**Recommendation:** **ADOPT.** Strict upgrade.

---

### 9. `install/install_functions.sh` refactor (~1300-line diff)

**What:** Whitespace normalization + new installers + better OS handling.

**New install functions (worth cherry-picking individually):**
- `install_mdterm`, `install_markitdown`
- `install_ruff`, `install_biome`, `install_sourcery`
- `install_shfmt`, `install_yamllint`, `install_hadolint`, `install_golangci_lint`, `install_lefthook`
- `install_lazysql`, `install_opencode`

**Other improvements:**
- `OS_CLIPBOARD` env var set at startup (macOS=`pbcopy`, Linux=`xclip`)
- `cd "$(dirname "$0")"` guard in setup.sh to handle relative paths
- `install_if_dir_missing ~/.nvm` pattern (more reliable than command check)
- tmux plugin install deferred to after tmux binary is present (matches this fork's approach)

**Key commits:**
- `6422f3d` — fix setup.sh for fresh macOS: install homebrew first, defer TPM plugins

**Mergeability:** **HARD.** This fork has ~10 independent commits modifying `install_functions.sh` (voicemode removal, CoreWeave hardening, gum install, plugin install flow).

**Recommendation:** **CHERRY-PICK INDIVIDUAL FUNCTIONS.** Adopt specific new installers (ruff, biome, lefthook, mdterm, markitdown) by hand. Adopt the `cd "$(dirname "$0")"` guard. **Do not `git merge` this file.**

---

### 10. README.md (new, +548 lines)

**What:** Super-TUI positioning, tool inventory, keybindings, FAQ.

**Recommendation:** **SKIP verbatim.** This fork already has a README. If you want to revamp it, use upstream's structure as a template but keep the CoreWeave/Linux/Claude-Code focus.

---

### 11. `open_claw/CONFIGURE_OPENCLAW.md` (+1719 lines)

**What:** Playbook for running a 5-agent team on a dedicated always-on Mac Mini with Syncthing + Tailscale.

**Recommendation:** **SKIP.** macOS/Mac Mini specific.

---

### 12. Claude session tracking — `tools/check_limits.py`, `claude-session-digest`, `get_transcript`

**What:**
- `tools/check_limits.py` (126 lines) — hits `https://api.anthropic.com/account/usage`, caches, feeds tmux. Graceful degradation if key missing.
- `tools/claude-session-digest` (405 lines) — summarizes Claude Code session logs from `~/.claude/logs/`
- `tools/get_transcript` (317 lines) — exports conversations to markdown

**Key commits:** `99cbef2`, `0d9acfe`, `781d135` (widget fixes and labels).

**Mergeability:** **EASY.** Standalone tools.

**Recommendation:** **ADOPT `check_limits.py`** if you want API spend in the status bar. Others are nice-to-have archival.

---

### 13. Media-stack tools — `tools/media-stack-*`, `sync-qbit-port`, `upscale`

**What:** Ops tools for qBittorrent / Jellyfin (status, backup, watchdog) + Real-ESRGAN upscale wrapper.

**Key commits:** `5eddc60` — add media stack tools/skills, clean up finditfaster removal.

**Recommendation:** **SKIP.** Not your use case.

---

### 14. Prompt bank — `prompt_bank/`

**What:** `cleanup_transcript.md`, `ocr.md`, `file-renamer.md`, `prompt_bank-context.md` (~230 lines total).

**Recommendation:** **ADOPT.** Tiny, additive, useful.

---

### 15. Miscellaneous tools

- `tools/start_claude_proxy` (70 lines) — ADOPT if you use a proxy
- `tools/copy-last-output` (41) — ADOPT (small, pairs with tmux hooks from §7)
- `tools/rename_pdf` rewrite — minor improvement
- `tools/ocr_agent.*` — minor tweaks
- `codex/config.toml` minor tweaks — ADOPT if you use Codex CLI
- `fzf/.fzf-env.zsh` +68 lines — CONSIDER, merge selectively

---

## Top picks, ranked

| # | Thing | Tier | Effort | Key commits |
|---|---|---|---|---|
| 1 | `ctx-*` tools + context files | Must | ~2h | `41d2f2a`, `ed5544f`, `490b928`, `246475c`, `d9e1589` |
| 2 | Linting system (`linters/`) | Must | ~3h | `dc32494`, `8a2867d` |
| 3 | fzf-preview overhaul | Must | ~1h | `f984eb5`, `6cb824b` |
| 4 | Shell guards + `copy-last-output` hooks | Must | ~1h | surgical edits + `e0f796c` |
| 5 | Shell themes (gruvbox on SSH) | Strong | ~1.5h | see `shell/themes/*` |
| 6 | Selective tmux status scripts | Strong | ~2h | `7d30033`, `99cbef2`, `0d9acfe`, `781d135` |
| 7 | `check_limits.py` API usage pill | Strong | ~1h | pairs with #6 |
| 8 | Prompt bank | Nice | ~15m | bulk copy |
| 9 | 1–2 Claude agents (plan-writer, context-researcher) | Consider | ~3–4h ea | `1bb3ac1`, and later skill commits |
| 10 | Individual installers from `install_functions.sh` | Consider | ~2h | hand-import |

**Skip entirely:** email stack, OpenClaw guide, media-stack tools, iTerm2 SSH themes on Linux, the `install_functions.sh` whitespace refactor, upstream README verbatim.

---

## Suggested cherry-pick order

### Phase 1 — low risk, zero conflict (2–3h total)

1. `ctx-*` tools + context files — **§2**
2. `linters/` + ruff/biome/lefthook installers — **§6**
3. fzf-preview rewrite + onnx/torch previewers — **§8**
4. Shell defensive guards + `copy-last-output` hooks — **§7**
5. Prompt bank — **§14**

### Phase 2 — test after each (3–4h total)

6. Shell themes (SSH gruvbox, local palenight) — **§7**
7. Selected tmux status scripts (Claude metrics, battery) wired into existing `.tmux.conf` — **§4**
8. `check_limits.py` — **§12**

### Phase 3 — open-ended exploration

9. One Claude agent at a time, starting with `plan-writer` or `context-researcher` — **§1**
10. Individual installers from `install_functions.sh` as needed — **§9**

For each cherry-pick: if it touches `install_functions.sh`, `.tmux.conf`, `.zshrc`, or `settings.json`, expect manual resolution.

---

## How this report was built

1. `git remote add upstream https://github.com/vmasrani/dotfiles.git && git fetch upstream`
2. Identified sync boundary by finding the most recent upstream commit subject also present in this fork's log: `ce7111c` "pkl preview" ↔ local `6ddd77c` (same subject, rebased hash).
3. Listed 86 non-merge commits: `git log ce7111c..upstream/main --no-merges --oneline`
4. Got cumulative diff stats: `git diff ce7111c..upstream/main --stat` (189 files, +19063 / −1155)
5. Delegated deep per-area analysis to an exploration agent that read the diffs by functional grouping.

To regenerate or re-verify:

```bash
git fetch upstream
git log ce7111c..upstream/main --no-merges --oneline | wc -l
git diff ce7111c..upstream/main --stat | tail -1
```
