# Prompt — ADO Item (Operation) Poster

**Purpose:** Generate poster prompts to hand to the custom GPT for any PBI / ADO work-item poster.
**Style source of truth:** [`aesthetic.md`](./aesthetic.md). This file is generator scaffolding only — visual rules live there.

---

## When to use this

Use for any Operation poster: a PBI, a PR, a completed mission, a canceled scope, or an architecture refactor framed as an op. One operation may produce multiple posters across its lifecycle — see *State variants* below.

For the 13 War Room personas, use [`prompt_persona_image.md`](./prompt_persona_image.md) instead.
For AI faction posters, no dedicated prompt doc yet — per-faction canon lives in [`aesthetic_faction_claude.md`](./aesthetic_faction_claude.md), [`aesthetic_faction_chatgpt.md`](./aesthetic_faction_chatgpt.md), and [`aesthetic_faction_githubcopilot.md`](./aesthetic_faction_githubcopilot.md) (overview in `aesthetic.md` §10).

---

## Inputs you need before prompting

1. **Operation name** — `OPERATION X` (or the state-prefixed variant — see below).
2. **Mission line** — 3–6 words, active voice ("Seal the breach between plan and tenant").
3. **Mode** — A (painterly war scene), B (geometric propaganda), C (dark variant), D (flat infographic), or E (mixed media). See `aesthetic.md` §5.
4. **Software artifact(s)** — the modern thing a WW2 figure is handling (`QUERY TIMEOUT` on a CRT, sticky note `feature flag: ENHANCED ON`, a `VDS PASSWORD` PDF). The anachronism is the joke — see `aesthetic.md` §10.
5. **Tagline** — imperative triplet, one-line imperative, quote-style, or objective block. See `aesthetic.md` §8.
6. **Aspect ratio** — default portrait 2:3, or 1:1 / wide briefing as the composition demands. See `aesthetic.md` §7.

---

## Mode A — painterly war scene

> *A WW2-era American propaganda war-room poster, aged paper texture, parchment cream background with burnt orange, olive drab, and red accents. Multiple GI soldiers in helmets gathered around a planning table covered in maps and paper documents. In the scene: **[modern software artifact — e.g., a vintage CRT displaying 'QUERY TIMEOUT', sticky notes labeled 'feature flag ON']**. Top title bar reads **'OPERATION [NAME]'** in bold cream-on-red ALL CAPS. Bottom tagline reads **'[IMPERATIVE TRIPLET].'**. Painterly illustration, distressed grungy texture overlay, atmospheric warm lighting. Thin cream frame border. Portrait 2:3 aspect ratio.*

## Mode B — geometric propaganda

> *A WW2-era American propaganda poster, geometric flat-color illustration, parchment cream background with olive green, burnt orange, and red. Single GI soldier holding **[modern software artifact — e.g., a clipboard labeled 'NULL']**. Bold ALL CAPS title **'OPERATION [NAME]'** at top, red on cream. Bottom imperative tagline **'[ONE LINE].'**. Clean simplified shapes, no realistic shading, propaganda-poster aesthetic. Thin cream frame. Portrait 2:3.*

## Mode C — dark variant (use sparingly)

> *A WW2-era American propaganda poster ramped into gothic horror tones. Burning structures, lightning, deep red and black palette over parchment cream. **[Scene featuring the technical-debt or risky-shortcut artifact]**. Title **'OPERATION [NAME]'**, tagline **'[MORALLY GREY. OPERATIONALLY SUPERIOR.-style line]'**. Distressed, ominous, propaganda-poster aesthetic. Portrait 2:3.*

## Mode D / E

See `aesthetic.md` §5. Mode D for pure architecture / data-model diagrams (no soldiers, flat geometric icons); Mode E for posters with real photographic insets inside a propaganda frame. Dedicated prompt templates pending — extend from Mode A's pattern with the appropriate framing change.

---

## State variants — same operation, multiple posters

One operation can produce several posters over its lifecycle. The artwork can be regenerated or reused with overlays — both patterns exist in the current set.

| Title prefix | When | Notes |
|---|---|---|
| **`OPERATION X`** | Planned / in-progress | Base poster. |
| **`PR OPERATION X`** | Up for review | Same artwork; prefix-only change. |
| **`MISSION ACCOMPLISHED — OPERATION X`** | Completed | Often add a laurel-wreath medallion + ribbon at the bottom. |
| **`CANCELED OPERATION X`** | Abandoned | Stamp "CANCELLED" across the artwork. Swap tagline to acknowledge ("OPERATION CANCELLED BY HIGHER COMMAND"). |

When prompting, include the full prefixed title in the title-bar instruction so the GPT renders it correctly.

---

## Workflow

1. Pick the mode and fill in the inputs above.
2. Paste the matching template into the custom GPT, replacing `[bracketed]` slots.
3. If the result drifts (modern military gear, generic-AI palette, white background, etc.), correct by quoting `aesthetic.md` §3 (palette), §6 (iconography), or §10 (anachronism rule) in the follow-up message.
4. Save successful prompts back here as named examples once a few good ones land.
