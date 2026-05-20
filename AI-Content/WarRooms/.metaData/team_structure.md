# Team Folder Structure — War Room

**Status:** First draft 2026-05-14. Defines the per-team folder layout under `.metaData/Teams/`.
**Relationship to other docs:**

- Personas (people) → [`persona_structure.md`](./persona_structure.md). Teams are the *units* those people belong to.
- Factual content schema → [`team_data_template.md`](./team_data_template.md).
- Creative / in-universe schema → [`team_template.md`](./team_template.md).
- Visual rules → [`aesthetic.md`](./aesthetic.md) (palette, typography, Era arc; same canon as everything else).

A *team* is a real, named org-chart unit at the company. A *persona* is an individual on one of those teams. Eric Hickey (Atlas) commands two teams: VDS and Indago — so under his entry in `Personas/EricHickey_Atlas/` there is no team content, and under `.metaData/Teams/VDS/` and `.metaData/Teams/Indago/` there is no people content. The two systems cross-link, but each holds only what belongs to its own layer.

---

## 1. One folder per team

Each named org-chart team gets exactly one folder under `.metaData/Teams/`. Folder name format:

```
<TeamHandle>
```

`TeamHandle` is the **short internal handle** the company uses for the team day-to-day, not the long marketing name. For example:

- `VDS/` — internal handle for the VEO® Design Studio team.
- `Indago/` — internal handle for the VEO Indago team.

PascalCase or all-caps acronyms are both fine; match what the team actually goes by.

Why short handles instead of full product names? The marketing name is captured *inside* `data.md`. The folder is for finding the team, and short handles make cross-links readable in other files.

---

## 2. Files inside a team folder

| File / directory | Required? | Purpose |
|---|---|---|
| `data.md` | yes | Factual account of the team. What product they own, what it does, how the team is structured, who commands it, current headcount, tech stack, notable history. Schema: [`team_data_template.md`](./team_data_template.md). |
| `persona.md` | yes | **Era I default** creative document translating the team into the War Room theme — typically as a *unit* (detachment, section, platoon, etc.) under a persona's command. Includes unit designation, emblem, doctrine, motto. Anchored to [`aesthetic.md`](./aesthetic.md). Schema: [`team_template.md`](./team_template.md). |
| `persona_future.md` | recommended | **Era III specialization** of the same unit — denser, cyberpunk-fused expression for "World War AI" milestone moments. Anchored to [`aesthetic_future.md`](./aesthetic_future.md). Schema: [`team_future_template.md`](./team_future_template.md). Use restraint with actual poster generation in this aesthetic; the file exists so the universe-building is in place even if outputs in this mode stay rare. |
| `poster.png` | optional, when generated | Team poster — unit pennant, group portrait, scene built around the doctrine. Follows `aesthetic.md` for the default; if generated in Era III, follows `aesthetic_future.md`. Not required up front; many teams will exist as `data.md` + `persona.md` (+ optional `persona_future.md`) only. |
| `poster_future.png` | optional, when generated | Era III companion poster, parallel to `persona_future.md`. |
| `variants/` | optional | Alternate generated pieces for this team. Same convention as persona `variants/`. |
| Reference documents (PDFs, screenshots, exported wiki pages) | optional | Source materials that informed `data.md`. Keep at the root for one or two; if more than two or three accumulate, group them in a `references/` directory. Cite each from the `source_notes:` section of `data.md`. |

Drafts, generation prompts, and conversation logs do NOT belong at the team folder root.

---

## 3. Canonical example

```
WarRooms/
├── .metaData/
│   └── Teams/
│       ├── VDS/
│       │   ├── data.md
│       │   ├── persona.md            # Era I
│       │   ├── persona_future.md     # Era III
│       │   ├── poster.png            # optional
│       │   └── variants/             # optional
│       └── Indago/
│           ├── data.md
│           ├── persona.md            # Era I
│           ├── persona_future.md     # Era III
│           └── Wiki-export.pdf       # reference doc
└── Personas/
    └── EricHickey_Atlas/
        ├── data.md                   # Eric commands VDS + Indago
        └── persona.md                # Atlas as Company Commander of both
```

---

## 4. Hierarchy convention (people ↔ teams)

The default in-universe military hierarchy is:

| In-universe rank / unit | What it represents at the company |
|---|---|
| **Company** | A senior leader's domain — a Director (or higher) and the teams reporting up to them. |
| **Platoon** | A single team / dev squad — the actual org-chart unit. Led by a team lead / tech lead (the persona who is the *commander* of that platoon). |
| **Squad** | A sub-team or feature pod within a platoon, if one exists. Optional. |

Examples:

- **Atlas's Company** = VDS Platoon + Indago Platoon, both under Eric Hickey.
- **VDS Platoon** = the VEO Design Studio team itself.
- **Indago Platoon** = the VEO Indago team itself.

A team's `persona.md` records who commands the platoon and who reports up the chain. A person's `persona.md` records which platoons they belong to or command. The two cross-link by name and codename.

This is the *default* convention. If a particular team or persona has a reason to break it — e.g., a battalion-scale shared-services group, or an independent specialist who doesn't sit in a platoon — record the deviation explicitly in that team's or persona's `persona.md`.

---

## 5. Lifecycle — how a team gets fleshed out

1. **Folder exists empty** (or with reference documents only).
2. **Draft `data.md`** from the corporate website, any internal product docs, the team's repository / README, and user-provided context. Cite each source in `source_notes:`.
3. **Draft `persona.md`** — pick the unit designation (platoon, ordnance works, signal corps, etc.), the in-universe doctrine, the emblem, the motto. Anchor every creative choice to something in `data.md`.
4. **Cross-link the commander.** Update the commanding persona's `persona.md` so the team appears in their "Relationships and deployments" section.
5. **(Optional) generate `poster.png`** — team poster following the prompt template, codename labeling per `prompt_persona_image.md` adapted for a unit rather than an individual.

Steps 2 and 3 do not need OpenAI image-gen quota — only step 5 does.

---

## 6. Promotion rule

When 3–4 teams settle on stable patterns for unit designation, emblem style, or commander-relationship phrasing, promote those choices upward:

- **Visual patterns** → new "Team poster rules" section in `aesthetic.md`.
- **Content patterns** (recurring unit designations, doctrine framings, motto grammars) → update `team_template.md` so future teams inherit the convention.

Per-team files should hold the *specifics*; the templates and `aesthetic.md` should hold what's *general*.

---

## 7. Out of scope

- **Operation / PBI posters** — `WarRooms/PBI Posters/`. Different aesthetic role, different schema.
- **Individual personas** — `WarRooms/Personas/<RealName>_<Codename>/`. Same person doesn't live in two layers.
- **AI faction personas** (Claude, Copilot, ChatGPT) — they have their own faction-spec files (`aesthetic_faction_*.md`) and are not part of the human-team folder.
- **Cross-team programs** (book clubs, training initiatives, QA program) — those belong in the *commanding persona's* `data.md` / `persona.md`, not duplicated into every team they touch.
