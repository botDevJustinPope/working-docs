# Flat Rate Pricing — Implementation Plan
**Story:** 31790 | Sprint: 20260408–20260421 (ProductSearch4)  
**Author:** Justin Pope  
**Sources:** `ado-story-planning-flat-rate-pricing.md`, `echelon-pricing-integration-stories.md` (28471), meeting 2026-04-09

---

## Context Summary

Echelon is introducing a flat rate pricing module. The goal is to support this model within the VDS pricing pipeline without breaking existing behavior. The previous sprint (28471) produced a multi-phase plan and kicked off Story 1.A (alignment with Jim/Echelon). The April 9 meeting answered most of Story 1.A's open questions and surfaced new cabinet-specific concerns.

---

## Confirmed Answers from Story 1.A (April 9 Meeting — Full Transcript)

| Question | Answer |
|---|---|
| What is the `price_type` string for flat rate field line? | `"area"` — the field line returns `price_type = "area"` from Echelon. This IS the flat rate pricing mechanism. "area" and "flat rate" are the same concept. |
| What is the `price_type` for zeroed-out non-field lines? | `"flat_rate"` — Echelon's `vds_selPricesLandedDataForSessionCreation` (prices-landed SP) stamps non-bypass, non-field lines with `price_type = "flat_rate"` and `unit_price = 0`. This is NOT coming from `vds_vs_selItemPrice` (the repricing SP). |
| Does `vds_vs_selItemPrice` return "flat_rate"? | **No.** Cindy confirmed flat rate does not come back from `vds_vs_selItemPrice`. That SP only returns `"area"` (for the field line) during repricing. |
| What is the zeroing-out behavior? | `vds_vs_selItemPrice` (and chain) always returns the real price for every BOM line. The existing price extension logic already works: `price_type = "area"` → qty forced to 1 × price; all others → qty × price. **What's new:** when the field line comes back as `price_type = "area"`, VDS must zero out the `BuilderPrice` and `HomeownerPrice` of every other BOM line that has `bypass_flat_fee_exclusion = false`. Lines with `bypass_flat_fee_exclusion = true` are priced normally as above. This zeroing logic does not exist yet and must be added to VDS. |
| Zero out price or quantity? | **Zero out price, keep quantity.** Justin's decision — preserves quantities for potential reselection if price type changes later. |
| What does `bypass_flat_fee_exclusion` control? | A per-line flag from Echelon. If `true` on a non-field line: that line is priced normally (real price_type + real price) even when the field line is area-priced. If `false` (or absent): the line comes from prices-landed as `"flat_rate"` with price = $0. |
| Where does `bypass_flat_fee_exclusion` come from? | It is a column on the `vds_selPricesLandedDataForSessionCreation` SP result. VDS needs to surface it through: `PricesLandedSessionPriceLevelBomLine` → `PriceLevelBomDetailDomainModel` → `BaseBomLine` / `BomLineDomainModel`. It does NOT come from `vds_vs_selItemPrice`. |
| Does area pricing set qty = 1 for the field line? | **No — retain bill qty as-is.** `AdjustBomLinePriceResultBillQtyIfPriceTypeIsArea` in `PriceBomLine` currently forces `BillQty = 1` when `price_type = "area"`. This behavior is incorrect. The call must be commented out (not deleted) with an explanatory comment: we intentionally preserve the original BOM qty so that if the price type changes (e.g., from flat rate to standard), the quantities remain intact for accurate repricing. |
| Does flat rate / area apply to options path? | Echelon rolls options up into a unit price on the parent line. Cabinet options (soft close hinges, crown molding, etc.) are Wisenbaker-specific — Jim's builders don't use them. For Jim's use case, price lives directly on BOM lines. |
| Should the floor guard (`PriceBuild.AdjustBomLinePricing`) apply to flat rate? | **Not fully resolved** — the transcript cuts off at 20:22 mid-discussion. From sprint 28471 notes: "floor guard does not apply here" — but this was not re-confirmed in the April 9 meeting. |
| Does door hardware hit the BOM for flat rate? | Yes — door hardware is marked as bypass. It comes through prices-landed with its real price_type and real price, and is always repriced by `GetBomLinesToReprice` Scenario 10. |
| Does VDS see "ex leg" / "price null" BOM lines? | Still unknown — Jim to provide a staging example (see Open Items). |
| Quantities on credits? | Cindy was unsure. Jim thinks flat rate also turns credit qty to 1. Not fully resolved — may need Jenna/Adrian. |

---

## Open Items (Blockers / Pre-work)

1. ~~**Confirm `bypass_flat_fee_exclusion` column name:**~~ **RESOLVED** — column is `bypass_flat_fee_exclusion` (bit), already in the result set of `vs_selItemPrice` as of jenam/sjc 12/8/2025. No SQL changes needed.

2. **Jim Warnement ACTION:** Create a staging example of a cabinet BOM with a `price null` / `ignore price null ex leg` line item so VDS can confirm whether these lines are visible on our side when we fetch the BOM.

3. ~~**Floor guard decision:**~~ **RESOLVED** — `AdjustBomLinePricing` is unchanged. Jim confirmed a price change that trips the floor guard would arrive via a new price set, not affect the current session.

4. ~~**Credit quantity behavior:**~~ **RESOLVED — not applicable.** Credit lines are excluded from repricing by `GetBomLinesToReprice` Scenario 2 (`IsCredit || IsOverrideCredit`). `GetBomLineQuantityForExtendedPrices` uses `CreditQty` only when `HomeownerPrice < 0`, `IsCredit`, or `BillQty <= 0` — none of these conditions are part of flat rate pricing scenarios. No changes needed.

---

## How Flat Rate Pricing Currently Works in VDS

Understanding the existing flow is essential before making changes.

### Session Creation Path
1. `CreateSession` calls `IGetSessionPricesLandedData`, which calls `EchelonRepository.GetPricesLandedDataForSessionCreation`
2. That calls `vds_selPricesLandedDataForSessionCreation` on the Echelon database
3. The SP returns `PricesLandedSessionPriceLevelBomLine` records, each with a `price_type` column
4. **Echelon sets `price_type = "area"` on the field line** (the total flat rate price) and **`price_type = "flat_rate"` on all other BOM lines** (zeroed — `unit_price = 0, unit_price_retail = 0`)
5. `PriceLevelBomDetailDomainModel` maps `PriceType` directly from `pricesLandedBomLine.PriceType` (line 55 of `PriceLevelBomDetailDomainModel.cs`)
6. These prices are stored in the VDS database at session creation time — **the zeroing is done by Echelon's SP, not by VDS code**

### Repricing Path
When a user makes a selection, `PriceBuild.UpdateBuildPricingAsync` calls `BomDomainModel.GetBomLinesToReprice` and then `PriceBomLine.Invoke` for each line returned.

`GetBomLinesToReprice` currently has these relevant rules:
- **Scenario 4:** NEVER reprice `price_type = "manual"` lines — `flat_rate` is NOT manual, so flat_rate lines are not excluded by this rule
- **Scenario 5:** NEVER reprice cabinet lines unless they are hardware — this skips most flat_rate cabinet lines
- **Scenario 10:** ALWAYS reprice cabinet door hardware and drawer hardware — this is why door hardware gets a real price even though it started as `flat_rate`/zeroed at session creation

For cabinet door hardware: it starts as `price_type = "flat_rate"` with price = $0 from prices landed, then Scenario 10 forces a reprice via `vds_vs_selItemPrice`, which returns the actual hardware price. This is the correct behavior for the old model.

### The Problem
The old model: all BOM lines priced as returned from the SP. No zeroing.  
The new model: when the field line is `price_type = "area"` (flat rate build), VDS must zero out `BuilderPrice` and `HomeownerPrice` on every BOM line where `bypass_flat_fee_exclusion = false`. Preserve qty. Lines with `bypass_flat_fee_exclusion = true` continue to be priced normally.

`bypass_flat_fee_exclusion` comes back from the repricing SP (`vds_vs_selItemPrice` → `vs_selItemPrice` → `osp_selItemPrice`) per line. VDS currently does not read or use this column.

---

## Story 31790 — Flat Rate Pricing: Surface `bypass_flat_fee_exclusion` and Protect Zeroed Lines

### Description

Echelon's flat rate pricing model is driven by `price_type = "area"` on the field line.

Existing pricing behavior (already implemented):
- `price_type = "area"` → qty forced to 1 × price (field line)
- all other `price_type` values → qty × price

`vds_vs_selItemPrice` (and its chain) always returns the real price for every BOM line. That does not change.

**What's new:** when the field line comes back as `price_type = "area"`, VDS must zero out `BuilderPrice` and `HomeownerPrice` on all other BOM lines where `bypass_flat_fee_exclusion = false`. Lines with `bypass_flat_fee_exclusion = true` are priced normally. This zeroing logic does not exist in VDS yet.

`bypass_flat_fee_exclusion` (bit) is already returned by `vs_selItemPrice` → `vds_vs_selItemPrice` as of jenam/sjc 12/8/2025. VDS needs to read it and act on it.

The floor guard (`AdjustBomLinePricing`) and "ex leg" / options path questions are sub-tasks within this story — confirm and close each as part of implementation.

---

### Affected Files

| File | Change |
|---|---|
| `Databases/VeoSolutions/dbo/Tables/catalog_selections_area_details.sql` | Add `bypass_flat_fee_exclusion BIT NOT NULL DEFAULT (0)` column + extended property description |
| `Databases/VeoSolutions/dbo/Tables/z_catalog_selections_area_details.sql` | Add matching `bypass_flat_fee_exclusion BIT NOT NULL DEFAULT (0)` column — must stay in sync; triggers use `SELECT *` from `inserted`/`deleted` to populate this table |
| `Databases/VeoSolutions/dbo/Tables/catalog_selections_area_detail_options.sql` | Add `bypass_flat_fee_exclusion BIT NOT NULL DEFAULT (0)` column + extended property description |
| `Databases/VeoSolutions/dbo/Tables/z_catalog_selections_area_detail_options.sql` | Add matching `bypass_flat_fee_exclusion BIT NOT NULL DEFAULT (0)` column — must stay in sync; all three triggers use `SELECT *` from `inserted`/`deleted` |
| `Databases/VeoSolutions/dbo/Stored Procedures/vds_insBuildBomLine.sql` | Add `@bypass_flat_fee_exclusion BIT = 0` parameter; include in explicit INSERT column list |
| `Databases/VeoSolutions/dbo/Stored Procedures/vs_updCatalogSelectionAreaDetail.sql` | Add `@bypass_flat_fee_exclusion BIT = 0` parameter; include in both the UPDATE `SET` and INSERT column lists |
| `Databases/VeoSolutions/dbo/Stored Procedures/vds_selBuildBomLines.sql` | **No change needed** — uses `SELECT *`; new column flows through automatically |
| `Databases/VeoSolutions/dbo/Stored Procedures/vds_insBuildBomLineOption.sql` | Add `@bypass_flat_fee_exclusion BIT = 0` parameter; include in explicit INSERT column list |
| `Databases/VeoSolutions/dbo/Stored Procedures/vds_updCatalogSelectionAreaDetailOption.sql` | Add `@bypass_flat_fee_exclusion BIT = 0` parameter; include in UPDATE `SET` clause and both INSERT column list and VALUES (upsert pattern) |
| `Databases/VeoSolutions/dbo/Stored Procedures/vds_selBuildBomDetailOptions.sql` | **No change needed** — uses `SELECT *`; new column flows through automatically |
| `Databases/VeoSolutions/dbo/Stored Procedures/vds_vs_selItemPrice.sql` | **No change needed** — passthrough EXEC; `bypass_flat_fee_exclusion` already in result set from `vs_selItemPrice` |
| `Domain/Entities/PriceDomainModel.cs` | Add `BypassFlatFeeExclusion` bool property |
| `Dal/Repositories/PricingDomainRepository.cs` | **Conditionally** read `bypass_flat_fee_exclusion` from the result dict — check for key existence before reading (Echelon's SP chain may not include the column yet in all environments); default to `false` if absent |
| `Domain/Entities/BaseBomLine.cs` | Add `BypassFlatFeeExclusion` bool property; add `IsPriceTypeFlatRate` computed property; expand `GetExtendedBuilderPrice` to accept `BaseBomLine fieldBomLine = null` — return `0` if `fieldBomLine.IsPriceTypeArea && !BypassFlatFeeExclusion`; add the same check to `GetExtendedHomebuyerPrice` (already receives `fieldBomLine`) — return `0` before any other calculations if the flat rate zeroing condition is met |
| `Domain/Entities/BuildEntities/BuildDomainModel.cs` | `CalculateBuildCostTotal` calls `GetExtendedBuilderPrice()` with no args — update to pass `Bom.FieldBomLine` so the zeroing check has field line context |
| `Domain/Entities/BuildEntities/BomLineOptionDomainModel.cs` | Add `[Column("bypass_flat_fee_exclusion")] public bool BypassFlatFeeExclusion { get; set; }` property |
| `Domain/UseCases/Pricing/PriceBomLine.cs` | Comment out the `AdjustBomLinePriceResultBillQtyIfPriceTypeIsArea` call in `Invoke` — **do not delete the method**. Add a comment explaining that bill qty is preserved as-is. Set `bomLine.BypassFlatFeeExclusion = price.BypassFlatFeeExclusion` after successful price fetch (non-options path). Options path: pending confirmation from Cindy/Jim (see Open Question). **Refactoring note:** the `percent`/`unit`/field price type logic inside the options loop is a candidate to move to `BomLineOptionDomainModel` — consider as a follow-up refactor. |
| `Domain/UseCases/Pricing/PriceBuild.cs` | **No zeroing logic needed here** — zeroing is handled inside `GetExtendedBuilderPrice` / `GetExtendedHomebuyerPrice` at the calculation level. Floor guard (`AdjustBomLinePricing`) unchanged. |

---

### Acceptance Criteria

**Database Schema**
- [ ] `catalog_selections_area_details` — add `[bypass_flat_fee_exclusion] BIT NOT NULL CONSTRAINT [DF_catalog_selections_area_details_bypass_flat_fee_exclusion] DEFAULT (0)` with an extended property description
- [ ] `z_catalog_selections_area_details` — add matching `[bypass_flat_fee_exclusion] BIT NOT NULL CONSTRAINT [DF_z_catalog_selections_area_details_bypass_flat_fee_exclusion] DEFAULT (0)`. Must stay in sync — the INSERT/UPDATE/DELETE triggers use `SELECT *` from `inserted`/`deleted` to populate this table; a column mismatch will break them
- [ ] `catalog_selections_area_detail_options` — add `[bypass_flat_fee_exclusion] BIT NOT NULL CONSTRAINT [DF_catalog_selections_area_detail_options_bypass_flat_fee_exclusion] DEFAULT (0)` with an extended property description
- [ ] `z_catalog_selections_area_detail_options` — add matching `[bypass_flat_fee_exclusion] BIT NOT NULL CONSTRAINT [DF_z_catalog_selections_area_detail_options_bypass_flat_fee_exclusion] DEFAULT (0)`. Must stay in sync — same `SELECT *` trigger pattern applies
- [ ] `vds_insBuildBomLine` — add `@bypass_flat_fee_exclusion BIT = 0` parameter; add to INSERT column list and VALUES
- [ ] `vs_updCatalogSelectionAreaDetail` — add `@bypass_flat_fee_exclusion BIT = 0` parameter; add to UPDATE `SET` clause and both INSERT column list and VALUES (upsert pattern)
- [ ] `vds_selBuildBomLines` — no change; uses `SELECT *` so new column flows through automatically
- [ ] `vds_insBuildBomLineOption` — add `@bypass_flat_fee_exclusion BIT = 0` parameter; add to INSERT column list and VALUES
- [ ] `vds_updCatalogSelectionAreaDetailOption` — add `@bypass_flat_fee_exclusion BIT = 0` parameter; add to UPDATE `SET` clause and both INSERT column list and VALUES (upsert pattern)
- [ ] `vds_selBuildBomDetailOptions` — no change; uses `SELECT *` so new column flows through automatically

**SP Chain (for reference — no SQL changes needed)**
```
osp_selItemPrice (Veo DB)
  └─ esp_selItemPrice (Veo DB) — bypass_flat_fee_exclusion OUTPUT added jenam/sjc 12/8/2025
       └─ vs_selItemPrice (Veo DB) — SELECTs bypass_flat_fee_exclusion in result set
            └─ synonym Veo_vs_selItemPrice (VeoSolutions DB)
                 └─ vds_vs_selItemPrice (VeoSolutions DB) — passthrough EXEC, column flows through
                      └─ PricingDomainRepository.GetBomItemPriceAsync
```

**Repricing Pipeline — surface the flag**
- [ ] `PriceDomainModel` has a new `BypassFlatFeeExclusion` bool property
- [ ] `PricingDomainRepository.GetBomItemPriceAsync` **conditionally** reads `bypass_flat_fee_exclusion` from the result dict inside the `item_price != null` block. Because Echelon's side of the SP chain (`osp_selItemPrice` → `esp_selItemPrice`) may not yet include the column in all environments, use a key-existence check (e.g., `priceResult.ContainsKey("bypass_flat_fee_exclusion") && priceResult["bypass_flat_fee_exclusion"] != null`) before reading. If the key is absent or null, default `BypassFlatFeeExclusion = false` on the `PriceDomainModel`. This allows VDS to deploy ahead of Echelon's SP changes without breaking the repricing pipeline.
- [ ] `BaseBomLine` has `BypassFlatFeeExclusion` bool property and `IsPriceTypeFlatRate` computed property (consistent with existing `IsPriceTypeArea`, `IsPriceTypeManual`)
- [ ] `PriceBomLine.Invoke` sets `bomLine.BypassFlatFeeExclusion = price.BypassFlatFeeExclusion` after a successful price fetch (non-options path)
- [ ] Comment out the `AdjustBomLinePriceResultBillQtyIfPriceTypeIsArea` call in `PriceBomLine.Invoke` — **do not delete the method**. Add a code comment: we preserve the original BOM qty so that if the field line's `price_type` changes (e.g., flat rate to standard pricing), quantities remain intact for accurate repricing without requiring a full BOM refresh

**Zeroing Logic (new — in `BaseBomLine`)**

The zeroing is baked into the price calculation methods so it applies consistently everywhere prices are computed — including `GetBuildItemsForBomLine` (item browsing) and `PriceBuild` (full build reprice). `GetBuildItemsForBomLine` already flows through `BuildDomainModel.CalculateBomLineHomebuyerPrice` → `GetExtendedHomebuyerPrice(Bom.FieldBomLine, ...)` so no changes are needed there.

- [ ] `BaseBomLine.GetExtendedBuilderPrice` — update signature to `GetExtendedBuilderPrice(BaseBomLine fieldBomLine = null)`. At the top of the method, return `0m` if `fieldBomLine?.IsPriceTypeArea == true && !IsField && !BypassFlatFeeExclusion`. The `!IsField` guard is critical — the field line IS the flat rate total and must never be zeroed. Qty is preserved.
- [ ] `BaseBomLine.GetExtendedHomebuyerPrice` — already receives `BaseBomLine fieldBomLine`. At the top of the method (before the credit check), return `0m` if `fieldBomLine?.IsPriceTypeArea == true && !IsField && !BypassFlatFeeExclusion`. Same `!IsField` guard applies. Qty is preserved.
- [ ] `BuildDomainModel.CalculateBuildCostTotal` — update `GetExtendedBuilderPrice()` call to pass `Bom.FieldBomLine` so the zeroing check has field line context
- [ ] BOM lines where `BypassFlatFeeExclusion = true` return their real repriced values unchanged

**Floor Guard (`PriceBuild.AdjustBomLinePricing`) — No Change**
- `AdjustBomLinePricing` is unchanged. Jim confirmed: a price change large enough to trip the floor guard would come in as a new price set and would not affect the existing session. The guard applies as-is to all repriced lines.

**"Ex Leg" / Price Null Lines — Out of Scope for Story 31790**
- These lines are not accounted for in this story. If "ex leg" / price null lines surface as a problem during implementation or testing, they will be handled in a follow-up story.
- Jim to provide a staging BOM example when available (Open Item 2) — for future reference only.

**Options Path — Open Question for Cindy & Jim**

The options path in `PriceBomLine.Invoke` (lines 82–170) prices each `BomLineOption` individually via `GetBomItemPriceAsync`, then sums them into `bomLine.BuilderPrice` / `bomLine.HomeownerPrice`. There is no fallback to a direct BOM line price fetch.

In a flat rate scenario Echelon rolls option pricing up to the parent BOM line — individual option prices may come back zeroed. This means `costTotal` and `priceTotal` could sum to `$0` even though the line has a real price.

**Proposed logic (pending confirmation from Cindy and Jim):**
1. Price out options as normal
2. Sum into `BuilderPrice` / `HomeownerPrice` as normal
3. If both sum to `$0`, fall through to the non-options path to fetch the price directly against the BOM line itself

**Open question to ask Cindy and Jim:**
- In a flat rate build, does an options BOM line's price come back entirely on the parent line (rolled up), with all individual option prices zeroed?
- If so, is step 3 the correct fallback — or does Echelon have a different mechanism for pricing options lines under flat rate?
- Does `bypass_flat_fee_exclusion` play a role on option lines?

Until confirmed, no code changes are made to the options path. This question must be resolved before considering this story complete.

**General**
- [ ] Build passes, no regressions
- [ ] All decisions (floor guard, ex leg, options) documented in code comments or ADO story notes

---

## Unit Testing

All affected domain files have existing test files in `BuildOnTechnologies.VDS.Legacy.Domain.Tests`. The DAL (`PricingDomainRepository`) has no unit test file — it is tested through integration tests.

### `BaseBomLineTests.cs`
**Existing coverage:** `IsPriceTypeManual` and `IsPriceTypeArea` each have 5 tests (true, false, mixed case, null, empty string) — follow this exact pattern for `IsPriceTypeFlatRate`.

**New tests to add:**
- `BaseBomLine_IsPriceTypeFlatRate_returnsTrue_whenPriceTypeIsFlatRate`
- `BaseBomLine_IsPriceTypeFlatRate_returnsFalse_whenPriceTypeIsNotFlatRate`
- `BaseBomLine_IsPriceTypeFlatRate_returnsTrue_whenPriceTypeIsFlatRateWithMixedCase`
- `BaseBomLine_IsPriceTypeFlatRate_returnsFalse_whenPriceTypeIsNull`
- `BaseBomLine_IsPriceTypeFlatRate_returnsFalse_whenPriceTypeIsEmptyString`
- `BaseBomLine_GetExtendedBuilderPrice_returnsZero_whenFieldLineIsAreaPricedAndBypassIsFalse`
- `BaseBomLine_GetExtendedBuilderPrice_returnsRealPrice_whenFieldLineIsAreaPricedAndBypassIsTrue`
- `BaseBomLine_GetExtendedBuilderPrice_returnsRealPrice_whenFieldLineIsNotAreaPriced`
- `BaseBomLine_GetExtendedBuilderPrice_preservesQty_whenPriceIsZeroedByFlatRate`
- `BaseBomLine_GetExtendedBuilderPrice_returnsRealPrice_whenLineIsFieldLine` — confirms field line is never zeroed even when it is the area-priced line
- `BaseBomLine_GetExtendedHomebuyerPrice_returnsZero_whenFieldLineIsAreaPricedAndBypassIsFalse`
- `BaseBomLine_GetExtendedHomebuyerPrice_returnsRealPrice_whenFieldLineIsAreaPricedAndBypassIsTrue`
- `BaseBomLine_GetExtendedHomebuyerPrice_returnsRealPrice_whenFieldLineIsNotAreaPriced`
- `BaseBomLine_GetExtendedHomebuyerPrice_preservesQty_whenPriceIsZeroedByFlatRate`
- `BaseBomLine_GetExtendedHomebuyerPrice_returnsRealPrice_whenLineIsFieldLine` — confirms field line is never zeroed

### `BomLineOptionDomainModelTests.cs`
**Existing coverage:** `IsField` only (5 tests — true, false, mixed case, null, empty string).

`BypassFlatFeeExclusion` is a plain data property with no computed logic — no behavioral tests are required. However, if any computed behavior is added to `BomLineOptionDomainModel` as part of the options path resolution (pending Cindy/Jim answer), tests should be added at that time following the `IsField` naming pattern.

### `BuildDomainModelTests.cs`
**Existing coverage:** `HasPattern`, `HasBom`, `CalculateBuildSelectionTotal` (credits, staggered, area price type, modifications).

**⚠️ Existing test to review:** `BuildDomainModel_CalculateBuildSelectionTotal_BomLinesWithAreaPriceTypeSetBillQtyToOneForCalculation` — this test has one area-priced line with `billQty = 5` and expects total `$200` (qty forced to 1). After our changes, this line IS the field line in context, so `!IsField` prevents zeroing and qty-to-1 logic in `GetBomLineQuantityForExtendedPrices` still applies. Verify this test still passes; update description if needed.

**New tests to add:**
- `BuildDomainModel_CalculateBuildCostTotal_ZerosCostOnNonBypassLines_WhenFieldLineIsAreaPriced`
- `BuildDomainModel_CalculateBuildCostTotal_PreservesCostOnBypassLines_WhenFieldLineIsAreaPriced`
- `BuildDomainModel_CalculateBuildCostTotal_DoesNotZeroFieldLine_WhenFieldLineIsAreaPriced`

### `PriceBomLineTests.cs`
**Existing coverage:** focused on accent tile rounding. No tests currently exist for the area price qty adjustment or for `BypassFlatFeeExclusion` mapping.

**New tests to add:**
- `PriceBomLine_DoesNotAdjustBillQty_WhenPriceTypeIsArea` — verify `BillQty` is unchanged after repricing an area-priced line (confirms `AdjustBomLinePriceResultBillQtyIfPriceTypeIsArea` is commented out)
- `PriceBomLine_SetsBypassFlatFeeExclusion_WhenPriceResultHasBypassTrue`
- `PriceBomLine_SetsBypassFlatFeeExclusion_WhenPriceResultHasBypassFalse`

### `PriceBuildTests.cs`
**Existing coverage:** floor guard tests (`AdjustBomLinePricing` — prices adjusted when below original, allowed below when credit area), build status tests. No new flat rate zeroing tests needed here — zeroing is now tested at the `BaseBomLine` level.

The broader Phase 2 (replace `PriceBomLine` / `PriceBuild` with Echelon endpoint versions) and Phase 3 (replace `GetBuildItemsForBomLine` with Echelon parts search) plans from sprint 28471 (`echelon-pricing-integration-stories.md`) remain valid and unchanged. The work in this sprint is strictly Phase 1 — supporting flat rate within the existing internal pricing pipeline. Phase 2/3 cannot begin until Echelon pricing and parts endpoints are deployed.
