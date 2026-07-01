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

## Quick start (automated)

```bash
git clone https://github.com/Tiobold/ClaudeTio.git
cd ClaudeTio
./scripts/setup-all.sh ~/ObsidianVaults/SecondBrain
```

This creates the vault, downloads and enables the Local REST API plugin,
and wires both Claude Desktop and Claude Code — everything sections 1-6
below do by hand, run for you. It ends with a short checklist of the two
or three things nothing can script (Obsidian has to actually run once to
generate its own API key). Flags: `--desktop` / `--code` (configure just
one client instead of both), `--skip-plugin`, `--api-key KEY` — see the
comment header in `scripts/setup-all.sh` for details, or run the
individual scripts it calls — `scripts/install-obsidian-plugin.sh`,
`scripts/configure-claude-desktop.sh`, `scripts/configure-claude-code.sh`
— on their own.

The sections below explain what each step actually does and how to do it
by hand if you'd rather not run scripts that touch your Claude config —
read on if you want the manual path, or to understand/troubleshoot what
the automated one just did.

---

## 1. Prerequisites

- [Obsidian](https://obsidian.md) installed, with a vault created (or use
  `scripts/setup-vault.sh` below to create one with a sensible structure).
- [Claude Desktop](https://claude.ai/download) and/or [Claude Code](https://claude.com/claude-code).
- Node.js 18+ for Option A's filesystem MCP server; **Node.js 24+** (or
  [Bun](https://bun.sh/) 1.3+) for Option B's `obsidian-mcp-server` — see
  section 4.

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
├── CLAUDE.md                    # Claude Code session-context trigger (see section 5)
├── 00-Inbox/                    # Quick capture — unsorted notes, Claude drops new notes here by default
├── 01-Projects/                 # Active, time-bound efforts
├── 02-Areas/                    # Ongoing responsibilities (no end date)
├── 03-Resources/                # Reference material, research, Claude-generated summaries
├── 04-Archive/                  # Completed / inactive
├── 05-Meeting-Transcripts/      # Teams transcripts (see teams-meeting-notes skill)
├── 06-People/                   # One note per person (see person-notes skill)
├── Meta/Claude Context/         # Session-context layer (see claude-context skill) — path is configurable
├── Daily/                       # Daily notes (YYYY-MM-DD.md)
└── Templates/                   # Copied from this repo's templates/ folder
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
vault path only (`scripts/configure-claude-desktop.sh` writes this — and
the Option B entry below — into your real config for you):

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

## 4. Option B — Local REST API + `obsidian-mcp-server` (structured access)

For section-aware reads/edits, tag and frontmatter management, and
folder-scoped permissions — the depth the skills in this repo actually use
— pair the **Local REST API** community plugin with
[`obsidian-mcp-server`](https://github.com/cyanheads/obsidian-mcp-server):
14 tools covering reads, writes, surgical patches (append/prepend/replace
against a heading, block, or frontmatter field), tag/frontmatter
management, and search (text, JSONLogic, and BM25 via the optional
Omnisearch plugin).

1. In Obsidian: **Settings → Community plugins → Browse**, search for
   **"Local REST API"**, install and enable it (v4.0.0 or later). Or run
   `scripts/install-obsidian-plugin.sh /path/to/vault` to download and
   stage it for you — see that script's header for exactly what it
   automates and what it can't (Obsidian has to run once for the plugin to
   generate its API key).
2. Open its settings, enable **HTTPS**, and copy the generated **API key**.
3. Add the MCP server to your Claude config (see
   `config/claude_desktop_config.example.json`, or let
   `scripts/configure-claude-desktop.sh` / `scripts/configure-claude-code.sh`
   write it for you — both back up your existing config first and only
   touch the entries they manage):

   ```jsonc
   {
     "mcpServers": {
       "obsidian": {
         "command": "npx",
         "args": ["-y", "obsidian-mcp-server@latest"],
         "env": {
           "MCP_TRANSPORT_TYPE": "stdio",
           "OBSIDIAN_API_KEY": "paste-your-local-rest-api-key-here",
           "OBSIDIAN_BASE_URL": "https://127.0.0.1:27124",
           "OBSIDIAN_VERIFY_SSL": "false"
         }
       }
     }
   }
   ```

   Requires **Node.js 24+** (or [Bun](https://bun.sh/) 1.3+) — newer than
   the Node 18+ needed for Option A; check your Node version before this
   step.
4. Restart Claude Desktop. Keep Obsidian running (the REST API only serves
   requests while the vault is open).

**Optional: scope what the server can touch.** `OBSIDIAN_READ_PATHS` /
`OBSIDIAN_WRITE_PATHS` (comma-separated, prefix-matched vault folders)
restrict reads/writes to specific folders; `OBSIDIAN_READ_ONLY=true`
disables writes entirely. Unset (default) is full-vault read/write — see
the [server's configuration reference](https://github.com/cyanheads/obsidian-mcp-server#configuration)
for the full env var list.

**Never commit your real API key.** Copy the example config, fill in the key
locally, and keep the real file out of version control (see `.gitignore` —
`claude_desktop_config.json` is already excluded).

---

## 5. Persistent session context

Everything above gets Claude reading and writing vault files. This section
is the piece that makes it a *second brain across sessions* rather than
just a folder Claude happens to have access to: a small set of files Claude
reads before responding and writes to as a session wraps up, so decisions,
priorities, and open questions survive without living only in that
session's chat history.

This repo's `claude-context` skill (`.claude/skills/claude-context/SKILL.md`)
defines four files, seeded by `scripts/setup-vault.sh` from
`templates/claude-context/` into `Meta/Claude Context/` by default (the path
is configurable):

| File | Purpose |
|---|---|
| `About.md` | Stable facts about you — role, working style, standing preferences. Changes rarely, only on request. |
| `Current Focus.md` | Active projects/priorities as a condensed, dated narrative. |
| `Open Threads.md` | Questions/ideas without a home yet — removed once resolved, not marked done. |
| `Decisions Log.md` | A running, dated, prose log of day-to-day decisions — distinct from `templates/decision-log.md`, which is for a single decision significant enough to warrant its own note. |

**The skill only defines what to read and how to route writes — it doesn't
trigger itself at session start.** That trigger has to be wired up per
client:

**Claude Code:** Claude Code auto-loads a `CLAUDE.md` file from the working
directory at the start of every session, so the recommended wiring is a
one-line pointer in your vault's `CLAUDE.md`. `scripts/setup-vault.sh`
generates this for you from `templates/CLAUDE.md.example` (substituting the
`Meta/Claude Context` path if you've customized it) — nothing further to
compose by hand.

**Claude Desktop (or any client without an auto-loaded memory file):** add
the same instruction manually, as a custom system prompt or project
instructions block:

> Before responding, silently read `Meta/Claude Context/About.md`,
> `Current Focus.md`, `Open Threads.md`, and `Decisions Log.md` from my
> Obsidian vault. Don't narrate that you read them. At the end of a session
> that produced decisions or priority changes worth keeping, update the
> right file — see `.claude/skills/claude-context/SKILL.md` for how to
> route updates.

---

## 6. Verify the connection

Ask Claude:

> "List the folders in my Obsidian vault."
> "Create a note in `00-Inbox` called `test-note.md` with today's date."
> "Search my vault for notes tagged `#project`."

If Claude can complete these, the connection is working.

---

## 7. Suggested workflow

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
- **Link people, don't retype context:** mention people as `[[Full Name]]`
  so notes resolve to their `06-People/` profile — meeting/transcript
  skills use that link (plus the person note's `aliases`) to keep each
  person's interaction timeline current automatically. `templates/CLAUDE.md.example`
  already tells Claude to do this by default — this isn't just a habit to
  ask for.
- **Link, don't duplicate:** `[[wikilinks]]` to connect new notes to
  existing ones instead of restating context — also baked into the default
  `CLAUDE.md` instructions, not something you need to remind Claude to do.
- **Tag consistently:** agree on a small tag vocabulary (e.g. `#project`,
  `#decision`, `#reference`). The default `CLAUDE.md` tells Claude to reuse
  whatever's already in use rather than invent new tags — worth agreeing on
  the vocabulary early since Claude will follow it, not set it.

---

## 8. Claude Code skills

This repo ships [Claude Code skills](https://code.claude.com/docs) under
`.claude/skills/` that travel with the vault repo. None of them talk to
external services directly — each one drives whatever MCP tools you've
connected and authorized, and tells you what's missing instead of guessing.

| Skill | What it does | Requires |
|---|---|---|
| `md-confluence` | Push a note to Confluence as a page (or update the linked page), or pull a Confluence page into the vault as a note. | Atlassian MCP server (Confluence) |
| `md-jira` | Turn a note (or a single task) into a Jira ticket, or pull a Jira issue into the vault as a note. | Atlassian MCP server (Jira) |
| `weekly-slack-update` | Draft a concise weekly summary from daily notes, project activity, and decisions, and post it to a Slack channel — draft-then-approve, never auto-sent. | Slack MCP server |
| `meeting-prep` | Before a meeting, pull related project/people/decision notes from the vault into a short briefing linked from today's daily note. | Google Calendar or Outlook/Microsoft 365 MCP server |
| `teams-meeting-notes` | Find calendar events with Teams links, retrieve the transcript, archive it in `05-Meeting-Transcripts/`, and write a summary + action items. Proposes (never silently applies) related updates to project/decision-log notes. | Microsoft 365 MCP server (Outlook calendar + Teams transcripts) |
| `person-notes` | Maintain one note per person in `06-People/`: profile + interaction timeline, built from vault mentions and optionally enriched from Slack/Telegram/WhatsApp/Email. | None for vault-only sync; chat/email MCP servers for the optional research mode |
| `claude-context` | Read `Meta/Claude Context/*.md` at the start of a session and route updates (decisions, priority shifts, open questions) to the right file at the end. See [section 5](#5-persistent-session-context). | None — pure vault read/write |

`md-confluence`/`md-jira` keep a link back via frontmatter
(`confluence-page-id`, `jira-key`) so re-running updates the same
page/ticket instead of duplicating it — see each `SKILL.md` for the exact
field contract and formatting mapping. `teams-meeting-notes` and
`person-notes` treat existing notes as **append-only**: they propose
additions and show them before writing, never rewriting or removing what's
there.

**No skill runs on a background timer or file-watcher** — Claude Code
skills only execute when invoked. `06-People/` notes stay current because
`meeting-prep` and `teams-meeting-notes` call `person-notes`'s sync step
for the people they touch as their last step, not because anything is
watching the vault. Run `person-notes` directly (its whole-vault resync
mode) to catch anything created before this was wired up, or by a note
added outside those two skills. `claude-context` has the same limitation —
see [section 5](#5-persistent-session-context) for how its session-start
read actually gets triggered.

---

## 9. Troubleshooting

| Symptom | Fix |
|---|---|
| Claude says it has no file access | Confirm the MCP server entry is present and Claude Desktop was fully restarted (quit, not just closed). |
| `obsidian-mcp-server` connection refused | Obsidian must be running with the vault open; check `OBSIDIAN_BASE_URL` matches the plugin's HTTPS port (default `27124`). |
| Certificate / HTTPS errors from the REST API | The plugin uses a self-signed cert — `OBSIDIAN_VERIFY_SSL=false` (the default) handles this. If you switched to the plugin's non-encrypted HTTP port instead, set `OBSIDIAN_BASE_URL=http://127.0.0.1:27123` and enable "Non-encrypted (HTTP) Server" in the plugin settings. |
| `obsidian-mcp-server` won't start / `command not found` | Check your Node version — this server needs Node.js 24+ (or Bun 1.3+), newer than Option A's filesystem server requires. |
| Filesystem server can't write | Check the path passed to `server-filesystem` is absolute and Claude Desktop's process has write permission to it. |

---

## Repo layout

```
├── README.md                          # this guide
├── scripts/
│   ├── setup-all.sh                   # orchestrator: runs everything below
│   ├── setup-vault.sh                 # creates the PARA vault structure + templates
│   ├── install-obsidian-plugin.sh     # downloads + enables the Local REST API plugin
│   ├── configure-claude-desktop.sh    # merges MCP entries into your real Claude Desktop config
│   ├── configure-claude-code.sh       # writes the vault's .mcp.json for Claude Code
│   └── lib/merge-mcp-config.py        # shared safe JSON-merge used by both configure-* scripts
├── templates/                         # Obsidian note templates
│   ├── daily-note.md
│   ├── project-note.md
│   ├── meeting-note.md
│   ├── claude-chat-log.md
│   ├── weekly-review.md
│   ├── decision-log.md
│   ├── person.md
│   ├── claude-context/                # starter files for Meta/Claude Context/
│   │   ├── about.md
│   │   ├── current-focus.md
│   │   ├── open-threads.md
│   │   └── decisions-log.md
│   └── CLAUDE.md.example              # copied to the vault root as CLAUDE.md
├── config/claude_desktop_config.example.json
├── .claude/skills/                    # Claude Code skills for this vault
│   ├── md-confluence/SKILL.md         # push/pull notes <-> Confluence pages
│   ├── md-jira/SKILL.md               # push/pull notes <-> Jira issues
│   ├── weekly-slack-update/SKILL.md   # draft + send a weekly team update
│   ├── meeting-prep/SKILL.md          # pre-meeting briefing from the vault
│   ├── teams-meeting-notes/SKILL.md   # Teams transcripts -> summary + actions
│   ├── person-notes/SKILL.md          # maintain 06-People/ profiles
│   └── claude-context/SKILL.md        # persistent session-context layer
└── docs/
    ├── video-script.md                # narration script / storyboard
    └── video/
        ├── obsidian-second-brain.mp4  # the video
        ├── build.sh                   # rebuild pipeline (slides + TTS + ffmpeg)
        └── voice-clone/               # optional: narrate in your own voice
```
