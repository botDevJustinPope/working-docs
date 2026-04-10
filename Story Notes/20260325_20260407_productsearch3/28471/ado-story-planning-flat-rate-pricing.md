# Flat Rate Pricing
This is a rough out line of what implementing the Flat Rate Pricing module into Veo Design Studio could look like:

---

## Pricing within our domain

---

## 1 — Implement Flat Rate Pricing
**Description**  
Work with Jim and Echelon to confirm what we need to do to flat rate bom lines within builds. Then with this information modify existing backend pricing code to match what is expected.

**Implementation Notes**
- Evaluate `vds_vs_selItemPrice` and confirm the data model `PriceDomainModel` contains the information we need; make changes to support the Flat Rate Pricing Model
  - There is a new `override_builder_flat_rate` flag that we may need to account for — confirm with Jim what this flag controls (does it allow the builder to override the flat rate and enter a manual price? Does it affect the floor guard in `PriceBuild.AdjustBomLinePricing`?)
  - Confirm if `price_type` alone (e.g. `"flat_rate"`) will be enough to drive flat rate pricing, or if `override_builder_flat_rate` needs to be surfaced in `PriceDomainModel` as a new property alongside the existing `IsAreaPrice` pattern
- If `PriceDomainModel` needs changes: add `IsFlatRatePrice` computed bool property and surface `override_builder_flat_rate` if needed
- Implement the Flat Rate Pricing branch within `PriceBomLine`:
  - The options loop in `PriceBomLine.Invoke` currently handles `"percent"`, `"unit"`, and `""` (field line) — add a `flat_rate` branch
  - Confirm with Jim: for flat rate option lines, is qty = 1 always (fixed total), or is it multiplied by qty from `_buildRepo.GetOptionQtyForItemAsync`?
  - Confirm: is `AdjustBomLinePriceResultBillQtyIfPriceTypeIsArea` (which sets `BillQty = 1` for area items) relevant for flat rate — i.e., does flat rate also require a BillQty adjustment on the non-options path?
- Confirm `PriceBuild` needs any changes — likely `PriceBuild` is unaffected since it orchestrates `PriceBomLine` but does not inspect price type directly, though `AdjustBomLinePricing` (floor guard: never let repriced bom go below original price level price) should be reviewed for flat rate compatibility

**Questions to Confirm with Jim / Echelon**
- What is the exact `price_type` string returned for flat rate? (`"flat_rate"`, `"flat"`, other?)
- Does flat rate apply to the bom line itself (non-options path), the options path, or both?
- What does `override_builder_flat_rate` control — is it a VDS concept or an Echelon concept?
- Should the price floor guard (`AdjustBomLinePricing` in `PriceBuild`) still apply to flat rate items?

**Rough Score**  
5

---

## Echelon APIs — Get Echelon to do the work

---

## 2 — Echelon Pricing Build/BOM — Sign Contract
**Description**  
Work and discuss a contract to establish with Echelon to be able to price BOM lines and/or whole builds.  
The intention is that VDS should not need to worry about or have to price these things on our side, and should just be displaying information from Echelon.  
Review how `PriceBomLine` and `PriceBuild` work and confirm with the Echelon team how the contract can be set up.

**Implementation Notes**
- Review `PriceBomLine.Invoke` and `PriceBuild.UpdateBuildPricingAsync` with the Echelon team to understand what context they need from VDS to price a bom line or build
  - Current inputs we send to `vds_vs_selItemPrice`: `SessionID`, `BuildID`, `EffectiveDate` (session create date), `CustomerID` (external org ID), `ItemType`, `ItemID`, `RealItemID`, `UomID`, `PatternID`, `SpecID`, `Application`, `Product`, `Area`, `SubArea` — Echelon will need to know which subset of these fields drive their pricing
  - For option lines: `RealItemID` is formatted as `"{OptionID}~{OptionValue}"` or the field option value — confirm if this composite key works for Echelon or if they need a different identifier
- Determine if Echelon will provide: (a) a per-bom-line pricing endpoint, (b) a price-whole-build endpoint, or both
- Confirm how the Echelon pricing response maps back to what VDS needs: `BuilderPrice`, `HomeownerPrice`, `PriceType`, `PricingLayer`, `RetailPercentage`, `RetailPercentageType`
- Confirm error response shape — VDS needs to be able to distinguish "pricing error" (item not found, etc.) from an HTTP/network failure

**Rough Score**  
3

---

## 3 — Implement Pricing From Echelon Endpoint
**Description**  
After completing the contract and Echelon providing endpoints, implement utilization of the endpoint(s) within VDS.  
Theoretically this would overhaul `PriceBomLine` and `PriceBuild` if not completely obsolete them.  
Considerations to make sure that the contract lines up with our session data.

**Implementation Notes**
- Add pricing method(s) to `IEchelonRepository` (interface already exists; currently used for builder image overrides in `GetBuildItemsForBomLine`)
  - e.g., `GetBomLinePriceAsync(PriceBomItemDTO priceParms, Guid securityToken)` returning `PriceDomainModel`
  - e.g., `GetBuildPriceAsync(...)` if a build-level endpoint is provided
- Create new use case `PriceBomLineViaEchelon` implementing `IPriceBomLine` — same interface as the existing class, so no consumers (`PriceBuild`, `GetBuildItemsForBomLine`) need to change, only the DI registration
- Create `PriceBuildViaEchelon` implementing `IPriceBuild` if Echelon provides a build-level endpoint
- Map Echelon response → `PriceDomainModel` so that all existing downstream logic (`AdjustBomLinePricing` floor guard, `AdjustBomLinePriceResultBillQtyIfPriceTypeIsArea`, `BuilderMarkupHBPricing` handling) continues to work without modification
- Mark `PriceBomLine` and `PriceBuild` as `[Obsolete]` once the Echelon path is stable in production — do not delete yet

**Rough Score**  
8

---

## 4 — Echelon Part Search — Sign Contract
**Description**  
Work and discuss a contract to establish with Echelon to search for selectable parts for BOM lines.  
This should fall in line with how `GetBuildItemsForBomLine` works and theoretically obsolete it if not heavily overhaul how it works.

**Implementation Notes**
- Review `GetBuildItemsForBomLine.GetBuildItems()` with the Echelon team — it currently handles several distinct bom line types with different data sources: field items, sink items, edge items, grout items, cabinet door hardware, cabinet drawer hardware, accent items, and standard items — confirm if Echelon can provide a unified endpoint or if it needs to be per-type
- Current inputs to the internal SP calls: `SessionID`, `BuildID`, `ItemID`, `ItemClass`, search criteria (text filter), selected item number, page index, page size — confirm what the Echelon parts search endpoint needs
- Consider pagination: internal calls are already paged — confirm if Echelon supports the same paging contract
- Builder image override feature (`ProcessBuilderOverrideImages`) already calls Echelon today — confirm how image data comes back from the parts search endpoint (embedded in results, or separate call?)
- Countertop selectable inventory (`ProcessSelectableInventory` / slab selection) is a separate flow that will need to be addressed — confirm if it stays as-is or if Echelon handles slab availability too

**Rough Score**  
3

---

## 5 — Echelon Part Search — Implement
**Description**  
After completing the contract and Echelon providing endpoints, implement utilization of the endpoint(s) within VDS.  
Theoretically this would overhaul `GetBuildItemsForBomLine` if not completely obsolete it.

**Implementation Notes**
- Add parts search method(s) to `IEchelonRepository`
- `_echelonRepository` is already injected into `GetBuildItemsForBomLine` (for image overrides today) — no constructor changes needed, only new method calls
- Route through Echelon parts search in `GetBuildItems()` — recommend feature-flagging initially so individual bom line types can be migrated one at a time without a big-bang cutover
- `PriceBomDetailLine()` calls `_priceBomLineUseCase.Invoke` — once Story 3 (Implement Pricing From Echelon Endpoint) is complete and the DI registration is swapped, this call automatically routes through Echelon with no further changes here
- Preserve `ProcessBuilderOverrideImages` behavior on the Echelon parts path (may be a no-op if Echelon returns images directly in the parts response)
- Preserve `ProcessSelectableInventory` (slab selection for countertops) on the Echelon parts path

**Rough Score**  
8
