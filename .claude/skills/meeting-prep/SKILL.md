---
name: meeting-prep
description: Prepare a short briefing before a calendar meeting by pulling related notes (project, people, past meetings, decisions) from the Obsidian vault. Use when asked to "prep for" a meeting or "brief me" ahead of one. Works with Google Calendar or Outlook, whichever is connected.
---

# Meeting prep

Builds a short briefing note before a meeting, linked from today's daily
note, so the user walks in with context instead of reconstructing it from
memory.

## Before you start

Find calendar tools via `ToolSearch` (query `"calendar"`) — this could be
Google Calendar or Outlook/Microsoft 365 tools. Use whichever is connected;
if both are, ask which one only if it isn't obvious from context.

## Find the meeting

1. If given a meeting name or time, look it up directly. Otherwise ask
   which meeting — or default to "the next one on the calendar" if the
   user just says "prep me for my next meeting."
2. Pull attendees, title, description/agenda, and any attached
   documents/links from the event.

## Gather vault context

Search the vault for anything relevant:

- Notes whose title or `[[wikilinks]]` match attendee names
- `01-Projects/` notes matching the meeting title or description keywords
- Past `templates/meeting-note.md` notes with overlapping attendees or a
  similar title (previous meetings in the same series)
- Relevant `templates/decision-log.md` entries touching the same topic
- Open `- [ ]` tasks tied to this project or person that might come up

If nothing relevant turns up, say so plainly rather than padding the
briefing with loosely related notes.

## Write the briefing

Create (or update, if one already exists for this meeting) a note based on
`templates/meeting-note.md`, pre-filled with:

- Attendees and agenda, from the calendar event
- "Since last time" — a short recap from the most recent related meeting
  note, if any
- Open items or decisions relevant to this meeting
- Suggested talking points, only where there's real signal for them (open
  questions, blockers, overdue items) — don't invent an agenda

Link the briefing from today's daily note.

## Guardrails

- Don't fabricate history — if no past meeting or relevant project note
  exists, say the briefing is light on context rather than inventing
  plausible-sounding backstory.
- This only reads the vault and calendar; it doesn't message anyone or
  change any notes other than the briefing itself.
