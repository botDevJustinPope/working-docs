# Château — In-Universe Persona

**Real-world anchor:** [`data.md`](./data.md) — James "Jim" Warnement, Director of Implementation in BuildOn's Service and Support department (customer-facing; ~20-year tenure despite an out-of-date profile).
**Era applicability:** Era I default.
**Faction:** Allied (human side).
**Last updated:** 2026-06-23

---

## Status

**First draft, 2026-06-23.** Codename **Château** is locked (brainstormed and chosen by the user). The five lifecycle locks below — codename rationale, WW2 unit identity, signature props, portrait composition, tagline — are filled. Voice/tone is now anchored by a real artifact (see the joke variant). Some factual anchors (reporting line, prior background) remain open in [`data.md`](./data.md) and do not block this creative draft.

**Assets on file:** `source.jpg` (headshot, ready for portrait generation) · `variants/jim_needs_to_update.png` (joke / meme image — see *Voice* and *Variants* below). The canonical Era I poster (Mode B château general) is **not yet generated**.

## Codename rationale

**Château** is the *château general* — the commander who runs the battle from a wall map miles behind the line, by map and field telephone, in comfort, and never sets foot in the mud. The front-line troops catch whatever he sends forward.

Facts from [`data.md`](./data.md) anchor it:

- **The command echelon is organizationally removed from the engineering front.** Jim sits in **Service and Support** — a customer-facing org *outside* Atlas's software-development org, a command level distant from where the code is actually written and broken.
- **He lobs "problems" forward without grasping the ground-truth.** Per the user's framing, his position is "so far removed that he doesn't understand what we do, yet he throws his problems at us regardless" — bug reports of varying validity, often the product used in ways it was never designed for. The château general's signature: confident orders issued from a map, detached from what's actually happening on the ground.
- **He orders impossible offensives.** His defining tell is *proposing outrageous or complicated ideas that are hard to implement* — the grand sweeping arrow drawn across the map ("take that ridge by dawn") with no feel for the terrain, the wire, or the cost of executing it. This is the purest château-general trait: bold strategy from the armchair, paid for by the troops downrange.

### Codename framing rule

Per repo convention (war-room codenames center heritage / role-posture, never defector / refugee / displacement framing): **Château centers a *command-echelon role-posture***, the distant-HQ general. He is firmly **Allied** — same side, just far behind the line. The codename is an *affectionate roast* of organizational distance, not an enemy or saboteur framing. Keep all in-universe content good-natured; he is a senior colleague, not an antagonist.

## WW2 unit identity

- **Rank / role analogue:** General Staff / High Command officer at a rear château headquarters — brass cap, general's insignia.
- **Wartime function:** directs the battle from a grand wall map far behind the front, orders grand sweeping offensives the troops can't actually execute, issues them down a field telephone, and forwards "problems" to the front-line units — without ever walking the ground himself.
- **Why this unit:** Director (a command echelon) + organizational distance from engineering + a habit of sending issues forward = the classic rear-HQ château general. The mapping is direct: *removed authority that commands by map and telephone* → the château general who never sees the mud.

## Signature props / recurring artifacts

- **The grand wall map he points at but has never walked** — and the **big sweeping offensive arrows** he draws across it, confident strokes through terrain he's never seen, mapping advances no one downrange can actually execute. The map *is* his reality; this is the prop that carries the whole gag.
- **The field telephone** — the channel down which dispatches and "problems" arrive at the front. He barks into it; the troops downrange answer for it.
- **Château comfort** — armchair, fireplace, decanter: the trappings of distance from the mud. Signals *how far back* he is without a word of dialogue.

Aim is three artifacts max. Avoid front-line kit (rifle, helmet, field-radio-on-the-back) — those belong to the troops he's removed from. A swagger stick / map pointer is an acceptable fourth accent if a pose needs it.

## Portrait composition notes

- **Pose:** standing at a grand château war-map, swagger-stick / pointer tapping a spot on the map, field telephone in the other hand, mid-order. Confident, comfortable, unbothered.
- **Setting:** a richly appointed château war-room — paneled walls, fireplace, the wall map dominating. The *real* front is visible only as a tiny, distant view through a far window (mud and trenches, kept small and far).
- **Anachronism (required per `aesthetic.md` §9):** the thing he's pointing at on the map is a modern software artifact — a map pin or dispatch stamped **"THIS IS BROKEN!"** while a small label beneath it reads **"UPDATE REQUIRED — VERSION OUT OF DATE"** (i.e. the fault is on his end). The 1944 general gravely declaring a sev-unknown bug that's really just an un-applied update is the joke. Alternate artifacts: **"BUG? — WORKS ON MY SCREEN"**, **"PROD ISSUE — SEV: ?"**.
- **Mode:** **Mode B — Geometric propaganda poster** per `aesthetic.md` §5. Matches the active roster (Centinela, Ironforge, Overseer, Tinker).
- **Codename label placement:** **Top banner**, cream-on-red ALL CAPS — **CHÂTEAU**.
- **Subtitle band:** **DIRECTOR OF IMPLEMENTATION · GENERAL STAFF, REAR HQ** (olive band below the title bar).

## Voice / tone

Anchored by the joke variant `variants/jim_needs_to_update.png` (see *Variants*).

- **The impossible ask (primary tell):** breezily proposes outrageous or complicated things as if they were trivial — "can we just…?", "HOW HARD COULD IT BE?" — the grand offensive arrow drawn across the map with no sense of the cost to execute it. This is his defining behavior.
- **Signature catchphrase:** **"THIS IS BROKEN!"** — declared at full volume about something that, on inspection, just needs an update on his end (out-of-date browser, un-applied version, user error). The complaint half of the same coin as the impossible ask.
- **Cadence:** confident directives detached from ground-truth; declarative alarms, not questions. Everything is an emergency from the map's distance.
- **Lexicon:** speaks in objectives, timelines, and "the customer"; rarely in technical specifics. Refers to the engineering front as "the field" / "down there."
- **Never:** walks the mud, debugs at a keyboard, checks whether his own gear is current, scopes the work before proposing it, or concedes that the map ≠ the ground.

## Tagline / motto

**Locked (2026-06-23):**

> **"HOW HARD COULD IT BE?"**

The breezy impossible ask — the grand idea proposed from the armchair, hard to execute on the ground. Per `aesthetic.md` §8 (quote-style, attributable to a fictional officer). Optional ironic counterpoint line a piece may add beneath it: *"— from a man who has never taken the ridge."*

Secondary lines still available for other pieces:

- Catchphrase / complaint half: **"THIS IS BROKEN!"** (anchored by the joke variant) — often paired with *…it works on the map.*
- Imperative triplet (signature §8 pattern): **"DREAM IT. DEMAND IT. DELEGATE IT."**

## Relationships and deployments

- **Lobs problems forward to:** the **VDS Pathfinder Detachment** + **Indago Artillery Section** — the combined-arms engineering front under [`Atlas`](../EricHickey_Atlas/). They triage his dispatches.
- **Peer — *not* in chain:** [`Atlas`](../EricHickey_Atlas/) (Director of Software Development). Château commands a *different department* (Implementation) from his own château; he is not in Atlas's chain of command, and the two are peer directors.
- **Recurring foil:** the triage queue itself — issues of "varying validity" arriving from the rear. Frame affectionately; the gag is organizational distance, never malice.

## Variants

- **`variants/jim_needs_to_update.png`** — a modern **meme / joke** image (not a War Room propaganda poster; per `aesthetic.md` §4 funny content sits outside the Era aesthetic). James at his desk shouting **"THIS IS BROKEN!"** at monitors that are merely showing *Update Required / Chrome out of date / version no longer supported*; sticky notes read UPDATE!, SLOW, OUTDATED, UPDATE ME!; mug reads COFFEE FUELS FIXES; storm/lightning backdrop, "ERROR" tiling the screens. The gag — and the source of his catchphrase and codename — is that the thing he's declaring broken just needs updating **on his end**. This image is the persona's anchor artifact; the canonical Era I château poster should echo its spirit in WW2 Mode B form.
- **Second-layer irony (real):** per [`data.md`](./data.md), Jim's own LinkedIn is badly out of date — it lists ~2.5 years when his actual tenure is ~20. *Jim, of all people, needs to update.* Fair game for a future caption or poster beat.

## Era II / III appearances

Era I only — TBD if / when promoted.

## Open creative questions

- **Confirm the roast lands affectionately** — he's a real, senior colleague; tone stays good-natured.
- **Tagline lock** — paired **"THIS IS BROKEN!" / "…it works on the map."** vs. standalone *"It works on the map."* vs. imperative **"I'LL POINT. YOU ADVANCE."**
- **Subtitle wording** — confirm "GENERAL STAFF, REAR HQ" reads right.
- **Generate the canonical Era I poster** — `source.jpg` is on file; ready for a Mode B château-general `poster.png` whenever image-gen is available.
- **Factual anchors** (reporting line, prior background) — open in [`data.md`](./data.md); will refine flavor as they land.
