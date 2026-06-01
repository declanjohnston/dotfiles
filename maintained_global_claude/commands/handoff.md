---
description: Write a self-contained handoff plan so a new session can pick up the current work
---

# Session Handoff

Produce a **self-contained handoff document** that lets a brand-new session
(with zero prior chat) resume exactly where this one leaves off.

**IMPORTANT:** If you are in plan mode, call `ExitPlanMode` immediately — this
command writes a file.

`$ARGUMENTS` is an optional output path. If empty, write to `HANDOFF.md` in
the repo root (or the active worktree root). If a file already exists there,
read it first, then **overwrite** it with a refreshed version — never append.

If a prior `HANDOFF.md` exists in the repo, read it before writing to calibrate
depth and tone, then replace it.

## 1. Gather state (do this before writing anything)

Run these in parallel and read the results — do not guess from memory:

- `git status --porcelain=v1 -b` and `git worktree list` — branch, worktree,
  uncommitted/untracked files.
- `git log --oneline -15` and, if on a feature branch,
  `git log --oneline origin/main..HEAD` (or `origin/master..HEAD`) — what's
  already committed here vs. what's safely rewritable / unpushed.
- `git diff --stat` and `git diff --stat --cached` — the shape of in-flight work.
- The current TODO list / plan, if one exists in this session.
- Project notes relevant to the work: `CLAUDE.md` (repo + `~/.claude/CLAUDE.md`),
  any `*.md` near the changed files, and the persistent memory index at
  `~/.claude/projects/<encoded-cwd>/memory/MEMORY.md` if one exists.
- If running inside a named tmux session (check `$TMUX` and
  `tmux display-message -p '#S'`), capture the session name — the next session
  may want to attach there.

When exploring, prefer your usual tools: `rg` over `grep`, `fd` over `find`,
`eza --tree` over `tree`.

Reconstruct, from THIS conversation, the things a transcript would not reveal:
the **goal**, the **why**, decisions already made (and rejected alternatives),
dead ends already hit, and any user constraints/preferences stated in chat.

## 2. Write the handoff

Open with a one-paragraph **Goal** + what is blocked on it. State explicitly:
"This file is self-contained — a new session does not need the prior chat."

Then include these sections (drop any that genuinely don't apply; never pad):

1. **Where the work lives** — worktree path(s), branch, tmux session name (if
   any), how path deps resolve, anything gitignored that matters, stale
   worktrees/branches safe to remove, and a table of **commits already landed**
   (`hash | what`) so the new session doesn't redo them.
2. **Critical lessons / gotchas** — anything that already went wrong this
   session and the mitigation. This is the highest-value section: it's the part
   a transcript can't recover. Be concrete (commands, symptoms, root cause).
3. **Remaining work** — concrete, ordered tasks grouped by workstream. Each
   task: the file(s), what to do, and how to know it's done. Mark items that
   are sequenced or mutually exclusive. Flag anything risky to parallelize.
4. **Suggested orchestration** — the order to do it in, what's safe to fan out
   to subagents vs. do by hand, and merge order if multiple branches.
5. **Acceptance bar** — the checkable definition of done (commands that must be
   green, invariants that must hold).
6. **Reference** — full punch-list / findings / links, so the new session has
   the source of truth without this chat.

## Rules

- **Self-contained.** No "as discussed" / "see above" / references to this chat.
  Every path is absolute or unambiguous. Every commit hash is real (from
  `git log`, not invented). Every command is copy-pasteable.
- **Honest.** If something is untested, unverified, or uncertain, say so. If a
  P0 bug is fixed and verified, say that plainly. Don't oversell progress.
- **Concrete over prose.** Tables for commits/tasks. Real file paths and line
  hints. The reader should be able to act without re-deriving context.
- **Capture the why, not just the what.** Code shows what; the handoff must
  carry the reasoning, the rejected options, and the user's constraints.
- After writing, print the path and a 3–5 line summary of what it covers.
