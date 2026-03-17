/*
    Story: 30900
    Purpose:
        Deploy only the WBS synonym objects needed by
        dbo.vds_selNonSessionEstimatedProductSearchOptions.

        This script is intended for the production VeoSolutions databases:
          - AFI_VEOSolutions
          - CCDI_VEOSolutions
          - EPLAN_VEOSolutions
          - VEOSolutions

        The stored procedure itself will be deployed separately via RedGate SQL Compare.

    Notes:
        - Synonyms point to the WBS source indicated by each production publish profile.
        - Safe to re-run: existing synonyms are dropped before being recreated.
*/

SET NOCOUNT ON;
GO

PRINT 'Deploying WBS synonyms to AFI_VEOSolutions';
GO
USE [AFI_VEOSolutions];
GO

IF OBJECT_ID(N'[dbo].[wbs_applications]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_applications];
IF OBJECT_ID(N'[dbo].[wbs_areas]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_areas];
IF OBJECT_ID(N'[dbo].[wbs_areas_sub_areas]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_areas_sub_areas];
IF OBJECT_ID(N'[dbo].[wbs_builder_styles]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_builder_styles];
IF OBJECT_ID(N'[dbo].[wbs_plan_builds]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_plan_builds];
IF OBJECT_ID(N'[dbo].[wbs_plan_material]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_plan_material];
IF OBJECT_ID(N'[dbo].[wbs_plan_mstr]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_plan_mstr];
IF OBJECT_ID(N'[dbo].[wbs_prices_landed]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_prices_landed];
IF OBJECT_ID(N'[dbo].[wbs_pricesets]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_pricesets];
IF OBJECT_ID(N'[dbo].[wbs_products]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_products];
IF OBJECT_ID(N'[dbo].[wbs_spec_areas_items]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_spec_areas_items];
IF OBJECT_ID(N'[dbo].[wbs_spec_communities]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_spec_communities];
IF OBJECT_ID(N'[dbo].[wbs_spec_items]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_spec_items];
IF OBJECT_ID(N'[dbo].[wbs_spec_mstr]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_spec_mstr];
IF OBJECT_ID(N'[dbo].[wbs_spec_series]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_spec_series];
IF OBJECT_ID(N'[dbo].[wbs_styles_groups_detail]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_styles_groups_detail];
IF OBJECT_ID(N'[dbo].[wbs_sub_areas]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_sub_areas];
GO

CREATE SYNONYM [dbo].[wbs_applications] FOR [AFI].[dbo].[applications];
CREATE SYNONYM [dbo].[wbs_areas] FOR [AFI].[dbo].[areas];
CREATE SYNONYM [dbo].[wbs_areas_sub_areas] FOR [AFI].[dbo].[areas_sub_areas];
CREATE SYNONYM [dbo].[wbs_builder_styles] FOR [AFI].[dbo].[builder_styles];
CREATE SYNONYM [dbo].[wbs_plan_builds] FOR [AFI].[dbo].[plan_builds];
CREATE SYNONYM [dbo].[wbs_plan_material] FOR [AFI].[dbo].[plan_material];
CREATE SYNONYM [dbo].[wbs_plan_mstr] FOR [AFI].[dbo].[plan_mstr];
CREATE SYNONYM [dbo].[wbs_prices_landed] FOR [AFI].[dbo].[prices_landed];
CREATE SYNONYM [dbo].[wbs_pricesets] FOR [AFI].[dbo].[pricesets];
CREATE SYNONYM [dbo].[wbs_products] FOR [AFI].[dbo].[products];
CREATE SYNONYM [dbo].[wbs_spec_areas_items] FOR [AFI].[dbo].[spec_areas_items];
CREATE SYNONYM [dbo].[wbs_spec_communities] FOR [AFI].[dbo].[spec_communities];
CREATE SYNONYM [dbo].[wbs_spec_items] FOR [AFI].[dbo].[spec_items];
CREATE SYNONYM [dbo].[wbs_spec_mstr] FOR [AFI].[dbo].[spec_mstr];
CREATE SYNONYM [dbo].[wbs_spec_series] FOR [AFI].[dbo].[spec_series];
CREATE SYNONYM [dbo].[wbs_styles_groups_detail] FOR [AFI].[dbo].[styles_groups_detail];
CREATE SYNONYM [dbo].[wbs_sub_areas] FOR [AFI].[dbo].[sub_areas];
GO

PRINT 'Deploying WBS synonyms to CCDI_VEOSolutions';
GO
USE [CCDI_VEOSolutions];
GO

IF OBJECT_ID(N'[dbo].[wbs_applications]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_applications];
IF OBJECT_ID(N'[dbo].[wbs_areas]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_areas];
IF OBJECT_ID(N'[dbo].[wbs_areas_sub_areas]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_areas_sub_areas];
IF OBJECT_ID(N'[dbo].[wbs_builder_styles]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_builder_styles];
IF OBJECT_ID(N'[dbo].[wbs_plan_builds]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_plan_builds];
IF OBJECT_ID(N'[dbo].[wbs_plan_material]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_plan_material];
IF OBJECT_ID(N'[dbo].[wbs_plan_mstr]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_plan_mstr];
IF OBJECT_ID(N'[dbo].[wbs_prices_landed]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_prices_landed];
IF OBJECT_ID(N'[dbo].[wbs_pricesets]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_pricesets];
IF OBJECT_ID(N'[dbo].[wbs_products]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_products];
IF OBJECT_ID(N'[dbo].[wbs_spec_areas_items]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_spec_areas_items];
IF OBJECT_ID(N'[dbo].[wbs_spec_communities]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_spec_communities];
IF OBJECT_ID(N'[dbo].[wbs_spec_items]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_spec_items];
IF OBJECT_ID(N'[dbo].[wbs_spec_mstr]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_spec_mstr];
IF OBJECT_ID(N'[dbo].[wbs_spec_series]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_spec_series];
IF OBJECT_ID(N'[dbo].[wbs_styles_groups_detail]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_styles_groups_detail];
IF OBJECT_ID(N'[dbo].[wbs_sub_areas]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_sub_areas];
GO

CREATE SYNONYM [dbo].[wbs_applications] FOR [CCDI].[dbo].[applications];
CREATE SYNONYM [dbo].[wbs_areas] FOR [CCDI].[dbo].[areas];
CREATE SYNONYM [dbo].[wbs_areas_sub_areas] FOR [CCDI].[dbo].[areas_sub_areas];
CREATE SYNONYM [dbo].[wbs_builder_styles] FOR [CCDI].[dbo].[builder_styles];
CREATE SYNONYM [dbo].[wbs_plan_builds] FOR [CCDI].[dbo].[plan_builds];
CREATE SYNONYM [dbo].[wbs_plan_material] FOR [CCDI].[dbo].[plan_material];
CREATE SYNONYM [dbo].[wbs_plan_mstr] FOR [CCDI].[dbo].[plan_mstr];
CREATE SYNONYM [dbo].[wbs_prices_landed] FOR [CCDI].[dbo].[prices_landed];
CREATE SYNONYM [dbo].[wbs_pricesets] FOR [CCDI].[dbo].[pricesets];
CREATE SYNONYM [dbo].[wbs_products] FOR [CCDI].[dbo].[products];
CREATE SYNONYM [dbo].[wbs_spec_areas_items] FOR [CCDI].[dbo].[spec_areas_items];
CREATE SYNONYM [dbo].[wbs_spec_communities] FOR [CCDI].[dbo].[spec_communities];
CREATE SYNONYM [dbo].[wbs_spec_items] FOR [CCDI].[dbo].[spec_items];
CREATE SYNONYM [dbo].[wbs_spec_mstr] FOR [CCDI].[dbo].[spec_mstr];
CREATE SYNONYM [dbo].[wbs_spec_series] FOR [CCDI].[dbo].[spec_series];
CREATE SYNONYM [dbo].[wbs_styles_groups_detail] FOR [CCDI].[dbo].[styles_groups_detail];
CREATE SYNONYM [dbo].[wbs_sub_areas] FOR [CCDI].[dbo].[sub_areas];
GO

PRINT 'Deploying WBS synonyms to EPLAN_VEOSolutions';
GO
USE [EPLAN_VEOSolutions];
GO

IF OBJECT_ID(N'[dbo].[wbs_applications]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_applications];
IF OBJECT_ID(N'[dbo].[wbs_areas]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_areas];
IF OBJECT_ID(N'[dbo].[wbs_areas_sub_areas]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_areas_sub_areas];
IF OBJECT_ID(N'[dbo].[wbs_builder_styles]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_builder_styles];
IF OBJECT_ID(N'[dbo].[wbs_plan_builds]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_plan_builds];
IF OBJECT_ID(N'[dbo].[wbs_plan_material]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_plan_material];
IF OBJECT_ID(N'[dbo].[wbs_plan_mstr]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_plan_mstr];
IF OBJECT_ID(N'[dbo].[wbs_prices_landed]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_prices_landed];
IF OBJECT_ID(N'[dbo].[wbs_pricesets]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_pricesets];
IF OBJECT_ID(N'[dbo].[wbs_products]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_products];
IF OBJECT_ID(N'[dbo].[wbs_spec_areas_items]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_spec_areas_items];
IF OBJECT_ID(N'[dbo].[wbs_spec_communities]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_spec_communities];
IF OBJECT_ID(N'[dbo].[wbs_spec_items]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_spec_items];
IF OBJECT_ID(N'[dbo].[wbs_spec_mstr]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_spec_mstr];
IF OBJECT_ID(N'[dbo].[wbs_spec_series]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_spec_series];
IF OBJECT_ID(N'[dbo].[wbs_styles_groups_detail]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_styles_groups_detail];
IF OBJECT_ID(N'[dbo].[wbs_sub_areas]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_sub_areas];
GO

CREATE SYNONYM [dbo].[wbs_applications] FOR [CCDI_ERP].[CCDI].[dbo].[applications];
CREATE SYNONYM [dbo].[wbs_areas] FOR [CCDI_ERP].[CCDI].[dbo].[areas];
CREATE SYNONYM [dbo].[wbs_areas_sub_areas] FOR [CCDI_ERP].[CCDI].[dbo].[areas_sub_areas];
CREATE SYNONYM [dbo].[wbs_builder_styles] FOR [CCDI_ERP].[CCDI].[dbo].[builder_styles];
CREATE SYNONYM [dbo].[wbs_plan_builds] FOR [CCDI_ERP].[CCDI].[dbo].[plan_builds];
CREATE SYNONYM [dbo].[wbs_plan_material] FOR [CCDI_ERP].[CCDI].[dbo].[plan_material];
CREATE SYNONYM [dbo].[wbs_plan_mstr] FOR [CCDI_ERP].[CCDI].[dbo].[plan_mstr];
CREATE SYNONYM [dbo].[wbs_prices_landed] FOR [CCDI_ERP].[CCDI].[dbo].[prices_landed];
CREATE SYNONYM [dbo].[wbs_pricesets] FOR [CCDI_ERP].[CCDI].[dbo].[pricesets];
CREATE SYNONYM [dbo].[wbs_products] FOR [CCDI_ERP].[CCDI].[dbo].[products];
CREATE SYNONYM [dbo].[wbs_spec_areas_items] FOR [CCDI_ERP].[CCDI].[dbo].[spec_areas_items];
CREATE SYNONYM [dbo].[wbs_spec_communities] FOR [CCDI_ERP].[CCDI].[dbo].[spec_communities];
CREATE SYNONYM [dbo].[wbs_spec_items] FOR [CCDI_ERP].[CCDI].[dbo].[spec_items];
CREATE SYNONYM [dbo].[wbs_spec_mstr] FOR [CCDI_ERP].[CCDI].[dbo].[spec_mstr];
CREATE SYNONYM [dbo].[wbs_spec_series] FOR [CCDI_ERP].[CCDI].[dbo].[spec_series];
CREATE SYNONYM [dbo].[wbs_styles_groups_detail] FOR [CCDI_ERP].[CCDI].[dbo].[styles_groups_detail];
CREATE SYNONYM [dbo].[wbs_sub_areas] FOR [CCDI_ERP].[CCDI].[dbo].[sub_areas];
GO

PRINT 'Deploying WBS synonyms to VEOSolutions';
GO
USE [VEOSolutions];
GO

IF OBJECT_ID(N'[dbo].[wbs_applications]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_applications];
IF OBJECT_ID(N'[dbo].[wbs_areas]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_areas];
IF OBJECT_ID(N'[dbo].[wbs_areas_sub_areas]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_areas_sub_areas];
IF OBJECT_ID(N'[dbo].[wbs_builder_styles]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_builder_styles];
IF OBJECT_ID(N'[dbo].[wbs_plan_builds]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_plan_builds];
IF OBJECT_ID(N'[dbo].[wbs_plan_material]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_plan_material];
IF OBJECT_ID(N'[dbo].[wbs_plan_mstr]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_plan_mstr];
IF OBJECT_ID(N'[dbo].[wbs_prices_landed]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_prices_landed];
IF OBJECT_ID(N'[dbo].[wbs_pricesets]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_pricesets];
IF OBJECT_ID(N'[dbo].[wbs_products]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_products];
IF OBJECT_ID(N'[dbo].[wbs_spec_areas_items]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_spec_areas_items];
IF OBJECT_ID(N'[dbo].[wbs_spec_communities]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_spec_communities];
IF OBJECT_ID(N'[dbo].[wbs_spec_items]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_spec_items];
IF OBJECT_ID(N'[dbo].[wbs_spec_mstr]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_spec_mstr];
IF OBJECT_ID(N'[dbo].[wbs_spec_series]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_spec_series];
IF OBJECT_ID(N'[dbo].[wbs_styles_groups_detail]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_styles_groups_detail];
IF OBJECT_ID(N'[dbo].[wbs_sub_areas]', N'SN') IS NOT NULL DROP SYNONYM [dbo].[wbs_sub_areas];
GO

CREATE SYNONYM [dbo].[wbs_applications] FOR [ERP].[WBS].[dbo].[applications];
CREATE SYNONYM [dbo].[wbs_areas] FOR [ERP].[WBS].[dbo].[areas];
CREATE SYNONYM [dbo].[wbs_areas_sub_areas] FOR [ERP].[WBS].[dbo].[areas_sub_areas];
CREATE SYNONYM [dbo].[wbs_builder_styles] FOR [ERP].[WBS].[dbo].[builder_styles];
CREATE SYNONYM [dbo].[wbs_plan_builds] FOR [ERP].[WBS].[dbo].[plan_builds];
CREATE SYNONYM [dbo].[wbs_plan_material] FOR [ERP].[WBS].[dbo].[plan_material];
CREATE SYNONYM [dbo].[wbs_plan_mstr] FOR [ERP].[WBS].[dbo].[plan_mstr];
CREATE SYNONYM [dbo].[wbs_prices_landed] FOR [ERP].[WBS].[dbo].[prices_landed];
CREATE SYNONYM [dbo].[wbs_pricesets] FOR [ERP].[WBS].[dbo].[pricesets];
CREATE SYNONYM [dbo].[wbs_products] FOR [ERP].[WBS].[dbo].[products];
CREATE SYNONYM [dbo].[wbs_spec_areas_items] FOR [ERP].[WBS].[dbo].[spec_areas_items];
CREATE SYNONYM [dbo].[wbs_spec_communities] FOR [ERP].[WBS].[dbo].[spec_communities];
CREATE SYNONYM [dbo].[wbs_spec_items] FOR [ERP].[WBS].[dbo].[spec_items];
CREATE SYNONYM [dbo].[wbs_spec_mstr] FOR [ERP].[WBS].[dbo].[spec_mstr];
CREATE SYNONYM [dbo].[wbs_spec_series] FOR [ERP].[WBS].[dbo].[spec_series];
CREATE SYNONYM [dbo].[wbs_styles_groups_detail] FOR [ERP].[WBS].[dbo].[styles_groups_detail];
CREATE SYNONYM [dbo].[wbs_sub_areas] FOR [ERP].[WBS].[dbo].[sub_areas];
GO
