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
	laborCode varchar(100),
	build_id int
);
insert into @labor_codes
values ('E114C', 17273879), -- code E114C is '1 1/4" Classic Edge - Stone' and has been expcluded to the build 'Kitchen/Breakfast Island'
       ('BNES2', 12039582), -- code BNES2 is 'Bullnose Edge - 1 1/4" - Stone' and has been expcluded to the build 'Master Bath Seat'
       ('WES2', 12039573);  -- code WES2 is 'Waterfall Edge - 1 1/4" - Stone' and has been expcluded to the build 'Kitchen w/Range'
/*
-- builsd in spec with application product
select 
    vpb.build_id,
	vpb.build_desc
from veo_spec_mstr vsm
left join Veo_plan_mstr vpm on vsm.spec_id = vpm.spec_id
left join Veo_plan_builds vpb on vpb.plan_id = vpm.plan_id
where vsm.spec_id = @spec_id
and vpb.application_id = @application_id
and vpb.product_id = @product_id;
*/

with spec_items as (
						select 
							@spec_id as [spec_id],
                            row_number() over (order by (select null)) + (select max(line_no) from veo_spec_areas_items where spec_id = @spec_id) as [line_no],
							@application_id as [application_id],
							@product_id as [product_id],
							builds.area_id as [area_id],
							builds.sub_area_id as [sub_area_id],
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
								lc.[build_id],
								vlc.[description]
							from @labor_codes lc
							inner join Veo_labor_codes vlc on vlc.code = lc.laborCode
							) as labor
							inner join (
								select
									vpb.build_id,
									vpb.area_id,
									vpb.sub_area_id			
								from
									veo_spec_mstr vsm
									left join Veo_plan_mstr vpm on vsm.spec_id = vpm.spec_id
									left join Veo_plan_builds vpb on vpb.plan_id = vpm.plan_id
								where vsm.spec_id = @spec_id
								and vpb.application_id = @application_id
								and vpb.product_id = @product_id ) as builds on labor.build_id = builds.build_id )

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


