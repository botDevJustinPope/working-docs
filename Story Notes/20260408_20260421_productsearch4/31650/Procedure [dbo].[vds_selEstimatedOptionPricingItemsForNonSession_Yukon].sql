SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[vds_selEstimatedOptionPricingItemsForNonSession_Yukon]
@account_id uniqueidentifier,
@external_organization_id varchar(15),
@unmapped_community_id int,
@unmapped_series_name varchar(30),
@unmapped_plan_name varchar(50),
@effective_date datetime,
@application varchar(50),
@product varchar(50) = ''
WITH RECOMPILE
as

/*
		Procedure:	vsp_getAccountOrganizationEstimatedItemsForPricingPortal_Yukon
		Author:		Richard Gladstone
		Date:		06/23/2014
		Purpose:	Retrieves estimated areas and their price level prices
		Usage:	
					select * from spec_mstr where spec_id = 2989
					select * from prices_landed pl LEFT JOIN plan_mstr pm on pm.plan_id = pl.plan_id where spec_id = 2989
					declare @account_id uniqueidentifier = newid()
					declare @org_id uniqueidentifier = newid()
					exec vsp_getAccountOrganizationEstimatedItemsForPricingPortal_Yukon @account_id, @org_id, 2989, 'bandera','bandera', '12-10-2012'
					vsp_getAccountOrganizationEstimatedItemsForPricingPortal_Yukon_20140902 'bab32b7e-3ada-497c-862e-e5083971cc59', '78d12721-c3d5-4067-9e89-9b4c32a8cda2', 2844,'CP05','CP05','9/1/2014'

	    Updates:

		RIG 20160512 Use customer columns to dictate wall grouping and build selection behavior

		10/28/2015 commented the COLLATE call to remove caps-sensitive-comparison for plan_ids. 

		01/21/2015 added max/min build table to alter results to show max builds or min builds -ADG

        07/16/2015 Return the contract_sort_order from the builder_styles table. Saul.

        10/26/2015 Perform ceiling rounding on the price that is returned. Saul.

		Modified: Shelby Mansker
		Date: 3/7/2017
		Description: Fixed an issue where the spec end date wasn't being honored properly. We were comparing the end date to TSQL's GETDATE() method,
			which returns a date with a time component. However, Echelon does not store a time component for a spec's end date. A spec is valid through the end
			date, and is only invalid on the day after the end date. To make the comparisons work, we must remove the time component by converting the result of GETDATE
			to a DATE.

		Modified: Shelby Mansker
		Date: 5/25/2017
		Description: Fixed an issue where the proc would return the prices landed for the wrong plan version, when there are multiple plan versions with the same
			effective date publish. The "correct" plan version is the one that was most recently created.

		Modified: Saul Sanchez
		Date: 11/6/2017
		Description: Return plan version.

		Modified: Robert Hobbs
		Date: 11/01/2018
		Description: expanded Area in @results to 100 to accommodate an increase in build_desc from Echelon


*/

--------------------------------------------------------------------------------------------------------------------------------
-- Look for an active spec id and populate the variable required to drive the wall grouping and build type selection behavior
--------------------------------------------------------------------------------------------------------------------------------
DECLARE @active_spec_id INT, @group_walls bit, @build_type varchar(10)
SELECT TOP 1
    @active_spec_id = sm.spec_id,
	@group_walls = group_walls,
	@build_type = opt_pricing_build_type
FROM
    spec_mstr sm WITH (NOLOCK)
    LEFT JOIN spec_communities sc WITH (NOLOCK) ON sc.spec_id = sm.spec_id
    LEFT JOIN spec_series ss WITH (NOLOCK) ON ss.spec_id = sm.spec_id
    JOIN plan_mstr pm WITH (NOLOCK) ON pm.spec_id = sm.spec_id
    JOIN pricesets p WITH (NOLOCK) ON p.spec_id = sm.spec_id
	join customers c with (nolock) on c.custnmbr = sm.builder_id
WHERE
    sm.builder_id = @external_organization_id
    AND sm.active = 1
    AND (sm.end_date = null OR sm.end_date >= CONVERT(DATE, @effective_date))
    AND sc.community_id = @unmapped_community_id
    AND ss.series = @unmapped_series_name
    AND pm.plan_name = @unmapped_plan_name
    AND p.active = 1
    AND p.effective_date <= @effective_date
ORDER BY
    p.effective_date DESC

-- If we don't find an active spec id, then stop and exit.
IF @active_spec_id = NULL
BEGIN
    RETURN
END

-- Get Max effective date
DECLARE @prices_landed_effective_date DATETIME
SELECT
    @prices_landed_effective_date =  MAX(pl.effective_date)
FROM
    prices_landed pl WITH (NOLOCK)
    left join plan_mstr pm with (nolock) on pm.plan_id = pl.plan_id  
    left join pricesets ps with (nolock) on ps.spec_id = pm.spec_id  and ps.effective_date = pl.effective_date
WHERE
    pm.spec_id = @active_spec_id   
    and pm.active = 1  
    and pl.effective_date <= @effective_date
    and ps.active = 1
    and (pm.plan_name = @unmapped_plan_name or @unmapped_plan_name = '')

-----------------------------------------------------------
-- Determine which plan to use. It is possible for there to
-- be multiple matches for a given spec, plan name, and effective date.
-- If there are, we must choose the most recent one (highest plan id).
-----------------------------------------------------------
DECLARE @plan_id INT;

SELECT DISTINCT TOP 1
	@plan_id = pm.plan_id
FROM
	plan_mstr pm WITH (NOLOCK)
	JOIN prices_landed pl WITH (NOLOCK) ON pl.plan_id = pm.plan_id
WHERE
	pm.spec_id = @active_spec_id
	AND pm.plan_name = @unmapped_plan_name
	AND pm.active = 1
	AND (pm.end_date IS NULL OR pm.end_date >= CONVERT(DATE, GETDATE()))
	AND pl.effective_date = @prices_landed_effective_date
ORDER BY
	pm.plan_id DESC

-------------------------------------------------
-- Get the max and min builds.
-------------------------------------------------
declare @MaxMinBuilds table
( 
  application_id varchar(10),
  product_id varchar(10),
  area_id varchar(10),
  sub_area_id varchar(10),
  location_id int,
  max_build_id bigint,
  max_build_desc varchar(100),
  max_field_qty decimal(18,2),
  min_build_id bigint,
  min_build_desc varchar(100),
  min_field_qty decimal(18,2),
  std_build_id bigint,
  std_build_desc varchar(100),
  std_field_qty decimal(18,2)
  )

insert into @MaxMinBuilds
exec vds_optionPricingMaxMinBuilds @active_spec_id, @unmapped_plan_name, @prices_landed_effective_date


-------------------------------------------------
-- Get the initial result set.
-------------------------------------------------
declare @results table
(
  area_id varchar(50),
  area varchar(100),
  sub_area_id varchar(50),
  sub_area varchar(50),
  location_id int,
  application_id varchar(50),
  [application] varchar(50),
  product_id varchar(50),
  product varchar(50),
  elevation varchar(50),
  item varchar(200),       
  price_retail decimal(18,2),
  effective_date datetime,
  spec_id int,
  plan_version varchar(50),
  item_type varchar(50),
  item_no varchar(50),
  plan_id bigint,
  plan_mstr_plan_name varchar(50),
  contract_sort_order int,
  build_desc varchar(100),
  build_id varchar(50),
  [source] varchar(50)
)

insert into @results 
select distinct
	ar.area_id,
	ar.name as area,
	sar.sub_area_id,
	sar.name as sub_area,
	pl.location_id,
	ap.application_id,
	LTRIM(RTRIM(ap.name)) as [application],
	pr.product_id as product_id,
	LTRIM(RTRIM(pr.name)) as product,
	pl.elevation,
	ISNULL(bs.builder_style_name, pl.customer_item_name) as item,       
	pl.price_retail,
	pl.effective_date,
	pm.spec_id,
	pl.plan_version,
	pl.item_type,
	pl.item as item_no,
	pm.plan_id,
	pm.plan_name as plan_mstr_plan_name,
    ISNULL(bs.contract_sort_order, 9999999) AS contract_sort_order,
	case @group_walls
		when 1 then
			case
				when ap.application_id = '3' and rg.code in (2,3) then ar.name + ' Walls' 
				else mmb.std_build_desc 
			end
		else
			mmb.std_build_desc
	end as build_desc,
	case ap.application_id 
        when '3' then '' 
        else pl.build_id 
    end as build_id,
    'Contract' as [source]
from 
	prices_landed pl with (nolock)
	LEFT JOIN plan_builds pb with (nolock) on pb.build_id = pl.build_id	
	LEFT JOIN plan_mstr pm with (nolock) on pm.plan_id = pb.plan_id 
	LEFT JOIN areas ar with (nolock) on ar.area_id = pl.area_id
	LEFT JOIN room_groups rg with (nolock) on rg.code = ar.room_group
	LEFT JOIN sub_areas sar with (nolock) on sar.sub_area_id = pl.sub_area_id
	LEFT JOIN applications ap with (nolock) on ap.application_id = pl.application_id
	LEFT JOIN products pr with (nolock) on pr.product_id = pl.product_id
	LEFT JOIN areas_sub_areas asa with (nolock) on asa.area_id = ar.area_id and asa.sub_area_id = sar.sub_area_id
	LEFT JOIN spec_mstr sm with (nolock) on sm.spec_id = pm.spec_id
	LEFT JOIN builder_styles bs with (nolock) on bs.builder_id = sm.builder_id and bs.spec_id = pm.spec_id and bs.item_type = pl.item_type and bs.item = pl.item and bs.effective_date = @prices_landed_effective_date
	LEFT JOIN plan_material pbm with (nolock) on pbm.plan_id = pb.plan_id and pbm.build_id = pb.build_id
	LEFT JOIN spec_areas_items sai with (nolock) on sai.spec_id = pm.spec_id and sai.application_id = pl.application_id and sai.product_id = pl.product_id and sai.area_id = pl.area_id and sai.sub_area_id = pl.sub_area_id and (sai.location_id = pl.location_id or sai.location_id = 0) and sai.item_type = pl.item_type and sai.item = pl.item
	LEFT JOIN @MaxMinBuilds mmb on 
		case @build_type 
			when 'maximum' then mmb.max_build_id
			when 'minimum' then mmb.min_build_id
			else mmb.std_build_id 
		end = pl.build_id
where 
	pl.plan_id = @plan_id
	and pm.spec_id = @active_spec_id
	and pm.plan_name = @unmapped_plan_name --COLLATE SQL_Latin1_General_CP1_CS_AS
	and pl.effective_date = @prices_landed_effective_date 
    and ap.name = @application
    and (@product = '' OR pr.name = @product)
	and pl.build_id in (select 
							case @build_type 
								when 'maximum' then max_build_id 
								when 'minimum' then min_build_id 
								else std_build_id 
							end 
							from @MaxMinBuilds)
	and pbm.bill_qty > 0
	and (pr.product_id != 'B' or (pr.product_id = 'B' and ar.name in ('Whole House', 'Sides and Rear', 'Front Elevation')))
	and (asa.exclude_quick_price_display = 0 or asa.exclude_quick_price_display is null)
	and pm.active = 1  
	and (pm.end_date > getdate() or pm.end_date is null)
	and isnull(sai.excluded,0) <> 1

-- ------------------
-- Combine bath walls
-- ------------------
if @group_walls = 1
begin
	update 
		@results
	set
		sub_area =  
		case when application_id = '3' and rg.code in (2,3) then 'Tile Walls'
			else sub_area
		end,
		sub_area_id =
		case when application_id = '3' and rg.code in (2,3) then 'TW'
			else sub_area_id
		end
	from
		@results r 
		LEFT JOIN areas ar with (nolock) on ar.area_id = r.area_id
		LEFT JOIN room_groups rg with (nolock) on rg.code = ar.room_group	
end

-- --------------------------------------------------------------------------------------
-- fix required because estimating might incorrectly assign multiple locations to an area
-- --------------------------------------------------------------------------------------
declare @location_id int
declare @area varchar(100)
declare @sub_area varchar(50)
declare c cursor for
select
	area,
	sub_area
from
	(
		select distinct
			area,
			sub_area,
			location_id
		from
			@results
		where
			application_id = '3'
	) t1
group by
	area, 
	sub_area
having 
	count(*) > 1
open c
fetch next from c into @area, @sub_area
while @@fetch_status = 0
begin
	select top 1 @location_id = location_id from @results where application_id = '3' and area = @area and sub_area = @sub_area
	update @results 
		set location_id = @location_id
	where
		application_id = '3'
		and area = @area 
		and sub_area = @sub_area
	fetch next from c into @area, @sub_area
end
close c
deallocate c
-- ----------------------
-- end of location id fix
-- ----------------------


update @results
set
    area = case build_desc
               when null then area
               else build_desc
           end,
    sub_area = case build_desc
                   when null then sub_area
                   else ''
               end
from
    @results


select
	area_id,
	area,
	sub_area,
	sub_area_id,
	location_id,
	application_id,
	[application],
	product_id,
	product,
	elevation,
	item,       
	((CEILING(SUM(price_retail) / 10)) * 10) as price,
	effective_date,
	spec_id,
	plan_version,
	item_type,
	item_no,
	plan_id,
	plan_mstr_plan_name,
    contract_sort_order,
	build_desc,
	build_id,
    [source]
from 
	@results
where
    item NOT LIKE '%edge%'
    AND item NOT LIKE '%pad%'
group by
	area_id,
	area,
	sub_area,
	sub_area_id,
	location_id,
	application_id,
	[application],
	product_id,
	product,
	elevation,
	item,       
	effective_date,
	spec_id,
	plan_version,
	item_type,
	item_no,
	plan_id,
	plan_mstr_plan_name,
    contract_sort_order,
	build_desc,
	build_id,
    [source]
GO
