# Onboarding prompt for leadership team members

After one person has created the Confluence skeleton (`lt-setup`, create
mode), every other member can join by pasting the prompt below into their
own Claude (Claude Code in their vault, or any client with the Atlassian MCP
server connected). It creates nothing in Confluence or Slack; it only
writes that member's personal `LT Config.md` and walks them through their
allowlist and denylist.

Fill in the `<placeholders>` once (the IDs are printed when the skeleton is
created, or visible in each page's URL), then share the filled prompt with
the team. Keep the filled version out of public repos: it contains your
organization's page IDs and member names.

```text
I'm joining our leadership team's shared second brain in Confluence. This is a one-time setup of MY personal config. You will not create or edit any page in Confluence, and you will not post anything to Slack.

Facts (the space is already scaffolded by whoever ran lt-setup):
- Confluence site: <your-site>.atlassian.net, cloudId <cloud-id>
- Space: key <SPACEKEY>, spaceId <space-id>
- Page IDs: home <id>, LT Focus <id>, Decisions <id>, Asks and Risks <id>, Open <id>, Closed <id>, Contributions <id>, Briefs <id>
- Members (exactly these four): <Name One>, <Name Two>, <Name Three>, <Name Four>
- Focus owner (the only person who edits LT Focus): <Name>
- Private Slack channel ID for the briefs: <channel-id>

Do this, in order, and stop to ask me whenever something is unclear:

1. Ask me which of the four members I am, so you use my name exactly as listed above.
2. Check that Confluence tools are available (use ToolSearch with "confluence"). If they are not, tell me how to connect and authorize the Atlassian MCP server, then stop.
3. Read-only check: fetch each page ID above and confirm its title matches (LT Focus, Decisions, Asks and Risks, Open, Closed, Contributions, Briefs) and that it is in space <SPACEKEY>. If anything differs, stop and tell me.
4. Find my vault's Claude context folder (default "Meta/Claude Context"). If you can't find it, ask me where it is.
5. Check whether the leadership skills are installed in my vault under .claude/skills (lt-setup, lt-context, lt-contribute, lt-brief, daily-sync) and whether templates/leadership exists. If not, tell me they come from https://github.com/Tiobold/SecondBrainClaude and offer to copy them. Don't download or run anything without my yes.
6. Write "<context folder>/LT Config.md" with exactly this frontmatter, with "me" set to my name. If the file already exists, show me a diff and ask before changing it:

---
type: lt-config
tags: [claude-context, leadership]
me: "<my name>"
members: ["<Name One>", "<Name Two>", "<Name Three>", "<Name Four>"]
focus-owner: "<Name>"
atlassian-cloud-id: "<cloud-id>"
confluence-space-key: "<SPACEKEY>"
confluence-space-id: "<space-id>"
parents:
  charter: "<home-id>"
  focus: "<focus-id>"
  decisions: "<decisions-id>"
  asks-open: "<open-id>"
  asks-closed: "<closed-id>"
  contributions: "<contributions-id>"
  briefs: "<briefs-id>"
contribute-allow: []
contribute-deny: []
contribute-approval: required
slack-channel: "<channel-id>"
slack-post: draft
---

7. Now fill in contribute-allow and contribute-deny WITH me, line by line. Look at my vault's real folder structure and propose an allowlist limited to what is meant to be shared (for example project notes, my decisions log, open threads, daily notes). Then ask me explicitly which folders hold anything about individuals (1:1s, development plans, hiring, performance, compensation, health, personal notes) and put every one of them in the denylist. The denylist always wins. Don't leave either list empty and don't guess: show me both lists and get my approval before saving them.
8. Offer to add one line to my vault's CLAUDE.md: "Also follow the lt-context skill at the start of each session." Add it only if I agree.
9. Finish with a short report: what you wrote and where, what you skipped, and the next step, which is to run the lt-contribute skill once in dry-run mode (it prints a draft and writes nothing).

Rules: never write anything to Confluence or Slack in this run, never read my notes outside the folders I've approved, and if a tool returns a permissions error, report it plainly instead of retrying another way.
```
