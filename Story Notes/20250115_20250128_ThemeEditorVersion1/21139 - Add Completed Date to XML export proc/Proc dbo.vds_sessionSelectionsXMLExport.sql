/*
*** 'DEV' DBS ***

USE [VeoSolutions_DEV]
use [VeoSolutions_QA]
use [VeoSolutions_Staging]
use [VeoSolutions_Preview]

*** Prod DBS ***

use [AFI_VEOSolutions]
use [CCDI_VEOSolutions]
use [EPLAN_VEOSolutions]
use [VEOSolutions]

*/


CREATE or ALTER PROCEDURE [dbo].[vds_sessionSelectionsXMLExport]
	@session_id	UNIQUEIDENTIFIER,
	@xml XML = NULL OUT
AS
/*
	Author: Shelby Mansker
	Date: 10/18/2019
	Description: Creates an XML structure, containing all of the selections for a session.
		If the @set_export_date flag is set, it will also set the export_date on the session record.

	Modified By: Shelby Mansker
	Date: 10/22/2019
	Description: This proc no longer updates the export date on the session record. Cindy asked that we
		allow that to happen on the Echelon side, because they may encounter an error after exporting, in
		which case, they wouldn't want the export date to be set.

	Modified By: Justin Pope
	Date: 1/14/2020
	Description: This proc did not include the credit_qty of each area item coming from catalog_selections_area_details.
		This change will match what was originally in vs_selVeoSolutionsSelectionSetDataExport.
	
	Modified By: Charles Moore
	Date: 9/10/2021
	Description: Convert Lot to string values

	Modified By: Justin Pope
	Date: 1/16/2025
	Description: Including new fields to the export
		completed_date & first_completed_date

	-- Example test for this proc
	DECLARE @xml XML
	EXEC vds_shelbyTestSelectionsExport @session_id = 'e9656bba-c9ff-4a0b-99df-e8751e244b69', @xml = @xml OUT
	SELECT @xml

	-- Example test for original proc
	DECLARE @xml XML
	EXEC vs_selVeoSolutionsSelectionSetDataExport @session_id_orig = 'e9656bba-c9ff-4a0b-99df-e8751e244b69', @xml = @xml OUT
	SELECT @xml
*/
BEGIN
	DECLARE @appointment_date DATETIME,
			@plan_id INT,
			@plan_name VARCHAR(50),
			@community_id INT;

	-- Get the user's first appointment date if they have one
	SELECT TOP(1)
		@appointment_date = sa.appointment_date
	FROM
		account_organization_user_profile_plan_catalog_sessions cs WITH (NOLOCK)
		JOIN account_organization_user_profile p WITH (NOLOCK) ON
			p.account_id = cs.account_id
			AND p.organization_id = cs.organization_id
			AND p.[user_id] = cs.[user_id]
		JOIN scheduling_appointments sa ON 
			sa.buyer_profile_id = p.profile_id
	WHERE
		cs.session_id = @session_id
	ORDER BY
		sa.appointment_date

	SET @appointment_date = ISNULL(@appointment_date, '1/1/1900')

	-- Figure out the echelon plan id
	SELECT TOP(1)
		@plan_id = vpb.plan_id,
		@plan_name = pm.plan_name
	FROM 
		account_organization_user_profile_plan_catalog_sessions cs WITH (NOLOCK)
		JOIN catalog_selections_areas csa WITH (NOLOCK) ON csa.session_id = cs.session_id
		JOIN veo_plan_builds vpb ON vpb.build_id_num = csa.build_id
		JOIN Veo_plan_mstr pm ON pm.plan_id = vpb.plan_id
	WHERE
		cs.session_id = @session_id

	-- Figure out the Echelon community id
	SELECT @community_id = dbo.getSessionWBSCommunityID(@session_id)

	-- Build the XML Output
	SET @xml = (SELECT
		@session_id AS '@user_plan_id',
		@session_id AS '@estimated_id',
		u.[user_id] AS '@user_id',
		@plan_id AS '@plan_id',
		cs.spec_id AS '@spec_id',
		cs.create_date AS '@effective_date',
		cs.completed_date as '@completed_date',
		cs.first_completed_date as '@first_completed_date',
		cs.designer AS '@designer',
		pp.job_type AS '@job_type',
		CONVERT(VARCHAR, @appointment_date, 101) AS '@appointment_date',
		pp.[address] AS 'address/@address',
		IIF(pp.lot in('0',''), '', CONCAT(pp.lot, ' ', pp.[block])) AS 'address/@lot_block',
		pp.city AS 'address/@city',
		pp.[state] AS 'address/@state',
		pp.zip_code AS 'address/@zipcode',
		ISNULL(o.external_organization_id, '') AS 'address/@builder_id',
		ISNULL(cs.spec_id, 0) AS 'address/@spec_id',
		cs.community_id AS 'address/@community_id',	
		ISNULL(cs.series, '') AS 'address/@series',
		@plan_name AS 'address/@plan_name',
		pp.elevation AS 'address/@elevation',
		CONCAT(u.first_name, ' ', u.last_name) AS 'contact/@contact_name',
		pp.home_phone AS 'contact/@home_phone',
		pp.work_phone AS 'contact/@work_phone',
		u.email AS 'contact/@email',
		(
			SELECT
				a.application_id AS '@application_id',
				p.product_id AS '@product_id',
				CONCAT(csa.area_id, '|', csa.sub_area_id) AS '@area_group_id',
				csa.area AS '@area_desc',
				csa.area_id AS '@area_id',
				csa.sub_area_id AS '@sub_area_id',
				'1' AS '@location_id',
				csa.build_id AS '@build_id',
				dbo.vdsf_sanitizeStringForXml(
					CASE
						WHEN csa.notes <> '' and dbo.vdsf_getBomModificationNotes(@session_id,csa.build_id) <> '' THEN 	'Area Notes: '+csa.notes + ' Bom Mod Notes: '+ dbo.vdsf_getBomModificationNotes(@session_id,csa.build_id)
						WHEN csa.notes <> '' THEN 'Area Notes: '+csa.notes
						WHEN dbo.vdsf_getBomModificationNotes(@session_id,csa.build_id) <> '' THEN ' Bom Mod Notes: '+ dbo.vdsf_getBomModificationNotes(@session_id,csa.build_id)
						ELSE ''
					END
				) AS '@area_notes',
				(
					SELECT
						details.item_type AS '@item_type',
						details.item_id AS '@item_id',
						details.real_item_id AS '@item_number',
						details.uom_id AS '@uom_id',
						CASE
							WHEN details.price_type = 'area' THEN 1
							ELSE details.bill_qty
						END AS '@bill_qty',
						details.homeowner_price AS '@homeowner_price',
						details.alloc_qty AS '@alloc_qty',
						details.pattern_id AS '@pattern_id',
						details.credit_qty as '@credit_qty',
						pp.pattern_name AS '@pattern_name',
						(
							SELECT
								options.option_id AS '@option_id',
								options.option_value AS '@option_value',
								options.option_source AS '@option_source',
								options.included AS '@included',
								options.qty AS '@qty',
								options.alloc_qty AS '@alloc_qty',
								options.price AS '@price',
								options.price_retail AS '@price_retail',
								options.retail_percentage AS '@retail_percentage',
								options.price_type AS '@price_type',
								options.pricing_source AS '@pricing_source'
							FROM
								catalog_selections_area_detail_options options WITH (NOLOCK)
							WHERE
								options.session_id = details.session_id
								AND options.[application] = details.[application]
								AND options.product = details.product
								AND options.area = details.area
								AND options.sub_area = details.sub_area
								AND options.item_type = details.item_type
								AND options.item_id = details.item_id
							FOR XML PATH ('option'), ROOT ('options'), TYPE
						)
					FROM
						catalog_selections_area_details details WITH (NOLOCK)
						LEFT JOIN Veo_product_patterns pp WITH (NOLOCK) ON pp.pattern_id = details.pattern_id
					WHERE
						details.session_id = csa.session_id
						AND details.item_id NOT IN ('promo_credit','override_credit','incorrect_price_credit','credit','sold_at_contract_credit')
						AND details.[application] = csa.[application]
						AND details.product = csa.product
						AND details.area = csa.area
						AND details.sub_area = csa.sub_area
					FOR XML PATH ('item'), ROOT ('items'), TYPE
				),
				(
					SELECT
						line_no,
						pricing_source,
						price_type,
						item_type,
						item_id,
						item_class,
						item_description,
						selectable,
						real_item_id,
						real_item_description,
						bill_qty,
						alloc_qty,
						credit_qty,
						uom,
						builder_price,
						homeowner_price,
						force_reprice,
						retail_percentage,
						retail_percentage_type,
						(
							SELECT
								*
							FROM
								OPENJSON(options_json)
							WITH (
								option_id VARCHAR(25) '$.OptionID',
								option_value VARCHAR(100) '$.OptionValue',
								option_source VARCHAR(50) '$.OptionSource',
								included BIT '$.Included',
								qty INT '$.Qty',
								price DECIMAL(18,2) '$.Price',
								price_retail DECIMAL(18,2) '$.PriceRetail',
								price_type VARCHAR(25) '$.PriceType',
								pricing_source VARCHAR(50) '$.PricingSource',
								retail_percentage DECIMAL(18,2) '$.RetailPercentage',
								retail_percentage_type VARCHAR(50) '$.RetailPercentageType'
							)
							FOR XML RAW ('option'), ROOT ('options'), TYPE
						)
					FROM
						OPENJSON
						(
							(
							SELECT
								CAST(DECOMPRESS(serialized_bom_data) AS VARCHAR(MAX))
							FROM
								catalog_selections_price_level_boms WITH (NOLOCK)
							WHERE
								session_id = csa.session_id
								AND catalog_selections_row_id = csa.selected_field_group
							)
						)
						WITH 
						(
							line_no INT '$.LineNo',
							pricing_source VARCHAR(25) '$.PricingSource',
							price_type VARCHAR(50) '$.PriceType',
							item_type VARCHAR(50) '$.ItemType',
							item_id VARCHAR(50) '$.ItemID',
							item_class VARCHAR(50) '$.ItemClass',
							item_description VARCHAR(100) '$.ItemDescription',
							selectable BIT '$.Selectable',
							real_item_id VARCHAR(100) '$.RealItemID',
							real_item_description VARCHAR(200) '$.RealItemDescription',
							bill_qty DECIMAL(18,4) '$.BillQty',
							alloc_qty DECIMAL(18,4) '$.AllocQty',
							credit_qty DECIMAL(18,4) '$.CreditQty',
							uom VARCHAR(10) '$.UOM',
							builder_price DECIMAL(18,2) '$.BuilderPrice',
							homeowner_price DECIMAL(18,2) '$.HomeownerPrice',
							force_reprice BIT '$.ForceReprice',
							retail_percentage DECIMAL(18,2) '$.RetailPercentage',
							retail_percentage_type VARCHAR(50) '$.RetailPercentageType',
							options_json NVARCHAR(MAX) '$.Options' AS JSON
						)
					FOR XML RAW ('item'), ROOT ('original_items'), TYPE
				)
			FROM
				catalog_selections_areas csa WITH (NOLOCK)
				LEFT JOIN Veo_applications a WITH (NOLOCK) ON a.[name] = rtrim(ltrim(csa.[application]))
				LEFT JOIN Veo_products p WITH (NOLOCK) ON p.[name] = rtrim(ltrim(csa.product))
			WHERE 
				csa.session_id = cs.session_id
				AND csa.area_selected = 1
				AND csa.selected > 0
			FOR XML PATH ('area_group'), TYPE
		),
		(
			SELECT
				document_type AS 'image/@document_type',
				application_id AS 'image/@application_id',
				product_id AS 'image/@product_id',
				area_id AS 'image/@area_id',
				sub_area_id AS 'image/@sub_area_id',
				location_id AS 'image/@location_id',
				document_data AS 'image'
			FROM
				account_organization_user_profile_plan_catalog_sessions_documents docs WITH (NOLOCK)
			WHERE
				docs.session_id = cs.session_id
			FOR XML PATH ('images'), TYPE, BINARY BASE64
		)
	FROM
		account_organization_user_profile_plan_catalog_sessions cs WITH (NOLOCK)
		JOIN account_organization_user_profile_plan pp WITH (NOLOCK) ON
			pp.account_id = cs.account_id
			AND pp.organization_id = cs.organization_id
			AND pp.[user_id] = cs.[user_id]
			AND pp.community_name = cs.community_name
			AND pp.series = cs.series
			AND pp.plan_name = cs.plan_name
		JOIN VeoSolutionsSecurity_organizations o WITH (NOLOCK) ON o.organization_id = pp.organization_id
		JOIN VeoSolutionsSecurity_users u WITH (NOLOCK) ON u.[user_id] = pp.[user_id]
	WHERE
		cs.session_id = @session_id
	FOR XML PATH ('ConciergeSelectionSet'))
END
GO