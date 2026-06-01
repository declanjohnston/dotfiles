# inference-flow — Personal Skill Suite Design

**Date:** 2026-06-01
**Author:** Declan
**Status:** Implemented (all four skills authored + GREEN-verified, 2026-06-01)
**Type:** Personal tooling (Claude Code skills), lives in `~/dotfiles/maintained_global_claude/skills/` (symlinked to `~/.claude/skills/`)

---

## 1. Purpose

A suite of four personal Claude Code skills that wrap **my company's feature-delivery
workflow** around **superpowers**, my preferred development flow. The company mandates
its Linear/PM process; superpowers is where I want to do design-gap-filling, planning,
and execution. These skills integrate the two so I can move from a product meeting to
shipped, ticket-tracked code with minimal manual glue.

**Audience:** me (personal accelerator), not team-wide. Skills encode *my* preferences
and conventions, not a published company standard.

**Success looks like:** I can hand a meeting transcript to a skill and get the right
artifacts (checklists, Linear tickets, prep talking points, sub-issues, plans) produced
the way I produced them by hand for the Signals feature — with superpowers invoked for
anything it already does well.

---

## 2. The workflow being modeled

Two **human, team** meetings bracket the automated work:

```
[Meeting 1: Product design] ── human ──▶ transcript + notes
        │
        ▼
  inference-flow-distill        (Skill A)
        │   ├─ user-requirement checklist (+ v1/future split)
        │   ├─ Linear: parent product ticket + v1 ticket
        │   └─ infra-meeting prep doc (talking points)
        ▼
[Meeting 2: Infra/arch design] ── human ──▶ transcript + notes
        │
        ▼
  inference-flow-breakdown      (Skill B)
        │   ├─ arch / data-model design doc
        │   └─ Linear: dev-scoped sub-issues under the v1 ticket
        ▼
  inference-flow-build          (Skill C)
            └─ superpowers: writing-plans → execute → close ticket(s)
```

Superpowers' **brainstorming** skill is *not* the primary design engine (design happens
in the human meetings). It is invoked **conditionally as a gap-filler** when a transcript
is thin or informal and decisions are missing.

---

## 3. Skills

Naming convention: `inference-flow-{name}`. The index uses the bare root `inference-flow`.

| Skill | Phase | One-line trigger |
|---|---|---|
| `inference-flow` | index | "what's our feature flow?" / starting a new feature |
| `inference-flow-distill` | after Meeting 1 | have a product-design transcript; need the user-req checklist, tickets, and infra-meeting prep |
| `inference-flow-breakdown` | after Meeting 2 | have an infra/arch transcript; v1 ticket exists; need engineering sub-issues |
| `inference-flow-build` | implementation | ready to build a v1 sub-issue (or a whole small v1) |

### 3.1 `inference-flow` (index)

A short (<150 word) orientation skill. Explains the four-phase flow, when to reach for
each of the other three skills, and that superpowers is the underlying dev engine
(brainstorming = gap-filler; writing-plans + execution = build). Points to the other
skills **by name** (no `@` force-loading). Triggered when starting a feature or asking
about the flow.

### 3.2 `inference-flow-distill` (Skill A — after Meeting 1)

**Input:** product-design transcript + notes; feature name; optional existing Linear
ticket IDs and any existing design docs.

**Process:**
1. Read transcript/notes (+ existing ticket/docs if provided).
2. Extract every desired user experience as a candidate **"A user can …"** item.
3. Bucket each into **`[v1]` / `[fast-follow]` / `[v2]` / `[future]`** from what the
   meeting decided. Flag items where the iteration wasn't decided.
4. **Gap check** — if scope / UX detail / v1-inclusion is ambiguous or the transcript is
   thin, invoke `superpowers:brainstorming` to resolve interactively. **Never fabricate
   requirements.**
5. Commit the **product spec** → `inference/.ai-docs/design-docs/<feature>/00-product-spec.md`:
   the grouped user-perspective checklist + the v1-vs-later rationale.
6. **Present drafts, get explicit go-ahead, then write to Linear:**
   - **Parent product ticket** — the full checklist across all iterations, **v1 items
     checked**, items tagged by iteration.
   - **v1 ticket** (child of parent) — **v1 items only, unchecked** (they are work to do).
7. Produce the **infra-meeting prep doc** (see §4) — **mandatory, uncommitted**.

**Output:** committed product spec; populated parent + v1 Linear tickets; an uncommitted
prep doc of talking points for Meeting 2.

### 3.3 `inference-flow-breakdown` (Skill B — after Meeting 2)

**Input:** infra/arch-design transcript + notes; v1 ticket ID; the prep doc; the product spec.

**Process:**
1. Synthesize the agreed architecture → commit a **design / data-model doc**
   (`inference/.ai-docs/design-docs/<feature>/01-data-model.md`, in the spirit of the
   `signals/03-signals-data-model.md` doc: storage map, tables/queues/jobs, services,
   data flow, decisions locked, "net new vs reused").
2. **Gap check** — undecided architecture / unclear component boundaries / unresolved
   trade-offs invoke `superpowers:brainstorming`.
3. Derive **dev-scoped, ≈PR-sized sub-issues** that together satisfy the v1 checklist.
   Consolidate toward **~10–15** logical chunks. **UI surfaces split into POC (me) +
   Polish (colleague).** Dependency-order them.
4. **Coverage check** — map each sub-issue back to the v1 checklist items; surface
   anything left uncovered before writing.
5. Present the proposed set; on go-ahead, **create the sub-issues under the v1 ticket**
   in Linear, each description dev-scoped and referencing the design docs.

**Output:** committed arch/data-model doc; Linear sub-issues under the v1 ticket.

### 3.4 `inference-flow-build` (Skill C — implementation)

**Input:** a sub-issue ID (large project) **or** the v1 ticket (small project).

**Process:**
1. **Pick mode by size:** per-sub-issue cycle (large features) vs one plan covering all of
   v1 (small features). Heuristic on sub-issue count / scope; confirm with me when unsure.
2. Gather context: pull the relevant Linear ticket(s) + the committed design docs.
3. **Probe the repo's testing structures** *before* planning: what test runner/framework is
   used (e.g. vitest), the commands (e.g. `bun run test:unit`, `bun test <file>`,
   `task integration-test`), unit-vs-integration-vs-e2e split, fixture/helper conventions,
   and any repo-local testing skills (e.g. this monorepo's `running-tests` / `writing-tests`).
   The plan must conform to what's already there — don't invent a parallel test setup.
4. **Ask whether to isolate in a git worktree** (`superpowers:using-git-worktrees`) — do
   **not** default to one; if I decline, work in the current branch.
5. `superpowers:writing-plans` → a detailed bite-sized TDD plan. **The plan is a scratch
   artifact: written to `docs/superpowers/plans/` and never committed.** The plan MUST
   contain an explicit **Testing** section that marries superpowers TDD (the RED→GREEN→
   refactor discipline) with the repo conventions found in step 3 — exact test commands,
   where test files live, which layer (unit/integration/e2e) each task is tested at, and the
   repo's assertion/fixture patterns. No generic "add tests" placeholders.
6. Execute via `superpowers:subagent-driven-development` (recommended) or
   `superpowers:executing-plans`.
7. On completion: update/close the Linear ticket(s); wrap with
   `superpowers:finishing-a-development-branch`.

**Output:** shipped, tested code + PR; Linear ticket(s) updated/closed.

---

## 4. The infra-meeting prep doc (Skill A output)

**Purpose:** prepare *me* to **run** Meeting 2 — primarily a list of decisions to drive
to closure. **Mandatory, uncommitted** — written into the feature's design-docs folder
(`inference/.ai-docs/design-docs/<feature>/infra-prep.md`) but never staged/committed.

**The code exploration always happens.** Producing good talking points *requires*
understanding what already exists and what the feature builds around — so the skill always
explores the codebase. The optional sections below are only about whether those findings
are **written into the doc**, not whether the exploration is done.

| Section | Required? | Content |
|---|---|---|
| **Open questions for the meeting** | **Mandatory** | The concrete decisions the team must make (storage engine, queueing, data-model shape, integration approach, …), phrased as discussion points so I can lead the meeting. Each may carry a candidate recommendation to seed debate. |
| What exists | Optional | Existing packages/services/tables/patterns the feature touches or mirrors, with file pointers. |
| Reuse vs net-new | Optional | What can be built on / mirrored vs what is genuinely new. |
| Integration points | Optional | Where the new feature hooks into existing systems. |

Optional sections are included or omitted based on how familiar I already am with the area
(the skill asks). Even when omitted, the underlying exploration still informs the mandatory
open-questions section.

---

## 5. Cross-cutting conventions

- **User-requirement phrasing:** from the user's POV — *"A user can …"*.
- **Iteration tags:** `[v1]` · `[fast-follow]` · `[v2]` · `[future]`.
- **Ticket shape:** parent = full checklist (v1 checked); v1 child = v1 items unchecked;
  sub-issues = dev-scoped, ≈PR-sized, ~10–15, dependency-ordered, UI split POC + Polish.
- **Always present drafts and get a go-ahead before any Linear write** (the pattern used
  on Signals).
- **Lean on superpowers** for what it does well; never re-implement brainstorming,
  planning, worktrees, execution, or branch-finishing.

### 5.1 Artifacts & commit policy

| Artifact | Location | Committed? |
|---|---|---|
| Product spec | `inference/.ai-docs/design-docs/<feature>/00-product-spec.md` | **Yes** |
| Arch / data-model doc | `inference/.ai-docs/design-docs/<feature>/01-data-model.md` | **Yes** |
| Infra-meeting prep doc | `inference/.ai-docs/design-docs/<feature>/infra-prep.md` | **No** — skill simply never `git add`s it (not git-ignored) |
| Superpowers plans | `docs/superpowers/plans/` | **No** |

The product spec and arch/data-model doc are committed to the **company monorepo**. The
prep doc lives **alongside** them in the feature folder for convenience, but the skill
leaves it uncommitted (no git-ignore — it just doesn't stage it). Superpowers plans are
personal scratch and never committed.

### 5.2 Linear integration

Skills use the Linear MCP tools (as used on Signals: `get_issue`, `save_issue`, etc.).
Parent product ticket and v1 ticket are created/updated by Skill A; sub-issues by Skill B,
each as a child of the v1 ticket. Team / project are inferred from the existing ticket
context or asked once. Bracket tags (`[v1]`) render fine even if Linear escapes them in
stored markdown (observed on Signals — worth a note in the skill, not a blocker).

---

## 6. How these skills will be authored

These are **technique / process skills** (not discipline-enforcing rule skills). They will
be created via `superpowers:writing-skills` (TDD-for-docs):

- **Baseline (RED):** give a subagent a sample meeting transcript with no skill; observe
  what artifacts it produces and where it goes wrong (misses the v1 split, fabricates
  requirements, writes to Linear without confirming, skips the prep doc, etc.).
- **Write (GREEN):** author the skill addressing those specific failures.
- **Refactor:** feed varied transcripts (thorough vs thin/informal) and verify the
  gap-filling path and artifact correctness.

The **Signals session** (this feature's origin) is the canonical worked example: the
INF-3134 parent checklist, INF-3215 v1 checklist, the `signals/00`–`03` design docs, and
the 11 consolidated sub-issues are the reference outputs each skill should be able to
reproduce from the same inputs.

> **Note on the brainstorming → writing-plans handoff:** the brainstorming skill's default
> terminal step is `writing-plans`. Here the deliverable is *skills*, so the correct next
> step is `superpowers:writing-skills` (TDD-for-docs), which is purpose-built for authoring
> skills. This is an intentional deviation, justified by the deliverable type.

---

## 7. Out of scope

- Team-wide publishing / documentation of the workflow as a company standard.
- Automating the human meetings themselves.
- A standalone codebase-recon skill (the recon lives inside Skill A for now; may graduate
  later if I want it outside this flow).
- Splitting Skill C's planning and execution into separate skills (superpowers already
  separates them; C only orchestrates).
