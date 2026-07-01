---
name: claude-context
description: Read and maintain the vault's persistent session-context layer (About, Current Focus, Open Threads, Decisions Log) so decisions/priorities/open questions survive across sessions instead of living only in chat history. Use at the start of any session in this vault (silently, before responding), whenever asked to "remember this" or "update my context", and at the end of a session that produced decisions or priority changes worth keeping.
---

# Claude Context

Maintains four files that together form the vault's session-context layer,
read at the start of a session and written to during/at the end of one —
the piece that makes the vault a second brain across sessions, not just a
place notes happen to live.

**Default location:** `Meta/Claude Context/About.md`, `Current Focus.md`,
`Open Threads.md`, `Decisions Log.md`. **This path is configurable** — not
every vault uses this exact folder name. If a vault uses a different
location, note it once and use it for the rest of the session rather than
asking every time.

**This skill doesn't run itself at session start** — like every Claude
Code skill, it only runs when invoked. The actual trigger for "read this
before responding" is external: a one-line pointer in `CLAUDE.md` for
Claude Code, or the equivalent added to a custom system prompt / project
instructions for Claude Desktop and other clients. See the README section
on wiring this up. What follows assumes that trigger has fired.

## Frontmatter contract

```yaml
type: claude-context
context: about | current-focus | open-threads | decisions-log
tags: [claude-context]
last-updated: YYYY-MM-DD
```

## Before you start

1. Confirm the four files exist at the configured path. If one is missing,
   ask before creating it rather than silently scaffolding a new structure
   mid-session — `scripts/setup-vault.sh` creates the intended default
   layout from `templates/claude-context/`.

## Reading (start of session)

1. Read all four files before responding to the first message. This is
   context-loading, not a task — don't narrate that it happened ("I read
   your Claude Context files") unless asked what's in them.
2. Treat `About.md` as background, `Current Focus.md`'s most recent dated
   section as what matters right now, `Open Threads.md` as things that
   might resurface, and `Decisions Log.md`'s recent entries as what was
   already settled — don't re-litigate a decision that's already logged
   without saying you're revisiting it.

## Writing (during / end of session)

Trigger: an explicit request ("remember this", "update my context"), or
the end of a session that produced decisions/updates worth keeping. Don't
write after every message — batch it.

Route what happened to the right place:

1. A decision was made → append one sentence to today's `## YYYY-MM-DD`
   section in `Decisions Log.md` (create the section if today doesn't have
   one yet). Prose, one sentence per item — not a bullet list.
2. A priority shifted → update `Current Focus.md`: add or revise today's
   dated section as a short condensed narrative. Link to `01-Projects/`
   notes for detail instead of repeating it here.
3. A new open question surfaced without a home yet → append it to
   `Open Threads.md`.
4. An open thread got resolved → remove it from `Open Threads.md`
   entirely. It moves into `Decisions Log.md` or a project note instead —
   never leave a resolved item marked done in both places.
5. The update is specific to one project → append it to that project's
   `01-Projects/` note instead of `Current Focus.md` — Current Focus stays
   a condensed cross-project view, not a duplicate of project detail.
6. A standalone insight doesn't fit any of the above → new note in
   `00-Inbox/` (see `templates/claude-chat-log.md`) rather than forcing it
   into one of the four context files.
7. `About.md` is the exception: only touch it on explicit request. Don't
   infer stable facts from one session's conversation.

## Condense on write

Large single files cause MCP/tool read-write timeouts in practice — that's
the actual reason for this rule, not tidiness.

1. Before appending to `Current Focus.md` or `Decisions Log.md`, check its
   length. If it's over roughly 500 lines:
   - Summarize older dated sections down to a sentence or two each,
     keeping the most recent few weeks at full length.
   - Move the condensed-away detail into a dated archive note next to the
     original (e.g. `decisions-log-archive.md`,
     `current-focus-archive.md`), appending to it if one already exists.
   - Leave a one-line pointer where the condensed range used to be, e.g.
     "See decisions-log-archive.md for entries before 2026-04."
2. Do this as part of the same write, not a separate step the user has to
   ask for — a file crossing the threshold gets condensed before the new
   entry is added, not after.

## Guardrails

- Never rewrite or delete a prior dated entry — only append new entries or
  condense old ones per the rule above. Condensing summarizes; it doesn't
  discard meaning.
- Never invent content for a section that's genuinely empty (e.g. no open
  threads right now) — leave it empty rather than filling it with filler.
- Don't write after every message — batch updates to an explicit request
  or the end of a session, per the trigger above.
- `About.md` changes only on explicit request, never inferred.
