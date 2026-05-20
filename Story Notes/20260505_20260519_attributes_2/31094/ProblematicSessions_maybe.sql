declare @days_past int = -90; -- how many days back to look for sessions
declare @dbTarget varchar(50) = '<db_name>';
declare @target_dbs table (database_name sysname)
insert into @target_dbs values ('VeoSolutions'),('Eplan_VeoSolutions');

drop table if exists #sessions;

create table #sessions (
    [stack] varchar(250),
    [session_id] uniqueidentifier,
    [account_id] uniqueidentifier,
    [organization_id] uniqueidentifier,
    [org_name] varchar(250)
) 

declare @sql_string nvarchar(max) = '
insert into #sessions
select
    ''['+@dbTarget+']'' as stack,
    s.session_id,
    s.account_id,
    s.organization_id,
    o.[name] as organization_name
from ['+@dbTarget+'].[dbo].[account_organization_user_profile_plan_catalog_sessions] s
inner join ['+@dbTarget+'].[dbo].[VeoSolutionsSecurity_account_organizations] ao on ao.account_id = s.account_id and ao.organization_id = s.organization_id
inner join ['+@dbTarget+'].[dbo].[VeoSolutionsSecurity_organizations] o on o.organization_id = ao.organization_id
cross apply (
    /*
    Does this session have any selections with area-based pricing where the bill quantity is greater than 1?
    */
    select top 1
        1 as found
    from ['+@dbTarget+'].[dbo].[catalog_selections] cs 
    inner join ['+@dbTarget+'].[dbo].[catalog_selections_areas] csa on csa.session_id = s.session_id and csa.build_id = cs.build_id and csa.selected > 0
    inner join ['+@dbTarget+'].[dbo].[catalog_selections_area_details] csad on csad.session_id = s.session_id 
                                                                        and csad.application = cs.application
                                                                        and csad.product = cs.product
                                                                        and csad.area = csa.area
                                                                        and csad.item_type = ''material''
                                                                        and csad.price_type = ''area''
                                                                        and csad.bill_qty > 1
    where cs.session_id = s.session_id
    UNION
    /*
    Does this session have any selections where the field is area priced and the other selectable bom lines have non zero price?
    */
    select top 1
        1 as found 
    from ['+@dbTarget+'].[dbo].[catalog_selections] cs 
    inner join ['+@dbTarget+'].[dbo].[catalog_selections_areas] csa on csa.session_id = s.session_id and csa.build_id = cs.build_id and csa.selected > 0
    inner join ['+@dbTarget+'].[dbo].[catalog_selections_area_details] csad on csad.session_id = s.session_id 
                                                                        and csad.application = cs.application
                                                                        and csad.product = cs.product
                                                                        and csad.area = csa.area
                                                                        and csad.item_type = ''material''
                                                                        and csad.price_type = ''area''
                                                                        and csad.item_id = ''field''
    cross apply (
        /*
        Flat rate pricing is when the field is area priced
        other selectable bom lines in the wizard are to look at the override boolean on osp_selItemPrice to know if there price is zero or not
        If the bom line is selectable and has a non zero price, then this could cause suspicion from the user / designer
        */
        select top 1
            1 as found
        from ['+@dbTarget+'].[dbo].[catalog_selections_area_details] o_csad 
        where o_csad.session_id = s.session_id 
            and o_csad.application = cs.application
            and o_csad.product = cs.product
            and o_csad.area = csa.area
            and o_csad.selectable = 1
            and o_csad.item_type = ''material''
            and o_csad.item_id <> ''field''
            and o_csad.homeowner_price > 0
    ) other_selectable_bom_lines
    where cs.session_id = s.session_id
) area_selections
where s.[status] = 1 -- active status
and s.[create_date] >= dateadd(day, -90, getdate()) -- sessions created in the last 90 days
--and selections.count > 0 -- only sessions with at least one selection
';

declare @current_db sysname;
declare @cursor_sql nvarchar(max);
declare db_cursor cursor for 
    select [database_name] from @target_dbs;
open db_cursor;
fetch next from db_cursor into @current_db;
while @@fetch_status = 0
begin
    print 'Processing database: ' + @current_db;
    set @cursor_sql = replace(@sql_string, @dbTarget, @current_db);
    exec sp_executesql @cursor_sql;
    fetch next from db_cursor into @current_db;
end
close db_cursor;
deallocate db_cursor;

select * from #sessions
order by [stack], [account_id], [organization_id]