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
get a go-ahead before writing to Linear.
