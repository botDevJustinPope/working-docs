# Team — `persona.md` Template

**Status:** First draft 2026-05-14.
**Used by:** every `.metaData/Teams/<TeamHandle>/persona.md` — the **Era I default** aesthetic write-up for a team.
**Era III companion:** [`team_future_template.md`](./team_future_template.md) governs the parallel `persona_future.md` file in each team folder.
**Related:** [`team_structure.md`](./team_structure.md), [`team_data_template.md`](./team_data_template.md), [`aesthetic.md`](./aesthetic.md), [`persona_template.md`](./persona_template.md).

`persona.md` is the **creative** half of a team. It translates the real team into a War Room *unit* — usually a platoon under a commanding persona, sometimes a larger formation when the org-chart shape calls for it. Records the unit designation, emblem, doctrine, motto, and how the unit shows up in scenes alongside individual personas.

The locked visual aesthetic (palette, typography, modes) is in [`aesthetic.md`](./aesthetic.md). `persona.md` does not redefine those rules — only records this team's specific choices within them.

---

## Authoring rules

1. **Anchor every creative choice to a fact in `data.md`.** "Ordnance Works Platoon, because they run the literal manufacturing plant" is good. "Ordnance Works because it sounds tough" is not.
2. **Lock the unit designation early.** Once a team's WW2 analogue is set (platoon, ordnance works, signal corps detachment, civil affairs unit, etc.), it stops shifting. Drift between pieces is the enemy of recognizability.
3. **Default hierarchy is *platoon under a company commander*.** See [`team_structure.md`](./team_structure.md) §4. If a team breaks the default — a battalion-scale shared-services unit, a detached specialist squad, anything that isn't a "platoon under one commander" — record the deviation here, and explain why.
4. **The team's emblem is canon-adjacent.** A platoon pennant or unit patch may appear on posters, on a commander's portrait (per `Personas/.../persona.md` "Signature props"), in PBI posters where the team is the anchor unit. Lock the emblem's symbology once.
5. **Update `last_updated:`** whenever you change unit designation, doctrine, or emblem.

---

## Skeleton

Copy this into a new `persona.md`. Drop sections that don't yet apply; mark them "TBD" rather than inventing.

```markdown
# <TeamHandle> — <Unit Designation>

**Real-world anchor:** [`data.md`](./data.md) — <product / what the team owns, one line>.
**Commanding persona:** [`<RealName>_<Codename>`](../../../Personas/<RealName>_<Codename>/) — <role line>.
**Era applicability:** Era I default. <Notes on Era II/III appearances if relevant.>
**Faction:** <Allied (human side) | Claude-aligned | Copilot-aligned | Independent>.
**Last updated:** <YYYY-MM-DD>.

---

## Unit designation

One short paragraph naming the unit and explaining the choice.

- **In-universe name:** <e.g., "VDS Forward Liaison Platoon">.
- **WW2 unit analogue:** <e.g., civil affairs platoon, ordnance works platoon, signal corps detachment, combat engineers, quartermaster section>.
- **Why this unit:** the bridge from the real team's surface area (per `data.md`) to the wartime analogue.

## Position on the front

Where this unit sits in the universe's geography.

- **Front-of-house / rear / liaison / fortified:** <one of these or close>.
- **Adjacent units:** which other Teams or AI factions does this unit interact with? Cross-link to their team folders.
- **Upstream / downstream supply:** the wartime version of the real upstream/downstream from `data.md`. E.g., "receives Manufacturing Orders from the Echelon Quartermaster's office; ships finished materiel forward to the line."

## Emblem / unit patch

The visual identifier that goes on the pennant, on the patch, and in any "team standard" prop on a commander's portrait.

- **Primary symbol:** <one-line description — a specific shape or object, not "something cool">.
- **Color treatment:** anchored to `aesthetic.md` §3 — cream, ochre, olive drab, red, brown. Pick the dominant pairing.
- **Inscription / wordmark:** any text on the emblem — usually the TeamHandle in stencil-adjacent ALL CAPS.

If a poster of the emblem on its own exists (or is planned), reference it: `[`emblem.png`](./emblem.png)`.

## Doctrine

How this unit *operates* in-universe — two or three concrete tells, anchored to how the real team actually works.

- **Cadence / tempo:** <e.g., "scheduled pushes per shift change," "rapid liaison sweeps before each homebuyer appointment">.
- **Standing orders:** the unwritten rules. <e.g., "no Manufacturing Order proceeds without a verified saw assignment," "every customer touchpoint is rehearsed before deployment">.
- **Quirks:** <e.g., "keeps the production schedule on a wall-sized chart even when the screens go down">.
- **Never:** one thing this unit definitionally would not do — usually the thing the real team has explicit principles against.

## Motto

One short line per `aesthetic.md` §8 tagline grammar. Goes on the emblem, on the platoon pennant, and in any unit-level content.

> "<MOTTO GOES HERE.>"

## Composition

How this unit is staffed in-universe. Cross-link the commander and any named members who have persona folders.

- **Commander:** [`<RealName>_<Codename>`](../../../Personas/<RealName>_<Codename>/) — <one-line reason this persona commands this unit>.
- **Named members with persona folders:** cross-link by codename. Note their role *within the platoon* if relevant ("squad lead," "ranged specialist," etc.).
- **Approximate platoon size:** <known | inferred>. Realistic WW2 platoon size is ~30–40; most dev teams are smaller. Lean into the analogue — call a 6-person team a "squad-sized platoon" if needed rather than inflating numbers.

## Relationships and deployments

How this unit shows up alongside others.

- **Sister unit(s):** other platoons in the same company. Cross-link by team handle.
- **Standing orders from above:** who this unit reports to — usually the commanding persona's company.
- **Recurring antagonist / foil:** the kind of *Operation* (PBI poster subject) that tends to land on this unit. Not other personas; usually a class of problem.
- **Operations anchored on this unit:** if known, list the PBI posters this team owned.

## Era II / III appearances

Optional. If this unit has shown up in World War AI content (faction crossovers, summit scenes, near-future cyber-WW2 pieces), record it here. Otherwise: "Era I only — TBD if/when promoted."

## Open creative questions

- <question>
- <question>
```

---

## What this file is *for*, in practice

When we go to generate or write something involving this team — a unit poster, a PBI poster where this team is the anchor, an in-universe briefing — we read `persona.md` and pull:

- The unit designation (for the figures' uniforms and the platoon pennant).
- The emblem (for the patch, the pennant, any standard).
- The doctrine tells (for what the unit is *doing* in the scene).
- The motto (if a quote / tagline is needed).
- The commander cross-link (for the figure who anchors the scene).

If a team's `persona.md` doesn't give us those five things, it isn't doing its job.

---

## What does NOT belong here

- **Real-world facts.** Product name, headcount, tech stack — `data.md`.
- **Global aesthetic rules.** Palette, typography, era arc — `aesthetic.md`.
- **Per-person voice / bio.** That's the individual persona's `persona.md`.
- **Status / lifecycle of generated assets.** Which poster is current, which is a draft — sub-project #4's sidecar metadata.
