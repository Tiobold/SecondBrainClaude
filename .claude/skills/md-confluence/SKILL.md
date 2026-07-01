---
name: md-confluence
description: Convert between a vault note (Markdown/Obsidian) and a Confluence page, in either direction. Use when asked to publish, push, sync, or turn a note into a Confluence page, or to pull/import a Confluence page into the vault. Requires an Atlassian MCP server with Confluence tools, connected and authorized by the user.
---

# MD ⇄ Confluence

Converts between vault notes and Confluence pages, keeping them linked via
frontmatter so re-running this skill updates the same page/note instead of
creating a duplicate.

## Before you start

1. Confirm Confluence tools are actually available: use `ToolSearch` with a
   query like `"confluence"`. If nothing relevant comes back, tell the user
   to connect and authorize an Atlassian MCP server (e.g. the official
   Atlassian Remote MCP server) first, and stop there — don't guess at tool
   names, and don't fall back to scraping a Confluence URL.
2. Tool names vary by MCP server (`confluence_create_page` vs
   `createConfluencePage`, etc.). Use whatever `ToolSearch` surfaces for this
   session — don't hardcode a specific server's naming.

## Frontmatter contract

Notes synced with Confluence carry these fields once linked:

```yaml
confluence-space: ENG
confluence-page-id: "123456"
confluence-url: https://yourteam.atlassian.net/wiki/spaces/ENG/pages/123456
confluence-parent-id: "123400"   # optional
```

If these are already present, treat the note and page as linked: update in
place, don't create a new page.

## Note → Confluence

1. Read the note. If `confluence-page-id` is set, this is an update — fetch
   the current page first (so you don't clobber content someone edited
   directly in Confluence) and show a short summary of what will change
   before pushing.
2. If unlinked, ask which space (and parent page, if any) to publish under
   before creating anything — a new page is visible to the whole space, so
   don't guess.
3. Convert markdown → Confluence content:
   - `#`/`##`/`###` headings → Confluence headings, same level
   - `[[wikilink]]` → search Confluence for a page with that title; if
     found, link to it; if not, leave the text as-is and flag it instead of
     silently dropping the link
   - fenced code blocks → Confluence code block macro (preserve language)
   - `> [!note]` / `> [!warning]` callouts → Confluence info/warning/note
     panels
   - `- [ ]` / `- [x]` task lists → Confluence task list
   - tables → Confluence tables
4. Create or update the page via the MCP tool. On success, write
   `confluence-space`, `confluence-page-id`, and `confluence-url` back into
   the note's frontmatter so future syncs update in place.
5. Report the resulting Confluence URL.

## Confluence → Note

1. Ask which page (URL, page ID, or title + space) if not already given.
2. Fetch the page and convert its storage format back to markdown, using
   the same mapping as above in reverse (panels → callouts, macros → code
   blocks, etc.).
3. Default destination folder: `03-Resources/`, unless told otherwise. Use
   the page title for the note title/filename.
4. Search the vault for a note already linked to this `confluence-page-id`
   before creating one — update that note instead of duplicating it.
5. Write the frontmatter contract fields into the note either way.

## Guardrails

- Never overwrite a Confluence page without showing what's changing first —
  it's shared team content, not a private file.
- Never create a page in a space that hasn't been explicitly confirmed.
- If the MCP tools return a permissions error, report it plainly — don't
  retry with different scopes or attempt a workaround.
