/*
===============================================================================
  Author: Justin Pope
  date: 2025-05-22
  title: removal of rm00101 script 
  description: 
    This script removes procedures and synonyms relate to rm00101.

    This script has an execute flag and verbose flag for execution. The 
    verbose flag will print out information durint the information of the
    script. The execute flag will execute the dynamic SQL produced by the 
    script.

    This script has a variable table for the databases toe execute against.

    Based on the configured databases, the script will first check if the
    databases exists on the server you are connected to. If the database
    exists, the script will execute the dynamic SQL against the database.
    The dynamic SQL utilize a drop if exists statement to remove the procedures
    and synonyms from the database.

===============================================================================
*/

-- @sql_execute = 1 will execute the script, @sql_execute = 0 will not execute
declare @sql_execute bit = 1;
-- @sql_verbose = 1 will print out information during the execution of the script,
declare @sql_verbose bit = 1;

if @sql_verbose = 1
begin 
    print 'Starting removal script for rm00101';
end

-- @sql_dbs
declare @sql_dbs table (
    db_name varchar(255),
    enabled bit,
    db_found bit
)
insert into @sql_dbs (db_name, enabled)
values ('VeoSolutions_DEV', 1),
       ('VeoSolutions_QA', 1),
       ('VeoSolutions_STAGING', 0),
       ('VeoSolutions_PREVIEW', 0),
       ('VeoSolutions', 0),
       ('AFI_VeoSolutions', 0),
       ('CCDI_VeoSolutions', 0),
       ('EPLAN_VeoSolutions', 0);

update tdbs 
    set db_found = 1
from @sql_dbs tdbs
join [master].sys.databases tdb
    on tdbs.db_name = tdb.name
where tdbs.db_name = tdb.name
    and tdbs.enabled = 1
    and tdb.state_desc = 'ONLINE';

if @sql_verbose = 1
begin 
    declare @db_names varchar(max);
    select @db_names = coalesce(@db_names + ', ', '') + db_name from @sql_dbs where db_found = 1;
    print @db_names;
    print 'Databases to execute against: ' + @db_names;
END

declare sql_cursor cursor for 
select db_name from @sql_dbs where db_found = 1;
declare @db_name varchar(255), @sql nvarchar(max);

open sql_cursor;
fetch next from sql_cursor into @db_name;
while @@fetch_status = 0
begin 
    if @sql_verbose = 1
    begin 
        print 'Executing against database: ' + @db_name;
    end

    -- set the data base context
    set @sql = 'use [' + @db_name + '];' + char(13) + char(10) +
    -- drop vs_selCustomerClass
        'drop procedure if exists [dbo].[vs_selCustomerClass];' + char(13) + char(10) +
    -- drop vds_selSpecCustomEdge
        'drop procedure if exists [dbo].[vds_selSpecCustomEdge];' + char(13) + char(10) +
    -- drop veo_rm00101
        'drop synonym if exists [dbo].[veo_rm00101];'

    if @sql_verbose = 1
    begin 
        print 'Executing SQL: ';
        print @sql;
    end

    if @sql_execute = 1
    begin 
        exec sp_executesql @sql;
    end 

    if @sql_verbose = 1
    begin 
        print 'Executed against database: ' + @db_name;
    end

    fetch next from sql_cursor into @db_name;
end 
close sql_cursor;
deallocate sql_cursor;

if @sql_verbose = 1
begin 
    print 'Finished removal script for rm00101';
end