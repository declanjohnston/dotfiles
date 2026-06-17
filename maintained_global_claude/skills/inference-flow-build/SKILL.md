---
name: inference-flow-build
description: Use when ready to implement v1 work from the inference-flow breakdown - turning a Linear sub-issue (or a whole small v1) plus the design docs into shipped, tested code. Triggers - "build this ticket", "implement this sub-issue", "start on this Linear issue", moving from arch/tickets to code.
---

# inference-flow-build

## Overview

Third skill in the **inference-flow** suite. Takes agreed v1 work (a Linear sub-issue, or a
whole small v1) and drives it to shipped, tested code — using **superpowers** as the
implementation engine.

**Core principle:** this skill is an orchestrator. It does NOT invent a planning or testing
method — it sets up context from Linear + the design docs, makes the plan conform to *this
repo's* test conventions, and hands off to superpowers for planning and execution.

## When to use

- When you're ready to **build** v1 work that's already broken down (from `inference-flow-breakdown`).
- **NOT** for capturing requirements (`inference-flow-distill`) or breaking down work (`inference-flow-breakdown`).

## Process

1. **Pick mode by size.** Large feature → one cycle **per sub-issue**, each in its **own
   fresh context** (see step 8). Small feature → **one plan covering all of v1** in a single
   context. Confirm with the user when it's a judgment call.
2. **Gather context, and move the ticket to In Progress.** Pull the Linear ticket(s) and read
   the committed design docs (`inference/.ai-docs/design-docs/<feature>/`). As you pick up a
   sub-issue, set its Linear status to **In Progress** — the status field is how the team sees
   what's being worked on; don't announce it with a comment.
3. **Probe the repo's testing structures BEFORE planning** (this is mandatory and easy to
   skip): the test runner/framework, the exact commands (e.g. `bun run tsc`,
   `bun run test:unit`, `bun test <file>`, `task integration-test`), the
   unit/integration/e2e split, fixture/assertion conventions, and any **repo-local testing
   skills** (e.g. this monorepo's `running-tests` and `writing-tests`). The plan must conform
   to what exists — never stand up a parallel test setup. *(Per-sub-issue mode: if a prior
   handoff already records these test conventions, reuse them — re-verify only if something
   looks stale; don't re-run the whole probe.)*
4. **Ask how to isolate the work** (offer, don't default):
   - a git worktree (`superpowers:using-git-worktrees`); and
   - in **per-sub-issue mode**, a **dedicated branch per sub-issue cut from the v1 feature
     branch** (the parent issue's branch), so the sub-issue can be PR'd back into it for
     review (step 7).
   If the user declines both, work on the current branch.
5. **Plan with superpowers.** Use **`superpowers:writing-plans`** to produce the bite-sized
   TDD plan. **The plan is a scratch artifact in `docs/superpowers/plans/` and is never
   committed.** Stage commits with EXPLICIT paths only — NEVER `git add -A`/`git add .`/`git
   commit -a` (those sweep in the plan + other untracked scratch; this has shipped a 23k-line
   scratch dump into a PR). Before each commit run `git diff --cached --name-only` and confirm
   the staged set is exactly the intended files. The plan MUST include an explicit **Testing** section
   that marries superpowers' RED→GREEN→refactor discipline with the repo conventions from
   step 3 — exact commands, where test files live, which layer each task is tested at, and
   the repo's fixture/assertion patterns. No generic "add tests" placeholders.
6. **Execute with superpowers** — `superpowers:subagent-driven-development` (recommended) or
   `superpowers:executing-plans`. **Hunt for parallelism first.** A plan's flat task order is
   often incidental, not a real dependency — tasks touching different files/layers with no
   shared state don't collide. Scan for those independent groups and run them as **concurrent
   sub-agents** via `superpowers:dispatching-parallel-agents`; serialize only on a genuine
   dependency or a shared-file edit. Default to parallel where it's safe — running
   collision-free tasks one-at-a-time just wastes wall-clock.
7. **Finish — move status, don't narrate it.** When the work is done and the PR is open, set
   the Linear ticket to **In Review**; once it's merged, set it to **Done**. The status field
   tells the team where the ticket stands — do NOT post a "this is complete / shipped X"
   comment, the status already conveys that. Only edit the ticket or comment if the
   implementation **materially diverged** from what the ticket described, or you made a
   **clarifying decision** on something underspecified — and keep it to a sentence or two (deep
   detail lives in the PR + repo docs). Then wrap with
   `superpowers:finishing-a-development-branch`. In **per-sub-issue mode**, offer to open a
   **PR from the sub-issue branch back into the v1 feature branch** (not into the main trunk)
   so each sub-issue gets CI + bugbot review; merge once green. *(Whole-v1 mode PRs into the
   main trunk as usual. Once all sub-issues have merged into the v1 branch, that branch is
   PR'd to the trunk.)*
8. **(Per-sub-issue mode only) Hand off, then reset context before the next ticket.** Don't
   carry one ticket's accumulated context into the next, or it balloons across all the
   sub-issues. After step 7, run **`/handoff`** to write a self-contained handoff: what shipped,
   commits landed, gotchas, the remaining sub-issues in order, **and the stable discovery the
   next agent would otherwise re-derive from scratch** — the step-3 testing setup (runner, exact
   commands, unit/integration/e2e split, fixture/assertion conventions, repo-local testing
   skills) plus any other exploration findings that don't change between sub-issues (design-doc
   locations, build/lint commands, key architecture touchpoints). Then start the next sub-issue
   in a **fresh context** (`/clear` or a new session) — it re-enters this skill at step 2 and
   **reuses that recorded discovery instead of re-probing**.
   *(Whole-v1 mode stays in one context — no per-ticket reset.)*

## Red flags — you're off the rails

- Writing implementation before a failing test (build-then-test instead of TDD).
- Producing a plan with no repo-conforming Testing section, or one that invents a new test setup.
- Committing the superpowers plan — or any untracked scratch (handoffs, `.codex/`, notes). Caused by `git add -A`/`git add .`; stage explicit paths and check `git diff --cached --name-only` before committing.
- Spinning up a worktree without asking (or never offering one).
- Building without moving the ticket to **In Progress**, or finishing the code but leaving the status stuck (not → **In Review** on PR, → **Done** on merge) / not running the branch-finish wrap-up.
- Posting a comment that just narrates status ("ticket complete", "started this") when the status field already conveys it.
- Editing ticket content or commenting when nothing materially changed and no clarifying decision was made.
- Hand-rolling your own planning/execution instead of invoking the superpowers sub-skills.
- Running collision-free tasks sequentially when they could safely run as parallel sub-agents.
- (Per-sub-issue mode) running ticket after ticket in one ever-growing context instead of `/handoff` + fresh context between them.
- (Per-sub-issue mode) re-running the full test-structure probe / re-doing stable discovery the prior handoff already records.
