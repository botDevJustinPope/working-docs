use [VEO_DEV];
go

declare @effective_date datetime = '2018-09-01 00:00:00',
		@spec_id int = 3520,
		@plan_id varchar(10) = '', --any
		@build_id varchar(10) = '', --any
		@application_id varchar(10) = '10', --cabinets
		@product_id varchar(10) = 'Y', -- cabinets
		@area_id varchar(10) = 'KIT', --kitchen
		@sub_area_id varchar(10) = 'CAB', --cabinets
		@uom varchar(10) = '',
		@price_type_1 varchar(10) = 'area',
		@item_id_1 varchar(250) = 'DRWHDWR',
		@price_type_2 varchar(10) = 'unit',
		@item_id_2 varchar(250) = 'DOORHDWR';

declare @groups table (item_no varchar(250));
insert into @groups (item_no)
values 
('5200');

declare @areas table (area_id varchar(15), sub_area_id varchar(15));
insert into @areas (area_id, sub_area_id)
select 
area_id, sub_area_id
from [dbo].[areas_sub_areas]
where sub_area_id = @sub_area_id

insert into [dbo].[prices_extended_material] (	[spec_id], 
															[effective_date], 
															[application_id], 
															[product_id], 
															[area_id], 
															[sub_area_id], 
															[plan_id], 
															[build_id], 
															[item_type], 
															[item], 
															[price_type], 
															[price], 
															[uom], 
															[retail_percentage_type], 
															[retail_percentage], 
															[retail_unit_price], 
															[author], 
															[create_date], 
															[modifier], 
															[modified_date], 
															[item_id], 
															bypass_flat_fee_exclusion)
SELECT
	params.spec_id, 
	params.effective_date, 
	params.application_id, 
	params.product_id, 
	a.area_id, 
	a.sub_area_id, 
	params.plan_id, 
	params.build_id, 
	'group' as item_type, 
	g.item_no as item, 
	item_id_pricing.price_type, 
	item_id_pricing.price as price, 
	item_id_pricing.uom as uom, 
	'none' as retail_percentage_type, 
	item_id_pricing.retail_percentage as retail_percentage, 
	item_id_pricing.retail_unit_price as retail_unit_price, 
	SYSTEM_USER as author, 
	getdate() as create_date, 
	SYSTEM_USER as modifier, 
	getdate() as modified_date,
	case when item_id_pricing.item_id is not null then item_id_pricing.item_id else g.item_no end as item_id,
	1 as bypass_flat_fee_exclusion
from @groups g
	left join (
		select @item_id_1 as item_id, @price_type_1 as price_type, 500.00 as [price], .45 as retail_percentage, 725.00 as retail_unit_price, '' as uom
		UNION ALL
		select @item_id_2 as item_id, @price_type_2 as price_type, 12.50 as [price], .30 as retail_percentage, 17.86 as retail_unit_price, 'Ea' as uom
	) [item_id_pricing] on 1=1
	left join @areas a on 1=1
cross join (select @effective_date as effective_date, @spec_id as spec_id, @application_id as application_id, @product_id as product_id, @plan_id as plan_id, @build_id as build_id) params

select 
	*
from [dbo].[prices_extended_material]
where [spec_id] = @spec_id
and [author] = SYSTEM_USER
and [effective_date] = @effective_date


/*
-- delete the test data after validation
delete m
from [dbo].[prices_extended_material] m
where m.author = SYSTEM_USER
*/
