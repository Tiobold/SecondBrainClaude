---
name: lt-setup
description: One-time setup of a leadership team's shared second brain in Confluence; create the page skeleton (charter, focus, decisions, asks and risks, contributions, briefs) in an existing restricted space and write the personal LT Config note the other lt-* skills read. Use when asked to "set up the LT space", "set up the leadership brain", or "create the leadership second brain". Requires an Atlassian MCP server with Confluence tools. Run once, by one person; teammates then run it only in "join" mode.
---

# LT setup

Creates the shared structure for the leadership second brain (see
`docs/leadership-team.md`) and wires one person's vault to it. The shared
space is visible to the whole team, so this skill is cautious: it
confirms before creating anything and never creates the space itself.

## Before you start

1. Confirm Confluence tools exist via `ToolSearch` (query `"confluence"`).
   If none, tell the user to connect an Atlassian MCP server and stop.
2. The **space must already exist and be restricted** to exactly the LT
   members. This skill can't create or permission a space. Ask the user to
   confirm, in words, that (a) the space exists, (b) only the members have
   view and edit access, and (c) no org-wide or anonymous access is
   enabled. Do not proceed on "I think so".
3. Gather: space key, member names, who owns *LT Focus* (single person),
   the Slack channel (optional), and which mode this is:
   - **create** (first person): build the skeleton.
   - **join** (everyone else): the skeleton exists; only write the
     personal config note. Look the page IDs up rather than creating.
4. Dry run: if asked for a dry run, print what would be created and stop.

## Create mode

1. Resolve `atlassian-cloud-id` and the space ID from the key.
2. Search the space for each title below first. If a page already exists,
   reuse its ID and say so. Never create duplicates.
3. Create these pages, in order, using the matching file in
   `Templates/leadership/` as the body (fill `{{members}}`, `{{focus-owner}}`,
   `{{date}}`; use markdown content format):

   | Title | Parent | Template |
   |---|---|---|
   | LT Second Brain (home) | space root | charter.md |
   | LT Focus | home | lt-focus.md |
   | Decisions | home | short index page: "One page per decision. See Decision template." |
   | Asks and Risks | home | short index page |
   | Open | Asks and Risks | index page: "Open items." |
   | Closed | Asks and Risks | index page: "Resolved items, kept for the record." |
   | Contributions | home | index page: "One page per member per day." |
   | Briefs | home | index page: "Daily and weekly briefs." |

4. Show the user the list of pages and URLs, and ask them to open the home
   page and confirm the member list is right before telling teammates.

## Join and create: write the personal config

Write `Meta/Claude Context/LT Config.md` (path configurable, same folder as
the claude-context files) from `Templates/leadership/lt-config.md`, filling
in every field including the page IDs. If it already exists, show a diff
and update in place, never silently overwrite the user's allowlist or
denylist.

Ask the user to review `contribute-allow` and `contribute-deny` line by
line. The denylist is the main privacy control. Suggest adding any folder
that holds notes about individuals (performance, compensation, 1:1s,
health, hiring) before the first contribution is ever drafted.

## Finish

1. Add one pointer to the vault's `CLAUDE.md`, so each session starts with
   the shared layer: "Also follow the lt-context skill at the start of
   each session." Show the line; add it only if the user agrees.
2. Report: space URL, what was created vs reused, the config path, and the
   next step (run `lt-contribute` by hand once, in dry-run mode).

## Guardrails

- Never create a space, change permissions, or add members. Those are the
  Confluence admin's job.
- Never create pages in a space the user hasn't confirmed by key.
- Permissions errors: report plainly. Don't retry with other scopes.
- Don't put any personal content in the shared pages; the charter and
  index pages are the only content this skill writes.
