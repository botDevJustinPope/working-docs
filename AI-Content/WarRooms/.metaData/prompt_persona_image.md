# Prompt — Persona Image

**Purpose:** Generate prompts for the 13 War Room persona portraits under `WarRooms/Personas/`.
**Style source of truth:** [`aesthetic.md`](./aesthetic.md). This file is generator scaffolding only.

**Status:** Scaffold. Persona-specific visual rules (codename labeling, portrait composition, signature props) are flagged as deferred in `aesthetic.md` §11 ("Persona-specific rules belong in sub-project #3"). Treat the template below as a starting point and refine as we generate.

---

## When to use this

Use for the 13 named War Room personas: single-figure portrait posters with codename labeling.

Do NOT use for:
- PBI / Operation posters → [`prompt_ado_item_poster.md`](./prompt_ado_item_poster.md)
- AI faction posters → per-faction canon in [`aesthetic_faction_claude.md`](./aesthetic_faction_claude.md), [`aesthetic_faction_chatgpt.md`](./aesthetic_faction_chatgpt.md), [`aesthetic_faction_githubcopilot.md`](./aesthetic_faction_githubcopilot.md) (overview in `aesthetic.md` §10); dedicated prompt doc pending

---

## Inputs you need before prompting

1. **Codename** — the persona's War Room handle.
2. **Real-world role** — actual job / responsibility being personified (lets the GPT pick the right WW2 unit analogue).
3. **WW2 unit identity** — pick one that maps to the role: intelligence officer, field medic, scout, signal corps, engineer, artillery captain, quartermaster, war correspondent, etc.
4. **Era** — usually Era I (classic WW2). Era II/III reserved for AI factions, not the standard 13. See `aesthetic.md` §2.
5. **Faction palette** — default warm Era-I palette. Cool / steel palette is reserved for Copilot-side AI factions. See `aesthetic.md` §3.
6. **One-line descriptor** — what the figure is doing / holding / about to do. Pair with a modern-software artifact per the anachronism rule (`aesthetic.md` §10).

---

## Base template

> *A WW2-era American propaganda portrait poster, single-figure composition. Aged paper texture, parchment cream background with burnt orange, olive drab, and red accents. **[Codename]** depicted as a **[WW2 unit identity — e.g., intelligence officer in brass cap with map case]**, **[one-line action / pose / artifact pairing]**. Bold ALL CAPS codename label **'[CODENAME]'** prominent on the poster — cream-on-red or red-on-cream. Optional subtitle banner stating the role-line in 3–6 words. Painterly illustration with distressed grungy texture overlay, atmospheric warm lighting; sunburst rays optional. Thin cream frame border. Portrait 2:3 aspect ratio.*

---

## What we don't know yet

- Exact codename label placement (top banner vs. mid-ribbon vs. bottom plate).
- Whether persona posters get taglines, and if so what grammar (the §8 grammars are tuned for Operation posters, not portraits).
- Whether each persona has a recurring prop / signature artifact across appearances.
- Whether the portrait gets a mode-equivalent split (painterly vs. geometric) the way Operation posters do.

Fill these in as the 13 personas get generated. Once 3–4 personas settle on a stable pattern, promote those choices into `aesthetic.md` as a new "Persona portrait rules" section.

---

## Workflow

1. Pick a persona and fill in the inputs above.
2. Paste the template into the custom GPT, replacing `[bracketed]` slots.
3. Iterate. Note what worked and what drifted.
4. Save successful prompts back here as named examples.
