
-- @sql_execute = 1 will execute the script, @sql_execute = 0 will not execute
declare @sql_execute bit = 1;
-- @sql_verbose = 1 will print out information during the execution of the script,
declare @sql_verbose bit = 1;

if @sql_verbose = 1
begin 
    print 'Starting merge to turn on time on site feature for builders';
end

-- @sql_dbs
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
    declare @db_names varchar(max);
    select @db_names = coalesce(@db_names + ', ', '') + db_name from @sql_dbs where db_found = 1;
    print @db_names;
    print 'Databases to execute against: ' + @db_names;
END

declare @feature_id int = 67; 

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
    set @sql = 'merge builder_features as target ' + char(13) + char(10) +
               'using (' + char(13) + char(10) +'use [' + @db_name + '];' + char(13) + char(10) +
               'select' + char(13) + char(10) +
               'o.organization_id,' + char(13) + char(10) +
               +cast(@feature_id as varchar(2)) + ' as feature_id,' + char(13) + char(10) +
               '1 as [value],' + char(13) + char(10) +
               '''vdsadmin'' as author,'  + char(13) + char(10) +
               'getdate() as create_date,'  + char(13) + char(10) +
               '''vdsadmin'' as modifier,'  + char(13) + char(10) +
               'getdate() as modified_date'  + char(13) + char(10) +
               'from veosolutionssecurity_organizations as o' + char(13) + char(10) +
               ') as source on target.organization_id = source.organization_id '  + char(13) + char(10) +
               'and target.feature_id = source.feature_id '  + char(13) + char(10) +
               'when not matched by target then '  + char(13) + char(10) +
               'insert (organization_id, feature_id, [value], author, create_date, modifier, modified_date)'  + char(13) + char(10) +
               'values (source.organization_id, source.feature_id, source.[value], source.author, source.create_date, source.modifier, source.modified_date)'  + char(13) + char(10) +
               'when matched then '  + char(13) + char(10) +
               'update set target.[value] = source.[value],'  + char(13) + char(10) +
               'target.modifier = source.modifier,'  + char(13) + char(10) +
               'target.modified_date = source.modified_date;'


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


