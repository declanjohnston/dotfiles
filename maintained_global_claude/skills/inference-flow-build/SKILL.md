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
2. **Gather context.** Pull the Linear ticket(s) and read the committed design docs
   (`inference/.ai-docs/design-docs/<feature>/`).
3. **Probe the repo's testing structures BEFORE planning** (this is mandatory and easy to
   skip): the test runner/framework, the exact commands (e.g. `bun run tsc`,
   `bun run test:unit`, `bun test <file>`, `task integration-test`), the
   unit/integration/e2e split, fixture/assertion conventions, and any **repo-local testing
   skills** (e.g. this monorepo's `running-tests` and `writing-tests`). The plan must conform
   to what exists — never stand up a parallel test setup.
4. **Ask how to isolate the work** (offer, don't default):
   - a git worktree (`superpowers:using-git-worktrees`); and
   - in **per-sub-issue mode**, a **dedicated branch per sub-issue cut from the v1 feature
     branch** (the parent issue's branch), so the sub-issue can be PR'd back into it for
     review (step 7).
   If the user declines both, work on the current branch.
5. **Plan with superpowers.** Use **`superpowers:writing-plans`** to produce the bite-sized
   TDD plan. **The plan is a scratch artifact in `docs/superpowers/plans/` and is never
   committed** (don't `git add` it). The plan MUST include an explicit **Testing** section
   that marries superpowers' RED→GREEN→refactor discipline with the repo conventions from
   step 3 — exact commands, where test files live, which layer each task is tested at, and
   the repo's fixture/assertion patterns. No generic "add tests" placeholders.
6. **Execute with superpowers** — `superpowers:subagent-driven-development` (recommended) or
   `superpowers:executing-plans`.
7. **Finish.** Update/close the Linear ticket(s), then wrap with
   `superpowers:finishing-a-development-branch`. In **per-sub-issue mode**, offer to open a
   **PR from the sub-issue branch back into the v1 feature branch** (not into the main trunk)
   so each sub-issue gets CI + bugbot review; merge once green. *(Whole-v1 mode PRs into the
   main trunk as usual. Once all sub-issues have merged into the v1 branch, that branch is
   PR'd to the trunk.)*
8. **(Per-sub-issue mode only) Hand off, then reset context before the next ticket.** Each
   sub-issue is its own clean context — never carry one ticket's accumulated context into
   the next, or it balloons across all the sub-issues. After step 7, run the **`/handoff`**
   command to write a self-contained handoff (what shipped, commits landed, gotchas, and the
   remaining sub-issues in order). Then **start the next sub-issue in a fresh context**
   (`/clear`, or a new session), which begins by reading that handoff and re-entering this
   skill at step 2. Repeat per sub-issue. *(Whole-v1 mode stays in one context — no
   per-ticket reset.)*

## Don't reinvent — delegate to superpowers

| Need | Use |
|---|---|
| Isolation | `superpowers:using-git-worktrees` |
| The plan | `superpowers:writing-plans` |
| Execution | `superpowers:subagent-driven-development` / `superpowers:executing-plans` |
| Wrap-up / PR | `superpowers:finishing-a-development-branch` |

## Red flags — you're off the rails

- Writing implementation before a failing test (build-then-test instead of TDD).
- Producing a plan with no repo-conforming Testing section, or one that invents a new test setup.
- Committing the superpowers plan.
- Spinning up a worktree without asking (or never offering one).
- Finishing the code but leaving the Linear ticket open / not running the branch-finish wrap-up.
- Hand-rolling your own planning/execution instead of invoking the superpowers sub-skills.
- (Per-sub-issue mode) running ticket after ticket in one ever-growing context instead of `/handoff` + fresh context between them.
