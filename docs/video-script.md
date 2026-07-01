# Video script / storyboard — "Obsidian as a Second Brain for Claude"

Ten scenes. Each scene = one slide (`docs/video/slides/sceneNN.html`) + one
narration block (`docs/video/audio/sceneNN.wav`, generated offline with
`espeak-ng`). The build script stitches them into
`docs/video/obsidian-second-brain.mp4`, holding each slide on screen for the
length of its narration.

---

### Scene 1 — Title
**Slide:** "Obsidian as a Second Brain for Claude" / "A ClaudeTio guide"

**Narration:**
> Welcome. This is a quick guide to turning Obsidian into a second brain for
> Claude, so your notes and project context survive across every
> conversation.

---

### Scene 2 — Why Obsidian + Claude
**Slide:** bullets — Plain markdown files · No API lock-in · Human and AI
edit the same notes · Durable memory across sessions

**Narration:**
> An Obsidian vault is just a folder of plain markdown files. That makes it a
> perfect long-term memory for Claude: no lock-in, fully searchable, and
> linkable with wikilinks.

---

### Scene 3 — Two ways to connect
**Slide:** Option A: Filesystem access (simple) / Option B: Local REST API +
MCP server (structured search)

**Narration:**
> There are two ways to connect them. Option A, filesystem access, is the
> simplest: Claude just reads and writes files in your vault folder. Option
> B adds the Local REST API plugin and the M C P dash obsidian server, for
> structured search and tag queries.

---

### Scene 4 — Vault structure
**Slide:** folder tree — 00-Inbox, 01-Projects, 02-Areas, 03-Resources,
04-Archive, Daily, Templates

**Narration:**
> Start by giving your vault a simple structure. This repo includes a setup
> script that creates the PARA folders: inbox, projects, areas, resources,
> and archive, plus a daily notes folder and templates.

---

### Scene 5 — Run the setup script
**Slide:** command block — `./scripts/setup-vault.sh ~/ObsidianVaults/SecondBrain`

**Narration:**
> Run setup-vault dot s h and point it at your vault path. It creates every
> folder and copies in the note templates automatically.

---

### Scene 6 — Option A: filesystem config
**Slide:** JSON snippet — `server-filesystem` entry in
`claude_desktop_config.json`

**Narration:**
> For Claude Code, just tell it where your vault lives, it already reads and
> writes files directly. For Claude Desktop, add the filesystem M C P server
> to your config, pointed at your vault path.

---

### Scene 7 — Option B: Local REST API + MCP
**Slide:** steps — Install "Local REST API" plugin · Copy the API key · Add
`obsidian-mcp-server` to your config · Restart Claude

**Narration:**
> For richer search, install the Local REST API community plugin inside
> Obsidian, copy its API key, and add obsidian dash M C P dash server to
> your Claude config with that key.

---

### Scene 8 — Verify the connection
**Slide:** example prompts — "List the folders in my vault" · "Create a test
note in 00-Inbox" · "Search notes tagged project"

**Narration:**
> Restart Claude, then verify the connection. Ask it to list your vault
> folders, create a test note, or search notes by tag.

---

### Scene 9 — Suggested workflow
**Slide:** bullets — Capture fast into the inbox · Log session summaries in
the daily note · Link related notes instead of repeating context

**Narration:**
> For day to day use: capture fast into the inbox, ask Claude to log session
> summaries into today's daily note, and link related notes instead of
> repeating context.

---

### Scene 10 — Get started
**Slide:** "ClaudeTio" repo · README.md · scripts/ · templates/ · config/

**Narration:**
> Everything shown here, the setup script, the templates, and the example
> config, is in the ClaudeTio repo. Check the README to get started.

---

## Rebuilding the video

```bash
docs/video/build.sh
```

Regenerates slide PNGs (headless Chromium), narration WAVs, and re-muxes the
final MP4 with `ffmpeg`. Narration defaults to Festival's offline
`cmu_us_slt_arctic_hts` voice (`gen_audio.sh`, statistical parametric —
noticeably smoother than `espeak-ng`'s formant synthesis, which is still
available via `gen_audio.sh espeak`). Everything here runs locally; no cloud
TTS is used.

**Want it in your own voice?** See `docs/video/voice-clone/README.md` — a
Coqui XTTS-v2 script that clones narration from a short recording of you.
It has to run on a machine with normal internet access (not this repo's
sandboxed build environment), then feed the result back in with
`docs/video/build.sh --skip-audio`.
