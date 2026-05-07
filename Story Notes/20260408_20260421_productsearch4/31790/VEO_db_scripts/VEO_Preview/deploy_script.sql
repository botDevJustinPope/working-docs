/*
Run this script on:

        dev-sql.veodesignstudio.com.VEO_PREVIEW    -  This database will be modified

to synchronize it with:

        dev-sql.veodesignstudio.com.VEO_QA

You are recommended to back up your database before running this script

Script created by SQL Compare version 15.4.1.27450 from Red Gate Software Ltd at 4/21/2026 3:24:50 PM

*/
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
PRINT N'Dropping index [AK2RM00101] from [dbo].[RM00101]'
GO
DROP INDEX [AK2RM00101] ON [dbo].[RM00101]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping index [ix_colors_barcode_id] from [dbo].[colors]'
GO
DROP INDEX [ix_colors_barcode_id] ON [dbo].[colors]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping index [IX_colors_1] from [dbo].[colors]'
GO
DROP INDEX [IX_colors_1] ON [dbo].[colors]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping index [IX_colors_part_no] from [dbo].[colors]'
GO
DROP INDEX [IX_colors_part_no] ON [dbo].[colors]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping index [IX_colors_2] from [dbo].[colors]'
GO
DROP INDEX [IX_colors_2] ON [dbo].[colors]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping index [IX_colors] from [dbo].[colors]'
GO
DROP INDEX [IX_colors] ON [dbo].[colors]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping index [IX_prices_global_material_customer_id_effective_date_application_id_item_type_item_includes] from [dbo].[prices_global_material]'
GO
DROP INDEX [IX_prices_global_material_customer_id_effective_date_application_id_item_type_item_includes] ON [dbo].[prices_global_material]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[RM00101]'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
ALTER TABLE [dbo].[RM00101] ALTER COLUMN [DEX_ROW_ID] ADD NOT FOR REPLICATION
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating index [AK2RM00101] on [dbo].[RM00101]'
GO
CREATE UNIQUE NONCLUSTERED INDEX [AK2RM00101] ON [dbo].[RM00101] ([CUSTNAME], [DEX_ROW_ID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[labor_codes]'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
ALTER TABLE [dbo].[labor_codes] ADD
[post_install_service] [bit] NOT NULL CONSTRAINT [DF_labor_codes_post_install_service] DEFAULT ((0))
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[products]'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
ALTER TABLE [dbo].[products] ADD
[convert_quote_material_bill_uoms] [bit] NOT NULL CONSTRAINT [DF_products_convert_quote_material_bill_uoms] DEFAULT ((1)),
[convert_quote_material_alloc_uoms] [bit] NOT NULL CONSTRAINT [DF_products_convert_quote_material_alloc_uoms] DEFAULT ((1)),
[convert_quote_labor_bill_uoms] [bit] NOT NULL CONSTRAINT [DF_products_convert_quote_labor_bill_uoms] DEFAULT ((1)),
[labor_lesser_of_bill_alloc_qty] [bit] NOT NULL CONSTRAINT [DF_products_labor_lesser_of_bill_alloc_qty] DEFAULT ((0)),
[preserve_source_credits] [bit] NOT NULL CONSTRAINT [DF_products_preserve_source_credits] DEFAULT ((0))
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[customers]'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
ALTER TABLE [dbo].[customers] ADD
[tax_liable] [bit] NOT NULL CONSTRAINT [DF_customers_tax_liable] DEFAULT ((0)),
[tax_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[colors]'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
ALTER TABLE [dbo].[colors] ADD
[replacement_part_no] [varchar] (31) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding constraints to [dbo].[colors]'
GO
ALTER TABLE [dbo].[colors] ADD CONSTRAINT [DF_colors_global_product_id] DEFAULT (newid()) FOR [global_product_id]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating index [IX_colors_barcode_id_Includes] on [dbo].[colors]'
GO
CREATE NONCLUSTERED INDEX [IX_colors_barcode_id_Includes] ON [dbo].[colors] ([barcode_id]) INCLUDE ([part_no])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating index [ix_colors_global_product_id] on [dbo].[colors]'
GO
CREATE NONCLUSTERED INDEX [ix_colors_global_product_id] ON [dbo].[colors] ([global_product_id])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating index [IX_colors_modified_date] on [dbo].[colors]'
GO
CREATE NONCLUSTERED INDEX [IX_colors_modified_date] ON [dbo].[colors] ([modified_date])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating index [IX_colors_name] on [dbo].[colors]'
GO
CREATE NONCLUSTERED INDEX [IX_colors_name] ON [dbo].[colors] ([name])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating index [IX_colors_part_no_include] on [dbo].[colors]'
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_colors_part_no_include] ON [dbo].[colors] ([part_no]) INCLUDE ([name])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating index [IX_colors_product_id_stocking_code_includes] on [dbo].[colors]'
GO
CREATE NONCLUSTERED INDEX [IX_colors_product_id_stocking_code_includes] ON [dbo].[colors] ([product_id], [stocking_code]) INCLUDE ([part_no], [style_id], [color_id], [name])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating index [colors_product_id_style_id_default_related_item_includes] on [dbo].[colors]'
GO
CREATE NONCLUSTERED INDEX [colors_product_id_style_id_default_related_item_includes] ON [dbo].[colors] ([product_id], [style_id], [default_related_item]) INCLUDE ([part_no])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating index [IX_colors_stocking_code] on [dbo].[colors]'
GO
CREATE NONCLUSTERED INDEX [IX_colors_stocking_code] ON [dbo].[colors] ([stocking_code])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating index [IX_colors_style_id] on [dbo].[colors]'
GO
CREATE NONCLUSTERED INDEX [IX_colors_style_id] ON [dbo].[colors] ([style_id])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[osp_selUnitPricePublicMaterial]'
GO
ALTER procedure [dbo].[osp_selUnitPricePublicMaterial]
	(
		@effective_date datetime,
		@region_id varchar(2),
		@custclas varchar(25),
		@application_id varchar(10),
		@product_id varchar(10),
		@item_type varchar(10),
		@item varchar(81),
		@uom varchar(20),
		@mode varchar(25),
		@precision INT = 2,
		@price DECIMAL(18,2) OUTPUT,
		@error_msg VARCHAR(255) OUTPUT,
		@price_date DATETIME = '1/1/1900' OUTPUT,
		@price_type VARCHAR(10) = '' OUTPUT  
	)
WITH RECOMPILE
AS

--===================================================================
-- This procedure returns the unit price from prices_public_material
-- in terms of the desired unit of measure.
--===================================================================

/*
select dbo.of_uomMultiplier('6', '754', '', 'LinFt', 'LinFt', 6)

declare @price decimal(18,6)
declare @error varchar(255)
exec osp_selUnitPricePublicMaterial '01','TRACT - HOUSTON','3','6','style','754','LinFt','', 2, @price output, @error output
print @price
print @error

print dbo.of_unitPricePublicMaterial('01','TRACT - HOUSTON','3','6','755','','Each','',2)
print 1.25 * 9
*/

DECLARE
@local_effective_date DATETIME = @effective_date,
@local_region_id varchar(2) = @region_id,
@local_custclas varchar(25) = @custclas,
@local_application_id varchar(10) = @application_id,
@local_product_id varchar(10) = @product_id,
@local_item_type varchar(10) = @item_type,
@local_item varchar(81) = @item,
@local_uom varchar(20) = @uom,
@local_mode varchar(25) = @mode,
@local_precision INT = @precision

DECLARE @multiplier decimal(18,6)
declare @routine varchar(50)
declare @table_uom varchar(50)

set @price = null
set @error_msg = ''
set @multiplier = null
set @routine = 'osp_selUnitPricePublicMaterial'

--===========================
-- Get a price for the color
--===========================
if @local_item_type = 'color'
	begin
		declare @local_item_product varchar(10)
		declare @local_item_style varchar(20)
		declare @local_item_color varchar(50)
		
		select
			@local_item_product = product_id,
			@local_item_style = style_id,
			@local_item_color = color_id
		from
			colors with (nolock)
		where
			part_no = @local_item
	
		select top 1
			@price = pp.price,
			@multiplier = dbo.of_uomMultiplier(@local_item_product, @local_item_style, @local_item_color, pp.uom, @local_uom, 6),
			@table_uom = pp.uom,
			@price_date = pp.effective_date
		from 
			prices_public_material pp with (nolock)
		where 
			pp.region_id = @local_region_id and
			pp.custclas = @local_custclas and
			pp.application_id = @local_application_id and
			pp.product_id = @local_product_id and
			pp.item_type = @local_item_type and
			pp.item = @local_item and
			pp.effective_date <= @local_effective_date
			AND (pp.end_date >= @local_effective_date OR pp.end_date IS NULL)
		order by
			pp.effective_date desc

		if @price is null
			return 0

		if @multiplier is null --(bad uom: abort)
			begin
				set @error_msg = 'The public price for the ' + @local_item_type + ' ''' + @local_item + ''' could not be converted to ''' + @local_uom + ''''
				--set @error_msg = 'Cannot convert to pricing UOM (' + @table_uom + ')'
				set @price = null
				return -1
			end

		-- successfully return a price
		set @price = round( @price / @multiplier, @local_precision)
		return 0
	end

--===========================
-- Get a price for the style
--===========================
if @local_item_type = 'style'
	begin
		select top 1
			@price = pp.price,
			@multiplier = dbo.of_uomMultiplier(@local_product_id, @local_item, '', pp.uom, @local_uom, 6),
			@table_uom = pp.uom,
			@price_date = pp.effective_date
		from 
			prices_public_material pp with (nolock)
		where 
			pp.region_id = @local_region_id and
			pp.custclas = @local_custclas and
			pp.application_id = @local_application_id and
			pp.product_id = @local_product_id and
			pp.item_type = @local_item_type and
			pp.item = @local_item and
			pp.effective_date <= @local_effective_date 
			AND (pp.end_date >= @local_effective_date OR pp.end_date IS NULL OR pp.end_date = '')
		order by
			pp.effective_date desc
		
		if @price is null
			return 0

		if @multiplier is null
			begin
				set @error_msg = 'The public price for the ' + @local_item_type + ' ''' + @local_item + ''' could not be converted to ''' + @local_uom + ''''
				--set @error_msg = 'Cannot convert to pricing UOM (' + @table_uom + ')'
				set @price = null
				return -1
			end
	
		set @price = round( @price / @multiplier, @local_precision)
		return 0
	end


--===========================
-- Get a price for the option
--===========================
if @local_item_type = 'option'
	--print 'search public option '
	begin
		select top 1
			@price = pp.price,
			@multiplier = dbo.of_uomMultiplier(@local_product_id, @local_item, '', pp.uom, @local_uom, 6),
			@table_uom = pp.uom,
			@price_date = pp.effective_date,
			@price_type = price_type
		from 
			prices_public_material pp with (nolock)
		where 
			pp.region_id = @local_region_id and
			pp.custclas = @local_custclas and
			pp.application_id = @local_application_id and
			pp.product_id = @local_product_id and
			pp.item_type = @local_item_type and
			pp.item = @local_item and
			pp.effective_date <= @local_effective_date 
			AND (pp.end_date >= @local_effective_date OR pp.end_date IS NULL)
		order by
			pp.effective_date desc
		
		if @price is null
			return 0

	end


return 0


















GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[osp_selUnitPricePublicLabor]'
GO
ALTER PROCEDURE [dbo].[osp_selUnitPricePublicLabor]
(
	@effective_date datetime,
	@region_id varchar(2),
	@custclas varchar(25),
	@application_id varchar(10),
	@product_id varchar(10),
	@labor_code varchar(10),
	@uom varchar(20),
	@mode varchar(25),
	@precision int = 2,
	@price DECIMAL(18,6) OUTPUT,
	@error_msg VARCHAR(255) OUTPUT
)
WITH RECOMPILE
AS

/*
this function returns the unit price from prices_public_labor in terms of the desired unit of measure.
*/
/*
select dbo.of_getUomQty(1,'SqFt','SqFt')

declare @price decimal(18,6), @error varchar(255)
exec osp_selUnitPricePublicLabor '2019-06-18','02','production','10','Y','YSKIN','Ea','',2, @price output, @error output
print @price
print @error

select * from styles where style_id = '6B1BRICW'
*/

DECLARE
@local_effective_date DATETIME = @effective_date,
@local_region_id varchar(2) = @region_id,
@local_custclas varchar(25) = @custclas,
@local_application_id varchar(10) = @application_id,
@local_product_id varchar(10) = @product_id,
@local_labor_code varchar(10) = @labor_code,
@local_uom varchar(20) = @uom,
@local_mode varchar(25) = @mode,
@local_precision int = @precision


DECLARE @multiplier DECIMAL(18,6)
DECLARE @routine VARCHAR(50)
DECLARE @table_uom VARCHAR(50)

SET @price = NULL
SET @error_msg = ''
SET @multiplier = NULL
SET @routine = 'osp_selUnitPricePublicLabor'

SELECT TOP 1
	@price = p.price,
	@multiplier = dbo.of_getUomQty(1, p.uom, @local_uom),
	@table_uom = p.uom
FROM
	prices_public_labor p WITH (NOLOCK)
WHERE
	p.region_id = @local_region_id and
	p.custclas = @local_custclas and
	p.application_id = @local_application_id and
	p.product_id = @local_product_id and
	p.labor_code = @local_labor_code and
	p.effective_date <= @local_effective_date
	AND (p.end_date >= @local_effective_date OR p.end_date IS NULL)
order by
	p.effective_date desc

if @price is null
begin
	--search again without application
	select top 1
		@price = p.price,
		@multiplier = dbo.of_getUomQty(1, p.uom, @local_uom),
		@table_uom = p.uom
	from
		prices_public_labor p with (nolock)
	where
		p.region_id = @local_region_id and
		p.custclas = @local_custclas and
		p.product_id = @local_product_id and
		p.labor_code = @local_labor_code and
		p.effective_date <= @local_effective_date
		AND (p.end_date >= @local_effective_date OR p.end_date IS NULL)
	order by
		p.effective_date desc
end

if @price is not null -- found a record	
	begin
		if @multiplier < 0 --(bad uom: abort)
			begin
				--set @error_msg = 'Cannot convert to pricing UOM (' + @table_uom + ')'
				set @error_msg = 'The public labor price for the ' + 'labor code' + ' ''' + @local_labor_code + ''' could not be converted to ''' + @local_uom + '''.'

				set @price = null
				return -1
			end

		-- successfully return a price
		set @price = round(@price / @multiplier,@local_precision)
		return 0
	end

-- ALL OK --
set @price = round(@price / @multiplier,@local_precision)
return 0
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[osp_selUnitPriceGlobalMaterial]'
GO
ALTER procedure [dbo].[osp_selUnitPriceGlobalMaterial] (
@effective_date datetime,
@customer_id varchar(15),
@application_id varchar(10),
@product_id varchar(10),
@item_type varchar(10),
@item varchar(81),
@uom varchar(20),
@mode varchar(25),
@precision int = 2,
@price decimal(18,6) output,
@retail_unit_price decimal(18,6) output,
@retail_percentage decimal(18,6) OUTPUT,
@retail_percentage_type VARCHAR(10) OUTPUT,
@error_msg VARCHAR(255) OUTPUT,
@price_date DATETIME = '1/1/1900' OUTPUT,
@actual_item_number VARCHAR(81) = '' ,
@price_type VARCHAR(10) = '' OUTPUT
)
WITH RECOMPILE
AS

IF @item_type NOT IN ('color', 'style', 'group', 'cust_item','option')
	RETURN 0

declare
@local_effective_date DATETIME = @effective_date,
@local_customer_id varchar(15) = @customer_id,
@local_application_id varchar(10) = @application_id,
@local_product_id varchar(10) = @product_id,
@local_item_type varchar(10) = @item_type,
@local_item varchar(81) = @item,
@local_uom varchar(20) = @uom,
@local_mode varchar(25) = @mode,
@local_precision int = @precision,
@local_actual_item_number VARCHAR(81) = @actual_item_number
--==================================================================
-- This function returns the unit price from prices_global_material
-- in terms of the desired unit of measure.
--==================================================================
DECLARE @multiplier DECIMAL(18,6)
DECLARE @routine VARCHAR(50)
DECLARE @table_uom VARCHAR(50)
declare @local_item_product varchar(10)
declare @local_item_style varchar(20)
declare @local_item_color varchar(50)

set @price = null
set @retail_unit_price = null
set @retail_percentage = null
set @retail_percentage_type = ''
set @error_msg = ''
set @multiplier = null
set @routine = 'osp_selUnitPriceGlobalMaterial'

--===========================
-- Get a price for the color
--===========================
if @local_item_type = 'color' or @local_item_type = 'cust_item'
	begin
		select
			@local_item_product = product_id,
			@local_item_style = style_id,
			@local_item_color = color_id
		from
			colors with (nolock)
		where
			part_no = @local_item

		select top 1
			@price = pg.price,
			@retail_unit_price = pg.retail_unit_price,
			@retail_percentage = pg.retail_percentage,
			@retail_percentage_type = pg.retail_percentage_type,
			@multiplier = case @local_item_type
											when 'color' then dbo.of_uomMultiplier(@local_item_product, @local_item_style, @local_item_color, pg.uom, @local_uom, 6)
											else 1
										end,
			@table_uom = pg.uom,
			@price_date = pg.effective_date
		from
			prices_global_material pg with (nolock)
		where
			pg.customer_id = @local_customer_id and
			pg.application_id = @local_application_id and
			pg.product_id = @local_product_id and
			pg.item_type = @local_item_type and
			pg.item = @local_item and
			pg.effective_date <= @local_effective_date
			AND (pg.end_date >= @local_effective_date OR pg.end_date IS NULL)
		order by
			pg.effective_date desc
	end

--===========================
-- Get a price for the style
--===========================
if @local_item_type = 'style'
	begin
		select top 1
			@price = pg.price,
			@retail_unit_price = pg.retail_unit_price ,
			@retail_percentage = pg.retail_percentage,
			@retail_percentage_type = pg.retail_percentage_type,
			@multiplier = dbo.of_uomMultiplier(@local_product_id, @local_item, '', pg.uom, @local_uom, 6),
			@table_uom = pg.uom,
			@price_date = pg.effective_date
		from
			prices_global_material pg with (nolock)
		where
			pg.customer_id = @local_customer_id and
			pg.application_id = @local_application_id and
			pg.product_id = @local_product_id and
			pg.item_type = @local_item_type and
			pg.item = @local_item and
			pg.effective_date <= @local_effective_date
			AND (pg.end_date >= @local_effective_date OR pg.end_date IS NULL)
		order by
			pg.effective_date desc
	end

--===========================
-- Get a price for the group
--===========================
if @local_item_type = 'group'
	begin
		select top 1
			@price = pg.price,
			@retail_unit_price = pg.retail_unit_price,
			@retail_percentage = pg.retail_percentage,
			@retail_percentage_type = pg.retail_percentage_type,
			@multiplier = 1,
			@table_uom = pg.uom,
			@price_date = pg.effective_date
		from
			prices_global_material pg with (nolock)
		where
			pg.customer_id = @local_customer_id and
			pg.application_id = @local_application_id and
			pg.product_id = @local_product_id and
			pg.item_type = @local_item_type and
			pg.item = @local_item and
			pg.effective_date <= @local_effective_date
			AND (pg.end_date >= @local_effective_date OR pg.end_date IS NULL)
		order by
			pg.effective_date desc


		if @local_actual_item_number <> ''
			begin
				select
					@local_item_product = product_id,
					@local_item_style = style_id,
					@local_item_color = color_id
				from
					colors with (nolock)
				where
					part_no = @local_actual_item_number
				
				
				--print @local_item_product
				--print @local_item_style
				--print @local_item_color
				--print @table_uom
				--print @local_uom
				
				set @multiplier = dbo.of_uomMultiplier(@local_item_product, @local_item_style, @local_item_color, @table_uom, @local_uom, 6)
			end
			
	end


--===========================
-- Get a price for the option
--===========================
if @local_item_type = 'option'
	--print 'search glbl option '
	begin
		select top 1
			@price = pg.price,
			@retail_unit_price = pg.retail_unit_price,
			@retail_percentage = pg.retail_percentage,
			@retail_percentage_type = pg.retail_percentage_type,
			@multiplier = 1,
			@table_uom = pg.uom,
			@price_date = pg.effective_date,
			@price_type = price_type
		from
			prices_global_material pg with (nolock)
		where
			pg.customer_id = @local_customer_id and
			pg.application_id = @local_application_id and
			pg.product_id = @local_product_id and
			pg.item_type = @local_item_type and
			pg.item = @local_item and
			pg.effective_date <= @local_effective_date
			AND (pg.end_date >= @local_effective_date OR pg.end_date IS NULL OR pg.end_date = '')
		order by
			pg.effective_date desc
		option (recompile)	
	end
--==============================
-- Validate and calculate price
--==============================
if @price is null
	return 0

if @multiplier is null
	begin
	    --print 'bad multi'
		set @error_msg = 'The global price for the ' + @local_item_type + ' ''' + @local_item + ''' could not be converted to ''' + @local_uom + ''''
		set @price = null
		return -1
	end

set @price = round(@price / @multiplier, @local_precision)
set @retail_unit_price = round(@retail_unit_price / @multiplier, @local_precision)
set @retail_percentage = round(@retail_percentage / @multiplier, @local_precision)

return 0
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[osp_selUnitPriceGlobalLabor]'
GO
ALTER PROCEDURE [dbo].[osp_selUnitPriceGlobalLabor]
(
	@effective_date datetime,
	@customer_id varchar(15),
	@application_id varchar(10),
	@product_id varchar(10),
	@labor_code varchar(10),
	@uom varchar(20),
	@mode varchar(25),
	@precision INT = 2,
	@price DECIMAL(18,6) OUTPUT,
	@retail_unit_price DECIMAL(18,6) OUTPUT,
	@retail_percentage DECIMAL(18,6) OUTPUT,
	@retail_percentage_type VARCHAR(10) OUTPUT,
	@error_msg VARCHAR(255) OUTPUT
)
WITH RECOMPILE
AS

/*
SUMMARY:
this function returns the unit price & retail_unit_price
from prices_global_labor
in terms of the desired unit of measure.
*/

/*
select dbo.of_getUomQty(1,'SqFt','SqFt')

declare @price decimal(18,6), @error varchar(255)
exec osp_selUnitPricePublicLabor '01','TRACT - HOUSTON','3','6','NLBR','SqFt','',2, @price output, @error output
print @price
print @error

select * from styles where style_id = '6B1BRICW'
*/

DECLARE 
@local_effective_date DATETIME = @effective_date,
@local_customer_id VARCHAR(15) = @customer_id,
@local_application_id VARCHAR(10) = @application_id,
@local_product_id VARCHAR(10) = @product_id,
@local_labor_code varchar(10) = @labor_code,
@local_uom VARCHAR(20) = @uom,
@local_mode VARCHAR(25) = @mode,
@local_precision INT = @precision

declare @multiplier decimal(18,6)
declare @routine varchar(50)
declare @table_uom varchar(50)

set @price = null
set @retail_unit_price = null
set @error_msg = ''
set @multiplier = null
set @routine = 'osp_selUnitPriceGlobalLabor'

select top 1
	@price = p.price,
	@retail_unit_price = p.retail_unit_price,
	@retail_percentage = p.retail_percentage,
	@retail_percentage_type = p.retail_percentage_type,
	@multiplier = dbo.of_getUomQty(1, p.uom, @local_uom),
	@table_uom = p.uom
from
	prices_global_labor p with (nolock)
where
	p.customer_id = @local_customer_id and
	p.application_id = @local_application_id and
	p.product_id = @local_product_id and
	p.labor_code = @local_labor_code and
	p.effective_date <= @local_effective_date
	AND (p.end_date >= @local_effective_date OR p.end_date IS NULL)
order by
	p.effective_date desc

if @price is null
begin
	--search again, without using the application
	select top 1
		@price = p.price,
		@retail_unit_price = p.retail_unit_price,
		@retail_percentage = p.retail_percentage,
		@retail_percentage_type = p.retail_percentage_type,
		@multiplier = dbo.of_getUomQty(1, p.uom, @local_uom),
		@table_uom = p.uom
	from
		prices_global_labor p with (nolock)
	where
		p.customer_id = @local_customer_id and
		p.product_id = @local_product_id and
		p.labor_code = @local_labor_code and
		p.effective_date <= @local_effective_date
		AND (p.end_date >= @local_effective_date OR p.end_date IS NULL)
	order by
		p.effective_date desc
end

if @price is not null -- found a record	
	begin
		if @multiplier < 0 --(bad uom: abort)
			begin
				--set @error_msg = 'Cannot convert to pricing UOM (' + @table_uom + ')'
				set @error_msg = 'The global labor price for the ' + 'labor code' + ' ''' + @local_labor_code + ''' could not be converted to ''' + @local_uom + '''.'

				set @price = null
				return -1
			end

		-- successfully return a price
		set @price = round(@price / @multiplier,@local_precision)
		set @retail_unit_price  = round(@retail_unit_price  / @multiplier, @local_precision)
		set @retail_percentage  = round(@retail_percentage  / @multiplier, @local_precision)

		return 0
	end

-- return a null price to allow system to go to next level
set @price = round(@price / @multiplier,@local_precision)
set @retail_unit_price = round(@retail_unit_price / @multiplier , @local_precision)

return 0
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
    plan_id INT,
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
PRINT N'Altering [dbo].[osp_selUnitPriceDefaultMaterial]'
GO

ALTER procedure [dbo].[osp_selUnitPriceDefaultMaterial]    
 (    
  @spec_id int,    
  @effective_date datetime,    
  @application_id varchar(10),    
  @product_id varchar(10),    
  @item_type varchar(10),    
  @item varchar(81),    
  @uom varchar(20),    
  @mode varchar(25),    
  @precision int = 2,    
  @price DECIMAL(18,6) OUTPUT,    
  @retail_unit_price DECIMAL(18,6) OUTPUT,     
  @retail_percentage decimal(18,6) output,     
  @retail_percentage_type varchar(10) output, 
  @error_msg varchar(255) output,
  @price_type varchar(10) = '' output    
 )    
WITH RECOMPILE	
as    
    
/*--------------------------------------------------------------    
SUMMARY:     
this function returns the unit price & retail unit price     
from prices_default_material     
in terms of the desired unit of measure.    
    
HISTORY:     
Modified - this proc was not limiting its selections to ACTIVE     
pricesets. Modified to get most recent PRICESET date that is active    
to use when fetching a price for something.  

2016 01 26 Scott Friend - Commented out the Print lines   
----------------------------------------------------------------*/    
--select @local_item + 'UOM:' + @local_uom + ' ' + convert(varchar(4), len(@local_uom))    
    
DECLARE 
  @local_spec_id INT = @spec_id,    
  @local_effective_date DATETIME = @effective_date,    
  @local_application_id varchar(10) = @application_id,    
  @local_product_id varchar(10) = @product_id,    
  @local_item_type varchar(10) = @item_type,    
  @local_item varchar(81) = @item,    
  @local_uom varchar(20) = @uom,    
  @local_mode varchar(25) = @mode,    
  @local_precision int = @precision

declare @multiplier decimal(18,6)    
declare @routine varchar(50)    
declare @table_uom varchar(50)    
    
set @price = null    
set @error_msg = ''    
set @multiplier = null    
set @routine = 'osp_selUnitPriceDefaultMaterial'    
    
    
    
declare @local_item_product varchar(10)    
declare @local_item_style varchar(20)    
declare @local_item_color varchar(50)    
  
select    
	@local_item_product = product_id,    
	@local_item_style = style_id,    
	@local_item_color = color_id    
from    
colors with (nolock)  
where    
part_no = @local_item        

--print @local_item_style
--print @local_item_color
 
    
--===========================    
-- Get a price for the color    
--===========================    
if @local_item_type = 'color' or @local_item_type = 'cust_item'  
 begin   
  --declare @local_item_product varchar(10)    
  --declare @local_item_style varchar(20)    
  --declare @local_item_color varchar(50)    
      
  --select    
  -- @local_item_product = product_id,    
  -- @local_item_style = style_id,    
  -- @local_item_color = color_id    
  --from    
  -- colors with (nolock)  
  --where    
  -- part_no = @local_item    
    
  select top 1    
   @price = pd.price,    
   @retail_unit_price = pd.retail_unit_price,     
   @retail_percentage = pd.retail_percentage,     
   @retail_percentage_type = pd.retail_percentage_type,     
   @multiplier = case @local_item_type  
          when 'color' then dbo.of_uomMultiplier(@local_item_product, @local_item_style, @local_item_color, pd.uom, @local_uom, 6)    
          else 1  
         end,  
   @table_uom = pd.uom    
  from     
   prices_default_material pd with (nolock)    
   join pricesets p with (nolock) on p.spec_id = pd.spec_id and p.effective_date = pd.effective_date     
  where     
   pd.spec_id = @local_spec_id and    
   pd.application_id = @local_application_id and    
   pd.product_id = @local_product_id and    
   pd.item_type = @local_item_type     
   and pd.item = @local_item     
   --pd.effective_date <= @local_effective_date    
   and p.effective_date = @local_effective_date     
   and p.active = 1    
  order by    
   p.effective_date desc    
        
  if @price is null    
   return 0    
  if @multiplier is null    
   begin    
    set @error_msg = 'The default material price for the ' + @local_item_type + ' ''' + @local_item + ''' could not be converted to ''' + @local_uom + ''''    
    --set @error_msg = 'Cannot convert to pricing UOM (' + @table_uom + ')'    
    set @price = null    
    return -1    
   end    
       
  --(good uom, good price: return successfully)    
  set @price = round(@price / @multiplier,@local_precision)    
  set @retail_unit_price = round(@retail_unit_price / @multiplier, @local_precision)     
  set @retail_percentage = round(@retail_percentage / @multiplier, @local_precision)     
    
  return 0    
 end    
    
--===========================    
-- Get a price for the style    
--===========================    
if @local_item_type = 'style'    
 begin    
  select top 1    
   @price = pd.price,    
   @retail_unit_price = pd.retail_unit_price,     
   @retail_percentage = pd.retail_percentage,     
   @retail_percentage_type = pd.retail_percentage_type,     
   @multiplier = dbo.of_uomMultiplier(@local_product_id, @local_item, '', pd.uom, @local_uom, 6),    
   @table_uom = pd.uom    
  from     
   prices_default_material pd with (nolock)    
   join pricesets p with (nolock) on p.spec_id = pd.spec_id and p.effective_date = pd.effective_date     
  where        pd.spec_id = @local_spec_id and    
   pd.application_id = @local_application_id and    
   pd.product_id = @local_product_id and    
   pd.item_type = @local_item_type and    
   pd.item = @local_item and    
   p.effective_date = @local_effective_date    
   and p.active = 1    
  order by    
   p.effective_date desc    
    
  if @price is null -- this check is before the multiplier because if there is no price record at all, exit the routine and let the system look elsewhere    
   return 0    
    
  if @multiplier is null    
   begin    
    set @error_msg = 'The default material price for the ' + @local_item_type + ' ''' + @local_item + ''' could not be converted to ''' + @local_uom + ''''    
    --set @error_msg = 'Cannot convert to pricing UOM (' + @table_uom + ')'    
    set @price = null    
    return -1    
   end    
    
  set @price = round(@price / @multiplier, @local_precision)    
  set @retail_unit_price = round(@retail_unit_price / @multiplier, @local_precision)     
  set @retail_percentage = round(@retail_percentage / @multiplier, @local_precision)     
  return 0    
 end    
     
--===========================    
-- Get a price for the group    
--===========================    
if @local_item_type = 'group'    
 begin    
  
 
  select top 1    
   @price = pd.price,    
   @retail_unit_price = pd.retail_unit_price,    
   @retail_percentage = pd.retail_percentage,     
   @retail_percentage_type = pd.retail_percentage_type,      
   @multiplier = 1,    
   --@multiplier = dbo.of_uomMultiplier(@local_product_id, @local_item_style2, @local_item_color2, pd.uom, @local_uom, 6),
   @table_uom = pd.uom    
  from     
   prices_default_material pd with (nolock)    
   join pricesets p with (nolock) on p.spec_id = pd.spec_id and p.effective_date = pd.effective_date     
  where     
   pd.spec_id = @local_spec_id and    
   pd.application_id = @local_application_id and    
   pd.item_type = @local_item_type and    
   pd.item = @local_item and    
   p.effective_date = @local_effective_date    
   and p.active = 1    
  order by    
   p.effective_date desc    
        
  if @price is null    
   return 0    
   
    
  set @price = round(@price / @multiplier, @local_precision)    
  set @retail_unit_price = round(@retail_unit_price / @multiplier, @local_precision)     
  set @retail_percentage = round(@retail_percentage / @multiplier, @local_precision)     
  return 0    
 end    
   
--added 10/20/14 ADG for cabinets.   
--===========================    
-- Get a price for the group    
--=========================== 
if @local_item_type = 'option'
begin
	--print 'search default option '
  select top 1    
   @price = pd.price,    
   @retail_unit_price = pd.retail_unit_price,    
   @retail_percentage = pd.retail_percentage,     
   @retail_percentage_type = pd.retail_percentage_type,    
   @price_type = price_type,  
   @multiplier = 1,    
   --@multiplier = dbo.of_uomMultiplier(@local_product_id, @local_item_style2, @local_item_color2, pd.uom, @local_uom, 6),
   @table_uom = pd.uom    
  from     
   prices_default_material pd with (nolock)    
   join pricesets p with (nolock) on p.spec_id = pd.spec_id and p.effective_date = pd.effective_date     
  where     
   pd.spec_id = @local_spec_id and    
   pd.application_id = @local_application_id and    
   pd.item_type = @local_item_type and    
   pd.item = @local_item and    
   p.effective_date = @local_effective_date    
   and p.active = 1    
  order by    
   p.effective_date desc    
        
  if @price is null    
   return 0    
   
    
  set @price = round(@price / @multiplier, @local_precision)    
  set @retail_unit_price = round(@retail_unit_price / @multiplier, @local_precision)     
  set @retail_percentage = round(@retail_percentage / @multiplier, @local_precision)     
  return 0 

end   
    
return 0    
   
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[osp_selUnitPriceDefaultLabor]'
GO
ALTER PROCEDURE [dbo].[osp_selUnitPriceDefaultLabor]
(
	@spec_id int,
	@effective_date datetime,
	@application_id varchar(10),
	@product_id varchar(10),
	@labor_code varchar(10),
	@uom varchar(20),
	@mode varchar(25),
	@precision int = 2,
	@price decimal(18,6) output,
	@retail_unit_price decimal(18,6) output,
	@retail_percentage decimal(18,6) output,
	@retail_percentage_type varchar(10) output,
	@error_msg varchar(255) OUTPUT
)
WITH RECOMPILE
as

/*
this function returns the unit price from prices_default_labor in terms of the desired unit of measure.
--MODIFIED ON 07/06/2005 - if the @local_uom = '', then it is assumed we are using the uom in the pricing.
*/

DECLARE
@local_spec_id INT = @spec_id,
@local_effective_date DATETIME = @effective_date,
@local_application_id varchar(10) = @application_id,
@local_product_id varchar(10) = @product_id,
@local_labor_code varchar(10) = @labor_code,
@local_uom varchar(20) = @uom,
@local_mode varchar(25) = @mode,
@local_precision int = @precision

declare @multiplier decimal(18,6)
declare @routine varchar(50)
declare @table_uom varchar(50)

set @price = null
set @retail_unit_price = null
set @retail_percentage = null
set @retail_percentage_type = ''
set @error_msg = ''
set @multiplier = null
set @routine = 'osp_selUnitPriceDefaultLabor'

select top 1
 @price = p.price,
 @retail_unit_price = p.retail_unit_price,
 @retail_percentage = p.retail_percentage,
 @retail_percentage_type = p.retail_percentage_type,
 @multiplier = dbo.of_getUomQty(1, p.uom, case len(@local_uom)
       when 0 then p.uom
       else @local_uom end
     ),
 @table_uom = p.uom
from
 prices_default_labor p with (nolock)
where
 p.spec_id = @local_spec_id and
 p.application_id = @local_application_id and
 p.product_id = @local_product_id and
 p.labor_code = @local_labor_code and
 p.effective_date = @local_effective_date
order by
 p.effective_date desc


if @price is null
begin
--search again, this time without application. This handles labor codes assigned to an item used across multiple applications.
 select top 1
  @price = p.price,
  @retail_unit_price = p.retail_unit_price,
  @retail_percentage = p.retail_percentage,
  @retail_percentage_type = p.retail_percentage_type,
  @multiplier = dbo.of_getUomQty(1, p.uom,  case len(@local_uom)
       when 0 then p.uom
       else @local_uom end
     ),
  @table_uom = p.uom
 from
  prices_default_labor p with (nolock)
  join pricesets ps with (nolock) on ps.spec_id = p.spec_id and ps.effective_date = p.effective_date
 where
  p.spec_id = @local_spec_id and
  p.product_id = @local_product_id and
  p.labor_code = @local_labor_code and
  ps.effective_date = @local_effective_date
  and ps.active = 1
 order by
  ps.effective_date desc
end

if @price is not null -- found a record
 begin
  if @multiplier < 0 --(bad uom: abort)
   begin
    set @error_msg = 'The default labor price for ' + @local_labor_code + ' could not be converted to ''' + @local_uom + ''''
    --set @error_msg = 'Cannot convert to pricing UOM (' + @table_uom + ')'
    set @price = null
    return -1
   end

  -- successfully return a price
  set @price = round(@price / @multiplier,@local_precision)
  set @retail_unit_price = round(@retail_unit_price / @multiplier, @local_precision)
  set @retail_percentage = round(@retail_percentage / @multiplier, @local_precision)

  return 0
 end

-- return a null price to allow system to go to next level
set @price = round(@price / @multiplier,@local_precision)
return 0
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

 DECLARE @group_id INT
 SET @group_id = NULL

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
		   DECLARE @style_id VARCHAR(50)
		   SET @style_id = ''

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
PRINT N'Creating [dbo].[osp_selContractItemPrice]'
GO
CREATE PROCEDURE [dbo].[osp_selContractItemPrice]    
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
@item_type varchar(10),    
@item varchar(81),     
@uom varchar(9) = '',    
@item_price decimal(18,2) output,    
@price_type varchar(10) output,    
@pricing_layer varchar(20) output,    
@item_price_retail decimal(18,2) output,     
@retail_percentage decimal(18,2) output,     
@retail_percentage_type varchar(10) output,     
@error_msg varchar(255) OUTPUT,
@bypass_flat_fee_exclusion BIT OUTPUT
AS

/*

History: 09.24.2025 - SJC Added bypass_flat_fee_exclusion OUTPUT parameter


*/

set nocount on    
declare @priceset_effective_date datetime    
set @priceset_effective_date = '1/1/1900'

    
declare @error varchar(255)    
set @error = ''
SET @bypass_flat_fee_exclusion = 0
    
declare @price_date datetime     
    
--============================================================    
-- If item_type is 'color' or 'group', use their product_id's    
-- If item_type = style use the incoming @product_id    
--============================================================    
    
if @item_type = 'color'    
 begin    
  select    
   @product_id = product_id    
  from    
   colors with (nolock)    
  where    
   part_no = @item    
 end   
 
 if @item_type = 'style'    
 begin 
  IF EXISTS (SELECT 1 FROM styles WITH (NOLOCK) WHERE style_id = @item AND product_id = 'T')   
  select    
   @product_id = product_id    
  from    
   styles with (nolock)    
  where    
   style_id = @item 
   AND product_id = 'T'   
 end 
    
if @item_type = 'group'    
 begin    
  select    
   @product_id = product_id    
  from    
   styles_groups with (nolock)    
  where    
   group_id = @item    
 end    
    
if @item_type = 'labor'    
 begin  
 declare @lc_application_id varchar(10)                                 
 declare @lc_product_id varchar(10)  
 
  select    
   @lc_application_id = application_id,    
   @lc_product_id = product_id    
  from    
   labor_codes with (nolock)    
  where    
   code = @item    
 
  if len(@lc_application_id) > 0                             
   begin                            
    set @application_id = @lc_application_id                            
   end                            
 if len(@lc_product_id) > 0                             
   begin                            
    set @product_id = @lc_product_id                            
   end   

  --testing     
  --select @application_id, @product_id     
 end    
    
--=========================================================    
-- Get the latest priceset for @spec_id    
-- This date is only used for default and extended pricing    
--=========================================================    
if @spec_id <> 0    
 begin    
  select top 1    
   @priceset_effective_date = effective_date    
  from    
   pricesets with (nolock)    
  where    
   spec_id = @spec_id    
   and active = 1    
   and effective_date <= @effective_date    
  order by     
   effective_date desc    
 end    
    
---------------------------------------------------------------------------------------------------------    
-- Extended pricing    
---------------------------------------------------------------------------------------------------------    
set @pricing_layer = 'extended'     
    
if @generic_item_type = 'material'     
 begin    
  exec osp_selUnitPriceExtendedMaterial    
    @spec_id, @priceset_effective_date,    
    @application_id, @product_id,    
    @area_id, @sub_area_id,    
    @plan_id, @build_id,    
    @item_type,
	@generic_item_id,  --added new parm 6/19/2025 Jena & Adrian  
	@item,    
    @uom, 2, @customer_id,    
    @item_price output,    
    @price_type output,    
    @item_price_retail output,     
    @retail_percentage output,     
    @retail_percentage_type output,     
    @error OUTPUT,
	@bypass_flat_fee_exclusion OUTPUT
    
  if @error <> ''    
   begin    
    set @error_msg = @error    
    return    
   end    
    
  if not @item_price is null    
   begin     
    return    
   end     
 end    
    
if @generic_item_type = 'labor'     
 begin    
  exec osp_selUnitPriceExtendedLabor    
    @spec_id, @priceset_effective_date,    
    @application_id, @product_id,    
    @area_id, @sub_area_id,    
    @plan_id, 
	@build_id,
	@generic_item_id,  --added new parm 6/19/2025 Jena & Adrian  
    @item,    
    @item_price output,     
    @price_type output,    
    @item_price_retail output,     
    @retail_percentage output,     
    @retail_percentage_type output,    
    @error OUTPUT,
	@bypass_flat_fee_exclusion OUTPUT
      
  if @error <> ''    
   begin    
    set @error_msg = @error    
    return    
   end    
    
  if not @item_price is null    
   begin     
    return    
   end     
 end    
    
---------------------------------------------------------------------------------------------------------    
-- Default pricing    
---------------------------------------------------------------------------------------------------------    
set @pricing_layer = 'default'    
    
if @generic_item_type = 'material'     
 begin    
  exec osp_selUnitPriceDefaultMaterial    
    @spec_id,    
    @priceset_effective_date,    
    @application_id,     
    @product_id,     
    @item_type,     
    @item,    
    @uom, '', 2,     
    @item_price output,      
    @item_price_retail output,     
    @retail_percentage output,     
    @retail_percentage_type output,     
    @error output,
	@price_type output 
    
  if @error <> ''    
   begin    
    set @error_msg = @error    
    return    
   end    
     
  if not @item_price is null    
   begin     
    return     
   end    
 end    
    
if @generic_item_type = 'labor'     
 begin     
  exec osp_selUnitPriceDefaultLabor    
    @spec_id,    
    @priceset_effective_date,    
    @application_id,     
    @product_id,     
    @item,     
    @uom,     
    '',     
    2,     
    @item_price output,    
    @item_price_retail output,      
    @retail_percentage output,     
    @retail_percentage_type output,     
    @error output

    
    
  if @error <> ''    
   begin    
    set @error_msg = @error    
    return    
   end    
    
  if not @item_price is null    
   begin     
    return    
   end     
 end     
    
---------------------------------------------------------------------------------------------------------    
-- Global pricing    
---------------------------------------------------------------------------------------------------------    
set @pricing_layer = 'global'    
    
if @generic_item_type = 'material'     
 begin     
  exec osp_selUnitPriceGlobalMaterial    
    @effective_date,     
    @customer_id,    
    @application_id,     
    @product_id,     
    @item_type,     
    @item,    
    @uom, '', 2,     
    @item_price output,    
    @item_price_retail output,     
    @retail_percentage output,     
    @retail_percentage_type output,       
    @error output,    
    @price_date output,
	'',
	@price_type output 
    
    
  if @error <> ''    
   begin    
    set @error_msg = @error    
    return    
   end    
    
  if not @item_price is null    
   begin     
    return    
   end     
 end    
    
if @generic_item_type = 'labor'     
 begin     
  exec osp_selUnitPriceGlobalLabor    
    @effective_date,     
    @customer_id,    
    @application_id,     
    @product_id,     
    @item,     
    @uom,     
    '',     
    2,     
    @item_price output,    
    @item_price_retail output,       
    @retail_percentage output,     
    @retail_percentage_type output,      
    @error output    
    
  if @error <> ''    
   begin    
    set @error_msg = @error    
    return    
   end    
    
  if not @item_price is null    
   begin     
    return    
   end     
 end     
    
---------------------------------------------------------------------------------------------------------    
-- Public pricing    
---------------------------------------------------------------------------------------------------------    
set @pricing_layer = 'public'    
    
--====================    
-- Get customer class     
--====================    
declare @customer_class varchar(15)    
set @customer_class = ''    
    
select    
 @customer_class = class    
from    
 customers with (nolock)   
where    
 custnmbr = @customer_id     
    
if @generic_item_type = 'material'     
 begin     
  exec osp_selUnitPricePublicMaterial    
    @effective_date,     
    @region_id,    
    @customer_class,    
    @application_id,     
    @product_id,     
    @item_type,     
    @item,    
    @uom, '', 2,     
    @item_price output,     
    @error output,
	@price_date output,
	@price_type output
    
  if @error <> ''    
   begin    
    set @error_msg = @error    
    return    
   end    
    
  if not @item_price is null    
   begin     
    return     
   end    
 end    
    
if @generic_item_type = 'labor'     
 begin     
  exec osp_selUnitPricePublicLabor    
    @effective_date,     
    @region_id,    
    @customer_class,    
    @application_id,     
    @product_id,     
    @item,     
    @uom,     
    '',     
    2,     
    @item_price output,     
    @error output    
    
  if @error <> ''    
   begin    
    set @error_msg = @error    
    return    
   end    
    
  if not @item_price is null    
   begin     
    return    
   end    
 end    
    
set @pricing_layer = ''    
--set @error_msg = 'Unit price not found'  

set @error_msg = 'Unit price not found for the ' + @item_type + ' ''' + @item + ''''  
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating index [IX_prices_global_material] on [dbo].[prices_global_material]'
GO
CREATE NONCLUSTERED INDEX [IX_prices_global_material] ON [dbo].[prices_global_material] ([customer_id], [effective_date], [application_id], [item_type], [item])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating index [ix_prices_public_material)region_id_custclas_application_id_product_id_item_type_item_effective_date_end_date] on [dbo].[prices_public_material]'
GO
CREATE NONCLUSTERED INDEX [ix_prices_public_material)region_id_custclas_application_id_product_id_item_type_item_effective_date_end_date] ON [dbo].[prices_public_material] ([region_id], [custclas], [application_id], [product_id], [item_type], [item], [effective_date], [end_date])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[labor_codes]'
GO
ALTER TABLE [dbo].[labor_codes] WITH NOCHECK  ADD CONSTRAINT [FK_labor_codes_generic_parts] FOREIGN KEY ([generic_part_id]) REFERENCES [dbo].[generic_parts] ([part_id])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[prices_default_material]'
GO
ALTER TABLE [dbo].[prices_default_material] WITH NOCHECK  ADD CONSTRAINT [FK_plan_default_material_uom] FOREIGN KEY ([uom]) REFERENCES [dbo].[uom] ([uom_id])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[labor_codes]'
GO
ALTER TABLE [dbo].[labor_codes] ADD CONSTRAINT [FK_labor_codes_uom] FOREIGN KEY ([uom]) REFERENCES [dbo].[uom] ([uom_id])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[prices_default_labor]'
GO
ALTER TABLE [dbo].[prices_default_labor] ADD CONSTRAINT [FK_prices_default_labor_uom] FOREIGN KEY ([uom]) REFERENCES [dbo].[uom] ([uom_id])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[prices_global_labor]'
GO
ALTER TABLE [dbo].[prices_global_labor] ADD CONSTRAINT [FK_prices_global_labor_applications] FOREIGN KEY ([application_id]) REFERENCES [dbo].[applications] ([application_id])
GO
ALTER TABLE [dbo].[prices_global_labor] ADD CONSTRAINT [FK_prices_global_labor_labor_codes] FOREIGN KEY ([labor_code]) REFERENCES [dbo].[labor_codes] ([code])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[prices_public_labor]'
GO
ALTER TABLE [dbo].[prices_public_labor] ADD CONSTRAINT [FK_prices_public_labor_applications] FOREIGN KEY ([application_id]) REFERENCES [dbo].[applications] ([application_id])
GO
ALTER TABLE [dbo].[prices_public_labor] ADD CONSTRAINT [FK_prices_public_labor_products] FOREIGN KEY ([product_id]) REFERENCES [dbo].[products] ([product_id])
GO
ALTER TABLE [dbo].[prices_public_labor] ADD CONSTRAINT [FK_prices_public_labor_uom] FOREIGN KEY ([uom]) REFERENCES [dbo].[uom] ([uom_id])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[prices_public_material]'
GO
ALTER TABLE [dbo].[prices_public_material] ADD CONSTRAINT [FK_prices_public_material_uom] FOREIGN KEY ([uom]) REFERENCES [dbo].[uom] ([uom_id])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Disabling constraints on [dbo].[prices_default_material]'
GO
ALTER TABLE [dbo].[prices_default_material] NOCHECK CONSTRAINT [FK_plan_default_material_uom]
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
