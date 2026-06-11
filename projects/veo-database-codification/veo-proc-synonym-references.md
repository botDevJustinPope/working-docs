# VEO Synonym References — VeoSolutions Stored Procedures

> **Companion to:** `veo-database-codification-design-options.md`
> **Generated:** 2026-06-11 from the VDS `master` worktree
> **Method:** parsed `Databases/VeoSolutions/dbo/Synonyms/*.sql` for synonyms targeting `[$(VEO)].[dbo].*`, then case-insensitive word-boundary matched each synonym name in `Databases/VeoSolutions/dbo/Stored Procedures/*.sql`. No proc references `$(VEO)` directly — all access goes through synonyms.

**Totals:** 75 VEO-targeting synonyms · 117 procs referencing at least one · 16 synonyms unreferenced by any proc (may be used by views/functions/triggers — not scanned).

## Synonym usage summary

| Synonym | VEO target table | Procs referencing |
|---|---|---|
| `Veo_accent_sqft_conversions` | `[$(VEO)].[dbo].[accent_sqft_conversions]` | 1 |
| `Veo_application_products` | `[$(VEO)].[dbo].[application_products]` | 1 |
| `Veo_applications` | `[$(VEO)].[dbo].[applications]` | 30 |
| `Veo_areas` | `[$(VEO)].[dbo].[areas]` | 20 |
| `Veo_areas_sub_areas` | `[$(VEO)].[dbo].[areas_sub_areas]` | 0 |
| `Veo_builder_styles` | `[$(VEO)].[dbo].[builder_styles]` | 9 |
| `Veo_cabinet_colors` | `[$(VEO)].[dbo].[cabinet_colors]` | 3 |
| `Veo_cabinet_door_panels` | `[$(VEO)].[dbo].[cabinet_door_panels]` | 2 |
| `Veo_cabinet_door_styles` | `[$(VEO)].[dbo].[cabinet_door_styles]` | 2 |
| `Veo_cabinet_species` | `[$(VEO)].[dbo].[cabinet_species]` | 2 |
| `Veo_colors_attributes` | `[$(VEO)].[dbo].[colors_attributes]` | 1 |
| `Veo_colors_customer_overrides` | `[$(VEO)].[dbo].[colors_customer_overrides]` | 13 |
| `Veo_customers` | `[$(VEO)].[dbo].[customers]` | 9 |
| `Veo_customers_items_applications` | `[$(VEO)].[dbo].[customers_items_applications]` | 0 |
| `Veo_customers_items_products` | `[$(VEO)].[dbo].[customers_items_products]` | 0 |
| `Veo_customers_plans` | `[$(VEO)].[dbo].[customers_plans]` | 1 |
| `Veo_ef_selStyleColorNameWithAttributes` | `[$(VEO)].[dbo].[ef_selStyleColorNameWithAttributes]` | 0 |
| `Veo_esp_selColor` | `[$(VEO)].[dbo].[esp_selColor]` | 0 |
| `Veo_esp_selColorsFromAttributes` | `[$(VEO)].[dbo].[esp_selColorsFromAttributes]` | 0 |
| `Veo_esp_selItemPrice` | `[$(VEO)].[dbo].[esp_selItemPrice]` | 1 |
| `Veo_labor_codes` | `[$(VEO)].[dbo].[labor_codes]` | 8 |
| `Veo_of_getProductFromItemNumber` | `[$(VEO)].[dbo].[of_getProductFromItemNumber]` | 1 |
| `Veo_of_selCustomerItemProductName` | `[$(VEO)].[dbo].[of_selCustomerItemProductName]` | 1 |
| `Veo_of_selPartName` | `[$(VEO)].[dbo].[of_selPartName]` | 1 |
| `Veo_of_selProductName` | `[$(VEO)].[dbo].[of_selProductName]` | 1 |
| `Veo_photo_attributes` | `[$(VEO)].[dbo].[photo_attributes]` | 2 |
| `Veo_photo_attributes_values` | `[$(VEO)].[dbo].[photo_attributes_values]` | 11 |
| `Veo_photos` | `[$(VEO)].[dbo].[photos]` | 9 |
| `Veo_plan_areas` | `[$(VEO)].[dbo].[plan_areas]` | 2 |
| `Veo_plan_builds` | `[$(VEO)].[dbo].[plan_builds]` | 18 |
| `Veo_plan_items` | `[$(VEO)].[dbo].[plan_items]` | 7 |
| `Veo_plan_items_alias` | `[$(VEO)].[dbo].[plan_items_alias]` | 0 |
| `Veo_plan_items_sort` | `[$(VEO)].[dbo].[plan_items_sort]` | 1 |
| `Veo_plan_material` | `[$(VEO)].[dbo].[plan_material]` | 1 |
| `Veo_plan_mstr` | `[$(VEO)].[dbo].[plan_mstr]` | 18 |
| `Veo_pricesets` | `[$(VEO)].[dbo].[pricesets]` | 2 |
| `Veo_product_patterns` | `[$(VEO)].[dbo].[product_patterns]` | 17 |
| `Veo_product_patterns_areas` | `[$(VEO)].[dbo].[product_patterns_areas]` | 7 |
| `Veo_product_patterns_customers` | `[$(VEO)].[dbo].[product_patterns_customers]` | 5 |
| `Veo_product_patterns_labor` | `[$(VEO)].[dbo].[product_patterns_labor]` | 2 |
| `Veo_product_patterns_material` | `[$(VEO)].[dbo].[product_patterns_material]` | 6 |
| `Veo_products` | `[$(VEO)].[dbo].[products]` | 32 |
| `Veo_products_attributes` | `[$(VEO)].[dbo].[products_attributes]` | 1 |
| `Veo_products_attributes_values` | `[$(VEO)].[dbo].[products_attributes_values]` | 1 |
| `Veo_products_options` | `[$(VEO)].[dbo].[products_options]` | 1 |
| `Veo_spec_communities` | `[$(VEO)].[dbo].[spec_communities]` | 3 |
| `Veo_spec_plans` | `[$(VEO)].[dbo].[spec_plans]` | 0 |
| `Veo_stocking_codes` | `[$(VEO)].[dbo].[stocking_codes]` | 15 |
| `Veo_styles` | `[$(VEO)].[dbo].[styles]` | 21 |
| `Veo_styles_attributes` | `[$(VEO)].[dbo].[styles_attributes]` | 5 |
| `Veo_styles_groups` | `[$(VEO)].[dbo].[styles_groups]` | 15 |
| `Veo_styles_groups_detail` | `[$(VEO)].[dbo].[styles_groups_detail]` | 7 |
| `Veo_styles_related_items` | `[$(VEO)].[dbo].[styles_related_items]` | 1 |
| `Veo_sub_areas` | `[$(VEO)].[dbo].[sub_areas]` | 11 |
| `Veo_vs_searchPart` | `[$(VEO)].[dbo].[vs_searchPart]` | 0 |
| `Veo_vs_selItemPrice` | `[$(VEO)].[dbo].[vs_selItemPrice]` | 2 |
| `Veo_vsp_selSpecColorsFromAttributes` | `[$(VEO)].[dbo].[vsp_selSpecColorsFromAttributes]` | 0 |
| `veo_colors` | `[$(VEO)].[dbo].[colors]` | 40 |
| `veo_communities` | `[$(VEO)].[dbo].[communities]` | 6 |
| `veo_getUomQty` | `[$(VEO)].[dbo].[of_getUomQty]` | 2 |
| `veo_prices_default_labor` | `[$(VEO)].[dbo].[prices_default_labor]` | 0 |
| `veo_prices_extended_labor` | `[$(VEO)].[dbo].[prices_extended_labor]` | 0 |
| `veo_prices_global_labor` | `[$(VEO)].[dbo].[prices_global_labor]` | 0 |
| `veo_prices_public_labor` | `[$(VEO)].[dbo].[prices_public_labor]` | 0 |
| `veo_prices_published` | `[$(VEO)].[dbo].[prices_published]` | 1 |
| `veo_prices_published_groups_detail` | `[$(VEO)].[dbo].[prices_published_groups_detail]` | 1 |
| `veo_products_options_materials` | `[$(VEO)].[dbo].[products_options_materials]` | 1 |
| `veo_products_options_values` | `[$(VEO)].[dbo].[products_options_values]` | 0 |
| `veo_regions` | `[$(VEO)].[dbo].[regions]` | 0 |
| `veo_room_groups` | `[$(VEO)].[dbo].[room_groups]` | 4 |
| `veo_spec_areas_items` | `[$(VEO)].[dbo].[spec_areas_items]` | 9 |
| `veo_spec_items` | `[$(VEO)].[dbo].[spec_items]` | 14 |
| `veo_spec_mstr` | `[$(VEO)].[dbo].[spec_mstr]` | 16 |
| `veo_spec_series` | `[$(VEO)].[dbo].[spec_series]` | 3 |
| `veo_uomMultiplier` | `[$(VEO)].[dbo].[of_uomMultiplier]` | 1 |

## Procedure → synonym cross-reference

| # | Stored procedure | VEO synonyms referenced |
|---|---|---|
| 1 | `dev_importVEOImage` | `Veo_photos` |
| 2 | `osp_selPublishedSessionUnitPriceDefaultLabor` | `Veo_pricesets`, `veo_getUomQty` |
| 3 | `osp_selPublishedSessionUnitPriceGlobalLabor` | `veo_getUomQty` |
| 4 | `osp_selPublishedSessionUnitPricePublicMaterial` | `veo_colors`, `veo_uomMultiplier` |
| 5 | `vds_getAllApplications` | `Veo_applications` |
| 6 | `vds_getAllProducts` | `Veo_products` |
| 7 | `vds_getApplicationsByIconId` | `Veo_applications` |
| 8 | `vds_getDesignSessionWizardAccentPrompts` | `Veo_accent_sqft_conversions` |
| 9 | `vds_getOptionPricingSessionSelections` | `Veo_applications`, `Veo_areas`, `Veo_builder_styles`, `Veo_products`, `veo_room_groups` |
| 10 | `vds_getPartAttributes` | `Veo_colors_attributes`, `Veo_products_attributes`, `Veo_products_attributes_values`, `Veo_styles_attributes`, `veo_colors` |
| 11 | `vds_getSlabReportDetails` | `veo_colors` |
| 12 | `vds_getSpecAreaItemsBySessionBuild` | `veo_spec_areas_items` |
| 13 | `vds_insCatalogSelectionGroupDetails` | `Veo_styles_groups`, `Veo_styles_groups_detail`, `veo_spec_items` |
| 14 | `vds_optionPricingSessionMaxMinBuilds` | `Veo_plan_builds`, `Veo_plan_material` |
| 15 | `vds_overridePatternCharge` | `Veo_labor_codes` |
| 16 | `vds_selAccountOrganizationCommunity` | `Veo_customers`, `veo_communities` |
| 17 | `vds_selAccountOrganizationCommunityByName` | `Veo_customers`, `veo_communities` |
| 18 | `vds_selAccountOrganizationMatchingSpecCommunities` | `Veo_spec_communities`, `veo_communities`, `veo_spec_mstr` |
| 19 | `vds_selAccountOrganizationMatchingSpecSeries` | `veo_spec_mstr`, `veo_spec_series` |
| 20 | `vds_selAccountOrganizationPlanItems` | `Veo_applications`, `Veo_products` |
| 21 | `vds_selAllCatalogOptionPricingItemsForNonSession` | `Veo_applications`, `Veo_products` |
| 22 | `vds_selAllOptionPricingItemsForSession` | `Veo_applications`, `Veo_areas`, `Veo_builder_styles`, `Veo_products` |
| 23 | `vds_selAllPatterns` | `Veo_product_patterns`, `Veo_product_patterns_areas` |
| 24 | `vds_selAreaPriceLevels` | `Veo_applications`, `Veo_builder_styles`, `Veo_products` |
| 25 | `vds_selAvailableCabinetPartsBySessionGroup` | `Veo_cabinet_colors`, `Veo_cabinet_door_panels`, `Veo_cabinet_door_styles`, `Veo_cabinet_species`, `Veo_plan_builds`, `Veo_plan_mstr`, `Veo_stocking_codes`, `Veo_styles`, `Veo_styles_attributes`, `Veo_styles_groups`, `veo_colors`, `veo_spec_mstr` |
| 26 | `vds_selBuildAvailableBomModifications` | `Veo_applications`, `Veo_products` |
| 27 | `vds_selBuildItemClass` | `Veo_applications`, `Veo_plan_items`, `Veo_products` |
| 28 | `vds_selBuildPatternBomLines` | `Veo_plan_items`, `Veo_product_patterns_labor`, `Veo_product_patterns_material` |
| 29 | `vds_selBuildPatternCharge` | `Veo_labor_codes` |
| 30 | `vds_selBuilderPatterns` | `Veo_photo_attributes_values`, `Veo_product_patterns`, `Veo_product_patterns_areas`, `Veo_product_patterns_customers` |
| 31 | `vds_selBuilderSelectionsPatternsReport` | `Veo_applications`, `Veo_plan_items`, `Veo_product_patterns`, `Veo_product_patterns_material`, `Veo_products`, `veo_colors` |
| 32 | `vds_selBuilds` | `Veo_applications`, `Veo_areas`, `Veo_colors_customer_overrides`, `Veo_labor_codes`, `Veo_plan_areas`, `Veo_plan_builds`, `Veo_plan_items`, `Veo_product_patterns`, `Veo_products`, `Veo_sub_areas`, `veo_colors` |
| 33 | `vds_selCabinetColorsImage` | `Veo_cabinet_colors` |
| 34 | `vds_selCabinetDoorPanelsImage` | `Veo_cabinet_door_panels` |
| 35 | `vds_selCabinetDoorStylesImage` | `Veo_cabinet_door_styles` |
| 36 | `vds_selCabinetSpeciesImage` | `Veo_cabinet_species` |
| 37 | `vds_selCatalogAreasBySessionID` | `Veo_areas`, `Veo_sub_areas` |
| 38 | `vds_selCatalogOptionPricingItemsForSession` | `Veo_applications`, `Veo_areas`, `Veo_builder_styles`, `Veo_products` |
| 39 | `vds_selCatalogSelectionArea` | `Veo_applications`, `Veo_products` |
| 40 | `vds_selCatalogSelectionsGroupDetail` | `Veo_applications`, `Veo_products`, `Veo_styles`, `Veo_styles_groups`, `veo_colors` |
| 41 | `vds_selColor` | `Veo_colors_customer_overrides`, `Veo_styles`, `veo_colors` |
| 42 | `vds_selColorsBySessionAndBuild` | `Veo_products`, `Veo_stocking_codes`, `Veo_styles`, `veo_colors` |
| 43 | `vds_selCustomerCommunityExteriorPhotos` | `Veo_customers`, `Veo_photo_attributes_values`, `Veo_photos` |
| 44 | `vds_selEchelonAreas` | `Veo_areas` |
| 45 | `vds_selEchelonCustomerResolutionWithTenantPlan` | `Veo_plan_mstr`, `Veo_pricesets`, `Veo_spec_communities`, `veo_communities`, `veo_spec_mstr`, `veo_spec_series` |
| 46 | `vds_selEchelonGroupDetail` | `Veo_styles`, `Veo_styles_groups`, `Veo_styles_groups_detail`, `veo_colors`, `veo_spec_items` |
| 47 | `vds_selEchelonPlanFromBuildID` | `Veo_plan_builds`, `Veo_plan_mstr` |
| 48 | `vds_selEchelonPlansFromSpecID` | `Veo_plan_mstr` |
| 49 | `vds_selEchelonSubAreas` | `Veo_sub_areas` |
| 50 | `vds_selEstimatedOptionPricingItemsForSession` | `Veo_applications`, `Veo_areas`, `Veo_builder_styles`, `Veo_products` |
| 51 | `vds_selFieldItemsForAllBuildPriceLevels` | `Veo_builder_styles`, `Veo_colors_customer_overrides`, `Veo_plan_builds`, `Veo_plan_mstr`, `Veo_stocking_codes`, `Veo_styles`, `Veo_styles_groups`, `veo_colors`, `veo_spec_areas_items`, `veo_spec_items`, `veo_spec_mstr` |
| 52 | `vds_selHomebuyerCatalogBuilds` | `Veo_applications`, `Veo_areas`, `Veo_plan_areas`, `Veo_plan_builds`, `Veo_plan_mstr`, `Veo_products`, `Veo_sub_areas` |
| 53 | `vds_selHomebuyerCatalogEstimatedSelections` | `Veo_colors_customer_overrides`, `veo_colors` |
| 54 | `vds_selHomebuyerCatalogFieldColorsForBuild` | `Veo_applications`, `Veo_areas`, `Veo_builder_styles`, `Veo_colors_customer_overrides`, `Veo_photo_attributes_values`, `Veo_plan_builds`, `Veo_plan_mstr`, `Veo_products`, `Veo_stocking_codes`, `Veo_styles`, `Veo_styles_groups`, `veo_colors`, `veo_room_groups`, `veo_spec_areas_items`, `veo_spec_items`, `veo_spec_mstr` |
| 55 | `vds_selHomebuyerCatalogGeneralOptionsForRooms` | `Veo_areas`, `Veo_sub_areas` |
| 56 | `vds_selHomebuyerCatalogNonestimatedSelections` | `Veo_areas`, `Veo_sub_areas` |
| 57 | `vds_selInstalledProductPhotoAreas` | `Veo_areas`, `Veo_customers`, `Veo_photo_attributes`, `Veo_photo_attributes_values`, `Veo_photos`, `Veo_styles_groups_detail`, `veo_colors` |
| 58 | `vds_selInstalledProductPhotoProducts` | `Veo_customers`, `Veo_photo_attributes_values`, `Veo_photos`, `Veo_products`, `Veo_styles_groups_detail`, `veo_colors` |
| 59 | `vds_selInstalledProductPhotos` | `Veo_customers`, `Veo_photo_attributes_values`, `Veo_photos`, `Veo_styles_groups_detail`, `veo_colors` |
| 60 | `vds_selItemPricingData` | `Veo_vs_selItemPrice` |
| 61 | `vds_selLaborImageData` | `Veo_labor_codes` |
| 62 | `vds_selLargePhoto` | `Veo_photos` |
| 63 | `vds_selMediumPhoto` | `Veo_photos` |
| 64 | `vds_selNonSessionEstimatedProductSearchOptions` | `Veo_colors_customer_overrides`, `Veo_plan_mstr`, `Veo_spec_communities`, `Veo_stocking_codes`, `Veo_styles`, `Veo_styles_groups`, `veo_colors`, `veo_communities`, `veo_spec_items`, `veo_spec_mstr`, `veo_spec_series` |
| 65 | `vds_selOptionQtyByItemNumber` | `Veo_products_options`, `Veo_styles`, `Veo_styles_attributes`, `veo_colors`, `veo_products_options_materials` |
| 66 | `vds_selOtherAreas` | `Veo_product_patterns`, `Veo_product_patterns_areas` |
| 67 | `vds_selPartImageData` | `Veo_cabinet_colors`, `veo_colors` |
| 68 | `vds_selPartLaborCode` | `Veo_styles`, `veo_colors` |
| 69 | `vds_selPattern` | `Veo_photo_attributes_values`, `Veo_product_patterns` |
| 70 | `vds_selPatternAccentImage` | `Veo_product_patterns_material` |
| 71 | `vds_selPatternImage` | `Veo_product_patterns` |
| 72 | `vds_selPatterns` | `Veo_product_patterns`, `Veo_product_patterns_areas`, `Veo_product_patterns_customers` |
| 73 | `vds_selPatternsBySessionBuildOrganizationAndCriteria` | `Veo_applications`, `Veo_photo_attributes_values`, `Veo_product_patterns`, `Veo_product_patterns_areas`, `Veo_product_patterns_customers`, `Veo_products` |
| 74 | `vds_selPhotoAttributes` | `Veo_areas`, `Veo_customers_plans`, `Veo_of_getProductFromItemNumber`, `Veo_of_selCustomerItemProductName`, `Veo_of_selPartName`, `Veo_of_selProductName`, `Veo_photo_attributes`, `Veo_photo_attributes_values`, `Veo_product_patterns`, `veo_communities` |
| 75 | `vds_selPhotoIDsBySingleAttribute` | `Veo_photo_attributes_values`, `Veo_photos` |
| 76 | `vds_selPlanItemsSort` | `Veo_plan_items_sort` |
| 77 | `vds_selPriceLevelsByBuild` | `Veo_applications`, `Veo_builder_styles`, `Veo_products` |
| 78 | `vds_selPriceLevelsThatContainColorForSession` | `Veo_applications`, `Veo_areas`, `Veo_plan_builds`, `Veo_products`, `Veo_stocking_codes`, `Veo_sub_areas`, `veo_colors`, `veo_spec_areas_items` |
| 79 | `vds_selSelectedPatternBySessionAndBuild` | `Veo_photo_attributes_values`, `Veo_product_patterns` |
| 80 | `vds_selSessionCabinetAreaPriceLevels` | `Veo_styles_attributes`, `veo_colors` |
| 81 | `vds_selSessionCatalogItems` | `Veo_areas`, `Veo_sub_areas` |
| 82 | `vds_selSessionProductSearchOptions` | `Veo_areas`, `Veo_colors_customer_overrides`, `Veo_plan_builds`, `Veo_plan_mstr`, `Veo_stocking_codes`, `Veo_styles`, `Veo_styles_groups`, `Veo_sub_areas`, `veo_colors`, `veo_spec_items`, `veo_spec_mstr` |
| 83 | `vds_selSessionStructuralOptions` | `Veo_areas`, `Veo_sub_areas` |
| 84 | `vds_selSpecAccentItems` | `Veo_colors_customer_overrides`, `Veo_plan_builds`, `Veo_plan_mstr`, `Veo_stocking_codes`, `Veo_styles`, `Veo_styles_groups`, `Veo_styles_groups_detail`, `veo_colors`, `veo_spec_areas_items`, `veo_spec_items`, `veo_spec_mstr` |
| 85 | `vds_selSpecCabinetHardwareItems` | `Veo_colors_customer_overrides`, `Veo_plan_builds`, `Veo_plan_mstr`, `Veo_stocking_codes`, `Veo_styles`, `Veo_styles_groups`, `veo_colors`, `veo_spec_areas_items`, `veo_spec_items`, `veo_spec_mstr` |
| 86 | `vds_selSpecEdgeItems` | `Veo_customers`, `Veo_labor_codes`, `Veo_plan_builds`, `Veo_plan_mstr`, `Veo_styles`, `veo_colors`, `veo_spec_items`, `veo_spec_mstr` |
| 87 | `vds_selSpecFieldItems` | `Veo_colors_customer_overrides`, `Veo_plan_builds`, `Veo_plan_mstr`, `Veo_stocking_codes`, `Veo_styles`, `Veo_styles_groups`, `veo_colors`, `veo_spec_areas_items`, `veo_spec_items`, `veo_spec_mstr` |
| 88 | `vds_selSpecGroutItems` | `Veo_colors_customer_overrides`, `Veo_plan_builds`, `Veo_plan_mstr`, `Veo_stocking_codes`, `Veo_styles`, `Veo_styles_groups`, `veo_colors`, `veo_spec_areas_items`, `veo_spec_items`, `veo_spec_mstr` |
| 89 | `vds_selSpecItems` | `Veo_colors_customer_overrides`, `Veo_plan_builds`, `Veo_plan_mstr`, `Veo_stocking_codes`, `Veo_styles`, `Veo_styles_groups`, `veo_colors`, `veo_spec_areas_items`, `veo_spec_items`, `veo_spec_mstr` |
| 90 | `vds_selSpecPatternItems` | `Veo_applications`, `Veo_product_patterns`, `Veo_product_patterns_areas`, `Veo_product_patterns_customers`, `Veo_products` |
| 91 | `vds_selSpecSinkItems` | `Veo_colors_customer_overrides`, `Veo_plan_builds`, `Veo_plan_mstr`, `Veo_stocking_codes`, `Veo_styles`, `Veo_styles_groups`, `veo_colors`, `veo_spec_items`, `veo_spec_mstr` |
| 92 | `vds_selThumbnailPhoto` | `Veo_photos` |
| 93 | `vds_selValidPatternsForBuild` | `Veo_applications`, `Veo_product_patterns`, `Veo_product_patterns_areas`, `Veo_product_patterns_customers`, `Veo_products` |
| 94 | `vds_selVisualizationErrorReport` | `Veo_products`, `veo_colors` |
| 95 | `vds_sessionSelectionsXMLExport` | `Veo_applications`, `Veo_plan_builds`, `Veo_plan_mstr`, `Veo_product_patterns`, `Veo_products` |
| 96 | `vds_updApplyPattern` | `Veo_applications`, `Veo_esp_selItemPrice`, `Veo_plan_items`, `Veo_product_patterns_labor`, `Veo_product_patterns_material`, `Veo_products` |
| 97 | `vds_updateBuildStatus` | `Veo_products`, `Veo_styles`, `veo_colors` |
| 98 | `vds_vs_selItemPrice` | `Veo_vs_selItemPrice` |
| 99 | `vs_CreateCatalogSelectionGroups` | `Veo_styles_groups`, `Veo_styles_groups_detail`, `veo_spec_items` |
| 100 | `vs_RptInvoice` | `Veo_customers` |
| 101 | `vs_createSessionPricingSnapshot` | `veo_prices_published`, `veo_prices_published_groups_detail` |
| 102 | `vs_getUserCatalogSelections` | `Veo_applications`, `Veo_areas`, `Veo_builder_styles`, `Veo_products`, `veo_room_groups` |
| 103 | `vs_rptSelectionsPatterns` | `Veo_applications`, `Veo_plan_items`, `Veo_product_patterns`, `Veo_product_patterns_material`, `Veo_products`, `veo_colors` |
| 104 | `vs_selAddressSelectionSummaryByArea` | `Veo_labor_codes`, `veo_colors`, `veo_spec_mstr` |
| 105 | `vs_selCatalogAreaBySessionID` | `Veo_areas`, `Veo_sub_areas` |
| 106 | `vs_selCatalogSelectionAreaDetails` | `Veo_applications`, `Veo_labor_codes`, `Veo_plan_items`, `Veo_products`, `veo_colors` |
| 107 | `vs_selCatalogSelectionAreas` | `Veo_areas`, `veo_room_groups` |
| 108 | `vs_selCatalogSelectionsByDate` | `Veo_labor_codes`, `veo_colors` |
| 109 | `vs_selCustomerLogo` | `Veo_customers` |
| 110 | `vs_selDocumentApplications` | `Veo_applications` |
| 111 | `vs_selDocumentProductFromApplications` | `Veo_application_products`, `Veo_applications`, `Veo_products` |
| 112 | `vs_selGroupDetails` | `Veo_stocking_codes`, `Veo_styles`, `veo_colors` |
| 113 | `vs_selPartListFromSession` | `Veo_stocking_codes`, `Veo_styles`, `veo_colors` |
| 114 | `vs_selPatternBuildReportDetails` | `Veo_product_patterns_material`, `veo_colors` |
| 115 | `vs_selPatternBuildReportInfo` | `Veo_product_patterns` |
| 116 | `vs_selVeoSolutionsSelectionSetDataExport` | `Veo_applications`, `Veo_plan_builds`, `Veo_plan_mstr`, `Veo_product_patterns`, `Veo_products` |
| 117 | `vsd_selSessionCabinetsByBuild` | `Veo_styles_attributes`, `Veo_styles_related_items`, `veo_colors` |

## Synonyms with no proc references

`Veo_areas_sub_areas`, `Veo_customers_items_applications`, `Veo_customers_items_products`, `Veo_ef_selStyleColorNameWithAttributes`, `Veo_esp_selColor`, `Veo_esp_selColorsFromAttributes`, `Veo_plan_items_alias`, `Veo_spec_plans`, `Veo_vs_searchPart`, `Veo_vsp_selSpecColorsFromAttributes`, `veo_prices_default_labor`, `veo_prices_extended_labor`, `veo_prices_global_labor`, `veo_prices_public_labor`, `veo_products_options_values`, `veo_regions`

