declare @sql_execute bit = 0;
declare @sql_verbose bit = 1;

if @sql_verbose = 1
begin 
    print 'Starting removal script for rm00101';
end

declare @sql_dbs table (
    db_name varchar(255),
    enabled bit,
    db_found bit
)
insert into @sql_dbs (db_name, enabled)
values ('VeoSolutions_DEV', 1),
       ('VeoSolutions_QA', 0),
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
    print 'Databases to execute against:';
    select db_name from @sql_dbs where db_found = 1;
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

    set @sql = 'use [' + @db_name + '];' + char(13) + char(10) +
        'if exists drop procedure [dbo].[vs_selCustomerClass];' + char(13) + char(10) +
        'if exists drop procedure [dbo].[vds_selSpecCustomEdge];' + char(13) + char(10) +
        'if exists drop synonym [dbo].[veo_rm00101];'

    if @sql_verbose = 1
    begin 
        print 'Executing SQL: ';
        print @sql;
    end

    if @sql_execute = 1
    begin 
        exec sp_execute @sql;
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