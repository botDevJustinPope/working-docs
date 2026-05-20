# Team — `persona_future.md` Template (Era III)

**Status:** First draft 2026-05-14.
**Used by:** every `.metaData/Teams/<TeamHandle>/persona_future.md`.
**Era I companion:** [`team_template.md`](./team_template.md) — the base / default file in each team folder.
**Visual canon:** [`aesthetic_future.md`](./aesthetic_future.md) — Era III "Near-future cyber-WW2" specialization of `aesthetic.md`.

This file is a **specialization**, not a duplicate. The team's *identity* — unit designation, commander, doctrine, motto, emblem symbology — is set in `persona.md` and inherits here. `persona_future.md` records what *changes* in Era III: the environment, the augmentations, the palette balance, the props, the prompt fragments.

Era III is restrained-use, per `aesthetic_future.md`. The file exists so the universe-building is in place; actual `poster_future.png` generation should remain rare and reserved for milestone moments.

---

## Authoring rules

1. **Inherit, do not redefine.** Unit designation, commander, motto, emblem symbology, doctrine — all stay the same as `persona.md`. If you find yourself rewriting them, you're drifting; pull back.
2. **The propaganda-poster heritage must survive.** Per `aesthetic_future.md` "Critical balance rule" — if the Era III scene reads as Cyberpunk-2077 fan art instead of WW2 propaganda with cyber elements, the balance is wrong.
3. **Augmentations are unit-specific.** A Pathfinder Detachment's Era III augmentations (HUD visors, holographic drop markers) differ from an Artillery Section's (firing-solution overlays, fiber-optic fire-control lines). Pick augmentations that follow from the *real team's work*, not generic "cyber stuff."
4. **The motto and emblem inscription do NOT change in Era III.** They are canon. The emblem's *rendering* may pick up steel/cyan touches; the symbology and wordmark stay.
5. **Update `last_updated:`** whenever Era III environment / props / augmentations change.

---

## Skeleton

Copy this into a new `persona_future.md`. Keep it tight — Era III specializes the Era I file rather than restating it.

```markdown
# <TeamHandle> — <Unit Designation> · Era III

**Era I source:** [`persona.md`](./persona.md) — the base unit identity. Inherits commander, doctrine, motto, emblem symbology.
**Visual canon:** [`aesthetic_future.md`](../../aesthetic_future.md).
**Last updated:** <YYYY-MM-DD>

---

## What changes in Era III

One short paragraph stating how this specific unit is reimagined in the rain-soaked, cybernetically-augmented near-future. Do NOT restate the unit designation, doctrine, or motto — link back to `persona.md` for those.

## Environment

Where this unit operates in Era III. Anchor to `aesthetic_future.md` "Setting / environment":

- **Position on the future front:** <e.g., forward neo-noir drop zone, rear-area cyber-foundry, fortified server-rack bunker>.
- **Atmospherics:** <rain / smoke / code rain / fog / burning neon — pick what suits>.
- **Built-environment cues:** <e.g., server-rack trenches, holographic battle maps, arcology bunkers, fiber-optic field radios>.

## Augmentations on the unit

Cyber-augmentations specific to this team. Per `aesthetic_future.md`, neon is sparing — pick 2–3 augmentations that follow from the *team's actual work*, not generic cyber dressing.

- <augmentation> — <why this fits the team's function>
- <augmentation> — <…>

## Props (Era III layer)

What changes about the unit's gear, emblem rendering, and in-scene artifacts when shifted to Era III. The emblem symbology does not change; the rendering may pick up cyan / steel-navy accents.

- **Emblem rendering:** <e.g., cream + ochre as primary, with a thin electric-cyan glow on the wordmark>.
- **In-scene props:** <e.g., holographic production-schedule projected over a wooden strategy table; CRT monitors showing fire-mission solutions; analog radio with fiber-optic cable>.
- **Uniform layer:** <e.g., olive-drab fatigues with mech-knight shoulder armor; brass officer cap with HUD visor>.

## Composition notes for Era III posters

Specific direction for any `poster_future.png` of this unit. Pull from `aesthetic_future.md` "Stylistic direction" and "Mood":

- **Mode:** <painterly propaganda composition with cyberpunk environmental density — the propaganda framing stays>.
- **Lighting:** <e.g., chiaroscuro single-source + neon set-dressing>.
- **Critical balance check:** the aged-paper / propaganda finish MUST survive the scene. If neon is dominating, pull back.

## Motto in Era III

The Era I motto **does not change**. Quote it here for convenience:

> "<MOTTO FROM persona.md.>"

If — and only if — the team has a specific *campaign* in Era III that warrants its own sub-tagline (e.g., a milestone Operation that lives in Era III only), record it separately as a *campaign motto*, distinct from the unit motto.

## Era III prompt fragments

Composable phrases for prompts generating this unit in Era III. Cherry-pick — using all of them dilutes each. Combine with the keyword library in `aesthetic_future.md`.

- `<phrase>`
- `<phrase>`
- `<phrase>`

## Era III appearances log

When an actual `poster_future.png` or Era III scene featuring this unit is generated, log it here with a one-line note.

- *(none yet)*

## Open creative questions (Era III only)

Questions specific to the Era III specialization that don't apply to the Era I base.

- <question>
```

---

## What does NOT belong here

- **Unit designation, commander, doctrine, motto, emblem symbology** — those live in `persona.md` and inherit. Don't restate them.
- **Era I composition / pose / palette** — that's `persona.md` and `aesthetic.md` territory.
- **Faction-aligned content** — Claude / ChatGPT / Copilot factions have their own spec files (`aesthetic_faction_*.md`). Reference them when the team interacts with a faction in Era II or III; don't redefine them here.
- **Status / lifecycle of generated assets** — sub-project #4's sidecar metadata.
