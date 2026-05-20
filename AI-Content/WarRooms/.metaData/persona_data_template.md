# Persona — `data.md` Template

**Status:** First draft 2026-05-13.
**Used by:** every `WarRooms/Personas/<RealName>_<Codename>/data.md`.
**Related:** [`persona_structure.md`](./persona_structure.md), [`persona_template.md`](./persona_template.md).

`data.md` is the **factual** half of a persona. No theming, no in-universe voice. If a stranger needed to figure out who this person actually is, what they do, and how to verify any of it, this file is what they'd read.

The creative leap — codename voice, WW2 unit, signature props — lives in the sibling `persona.md`.

---

## Authoring rules

1. **Two sources of truth feed this file:** (a) what the user tells us about the team member, and (b) what the team member's public LinkedIn profile says. Record both, separately, in the `source_notes:` section.
2. **Inferences are allowed, but flag them.** If you derive "probably has 5 years of Power Platform experience" from job-history dates, write it as *Inferred* — don't promote to fact.
3. **Anything we can't verify is omitted, not invented.** Empty sections are fine. Made-up history is not.
4. **Update `last_updated:`** whenever the file changes.
5. **Cross-link the codename** to `persona.md` in the same folder.

---

## Skeleton

Copy the block below into a new `data.md`. Delete sections that don't apply rather than leaving placeholder text.

```markdown
# <RealName> — <Codename>

**Real name:** <First Last>
**War Room codename:** <Codename> — see [`persona.md`](./persona.md) for the in-universe write-up.
**Last updated:** <YYYY-MM-DD>

---

## Role at the company

- **Title:** <e.g., Senior Software Engineer>
- **Team / department:** <e.g., Platform Engineering>
- **Reports to / reporting line:** <optional, only if user provided>
- **Start date / tenure:** <e.g., Joined 2022-03; ~4 years>
- **Day-to-day:** <one-paragraph plain description of what they actually do most weeks>

## Background

- **Prior roles:** <bullet list, most recent first>
- **Education:** <degrees, institutions if provided>
- **Domains of experience:** <e.g., Power Platform, .NET, data engineering, IT operations>
- **Certifications / specializations:** <optional>

## Core skills

Short, honest list. No buzzword bingo.

- <skill>
- <skill>
- <skill>

## Notable contributions in this codebase / org

PBIs led, areas of code owned, recurring projects, fires put out. Anything that anchors *this person* to *this team's history*.

- <contribution>
- <contribution>

## Public profile links

- **LinkedIn:** <URL or "not on file">
- **GitHub / GitLab / etc.:** <URL or omit>
- **Other (blog, conference talks):** <URL or omit>

## Source notes

Where this file's facts came from. Be honest about each line.

- *User account, <date>:* "<short paraphrase or quote of what the user told us>"
- *LinkedIn profile read on <YYYY-MM-DD>:* roles, dates, education pulled directly. URL above.
- *Inferred:* <list any items in this file that are derived rather than stated, with the reasoning>

## Open questions

Things we'd want to confirm with the team member or with someone closer to the work.

- <question>
- <question>
```

---

## Worked example — sketch

A finished `data.md` should read like a short biographical brief, not a resume dump. The example below is *fictional*, illustrative only — don't copy these facts into a real persona:

> **Real name:** Sample Person
> **War Room codename:** Quartermaster — see `persona.md`.
> **Last updated:** 2026-05-13.
>
> Sample joined the platform team in 2021 after eight years in IT operations at a regional MSP. They own the deployment-tooling area of the codebase and were the lead on Operation Iron Ledger and Operation Iron Link. Background is sysadmin → release engineer → platform engineer; comfortable in PowerShell, Azure DevOps pipelines, and the storage layer most other engineers avoid.
>
> *Source notes — user told us about the Iron Ledger / Iron Link leadership; everything pre-2021 came from LinkedIn read on 2026-05-13.*

That density — facts, anchors, sources — is the bar.

---

## What does NOT belong here

- **In-universe voice or backstory.** "She rallied the squad in the trenches of the migration..." → that's `persona.md`.
- **Visual / portrait direction.** Pose, prop, palette → `persona.md` and `aesthetic.md`.
- **Speculation framed as fact.** If you don't know, say so or leave the section out.
- **Comparison or ranking against other team members.** Each persona is described on its own terms.
