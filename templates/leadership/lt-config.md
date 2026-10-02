---
type: lt-config
tags: [claude-context, leadership]
# Written by the lt-setup skill; read by lt-context, lt-contribute, lt-brief.
# Lives in your PERSONAL vault (Meta/Claude Context/LT Config.md). The shared
# space holds no per-person settings.
me: "Your Name"                      # exactly as it appears in contribution page titles
members: ["Name One", "Name Two", "Name Three", "Name Four"]
focus-owner: "Name Of Sr Director"   # the only person who edits LT Focus
atlassian-cloud-id: ""
confluence-space-key: ""
confluence-space-id: ""
parents:                             # Confluence page IDs, filled in by lt-setup
  charter: ""
  focus: ""
  decisions: ""
  asks-open: ""
  asks-closed: ""
  contributions: ""
  briefs: ""
# What lt-contribute may read from this vault (folder or file prefixes).
contribute-allow: ["01-Projects", "Meta/Claude Context/Decisions Log.md", "Meta/Claude Context/Open Threads.md", "Daily"]
# What it must never read, even if a path above contains it. Add your own.
contribute-deny: ["06-People", "05-Meeting-Transcripts"]
contribute-approval: required        # required | auto-decisions  (see lt-contribute)
slack-channel: ""                    # private channel containing exactly the members, e.g. lt-brief
slack-post: draft                    # draft | send  (send is refused unless channel membership matches members)
---

# LT Config

Settings for the leadership second brain. See `docs/leadership-team.md`.
