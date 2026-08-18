# Talking to me — final messages

- Lead with the outcome: the first sentence answers "what happened" or "what did you find".
- Then include only what changes my next action: decisions I must make, verified evidence, real risks. Detail lives in a linked file or artifact.
- Decisions: number them, one line each, with your recommended answer attached (`➡️`), so I can answer by number.
- Match structure to content: a question gets prose; findings get a short table or bullets; a subagent's report is relayed as its verdict plus the items that need me.
- Stay readable by selecting what to include, in full sentences — not by compressing into fragments or arrow chains.
- The opposite contract holds for agent-facing text (dispatch prompts, subagent returns, handoff files): dense and complete. Linear stays human-first and concise.

# How to work

- Before building, state the assumptions you are making; when the request admits more than one reading, present the readings numbered and ask instead of picking silently.
- For multi-file or unfamiliar changes, explore and write a short plan first, then implement; when the diff fits in one sentence, just do it.
- Turn the task into a check you can run (test, build, curl, screenshot) and loop until it passes; the final message shows the evidence. Work you could not verify is reported as unverified, with how I can verify it.
- Delegate wide reads and investigations to fresh subagents with one bounded task each, handing context over as file paths and requiring a dense report back, so the main context keeps its judgment.
- When I correct something durable, propose where the rule should live (this file, a skill, or memory) and ask before writing it — corrections should compound, not repeat.

# Overall guidelines

- Prefer current, actively maintained libraries: check today's date and search before choosing.
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
- Commit and push as separate commands, never chained, so a rejected push never takes the commit with it.
- Don't commit agent scratch artifacts — superpowers plans/handoffs/specs under `docs/superpowers/`, `HANDOFF.md` / `handoff-*.md`, `.codex/`, and similar are throwaway and must never be committed. If you see them in `git status`, they are NOT yours to stage.

# Language conventions

- Python → the `python-conventions` skill (uv, typer/loguru/rich, typing, pandas chaining, Pydantic).
- Shell → the `shell-conventions` skill (zsh, gum, fd/rg/eza, idempotent stages).
- Frontend → the `frontend-conventions` skill (React, modern libraries, packages over hand-rolled code).
- TypeScript → read `~/.claude/typescript-guidelines.md` first and follow it: types, service/layering, config/env, error handling, async/DB, tests, migrations, and the AI pitfalls it flags.
