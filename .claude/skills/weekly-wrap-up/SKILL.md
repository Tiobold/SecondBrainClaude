---
name: weekly-wrap-up
description: Friday wrap-up of the week; build the weekly review note from the week's daily notes, decisions, open threads, and project activity, and prepare (never send) a Slack draft via weekly-slack-update. Designed to run unattended on a schedule. Use when asked to "wrap up the week", "do the weekly review", or when invoked by a scheduler.
---

# Weekly wrap-up

Turns the week's daily notes into one weekly review note and a ready-to-
approve team update. Built to run unattended on a schedule, so everything
it writes is additive and anything outward-facing stays a draft.

**This skill doesn't schedule itself.** See the README's "Scheduled runs"
section for how to trigger it.

## Before you start

1. Read the `claude-context` files silently.
2. Window: Monday through today (or the last 7 days if today is Monday).
   The note name is the ISO week, e.g. `Weekly/2026-W40.md`.

## Gather

- `Daily/` notes in the window, including each "Daily sync" and "Claude
  session log" section.
- `Decisions Log.md` entries dated in the window.
- `Open Threads.md`: what's still open, and what was resolved this week
  (resolved items live in the Decisions Log or project notes, not here).
- `01-Projects/` notes modified in the window; anything moved to
  `04-Archive/` counts as finished.
- `00-Inbox/`: how many notes are still unsorted. Report the count; don't
  file anything unattended.

## Write the weekly review

Create `Weekly/YYYY-Www.md` from `Templates/weekly-review.md` (create the
`Weekly/` folder if it's missing; if the note already exists, update only
the sections you generated). Fill in:

- **Projects:** active, completed this week, stalled/needs attention, with
  `[[wikilinks]]` to the project notes.
- **Highlights:** decisions and outcomes, one sentence each, in prose.
- **Next week:** `- [ ]` items drawn from open loops and stalled projects.
- **Inbox sweep:** the unsorted count, left unchecked for the human.

Never invent progress: if a section has no signal, say "nothing this week".

## Draft the team update

Follow the `weekly-slack-update` skill to draft the summary, but stop at the
draft. Even when this runs unattended, **never post**: save the draft in the
weekly note under `## Slack draft` with the intended channel, and end the run
by saying it is waiting for approval. Posting happens only when a person
later says to send it.

## Guardrails

- Additive only: no moving, deleting, or rewriting existing notes. Condense
  `Current Focus.md` / `Decisions Log.md` only under the `claude-context`
  skill's condense-on-write rule.
- Don't change `About.md` or `Current Focus.md` unattended; list suggested
  changes in the weekly note instead.
- Skip anything that reads as private or personal, as in
  `weekly-slack-update`.
