# ctx-* System Evaluation

Follow-up notes after the upstream review (see `docs/upstream-review-2026-04.md`). This is a decision doc for whether / how to adopt the "progressive disclosure" context system from `vmasrani/dotfiles`. Written 2026-04-13.

Current state: **not adopted**. Leaving this doc for future-me to revisit when there's time to make a call.

---

## What the system is

A per-directory markdown convention (`{dirname}-context.md`) plus six small shell tools that let Claude navigate a repo by reading ~50–300 tokens of structured summary before opening any source file. Designed for AI-first codebase navigation.

**Philosophy:** traditional docs (docstrings, one big README, wikis) are shaped for humans. This is shaped for LLM agents — compact, predictable schema, discoverable via filesystem, explicit staleness tracking.

**Not a standard, not widespread.** Upstream (vmasrani) cooked this up himself. It sits in the same family as aider's repo-map and the `AGENTS.md` convention, but at per-directory granularity with hand-written / Claude-generated prose.

## How it works (reference)

### The six tools — all in `tools/` on `~/tools/` PATH

| Tool | Purpose | Typical output size |
|---|---|---|
| `ctx-index [dir] [--depth N] [--full]` | One-line summary per directory; the cheapest first-pass map | ~10 tok/dir |
| `ctx-peek [dir] [lines] [--depth N]` | Preview context files up to `<!-- peek -->` marker (default 12 lines) | ~100–200 tok/dir |
| `ctx-stale [dir] [--max-depth N] [--min-files N]` | Reports MISSING / STALE / FRESH / SKIPPED dirs via mtime compare | varies |
| `ctx-reset [dir] [--dry-run]` | Deletes all `*-context.md` (prompts via `gum_confirm`) | — |
| `ctx-skip [dir] [reason]` | Creates stub with `> SKIP: reason` marker | — |
| `ctx-tree [dir] [depth]` | `eza --tree` fallback when no context files exist | — |

All zsh scripts, graceful fallback without gum, respect .gitignore via `command fd`.

### File schema (fixed)

```markdown
# {Directory Name}
> {one-sentence summary, ≤120 chars, no "This directory…" prefix}
`{N} files | {YYYY-MM-DD}`

| Entry | Purpose |
|-------|---------|
| `{file}` | What it does and WHY it matters |
| **{subdir}/** | One-line summary from child's ctx-index, or inferred |

<!-- peek -->

## Conventions
{non-obvious patterns that differ from defaults}

## Gotchas
{subtle bugs, ordering dependencies, surprising behavior}
```

The `<!-- peek -->` marker is load-bearing — everything above is the cheap preview zone, everything below is detail loaded only when needed. Target length: 20–50 lines.

### The 3-pass protocol (added to upstream's global CLAUDE.md)

1. `ctx-index . --depth 1` — top-level map, pick 1–3 relevant dirs
2. `ctx-peek <dir> 8` — shallow skim (~200 tok/dir)
3. Read full `*-context.md` only for gotchas / non-obvious details

Rules: never load more than 2–3 full context files at once; fall back to `ctx-tree` if no context exists; if stale, suggest `/research`.

### The `/research` command (generates context files)

Dispatches to the `context-researcher` agent (sonnet, read-only). Workflow:

1. Exits plan mode
2. Runs `ctx-stale .` to find MISSING/STALE dirs
3. Splits into leaves vs parents (leaf = no child in the processing list)
4. **Parallel** `context-researcher` agents for all leaves in one message
5. Waits, then parallel agents for parents (they can call `ctx-index <dir> --depth 1` to quote child summaries)
6. Returns summary report: N created / N updated / N skipped / errors

**Requires the agent system** — without `context-researcher.md` in `maintained_global_claude/agents/`, `/research` has nothing to dispatch to. Fallback: generate by hand in a normal Claude session using the schema above.

### Maintenance workflow

After a code change commits:

```bash
ctx-stale .          # see what mtime-flipped
```

Three legitimate responses to a STALE flag:

| Judgement | Action |
|---|---|
| Content needs real update | `/research <dir>` scoped refresh |
| Content still correct, just mtime-stale | `touch {dir}/{dirname}-context.md` and commit |
| Dir no longer worth documenting | `ctx-skip <dir> "reason"` and commit |

Cadence: `/research` after refactors, `touch` after cosmetic changes, `ctx-stale` check every few weeks for hygiene.

---

## Interaction with my superpowers workflow

**They're orthogonal** — superpowers is *how to do work* (brainstorming → TDD → verify), ctx-* is *how to navigate code*. Different layers.

### Where they could collide

1. **The "first thing" slot in CLAUDE.md.** `using-superpowers` demands skill check BEFORE any response. Upstream's 3-pass protocol wants `ctx-index` as the first action. Resolution: ctx-* is subordinate — frame it as "when a skill requires codebase exploration, use ctx-* first," not "first thing every session."

2. **`defaultMode: "plan"`** in upstream's settings.json conflicts with `superpowers:brainstorming` coming first. **Do not adopt** this setting.

3. **Agent overlap.** Upstream agents that duplicate superpowers:

   | Upstream agent | Superpowers equivalent | Verdict |
   |---|---|---|
   | `plan-writer` | `superpowers:writing-plans` | skip upstream's |
   | `spec-interviewer` | `superpowers:brainstorming` | skip |
   | `test-generator` | `superpowers:test-driven-development` | skip |
   | `structural-completeness-reviewer` | `superpowers:receiving-code-review` | skip |
   | `context-researcher` | *no equivalent* | **adopt** (needed for /research) |
   | `codebase-researcher` | Explore agent | skip |

   **Minimum viable agent adoption for ctx:** just `context-researcher`.

### Where they complement

Within specific superpowers skills, ctx-* is useful as a first-action subroutine:

- `writing-plans` — `ctx-peek` the subsystems before scoping
- `executing-plans` — `ctx-peek` module X before editing
- `systematic-debugging` — gotchas section narrows hypotheses
- `dispatching-parallel-agents` / `subagent-driven-development` — each subagent starts with `ctx-peek` to cut its orientation tokens

Rule: whenever a skill says "understand the existing code," ctx-* is the cheap first move of that understanding.

---

## Concerns that made me pause

### 1. It's opinionated — team buy-in required

Context files live *alongside code* and land in PRs. Coworkers will reasonably ask what they are, whether they have to maintain them, and why there wasn't a team discussion. Unilateral adoption imposes cognitive tax on people who didn't opt in.

### 2. Gitignore-then-branch-switch is broken

Context files describe the *current* shape of a directory. Different branches legitimately have different shapes. If gitignored, branch switches leave stale files describing the old structure. If symlinked from a per-repo cache, still have to pick which branch's version is live.

No clean "just hide them" solution exists.

### 3. Maintenance burden is where adopters bounce off

`ctx-stale` is aggressive by design — every code edit marks its sibling context file stale. Upstream deals with this on his personal dotfiles as sole maintainer. In a team repo, staleness compounds across contributors and nobody owns refreshing it.

---

## The distinction that matters

**The tools and the files are separate adoption decisions.**

| | Tools (`ctx-*`) | Files (`*-context.md`) |
|---|---|---|
| Cost when unused | Zero — no-op | N/A |
| Team impact | Zero — just on PATH | High — land in diffs |
| Maintenance | None | Real, ongoing |
| Branch sensitivity | None | Each branch differs |
| Reversible | Trivially | Delete all + retrain habits |

Tools can be adopted without the files.

---

## Recommendation (for future-me)

**Do:**

- ✅ Adopt the 6 `ctx-*` tools globally. They no-op gracefully; zero cost when unused. `ctx-tree` alone (just `eza --tree` with gitignore respect) is mild upgrade.
- ✅ Generate context files for **this dotfiles repo** if motivated — sole stakeholder, bounded scope, tools pay off.
- ✅ Adopt `context-researcher` agent + `/research` command together (they're a unit; `/research` dispatches to `context-researcher`).
- ✅ Use `/research` *ephemerally* on unfamiliar codebases — generate, explore, `git clean -f '**/*-context.md'` when done. Don't commit.

**Don't:**

- ❌ Pitch this to the team. 20-minute conversation for a 3-month commitment no one asked for.
- ❌ Adopt upstream's `defaultMode: "plan"` — conflicts with superpowers brainstorming-first.
- ❌ Adopt plan-writer / test-generator / spec-interviewer / structural-completeness-reviewer agents — superpowers already covers these, better.
- ❌ Commit context files to work repos unilaterally.

**Consider:**

- ⚠️ For team repos where AI-first docs have value: propose a single `AGENTS.md` at the repo root instead. Known convention, minimum viable, maximum social acceptance. Gets you ~60–70% of the orientation benefit.

### CLAUDE.md integration (if adopted)

When merging the 3-pass protocol into your global CLAUDE.md, frame it as subordinate to superpowers:

> After invoking the relevant skill, if the skill requires codebase exploration, use the ctx-* tools (ctx-index → ctx-peek → full context). Never run ctx-* in place of a skill check.

Keep this boringly literal. It's the glue that preserves `using-superpowers`' skill-first invariant while letting ctx-* be the cheap exploration primitive.

---

## Concrete adoption steps (when ready)

```bash
cd ~/dotfiles

# 1. Copy the 6 tools
for s in ctx-index ctx-peek ctx-stale ctx-reset ctx-skip ctx-tree; do
  git show upstream/main:tools/$s > tools/$s && chmod +x tools/$s
done

# 2. Dependencies
command -v eza || sudo apt install eza   # or brew install eza
# gum already present

# 3. (Optional) adopt /research + context-researcher agent
mkdir -p maintained_global_claude/{commands,agents}
git show upstream/main:maintained_global_claude/commands/research.md \
  > maintained_global_claude/commands/research.md
git show upstream/main:maintained_global_claude/agents/context-researcher.md \
  > maintained_global_claude/agents/context-researcher.md

# 4. Run ./setup.sh to symlink everything
./setup.sh

# 5. (Optional) generate context files for this repo
# In Claude Code: /research .

# 6. Review generated files — expect 10–30% to need hand-editing
git diff '**/*-context.md'
git add '**/*-context.md'
git commit -m "add ctx files"
```

### CLAUDE.md additions (minimum)

Add to `/home/declan/.claude/CLAUDE.md` after the superpowers preamble, before the python/bash/etc. guidelines:

```markdown
# Codebase navigation (when inside a skill that requires exploring code)

After invoking the relevant skill, if the skill requires codebase exploration,
use the ctx-* tools — cheapest first:

1. `ctx-index . --depth 1` — top-level map
2. `ctx-peek <dir> 8` — shallow skim of relevant dirs
3. Read the full `*-context.md` only when you need gotchas or non-obvious details

Rules:
- Never run ctx-* in place of a skill check
- Never load more than 2–3 full context files at once
- If `ctx-index` returns nothing, fall back to `ctx-tree` then manual exploration
- If context files are stale (`ctx-stale`), suggest `/research` to refresh
```

---

## Upstream references (for future digging)

- Commits introducing / refining the system:
  - `41d2f2a` — added context (2026-02-27)
  - `ed5544f` — added skip context
  - `490b928` — add ctx-skip documentation + expand auto-skip dirs
  - `246475c` — fix ctx-stale to skip all subdirectories of SKIP-marked parents
  - `519d99d` — fixed ctx
  - `d9e1589` — overhaul progressive disclosure system
  - `0b95f2f` — update context doc to reflect API error caching behavior
  - `08e50cb` — enable LSP plugins + strengthen progressive disclosure defaults

- Key files at `upstream/main`:
  - `tools/ctx-index`, `ctx-peek`, `ctx-stale`, `ctx-reset`, `ctx-skip`, `ctx-tree`
  - `maintained_global_claude/commands/research.md`
  - `maintained_global_claude/agents/context-researcher.md`
  - `maintained_global_claude/CLAUDE.md` (3-pass protocol section)
  - `dotfiles-context.md` (example top-level context file)
  - Any `*-context.md` in upstream directories (real-world schema examples)

- To inspect any without checkout:
  ```bash
  git show upstream/main:<path>
  ```
