# ClaudeTio — Obsidian as a Second Brain for Claude

A practical guide (with working config, scripts, and templates) for turning an
[Obsidian](https://obsidian.md) vault into a persistent "second brain" that
Claude can read from and write to — so your notes, projects, and decisions
carry across every conversation instead of living only in chat history.

**Video walkthrough:** [`docs/video/obsidian-second-brain.mp4`](docs/video/obsidian-second-brain.mp4)
**Narration script / storyboard:** [`docs/video-script.md`](docs/video-script.md)
**Want it narrated in your own voice?** [`docs/video/voice-clone/README.md`](docs/video/voice-clone/README.md)

---

## Why Obsidian + Claude

Obsidian vaults are just folders of plain Markdown files on disk. That makes
them an ideal "second brain" for an AI assistant:

- **No lock-in / no API needed** — Claude can read and write notes as regular
  files, so it works with Claude Code, Claude Desktop, or any MCP-compatible
  client.
- **Human and AI both edit it** — you keep using Obsidian's graph view, search,
  and plugins; Claude reads the same files and appends structured notes.
- **Durable memory** — decisions, project context, and research survive after
  a chat ends, and any future Claude session can pick them back up by reading
  the vault.
- **Linkable and searchable** — `[[wikilinks]]`, tags, and frontmatter let
  Claude build and traverse a real knowledge graph instead of a flat list of
  files.

There are two ways to connect Claude to a vault, from simplest to most
capable:

| Approach | Setup effort | What you get |
|---|---|---|
| **Filesystem access** | None (Claude Code) / minimal (Desktop) | Claude reads/writes vault files directly. No plugin required. |
| **Local REST API + MCP server** | One community plugin + one MCP server | Claude gets structured search, frontmatter/tag queries, active-note context, and periodic (daily/weekly) note helpers. |

Both are covered below.

---

## 1. Prerequisites

- [Obsidian](https://obsidian.md) installed, with a vault created (or use
  `scripts/setup-vault.sh` below to create one with a sensible structure).
- [Claude Desktop](https://claude.ai/download) and/or [Claude Code](https://claude.com/claude-code).
- Node.js 18+ (only needed for the MCP server approach in section 4).

---

## 2. Set up the vault structure

This repo ships a script that lays out a [PARA-method](https://fortelabs.com/blog/para/)
folder structure — a good default for a second brain — and drops in the note
templates from `templates/`.

```bash
./scripts/setup-vault.sh ~/ObsidianVaults/SecondBrain
```

This creates:

```
SecondBrain/
├── 00-Inbox/       # Quick capture — unsorted notes, Claude drops new notes here by default
├── 01-Projects/    # Active, time-bound efforts
├── 02-Areas/       # Ongoing responsibilities (no end date)
├── 03-Resources/   # Reference material, research, Claude-generated summaries
├── 04-Archive/     # Completed / inactive
├── Daily/          # Daily notes (YYYY-MM-DD.md)
└── Templates/      # Copied from this repo's templates/ folder
```

Open the resulting folder in Obsidian as a vault (`Open folder as vault`).

---

## 3. Option A — Filesystem access (simplest)

**Claude Code:** if you run `claude` with your vault as (or inside) the
working directory, no extra setup is needed — Claude Code already reads and
writes files directly. Just tell it where the vault lives, e.g.:

> "My Obsidian vault is at `~/ObsidianVaults/SecondBrain`. When I ask you to
> remember something, write a note into `00-Inbox` using the template in
> `Templates/claude-chat-log.md`."

**Claude Desktop:** add the official filesystem MCP server, scoped to your
vault path only:

```jsonc
// claude_desktop_config.json — see config/claude_desktop_config.example.json
{
  "mcpServers": {
    "obsidian-vault": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/absolute/path/to/SecondBrain"]
    }
  }
}
```

Restart Claude Desktop, and Claude will be able to list, read, and write
files inside that folder — nothing outside it.

---

## 4. Option B — Local REST API + `mcp-obsidian` (structured access)

For semantic search, frontmatter/tag queries, and "what's in my daily note
today" style questions, pair the **Local REST API** community plugin with the
`mcp-obsidian` MCP server.

1. In Obsidian: **Settings → Community plugins → Browse**, search for
   **"Local REST API"**, install and enable it.
2. Open its settings, enable **HTTPS**, and copy the generated **API key**.
3. Add the MCP server to your Claude config (see
   `config/claude_desktop_config.example.json`):

   ```jsonc
   {
     "mcpServers": {
       "obsidian": {
         "command": "npx",
         "args": ["-y", "mcp-obsidian"],
         "env": {
           "OBSIDIAN_API_KEY": "paste-your-local-rest-api-key-here",
           "OBSIDIAN_HOST": "127.0.0.1",
           "OBSIDIAN_PORT": "27124"
         }
       }
     }
   }
   ```
4. Restart Claude Desktop. Keep Obsidian running (the REST API only serves
   requests while the vault is open).

**Never commit your real API key.** Copy the example config, fill in the key
locally, and keep the real file out of version control (see `.gitignore` —
`claude_desktop_config.json` is already excluded).

---

## 5. Verify the connection

Ask Claude:

> "List the folders in my Obsidian vault."
> "Create a note in `00-Inbox` called `test-note.md` with today's date."
> "Search my vault for notes tagged `#project`."

If Claude can complete these, the connection is working.

---

## 6. Suggested workflow

- **Capture fast, organize later:** tell Claude to drop anything worth
  remembering into `00-Inbox` using `templates/claude-chat-log.md`; sort it
  into `01-Projects` / `02-Areas` / `03-Resources` during a weekly review.
- **Daily notes as a running log:** ask Claude to append a summary of each
  session to today's daily note (`templates/daily-note.md`) so you have a
  chronological record.
- **Weekly review:** have Claude sweep `00-Inbox` and draft a
  `templates/weekly-review.md` note — what got filed, what's stalled, what's
  next — so nothing sits unsorted for long.
- **Log decisions, not just tasks:** for anything you and Claude debate and
  settle (architecture, tooling, process), capture it with
  `templates/decision-log.md` so the reasoning survives, not just the outcome.
- **Link, don't duplicate:** encourage Claude to use `[[wikilinks]]` to
  connect new notes to existing ones instead of restating context.
- **Tag consistently:** agree on a small tag vocabulary (e.g. `#project`,
  `#decision`, `#reference`) so both you and Claude can query by tag.

---

## 7. Claude Code skills: push/pull notes to Confluence & Jira

This repo ships two [Claude Code skills](https://code.claude.com/docs) under
`.claude/skills/` that travel with the vault repo:

| Skill | What it does |
|---|---|
| `md-confluence` | Push a note to Confluence as a page (or update the linked page), or pull a Confluence page into the vault as a note. |
| `md-jira` | Turn a note (or a single task in one) into a Jira ticket, or pull a Jira issue into the vault as a note. |

Both directions keep a link back via frontmatter (`confluence-page-id`,
`jira-key`, etc.) so re-running the skill updates the same page/ticket
instead of creating duplicates — see each `SKILL.md` for the exact field
contract and the markdown ⇄ Confluence/Jira formatting mapping.

**Requires an Atlassian MCP server** (e.g. the official Atlassian Remote MCP
server) connected and authorized in your Claude client — these skills don't
talk to Confluence/Jira directly, they drive whatever Atlassian MCP tools
you've connected. If none are available, the skill will tell you to connect
one instead of guessing.

---

## 8. Troubleshooting

| Symptom | Fix |
|---|---|
| Claude says it has no file access | Confirm the MCP server entry is present and Claude Desktop was fully restarted (quit, not just closed). |
| `mcp-obsidian` connection refused | Obsidian must be running with the vault open; check the Local REST API port (default `27124`) matches your config. |
| Certificate / HTTPS errors from the REST API | The plugin uses a self-signed cert; make sure `OBSIDIAN_HOST`/`OBSIDIAN_PORT` match the plugin settings, or disable HTTPS in the plugin and use the HTTP port instead. |
| Filesystem server can't write | Check the path passed to `server-filesystem` is absolute and Claude Desktop's process has write permission to it. |

---

## Repo layout

```
├── README.md                          # this guide
├── scripts/setup-vault.sh             # creates the PARA vault structure + templates
├── templates/                         # Obsidian note templates
│   ├── daily-note.md
│   ├── project-note.md
│   ├── meeting-note.md
│   ├── claude-chat-log.md
│   ├── weekly-review.md
│   └── decision-log.md
├── config/claude_desktop_config.example.json
├── .claude/skills/                    # Claude Code skills for this vault
│   ├── md-confluence/SKILL.md         # push/pull notes <-> Confluence pages
│   └── md-jira/SKILL.md               # push/pull notes <-> Jira issues
└── docs/
    ├── video-script.md                # narration script / storyboard
    └── video/
        ├── obsidian-second-brain.mp4  # the video
        ├── build.sh                   # rebuild pipeline (slides + TTS + ffmpeg)
        └── voice-clone/               # optional: narrate in your own voice
```
