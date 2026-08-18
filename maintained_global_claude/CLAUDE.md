# Talking to me — final messages

- Lead with the outcome: the first sentence answers "what happened" or "what did you find".
- Then include only what changes my next action: decisions I must make, verified evidence, real risks. Detail lives in a linked file or artifact.
- Decisions: number them, one line each, with your recommended answer attached (`➡️`), so I can answer by number.
- Match structure to content: a question gets prose; findings get a short table or bullets; a subagent's report is relayed as its verdict plus the items that need me.
- Stay readable by selecting what to include, in full sentences — not by compressing into fragments or arrow chains.
- The opposite contract holds for agent-facing text (dispatch prompts, subagent returns, handoff files): dense and complete. Linear stays human-first and concise.

# Overall guidelines

- always search for the latest modern 2026 libraries and use them when writing code
- never write a function yourself when it can come from a library instead

# Code comments

- Comment the code as it exists now, not the story of how it got there. I *like* good comments: short function/block descriptions of purpose and contract, and "why" notes on non-obvious logic, edge cases, or gotchas. Keep those.
- Never leave process/history narration comments — these are the dead giveaway that an AI wrote the diff, and I want them gone:
  - temporal/status comments: "deferred to v2", "TODO: revisit later", "for now we just…", "temporary workaround"
  - change-narration comments: "previously this used X", "refactored from Y", "renamed from…", "moved out of…" — anything describing the diff or what the code *used to be* instead of what it *is*
  - comments that just restate what self-evident code already says, line by line
- Rule of thumb: if a comment stops making sense once the PR is merged and its history is forgotten, it doesn't belong inline. That context goes in the PR description or repo docs, not the code.

# git

- Never "sign" commits: do not add `Co-Authored-By:` trailers, "Generated with…" lines, or any AI attribution to commit messages or PR bodies. Plain messages only.
- **NEVER stage with `git add -A`, `git add .`, `git add -u`, or `git commit -a`.** These sweep in whatever untracked junk happens to be in the tree (scratch plans, handoffs, `.codex/`, design notes) and silently commit it — this has happened and produced a 23k-line scratch dump in a PR. ALWAYS stage explicit paths: `git add path/to/file1 path/to/file2`. Before every commit, run `git status` / `git diff --cached --name-only` and confirm the staged set is EXACTLY the files you intended — nothing else. This rule also applies to any subagent/implementer prompt you write: instruct them to stage explicit paths, never `git add -A`.
- Don't commit agent scratch artifacts — superpowers plans/handoffs/specs under `docs/superpowers/`, `HANDOFF.md` / `handoff-*.md`, `.codex/`, and similar are throwaway and must never be committed. If you see them in `git status`, they are NOT yours to stage.

# Language conventions

- Python → the `python-conventions` skill (uv, typer/loguru/rich, typing, pandas chaining, Pydantic).
- Shell → the `shell-conventions` skill (zsh, gum, fd/rg/eza, idempotent stages).
- Frontend → the `frontend-conventions` skill (React, modern libraries, packages over hand-rolled code).
- TypeScript → read `~/.claude/typescript-guidelines.md` first and follow it: types, service/layering, config/env, error handling, async/DB, tests, migrations, and the AI pitfalls it flags.
