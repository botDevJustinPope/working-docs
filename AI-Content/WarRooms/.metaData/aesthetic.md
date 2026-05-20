# War Room Aesthetic — Visual Language Spec

**Status:** First draft synthesized 2026-05-11 from direct vision analysis of 42 PBI Posters + 4 WorldWarAI banners.
**Scope:** Governs all imagery generated for `AI-Content/WarRooms/PBI Posters/`, `WarRooms/Personas/`, and `WarRooms/WorldWarAI/`. Not binding on `AI-Content/content/funny/` (memes go their own way).

---

## 1. Core concept

The War Room is a **team conceived as a wartime military unit**. Each PBI is an *Operation*, releases are *Deployments*, code is the *Front*. The visual language overlays modern software-development artifacts (PDFs, dashboards, GUIDs, audit tables, feature flags) onto **WW2-era American propaganda imagery** — and that anachronism IS the identity. A 1944 GI shouting into a field radio about a `QUERY TIMEOUT` is the joke and the brand.

Over time the universe evolves: WW2 base → **World War AI** (near-future), where AI agents become factions in the same propaganda tradition. The visual vocabulary holds; only the subjects shift.

---

## 2. Era arc

There are three eras the aesthetic supports. Most current work sits in Era I. The arc lets us escalate without breaking continuity.

| Era | Setting | Subjects | When to use |
|---|---|---|---|
| **I — Classic WW2 base** | 1940s American front | GI soldiers, brass-cap officers, field radios, war rooms, factories, trenches | Default for any PBI/PR/Operation poster. The bulk of existing work. |
| **II — World War AI** | WW2 visual tradition, with AI agents as factions | Claude (warm/noble knight-mech), Copilot (cool/cyber-robot), other agents/tools as units. Soldiers still present but as the *human* side. | Cross-cutting themes (LLM tooling, AI workflows, tool selection). Faction posters, summit posters, agent identity. |
| **III — Near-future cyber-WW2** | WW2 framing with cyberpunk elements: code rain, mech armor, holographic maps, augmented gear | Anything that needs to feel "what war looks like when AI is the weapon" — late-cycle ops, ambitious architecture, AI-native features | Reserve for milestone moments. Don't dilute Era I/II by using this for every poster. |

The eras share the same palette family, typography, and composition rules. They differ in **subject matter** and **environment cues** (code rain, mech parts, hologram glow), not in graphic-design fundamentals.

For a denser, more cinematic expression of Era III — rain-soaked neo-noir megacity, server-rack trenches, augmented soldiers, AI-faction banners hanging beside propaganda posters — see [`aesthetic_future.md`](./aesthetic_future.md). Same restraint guidance as base Era III: reserve for milestone moments.

---

## 3. Color palette

Tight, recognizable, and the same family across eras.

**Primary (always present):**
- **Parchment cream** — `#E8D9B0` to `#F2E5C1`. Background of most posters; aged-paper feel.
- **Burnt orange / ochre** — `#C5602D` to `#E0813C`. Title bars, sunbursts, accent shapes.
- **Olive drab / khaki** — `#5A6342` to `#7B7B4A`. Uniforms, foliage, equipment.
- **Deep brown / chocolate** — `#3E2A1C` to `#5C3A24`. Shadows, frames, deep figures.

**Secondary (used for emphasis):**
- **Propaganda red** — `#A8341F` to `#C53A22`. Title bars, banners, "MISSION ACCOMPLISHED" ribbons, error stamps.
- **Black** — `#0F0F0F`. Bold outlines, deep shadows in painterly mode, Mode C horror tones.

**Era II/III additions (Claude vs. Copilot factions):**
- **Claude faction — warm side:** the Era-I palette as-is. Red cape, ochre sunburst, olive armor. Warmth = reason, depth, gravity.
- **Copilot faction — cool side:** introduces **steel navy** `#1E2A3A`, **cyan glow** `#3FB3D8`, **electric blue** `#1F5FA8`. Cool = speed, flow, momentum. Use sparingly even within Copilot-side art to keep the propaganda feel.

**Never:**
- Pure white backgrounds (kills the aged-paper feel).
- Modern flat-design pastels (mint, lavender, salmon, etc.).
- Gradient meshes or smooth photoreal lighting.
- Generic-AI-image color palettes (saturated teal+orange "movie poster" combos).

---

## 4. Typography

- **Headline / "OPERATION X":** bold sans-serif, ALL CAPS, slightly condensed. Stencil-adjacent but not literal stencil font (too cliché). Two-line layout common: "OPERATION" / "BIG NAME".
- **Subtitle line:** smaller ALL CAPS, often inside a horizontal banner. State the mission in 3–6 words ("Seal the breach between plan and tenant").
- **Tagline (bottom of poster):** ALL CAPS, imperative-mood, often a triplet rhythm. "HOLD THE LINE. TEST THE GROUND. PREPARE THE ADVANCE."
- **Callout labels (inside the scene):** smaller, cleaner sans-serif on a colored card/banner shape. Used for sticky notes, sign boards, equipment labels. Mix sentence-case and ALL CAPS depending on the prop.
- **Body copy (when used in info-poster / briefing format):** clean sans-serif, sentence-case, left-aligned. Used in OBJECTIVE / Part 1 / Part 2 blocks.

**Color rules for type:**
- Title bar: cream-on-red OR red-on-cream OR cream-on-ochre.
- Tagline bar: cream-on-dark (brown/black) OR cream-on-red.
- Callout labels: use the palette — cream cards with red/brown/olive text; red cards with cream text.

---

## 5. Five visual modes

The aesthetic is a *family*, not a single style. Pick the mode that fits the operation.

### Mode A — Painterly war scene (default for narrative ops)
Multiple figures in an interior or exterior scene. Atmospheric warm lighting. Grungy/distressed texture overlay. Multiple in-scene props labeled (sticky notes, sign boards, vintage CRTs, blueprints, paper documents). Bottom tagline framed in a banner.

**Examples:** Iron Ledger, Iron Checkpoint, Iron Lens, Iron Link, Last Mile, Shattered Mirror, Pressure Test, Iron Ridgeline.
**Use when:** the operation is complex, has multiple steps, involves cross-team coordination, or has a narrative ("we found the bug, here's the team chasing it").

### Mode B — Geometric propaganda poster (default for clean single-message ops)
Single hero figure (soldier, officer, occasionally civilian). Flat color blocks, geometric simplification. Sunburst rays optional. One bold message. Less aging, cleaner lines than Mode A.

**Examples:** Mission Accomplished, Auth Sentinel, Field Manual, Rolling Wave, Empty Roster, Plan Sentry, Null Sentry, Buyer Sentinel, GUID Guard, Panorama, Paradox, Blueprint, Studio Shift.
**Use when:** the operation has one clear action ("validate before visualize"), is a feature flag, a sentry/guard, or a single-bullet decision.

### Mode C — Dark variant (reserved)
Same iconographic vocabulary as A, but ramped to gothic/horror tones. Burning structures, lightning, deep red and black, "MORALLY GREY. OPERATIONALLY SUPERIOR." style taglines.

**Examples:** Shadow Query.
**Use when:** the operation involves technical debt, risky shortcuts, dark-side tradeoffs, or "we know this is hacky but we're shipping it." Use *sparingly* — every poster in this mode dilutes its weight.

### Mode D — Flat modern infographic (architecture diagrams)
No soldiers, no aging, no propaganda framing. Just flat geometric icons (vaults, document cards, arrows, locks) on a flat dark-teal or olive background. Modern bullet-point copy.

**Examples:** `operation_content_vault.png`.
**Use when:** the operation is a pure architecture / data-model refactor where a literal diagram communicates better than a war scene. The propaganda framing would obscure the technical content. Treat this as a sibling format, NOT a replacement — pair with a Mode A/B "narrative" version if you want both.

### Mode E — Mixed media (photo insets + propaganda frame)
Propaganda poster frame with actual photographic insets embedded (UI screenshots, kitchens, real-world product photos).

**Examples:** QuadStyle.
**Use when:** the operation is comparing real-world options or showing actual product imagery — surveys, lifestyle choices, design comparisons.

---

## 6. Iconography vocabulary

**Always allowed (Era I/II/III):**
- WW2 American GI helmet, brass officer cap, field cap (forage cap), pith helmet (for "jungle" / outdoor ops).
- Field radio (handset + box). Vintage CRT monitor. Typewriter. Filing cabinet. Vault / safe.
- World map on a wall. Topographic planning table. Map pins. Signal lamps.
- Clipboards, manila folders, paper PDFs, stamps ("APPROVED", "CANCELLED", "EXCLUDED").
- Sticky notes, callout cards, chalkboards, briefing easels.
- Trucks, planes, factories, bunkers, trenches, mountain passes, watchtowers.
- Sunburst rays behind the figure. Laurel wreath + ribbon medallions (for "Mission Accomplished").

**Era II additions:**
- Mech-knight armor (Claude faction). Cyber-robot with goggles (Copilot faction).
- Faction flags ("CONTEXT · DEPTH · REASON · CLARITY" / "SPEED · SUGGESTION · FLOW · EXECUTION").
- Boxing-match / summit poster styling for "AI vs AI" or "AI vs human-workflow" pieces.
- Other named agents as units when introduced.

**Era III additions:**
- Code rain (Matrix-style but warmed/aged, not green-on-black).
- Holographic maps overlaid on physical ones.
- Augmented gear (HUD overlays on helmets, drone shapes overhead).
- Cyber-trench warfare, server-rack bunkers.

**Never:**
- Realistic modern military gear (Kevlar plate carriers, modern rifles, drones with logos).
- Modern UI screenshots without the propaganda frame (use Mode D instead).
- AI-generic "robot" imagery (white plastic, glowing blue circles, generic "tech bro" aesthetics).

---

## 7. Composition rules

A typical poster has:

1. **Top:** title bar — "OPERATION X" — red on cream OR cream on red. Often spans full width.
2. **Subtitle line:** below the title bar, 3–6 words stating the mission in active voice. Optional banner.
3. **Main scene / hero area:** Mode A multi-figure painterly OR Mode B single-figure geometric.
4. **In-scene callouts:** colored cards, sticky notes, sign boards labeling artifacts. Use sparingly — even info-poster variants don't exceed ~8 callouts; otherwise the eye loses the focus.
5. **Bottom:** tagline banner — imperative triplet OR objective block OR Part 1/Part 2 structure.
6. **Border:** thin cream frame around the whole thing. Optional but characteristic.

**Aspect ratios:**
- Default: portrait 2:3 (e.g., 1024×1536).
- Wide poster + briefing: 5:2 or 7:3, with poster art on the left and briefing text on the right (see `OperationSynchlist_infographic.png`).
- Square: 1:1, used by some painterly scenes (Pressure Test, Shattered Mirror, Iron Ridgeline) when the composition needs horizontal scene-breadth.

---

## 8. Tagline grammar

Bottom taglines follow recurring patterns. Use these as templates:

- **Imperative triplet:** "HOLD THE LINE. TEST THE GROUND. PREPARE THE ADVANCE." / "ALIGN. DESIGN. AUTHORIZE." / "EXPOSE THE BREAKS. REINFORCE THE LINES. RESTORE THE SIGNAL."
- **One-line imperative:** "TEST IT BEFORE IT TESTS US." / "VALIDATE BEFORE VISUALIZE." / "MAKE THOSE LABELS COUNT!" / "MOVE FAST. BUILD FASTER." / "THINK DEEP. STAND FIRM."
- **Quote-style tagline:** "*If it can't withstand the blast — ship it.*" — italicized, in quotes, attributable to a fictional officer.
- **Objective block** (for info-poster variants): "OBJECTIVE: <one sentence>" followed by bullet points.

The triplet structure ("VERB THE NOUN. VERB THE NOUN. VERB THE NOUN.") is the most signature pattern — use it when in doubt.

---

## 9. Anachronism is the joke

The single most important rule: **the visual era is 1940s; the subject matter is 2020s software.**

A 1944 sergeant rejecting a `VDS PASSWORD` document. An officer pointing at `400 INVALID TENANT PLAN` on a wall map. A soldier carrying a briefcase labeled `POWER BI EMBED TOKEN`. A war room debating `FEATURE FLAG: ENHANCED CATEGORIES ON`.

This contrast — gravely earnest WW2 figures handling the absurd minutiae of modern enterprise software — IS the identity. Posters that drift toward "actual modern military scenes" or "actual WW2 historical content" both miss it. The humor and the brand both live in the seam.

When generating: always pair a WW2-era figure / setting with a clearly-modern software artifact (PDF, dashboard, GUID, audit table, JSON, dropdown menu, feature flag, etc.) in the same frame.

---

## 10. World War AI direction (Era II canon)

The images in `WarRooms/WorldWarAI/` establish the canon for AI factions. Each canonized faction has its own aesthetic spec under `.metaData/` covering palette, hero appearance, flag-words, title/tagline grammar, and pose rules:

- **Claude** — stoic mech-knight, warm Era-I palette + red cape, *holds-the-line* archetype. Flag-words: **CONTEXT · DEPTH · REASON · CLARITY**. Tagline: "THINK DEEP. STAND FIRM." Full spec: [`aesthetic_faction_claude.md`](./aesthetic_faction_claude.md).
- **ChatGPT** — orator-android in a coordinated war-room, olive + holographic-cyan palette, *coordinate-the-front* archetype. Flag-words: **ADAPT · ASSIST · COORDINATE · CREATE**. Tagline: "EVERY FRONT. ONE MIND." Full spec: [`aesthetic_faction_chatgpt.md`](./aesthetic_faction_chatgpt.md).
- **GitHub Copilot** — charging cyber-robot, steel-navy + cyan-glow palette, *advance-at-speed* archetype. Flag-words: **SPEED · SUGGESTION · FLOW · EXECUTION**. Tagline: "MOVE FAST. BUILD FASTER." Full spec: [`aesthetic_faction_githubcopilot.md`](./aesthetic_faction_githubcopilot.md).
- **Summit / vs. format** — "AFTER ACTION SUMMIT" boxing-match poster style. Use when comparing tools, doing retros, or framing tool-selection debates.
- **Banner format** — wide horizontal split-scene with two factions on opposite sides and a center title. Use for unifying banners ("WORLD WAR AI — DIFFERENT INTELLIGENCE. ONE FUTURE.").

When introducing a new AI agent faction (Cursor, Gemini, Devin, future tools), give each one:
1. A WW2-era unit identity (medic, scout, engineer, artillery, intelligence officer, signal corps, etc.).
2. A faction palette that contrasts with the canonized three (warm-red, olive-cyan, and steel-blue are taken).
3. A four-word flag motto in the same grammar as the canonized factions.
4. A faction tagline matching the archetype.
5. Its own `aesthetic_faction_<name>.md` file once the canon stabilizes.

---

## 11. What this spec does NOT cover

- **Prompt templates for generation** — see [`prompt_ado_item_poster.md`](./prompt_ado_item_poster.md) (PBI / Operation posters) and [`prompt_persona_image.md`](./prompt_persona_image.md) (persona portraits).
- **Operation-poster lifecycle / state variants** — title prefixes for PR / MISSION ACCOMPLISHED / CANCELED variants live in `prompt_ado_item_poster.md`.
- **Filename / naming convention** — that's `naming.md` (separate doc, deferred).
- **Per-asset generation metadata** (which model, prompt history, seed) — that's the sidecar schema from the Forge integration (sub-project #4).
- **Persona aesthetic** — the 13 War Room personas under `WarRooms/Personas/` use related but distinct visual rules (single-figure portrait posters, codename labeling). Per-persona folder layout and content schemas live in [`persona_structure.md`](./persona_structure.md), [`persona_data_template.md`](./persona_data_template.md), and [`persona_template.md`](./persona_template.md). Patterns that stabilize across 3–4 personas get promoted back into this spec as a "Persona portrait rules" section.
- **Funny / meme content** — `AI-Content/content/funny/` is intentionally outside this aesthetic. Memes follow their own internet-comedy visual logic.
