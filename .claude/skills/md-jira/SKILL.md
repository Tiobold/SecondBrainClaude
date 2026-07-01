---
name: md-jira
description: Convert between a vault note (or a task within one) and a Jira issue, in either direction. Use when asked to create/sync a ticket from a note, turn a task into a ticket, or pull a Jira issue into the vault. Requires an Atlassian MCP server with Jira tools, connected and authorized by the user.
---

# MD ⇄ Jira

Converts between vault notes/tasks and Jira issues, keeping them linked via
frontmatter so re-running this skill updates the same issue/note instead of
creating a duplicate.

## Before you start

1. Confirm Jira tools are actually available: use `ToolSearch` with a query
   like `"jira"`. If nothing relevant comes back, tell the user to connect
   and authorize an Atlassian MCP server first, and stop there.
2. Tool names vary by MCP server — use whatever `ToolSearch` surfaces for
   this session, don't hardcode a specific server's naming.

## Frontmatter contract

```yaml
jira-key: PROJ-123
jira-url: https://yourteam.atlassian.net/browse/PROJ-123
jira-project: PROJ
jira-status: "To Do"   # Jira is always the source of truth for status
```

## Note → Jira

1. If the note (or the specific task line) already has a `jira-key`, this is
   an update, not a new ticket — fetch the current issue first and show what
   will change before pushing.
2. If unlinked: don't assume a project. Ask which Jira project and issue
   type (Task/Bug/Story) to use, unless already specified.
3. A whole note (e.g. `project-note.md`) or a single checklist item can
   become a ticket. If asked to convert a note with multiple `- [ ]` tasks,
   ask whether that's one ticket for the whole note or one ticket per task
   before creating anything.
4. Map fields:
   - Note title / task text → issue summary
   - Note body (minus frontmatter) → issue description
   - `tags:` frontmatter → labels
   - `[[wikilinks]]` to other notes that already carry a `jira-key` → Jira
     issue links
5. Before creating, search Jira for existing issues with a similar summary
   in the target project to avoid an accidental duplicate — show anything
   close before proceeding.
6. Create/update the issue, then write `jira-key`, `jira-url`, and
   `jira-project` back into the note's frontmatter (or inline next to the
   specific checklist item, e.g. `- [ ] Fix login bug (PROJ-123)`, for a
   per-task ticket).

## Jira → Note

1. Ask for the issue key if not given.
2. Fetch the issue and convert its description to markdown.
3. Search the vault for a note already linked to this `jira-key` before
   creating one — update that note instead of duplicating it. Otherwise
   create a new note (default `01-Projects/` for stories/tasks tied to an
   active project, or ask).
4. Reflect `status`, `assignee`, and `priority` into frontmatter. Jira stays
   the source of truth for status — don't let local edits to the note
   silently overwrite it on the next sync without flagging that.

## Guardrails

- Never create a ticket without confirming the project and issue type first
  — it lands on a shared team board.
- Always search for near-duplicate summaries before creating.
- If the MCP tools return a permissions error, report it plainly — don't
  retry with different scopes or attempt a workaround.
