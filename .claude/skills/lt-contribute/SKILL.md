---
name: lt-contribute
description: Draft, and after approval publish, the user's daily contribution to the leadership team's shared Confluence space; a short distillation of decisions, risks, asks, commitments, and signals from their own notes, passed through a sensitivity screen. Use when asked to "publish my LT contribution", "contribute to the LT brain", or when invoked by a scheduler or by daily-sync. Draft-only when unattended. Requires an Atlassian MCP server and a configured LT Config note (see lt-setup).
---

# LT contribute

Each leader's own Claude turns that leader's own day into a short
contribution for the team. This is the **federated** half of the design:
only a distillation leaves the personal vault, and only after the author
approves it. Config from `Meta/Claude Context/LT Config.md`.

## Modes

- **Interactive:** draft, show, publish on approval.
- **Unattended** (a scheduler, or invoked by `daily-sync`): draft only.
  Save the draft into today's daily note under `## LT draft` and stop with
  "waiting for approval". Unattended runs never publish, whatever the
  `contribute-approval` setting says.
- **Dry run:** print the draft and the page it would create; write
  nothing anywhere.
- **Publish a saved draft:** when the user says "publish my LT
  contribution", use the `## LT draft` section as the draft, show it once,
  publish on approval.

`contribute-approval: auto-decisions` only changes interactive mode: items
that are already in the user's Decisions Log may be included without
per-item confirmation. Everything else is still reviewed.

## Gather (read only the allowlist)

1. Read only paths under `contribute-allow`, minus anything under
   `contribute-deny`. The denylist wins over the allowlist. If a path is
   ambiguous, don't read it.
2. Window: since the user's last published contribution (or today only,
   if none).
3. Candidate items come from: new entries in the Decisions Log, open
   threads that became asks or risks, project notes changed in the window,
   and today's daily note.

## Filter

For each candidate, keep it only if it passes: **would this change someone
else on the LT's decision this week?** If not, drop it. Status updates,
progress, and things the LT can already see in Jira or Slack are not
contributions.

Then the **sensitivity screen**. Drop, and count only as "withheld" (no
detail, no hint of content), anything that touches:
- an individual's performance, compensation, health, conduct, or career
- hiring, restructuring, or headcount plans that aren't announced
- confidences from customers, partners, or other teams
- anything the source note marks private, or that came from a denied path
- personal, non-work content

When unsure, withhold and let the user add it by hand. The cost of a
missing item is small and visible; the cost of a leak is not.

## Draft

Build the page from `Templates/leadership/contribution.md`, omitting empty
sections. Keep items to one or two sentences, in the user's voice, with no
quotes from messages or documents. Every ask names one person and a due
date; if the source doesn't say, leave the due date for the user to fill.
Report the withheld count under "Withheld".

Also list, separately, items that deserve their own structured page: each
**decision** (page under Decisions), **ask**, or **risk** (page under
Open). These are created through the `lt-context` skill's write routes, in
the same approval step.

## Publish (interactive only, after approval)

1. Show the final draft and the exact page title:
   `Contribution YYYY-MM-DD · <me>` under `parents.contributions`.
   Ask: "Publish this to the LT space?" Publish only on an explicit yes.
2. If a page with that title exists, fetch it, show the diff, and update
   only after approval. Never create a second page for the same day.
3. Create any approved decision/ask/risk pages via `lt-context`.
4. Log one line in today's daily note: what was published, where, when.
   Remove the `## LT draft` section if one was used.

## Guardrails

- Never read outside the allowlist, and never read `contribute-deny`
  paths, even to check whether they contain something relevant.
- Never publish unattended. Never publish without showing the exact text.
- Never include names of individuals in a performance or personnel
  context. If an item is about a person's work quality, it is withheld.
- If the Confluence space can't be reached, keep the draft in the daily
  note and say so; don't retry in a loop.
