# Persona — `persona.md` Template

**Status:** First draft 2026-05-13.
**Used by:** every `WarRooms/Personas/<RealName>_<Codename>/persona.md`.
**Related:** [`persona_structure.md`](./persona_structure.md), [`persona_data_template.md`](./persona_data_template.md), [`aesthetic.md`](./aesthetic.md), [`prompt_persona_image.md`](./prompt_persona_image.md).

`persona.md` is the **creative** half of a persona — the file that translates the real person (captured in `data.md`) into the War Room theme. It governs how the persona looks, sounds, and behaves across:

- The portrait at `poster.png`.
- Any `variants/` pieces.
- Any in-universe written content where this persona "speaks" or is referenced.
- Mentions in PBI / Operation posters when this persona shows up in the scene.

The locked visual aesthetic (palette, typography, modes) is in [`aesthetic.md`](./aesthetic.md). `persona.md` is *not* the place to redefine those rules — only to record this persona's specific choices *within* them.

---

## Authoring rules

1. **Anchor every creative choice to a fact in `data.md`.** "Quartermaster, because they own deployment tooling" is good. "Quartermaster because it sounds cool" is not. The translation should feel earned.
2. **Be specific.** "Carries a leather-bound ledger marked DEPLOY" beats "carries something military." Specifics propagate into prompts; vagueness doesn't.
3. **Lock the WW2 unit identity early.** Once a persona's analogue is set (engineer, signal corps, field medic, etc.), it stops shifting between pieces. Drift is the enemy of recognizability.
4. **The codename is canon.** It appears on the poster in ALL CAPS per `aesthetic.md` §4. Don't rename a persona casually — codenames are referenced across PBI posters, content, and other personas' files.
5. **Faction default is human / allied.** Unless a persona is explicitly aligned with an AI faction (Claude / Copilot / ChatGPT), they are on the human-soldier side of the Era arc. Most of the 13 stay there.
6. **Update `last_updated:`** whenever you change voice, props, or unit identity — those changes need to ripple into the next regenerated poster.

---

## Skeleton

Copy this into a new `persona.md`. Drop sections that don't yet apply; mark them "TBD" rather than inventing.

```markdown
# <Codename> — In-Universe Persona

**Real-world anchor:** [`data.md`](./data.md) — <real name>, <real role in one line>.
**Era applicability:** Era I default. <Note Era II/III appearances if relevant.>
**Faction:** <Allied (human side) | Claude-aligned | Copilot-aligned | Independent>.
**Last updated:** <YYYY-MM-DD>.

---

## Codename rationale

One paragraph. Why *this* codename for *this* person. Tie back to their real role, their reputation on the team, or a specific contribution from `data.md`. If the codename predates the structured persona docs (most do), explain it retroactively — but truthfully.

## WW2 unit identity

- **Rank / role analogue:** <e.g., Master Sergeant, Combat Engineer, Signal Corps Lieutenant, Field Medic, Quartermaster Captain>.
- **Wartime function:** one line — what would this character literally be doing in 1944?
- **Why this unit:** the bridge from real role to wartime role. *Owns deployment tooling → Quartermaster managing supply lines → makes sense.*

## Signature props / recurring artifacts

Things this persona is shown holding, wearing, or surrounded by — consistent across pieces so the persona is recognizable.

- <prop> — <what it represents in real-world terms>
- <prop> — <…>

Aim for 2–3 props max. More than that and posters start fighting themselves.

## Portrait composition notes

Specific direction for the persona poster. The base template is in [`prompt_persona_image.md`](./prompt_persona_image.md); fill in this persona's choices:

- **Pose:** <e.g., bracing against a map table, mid-stride with a clipboard, shouting into a field radio>.
- **Setting:** <e.g., interior war room with sticky notes, factory floor, field tent, trench>.
- **Mode:** <A — painterly | B — geometric propaganda> per `aesthetic.md` §5. Most personas should pick one and stick with it.
- **Codename label placement:** <top banner | mid-ribbon | bottom plate>. Once 3–4 personas converge, this gets promoted to `aesthetic.md`.

## Voice / tone

How does this persona "talk" in any in-universe content (captions, dialogue in posters, written briefings attributed to them)? Two or three concrete tells, plus a do-not-do.

- **Cadence:** <e.g., short imperative sentences; long looping anecdotes; deadpan one-liners>.
- **Lexicon:** <e.g., uses ledger / supply / inventory metaphors; quotes RFCs; speaks in checklists>.
- **Quirks:** <e.g., always references the previous deployment by date>.
- **Never:** <one thing this persona definitionally would not say or do>.

## Tagline / motto

One short line, ALL CAPS-able, per `aesthetic.md` §8 tagline grammar. This is what would appear under their portrait or as a quote attributed to them.

> "<TAGLINE GOES HERE.>"

## Relationships and deployments

Other personas this one regularly shows up alongside, or operations they tend to anchor. Cross-link by codename. Keep it short — this is flavor, not a graph database.

- Often deployed alongside: <Codename> (because <reason>)
- Recurring antagonist / foil: <Codename or faction> (because <reason>)
- Operations led / anchored: <Operation name> (<one-line reason this persona was the right anchor>)

## Era II / III appearances

Optional. If this persona has shown up in World War AI content (faction alliances, summit posters, near-future cyber pieces), record it here. Otherwise leave as "Era I only — TBD if/when promoted."

## Open creative questions

Things we haven't decided yet that future pieces will force us to lock down.

- <question>
- <question>
```

---

## What this file is *for*, in practice

When we go to generate or write something involving this persona — a new poster variant, a meme, a Slack post attributed to them, an Operation poster that features them — we read `persona.md` and pull:

- The codename (for the label).
- The WW2 unit identity (for the figure / costume).
- The signature props (for the in-scene objects).
- The voice tells (for any text in their mouth).
- The tagline grammar (if we need a quote).

If a persona's `persona.md` doesn't give us those five things, it isn't doing its job. The template above forces each one.

---

## What does NOT belong here

- **Real-world facts.** Job title, education, LinkedIn — `data.md`.
- **Global aesthetic rules.** Palette, typography, era arc, anachronism logic — `aesthetic.md`.
- **Prompt templates.** Persona-portrait base prompt — `prompt_persona_image.md`. Quote `persona.md` *into* that template; don't duplicate it here.
- **Status / lifecycle of generated assets.** Which poster is current, which is a draft — that's the sidecar metadata sub-project #4 will handle, not this file.
