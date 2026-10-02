---
name: lt-context
description: Read and maintain the leadership team's shared layer in Confluence; at session start, silently load LT Focus, the latest brief, asks addressed to the user, and recent decisions; during a session, record decisions, asks, and risks as structured Confluence pages. Use at the start of any session when an LT Config note exists, and when asked to "log a decision", "raise an ask", "flag a risk", "close that ask", or "what does the LT need from me". Requires an Atlassian MCP server with Confluence tools and a configured LT Config note (see lt-setup).
---

# LT context

The shared counterpart to `claude-context`. `claude-context` is your
private memory; this is the team's. Config comes from
`Meta/Claude Context/LT Config.md` (see `lt-setup`). If it doesn't exist,
say the LT space isn't set up for this vault and stop.

## Reading (start of session)

Read silently and don't narrate it, as with `claude-context`. Everything
is **read-only** for this step.

1. **LT Focus** (`parents.focus`): the standing priorities. Treat as what
   the team is committed to.
2. **Latest brief:** newest page under `parents.briefs`.
3. **Asks addressed to me:** pages under `parents.asks-open` whose "To"
   field or title names `me`, plus overdue ones first. Also list *my*
   outstanding asks of others, so you can say what I'm waiting on.
4. **Decisions in the last 7 days:** pages under `parents.decisions`
   modified recently, so you don't re-litigate a settled decision without
   saying you are revisiting it.

Surface only what bears on the user's first message. If they open with
"what does the LT need from me", answer from item 3, overdue first.

## Writing (during a session)

Every write is shown to the user first and created only after a yes.
Attribution is part of the page ("Author" field); you act as the user.

1. **Decision made** that others should know: create a page under
   `parents.decisions` from `Templates/leadership/decision.md`. Title
   `D-YYYY-MM-DD <short name>`. Search first for an existing page on the
   same topic and revise it instead (below). Record disagreement honestly.
2. **Ask of a peer** or **risk**: create under `parents.asks-open` from
   `ask-risk.md`. Title `ASK YYYY-MM-DD · To: <name> · <short>` or
   `RISK YYYY-MM-DD · <short>`. An ask always has one named person and a
   due date; ask the user for them rather than guessing.
3. **Closing** an ask or risk: add the outcome under "Resolution", then
   move the page under `parents.asks-closed`. Only the author, or the
   person it was addressed to, closes it.
4. **Revisiting** a decision: append a dated line to its "Revisions"
   section and update Status. Never delete or rewrite the original text.
5. **LT Focus** is edited only by `focus-owner`. If the user is not the
   owner, don't edit it: draft a comment for the owner instead and post it
   as a comment only after the user approves.

## Guardrails

- One author per page. Never edit a page someone else authored, except to
  close an ask addressed to the user. Use comments to disagree or add.
- Nothing from the personal vault goes into these pages unless the user
  states it in the session. If the content might touch an individual's
  performance, pay, health, or an unannounced org change, stop and say it
  belongs in the private layer.
- If search finds two plausible pages, ask which; don't pick.
- Permissions error: report plainly; don't retry another way.
