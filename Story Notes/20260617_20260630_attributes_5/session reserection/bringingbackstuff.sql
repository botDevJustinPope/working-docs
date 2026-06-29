
declare @user_id uniqueidentifier = '34d653bc-87ae-4522-a681-092e1d871b36',
        @session_id uniqueidentifier = '09558911-ceaf-4d06-b800-ac120766c7cc',
        @delete_datetime datetime = '2026-06-26 10:48:45.727',
        @new_session_id uniqueidentifier = 'b74a0eed-4d59-4816-af54-ef84aed57ea0'

drop table if exists #temp1_catalog_selections
drop table if exists #temp1_homebuyer_catalog_estimated_selections
drop table if exists #temp1_homebuyer_catalog_nonestimated_selections
drop table if exists #temp1_homebuyer_catalog_price_level_filters

/*
select
*
from [VEOSolutions].[dbo].[z_account_organization_user_profile_plan_catalog_sessions]
where [account_id] = 'bab32b7e-3ada-497c-862e-e5083971cc59'
    and [organization_id] = '59c673fe-79f5-42cb-823e-76eb2066a081'
    and [user_id] = @user_id*/

select
*
into #temp1_catalog_selections
from [VEOSolutions].[dbo].[z_catalog_selections] cs
where cs.[session_id] = @session_id
    and cs.[z_action] = 'delete'
    and cs.[z_time] between dateadd(minute, -2, @delete_datetime) and dateadd(minute, 2, @delete_datetime)

select
*
into #temp1_homebuyer_catalog_estimated_selections
from [VEOSolutions].[dbo].[z_homebuyer_catalog_estimated_selections]
where [session_id] = @session_id
    and [z_action] = 'delete'
    and [z_time] between dateadd(minute, -2, @delete_datetime) and dateadd(minute, 2, @delete_datetime)

select
*
into #temp1_homebuyer_catalog_nonestimated_selections
from [VEOSolutions].[dbo].[z_homebuyer_catalog_nonestimated_selections]
where [session_id] = @session_id
    and [z_action] = 'delete'
    and [z_time] between dateadd(minute, -2, @delete_datetime) and dateadd(minute, 2, @delete_datetime)

select
*
into #temp1_homebuyer_catalog_price_level_filters
from [VEOSolutions].[dbo].[z_homebuyer_catalog_price_level_filters]
where [session_id] = @session_id
    and [z_action] = 'delete'
    and [z_time] between dateadd(minute, -2, @delete_datetime) and dateadd(minute, 2, @delete_datetime)


begin transaction

insert into [VEOSolutions].[dbo].[homebuyer_catalog_estimated_selections] (
    [session_id],
    [application_id],
    [product_id],
    [area_id],
    [sub_area_id],
    [build_id],
    [price_level_type],
    [price_level_id],
    [selected_option_id]
)
select
@new_session_id as [session_id],
application_id,
product_id,
area_id,
sub_area_id,
build_id,
price_level_type,
price_level_id,
selected_option_id
from #temp1_homebuyer_catalog_estimated_selections

insert into [VEOSolutions].[dbo].[catalog_selections] (
    [session_id],
    [row_id],
    [account_id],
    [organization_id],
    [community],
    [series],
    [plan],
    [application],
    [product],
    [area],
    [area_id],
    [sub_area],
    [sub_area_id],
    [item_type],
    [item_no],
    [item],
    [vendor],
    [standard],
    [qty],
    [cost],
    [price],
    [selected],
    [notes],
    [option_pricing_display],
    [mutually_exclusive],
    [build_data],
    [original_build_data],
    [source],
    [build_id],
    [gpc],
    [model],
    [make_std],
    [is_credit],
    [option_id],
    [stage],
    [is_package],
    [category_id]
)
select
    @new_session_id as [session_id],
    cs1.[row_id],
    cs1.account_id,
    cs1.organization_id,
    cs1.community,
    cs1.series,
    cs1.[plan],
    cs1.application,
    cs1.product,
    cs1.area,
    cs1.area_id,
    cs1.sub_area,
    cs1.sub_area_id,
    cs1.item_type,
    cs1.item_no,
    cs1.item,
    cs1.vendor,
    cs1.[standard],
    cs1.qty,
    cs1.cost,
    cs1.price,
    cs1.selected,
    cs1.notes,
    cs1.[option_pricing_display],
    cs1.[mutually_exclusive],
    cs1.[build_data],
    cs1.[original_build_data],
    cs1.[source],
    cs1.[build_id],
    cs1.[gpc],
    cs1.[model],
    cs1.[make_std],
    cs1.[is_credit],
    cs1.[option_id],
    cs1.[stage],
    cs1.[is_package],
    cs1.[category_id]
from #temp1_homebuyer_catalog_nonestimated_selections t1
inner join #temp1_catalog_selections cs1 on cs1.row_id = t1.row_id
left join [VEOSolutions].[dbo].[catalog_selections] cs2 on cs2.[session_id] = @new_session_id and 
                                                            cs2.[application] = cs1.[application] and 
                                                            cs2.[product] = cs1.[product] and 
                                                            cs2.[area] = cs1.[area] and 
                                                            cs2.[sub_area] = cs1.[sub_area] and 
                                                            cs2.[item_no] = cs1.[item_no] and
                                                            cs2.[item] = cs1.[item]
where cs2.[row_id] is null

insert into [VEOSolutions].[dbo].[homebuyer_catalog_nonestimated_selections] (
    [session_id],
    [row_id],
    [quantity]
)
select
@new_session_id as [session_id],
cs2.[row_id],
t1.quantity
from #temp1_homebuyer_catalog_nonestimated_selections t1
inner join #temp1_catalog_selections cs1 on cs1.row_id = t1.row_id
inner join [VEOSolutions].[dbo].[catalog_selections] cs2 on cs2.[session_id] = @new_session_id and 
                                                            cs2.[application] = cs1.[application] and 
                                                            cs2.[product] = cs1.[product] and 
                                                            cs2.[area] = cs1.[area] and 
                                                            cs2.[sub_area] = cs1.[sub_area] and 
                                                            cs2.[item_no] = cs1.[item_no] and
                                                            cs2.[item] = cs1.[item]

insert into [VEOSolutions].[dbo].[homebuyer_catalog_price_level_filters] (
    [id],
    [session_id],
    [room_id],
    [application_id],
    [product_id],
    [item_no]
)
select
newid() as [id],
@new_session_id as [session_id],
room_id,
application_id,
product_id,
item_no
from #temp1_homebuyer_catalog_price_level_filters


commit transaction
