/*
USE [VeoSolutions_DEV];
USE [VeoSolutions_QA];
USE [VeoSolutions_Preview];
USE [VeoSolutions_Staging];


*/


declare @spec_id int = 3520
declare @add bit = 1

declare @application_id varchar(10) = '2'
declare @product_id varchar(10) = 'O'
declare @item_type varchar(10) = 'labor'
declare @item_class varchar(50) = 'edge'

declare @labor_codes table (
	laborCode varchar(100)
);
insert into @labor_codes
values ('E114C'), ('BNES2'), ('WES2');

with spec_items as (
						select 
							@spec_id as [spec_id],
                            row_number() over (order by (select null)) + (select max(line_no) from veo_spec_areas_items where spec_id = @spec_id) as [line_no],
							@application_id as [application_id],
							@product_id as [product_id],
							spec_plan_builds_area_sub_area.area_id as [area_id],
							spec_plan_builds_area_sub_area.sub_area_id as [sub_area_id],
							0 as [location_id],
							'labor' as [item_type],
							labor.[code] as [item],
							labor.[description] as [item_description],
							0 as [included],
							1 as [excluded],
							'justinpo' as [author],
							getdate() as [date]
						from (
							select 
								vlc.[code],
								vlc.[description]
							from @labor_codes lc
							inner join Veo_labor_codes vlc on vlc.code = lc.laborCode
							) as labor
							cross apply (
								select distinct
									vpb.area_id,
									vpb.sub_area_id			
								from
									veo_spec_mstr vsm
									left join Veo_plan_mstr vpm on vsm.spec_id = vpm.spec_id
									left join Veo_plan_builds vpb on vpb.plan_id = vpm.plan_id
								where vsm.spec_id = @spec_id
								and vpb.application_id = @application_id
								and vpb.product_id = @product_id ) as spec_plan_builds_area_sub_area )

merge into [veo_spec_areas_items] as [target]
using spec_items as [source]
on [target].spec_id = [source].spec_id
and [target].application_id = [source].application_id
and [target].product_id = [source].product_id
and [target].area_id = [source].area_id
and [target].sub_area_id = [source].sub_area_id
and [target].location_id = [source].location_id
and [target].item_type = [source].item_type
and [target].item = [source].item
when matched and @add = 0 then
    delete
when not matched by target and @add = 1 then
    insert (spec_id, line_no, application_id, product_id, area_id, sub_area_id, location_id, item_type, item, item_description, included, excluded, author, create_date, modifier, modified_date)
    values (source.spec_id, source.line_no, source.application_id, source.product_id, source.area_id, source.sub_area_id, source.location_id, source.item_type, source.item, source.item_description, source.included, source.excluded, source.author, source.date, source.author, source.date);



