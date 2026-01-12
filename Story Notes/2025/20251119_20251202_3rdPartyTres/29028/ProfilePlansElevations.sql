/*
     !!!!READ ME FIRST!!!!
     This script is used to update Profile Plans with elevations that have been trunctated to 25 characters.

     This script can be run in two modes:
        1. Query Mode: This mode will query all Profile Plans with trunctated elevations and output the results to a temp table.
            To run in this mode, set the @is_Updating variable to 0.
        2. Update Mode: This mode will update all Profile Plans with the correct elevation from the organization elevations table.
            To run in this mode, set the @is_Updating variable to 1.
    
    Before running the script, ensure that the target databases and stacks are correct in the @dbTargets table.

    Preferred usage is to first run in Query Mode to review the results, then switch to Update Mode to apply the changes.
    There are no results from the update mode, so use the query mode first to confirm what changes should be made,
    then switch to update mode to apply the changes and confirm the messages line up with the query.
    
*/
declare @sql_query_execution varchar(max) = '
insert into ##result_table
select 
    ''<stack>'' as stack_name, o.[name], oe.organization_id, pp.profile_id, pp.elevation as [pp_Elevation], oe.elevation as [o_Elevation]
from <db_str>.dbo.account_organization_user_profile_plan pp
left join <db_str>.dbo.VeoSolutionsSecurity_organization_elevations oe on pp.elevation = substring(oe.elevation, 1, 25) and pp.organization_id = oe.organization_id
left join <db_str>.dbo.vss_organizations o on pp.organization_id = o.organization_id
where len(oe.elevation) > 25',
@sql_update_execution varchar(max) = '
update pp
    set pp.elevation = oe.elevation
from <db_str>.dbo.account_organization_user_profile_plan pp
left join <db_str>.dbo.VeoSolutionsSecurity_organization_elevations oe on pp.elevation = substring(oe.elevation, 1, 25) and pp.organization_id = oe.organization_id
where len(oe.elevation) > 25',
@targetSTR varchar(10) = '<db_str>',
@targetStack varchar(40) = '<stack>',
@is_Updating bit =  1; -- 1 = Update, 0 = Query

declare @dbTargets table (db_str varchar(50), stack_name varchar(50));
insert into @dbTargets 
values  /**/('VeoSolutions_DEV', 'Development - DEV'), 
        ('VeoSolutions_QA', 'Quality Assurance - QA'), 
        ('VeoSolutions_PREVIEW', 'Preview - PREVIEW'), 
        ('VeoSolutions_Staging', 'Staging')/*, 
        ('[VeoSolutions]', 'Production - VeoSolutions'), 
        ('[EPLAN_VeoSolutions]', 'Production - EPLAN_VeoSolutions'),
        ('[AFI_VeoSolutions]', 'Production - AFI_VeoSolutions'),
        ('[CCDI_VeoSolutions]', 'Production - CCDI_VeoSolutions')*/;

if @is_Updating = 0
begin
    create table ##result_table (stack_name varchar(40), organization_name varchar(100), organization_id varchar(50), profile_id varchar(50), [Profile Plan Elevation] varchar(100), [Organization Elevation] varchar(100));
end 

declare @dbstr varchar(50),
        @stack_name varchar(50),
        @exec_sql varchar(max);
declare db_cursor cursor for
select db_str, stack_name from @dbTargets;

open db_cursor
fetch next from db_cursor into @dbstr, @stack_name;
while @@FETCH_STATUS = 0
begin
    BEGIN TRY
        print 'Processing ' + @dbstr + ' - ' + @stack_name
        BEGIN TRANSACTION
        if @is_Updating = 1
        BEGIN 
            set @exec_sql = replace(replace(@sql_update_execution, @targetSTR, @dbstr), @targetStack, @stack_name)
        END
        ELSE
        BEGIN
            set @exec_sql = replace(replace(@sql_query_execution, @targetSTR, @dbstr), @targetStack, @stack_name)
        END
        exec(@exec_sql)
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        rollback transaction
        print 'Error in ' + @dbstr + ' - ' + @stack_name + ': ' + ERROR_MESSAGE()
    END CATCH
    
    fetch next from db_cursor into @dbstr, @stack_name
END

close db_cursor
deallocate db_cursor

if @is_Updating = 0
BEGIN
select * from ##result_table

drop table ##result_table
end


/*
update pp
    set pp.elevation = oe.elevation
from <db_str>.dbo.account_organization_user_profile_plan pp
left join <db_str>.dbo.VeoSolutionsSecurity_organization_elevations oe on pp.elevation = substring(oe.elevation, 1, 25) and pp.organization_id = oe.organization_id
where len(oe.elevation) > 25
*/