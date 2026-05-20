# Persona Folder Structure — War Room

**Status:** First draft 2026-05-13. Defines the per-persona folder layout under `WarRooms/Personas/`.
**Relationship to other docs:**

- Visual rules → [`aesthetic.md`](./aesthetic.md) (Era arc, palette, typography, modes).
- Image-prompt template → [`prompt_persona_image.md`](./prompt_persona_image.md).
- Factual content schema → [`persona_data_template.md`](./persona_data_template.md).
- Creative / in-universe schema → [`persona_template.md`](./persona_template.md).

This file is the *layout* spec. It does not prescribe content — that lives in the two template docs above.

---

## 1. One folder per person

Each named team member gets exactly one folder under `WarRooms/Personas/`. Folder name format:

```
<RealName>_<Codename>
```

PascalCase on both halves. Examples: `EricHickey_Atlas/`, `RobHobbs_Tactician/`, `CharlieBradley_Blueprint/`.

The real-name half is the canonical anchor (it can be looked up against `AI-Content/people/`); the codename half is the War Room handle that appears in posters and in-universe content.

---

## 2. Files inside a persona folder

| File / directory | Required? | Purpose |
|---|---|---|
| `data.md` | yes | Factual account of the team member. Real role, background, LinkedIn link, notable contributions. Schema: [`persona_data_template.md`](./persona_data_template.md). |
| `persona.md` | yes | Creative document translating the person into the War Room theme. Codename voice, WW2 unit analogue, signature props, tagline, in-universe backstory. Schema: [`persona_template.md`](./persona_template.md). |
| `source.<ext>` *or* `source/` | yes | Reference photo(s) of the person. **Single image:** `source.jpg` / `source.png` at the folder root. **Multiple images:** a `source/` directory containing all of them. Never mix — if a `source/` directory exists, no loose `source.*` file should sit beside it. |
| `poster.png` | when generated | The primary persona portrait, generated to the rules in `aesthetic.md` + `prompt_persona_image.md`. |
| `variants/` | optional | Alternate generated pieces for this persona — secondary portraits, mood variants, in-the-field shots, cartoon styling, etc. Filename should hint at the variant (`cheesing.png`, `serious.png`, `inthefield.png`, `jedi_padawan.png`). |
| Reference documents (e.g. `Profile.pdf`) | optional | Source materials that informed `data.md` — LinkedIn PDF exports, internal-doc screenshots, exported resumes. Keep at the root for single documents; if more than two or three accumulate, group them in a `references/` directory. Cite each one from the `source_notes:` section of `data.md`. |

Drafts, generation prompts, and conversation logs do NOT belong at the persona folder root — those live in the sidecar schema from sub-project #4 or in scratch directories outside `WarRooms/`. Reference documents are the one exception, because they directly back up the factual claims in `data.md`.

---

## 3. Canonical example

```
WarRooms/Personas/EricHickey_Atlas/
├── data.md
├── persona.md
├── source.jpg
├── poster.png
└── variants/
    ├── briefing.png
    └── parade.png
```

Multi-source variant:

```
WarRooms/Personas/JustinPope_Overseer/
├── data.md
├── persona.md
├── source/
│   ├── headshot_2023.jpg
│   ├── on_site_2024.jpg
│   └── cartoon_reference.png
├── poster.png
└── variants/
    ├── Justin_Pope_cartoon.png
    ├── Justin_Pope_cowboy_programer.png
    └── jedi_padawan.png
```

---

## 4. Lifecycle — how a persona gets fleshed out

1. **Folder exists with `source.*` only** (current state for most of the 13).
2. **Draft `data.md`** from a user-provided account + LinkedIn lookup. Mark `source_notes:` honestly — what came from the user, what came from public profile, what is inferred.
3. **Draft `persona.md`** referencing the locked aesthetic and the facts in `data.md`. The creative leap (WW2 unit, signature prop, voice) is a deliberate choice — record the *why*, not just the *what*.
4. **Generate `poster.png`** using the codename, the WW2 unit identity from `persona.md`, and the prompt template in `prompt_persona_image.md`. Iterate until it locks.
5. **Add `variants/`** as new pieces get crafted — alt poses, in-the-field shots, cartoon styling, faction crossovers.

Steps 2 and 3 can be drafted before any image generation; nothing in this structure depends on OpenAI image-gen quota being available.

---

## 5. Promotion rule

When 3–4 personas settle on stable patterns for portrait composition, signature props, or voice, promote those choices upward:

- **Visual patterns** → new "Persona portrait rules" section in `aesthetic.md`.
- **Content patterns** (recurring tropes, faction archetypes) → update `persona_template.md` so future personas inherit the convention.

Per-persona files should hold the *specifics*; the templates and `aesthetic.md` should hold what's *general*.

---

## 6. Out of scope

- **Operation / PBI posters** — `WarRooms/PBI Posters/`. Different aesthetic role, different schema.
- **AI faction personas** (Claude, Copilot, ChatGPT) — they have their own faction-spec files (`aesthetic_faction_*.md`) and are not part of the human-personas folder.
- **People without a persona folder** — anyone who appears in `AI-Content/content/funny/` or other content but doesn't have a `Personas/<Name>_<Codename>/` folder is intentionally not personified yet. Promotion to a persona folder is a deliberate decision, not automatic.
