
-- @sql_execute = 1 will execute the script, @sql_execute = 0 will not execute
declare @sql_execute bit = 1;
-- @sql_verbose = 1 will print out information during the execution of the script,
declare @sql_verbose bit = 1;

declare @VisualizationProviderId uniqueidentifier = 'cc4c17fb-25ed-47f2-af05-af576bbaf6ee';

if @sql_verbose = 1
begin 
    print 'Starting update to update urls for VDS Visualization Provider with ID : ' + cast(@VisualizationProviderId as nvarchar(36));
    if @sql_execute = 0 
    begin
        print 'SQL execution is disabled. No changes will be made.';
    end
    else 
    begin
        print 'SQL execution is enabled. Changes will be made.';
    end
end

declare @UrlTable table ([column] nvarchar(1000), [url] nvarchar(1000));
insert into @UrlTable ([column], [url])
values 
    ('RenderUrl', 'https://apirc.aareas.com/api/Image/GetImage/v2/buildon'),
    --('ConfigurationUrl', 'https://apirc.aareas.com/api/SceneSurface/GetClientSurfaceList/b73ce491-bc27-42a7-ad85-6463eca43bfd'),
    --('RenderableProductUrl', 'https://apirc.aareas.com/api/ClientProduct/GetClientProductlist/BuildOn'),
    ('GetAllPackagesUrl', 'https://apirc.aareas.com/api/ClientProduct/GetClientProductPackageList/false/veodesignstudio/b73ce491-bc27-42a7-ad85-6463eca43bfd');

if @sql_verbose = 1
begin
    print 'Updating URLs for VisualizationProviderId: ' + cast(@VisualizationProviderId as nvarchar(36));
    print 'URLs to be updated:';
    declare @updates nvarchar(max);
    select @updates = coalesce(@updates + ', ', '') + [column] + ' = ' + [url] from @UrlTable;
    print @updates;
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
       ('VeoSolutions_PREVIEW', 1),
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

declare @sql nvarchar(max);
declare @db_name varchar(255);

DECLARE db_cursor CURSOR FOR
SELECT db_name FROM @sql_dbs WHERE db_found = 1;

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @db_name;
WHILE @@FETCH_STATUS = 0
BEGIN
    if @sql_verbose = 1
    begin
        print 'Updating database: ' + @db_name;
    end

        set @sql = 'USE [' + @db_name+ ']; ' + char(13) + char(10) + 
                   'update [dbo].[VisualizationProvider] ' + char(13) + char(10) +
                     'set ' + char(13) + char(10) +
                        (select string_agg('[' + [column] + '] = ''' + [url] + '''', ', ' + char(13) + char(10))
                        from @UrlTable) + char(13) + char(10) +
                        'where Id = '''+cast(@VisualizationProviderId as nvarchar(36))+'''; ' + char(13) + char(10);

        if @sql_execute = 1
        begin
            exec sp_executesql @sql;
        end
        if @sql_verbose = 1
        begin
            print 'SQL Generated: ' + @sql;
        end

    FETCH NEXT FROM db_cursor INTO @db_name;
END
CLOSE db_cursor;
DEALLOCATE db_cursor;

if @sql_verbose = 1
begin
    print 'Finished updating URLs for VisualizationProviderId: ' + cast(@VisualizationProviderId as nvarchar(36));
end