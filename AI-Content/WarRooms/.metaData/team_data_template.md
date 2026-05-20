# Team — `data.md` Template

**Status:** First draft 2026-05-14.
**Used by:** every `.metaData/Teams/<TeamHandle>/data.md`.
**Related:** [`team_structure.md`](./team_structure.md), [`team_template.md`](./team_template.md), [`persona_data_template.md`](./persona_data_template.md).

`data.md` is the **factual** half of a team. What product the team owns, what that product does, how the team is structured, who commands it, what tech they run, what history they carry. No theming, no in-universe voice — that lives in the sibling `persona.md`.

Same authoring discipline as the persona-level `data.md`: cite sources, flag inferences, leave sections blank rather than inventing.

---

## Authoring rules

1. **Three sources of truth feed this file:** (a) the public-facing product page / corporate website, (b) the team's own repository — README, wiki, code structure, (c) user-provided context about how the team actually runs. Cite each in `source_notes:`.
2. **Distinguish the marketing name from the internal handle.** "VEO® Design Studio" is the product. "VDS" is what people inside the company call the team. Both belong in `data.md`; the folder uses the internal handle.
3. **Inferences are allowed but flagged.** "Probably ~6 developers based on the LinkedIn 'team of 6 to 10' phrasing in the commander's history" is acceptable as *Inferred*, never as fact.
4. **Cross-link the commander.** Always link to the commanding persona's folder so the chain of command is one click away.
5. **Update `last_updated:`** whenever the file changes.

---

## Skeleton

Copy the block below into a new `data.md`. Delete sections that don't apply rather than leaving placeholder text.

```markdown
# <TeamHandle> — <Long Product Name>

**Internal handle:** <e.g., VDS, Indago>
**Product name:** <e.g., VEO® Design Studio>
**Persona file:** [`persona.md`](./persona.md) — in-universe write-up as a unit under <commanding persona codename>.
**Commanding persona:** [`<RealName>_<Codename>`](../../../Personas/<RealName>_<Codename>/) — <role / rank line>.
**Last updated:** <YYYY-MM-DD>

---

## What this team owns

One paragraph in plain English. What is the product or system this team is responsible for? Who uses it? What does it do for them?

If the team owns multiple things, list each. If the team's responsibilities are not strictly product-aligned (e.g., a platform team, a shared-services group), say so.

## Where it sits in the company

- **Surface:** <customer-facing | internal / back-of-house | hybrid>
- **Upstream / downstream systems:** <e.g., receives Manufacturing Orders from Echelon; emits invoices to Accounting>
- **Public on the corporate site?** <yes / no — and if so, link the page>

## Team composition

- **Commander:** [`<RealName>_<Codename>`](../../../Personas/<RealName>_<Codename>/) — link.
- **Other named members with persona folders:** cross-link each by codename.
- **Headcount estimate:** <known | inferred from X | unknown>
- **Structure:** <single team / split into pods / mixed full-time + contractor / etc.>

## Tech stack

What the team actually runs. Be specific — versions, frameworks, doctrines. Pull from the team's README / repository directly when possible.

- **Backend:** <e.g., .NET 9 + C#, MediatR, EF Core 9, DDD layered architecture>
- **Frontend:** <e.g., Aurelia 1 + TypeScript 4, Sass, Syncfusion ej2>
- **Data:** <e.g., SQL Server 2019+>
- **CI/CD:** <e.g., Azure DevOps Pipelines>
- **Other:** <e.g., SignalR with SQL backplane, Serilog, FluentValidation>

## History

A short timeline of how the team and its product got here. Major rewrites, migrations, rebrands, the moments that defined the current shape of the work.

- <year>: <event>
- <year>: <event>

## Notable Operations (PBI posters) anchored on this team

PBI / Operation posters that named this team or this product as the primary subject. Cross-link to the poster file paths under `WarRooms/PBI Posters/` when known.

- <Operation name> — <one-line reason this team was the anchor>

## Source notes

Where this file's facts came from. Be honest about each line.

- *Corporate site `<url>`:* fetched <YYYY-MM-DD>. <what came from this source>
- *Team repository `<path or url>`:* read <YYYY-MM-DD>. <what came from this source>
- *User account, <YYYY-MM-DD>:* "<short paraphrase of what the user told us>"
- *Inferred:* <list any items derived rather than stated, with reasoning>

## Open questions

Things we'd want to confirm with the team lead, the commanding persona, or someone closer to the work.

- <question>
- <question>
```

---

## What does NOT belong here

- **In-universe unit designation, doctrine, motto, emblem.** That's `persona.md`.
- **Individual people's bios.** Names and codenames are fine as cross-links; full bios live in the person's `Personas/<RealName>_<Codename>/data.md`.
- **Speculation framed as fact.** If you don't know the headcount, say so. Don't invent it.
- **Comparison against other teams.** Each team is described on its own terms.
