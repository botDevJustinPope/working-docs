# VDS — VEO® Design Studio

**Internal handle:** VDS
**Product name:** VEO® Design Studio
**Persona file:** [`persona.md`](./persona.md) — in-universe write-up as a unit under Atlas.
**Commanding persona:** [`EricHickey_Atlas`](../../../Personas/EricHickey_Atlas/) — Director of Software Development, BuildOn Technologies (Senior Leadership Team).
**Last updated:** 2026-05-14 (revised — 4-person headcount confirmed by user)

---

## What this team owns

VDS owns **VEO® Design Studio** — the customer-facing software that helps homebuyers select options and finishes for their new home. Per the public product page: it "expedites homebuyer decisions by enabling exploration of different products, designs, and finishes while providing real-time pricing." It is used at the design center *during* a homebuyer appointment as well as by design-center staff and sales counselors preparing for those appointments.

Key user-facing capabilities (per buildontechnologies.com/products):

- On-the-spot pricing for design choices.
- Product and finish exploration tools (real-time option availability, selection visualization).
- Budget visualization.
- Pre-appointment design preparation for the homebuyer.

Per Eric Hickey's LinkedIn (Senior Technical Lead — VEO Design Studio, Oct 2019 – Feb 2020): the team led the conversion of the application from .NET Framework to .NET Core, established Entity Framework with repository/specification patterns, and built a provider model abstracting the visualization vendor so new vendors plug in with minimal work.

## Where it sits in the company

- **Surface:** customer-facing (homebuyers, designers, sales counselors).
- **Upstream / downstream systems:** drives pricing + selection data that flows into the homebuilder's broader order pipeline. Specific integration points with Echelon ERP / other internal systems TBD — not directly stated on the public site.
- **Public on the corporate site?** Yes — top-billed product alongside Echelon ERP at [buildontechnologies.com/products](https://www.buildontechnologies.com/products/).

## Team composition

- **Commander:** [`EricHickey_Atlas`](../../../Personas/EricHickey_Atlas/) — Director of Software Development. Eric leads both the VDS team and the Indago team; VDS is one of the two units under his company.
- **Team members (4, including Eric's command):**

  | Real name | Codename / persona folder | Role on the team |
  |---|---|---|
  | Rob Hobbs | [`RobHobbs_Tactician`](../../../Personas/RobHobbs_Tactician/) | Product Owner |
  | Walter Martinez | [`WalterMartinez_Hawkeye`](../../../Personas/WalterMartinez_Hawkeye/) | QA |
  | Daniel Arwe | [`DanielArwe_Ironforge`](../../../Personas/DanielArwe_Ironforge/) | Software Developer |
  | Justin Pope | [`JustinPope_Overseer`](../../../Personas/JustinPope_Overseer/) | Software Developer |

  All four have existing persona folders. Per user account 2026-05-14.
- **Headcount:** **4 people**, per user account 2026-05-14. Sub-squad scale — informs the "Pathfinder Detachment" unit designation in `persona.md`.
- **Structure:** single team. Interim Scrum Master is Eric himself (per his LinkedIn).

## Tech stack

- **Backend:** .NET Core (post-2019 migration from .NET Framework), C#. Entity Framework Core with repository and specification patterns.
- **Frontend:** TBD — not specified in the LinkedIn export or the public product page.
- **Vendor integration:** provider-model abstraction over the visualization vendor (per Eric's LinkedIn — supports plugging in new vendors with minimal work).
- **Note:** the stack listing here is partial. A direct look at the VDS repository would tighten this section the same way the Indago README did for `Teams/Indago/data.md`.

## History

- **2016:** VEO® Design Studio launched (per BuildOn corporate history / [About Us](https://www.buildontechnologies.com/about-us/)).
- **Oct 2019 – Feb 2020:** Eric Hickey served as Senior Technical Lead on VDS. Led the .NET Framework → .NET Core conversion, EF + repository/specification pattern adoption, and the visualization-vendor provider model.
- **Feb 2020 – present:** Eric continues to lead VDS as Director of Software Development across both VDS and Indago.

Pre-2016 context: VEO® Design Studio sits within a longer BuildOn lineage that started as **OBIS Software (2000)**, became **ePlan Partners (2007)**, and was rebranded to **BuildOn Technologies (2020)**. The "VEO" product family includes earlier siblings — VEO® Options Estimator (2010), VEO® Scheduler and Concierge (2011), Mobile IQA (2013) — before VDS launched in 2016. VDS represents the *front-of-house, homebuyer-facing* evolution of that lineage.

## Notable Operations (PBI posters) anchored on this team

*TBD — needs user input.* Which of the ~44 Operation posters in `WarRooms/PBI Posters/` were anchored on the VDS team specifically (vs. Indago vs. cross-team)?

## Source notes

- *BuildOn corporate site `buildontechnologies.com/products` and `/about-us/`:* fetched 2026-05-13. Source for the customer-facing capability list, the 2016 launch date, and the public-product positioning.
- *Eric Hickey's LinkedIn PDF (`../../../Personas/EricHickey_Atlas/Profile.pdf`):* read 2026-05-13. Source for the Senior-Technical-Lead-era technical accomplishments (.NET Core conversion, EF + repository/specification patterns, provider-model vendor abstraction).
- *User account, 2026-05-14:* user confirmed VDS and Indago are two distinct teams both reporting to Eric, and that **VDS is one of BuildOn's flagship products**. User stated VDS is **4 people** and named the full roster: Rob Hobbs (PO), Walter Martinez (QA), Daniel Arwe (SWE), Justin Pope (SWE). User redirected the `persona.md` framing from a service/liaison unit to a tip-of-the-spear elite detachment, and accepted the Pathfinder Detachment designation + motto.
- *Inferred:* Eric's *continuing* leadership of VDS post-2020 is inferred from his Director title spanning "two key development teams" plus the LinkedIn Summary; not a separately-attested fact.
- *Not verified:* frontend stack, current headcount, integration map with Echelon ERP.

## Open questions

- Frontend stack on VDS today — is it the same Aurelia + TypeScript that Indago uses, or a different choice?
- VDS ↔ Echelon ERP integration — what data flows between them, if any?
- VDS repository path — does it exist locally under `c:/github/botdevjustinpope/buildontechnologies/` similar to Indago? Inspecting it would tighten this file the way the Indago README tightened that team's `data.md`.
- Roster will be vetted by the user with the team members themselves before persona.md / persona_future.md details (roles within the detachment, codename rationales) are locked.
