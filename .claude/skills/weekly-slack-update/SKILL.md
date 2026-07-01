---
name: weekly-slack-update
description: Draft and send a concise weekly summary of the user's work to a Slack channel, pulled from their Obsidian vault (daily notes, project activity, decisions). Use when asked for a "weekly update", "team update", or "status update to Slack". Requires a Slack MCP connection.
---

# Weekly Slack update

Summarizes the week from the vault and posts it to a Slack channel — always
as a draft-then-approve flow, since posting to a shared channel is a
visible, hard-to-undo action.

## Before you start

Confirm Slack tools are available via `ToolSearch` (query `"slack"`). If
none are connected, say so and stop.

## Gather the week

1. Default window: Monday through today (or the last 7 days if today is
   Monday). Ask if a different range is wanted.
2. Read this week's `Daily/YYYY-MM-DD.md` notes, including the "Claude
   session log" section from `templates/daily-note.md`.
3. Read anything in `01-Projects/` touched this week (frontmatter dates, or
   ask which projects to include if that's unclear).
4. Pull in `templates/decision-log.md` entries dated this week — decisions
   are usually the most useful thing to share — and anything moved into
   `04-Archive/` (i.e. finished).
5. Skip anything that reads as private/personal. If it's unclear whether a
   note is meant for the team, ask rather than including it.

## Draft the summary

Keep it short — a team update, not a report:

```
*Weekly update — [date range]*

*Shipped / done*
- ...

*In progress*
- ...

*Decisions*
- ...

*Blocked / need input*
- ...
```

Only include sections that have real content. Strip anything that reads as
internal chatter or half-formed thoughts.

## Confirm before sending

1. Show the full draft and which Slack channel it will go to.
2. Ask which channel if not already specified — never guess a destination
   for a message this visible.
3. Only send after explicit approval. If asked to revise, redraft and
   reconfirm rather than sending the edited version straight away.

## After sending

Optionally log a short line back into today's daily note — what was sent,
where, and when — so the vault has a record of the update too.
