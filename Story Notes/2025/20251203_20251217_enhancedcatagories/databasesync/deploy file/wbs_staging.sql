/*
Run this script on:

        dev-sql.veodesignstudio.com.WBS_Staging    -  This database will be modified

to synchronize it with:

        echelon-staging.wisenbaker.com.Echelon_Staging

You are recommended to back up your database before running this script

Script created by SQL Compare version 15.4.1.27450 from Red Gate Software Ltd at 12/8/2025 2:55:30 PM

*/
use [WBS_Staging];
go
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
SET XACT_ABORT ON
GO
SET TRANSACTION ISOLATION LEVEL Serializable
GO
BEGIN TRANSACTION
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping foreign keys from [dbo].[prices_extended_material]'
GO
ALTER TABLE [dbo].[prices_extended_material] DROP CONSTRAINT [FK_prices_extended_material_sub_areas]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping foreign keys from [dbo].[prices_extended_labor]'
GO
ALTER TABLE [dbo].[prices_extended_labor] DROP CONSTRAINT [FK_prices_extended_labor_sub_areas]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping constraints from [dbo].[prices_extended_labor]'
GO
ALTER TABLE [dbo].[prices_extended_labor] DROP CONSTRAINT [PK_prices_extended_labor]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping constraints from [dbo].[prices_extended_material]'
GO
ALTER TABLE [dbo].[prices_extended_material] DROP CONSTRAINT [PK_prices_extended_material]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[prices_extended_labor]'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
ALTER TABLE [dbo].[prices_extended_labor] ADD
[item_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_prices_extended_labor_item_id] DEFAULT (''),
[bypass_flat_fee_exclusion] [bit] NOT NULL CONSTRAINT [DF__prices_ex__bypas__6303B0A0] DEFAULT ((0))
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_prices_extended_labor] on [dbo].[prices_extended_labor]'
GO
ALTER TABLE [dbo].[prices_extended_labor] ADD CONSTRAINT [PK_prices_extended_labor] PRIMARY KEY CLUSTERED ([spec_id], [effective_date], [application_id], [product_id], [area_id], [sub_area_id], [plan_id], [build_id], [item_id], [labor_code])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[z_prices_extended_labor]'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
ALTER TABLE [dbo].[z_prices_extended_labor] ADD
[item_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_z_prices_extended_labor_item_id] DEFAULT (''),
[bypass_flat_fee_exclusion] [bit] NOT NULL CONSTRAINT [DF__z_prices___bypas__22E92B8B] DEFAULT ((0))
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[prices_extended_material]'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
ALTER TABLE [dbo].[prices_extended_material] ADD
[item_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_prices_extended_material_item_id] DEFAULT (''),
[bypass_flat_fee_exclusion] [bit] NOT NULL CONSTRAINT [DF__prices_ex__bypas__620F8C67] DEFAULT ((0))
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_prices_extended_material] on [dbo].[prices_extended_material]'
GO
ALTER TABLE [dbo].[prices_extended_material] ADD CONSTRAINT [PK_prices_extended_material] PRIMARY KEY CLUSTERED ([spec_id], [effective_date], [application_id], [product_id], [area_id], [sub_area_id], [plan_id], [build_id], [item_id], [item_type], [item])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[z_prices_extended_material]'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
ALTER TABLE [dbo].[z_prices_extended_material] ADD
[item_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_z_prices_extended_material_item_id] DEFAULT (''),
[bypass_flat_fee_exclusion] [bit] NOT NULL CONSTRAINT [DF__z_prices___bypas__21F50752] DEFAULT ((0))
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[of_selItemStyleGroup]'
GO

ALTER FUNCTION [dbo].[of_selItemStyleGroup]
(
 @customer_id varchar(50),
 @effective_date varchar(30),
 @application_id varchar(10),
 @product_id varchar(10),
 @item_number varchar(81),
 @spec_id int
)
returns int


/*
select * from pricesets where spec_id in (select spec_id from spec_mstr where builder_id = 'hha2009' and active = 1)

select dbo.of_selItemStyleGroup('GHH4545','07/24/2017','10','Y','YFRBS/CHO',4588)
select * from spec_items where spec_id = 4588 and product_id = 'Y'
select * from styles_groups_detail where customer_id = 'GHH4545' and group_id in (select item from spec_items where spec_id = 4588 and product_id = 'Y')


select dbo.of_selItemStyleGroup('LEA2414','7/13/2016','1','1','1ps648/00502', 3774)
this function selects an item_number's group
given the customer, effective date, application date and product id
select * from styles_groups_detail where  item = '1ps648/00502' and customer_id = 'LEA2414' 
select * from spec_items where spec_id = '3774'
*/
AS
BEGIN

 DECLARE @group_id INT;
 SET @group_id = NULL;
 DECLARE @style_id VARCHAR(50) = '';

IF @spec_id = 0 --changed from null to 0 5/16/2023 ADG
	 begin
		 --==================================
		 -- Check if the color is in a group
		 --==================================
		 SELECT TOP 1
		   @group_id = sgd.group_id
		 FROM
		  styles_groups_detail sgd WITH (NOLOCK)
		  JOIN styles_groups sg WITH (NOLOCK) ON sg.group_id = sgd.group_id
		  --JOIN spec_items si WITH (NOLOCK) ON si.item_type = 'group' 
				--AND si.item = sg.group_id_string  --Added Cast 20220613 CRP 
				--AND (si.spec_id = @spec_id OR @spec_id = 0)

		 WHERE
		  sg.application_id = @application_id
		  AND sg.product_id = @product_id
		  AND sgd.customer_id = @customer_id
		  AND sgd.item_type = 'color'
		  AND sgd.item = @item_number
		  AND sgd.effective_date <= @effective_date
		  AND (CAST(sgd.end_date AS DATE) >= CAST(@effective_date AS DATE) OR sgd.end_date IS NULL)
		 ORDER BY
		  effective_date DESC

		 IF @group_id IS NULL
		  BEGIN
		   --==========================================
		   -- Check if the color's style is in a group
		   --==========================================

		   SELECT @style_id = style_id FROM colors WITH (NOLOCK) WHERE part_no = @item_number

		   SELECT TOP 1
			 @group_id = sgd.group_id
		   FROM
			styles_groups_detail sgd WITH (NOLOCK)
			JOIN styles_groups sg WITH (NOLOCK) ON sg.group_id = sgd.group_id
			 --JOIN spec_items si WITH (NOLOCK) ON si.item_type = 'group' AND si.item = sg.group_id_string  --Added Cast 20220613 CRP 
				  --AND (si.spec_id = @spec_id OR @spec_id = 0)
		   WHERE
			sg.application_id = @application_id
			AND sg.product_id = @product_id
			and sgd.customer_id = @customer_id
			and sgd.item_type = 'style'
			and sgd.item = @style_id
			and sgd.effective_date <= @effective_date
			and (cast(sgd.end_date as date) >= cast(@effective_date as date) or sgd.end_date is null)
		   order by effective_date desc
		  end

		 if @group_id is null
		  begin
		   --===========================
		   -- Use @item_number as style
		   --===========================
		   select top 1
			 @group_id = sgd.group_id
		   from
			styles_groups_detail sgd with (nolock)
			join styles_groups sg with (nolock) on sg.group_id = sgd.group_id
			--join spec_items si with (nolock) on si.item_type = 'group' and si.item = sg.group_id_string  --Added Cast 20220613 CRP 
				-- AND (si.spec_id = @spec_id OR @spec_id = 0)
		   where
			sg.application_id = @application_id
			and sg.product_id = @product_id
			and sgd.customer_id = @customer_id
			and sgd.item_type = 'style'
			and sgd.item = @item_number
			and sgd.effective_date <= @effective_date
			and (cast(sgd.end_date as date) >= cast(@effective_date as date) or sgd.end_date is null)
		   order by effective_date desc
		  END
	 END
 ELSE
	begin
 		 --==================================
		 -- Check if the color is in a group
		 --==================================
		 SELECT TOP 1
		   @group_id = sgd.group_id
		 FROM
		  styles_groups_detail sgd WITH (NOLOCK)
		  JOIN styles_groups sg WITH (NOLOCK) ON sg.group_id = sgd.group_id
		  JOIN spec_items si WITH (NOLOCK) ON si.item_type = 'group' 
				AND si.item = sg.group_id_string  --Added Cast 20220613 CRP 
				AND (si.spec_id = @spec_id)

		 WHERE
		  sg.application_id = @application_id
		  AND sg.product_id = @product_id
		  AND sgd.customer_id = @customer_id
		  AND sgd.item_type = 'color'
		  AND sgd.item = @item_number
		  AND sgd.effective_date <= @effective_date
		  AND (CAST(sgd.end_date AS DATE) >= CAST(@effective_date AS DATE) OR sgd.end_date IS NULL)
		 ORDER BY
		  effective_date DESC

		 IF @group_id IS NULL
		  BEGIN
		   --==========================================
		   -- Check if the color's style is in a group
		   --==========================================
		   --DECLARE @style_id VARCHAR(50)
		   --SET @style_id = ''

		   SELECT @style_id = style_id FROM colors WITH (NOLOCK) WHERE part_no = @item_number

		   SELECT TOP 1
			 @group_id = sgd.group_id
		   FROM
			styles_groups_detail sgd WITH (NOLOCK)
			JOIN styles_groups sg WITH (NOLOCK) ON sg.group_id = sgd.group_id
			 JOIN spec_items si WITH (NOLOCK) ON si.item_type = 'group' AND si.item = sg.group_id_string  --Added Cast 20220613 CRP 
				  AND (si.spec_id = @spec_id)
		   WHERE
			sg.application_id = @application_id
			AND sg.product_id = @product_id
			and sgd.customer_id = @customer_id
			and sgd.item_type = 'style'
			and sgd.item = @style_id
			and sgd.effective_date <= @effective_date
			and (cast(sgd.end_date as date) >= cast(@effective_date as date) or sgd.end_date is null)
		   order by effective_date desc
		  end

		 if @group_id is null
		  begin
		   --===========================
		   -- Use @item_number as style
		   --===========================
		   select top 1
			 @group_id = sgd.group_id
		   from
			styles_groups_detail sgd with (nolock)
			join styles_groups sg with (nolock) on sg.group_id = sgd.group_id
			join spec_items si with (nolock) on si.item_type = 'group' and si.item = sg.group_id_string  --Added Cast 20220613 CRP 
				 AND (si.spec_id = @spec_id)
		   where
			sg.application_id = @application_id
			and sg.product_id = @product_id
			and sgd.customer_id = @customer_id
			and sgd.item_type = 'style'
			and sgd.item = @item_number
			and sgd.effective_date <= @effective_date
			and (cast(sgd.end_date as date) >= cast(@effective_date as date) or sgd.end_date is null)
		   order by effective_date desc
		  END
	end
 return @group_id
end
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[osp_selUnitPriceExtendedMaterial]'
GO

ALTER PROCEDURE [dbo].[osp_selUnitPriceExtendedMaterial]
    @spec_id INT,
    @effective_date DATETIME,
    @application_id VARCHAR(10),
    @product_id VARCHAR(10),
    @area_id VARCHAR(10),
    @sub_area_id VARCHAR(10),
    @plan_id VARCHAR(20),
    @build_id VARCHAR(50),
    @item_type VARCHAR(10),
    @item_id VARCHAR(50),
    @item VARCHAR(81),
    @uom VARCHAR(9),
    @precision INT = 2,
    @customer_id VARCHAR(15),
    @price DECIMAL(18, 6) OUTPUT,
    @price_type VARCHAR(10) OUTPUT,
    @retail_unit_price DECIMAL(18, 6) OUTPUT,
    @retail_percentage DECIMAL(18, 6) OUTPUT,
    @retail_percentage_type VARCHAR(20) OUTPUT,
    @error_msg VARCHAR(255) OUTPUT,
	@bypass_flat_fee_exclusion BIT OUTPUT
WITH RECOMPILE
AS


/*
    Procedure:	osp_selUnitPriceExtendedMaterial
    Author:		unknown ( adriang? )
    Date:		unknown
    Purpose:	Used by osp_selItemPrice and osp_selContractItemPrice to get unit_price for Extended Material
    Updates:	06.17.2025 - jenam - adding item_id & sub_area_id optional checks 
				09.24.2025 - SJC Added bypass_flat_fee_exclusion OUTPUT parameter 
				10.10.2025 - jenam/sjc/adg revert sub_area_id & fix item_id logic

    Usage:
    
osp_selUnitPriceExtendedMaterial '2358','8/17/2010','2','O','MBTH','PONY','','','MATERIAL','OG0TBR3/1','SqFt',2,'RYL1000',Null,Null,Null,Null,Null,Null  
select * from styles_groups_detail where customer_id = 'geh2007' and group_id = '4795'
select * from colors where style_id = '501'
select * from pricesets where spec_id = 7017
osp_selUnitPriceExtendedMaterial '3399','12/1/2013','1','3','bed2','none','163015','11303708','MATERIAL','3501/1','SqFt',2,'GEH2007',Null,Null,Null,Null,Null,Null    
osp_selUnitPriceExtendedMaterial_crp '7017','2023-09-25','10','Y','BTH2','CAB','417721','35678183','group','5187','Ea',2,'TMD2016',Null,Null,Null,Null,Null,Null    

*/

DECLARE @local_spec_id INT = @spec_id,
        @local_effective_date DATETIME = @effective_date,
        @local_application_id VARCHAR(10) = @application_id,
        @local_product_id VARCHAR(10) = @product_id,
        @local_area_id VARCHAR(10) = @area_id,
        @local_sub_area_id VARCHAR(10) = @sub_area_id,
        @local_plan_id VARCHAR(20) = @plan_id,
        @local_build_id VARCHAR(50) = @build_id,
        @local_item_type VARCHAR(10) = @item_type,
        @local_item_id VARCHAR(50) = @item_id,
        @local_item VARCHAR(81) = @item,
        @local_uom VARCHAR(9) = @uom,
        @local_precision INT = @precision,
        @local_customer_id VARCHAR(15) = @customer_id;

SET @price = NULL;
SET @price_type = '';
SET @error_msg = '';
SET @bypass_flat_fee_exclusion = 0;

DECLARE @pricing_uom VARCHAR(9);
SET @pricing_uom = '';

--=====================================================================    
-- Put all application/product/area/sub_area matches into a temp table    
--=====================================================================    
DECLARE @ext_prices TABLE
(
    plan_id VARCHAR(20),
	sub_area_id VARCHAR(10),
    build_id INT,
	item_id VARCHAR(50),
    price_type VARCHAR(10),
    price DECIMAL(18, 6),
    retail_unit_price DECIMAL(18, 6),
    retail_percentage DECIMAL(18, 6),
    retail_percentage_type VARCHAR(10),
    uom VARCHAR(9),
	bypass_flat_fee_exclusion BIT
);

INSERT INTO @ext_prices
SELECT plan_id,
       sub_area_id,
       build_id,
       item_id,
       price_type,
       price,
       retail_unit_price,
       retail_percentage,
       retail_percentage_type,
       uom,
	   bypass_flat_fee_exclusion
FROM prices_extended_material WITH (NOLOCK)
WHERE spec_id = @local_spec_id
      AND effective_date = @local_effective_date
      AND application_id = @local_application_id
      AND product_id = @local_product_id
      AND area_id = @local_area_id
      and sub_area_id = @local_sub_area_id    -- jenam/sjc/adg 10.10.25 reverted -> // jenam 6.17.2025 - removed for item_id & sub_area checks
      AND item_type = @local_item_type
      AND item = @local_item;

--SELECT '@ext_price' as name,* FROM @ext_prices

--==================================================    
-- Area pricing (There is no uom for 'area' prices)
---- 06.17.2025 - jenam - added item_id check
--==================================================    
IF EXISTS (SELECT 1 FROM @ext_prices WHERE price_type = 'area')
BEGIN
    SET @price_type = 'area';

    --===========
    --== BUILD ==
    --===========

    -- PLAN / BUILD / ITEM ID MATCH     
    SELECT @price = price,
           @retail_unit_price = retail_unit_price,
           @retail_percentage = retail_percentage,
           @retail_percentage_type = retail_percentage_type,
		   @bypass_flat_fee_exclusion = bypass_flat_fee_exclusion 
    FROM @ext_prices
    WHERE (plan_id = @local_plan_id OR @local_plan_id = '')
		  AND build_id = @local_build_id
          AND item_id = @local_item_id
          AND price_type = 'area';

    IF @price IS NULL
    BEGIN
        -- PLAN / BUILD / NO ITEM ID MATCH
        SELECT @price = price,
               @retail_unit_price = retail_unit_price,
               @retail_percentage = retail_percentage,
               @retail_percentage_type = retail_percentage_type,
			   @bypass_flat_fee_exclusion = bypass_flat_fee_exclusion
        FROM @ext_prices
        WHERE (plan_id = @local_plan_id OR @local_plan_id = '')
			  AND build_id = @local_build_id
              AND item_id = ''
              AND price_type = 'area';
    END;

    IF @price IS NOT NULL
    BEGIN
        SET @price = ROUND(@price, @local_precision);
        SET @retail_unit_price = ROUND(@retail_unit_price, @local_precision);
        SET @retail_percentage = ROUND(@retail_percentage, @local_precision);  
        RETURN;
    END;

    --==========
    --== PLAN ==
    --==========

    -- PLAN / NO BUILD / ITEM ID MATCH    
    SELECT @price = price,
           @retail_unit_price = retail_unit_price,
           @retail_percentage = retail_percentage,
           @retail_percentage_type = retail_percentage_type,
		   @bypass_flat_fee_exclusion = bypass_flat_fee_exclusion
    FROM @ext_prices
    WHERE plan_id = @local_plan_id
          AND build_id = ''
          AND item_id = @local_item_id
          AND price_type = 'area';

    IF @price IS NULL
    BEGIN
        -- PLAN / NO BUILD / NO ITEM ID MATCH    
        SELECT @price = price,
               @retail_unit_price = retail_unit_price,
               @retail_percentage = retail_percentage,
               @retail_percentage_type = retail_percentage_type,
		       @bypass_flat_fee_exclusion = bypass_flat_fee_exclusion
        FROM @ext_prices
        WHERE plan_id = @local_plan_id
              AND build_id = ''
              AND item_id = ''
              AND price_type = 'area';
    END;

    IF @price IS NOT NULL
    BEGIN
        SET @price = ROUND(@price, @local_precision);
        SET @retail_unit_price = ROUND(@retail_unit_price, @local_precision);
        SET @retail_percentage = ROUND(@retail_percentage, @local_precision);
        RETURN;
    END;

    --=============
    --== ITEM ID ==
    --=============

    -- NO PLAN / NO BUILD / ITEM ID MATCH    
    SELECT @price = price,
           @retail_unit_price = retail_unit_price,
           @retail_percentage = retail_percentage,
           @retail_percentage_type = retail_percentage_type,
		   @bypass_flat_fee_exclusion = bypass_flat_fee_exclusion
    FROM @ext_prices
    WHERE plan_id = ''
          AND build_id = ''
          AND item_id = @local_item_id
          AND price_type = 'area';

	IF @price IS NULL	-- added no item area pricing / jenam 10.10.25
    BEGIN
        -- NO PLAN / NO BUILD / NO ITEM ID MATCH    
		SELECT @price = price,
		       @retail_unit_price = retail_unit_price,
		       @retail_percentage = retail_percentage,
		       @retail_percentage_type = retail_percentage_type,
			   @bypass_flat_fee_exclusion = bypass_flat_fee_exclusion
		FROM @ext_prices
		WHERE plan_id = ''
		      AND build_id = ''
		      AND item_id = ''
		      AND price_type = 'area';
		END;

		IF @price IS NOT NULL
		BEGIN
			SET @price = ROUND(@price, @local_precision);
			SET @retail_unit_price = ROUND(@retail_unit_price, @local_precision);
			SET @retail_percentage = ROUND(@retail_percentage, @local_precision);
			RETURN;
		END;
END;

--==============
-- Unit pricing 
---- 06.17.2025 - jenam - added item_id & sub_area_id check
--==============

SET @price_type = 'unit';

--===========
--== BUILD ==
--===========

-- PLAN / BUILD / ITEM ID MATCH  
SELECT @price = price,
       @pricing_uom = uom,
       @retail_unit_price = retail_unit_price,
       @retail_percentage = retail_percentage,
       @retail_percentage_type = retail_percentage_type,
	   @bypass_flat_fee_exclusion = bypass_flat_fee_exclusion
FROM @ext_prices
WHERE (plan_id = @local_plan_id OR @local_plan_id = '')
	  AND build_id = @local_build_id
      AND item_id = @local_item_id
      AND price_type = 'unit';

IF @price IS NULL
BEGIN
    -- PLAN / BUILD / NO ITEM ID MATCH
    SELECT @price = price,
           @pricing_uom = uom,
           @retail_unit_price = retail_unit_price,
           @retail_percentage = retail_percentage,
           @retail_percentage_type = retail_percentage_type,
		   @bypass_flat_fee_exclusion = bypass_flat_fee_exclusion
    FROM @ext_prices
    WHERE (plan_id = @local_plan_id OR @local_plan_id = '')
		  AND build_id = @local_build_id
          AND item_id = ''
          AND price_type = 'unit';
END;

IF @price IS NOT NULL
BEGIN
    --removed due unit pricing in extended not converting decos 10/16/2012 ADG  
    --if @local_item_type = 'color'    
    --begin    
    SET @price
        = ROUND(
                   dbo.of_getConvertedPrice(
                                               @local_item_type,
                                               @local_item,
                                               @price,
                                               @pricing_uom,
                                               @local_uom,
                                               @local_product_id,
                                               @local_customer_id,
                                               @local_effective_date
                                           ),
                   @local_precision
               );
    IF @price IS NULL
    BEGIN
        SET @error_msg
            = 'The extended material price for the ' + @local_item_type + ' ''' + @local_item
              + ''' could not be converted to ''' + @local_uom + '''.';
        SET @retail_unit_price
            = ROUND(
                       dbo.of_getConvertedPrice(
                                                   @local_item_type,
                                                   @local_item,
                                                   @retail_unit_price,
                                                   @pricing_uom,
                                                   @local_uom,
                                                   @local_product_id,
                                                   @local_customer_id,
                                                   @local_effective_date
                                               ),
                       @local_precision
                   );
    END;
    IF @retail_unit_price IS NULL
        SET @error_msg
            = 'The extended material retail price for the ' + @local_item_type + ' ''' + @local_item
              + ''' could not be converted to ''' + @local_uom + '''.';
    --end    
    RETURN;
END;

--==========
--== PLAN ==
--==========

-- PLAN / NO BUILD / ITEM ID MATCH   

SELECT @price = price,
       @retail_unit_price = retail_unit_price,
       @pricing_uom = uom,
       @retail_percentage = retail_percentage,
       @retail_percentage_type = retail_percentage_type,
	   @bypass_flat_fee_exclusion = bypass_flat_fee_exclusion
FROM @ext_prices
WHERE plan_id = @local_plan_id
      AND build_id = ''
      AND item_id = @local_item_id
      AND price_type = 'unit';

IF @price IS NULL
BEGIN
    -- PLAN / NO BUILD / NO ITEM ID MATCH
    SELECT @price = price,
           @pricing_uom = uom,
           @retail_unit_price = retail_unit_price,
           @retail_percentage = retail_percentage,
           @retail_percentage_type = retail_percentage_type,
		   @bypass_flat_fee_exclusion = bypass_flat_fee_exclusion
    FROM @ext_prices
    WHERE plan_id = @local_plan_id
          AND build_id = ''
          AND item_id = ''
          AND price_type = 'unit';
END;

IF @price IS NOT NULL
BEGIN
    --removed due unit pricing in extended not converting decos 10/16/2012 ADG  
    --if @local_item_type = 'color'    
    --begin    
    SET @price
        = ROUND(
                   dbo.of_getConvertedPrice(
                                               @local_item_type,
                                               @local_item,
                                               @price,
                                               @pricing_uom,
                                               @local_uom,
                                               @local_product_id,
                                               @local_customer_id,
                                               @local_effective_date
                                           ),
                   @local_precision
               );
    IF @price IS NULL
    BEGIN
        SET @error_msg
            = 'The extended material price for the ' + @local_item_type + ' ''' + @local_item
              + ''' could not be converted to ''' + @local_uom + '''.';
        SET @retail_unit_price
            = ROUND(
                       dbo.of_getConvertedPrice(
                                                   @local_item_type,
                                                   @local_item,
                                                   @retail_unit_price,
                                                   @pricing_uom,
                                                   @local_uom,
                                                   @local_product_id,
                                                   @local_customer_id,
                                                   @local_effective_date
                                               ),
                       @local_precision
                   );
    END;
    IF @retail_unit_price IS NULL
        SET @error_msg
            = 'The extended material retail price for the ' + @local_item_type + ' ''' + @local_item
              + ''' could not be converted to ''' + @local_uom + '''.';
    --end    
    RETURN;
END;

--=============
--== ITEM ID ==
--=============

-- NO PLAN / NO BUILD / ITEM ID MATCH 

SELECT @price = price,
       @retail_unit_price = retail_unit_price,
       @pricing_uom = uom,
       @retail_percentage = retail_percentage,
       @retail_percentage_type = retail_percentage_type,
	   @bypass_flat_fee_exclusion = bypass_flat_fee_exclusion
FROM @ext_prices
WHERE plan_id = ''
      AND build_id = ''
      AND item_id = @local_item_id
      AND price_type = 'unit';

IF @price IS NULL
-- NO PLAN / NO BUILD / NO ITEM ID MATCH
BEGIN
    SELECT @price = price,
           @pricing_uom = uom,
           @retail_unit_price = retail_unit_price,
           @retail_percentage = retail_percentage,
           @retail_percentage_type = retail_percentage_type,
		   @bypass_flat_fee_exclusion = bypass_flat_fee_exclusion
    FROM @ext_prices
    WHERE plan_id = ''
          AND build_id = ''
          AND item_id = ''
          AND price_type = 'unit';
END;

IF @price IS NOT NULL
BEGIN
    --removed due unit pricing in extended not converting decos 10/16/2012 ADG  
    --if @local_item_type = 'color'    
    --begin    
    SET @price
        = ROUND(
                   dbo.of_getConvertedPrice(
                                               @local_item_type,
                                               @local_item,
                                               @price,
                                               @pricing_uom,
                                               @local_uom,
                                               @local_product_id,
                                               @local_customer_id,
                                               @local_effective_date
                                           ),
                   @local_precision
               );
    IF @price IS NULL
    BEGIN
        SET @error_msg
            = 'The extended material price for the ' + @local_item_type + ' ''' + @local_item
              + ''' could not be converted to ''' + @local_uom + '''.';
        SET @retail_unit_price
            = ROUND(
                       dbo.of_getConvertedPrice(
                                                   @local_item_type,
                                                   @local_item,
                                                   @retail_unit_price,
                                                   @pricing_uom,
                                                   @local_uom,
                                                   @local_product_id,
                                                   @local_customer_id,
                                                   @local_effective_date
                                               ),
                       @local_precision
                   );
    END;
    IF @retail_unit_price IS NULL
        SET @error_msg
            = 'The extended material retail price for the ' + @local_item_type + ' ''' + @local_item
              + ''' could not be converted to ''' + @local_uom + '''.';
    --end    
    RETURN;
END;
ELSE
BEGIN
    SET @price_type = '';
END;
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[osp_selUnitPriceExtendedLabor]'
GO

ALTER PROCEDURE [dbo].[osp_selUnitPriceExtendedLabor]
    @spec_id INT,
    @effective_date DATETIME,
    @application_id VARCHAR(10),
    @product_id VARCHAR(10),
    @area_id VARCHAR(10),
    @sub_area_id VARCHAR(10),
    @plan_id VARCHAR(20),
    @build_id VARCHAR(50),
	@item_id VARCHAR(50),
    @labor_code VARCHAR(10),
    @price DECIMAL(18, 6) OUTPUT,
    @price_type VARCHAR(10) OUTPUT,
    @retail_unit_price DECIMAL(18, 6) OUTPUT,
    @retail_percentage DECIMAL(18, 6) OUTPUT,
    @retail_percentage_type VARCHAR(20) OUTPUT,
    @error_msg VARCHAR(255) OUTPUT,
	@bypass_flat_fee_exclusion BIT OUTPUT
WITH RECOMPILE
AS

/*
	Procedure:	osp_selUnitPriceExtendedLabor
	Author:		unknown ( adriang? )
	Date:		unknown
	Purpose:	Used by osp_selItemPrice and osp_selContractItemPrice to get unit price for Extended Labor
	Updates:	06.17.2025 - jenam - added item_id and sub_area_id check
				09.24.2025 - SJC Added bypass_flat_fee_exclusion OUTPUT parameter
				10.10.2025 - JENAM/SJC/ADG revert sub_area_id & fix item_id logic

	Usage:
	
osp_selUnitPriceExtendedLabor 3235, '5/3/2013', '3','6','kit','bs',158811,10804850,'NLBRT',Null,Null, Null, NUll, Null, Null

*/

DECLARE @local_spec_id INT = @spec_id,
        @local_effective_date DATETIME = @effective_date,
        @local_application_id VARCHAR(10) = @application_id,
        @local_product_id VARCHAR(10) = @product_id,
        @local_area_id VARCHAR(10) = @area_id,
        @local_sub_area_id VARCHAR(10) = @sub_area_id,
        @local_plan_id VARCHAR(20) = @plan_id,
        @local_build_id VARCHAR(50) = @build_id,
		@local_item_id VARCHAR(50) = @item_id,
        @local_labor_code VARCHAR(10) = @labor_code;

SET @price = NULL;
SET @retail_unit_price = NULL;
SET @price_type = '';
SET @bypass_flat_fee_exclusion = 0

--=====================================================================    
-- Put all application/product/area/sub_area matches into a temp table    
--=====================================================================    
DECLARE @ext_prices TABLE
(
    plan_id INT,
	sub_area_id VARCHAR(10),
    build_id INT,
	item_id VARCHAR(50),
    price_type VARCHAR(10),
    price DECIMAL(18, 6),
    retail_unit_price DECIMAL(18, 6),
    retail_percentage DECIMAL(18, 6),
    retail_percentage_type VARCHAR(10),
	bypass_flat_fee_exclusion BIT
);

INSERT INTO @ext_prices
SELECT plan_id,
	   sub_area_id,
       build_id,
	   item_id,
       price_type,
       price,
       retail_unit_price,
       retail_percentage,
       retail_percentage_type,
	   bypass_flat_fee_exclusion
FROM prices_extended_labor WITH (NOLOCK)
WHERE spec_id = @local_spec_id
      AND effective_date = @local_effective_date
      AND application_id = @local_application_id
      AND product_id = @local_product_id
      AND area_id = @local_area_id
      AND sub_area_id = @local_sub_area_id	-- uncommenting 10.10.25 - jenam
      AND labor_code = @local_labor_code;

--==================================================    
-- Area pricing (There is no uom for 'area' prices)
---- 06.17.2025 - jenam - added item_id check
--==================================================    

IF EXISTS (SELECT plan_id FROM @ext_prices WHERE price_type = 'area')
BEGIN
    SET @price_type = 'area';

	--===========
    --== BUILD ==
    --===========

    -- PLAN / BUILD / ITEM ID MATCH    
    SELECT @price = price,
           @retail_unit_price = retail_unit_price,
           @retail_percentage = retail_percentage,
           @retail_percentage_type = retail_percentage_type,
		   @bypass_flat_fee_exclusion = bypass_flat_fee_exclusion
    FROM @ext_prices
    WHERE (plan_id = @local_plan_id OR @local_plan_id = '')
		  AND build_id = @local_build_id
          AND item_id = @local_item_id
          AND price_type = 'area';

	IF @price IS NULL
	BEGIN
		-- PLAN / BUILD / NO ITEM ID MATCH
		SELECT @price = price,
			   @retail_unit_price = retail_unit_price,
			   @retail_percentage = retail_percentage,
			   @retail_percentage_type = retail_percentage_type,
			   @bypass_flat_fee_exclusion = bypass_flat_fee_exclusion
		FROM @ext_prices
		WHERE (plan_id = @local_plan_id OR @local_plan_id = '')
			  AND build_id = @local_build_id
			  AND item_id = ''
			  AND price_type = 'area';
	end

    IF @price IS NOT NULL
    BEGIN
        RETURN;
    END;

	--==========
    --== PLAN ==
    --==========

    -- PLAN / NO BUILD / ITEM ID MATCH   
    SELECT @price = price,
           @retail_unit_price = retail_unit_price,
           @retail_percentage = retail_percentage,
           @retail_percentage_type = retail_percentage_type,
		   @bypass_flat_fee_exclusion = bypass_flat_fee_exclusion
    FROM @ext_prices
    WHERE plan_id = @local_plan_id
          AND build_id = ''
          AND item_id = @local_item_id
          AND price_type = 'area';

	IF @price IS NULL
	BEGIN
		-- PLAN / NO BUILD / NO ITEM ID MATCH   
		SELECT @price = price,
		       @retail_unit_price = retail_unit_price,
		       @retail_percentage = retail_percentage,
		       @retail_percentage_type = retail_percentage_type,
			   @bypass_flat_fee_exclusion = bypass_flat_fee_exclusion
		FROM @ext_prices
		WHERE plan_id = @local_plan_id
		      AND build_id = ''
		      AND item_id = ''
		      AND price_type = 'area';
	END

    IF @price IS NOT NULL
    BEGIN
        RETURN;
    END;
	
	--=============
    --== ITEM ID ==
    --=============

    -- NO PLAN / NO BUILD / ITEM ID MATCH    
    SELECT @price = price,
           @retail_unit_price = retail_unit_price,
           @retail_percentage = retail_percentage,
           @retail_percentage_type = retail_percentage_type,
		   @bypass_flat_fee_exclusion = bypass_flat_fee_exclusion
    FROM @ext_prices
    WHERE plan_id = ''
          AND build_id = ''
          AND item_id = @local_item_id
          AND price_type = 'area';

	IF @price IS NULL
	BEGIN
		-- NO PLAN / NO BUILD / NO ITEM ID MATCH   
		SELECT @price = price,
		       @retail_unit_price = retail_unit_price,
		       @retail_percentage = retail_percentage,
		       @retail_percentage_type = retail_percentage_type,
			   @bypass_flat_fee_exclusion = bypass_flat_fee_exclusion
		FROM @ext_prices
		WHERE plan_id = ''
		      AND build_id = ''
		      AND item_id = ''
		      AND price_type = 'area';
	END

    IF @price IS NOT NULL
    BEGIN
        RETURN;
    END;
END;

--==============    
-- Unit pricing
---- 06.17.2025 - jenam - added item_id & sub_area_id check
--==============    

SET @price_type = 'unit';

--===========
--== BUILD ==
--===========

-- PLAN / BUILD / ITEM ID MATCH   
SELECT @price = price,
       @retail_unit_price = retail_unit_price,
       @retail_percentage = retail_percentage,
       @retail_percentage_type = retail_percentage_type,
	   @bypass_flat_fee_exclusion = bypass_flat_fee_exclusion
FROM @ext_prices
WHERE (plan_id = @local_plan_id OR @local_plan_id = '')
	  AND build_id = @local_build_id
      AND item_id = @local_item_id
      AND price_type = 'unit';

IF @price IS NULL
BEGIN
	--	PLAN / BUILD / NO ITEM ID MATCH  
	SELECT @price = price,
		   @retail_unit_price = retail_unit_price,
		   @retail_percentage = retail_percentage,
		   @retail_percentage_type = retail_percentage_type,
		   @bypass_flat_fee_exclusion = bypass_flat_fee_exclusion
	FROM @ext_prices
	WHERE (plan_id = @local_plan_id OR @local_plan_id = '')
		  AND build_id = @local_build_id
          AND item_id = ''
		  AND price_type = 'unit';
END

IF @price IS NOT NULL
BEGIN
    RETURN;
END;

--==========
--== PLAN ==
--==========

-- PLAN / NO BUILD / ITEM ID MATCH  
SELECT @price = price,
       @retail_unit_price = retail_unit_price,
       @retail_percentage = retail_percentage,
       @retail_percentage_type = retail_percentage_type,
	   @bypass_flat_fee_exclusion = bypass_flat_fee_exclusion
FROM @ext_prices
WHERE plan_id = @local_plan_id
      AND build_id = ''
      AND item_id = @local_item_id
      AND price_type = 'unit';

IF @price IS NULL
BEGIN
	-- PLAN / NO BUILD / NO ITEM ID MATCH  
	SELECT @price = price,
		   @retail_unit_price = retail_unit_price,
		   @retail_percentage = retail_percentage,
		   @retail_percentage_type = retail_percentage_type,
		   @bypass_flat_fee_exclusion = bypass_flat_fee_exclusion
	FROM @ext_prices
	WHERE plan_id = @local_plan_id
		  AND build_id = ''
          AND item_id = ''
		  AND price_type = 'unit';
END

IF @price IS NOT NULL
BEGIN
    RETURN;
END;

--=============
--== ITEM ID ==
--=============

-- NO PLAN / NO BUILD / ITEM ID MATCH    
SELECT @price = price,
       @retail_unit_price = retail_unit_price,
       @retail_percentage = retail_percentage,
       @retail_percentage_type = retail_percentage_type,
	   @bypass_flat_fee_exclusion = bypass_flat_fee_exclusion
FROM @ext_prices
WHERE plan_id = ''
      AND build_id = ''
	  AND item_id = @local_item_id
      AND price_type = 'unit';

IF @price IS NULL
BEGIN
	-- NO PLAN / NO BUILD / NO ITEM ID MATCH    
	SELECT @price = price,
		   @retail_unit_price = retail_unit_price,
		   @retail_percentage = retail_percentage,
		   @retail_percentage_type = retail_percentage_type,
		   @bypass_flat_fee_exclusion = bypass_flat_fee_exclusion
	FROM @ext_prices
	WHERE plan_id = ''
		  AND build_id = ''
		  AND item_id = ''
		  AND price_type = 'unit';
END

IF @price IS NOT NULL
BEGIN
    RETURN;
END;

IF @price IS NULL
BEGIN
    SET @price_type = '';
END;
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[osp_selItemPrice]'
GO

ALTER PROCEDURE [dbo].[osp_selItemPrice]
    @effective_date DATETIME,
    @customer_id VARCHAR(15),
    @region_id VARCHAR(2),
    @application_id VARCHAR(10),
    @product_id VARCHAR(10),
    @area_id VARCHAR(10),
    @sub_area_id VARCHAR(10),
    @spec_id INT = 0,
    @plan_id VARCHAR(20) = '',
    @build_id VARCHAR(50) = '',
    @generic_item_type VARCHAR(20),
    @generic_item_id VARCHAR(50) = '',
    @item VARCHAR(81),
    @uom VARCHAR(9) = '',
    @item_price DECIMAL(18, 2) OUTPUT,
    @item_price_retail DECIMAL(18, 2) OUTPUT,
    @price_type VARCHAR(10) OUTPUT,
    @pricing_layer VARCHAR(20) OUTPUT,
    @retail_percentage DECIMAL(18, 2) OUTPUT,
    @retail_percentage_type VARCHAR(20) OUTPUT,
    @pattern_id VARCHAR(50) = '0',
    @entity_id VARCHAR(15) = '0',
    @bypass_flat_fee_exclusion BIT OUTPUT
WITH RECOMPILE
AS

/*
        Procedure:	osp_selItemPrice
        Author:		Everyone
        Date:		03/17/2016
        Purpose:	Select a price using the 4 layer pricing model in this order:
                    Extended (Spec Area), Default (Spec), Global (Customer), Public (Region)

        History:	RIG Removed the block on the Extended pricing search for cabinets
                    RW Increase the length of style_id to 25
                    - 06.17.2025 - jenam - adding generic_item_id into Extended Material/Labor unit price calls
                      09.24.2025 - SJC Added bypass_flat_fee_exclusion OUTPUT parameter
*/

SET NOCOUNT ON;
DECLARE @debug INT;
SET @debug = 0;

DECLARE @local_effective_date DATETIME = @effective_date,
        @local_customer_id VARCHAR(15) = @customer_id,
        @local_region_id VARCHAR(2) = @region_id,
        @local_application_id VARCHAR(10) = @application_id,
        @local_product_id VARCHAR(10) = @product_id,
        @local_area_id VARCHAR(10) = @area_id,
        @local_sub_area_id VARCHAR(10) = @sub_area_id,
        @local_spec_id INT = @spec_id,
        @local_plan_id VARCHAR(20) = @plan_id,
        @local_build_id VARCHAR(50) = @build_id,
        @local_generic_item_type VARCHAR(20) = @generic_item_type,
        @local_generic_item_id VARCHAR(50) = @generic_item_id,
        @local_item VARCHAR(81) = @item,
        @local_uom VARCHAR(9) = @uom,
        @local_pattern_id VARCHAR(50) = @pattern_id,
        @local_entity_id VARCHAR(15) = @entity_id;


DECLARE @custclas VARCHAR(15);
DECLARE @style_id VARCHAR(25);
DECLARE @style_ivt_uom VARCHAR(9);
DECLARE @group_id INT;
DECLARE @priceset_effective_date DATETIME;
DECLARE @error VARCHAR(255);
DECLARE @price_date DATETIME;

SET @item_price_retail = NULL;
--declare @retail_percentage decimal(18,2)
SET @retail_percentage = NULL;
--declare @retail_percentage_type varchar(20)
SET @retail_percentage_type = '';

SET @custclas = '';
SET @style_id = '';
SET @style_ivt_uom = '';
SET @group_id = 0;
SET @priceset_effective_date = '1/1/1900';
SET @error = '';
SET @price_date = '1/1/1900';
SET @bypass_flat_fee_exclusion = 0;


--=========================================
-- Get Entity Type - ie. Service or install
--=========================================
DECLARE @entity_type VARCHAR(20);
SET @entity_type = '';
IF @local_entity_id <> 0
BEGIN
    SELECT @entity_type = order_type
    FROM sales_orders WITH (NOLOCK)
    WHERE order_id = @local_entity_id;
END;

--====================
-- Get customer class
--====================
SELECT @custclas = class
FROM customers WITH (NOLOCK)
WHERE custnmbr = @local_customer_id;

--==============================
-- Get material/labor variables
--==============================
IF @local_generic_item_type = 'material'
BEGIN
    SELECT @local_product_id = c.product_id,
           @style_id = s.style_id,
           @style_ivt_uom = ISNULL(s.ivt_uom, '')
    FROM colors c WITH (NOLOCK)
        JOIN styles s WITH (NOLOCK)
            ON s.style_id = c.style_id
               AND s.product_id = c.product_id
    WHERE c.part_no = @local_item;

    -- Use the style's base_uom when uom is not specified

    IF LEN(@local_uom) = 0
        SET @local_uom = @style_ivt_uom;

    -- Get the group_id if this item is in a group
    EXEC @group_id = dbo.of_selItemStyleGroup @local_customer_id,
                                              @local_effective_date,
                                              @local_application_id,
                                              @local_product_id,
                                              @local_item,
                                              @local_spec_id;
END;

IF @local_generic_item_type = 'labor'
BEGIN
    DECLARE @lc_application_id VARCHAR(10);
    DECLARE @lc_product_id VARCHAR(10);

    IF LEN(@local_uom) = 0
        SELECT @local_uom = ISNULL(uom, @local_uom)
        FROM labor_codes WITH (NOLOCK)
        WHERE code = @local_item;

    /*  added 1/23/2008 - CRP */
    SELECT @lc_application_id = application_id,
           @lc_product_id = product_id
    FROM labor_codes WITH (NOLOCK)
    WHERE code = @local_item;

    /* Modified if statement on 1/23/2008 due to pricing not working for web requisition for NLBRTS which is used for tool and supply labor code - CRP - was if len(@local_product_id) = 0 and if len(@local_application_id) = 0 */

    IF LEN(@lc_application_id) > 0
    BEGIN
        SET @local_application_id = @lc_application_id;
    END;
    IF LEN(@lc_product_id) > 0
    BEGIN
        SET @local_product_id = @lc_product_id;
    END;

END;

--=========================================================
-- Get the latest priceset for the spec_id
-- This date is only used for default and extended pricing
--=========================================================
IF @local_spec_id <> 0
BEGIN
    SELECT TOP 1
           @priceset_effective_date = effective_date
    FROM pricesets WITH (NOLOCK)
    WHERE spec_id = @local_spec_id
          AND active = 1
          AND effective_date <= @local_effective_date
    ORDER BY effective_date DESC;
END;


IF @local_spec_id <> 0
   AND @local_area_id <> ''
   AND @local_sub_area_id <> ''
BEGIN
    ---------------------------------------------------------------------------------------------------------
    -- Extended pricing
    ---------------------------------------------------------------------------------------------------------
    SET @pricing_layer = 'extended';


    IF @local_generic_item_type = 'material'
    BEGIN

        --===================================================
        -- 1st pass - Attempt to find a price for this color
        --===================================================
        EXEC osp_selUnitPriceExtendedMaterial @local_spec_id,
                                              @priceset_effective_date,
                                              @local_application_id,
                                              @local_product_id,
                                              @local_area_id,
                                              @local_sub_area_id,
                                              @local_plan_id,
                                              @local_build_id,
                                              'color',
                                              @local_generic_item_id,
                                              @local_item,
                                              @local_uom,
                                              2,
                                              @local_customer_id,
                                              @item_price OUTPUT,
                                              @price_type OUTPUT,
                                              @item_price_retail OUTPUT,
                                              @retail_percentage OUTPUT,
                                              @retail_percentage_type OUTPUT,
                                              @error OUTPUT,
                                              @bypass_flat_fee_exclusion OUTPUT;

        IF @error <> ''
        BEGIN
            RAISERROR(@error, 16, 1);
            RETURN;
        END;

        --if @local_pattern_id = '0' or (@local_pattern_id <> '0' and @price_type <> 'area')
        --   begin
        --  if @entity_type <> 'service_order' or (@entity_type = 'service_order' and @price_type <> 'area')
        --   begin
        --    if not @item_price is null
        --     begin
        --      return
        --     end
        --   end
        --  else
        IF @local_pattern_id = '0'
           OR
           (
               @local_pattern_id <> '0'
               AND @local_generic_item_id = 'Field'
           )
           OR
           (
               @local_pattern_id <> 0
               AND @local_generic_item_id <> 'Field'
               AND @price_type <> 'area'
           )
        BEGIN
            IF @entity_type <> 'service_order'
               OR
               (
                   @entity_type = 'service_order'
                   AND @price_type <> 'area'
               )
            BEGIN
                IF NOT @item_price IS NULL
                BEGIN
                    RETURN;
                END;
            END;
            ELSE
            BEGIN
                SET @item_price = NULL;
                SET @price_type = '';
                SET @item_price_retail = NULL;
                SET @retail_percentage = NULL;
                SET @retail_percentage_type = '';
            END;
        END;
        ELSE
        BEGIN
            SET @item_price = NULL;
            SET @price_type = '';
            SET @item_price_retail = NULL;
            SET @retail_percentage = NULL;
            SET @retail_percentage_type = '';
        END;

        --===========================================================
        -- 2nd pass - Attempt to find a price for this color's style
        --===========================================================
        EXEC osp_selUnitPriceExtendedMaterial @local_spec_id,
                                              @priceset_effective_date,
                                              @local_application_id,
                                              @local_product_id,
                                              @local_area_id,
                                              @local_sub_area_id,
                                              @local_plan_id,
                                              @local_build_id,
                                              'style',
                                              @local_generic_item_id,
                                              @style_id,
                                              @local_uom,
                                              2,
                                              @local_customer_id,
                                              @item_price OUTPUT,
                                              @price_type OUTPUT,
                                              @item_price_retail OUTPUT,
                                              @retail_percentage OUTPUT,
                                              @retail_percentage_type OUTPUT,
                                              @error OUTPUT,
                                              @bypass_flat_fee_exclusion OUTPUT;

        IF @error <> ''
        BEGIN
            RAISERROR(@error, 16, 1);
            RETURN;
        END;

        --if @local_pattern_id = '0' or (@local_pattern_id <> '0' and @price_type <> 'area')
        IF @local_pattern_id = '0'
           OR
           (
               @local_pattern_id <> '0'
               AND @local_generic_item_id = 'Field'
           )
           OR
           (
               @local_pattern_id <> 0
               AND @local_generic_item_id <> 'Field'
               AND @price_type <> 'area'
           )
        BEGIN
            IF @entity_type <> 'service_order'
               OR
               (
                   @entity_type = 'service_order'
                   AND @price_type <> 'area'
               )
            BEGIN
                IF NOT @item_price IS NULL
                BEGIN
                    RETURN;
                END;
            END;
            ELSE
            BEGIN
                SET @item_price = NULL;
                SET @price_type = '';
                SET @item_price_retail = NULL;
                SET @retail_percentage = NULL;
                SET @retail_percentage_type = '';
            END;
        END;
        ELSE
        BEGIN
            SET @item_price = NULL;
            SET @price_type = '';
            SET @item_price_retail = NULL;
            SET @retail_percentage = NULL;
            SET @retail_percentage_type = '';
        END;

        --===========================================================
        -- 3rd pass - Attempt to find a price for this color's group
        --===========================================================
        EXEC osp_selUnitPriceExtendedMaterial @local_spec_id,
                                              @priceset_effective_date,
                                              @local_application_id,
                                              @local_product_id,
                                              @local_area_id,
                                              @local_sub_area_id,
                                              @local_plan_id,
                                              @local_build_id,
                                              'group',
                                              @local_generic_item_id,
                                              @group_id,
                                              @local_uom,
                                              2,
                                              @local_customer_id,
                                              @item_price OUTPUT,
                                              @price_type OUTPUT,
                                              @item_price_retail OUTPUT,
                                              @retail_percentage OUTPUT,
                                              @retail_percentage_type OUTPUT,
                                              @error OUTPUT,
                                              @bypass_flat_fee_exclusion OUTPUT;


        --print 'group'
        --print @group_id

        IF @error <> ''
        BEGIN
            RAISERROR(@error, 16, 1);
            RETURN;
        END;

        --if @local_pattern_id = '0' or (@local_pattern_id <> '0' and @price_type <> 'area')
        IF @local_pattern_id = '0'
           OR
           (
               @local_pattern_id <> '0'
               AND @local_generic_item_id = 'Field'
           )
           OR
           (
               @local_pattern_id <> 0
               AND @local_generic_item_id <> 'Field'
               AND @price_type <> 'area'
           )
        BEGIN
            IF @entity_type <> 'service_order'
               OR
               (
                   @entity_type = 'service_order'
                   AND @price_type <> 'area'
               )
            BEGIN
                IF NOT @item_price IS NULL
                BEGIN
                    RETURN;
                END;
            END;
            ELSE
            BEGIN
                SET @item_price = NULL;
                SET @price_type = '';
                SET @item_price_retail = NULL;
                SET @retail_percentage = NULL;
                SET @retail_percentage_type = '';
            END;
        END;
        ELSE
        BEGIN
            SET @item_price = NULL;
            SET @price_type = '';
            SET @item_price_retail = NULL;
            SET @retail_percentage = NULL;
            SET @retail_percentage_type = '';
        END;





        --===========================================================
        -- 4th pass - Attempt to find a price for option
        --===========================================================
        --print '4th pass' + @local_generic_item_id

        EXEC osp_selUnitPriceExtendedMaterial @local_spec_id,
                                              @priceset_effective_date,
                                              @local_application_id,
                                              @local_product_id,
                                              @local_area_id,
                                              @local_sub_area_id,
                                              @local_plan_id,
                                              @local_build_id,
                                              'option',
                                              @local_generic_item_id,
                                              @local_item,
                                              @local_uom,
                                              2,
                                              @local_customer_id,
                                              @item_price OUTPUT,
                                              @price_type OUTPUT,
                                              @item_price_retail OUTPUT,
                                              @retail_percentage OUTPUT,
                                              @retail_percentage_type OUTPUT,
                                              @error OUTPUT,
                                              @bypass_flat_fee_exclusion OUTPUT;


        IF @error <> ''
        BEGIN
            RAISERROR(@error, 16, 1);
            RETURN;
        END;

        --if @local_pattern_id = '0' or (@local_pattern_id <> '0' and @price_type <> 'area')
        IF @local_pattern_id = '0'
           OR
           (
               @local_pattern_id <> '0'
               AND @local_generic_item_id = 'Field'
           )
           OR
           (
               @local_pattern_id <> 0
               AND @local_generic_item_id <> 'Field'
               AND @price_type <> 'area'
           )
        BEGIN
            IF @entity_type <> 'service_order'
               OR
               (
                   @entity_type = 'service_order'
                   AND @price_type <> 'area'
               )
            BEGIN
                IF NOT @item_price IS NULL
                BEGIN
                    --print 'found 4th pass'
                    RETURN;
                END;
            END;
            ELSE
            BEGIN
                SET @item_price = NULL;
                SET @price_type = '';
                SET @item_price_retail = NULL;
                SET @retail_percentage = NULL;
                SET @retail_percentage_type = '';
            END;
        END;
        ELSE
        BEGIN
            SET @item_price = NULL;
            SET @price_type = '';
            SET @item_price_retail = NULL;
            SET @retail_percentage = NULL;
            SET @retail_percentage_type = '';
        END;







    END;

    IF @local_generic_item_type = 'labor'
    BEGIN
        EXEC osp_selUnitPriceExtendedLabor @local_spec_id,
                                           @priceset_effective_date,
                                           @local_application_id,
                                           @local_product_id,
                                           @local_area_id,
                                           @local_sub_area_id,
                                           @local_plan_id,
                                           @local_build_id,
                                           @local_generic_item_id,
                                           @local_item,
                                           @item_price OUTPUT,
                                           @price_type OUTPUT,
                                           @item_price_retail OUTPUT,
                                           @retail_percentage OUTPUT,
                                           @retail_percentage_type OUTPUT,
                                           @error OUTPUT,
                                           @bypass_flat_fee_exclusion OUTPUT;

        IF @error <> ''
        BEGIN
            RAISERROR(@error, 16, 1);
            RETURN;
        END;

        IF NOT @item_price IS NULL
        BEGIN
            RETURN;
        END;
    END;
END;

IF @local_spec_id <> 0
BEGIN
    ---------------------------------------------------------------------------------------------------------
    -- Default pricing
    ---------------------------------------------------------------------------------------------------------
    SET @pricing_layer = 'default';

    IF @local_generic_item_type = 'material'
    BEGIN
        --===================================================
        -- 1st pass - Attempt to find a price for this color
        --===================================================
        EXEC osp_selUnitPriceDefaultMaterial @local_spec_id,
                                             @priceset_effective_date,
                                             @local_application_id,
                                             @local_product_id,
                                             'color',
                                             @local_item,
                                             @local_uom,
                                             '',
                                             2,
                                             @item_price OUTPUT,
                                             @item_price_retail OUTPUT,
                                             @retail_percentage OUTPUT,
                                             @retail_percentage_type OUTPUT,
                                             @error OUTPUT,
                                             @price_type OUTPUT;

        IF @error <> ''
        BEGIN
            RAISERROR(@error, 16, 1);
            RETURN;
        END;

        IF NOT @item_price IS NULL
        BEGIN
            RETURN;
        END;

        --===========================================================
        -- 2nd pass - Attempt to find a price for this color's style
        --===========================================================

        EXEC osp_selUnitPriceDefaultMaterial @local_spec_id,
                                             @priceset_effective_date,
                                             @local_application_id,
                                             @local_product_id,
                                             'style',
                                             @style_id,
                                             @local_uom,
                                             '',
                                             2,
                                             @item_price OUTPUT,
                                             @item_price_retail OUTPUT,
                                             @retail_percentage OUTPUT,
                                             @retail_percentage_type OUTPUT,
                                             @error OUTPUT,
                                             @price_type OUTPUT;


        IF @error <> ''
        BEGIN
            RAISERROR(@error, 16, 1);
            RETURN;
        END;

        IF NOT @item_price IS NULL
        BEGIN
            RETURN;
        END;

        --===========================================================
        -- 3rd pass - Attempt to find a price for this color's group
        --===========================================================
        EXEC osp_selUnitPriceDefaultMaterial @local_spec_id,
                                             @priceset_effective_date,
                                             @local_application_id,
                                             @local_product_id,
                                             'group',
                                             @group_id,
                                             @local_uom,
                                             '',
                                             2,
                                             @item_price OUTPUT,
                                             @item_price_retail OUTPUT,
                                             @retail_percentage OUTPUT,
                                             @retail_percentage_type OUTPUT,
                                             @error OUTPUT,
                                             @price_type OUTPUT;


        IF @error <> ''
        BEGIN
            RAISERROR(@error, 16, 1);
            RETURN;
        END;

        IF NOT @item_price IS NULL
        BEGIN
            RETURN;
        END;
    END;


    --===========================================================
    -- 4th pass - Attempt to find a price for option
    --===========================================================

    EXEC osp_selUnitPriceDefaultMaterial @local_spec_id,
                                         @priceset_effective_date,
                                         @local_application_id,
                                         @local_product_id,
                                         'option',
                                         @local_item,
                                         @local_uom,
                                         '',
                                         2,
                                         @item_price OUTPUT,
                                         @item_price_retail OUTPUT,
                                         @retail_percentage OUTPUT,
                                         @retail_percentage_type OUTPUT,
                                         @error OUTPUT,
                                         @price_type OUTPUT;

    IF @error <> ''
    BEGIN
        RAISERROR(@error, 16, 1);
        RETURN;
    END;

    IF NOT @item_price IS NULL
    BEGIN
        RETURN;
    END;



    IF @local_generic_item_type = 'labor'
    BEGIN
        EXEC osp_selUnitPriceDefaultLabor @local_spec_id,
                                          @priceset_effective_date,
                                          @local_application_id,
                                          @local_product_id,
                                          @local_item,
                                          @local_uom,
                                          '',
                                          2,
                                          @item_price OUTPUT,
                                          @item_price_retail OUTPUT,
                                          @retail_percentage OUTPUT,
                                          @retail_percentage_type OUTPUT,
                                          @error OUTPUT;

        IF @error <> ''
        BEGIN
            RAISERROR(@error, 16, 1);
            RETURN;
        END;

        IF NOT @item_price IS NULL
        BEGIN
            RETURN;
        END;
    END;
END;

---------------------------------------------------------------------------------------------------------
-- Global pricing
---------------------------------------------------------------------------------------------------------
SET @pricing_layer = 'global';

IF @local_generic_item_type = 'material'
BEGIN
    --===================================================
    -- 1st pass - Attempt to find a price for this color
    --===================================================
    EXEC osp_selUnitPriceGlobalMaterial @local_effective_date,
                                        @local_customer_id,
                                        @local_application_id,
                                        @local_product_id,
                                        'color',
                                        @local_item,
                                        @local_uom,
                                        '',
                                        2,
                                        @item_price OUTPUT,
                                        @item_price_retail OUTPUT,
                                        @retail_percentage OUTPUT,
                                        @retail_percentage_type OUTPUT,
                                        @error OUTPUT,
                                        @price_date OUTPUT,
                                        '',
                                        @price_type OUTPUT;

    IF @error <> ''
    BEGIN
        RAISERROR(@error, 16, 1);
        RETURN;
    END;

    SELECT 1 AS priority,
           @item_price AS price,
           @item_price_retail AS retail_price,
           @price_date AS price_date,
           @retail_percentage AS retail_percentage,
           @retail_percentage_type AS retail_percentage_type
    INTO #global_price_matches;

    --===========================================================
    -- 2nd pass - Attempt to find a price for this color's style
    --===========================================================
    EXEC osp_selUnitPriceGlobalMaterial @local_effective_date,
                                        @local_customer_id,
                                        @local_application_id,
                                        @local_product_id,
                                        'style',
                                        @style_id,
                                        @local_uom,
                                        '',
                                        2,
                                        @item_price OUTPUT,
                                        @item_price_retail OUTPUT,
                                        @retail_percentage OUTPUT,
                                        @retail_percentage_type OUTPUT,
                                        @error OUTPUT,
                                        @price_date OUTPUT;

    IF @error <> ''
    BEGIN
        RAISERROR(@error, 16, 1);
        RETURN;
    END;

    INSERT INTO #global_price_matches
    SELECT 2 AS priority,
           @item_price AS price,
           @item_price_retail AS retail_price,
           @price_date AS price_date,
           @retail_percentage AS retail_percentage,
           @retail_percentage_type AS retail_percentage_type;


    --===========================================================
    -- 3rd pass - Attempt to find a price for this color's group
    --===========================================================
    EXEC osp_selUnitPriceGlobalMaterial @local_effective_date,
                                        @local_customer_id,
                                        @local_application_id,
                                        @local_product_id,
                                        'group',
                                        @group_id,
                                        @local_uom,
                                        '',
                                        2,
                                        @item_price OUTPUT,
                                        @item_price_retail OUTPUT,
                                        @retail_percentage OUTPUT,
                                        @retail_percentage_type OUTPUT,
                                        @error OUTPUT,
                                        @price_date OUTPUT,
                                        '',
                                        @price_type OUTPUT;

    IF @error <> ''
    BEGIN
        RAISERROR(@error, 16, 1);
        RETURN;
    END;

    INSERT INTO #global_price_matches
    SELECT 3 AS priority,
           @item_price AS price,
           @item_price_retail AS retail_price,
           @price_date AS price_date,
           @retail_percentage AS retail_percentage,
           @retail_percentage_type AS retail_percentage_type;

    --===========================================================
    -- 4th pass - Attempt to find a price for option
    --===========================================================
    EXEC osp_selUnitPriceGlobalMaterial @local_effective_date,
                                        @local_customer_id,
                                        @local_application_id,
                                        @local_product_id,
                                        'option',
                                        @local_item,
                                        @local_uom,
                                        '',
                                        2,
                                        @item_price OUTPUT,
                                        @item_price_retail OUTPUT,
                                        @retail_percentage OUTPUT,
                                        @retail_percentage_type OUTPUT,
                                        @error OUTPUT,
                                        @price_date OUTPUT,
                                        @local_item,
                                        @price_type OUTPUT;

    IF @error <> ''
    BEGIN
        RAISERROR(@error, 16, 1);
        RETURN;
    END;

    INSERT INTO #global_price_matches
    SELECT 3 AS priority,
           @item_price AS price,
           @item_price_retail AS retail_price,
           @price_date AS price_date,
           @retail_percentage AS retail_percentage,
           @retail_percentage_type AS retail_percentage_type;
    SET @item_price = NULL;


    IF @debug = 1
    BEGIN
        SELECT *
        FROM #global_price_matches;
    END;

    SELECT TOP 1
           @item_price = price,
           @item_price_retail = retail_price,
           @retail_percentage = retail_percentage,
           @retail_percentage_type = retail_percentage_type
    FROM #global_price_matches
    WHERE price IS NOT NULL
    ORDER BY price_date DESC,
             priority ASC;
    DROP TABLE #global_price_matches;

    IF NOT @item_price IS NULL
    BEGIN
        RETURN;
    END;
END;

IF @local_generic_item_type = 'labor'
BEGIN
    EXEC osp_selUnitPriceGlobalLabor @local_effective_date,
                                     @local_customer_id,
                                     @local_application_id,
                                     @local_product_id,
                                     @local_item,
                                     @local_uom,
                                     '',
                                     2,
                                     @item_price OUTPUT,
                                     @item_price_retail OUTPUT,
                                     @retail_percentage OUTPUT,
                                     @retail_percentage_type OUTPUT,
                                     @error OUTPUT;

    IF @error <> ''
    BEGIN
        RAISERROR(@error, 16, 1);
        RETURN;
    END;

    IF NOT @item_price IS NULL
    BEGIN
        RETURN;
    END;
END;


---------------------------------------------------------------------------------------------------------
-- Public pricing
---------------------------------------------------------------------------------------------------------
SET @pricing_layer = 'public';

IF @local_generic_item_type = 'material'
BEGIN
    --===================================================
    -- 1st pass - Attempt to find a price for this color
    --===================================================
    EXEC osp_selUnitPricePublicMaterial @local_effective_date,
                                        @local_region_id,
                                        @custclas,
                                        @local_application_id,
                                        @local_product_id,
                                        'color',
                                        @local_item,
                                        @local_uom,
                                        '',
                                        2,
                                        @item_price OUTPUT,
                                        @error OUTPUT,
                                        @price_date OUTPUT,
                                        @price_type OUTPUT;

    IF @error <> ''
    BEGIN
        RAISERROR(@error, 16, 1);
        RETURN;
    END;

    SELECT 1 AS priority,
           @item_price AS price,
           @price_date AS price_date
    INTO #public_price_matches;

    --===========================================================
    -- 2nd pass - Attempt to find a price for this color's style
    --===========================================================
    EXEC osp_selUnitPricePublicMaterial @local_effective_date,
                                        @local_region_id,
                                        @custclas,
                                        @local_application_id,
                                        @local_product_id,
                                        'style',
                                        @style_id,
                                        @local_uom,
                                        '',
                                        2,
                                        @item_price OUTPUT,
                                        @error OUTPUT,
                                        @price_date OUTPUT,
                                        @price_type OUTPUT;

    IF @error <> ''
    BEGIN
        RAISERROR(@error, 16, 1);
        RETURN;
    END;

    INSERT INTO #public_price_matches
    SELECT 2 AS priority,
           @item_price AS price,
           @price_date AS price_date;


    --===========================================================
    -- 3rd pass - Attempt to find a price for this option
    --===========================================================
    EXEC osp_selUnitPricePublicMaterial @local_effective_date,
                                        @local_region_id,
                                        @custclas,
                                        @local_application_id,
                                        @local_product_id,
                                        'option',
                                        @local_item,
                                        @local_uom,
                                        '',
                                        2,
                                        @item_price OUTPUT,
                                        @error OUTPUT,
                                        @price_date OUTPUT,
                                        @price_type OUTPUT;

    IF @error <> ''
    BEGIN
        RAISERROR(@error, 16, 1);
        RETURN;
    END;

    INSERT INTO #public_price_matches
    SELECT 2 AS priority,
           @item_price AS price,
           @price_date AS price_date;
    SET @item_price = NULL;
    SET @item_price_retail = NULL;

    SELECT TOP 1
           @item_price = price,
           @item_price_retail = price --per nick retail price equals builder price in public layer - CP
    FROM #public_price_matches
    WHERE price IS NOT NULL
    ORDER BY price_date DESC,
             priority ASC;

    DROP TABLE #public_price_matches;

    IF NOT @item_price IS NULL
    BEGIN
        RETURN;
    END;
END;


IF @local_generic_item_type = 'labor'
BEGIN
    SET @item_price_retail = NULL;

    EXEC osp_selUnitPricePublicLabor @local_effective_date,
                                     @local_region_id,
                                     @custclas,
                                     @local_application_id,
                                     @local_product_id,
                                     @local_item,
                                     @local_uom,
                                     '',
                                     2,
                                     @item_price OUTPUT,
                                     @error OUTPUT;

    IF @error <> ''
    BEGIN
        RAISERROR(@error, 16, 1);
        RETURN;
    END;

    IF NOT @item_price IS NULL
    BEGIN
        SET @item_price_retail = @item_price; --per nick retail price equals builder price in public layer - CP
        RETURN;
    END;
END;

SET @pricing_layer = '';
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[esp_selItemPrice]'
GO

ALTER procedure [dbo].[esp_selItemPrice]
@effective_date datetime,
@customer_id varchar(15),
--@region_id varchar(2),
@application_id varchar(10),
@product_id varchar(10),
@area_id varchar(10),
@sub_area_id varchar(10),
@spec_id int = 0,
@plan_id varchar(20) = '',
@build_id varchar(50) = '',
@generic_item_type varchar(20),
@generic_item_id varchar(50) = '',
@item varchar(81),
@uom varchar(9) = '',
@pattern_id varchar(50) = '0',
@item_price decimal(18,2) output,
@item_price_retail decimal(18,2) output,
@price_type varchar(10) output,
@pricing_layer varchar(200) output,

--added 11-12-12 ADG needed for new VeoSolutions cost plus margin system
@retail_percentage decimal(18,2) output,
@retail_percentage_type varchar(20) output,
--

@security_token varchar(36) = null,
@suppress_errors bit = 0,

-- jenam/sjc 12/8/2025 added
@bypass_flat_fee_exclusion BIT OUTPUT

as

DECLARE @entity_id VARCHAR(15)
SET @entity_id = '0'

declare @customer_name varchar(75)
	, @region_id varchar(10)

select
	@customer_name = customer_name
	, @region_id = region_id
from
	customers with (nolock)
where
	custnmbr = @customer_id

if (@customer_name is null)
begin
	raiserror('Customer with id "%s" does not exist.', 16, 1, @customer_id)
	return
end

if (ISNULL(@region_id, '') = '')
begin
	raiserror('No customer region for "%s".', 16, 1, @customer_name)
	return
end

exec osp_selItemPrice @effective_date,@customer_id,@region_id,@application_id,@product_id,@area_id,@sub_area_id,@spec_id,@plan_id,@build_id,
					  @generic_item_type,@generic_item_id,@item,@uom,@item_price output,@item_price_retail output,@price_type output,
					  @pricing_layer output,@retail_percentage output,@retail_percentage_type output,@pattern_id, @entity_id, @bypass_flat_fee_exclusion OUTPUT

-- added check for nulls causing breaks in concierge.  6/16/2011 ADG
if (@pricing_layer is null)
	set @pricing_layer = ''

if (@price_type is null)
	set @price_type = ''	
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[vs_selItemPrice]'
GO

ALTER procedure [dbo].[vs_selItemPrice]  
  
@effective_date datetime,  
@customer_id varchar(15),   
--@region_id varchar(2),   
@application_id varchar(10),   
@product_id varchar(10),  
@area_id varchar(10),  
@sub_area_id varchar(10),  
@spec_id int = 0,  
@plan_id varchar(20) = '',  
@build_id varchar(50) = '',  
@generic_item_type varchar(20),  
@generic_item_id varchar(50) = '', 
@item varchar(81),   
@uom varchar(9) = '',  
@pattern_id varchar(50) = '0',                        
@security_token varchar(36) = null,
@suppress_errors bit = 0
  
as  

-- jenam/sjc 12/8/2025 added bypass_flat_fee_exclusion

declare @item_price decimal(18,2)   
declare @item_price_retail decimal(18,2)  
declare @price_type varchar(10) 
declare @pricing_layer varchar(200)
declare @retail_percentage decimal(18,2)                          
declare @retail_percentage_type varchar(20)                           
DECLARE @bypass_flat_fee_exclusion bit

exec esp_selItemPrice @effective_date,@customer_id,@application_id,@product_id,@area_id,@sub_area_id,@spec_id,@plan_id,@build_id,
					  @generic_item_type,@generic_item_id,@item,@uom,@pattern_id,@item_price output,@item_price_retail output,
					  @price_type output,@pricing_layer output,@retail_percentage output,@retail_percentage_type output,@security_token, @suppress_errors,
					  @bypass_flat_fee_exclusion OUTPUT	
					  
					  


select 
	@item_price as item_price,  
	@item_price_retail as item_price_retail,  
	@price_type as price_type,  
	@pricing_layer as pricing_layer,
	isnull(@retail_percentage,1) as retail_percentage,
	isnull(@retail_percentage_type,'') as retail_percentage_type,
	@bypass_flat_fee_exclusion AS bypass_flat_fee_exclusion
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[prices_extended_labor]'
GO
ALTER TABLE [dbo].[prices_extended_labor] ADD CONSTRAINT [FK_prices_extended_labor_areas] FOREIGN KEY ([area_id]) REFERENCES [dbo].[areas] ([area_id])
GO
ALTER TABLE [dbo].[prices_extended_labor] ADD CONSTRAINT [FK_prices_extended_labor_sub_areas] FOREIGN KEY ([sub_area_id]) REFERENCES [dbo].[sub_areas] ([sub_area_id]) ON UPDATE CASCADE
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[prices_extended_material]'
GO
ALTER TABLE [dbo].[prices_extended_material] ADD CONSTRAINT [FK_prices_extended_material_areas] FOREIGN KEY ([area_id]) REFERENCES [dbo].[areas] ([area_id])
GO
ALTER TABLE [dbo].[prices_extended_material] ADD CONSTRAINT [FK_prices_extended_material_sub_areas] FOREIGN KEY ([sub_area_id]) REFERENCES [dbo].[sub_areas] ([sub_area_id])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
COMMIT TRANSACTION
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
-- This statement writes to the SQL Server Log so SQL Monitor can show this deployment.
IF HAS_PERMS_BY_NAME(N'sys.xp_logevent', N'OBJECT', N'EXECUTE') = 1
BEGIN
    DECLARE @databaseName AS nvarchar(2048), @eventMessage AS nvarchar(2048)
    SET @databaseName = REPLACE(REPLACE(DB_NAME(), N'\', N'\\'), N'"', N'\"')
    SET @eventMessage = N'Redgate SQL Compare: { "deployment": { "description": "Redgate SQL Compare deployed to ' + @databaseName + N'", "database": "' + @databaseName + N'" }}'
    EXECUTE sys.xp_logevent 55000, @eventMessage
END
GO
DECLARE @Success AS BIT
SET @Success = 1
SET NOEXEC OFF
IF (@Success = 1) PRINT 'The database update succeeded'
ELSE BEGIN
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	PRINT 'The database update failed'
END
GO
