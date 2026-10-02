# Leadership second brain: video script

Narration and storyboard for `docs/video/leadership-team/leadership-team.mp4`.
The source of truth is `docs/video/leadership-team/scenes.json`; this file is
generated from it. Characters and dates are fictional.

## Rebuilding

```bash
./scripts/install-video-deps.sh                  # once
docs/video/build.sh leadership-team              # slides -> PNGs -> narration -> MP4
docs/video/build.sh --skip-audio leadership-team # reuse existing audio
```

Edit `scenes.json` and rebuild to change the video. The main walkthrough is
built the same way with `docs/video/build.sh` (no argument).

### Scene 1: A Leadership Second Brain
**Slide type:** title

**Narration:**
> Welcome. This is a short guide to a leadership second brain: a shared layer for a small leadership team, built on Confluence, that sits on top of everyone's own notes and tools.

---

### Scene 2: The problem
**Slide type:** bullets

**Narration:**
> Every leader already has a private second brain. But decisions end up in direct messages and meetings, and what the whole team needs to know is scattered. You cannot, and should not, solve that by letting one tool read everyone's messages.

---

### Scene 3: The design
**Slide type:** twocol

**Narration:**
> The design has two halves. Federate the contributions: each leader's own Claude reads only that leader's sources, and publishes a short distillation after they approve it. Centralize the synthesis: one scheduled run reads only the shared space and writes the brief. Nobody's raw messages are ever visible to anyone else.

---

### Scene 4: The shared space in Confluence
**Slide type:** tree

**Narration:**
> It lives in one restricted Confluence space, limited to exactly the leadership team. There is a focus page that only the senior director edits, one page per decision, one page per ask or risk, one contribution page per person per day, and the briefs. Every page has a single author, so nobody ever edits the same page.

---

### Scene 5: Guardrails
**Slide type:** bullets

**Narration:**
> The guardrails matter more than the automation. The space is restricted to the members. Agents draft and humans approve. A denylist keeps people notes and development plans in your private vault, and a sensitivity screen drops anything about an individual's performance, pay, or health, and reports only a count of what it left out.

---

### Scene 6: Evening: the contribution draft
**Slide type:** chat

**Narration:**
> Here is the daily rhythm. At the end of the day a scheduler runs the daily sync, which saves a leadership draft in your own daily note. It only read the folders on your allowlist, it skipped the people folder, and it kept only what would change a peer's decision. Two items were withheld, and the draft is not published.

---

### Scene 7: Approve and publish
**Slide type:** chat

**Narration:**
> Next morning you review it, and say publish. Claude shows you the exact text first, then creates your contribution page, plus one page for the decision and one for the ask, with a named person and a due date. Nothing leaves your vault until you say yes.

---

### Scene 8: Morning: the brief
**Slide type:** chat

**Narration:**
> The next morning, one run reads only the shared space and writes the brief. It leads with what changes someone's decision, lists asks by person with overdue items first, flags risks nobody owns, and names whoever did not contribute instead of hiding the gap. It saves a Slack draft, and only sends if the channel is private and its members match your team exactly.

---

### Scene 9: Starting a session
**Slide type:** chat

**Narration:**
> When you open a session, your Claude loads the shared layer first: the team's focus, the latest brief, and the asks addressed to you. Ask what the leadership team needs from you, and it answers with the overdue item first.

---

### Scene 10: Raising an ask
**Slide type:** chat

**Narration:**
> And you can raise an ask in plain language. Claude creates a page with one named person and a due date. It shows up in Sam's next session and in tomorrow's brief, so it never depends on someone remembering to follow up.

---

### Scene 11: Rollout
**Slide type:** bullets

**Narration:**
> Do not automate on day one. In week one, run everything as dry runs and post by hand, and tune your allowlist. In week two, schedule the contribution drafts. In week three, schedule the brief, and keep Slack as a draft until you trust it. And review your denylist before anything else.

---

### Scene 12: Get started
**Slide type:** outro

**Narration:**
> Everything shown here is in the Second Brain Claude repo: the guide, four skills, and the Confluence page templates. Start with the leadership team document.
