---
name: inference-flow
description: Use when starting or navigating a company feature from product meeting through to shipped code, or when unsure which inference-flow-* skill applies. Triggers - "what's our feature workflow", "I just had a product/infra meeting", "how do we take this from idea to code", starting a new feature end to end.
---

# inference-flow

## Overview

My company's feature workflow, wrapping **superpowers** (my dev engine). Two **human** team
meetings bracket the automated work; each is followed by a skill. Use this index to pick the
phase, then invoke that skill.

## The flow

| Phase | After... | Use skill | Produces |
|---|---|---|---|
| 1 | **Product design** meeting | `inference-flow-distill` | "A user can…" requirement checklist (v1/fast-follow/v2/future), product + v1 Linear tickets, infra-meeting prep doc |
| 2 | **Infra/architecture** meeting | `inference-flow-breakdown` | committed arch/data-model doc + dev-scoped Linear sub-issues under the v1 ticket (UI split POC + Polish) |
| 3 | ready to build | `inference-flow-build` | per sub-issue (or whole small v1): superpowers plan + execution with repo-conforming tests, ticket closed |

## Superpowers integration

- **Thin/informal meeting?** Each phase skill fills decision gaps via `superpowers:brainstorming` before committing artifacts.
- **Building (phase 3)** runs on `superpowers:writing-plans` → `superpowers:subagent-driven-development` / `executing-plans`, with `using-git-worktrees` and `finishing-a-development-branch`.

## Conventions (shared across phases)

Requirements are user-POV ("A user can…"); iteration tags `[v1]`/`[fast-follow]`/`[v2]`/`[future]`;
design docs committed to `inference/.ai-docs/design-docs/<feature>/`; always present drafts and
get a go-ahead before writing to Linear. **Two ticket layers, two levels of detail:** the
high-level product + v1 tickets stay simple and scannable — just the "A user can…" user stories
(a boss can grok them at a glance; sub-issues and their progress auto-list under the v1 ticket).
The **v1 sub-issues, by contrast, are detailed and self-contained** — enough context for an
engineer or AI to pick one up and build it (and to produce the superpowers plan), but never
code-level detail or the implementation plan itself. Long-form rationale and architecture still
live in the committed repo docs. **Comments/updates on the high-level tickets stay concise too:**
when one changes, note what changed and why in a sentence or two — the whole team reads these, so
no walls of text.

**Drive ticket status as you work, and let status — not comments — track progress.** Move a
ticket to **In Progress** when you start building it, to **In Review** once the work is done and
up for review (PR open), and to **Done** once it's merged. The status field conveys progress on
its own, so don't post comments announcing it ("this is complete", "started on this") — that's
noise the status already carries. Edit a ticket's content or leave a comment ONLY when the ticket
has **materially changed** (scope/requirements moved) or you made a **clarifying decision** on
something that was underspecified — and keep that note short.
