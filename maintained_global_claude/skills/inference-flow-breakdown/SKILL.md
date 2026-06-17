---
name: inference-flow-breakdown
description: Use right after an infra/architecture design meeting, when the v1 product requirements already exist as a Linear v1 ticket and you need to capture the agreed architecture and break v1 into engineering sub-issues. Triggers - "break this down into sub-issues", "turn the arch meeting into tickets", "create the v1 engineering tickets".
---

# inference-flow-breakdown

## Overview

Second skill in the **inference-flow** suite. A human infra/architecture meeting just
decided *how* the feature is built; this captures that architecture and turns the v1 ticket
into engineering sub-issues.

**Core principle:** record the agreed architecture as a committed design doc, then derive
**dev-scoped, PR-sized** sub-issues that *together* cover every v1 requirement.

## When to use

- Right after the **infra/architecture design** meeting; the v1 product ticket already exists (from `inference-flow-distill`).
- **NOT** before the infra meeting, and **NOT** for capturing product requirements → that's `inference-flow-distill`.

## Process

1. **Read** the infra/arch transcript + notes, the **v1 ticket**, the infra-prep doc, and the product spec.
2. **Gap check → brainstorm, don't guess.** If the meeting left architecture/boundaries/
   trade-offs undecided, resolve them with the user via **`superpowers:brainstorming`**
   before breaking anything down.
3. **Write the arch / data-model design doc** (committed) →
   `inference/.ai-docs/design-docs/<feature>/01-data-model.md`. Capture the agreed storage,
   services, queues/jobs, data flow, decisions locked, and a **"net new vs reused"** view —
   in the spirit of the `signals/03-signals-data-model.md` doc.
4. **Derive sub-issues** (see rules below).
5. **Coverage check** (mandatory): build an explicit map of **every v1 checklist item → the
   sub-issue(s) that deliver it.** If any requirement has no home, add a sub-issue. Surface
   the map so the gap is visible before writing.
6. **Present the proposed set, get an explicit go-ahead, THEN create the sub-issues** under
   the v1 ticket in Linear. **Sub-issues are detailed and self-contained** (see the sub-issue
   rules) — unlike the high-level v1/product tickets, this is the layer where the substance
   lives.

## Sub-issue rules

- **Dev-scoped, ≈PR-sized** — one logical chunk of implementation per ticket (a layer, a
  service, a table+store, a channel+consumer), not a single user requirement and not the
  whole feature.
- **Detailed and self-contained.** Each sub-issue carries everything someone needs to pick it
  up and execute: what it delivers (the v1 requirement(s) it covers), the relevant agreed
  design for this piece (data shapes, storage, services/queues, integration points) drawn from
  the design doc, acceptance criteria / definition of done, dependencies, and pointers to the
  committed design docs. **Stop short of code-level detail and the implementation plan** —
  superpowers still writes and executes that. Target: enough that an engineer or AI can build
  the superpowers plan straight from the ticket without re-deriving the design.
- **Consolidate toward ~10–15** tickets total. Don't explode into dozens of tiny ones.
- **Reuse is not a ticket.** Existing systems you build on (mirrored patterns, existing
  stores, shared services) are integration points inside other tickets, not their own.
- **Dependency-order** them, and state the order.
- **Split every UI surface into two tickets: a POC and a Polish.** The POC (functional,
  unpolished — built by me) and the Polish (design refinement — handled by a colleague).
  One "build the UI" ticket is wrong; if a feature has a list view + a form, that's
  POC + Polish for each surface (or per logical UI area), never a single combined UI ticket.

## Red flags — you're off the rails

- A single combined "frontend"/"UI" ticket with no POC vs Polish split.
- Creating sub-issues without having written the committed arch/data-model doc.
- No explicit requirement→ticket coverage map (you "think" it's covered).
- A ticket for work that's pure reuse of an existing system.
- A thin, under-specified sub-issue that just links the design doc with too little context to pick up and build — or the opposite: code-level steps / the implementation plan dumped in (that's superpowers' job).
- Writing to Linear before showing drafts and getting a go-ahead.
- One ticket per user requirement (too granular) or one ticket for all of v1 (too coarse).

## Next step

When you're ready to implement, hand off to `inference-flow-build`.
