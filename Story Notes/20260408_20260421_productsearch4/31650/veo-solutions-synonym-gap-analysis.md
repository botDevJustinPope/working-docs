# VeoSolutions Synonym Gap Analysis — WBS vs VEO

**Database:** `VeoSolutions_DEV`
**Analysis Date:** 2026-04-09

---

## Summary

| | Count |
|---|---|
| Total `wbs_` synonyms | 19 |
| Total `veo_` synonyms | 75 |
| `wbs_` synonyms **with** a matching `veo_` synonym | 18 |
| `wbs_` synonyms **without** a matching `veo_` synonym | **1** |

---

## ❌ WBS Synonyms Missing a VEO Counterpart (1)

| WBS Synonym | WBS Target Table | Expected VEO Synonym | Status |
|-------------|-----------------|----------------------|--------|
| `wbs_prices_landed` | `[WBS_Staging].[dbo].[prices_landed]` | `veo_prices_landed` | **MISSING** |

> **Note:** No synonym pointing to a `prices_landed` table exists anywhere in `VeoSolutions_DEV` for the VEO/Veo_DEV database. The WBS staging database has a `prices_landed` table but there is no VEO equivalent synonym defined.

---

## ✅ WBS Synonyms With a Matching VEO Counterpart (18)

| WBS Synonym | WBS Target | VEO Synonym | VEO Target |
|-------------|-----------|-------------|------------|
| `wbs_applications` | `[WBS_Staging].[dbo].[applications]` | `Veo_applications` | `[Veo_DEV].[dbo].[applications]` |
| `wbs_areas` | `[WBS_Staging].[dbo].[areas]` | `Veo_areas` | `[Veo_DEV].[dbo].[areas]` |
| `wbs_areas_sub_areas` | `[WBS_Staging].[dbo].[areas_sub_areas]` | `Veo_areas_sub_areas` | `[Veo_DEV].[dbo].[areas_sub_areas]` |
| `wbs_builder_styles` | `[WBS_Staging].[dbo].[builder_styles]` | `Veo_builder_styles` | `[Veo_DEV].[dbo].[builder_styles]` |
| `wbs_customers` | `[WBS_Staging].[dbo].[customers]` | `Veo_customers` | `[Veo_DEV].[dbo].[customers]` |
| `wbs_plan_builds` | `[WBS_Staging].[dbo].[plan_builds]` | `Veo_plan_builds` | `[Veo_DEV].[dbo].[plan_builds]` |
| `wbs_plan_material` | `[WBS_Staging].[dbo].[plan_material]` | `Veo_plan_material` | `[Veo_DEV].[dbo].[plan_material]` |
| `wbs_plan_mstr` | `[WBS_Staging].[dbo].[plan_mstr]` | `Veo_plan_mstr` | `[Veo_DEV].[dbo].[plan_mstr]` |
| `wbs_pricesets` | `[WBS_Staging].[dbo].[pricesets]` | `Veo_pricesets` | `[Veo_DEV].[dbo].[pricesets]` |
| `wbs_products` | `[WBS_Staging].[dbo].[products]` | `Veo_products` | `[Veo_DEV].[dbo].[products]` |
| `wbs_room_groups` | `[WBS_Staging].[dbo].[room_groups]` | `veo_room_groups` | `[Veo_DEV].[dbo].[room_groups]` |
| `wbs_spec_areas_items` | `[WBS_Staging].[dbo].[spec_areas_items]` | `veo_spec_areas_items` | `[Veo_DEV].[dbo].[spec_areas_items]` |
| `wbs_spec_communities` | `[WBS_Staging].[dbo].[spec_communities]` | `Veo_spec_communities` | `[Veo_DEV].[dbo].[spec_communities]` |
| `wbs_spec_items` | `[WBS_Staging].[dbo].[spec_items]` | `veo_spec_items` | `[Veo_DEV].[dbo].[spec_items]` |
| `wbs_spec_mstr` | `[WBS_Staging].[dbo].[spec_mstr]` | `veo_spec_mstr` | `[Veo_DEV].[dbo].[spec_mstr]` |
| `wbs_spec_series` | `[WBS_Staging].[dbo].[spec_series]` | `veo_spec_series` | `[Veo_DEV].[dbo].[spec_series]` |
| `wbs_styles_groups_detail` | `[WBS_Staging].[dbo].[styles_groups_detail]` | `Veo_styles_groups_detail` | `[Veo_DEV].[dbo].[styles_groups_detail]` |
| `wbs_sub_areas` | `[WBS_Staging].[dbo].[sub_areas]` | `Veo_sub_areas` | `[Veo_DEV].[dbo].[sub_areas]` |

---

## Query Used

```sql
SELECT
    wbs.name                  AS wbs_synonym,
    wbs.base_object_name      AS wbs_target,
    veo.name                  AS veo_synonym,
    veo.base_object_name      AS veo_target
FROM sys.synonyms wbs
LEFT JOIN sys.synonyms veo
    ON LOWER(SUBSTRING(veo.name, 5, LEN(veo.name)))
     = LOWER(SUBSTRING(wbs.name, 5, LEN(wbs.name)))
    AND veo.name LIKE 'veo[_]%'
WHERE wbs.name LIKE 'wbs[_]%'
ORDER BY wbs.name
```

*Match logic: strips the 4-character prefix (`wbs_` / `veo_`) from each synonym name and compares case-insensitively.*
