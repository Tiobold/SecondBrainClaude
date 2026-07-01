---
name: teams-meeting-notes
description: Find calendar meetings with Microsoft Teams links, retrieve the meeting transcript, save it in the vault's transcript folder, and write a summary with action items. Proposes (never silently applies) updates to relevant decision-log or project notes when a transcript touches them. Use when asked to "pull meeting transcripts", "summarize my Teams meetings", or "process this week's meetings". Requires the Microsoft 365 MCP connection (Outlook calendar + Teams transcripts), authorized by the user.
---

# Teams meeting transcripts → vault

Turns Teams meeting transcripts into vault notes: raw transcript archived,
a short summary with action items on top, and — when relevant — proposed
updates to existing project/decision notes. Never a silent overwrite.

## Before you start

Confirm Microsoft 365 tools are available via `ToolSearch` (query
`"outlook"` or `"microsoft"`). Specifically need `outlook_calendar_search`
and `read_resource`. If they're not both available, say so and stop rather
than guessing at a workaround or trying another data source.

## Find candidate meetings

1. Default window: today, unless told otherwise (e.g. "this week", a date
   range, or a specific meeting).
2. `outlook_calendar_search` for events in that window.
3. For each event, `read_resource` on `calendar:///events/{eventId}` to
   get full details, including whether a `meetingTranscriptUrl` is present.
   Skip events without one — not every meeting has a transcript yet
   (Teams can take a while to generate one after the meeting ends), and
   that's expected, not an error.
4. If several meetings qualify, list them and confirm which to process
   before pulling any transcript content — don't chew through a backlog of
   meetings without the user seeing the list first.

## Retrieve and store the transcript

1. `read_resource` on `meeting-transcript:///events/{joinUrlToken}`, using
   the event's `meetingTranscriptUrl` value verbatim — don't hand-construct
   this URI yourself.
2. Save the raw transcript into a dedicated folder: `05-Meeting-Transcripts/`
   (created by default by `scripts/setup-vault.sh`; create it if an older
   vault doesn't have it yet).
3. Filename: `YYYY-MM-DD - Meeting Title.md`. Frontmatter:

   ```yaml
   type: meeting-transcript
   date: YYYY-MM-DD
   meeting: Meeting Title
   attendees: [Name One, Name Two]
   calendar-event-id: "..."
   tags: [transcript]
   ```

4. Note layout, top to bottom: frontmatter → **Summary** → **Action
   items** → **Related notes** → `---` → full raw transcript. The summary
   and actions go first since that's what actually gets read; the
   transcript is there for reference and search, not for reading top to
   bottom.

## Summarize

- Summary: 3-6 sentences — what was discussed and decided, not a
  play-by-play.
- Action items: `- [ ] (Owner) Action — due date if one was mentioned`.
  Only include things stated as actual commitments, not every topic that
  came up in passing.

## Cross-link to existing notes

Search the vault (title, tags, attendee names, project keywords from the
transcript) for related `01-Projects/` or `templates/decision-log.md`
notes.

- If there's a clear match, propose an addition — e.g. a new row in that
  project's Decisions table, or a new decision-log entry linking back to
  the transcript note — and show the proposed change before writing it.
- **Never rewrite or remove existing content in a project/decision note.**
  Only append, and only after confirmation. These notes are the vault's
  record of past decisions — treat them as append-only from this skill.
- If nothing clearly matches, don't force a link. Let the transcript note
  stand on its own rather than bolting it onto an unrelated project.

## Guardrails

- Transcripts can contain sensitive discussion — don't post any part of one
  to Slack/Confluence/Jira as a side effect of this skill. Storing it in
  the vault and proposing note updates is the full scope here.
- If a transcript isn't available yet, say so rather than treating it as a
  failure.
