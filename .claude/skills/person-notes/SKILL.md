---
name: person-notes
description: Maintain one note per person in 06-People/, built from mentions across the vault (meetings, transcripts, decisions, projects) and optionally enriched from connected Slack/Telegram/WhatsApp/Email MCPs. Use when asked to "update people notes", "who is X", "build a profile for X", "sync people", or as a follow-up step after processing meeting/transcript content that names attendees. Two modes: vault sync (default, safe, no external calls) and external research (explicit, requires a time range or all-time).
---

# Person notes

Keeps `06-People/Full Name.md` notes current: a running profile and
interaction timeline per person, built primarily from what's already in the
vault, optionally enriched from external chat/email sources on request.

**No background watcher runs this automatically** — Claude Code skills only
run when invoked. "Automatic" here means: `meeting-prep` and
`teams-meeting-notes` call this skill's vault-sync step for the people they
touch as the last part of their own run, and this skill also has a
whole-vault resync mode to catch anything that slipped through. If you're
wiring up a new skill that creates content naming people, have it call this
skill's sync step too.

## Frontmatter contract

```yaml
type: person
name: Jane Doe
aliases: [Jane, J. Doe, jane.doe@company.com, "@jdoe"]
role: Product Manager
org: Acme Corp
tags: [person]
first-contact: 2026-01-10
last-updated: 2026-07-01
channels:
  email: jane.doe@company.com
  slack: "@jdoe"
  telegram:
  whatsapp:
related-projects: ["[[Project Atlas]]"]
```

`aliases` is what makes matching work across sources — name variants, chat
handles, email addresses. Keep it updated whenever a new handle for the
same person turns up; without it, later syncs won't recognize them and may
create a duplicate person note instead of updating the real one.

## Mode 1: vault sync (default — safe, no external calls)

Use this whenever asked to "update people" or "sync person notes", and
whenever another skill just wrote a note naming attendees/people.

1. Scan for person mentions: `[[wikilinks]]` to `06-People/` notes,
   `attendees:` frontmatter on meeting/transcript notes, and names
   appearing in `templates/decision-log.md` / `templates/project-note.md`
   content.
2. For a person with no existing note: search `06-People/` by name and
   alias first (avoid duplicates), then create one from
   `templates/person.md` if truly new. Fill what's known; leave the rest
   blank rather than guessing.
3. For a person with an existing note: append one row per new interaction
   to the **Interaction timeline** table (date, source note, one-line
   summary). **Never rewrite prior rows or the Summary section** without
   being explicitly asked — this file is a cumulative record, not a
   snapshot.
4. Update `last-updated` in frontmatter. If a new channel/handle for a
   known person surfaces (e.g. their Slack handle appears in a transcript),
   add it to `channels`/`aliases` on the existing note rather than creating
   a second one.
5. Report which person notes were created vs. updated — don't silently
   create a batch of new files without summarizing what happened.

## Mode 1b: whole-vault resync

When asked to "resync people" or "rebuild people notes": run mode 1's scan
across the entire vault (all meeting notes, transcripts, decision logs,
project notes) instead of just recently-touched files. This is the
catch-up mechanism for anything that was added before this skill existed,
or by a process that didn't call the sync step. List how many people
notes would be created/updated before making changes if the count is
large (double digits) — a big bulk write deserves a heads-up first.

## Mode 2: external research (explicit, needs a time range)

Only run this when specifically asked to "research," "pull everything on,"
or "build a full profile for" a person — never as a side effect of mode 1.

1. Ask which person (or "all people in `06-People/`" — warn that's a
   heavier, multi-person operation and get explicit confirmation before
   running it across everyone).
2. Ask for a time range: a specific window, or "all time." Don't default to
   all-time silently — it's a much bigger and more sensitive pull than a
   bounded one.
3. Find available sources via `ToolSearch` (queries: `"slack"`,
   `"telegram"`, `"whatsapp"`, `"gmail"` / `"email"` / `"outlook"`). Use
   whichever are actually connected, and report which ones were skipped
   because nothing was found — don't fail the whole run over one missing
   source.
4. Search each connected source using the person's `aliases` (handle,
   email, display name) and the chosen time range.
5. Summarize, don't transcribe: pull out what's actually useful for a
   profile — role/context, recurring topics, commitments made either
   direction, preferred contact channel — not verbatim message dumps. Skip
   anything that reads as personal/sensitive and unrelated to working
   context (health, family, personal finances, etc.) rather than storing
   it.
6. Append findings to the same **Interaction timeline** (tag each row with
   its source: Slack/Telegram/WhatsApp/Email). Only touch `Summary` or
   `Contact` with the user's explicit review if the change is more than
   additive — same append-only default as mode 1.
7. Show what was added before considering the run done.

## Guardrails

- Never message the person or post anywhere as a side effect of this skill
  — it only reads sources and writes to the vault.
- Treat `06-People/*.md` notes as append-only for anything beyond
  frontmatter housekeeping (channels, aliases, last-updated, related
  projects) — don't rewrite someone's Summary based on one new data point.
- An "all time, all people" run is the most expensive and most sensitive
  version of this skill — always confirm scope explicitly before running
  it, and default to suggesting a bounded time range or a single person.
- If a person can't be confidently matched across sources (ambiguous name,
  no alias match), ask rather than guessing and merging two different
  people into one note.
