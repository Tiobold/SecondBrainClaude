---
name: daily-sync
description: End-of-day sync of the vault; append a short "Daily sync" section to today's daily note (what was captured, what happened, what's open for tomorrow), route any unlogged decisions to the Decisions Log, and flag unsorted inbox notes. Designed to run unattended on a schedule, so it only ever appends. Use when asked to "run the daily sync", "wrap up today", or when invoked by a scheduler.
---

# Daily sync

A short, safe end-of-day pass over the vault. Built to run unattended (from
a scheduler) or on demand, so it is **append-only**: it adds to today's
note and the context files, and never moves, renames, or deletes anything.

**This skill doesn't schedule itself.** Like every skill, it only runs when
invoked. See the README's "Scheduled runs" section for how to trigger it
from cron/launchd or a client's scheduled-task feature.

## Before you start

1. Read the `claude-context` files (`Meta/Claude Context/*.md`) silently, as
   at the start of any session. They tell you what's in flight.
2. Find today's `Daily/YYYY-MM-DD.md`. If it doesn't exist, create it from
   `Templates/daily-note.md` rather than skipping the day.
3. Check which optional sources are connected via `ToolSearch` (calendar,
   Slack/email/chat). Use only what's connected and say which were skipped;
   never fail the whole run because one source is missing.

## Gather

- **Captured today:** notes in `00-Inbox/` created or modified today.
  Count and list them; don't file them (filing is a human call, done in the
  weekly review).
- **Happened today:** the "Claude session log" in today's daily note, plus
  calendar events that took place (if a calendar is connected). Link
  meeting notes and `06-People/` notes with `[[wikilinks]]`.
- **Open for tomorrow:** unchecked `- [ ]` items in today's daily note and in
  `01-Projects/` notes touched today, plus tomorrow's first calendar events.
- **Unlogged decisions:** anything in today's session log or notes that reads
  as a settled decision but isn't in `Decisions Log.md` yet.

## Write

1. Add (or, if today already has one, replace only that section) a
   `## Daily sync` section at the end of today's daily note, prose-first and
   short:

   ```
   ## Daily sync
   Captured: 3 new inbox notes, none filed yet.
   Happened: Atlas sync with [[Dana Reyes]]; cutover decision logged.
   Tomorrow: 10:00 Atlas standup. Open loop: confirm backfill runtime.
   ```

   Re-running must not duplicate the section.
2. For each unlogged decision, append one sentence to today's `## YYYY-MM-DD`
   section of `Decisions Log.md`, per the `claude-context` skill.
3. Don't touch `About.md`, and don't rewrite `Current Focus.md` unattended:
   if priorities look like they shifted, put one line in the sync section
   ("Possible focus shift: ...") for the human to confirm.

## Optional: leadership contribution

If `Meta/Claude Context/LT Config.md` exists, finish by invoking the
`lt-contribute` skill **in unattended mode**: it saves a draft under
`## LT draft` in today's daily note and never publishes. Mention the draft
in your final output so the user can review and approve it. Skip this step
silently if the config doesn't exist.

## Guardrails

- Append-only. No moving, renaming, or deleting notes; no inbox filing.
- Never message anyone or post anywhere. This run only reads sources and
  writes inside the vault.
- If there is nothing to report for a heading, omit it. Don't pad.
- Final output is two lines: what was written, and what was skipped and why.
