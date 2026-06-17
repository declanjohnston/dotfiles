---
name: inference-flow-distill
description: Use right after a product design meeting, when you have the transcript or notes and need to capture what the team decided before the infra/architecture meeting. Triggers - "turn this product meeting into a ticket", "draft the requirements checklist", "what do I take to the infra design meeting", scoping v1 vs later.
---

# inference-flow-distill

## Overview

First skill in the **inference-flow** suite. A human product-design meeting just
happened; this turns its transcript into committed requirements, the Linear tickets, and
prep for the next (infra/architecture) meeting.

**Core principle:** capture what the team decided about *product behavior* and *what ships
in v1*, surface what they left undecided, and prepare the user to **run** the infra meeting.

## When to use

- Right after a **product design** meeting; you have a transcript and/or notes.
- **NOT** after the infra/architecture meeting, and **NOT** for breaking work into engineering sub-issues → that's `inference-flow-breakdown` (which runs *after* the infra meeting).

## The one rule people break

**Do NOT produce an engineering breakdown.** No "data model" / "API" / "scheduler" /
"frontend" tickets. Those decisions depend on the infra meeting that hasn't happened yet.
This skill produces **user-requirement** artifacts only. If you catch yourself writing a
ticket about *how* it's built, stop — that's `inference-flow-breakdown`'s job.

## Process

1. **Read** the transcript/notes (and any existing ticket or design docs the user names).
2. **Extract every desired user experience** as a candidate requirement, each phrased from
   the user's point of view: **"A user can …"** / "A user should be able to …".
3. **Tag each requirement by iteration** based on what the meeting decided:
   `[v1]` · `[fast-follow]` · `[v2]` · `[future]`. Don't collapse to a binary "v1/later" —
   distinguish the near tiers from the someday tiers. Flag any requirement whose iteration
   the meeting did not actually settle.
4. **Gap check → brainstorm, don't guess.** Where the meeting left scope-affecting questions
   open (does X ship in v1? is it per-agent or per-project? who can do Y?), or the transcript
   is thin/informal, resolve them WITH the user via **`superpowers:brainstorming`** before
   committing artifacts. Never silently assume an answer that changes v1 scope.
5. **Explore the codebase now.** Understand what already exists and what this feature builds
   around — it's the only way to produce good open questions for the infra meeting.
6. **Write the product spec doc** (committed) →
   `inference/.ai-docs/design-docs/<feature>/00-product-spec.md`: the grouped
   "A user can…" checklist with iteration tags, plus the v1-vs-later rationale.
7. **Write the infra-meeting prep doc** (see below) →
   `inference/.ai-docs/design-docs/<feature>/infra-prep.md`. **Mandatory, but never
   `git add` it** (uncommitted; not gitignored — just don't stage it).
8. **Present the ticket drafts, get an explicit go-ahead, THEN write to Linear** (use the
   Linear tools). Never create/update tickets before the user approves the drafts. Keep tickets
   **concise and scannable** — the "A user can…" checklist itself, not paragraphs of exposition
   (rationale lives in the product-spec doc). If you're updating an existing high-level ticket,
   keep the change comment concise too — what changed and why in a sentence or two (the whole
   team reads it).

## Linear tickets this skill produces

Exactly two, no sub-issues:

| Ticket | Content |
|---|---|
| **Parent product ticket** | The **full** "A user can…" checklist across all iterations, with iteration tags, and **v1 items checked off** (checked = "in v1 scope"). |
| **v1 ticket** (child of parent) | The **v1 items only, unchecked** (they are work still to do). |

## Infra-meeting prep doc

Purpose: let the user walk in ready to **drive the architecture decisions**.

| Section | Required? | Content |
|---|---|---|
| **Open questions for the meeting** | **Mandatory** | The concrete decisions the team must make (storage, scheduling, data shape, integration, security), as discussion points the user can lead with. Each may carry a candidate recommendation to seed debate. |
| What exists | Optional | Existing packages/services/tables/patterns this touches or mirrors, with file pointers. |
| Reuse vs net-new | Optional | What can be built on/mirrored vs genuinely new. |
| Integration points | Optional | Where the feature hooks in. |

Write the optional sections only if the user wants them (ask if they already know the area);
the step-5 exploration feeds the mandatory open-questions section either way.

## Red flags — you're off the rails

- A ticket titled by a component/layer ("data model", "scheduler", "frontend") → you're doing the breakdown phase. Stop.
- Requirements phrased as features ("CRUD on reports") instead of "A user can…".
- A two-bucket v1/deferred split with no `[fast-follow]`/`[v2]`/`[future]` distinction.
- Writing to Linear before showing drafts.
- A verbose, essay-style ticket instead of a tight scannable checklist (depth belongs in the doc).
- Guessing an answer to a question that changes what's in v1 instead of brainstorming it.

## Next step

Hand off to the human **infra/architecture meeting**, then `inference-flow-breakdown`.
