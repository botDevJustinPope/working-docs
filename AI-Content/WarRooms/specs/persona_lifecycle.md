# Persona Lifecycle Spec — War Room

**Status:** First draft 2026-05-23.
**Scope:** End-to-end lifecycle of a War Room persona — from new-hire onboarding through poster refresh through decommissioning when a team member leaves.
**Source-of-truth files this spec coordinates with:**

- [`../.metaData/persona_structure.md`](../.metaData/persona_structure.md) — per-persona folder layout.
- [`../.metaData/persona_data_template.md`](../.metaData/persona_data_template.md) — factual schema (`data.md`).
- [`../.metaData/persona_template.md`](../.metaData/persona_template.md) — creative schema (`persona.md`).
- [`../.metaData/aesthetic.md`](../.metaData/aesthetic.md) — visual language (era arc, palette, modes, anachronism rule).
- [`../.metaData/aesthetic_future.md`](../.metaData/aesthetic_future.md) — Era III cyber-WW2 fusion environment.
- [`../.metaData/prompt_persona_image.md`](../.metaData/prompt_persona_image.md) — base persona-portrait prompt template.

This spec is the **workflow**, not the schema. The files above govern *what* lives in a persona folder; this spec governs *when* and *in what order* each artifact gets created, refreshed, or retired.

---

## 1. Lifecycle overview

A persona moves through four states:

1. **Onboarded** — folder exists, both `data.md` and `persona.md` are populated, both `poster.png` and `poster_future.png` exist, prompt files saved under `Prompts/`.
2. **In-progress** — folder exists but one or more of the artifacts above is missing or skeleton. Common transitional state during initial onboarding.
3. **Refresh** — an onboarded persona is being re-generated because aesthetic, voice, or persona details have shifted. Previous posters get archived; new prompts and images get written.
4. **Decommissioned** — the team member is no longer with the company. The persona folder is preserved (history matters) but moved out of the active roster.

The default direction is **In-progress → Onboarded → (Refresh* → Onboarded)* → Decommissioned**. Refresh can happen any number of times; decommissioning is one-way.

---

## 2. New-hire onboarding workflow

When a new team member joins and is being added to the War Room, run these steps in order. Each step has a gate — don't advance until it's met.

### Step 1 — Inputs and folder creation

**Inputs required from the requester:**

- Real name (canonical anchor).
- War Room codename (the in-universe handle that will appear on posters and across other personas' files). If undecided, brainstorm per the codename rules in [`persona_template.md`](../.metaData/persona_template.md) — codenames must center **heritage / role-posture**, never defector/refugee/displacement framing.
- A short account of who they are and what they do (3–10 sentences is plenty).
- Their public LinkedIn URL.
- A reference photo (single image) or a small set of reference photos (3–5).

**Actions:**

1. Create `WarRooms/Personas/<RealName>_<Codename>/` per `persona_structure.md` §1 (PascalCase on both halves).
2. Drop the reference photo(s):
   - Single photo → `source.jpg` (or `.png`) at the folder root.
   - Multiple photos → `source/` directory with all of them. Never mix loose `source.*` and a `source/` directory.
3. Drop any reference documents (LinkedIn PDF export, internal-doc screenshots) at the root, e.g., `Profile.pdf`. If more than two or three accumulate, group them in `references/`.

**Gate:** folder exists with source image(s) and reference documents in place.

### Step 2 — Draft `data.md` (factual)

Two sources of truth: the user's account and the team member's public LinkedIn profile. Inferences are allowed but must be flagged as *Inferred* in the `source_notes:` section. Anything that can't be verified is omitted, not invented.

Follow [`persona_data_template.md`](../.metaData/persona_data_template.md) strictly. Sections covered: role at the company, background, core skills, notable contributions, public profile links, source notes, open questions.

**Gate:** `data.md` exists, `last_updated:` is set, all factual claims are sourced or flagged inferred.

### Step 3 — Draft `persona.md` (creative)

This is where the real-person facts get translated into the War Room theme. Follow [`persona_template.md`](../.metaData/persona_template.md) strictly. Every creative choice must anchor to a `data.md` fact ("Quartermaster, because they own deployment tooling" — good; "Quartermaster because it sounds cool" — not good).

Lock these five things, because every downstream artifact reads them:

1. **Codename rationale** — why *this* codename for *this* person, tied to their real role or reputation.
2. **WW2 unit identity** — rank/role analogue (engineer, signal corps, field medic, intelligence officer, quartermaster, etc.), wartime function in one line, and the bridge from real role to wartime role.
3. **Signature props / recurring artifacts** — 2–3 items max. These propagate into every poster and variant.
4. **Portrait composition notes** — pose, setting, Mode A (painterly) vs Mode B (geometric), codename label placement.
5. **Tagline / motto** — one ALL CAPS-able line per `aesthetic.md` §8 grammar.

Voice/tone, relationships, Era II/III appearances, and open creative questions follow but are not load-bearing for the first poster.

**Gate:** `persona.md` exists, the five locks above are filled, `last_updated:` is set.

### Step 4 — Write `Prompts/prompt_poster.txt` (Era I poster prompt)

Generate the paste-ready prompt for the persona's primary Era I portrait. Format precedent: [`../Personas/MairimDelgado_Centinela/Prompts/prompt_poster.txt`](../Personas/MairimDelgado_Centinela/Prompts/prompt_poster.txt) — paste-ready (~250 words), structured into:

- **Opening anchor** — era statement, palette, aged-paper backbone rule, what to avoid (modern flat-design pastels, photoreal lighting, gradient mesh).
- **Hero figure** — codename in ALL CAPS, the WW2 unit identity from `persona.md`, costume specifics, heritage cues (flag patches, language signage on equipment, etc.) tied to `data.md`.
- **Pose / action** — drawn from `persona.md` portrait composition notes.
- **Background** — Era I setting (war room, trench, field tent, factory floor, checkpoint, etc.).
- **Anachronism** — the modern-software artifact in the 1940s frame per `aesthetic.md` §9. This is load-bearing; never skip it.
- **Top** — title bar with the codename in cream-on-red or red-on-cream ALL CAPS; optional subtitle banner.
- **Bottom** — tagline banner from `persona.md`, per the tagline grammar in `aesthetic.md` §8.
- **Closing** — aspect ratio (portrait 2:3), Mode A or B, thin cream frame border, aged-paper distress survives.

Era I means **no cyberpunk elements, no AI factions, no holographic gear.**

**Gate:** prompt file exists under `Prompts/`, reads as a complete paste-ready prompt at Mairim's depth.

### Step 5 — Write `Prompts/prompt_poster_future.txt` (Era II+III fused)

Same structure as Step 4, with the future-canon overlay:

- The visual era is still fundamentally 1940s wartime propaganda. The **parchment-cream / aged-paper backbone must dominate.** If the result reads as "Cyberpunk 2077 fan art" instead of "WW2 propaganda with cyberpunk elements," the palette balance has tipped wrong.
- The **hero figure is cyber-augmented** — HUD visor (cyan, orange, or holographic-blue), mech-assisted armor on shoulders/arms/legs, fiber-optic radio gear, brass-and-glass targeting monocles, handheld analog-cyber terminals. The augmentations grow out of `persona.md`'s signature props.
- The **environment is fused** — rain-slick neo-noir, server-rack trenches, holographic battle maps over wooden strategy tables, CRT monitors showing JSON / feature flags / GUIDs, vintage radios connected to fiber-optic cables, volumetric fog and rain.
- **AI factions are NOT included by default.** Claude / ChatGPT / Copilot are by-request — include them only when the work explicitly asks for it. Default future prompts show the persona alone in their cyber-trench environment.
- Electric cyan (`#3FB3D8`) and holographic blue (`#1F5FA8`–`#3FB3D8`) are used **sparingly** as accents only. Neon is set-dressing, never the dominant color.
- The **anachronism rule still holds** — pair the cyber-augmented WW2 figure with a clearly-modern software artifact in-frame (manifest, deployment, feature flag, JSON fragment, etc.).

Reference precedent: [`../Personas/MairimDelgado_Centinela/Prompts/prompt_poster_future.txt`](../Personas/MairimDelgado_Centinela/Prompts/prompt_poster_future.txt), with the AI-faction-banner element dropped per the by-request rule above.

**Gate:** prompt file exists under `Prompts/`, reads as a complete paste-ready prompt, fused Era II+III is correctly balanced.

### Step 6 — Generate `poster.png` and `poster_future.png`

Paste each prompt into the image generator (currently the Front Line Poster Forge custom GPT — see `documentation/skills/external-services/front-line-poster-forge.md`). Iterate until the result locks. Save the final images at the persona folder root.

**Note:** OpenAI billing has historically been the gating constraint here. Steps 1–5 do not depend on image-gen quota; only Step 6 does. A persona is considered "onboarded" once Step 6 completes for both posters.

**Gate:** `poster.png` and `poster_future.png` both exist at the folder root.

---

## 3. Refresh workflow

A persona's posters get refreshed when the aesthetic shifts, the persona's voice/props evolve, or the original output drifted. Refresh does NOT mean drafting new `data.md` or `persona.md` — those evolve through normal edits with `last_updated:` bumps. Refresh is specifically about regenerating the imagery.

**Pre-flight:**

- `persona.md` is up to date. If signature props, WW2 unit identity, or portrait composition have changed, update `persona.md` *first* and bump `last_updated:`.
- Decide which posters are being refreshed: just `poster.png`, just `poster_future.png`, or both.

**Steps per poster being refreshed:**

1. **Archive** the current image: `git mv` it into `variants/poster_archived<YYYYMMDD>.png` (for the primary) or `variants/poster_future_archived<YYYYMMDD>.png` (for the future). Use today's date.
2. **Rewrite** the corresponding prompt under `Prompts/` if the canon has changed or the prior prompt produced drift. Overwrite the existing file — the prior version is recoverable from git.
3. **Regenerate** the image via the Forge GPT. Save the new result back at the folder root with the canonical name (`poster.png` or `poster_future.png`).

**Folder hygiene during refresh:**

- If the persona folder uses `Prompt/` (singular) or `variant/` (singular), rename to `Prompts/` and `variants/` (plural) as part of the refresh. Both `persona_structure.md` and the precedent across the roster favor the plural form.
- If `Prompts/` doesn't exist yet on a refreshing persona, create it. Move any prior `Profile<Codename>_Future.txt` Era III character cards into the new `Prompts/` folder — those are a separate artifact but share the location.

---

## 4. Decommissioning workflow

When a team member leaves the company, their persona is **archived in place, not deleted.** The codename and prior contributions stay part of the canon history.

**Steps:**

1. Move the entire persona folder to `WarRooms/Personas/_Decommissioned/`. Use `git mv` to preserve history. The underscore prefix sorts `_Decommissioned/` to the top of the directory listing and visually separates it from the active roster.
2. Bump `last_updated:` in `data.md` and `persona.md`, and add a one-line note in each indicating the decommission date. Format: `**Decommissioned:** YYYY-MM-DD — no longer with the company.`
3. Update [`war-room-state` memory](../../../) (or equivalent project status doc) to reflect the reduced active-roster count.
4. Do NOT regenerate the decommissioned persona's posters in future passes. Skip them in roster-wide poster refreshes unless explicitly requested.

Decommissioned personas may still be referenced from other personas' `persona.md` files (relationships and deployments) — those references stay valid as historical context. Do not rewrite history to erase a decommissioned persona; the team's past collaborations are part of the canon.

**Precedent:** 2026-05-23 cleanup moved Charlie Bradley (Blueprint), Joe Ebeling (Chronos), Reid Wilson (Codeburst), and Sam Klepper (Private Klepper) into `_Decommissioned/`. Their files were preserved as-is and continue to be linked from any persona.md that referenced them.

---

## 5. Roster-wide passes

Occasionally the whole roster is refreshed in a batch — e.g., when the aesthetic canon changes meaningfully, or a new fused-era direction is introduced.

**Per-persona work:** identical to §3 (Refresh) for each persona, run end-to-end.

**Parallelization:** each persona's work is independent. A roster-wide pass can be dispatched as parallel agent jobs, one agent per persona, each with strict scope ("touch only this one folder"). Mairim (or any persona whose posters were just refreshed and are still considered locked) can be excluded from the pass.

**Format consistency:** all agents in a roster-wide pass should read the same Mairim-format precedent, so the resulting prompts share depth and structure.

**Commit hygiene:** one commit per persona is reasonable; one commit for the whole pass is also fine. The single-branch convention (see `documentation/assistants/claude.md`) means there's no PR per persona — commit and push when ready.

---

## 6. Out of scope for this spec

- **Aesthetic rules and palette.** Those live in `aesthetic.md` and `aesthetic_future.md`. This spec assumes the rules are correct and doesn't restate them.
- **Schema for `data.md` / `persona.md`.** Those live in the template files. This spec sequences when each gets drafted.
- **Image-generation tooling.** The current path is the Forge custom GPT plus the `Send-OpenAIChat.ps1` / `New-OpenAIImage.ps1` wrappers when billing is sorted. Tool selection is not this spec's concern.
- **Naming convention for archived files.** This spec uses `poster_archived<YYYYMMDD>.png`; a separate `naming.md` (deferred) will lock the broader naming conventions.
- **Operation / PBI posters.** Those use a different workflow rooted in `prompt_ado_item_poster.md`. Operation posters are not personas and don't follow this lifecycle.
- **AI faction personas.** Claude, Copilot, ChatGPT are faction artifacts, not human team-member personas. They live under separate aesthetic-faction docs and are out of this spec's scope.

---

## 7. Quick checklist — onboarding

When onboarding a new hire, work through this list:

- [ ] Folder created at `Personas/<RealName>_<Codename>/`.
- [ ] `source.*` or `source/` populated with reference photo(s).
- [ ] `Profile.pdf` or other reference documents at root (cited in `data.md` source notes).
- [ ] `data.md` drafted to the template, all sources flagged in `source_notes:`.
- [ ] `persona.md` drafted to the template, the five locks (codename rationale, WW2 unit, props, composition, tagline) are filled.
- [ ] `Prompts/prompt_poster.txt` written, Era I, ~250 words, Mairim-format depth.
- [ ] `Prompts/prompt_poster_future.txt` written, Era II+III fused, no AI factions (unless requested), parchment backbone dominant.
- [ ] `poster.png` generated and saved at root.
- [ ] `poster_future.png` generated and saved at root.
- [ ] Roster reference doc / project memory updated to include the new active persona.

## 8. Quick checklist — decommissioning

When a team member leaves:

- [ ] Folder moved to `Personas/_Decommissioned/<RealName>_<Codename>/` via `git mv`.
- [ ] `data.md` and `persona.md` updated with `**Decommissioned:** YYYY-MM-DD` line and bumped `last_updated:`.
- [ ] Roster reference doc / project memory updated to reflect the reduced active count.
- [ ] Cross-references from other personas' `persona.md` left intact (don't rewrite history).
