/*

    Theme Variables Export/Import Script
    This script is designed to export theme-related variables from a source database and import them into multiple target databases.

    THIS SHOULD BE RAN FROM THE DEV SQL SERVER, ALWAYS!!!

    In put parameters:
    - @source_db: The name of the source database from which to export theme variables.
    - @source_DB_prod: Indicates if the source database is in production (1 for PROD, 0 for DEV).
    - @export_variables: Set to 1 to export ThemeableVariable.
    - @export_group_variables: Set to 1 to export ThemeableGroupVariable.
    - @export_palette_variables: Set to 1 to export ThemeablePaletteVariable.
    - @export_mappings: Set to 1 to export ThemeableGroupVariableMapping.
    - @delete_existing_records_on_target: Set to 1 to delete existing records in the target database after importing.
    - #temp_input_destination_db: A temporary table to hold the list of target databases to import into, including their production status.
        Databases configured in this script are:
        - 'VeoSolutions_QA' (0)
        - 'VeoSolutions_STAGING' (0)
        - 'VeoSolutions_PREVIEW' (0)
        - 'VeoSolutions' (1) 
        - 'AFI_VeoSolutions' (1) 
        - 'CCDI_VeoSolutions' (1) 
        - 'EPLAN_VeoSolutions' (1)
        Comment out or add target databases as needed.
    
    It checks for the following in both the source and target databases:
    - ThemeableVariable
    - ThemeableGroupVariable
    - ThemeablePaletteVariable
    - ThemeableGroupVariableMapping

    The script uses temporary tables to export the source data. For each target database, it utilizes a merge statement to insert or update the records.
    If @delete_existing_records_on_target is set to 1, it will delete any records in the target database that do not exist in the source database after the import.
    This helps to ensure that the target database is in sync with the source database for the specified theme-related variables.
    Also, the merge statements are constructed with a values statement to handle going across the server link. The number of records merged at once is limited by
    the variable @max_variablestomerge to avoid hitting limits of nvarchar(max) or other performance issues. This can be adjusted based on performance needs.
    Note: Ensure that you have the necessary permissions to read from the source database and write to the target databases. 
    Also, ensure that the linked server is properly configured if using a production database.

*/

use [master];
go

declare @source_db nvarchar(50) = 'EPLAN_VeoSolutions',
        @messages nvarchar(250) = N'',
        @source_DB_prod bit = 1,
        @export_variables bit = 0,
        @export_group_variables bit = 0,
        @export_palette_variables bit =1,
        @export_mappings bit = 0,
        @delete_existing_records_on_target bit = 1,
        @SQL nvarchar(max) = N'';

declare @source_variables_exists bit = 0,
        @source_group_variables_exists bit = 0,
        @source_palette_variables_exists bit = 0,
        @source_mappings_exists bit = 0,
        @target_variables_exists bit = 0,
        @target_group_variables_exists bit = 0,
        @target_palette_variables_exists bit = 0,
        @target_mappings_exists bit = 0;

drop table if exists #temp_source_db;
drop table if exists #temp_input_destination_db;
drop table if exists #temp_variables;
drop table if exists #temp_group_variables;
drop table if exists #temp_palette_variables;
drop table if exists #temp_mappings;
drop table if exists #temp_target_db

create table #temp_input_destination_db (
    [dbName] sysname,
    [prod] bit
);

insert into #temp_input_destination_db ([dbName], [prod])
values --('VeoSolutions_DEV', 0) -- env: dev, db: dev
    --, ('VeoSolutions_QA', 0) -- env: qa, db: qa
    --, ('VeoSolutions_STAGING', 0) -- env: staging, db: staging
    --, ('VeoSolutions_PREVIEW', 0) -- env: preview, db: preview
    --, ('VeoSolutions', 1) -- env: prod, stack: WBS
    --, ('AFI_VeoSolutions', 1) -- env: prod, stack: AFI
    --, ('CCDI_VeoSolutions', 1) -- env: prod, stack: CCDI
    --, 
	('EPLAN_VeoSolutions', 1) -- env: prod, stack: EPLAN
    ;

create table #temp_source_db (
    [dbName] sysname,
    [prod] bit,
    [variables_exists] bit default 0,
    [group_variables_exists] bit default 0,
    [palette_variables_exists] bit default 0,
    [mappings_exists] bit default 0
);
print '/*'
print 'Checking if source database exists: ' + @source_db;

-- check if source database exists
set @SQL = 'insert into #temp_source_db ([dbName], [prod])
select '''+@source_DB+''' as dbName, '''+cast(@source_DB_PROD as nvarchar(1))+''' as prod
where exists (select 1 from '+case when @source_DB_PROD = 1 then '[VDS_PROD].' else '' end +'[master].sys.databases where name = '''+@source_DB+''')';
exec sp_executesql @SQL;

if (select count(*) from #temp_source_db) = 0
begin
    if @source_DB_PROD = 1
    begin
        set @messages = 'Source database '+@source_DB+' does not exist in PROD.';
    end
    else
    begin
        set @messages = 'Source database '+@source_DB+' does not exist DEV.';
    end
    RAISERROR(@messages, 16, 1);
    return;
end

print 'Checking if source database has ThemeableVariable, ThemeableGroupVariable, ThemeablePaletteVariable, and ThemeableGroupVariableMapping tables: ' + @source_db;

set @SQL = N'
use [master];
update #temp_source_db
    set [variables_exists] = case 
        when exists (select 1 from ' + 
        case when @source_DB_prod = 1 then '[VDS_PROD].['+@source_db+'].[' else '['+@source_db+'].[' end + 'sys].[tables] t1
        where t1.[name] = ''ThemeableVariable'')
        then 1
        else 0
    end
where [dbName] = '''+@source_db+''';

update #temp_source_db
    set [group_variables_exists] = case 
        when exists (select 1 from '  + 
        case when @source_DB_prod = 1 then '[VDS_PROD].['+@source_db+'].[' else '['+@source_db+'].[' end + 'sys].[tables] t1
        where t1.[name] = ''ThemeableGroupVariable'')
        then 1
        else 0
    end
where [dbName] = '''+@source_db+''';

update #temp_source_db
    set [palette_variables_exists] = case 
        when exists (select 1 from '  + 
        case when @source_DB_prod = 1 then '[VDS_PROD].['+@source_db+'].[' else '['+@source_db+'].[' end + 'sys].[tables] t1
        where t1.[name] = ''ThemeablePaletteVariable'')
        then 1
        else 0
    end
where [dbName] = '''+@source_db+''';

update #temp_source_db
    set [mappings_exists] = case 
        when exists (select 1 from ' + 
        case when @source_DB_prod = 1 then '[VDS_PROD].['+@source_db+'].[' else '['+@source_db+'].[' end + 'sys].[tables] t1
        where t1.[name] = ''ThemeableGroupVariableMapping'')
        then 1
        else 0
    end
where [dbName] = '''+@source_db+''';
';
exec sp_executesql @SQL;

--select * from #temp_source_db;

select 
    @source_variables_exists = [variables_exists],
    @source_group_variables_exists = [group_variables_exists],
    @source_palette_variables_exists = [palette_variables_exists],
    @source_mappings_exists = [mappings_exists]
from #temp_source_db;

if @source_variables_exists = 0 and 
   @source_group_variables_exists = 0 and 
   @source_palette_variables_exists = 0 and 
   @source_mappings_exists = 0
begin
    set @messages = 'Source database '+@source_db+' does not have any of the required tables (ThemeableVariable, ThemeableGroupVariable, ThemeablePaletteVariable, ThemeableGroupVariableMapping).';
    RAISERROR(@messages, 16, 1);
    return;
end

create table #temp_variables (
    [Id] UNIQUEIDENTIFIER,
    [CssName] NVARCHAR(100),
    [Name] NVARCHAR(100),
    [Description] NVARCHAR(500)
);
declare @varcnt int = 0;

if @source_variables_exists = 1 and @export_variables = 1
begin 
    print 'Exporting ThemeableVariable from source database: ' + @source_db;

    set @SQL = N'
    insert into #temp_variables ([Id], [CssName], [Name], [Description])
    select
        [Id], [CssName], [Name], [Description]
    from ' + case when @source_DB_prod = 1 then '[VDS_PROD].['+@source_db+'].[' else '['+@source_db+'].[' end + 'dbo].[ThemeableVariable]'

    exec sp_executesql @SQL;

    set @varcnt = (select count(*) from #temp_variables); -- Get the count of variables exported
    print 'Total ThemeableVariable records exported: ' + cast(@varcnt as nvarchar(10));

END

create table #temp_group_variables (
    [Id] UNIQUEIDENTIFIER,
    [Name] NVARCHAR(100),
    [Description] NVARCHAR(500)
)
declare @groupvarcnt int = 0;

if @source_group_variables_exists = 1 and @export_group_variables = 1
begin 
    print 'Exporting ThemeableGroupVariable from source database: ' + @source_db;

    set @SQL = N'
    insert into #temp_group_variables ([Id], [Name], [Description])
    select
        [Id], [Name], [Description]
    from ' + case when @source_DB_prod = 1 then '[VDS_PROD].['+@source_db+'].[' else '['+@source_db+'].[' end + 'dbo].[ThemeableGroupVariable]'

    exec sp_executesql @SQL;

    set @groupvarcnt = (select count(*) from #temp_group_variables); -- Get the count of group variables exported
    print 'Total ThemeableGroupVariable records exported: ' + cast(@groupvarcnt as nvarchar(10));

END

create table #temp_palette_variables (
    [Id] UNIQUEIDENTIFIER,
    [CssName] NVARCHAR(100),
    [Name] NVARCHAR(100),
    [Description] NVARCHAR(500)
)
declare @palettevarcnt int = 0;

if @source_palette_variables_exists = 1 and @export_palette_variables = 1
begin 
    print 'Exporting ThemeablePaletteVariable from source database: ' + @source_db;

    set @SQL = N'
    insert into #temp_palette_variables ([Id], [CssName], [Name], [Description])
    select
        [Id], [CssName], [Name], [Description]
    from ' + case when @source_DB_prod = 1 then '[VDS_PROD].['+@source_db+'].[' else '['+@source_db+'].[' end + 'dbo].[ThemeablePaletteVariable]'

    exec sp_executesql @SQL;

    set @palettevarcnt = (select count(*) from #temp_palette_variables); -- Get the count of palette variables exported
    print 'Total ThemeablePaletteVariable records exported: ' + cast(@palettevarcnt as nvarchar(10));

END

create table #temp_mappings (
    [ThemeableGroupVariableId] UNIQUEIDENTIFIER,
    [ThemeableVariableId] UNIQUEIDENTIFIER
)
declare @mappingscnt int = 0;

if @source_mappings_exists = 1 and @export_mappings = 1
begin 
    print 'Exporting ThemeableGroupVariableMapping from source database: ' + @source_db;

    set @SQL = N'
    insert into #temp_mappings ([ThemeableGroupVariableId], [ThemeableVariableId])
    select
        [ThemeableGroupVariableId], [ThemeableVariableId]
    from ' + case when @source_DB_prod = 1 then '[VDS_PROD].['+@source_db+'].[' else '['+@source_db+'].[' end + 'dbo].[ThemeableGroupVariableMapping]'

    exec sp_executesql @SQL;

    set @mappingscnt = (select count(*) from #temp_mappings); -- Get the count of mappings exported
    print 'Total ThemeableGroupVariableMapping records exported: ' + cast(@mappingscnt as nvarchar(10));

END

create table #temp_target_db (
    [dbName] sysname,
    [prod] bit,
    [variables_exists] bit default 0,
    [group_variables_exists] bit default 0,
    [palette_variables_exists] bit default 0,
    [mappings_exists] bit default 0
);

declare @cursor CURSOR;
declare @dbName sysname,
        @prod bit;
set @cursor = CURSOR FAST_FORWARD FOR
    select [dbName], [prod]
    from #temp_input_destination_db;
open @cursor;
fetch next from @cursor into @dbName, @prod;
while @@FETCH_STATUS = 0
BEGIN
    print 'Checking if target database exists: ' + @dbName;

    -- check if target database exists
    set @SQL = 'insert into #temp_target_db ([dbName], [prod])
    select '''+@dbName+''' as dbName, '''+cast(@prod as nvarchar(1))+''' as prod
    where exists (select 1 from '+case when @prod = 1 then '[VDS_PROD].' else '' end +'[master].sys.databases where name = '''+@dbName+''')';
    exec sp_executesql @SQL;

    if not exists(select 1 from #temp_target_db)
    begin
        if @prod = 1
        begin
            set @messages = 'Target database '+@dbName+' does not exist in PROD.';
        end
        else
        begin
            set @messages = 'Target database '+@dbName+' does not exist DEV.';
        end
        RAISERROR(@messages, 16, 1);
        fetch next from @cursor into @dbName, @prod;
        continue;
    end

    print 'Checking if target database (' + @dbName + ') has ThemeableVariable, ThemeableGroupVariable, ThemeablePaletteVariable, and ThemeableGroupVariableMapping tables';

    set @SQL = N'
    use [master];
    update #temp_target_db
        set [variables_exists] = case 
            when exists (select 1 from ' + 
            case when @prod = 1 then '[VDS_PROD].['+@dbName+'].[' else '['+@dbName+'].[' end + 'sys].[tables] t1
            where t1.[name] = ''ThemeableVariable'')
            then 1
            else 0
        end
    where [dbName] = '''+@dbName+''';
    update #temp_target_db
        set [group_variables_exists] = case 
            when exists (select 1 from ' + 
            case when @prod = 1 then '[VDS_PROD].['+@dbName+'].[' else '['+@dbName+'].[' end + 'sys].[tables] t1
            where t1.[name] = ''ThemeableGroupVariable'')
            then 1
            else 0
        end
    where [dbName] = '''+@dbName+''';
    update #temp_target_db
        set [palette_variables_exists] = case 
            when exists (select 1 from ' + 
            case when @prod = 1 then '[VDS_PROD].['+@dbName+'].[' else '['+@dbName+'].[' end + 'sys].[tables] t1
            where t1.[name] = ''ThemeablePaletteVariable'')
            then 1
            else 0
        end
    where [dbName] = '''+@dbName+''';
    update #temp_target_db
        set [mappings_exists] = case 
            when exists (select 1 from ' + 
            case when @prod = 1 then '[VDS_PROD].['+@dbName+'].[' else '['+@dbName+'].[' end + 'sys].[tables] t1
            where t1.[name] = ''ThemeableGroupVariableMapping'')
            then 1
            else 0
        end
    where [dbName] = '''+@dbName+''';
    ';
    exec sp_executesql @SQL;

    fetch next from @cursor into @dbName, @prod;
END
close @cursor;
deallocate @cursor;

--select * from #temp_target_db;
print '*/'
print '-- *** STARTING EXECUTABLE SQL ***'
set @cursor = CURSOR FAST_FORWARD FOR
    select [dbName], [prod], 
        [variables_exists],
        [group_variables_exists],
        [palette_variables_exists],
        [mappings_exists]
    from #temp_target_db;
open @cursor;
fetch next from @cursor into @dbName, @prod, 
    @target_variables_exists,
    @target_group_variables_exists,
    @target_palette_variables_exists,
    @target_mappings_exists;
while @@FETCH_STATUS = 0
begin 
    declare @max_variablestomerge int = 50; -- set a limit on how many variables to merge at once to avoid hitting limits of nvarchar(max) or other performance issues

    print 'use [' + @dbName + '];';
    print 'go';

    declare @Id UNIQUEIDENTIFIER,
            @CssName NVARCHAR(100),
            @Name NVARCHAR(100),
            @Description NVARCHAR(500),
            @ThemeableGroupVariableId UNIQUEIDENTIFIER,
            @ThemeableVariableId UNIQUEIDENTIFIER,
            @var_merge_cnt int = 0,
            @temp_sql_values nvarchar(max) = N'';

    if @target_variables_exists = 1 and @varcnt > 0
    BEGIN

        set @var_merge_cnt = 0;

        print '/* Inserting/Updating ThemeableVariable in target database: ' + @dbName + ' */' + char(10);
        print 'merge into ['+@dbName+'].[dbo].[ThemeableVariable] as target' + char(10) +
        'using (select src.* from ( ' + char(10) +
        'values '; -- Start the values clause for the merge statement

        declare @cursor_variables CURSOR;
        set @cursor_variables = CURSOR FAST_FORWARD FOR
            select [Id], [CssName], [Name], [Description] from #temp_variables;
        open @cursor_variables;
        fetch next from @cursor_variables into @Id, @CssName, @Name, @Description;
        while @@FETCH_STATUS = 0
        BEGIN
            set @var_merge_cnt += 1;
            if @var_merge_cnt > @varcnt
            begin 
                print '(''' + cast(@Id as nvarchar(36)) + ''', ' + isnull('''' + @CssName + '''', 'NULL') + ', ' + isnull('''' + @Name + '''', 'NULL') + ', ' + isnull('''' + @Description + '''', 'NULL') + '),';
            end 
            ELSE
            BEGIN
                print '(''' + cast(@Id as nvarchar(36)) + ''', ' + isnull('''' + @CssName + '''', 'NULL') + ', ' + isnull('''' + @Name + '''', 'NULL') + ', ' + isnull('''' + @Description + '''', 'NULL') + ')';
            end

            fetch next from @cursor_variables into @Id, @CssName, @Name, @Description;
        END
        close @cursor_variables;
        deallocate @cursor_variables;
        
        print ' ) as src ([Id], [CssName], [Name], [Description])  ) as source ' + char(10) +
        'ON target.[Id] = source.[Id]' + char(10) +
        'WHEN MATCHED THEN' + char(10) +
        'UPDATE SET' + char(10) +
        'target.[CssName] = source.[CssName],' + char(10) +
        'target.[Name] = source.[Name],' + char(10) +
        'target.[Description] = source.[Description],' + char(10) +
        'target.[Modifier] = ''SEED'',' + char(10) +
        'target.[ModifiedDate] = GETDATE()' + char(10) +
        'WHEN NOT MATCHED THEN ' + char(10) +
        'INSERT ([Id], [CssName], [Name], [Description], [Author], [CreateDate], [Modifier], [ModifiedDate]) ' + char(10) +
        'VALUES (source.[Id], source.[CssName], source.[Name], source.[Description], ''SEED'', GETDATE(), ''SEED'', GETDATE());' + char(10) +
        'go' + char(10); -- End the merge statement      

        if @delete_existing_records_on_target = 1
        begin 

            print '/* Deleting ThemeableVariable records in target database: ' + @dbName + ' that do not exist in the source database */' + char(10);
            print 'DELETE target' + char(10) +
                  'FROM  ['+@dbName+'].[dbo].[ThemeableVariable] as target' + char(10) +
                  'WHERE NOT EXISTS (' + char(10) +
                  'SELECT 1' + char(10) +
                  'FROM (' + char(10) +
                  'values ';

            set @var_merge_cnt = 0; -- Reset the variable count for the delete statement

            set @cursor_variables = CURSOR FAST_FORWARD FOR
                select [Id] from #temp_variables;
            open @cursor_variables;
            fetch next from @cursor_variables into @Id;
            while @@FETCH_STATUS = 0
            BEGIN
                set @var_merge_cnt += 1;
                if @var_merge_cnt > @varcnt
                begin 
                    print '(''' + cast(@Id as nvarchar(36)) + '''),';
                end 
                ELSE
                BEGIN
                    print '(''' + cast(@Id as nvarchar(36)) + ''')';
                end

                fetch next from @cursor_variables into @Id;
            END
            close @cursor_variables;
            deallocate @cursor_variables;

            print ') src ([Id])' + char(10) +
                  'WHERE target.[Id] = src.[Id]' + char(10) +
                  ');' + char(10) + 
                  'go' + char(10); -- End the delete statement
        end
    end

    if @target_group_variables_exists = 1 and @groupvarcnt > 0
    BEGIN

        set @var_merge_cnt = 0;

        print '/* Inserting/Updating ThemeableGroupVariable in target database: ' + @dbName + ' */' + char(10);
        print 'merge into ['+@dbName+'].[dbo].[ThemeableGroupVariable] as target' + char(10) +
        'using (select src.* from ( ' + char(10) +
        'values ' + char(10); -- Start the values clause for the merge statement

        declare @cursor_group_variables CURSOR;
        set @cursor_group_variables = CURSOR FAST_FORWARD FOR
            select [Id], [Name], [Description] from #temp_group_variables;
        open @cursor_group_variables;
        fetch next from @cursor_group_variables into @Id, @Name, @Description;
        while @@FETCH_STATUS = 0
        BEGIN
            set @var_merge_cnt += 1; -- Increment the variable count for each group variable processed
            if @var_merge_cnt < @groupvarcnt -- Check if we are still within the count of group variables to process
            begin 
                print '(''' + cast(@Id as nvarchar(36)) + ''', ' + isnull(''''+@Name+'''', 'NULL') + ', '+isnull('''' + @Description + '''', 'NULL') + '),';
            end
            ELSE
            begin 
                print '(''' + cast(@Id as nvarchar(36)) + ''', ' + isnull(''''+@Name+'''', 'NULL') + ', '+isnull('''' + @Description + '''', 'NULL') + ')';
            END

            fetch next from @cursor_group_variables into @Id, @Name, @Description;
        END
        close @cursor_group_variables;
        deallocate @cursor_group_variables;
        
        print ' ) as src ([Id], [Name], [Description]) ) as source' + char(10) +
              'ON target.[Id] = source.[Id]' + char(10) +
              'WHEN MATCHED THEN' + char(10) +
              'UPDATE SET ' + char(10) +
              'target.[Name] = source.[Name],' + char(10) +
              'target.[Description] = source.[Description],' + char(10) +
              'target.[Modifier] = ''SEED'',' + char(10) +
              'target.[ModifiedDate] = GETDATE()' + char(10) +
              'WHEN NOT MATCHED THEN ' + char(10) +
              'INSERT ([Id], [Name], [Description], [Author], [CreateDate], [Modifier], [ModifiedDate]) ' + char(10) +
              'VALUES (source.[Id], source.[Name], source.[Description], ''SEED'', GETDATE(), ''SEED'', GETDATE());' + char(10) +
              'go' + char(10); -- End the merge statement

        if @delete_existing_records_on_target = 1
        begin 
            print 'DELETE target' + char(10) + 
                  'FROM ['+@dbName+'].[dbo].[ThemeableGroupVariable] as target' + char(10) + 
                  'WHERE NOT EXISTS (' + char(10) + 
                  'SELECT 1' + char(10) + 
                  'FROM (' + char(10) + 
                  'values ';
                  
            set @var_merge_cnt = 0;
            
            set @cursor_group_variables = CURSOR FAST_FORWARD FOR
                select [Id] from #temp_group_variables;
            open @cursor_group_variables;
            fetch next from @cursor_group_variables into @Id;
            while @@FETCH_STATUS = 0
            BEGIN
                set @var_merge_cnt += 1; -- Increment the variable count for each group variable processed
                if @var_merge_cnt < @groupvarcnt -- Check if we are still within the count of group variables to process
                begin 
                    print ' (''' + cast(@Id as nvarchar(36)) + '''),';
                end
                ELSE
                begin 
                    print '(''' + cast(@Id as nvarchar(36)) + ''')';
                END

                fetch next from @cursor_group_variables into @Id;
            END
            close @cursor_group_variables;
            deallocate @cursor_group_variables;

            print ') src ([Id])' + char(10) + 
                  'WHERE target.[Id] = src.[Id]);' + char(10) + 
                  'go' + char(10); -- End the delete statement
        end
    end

    if @target_palette_variables_exists = 1 and (select count(*) from #temp_palette_variables) > 0
    BEGIN
        print '/*Inserting/Updating ThemeablePaletteVariable in target database: ' + @dbName + '*/' + char(10);

        set @var_merge_cnt = 0;

        print 'merge into  ['+@dbName+'].[dbo].[ThemeablePaletteVariable] as target' + char(10) + 
              'using ( SELECT * from (  values ' + char(10);
                
        declare @cursor_palette_variables CURSOR;
        set @cursor_palette_variables = CURSOR FAST_FORWARD FOR
            select [Id], [CssName], [Name], [Description] from #temp_palette_variables;
        open @cursor_palette_variables;
        fetch next from @cursor_palette_variables into @Id, @CssName, @Name, @Description;
        while @@FETCH_STATUS = 0
        BEGIN
            set @var_merge_cnt += 1; -- Increment the variable count for each palette variable processed

            if @var_merge_cnt < @palettevarcnt -- Check if we are still within the count of palette variables to process
            begin 
                print '(''' + cast(@Id as nvarchar(36)) + ''', ' + isnull(''''+@CssName+'''', 'NULL') + ', ' + isnull(''''+@Name+'''', 'NULL') + ', '+isnull('''' + @Description + '''', 'NULL') + '),';
            end
            ELSE
            begin 
                print'(''' + cast(@Id as nvarchar(36)) + ''', ' + isnull(''''+@CssName+'''', 'NULL') + ', ' + isnull(''''+@Name+'''', 'NULL') + ', '+isnull('''' + @Description + '''', 'NULL') + ')';
            END
            fetch next from @cursor_palette_variables into @Id, @CssName, @Name, @Description;
        END
        close @cursor_palette_variables;
        deallocate @cursor_palette_variables;

        print ' ) as src ([Id], [CssName], [Name], [Description]) ) as source' + char(10) + 
              'ON target.[Id] = source.[Id]' + char(10) + 
              'WHEN MATCHED THEN' + char(10) + 
              'UPDATE SET ' + char(10) + 
              'target.[CssName] = source.[CssName],' + char(10) + 
              'target.[Name] = source.[Name],' + char(10) + 
              'target.[Description] = source.[Description],' + char(10) + 
              'target.[Modifier] = ''SEED'',' + char(10) + 
              'target.[ModifiedDate] = GETDATE()' + char(10) + 
              'WHEN NOT MATCHED THEN ' + char(10) + 
              'INSERT ([Id], [CssName], [Name], [Description], [Author], [CreateDate], [Modifier], [ModifiedDate]) ' + char(10) + 
              'VALUES (source.[Id], source.[CssName], source.[Name], source.[Description], ''SEED'', GETDATE(), ''SEED'', GETDATE());' + char(10) + 
              'go' + char(10); -- End the merge statement

        if @delete_existing_records_on_target = 1
        begin 
            print '/* Deleting remaining ThemeablePaletteVariable records in target database: ' + @dbName + ' that were not included in the source database.*/'+char(10);
            print 'DELETE target' + char(10) + 
                  'FROM  ['+@dbName+'].[dbo].[ThemeablePaletteVariable] as target' + char(10) + 
                  'WHERE NOT EXISTS (' + char(10) + 
                  'SELECT 1' + char(10) + 
                  'FROM (' + char(10) + 
                  'values ';

            set @var_merge_cnt = 0;

            set @cursor_palette_variables = CURSOR FAST_FORWARD FOR
                select [Id] from #temp_palette_variables;
            open @cursor_palette_variables;
            fetch next from @cursor_palette_variables into @Id;
            while @@FETCH_STATUS = 0
            BEGIN
                set @var_merge_cnt += 1; -- Increment the variable count for each palette variable processed

                if @var_merge_cnt < @palettevarcnt -- Check if we are still within the count of palette variables to process
                begin 
                    print '(''' + cast(@Id as nvarchar(36)) + '''),';
                end
                ELSE
                begin 
                    print'(''' + cast(@Id as nvarchar(36)) + ''')';
                END
                fetch next from @cursor_palette_variables into @Id;
            END
            close @cursor_palette_variables;
            deallocate @cursor_palette_variables;

            print ') src ([Id])' + char(10) + 
                  'WHERE target.[Id] = src.[Id]);' + char(10) + 
                  'go' + char(10); -- End the delete statement
        end
    end

    if @target_mappings_exists = 1 and @mappingscnt > 0
    BEGIN
        print'/* Inserting/Updating ThemeableGroupVariableMapping in target database: ' + @dbName + ' */'+char(10);

        print 'merge into ['+@dbName+'].[dbo].[ThemeableGroupVariableMapping] as target' + char(10) +
        'using (select src.* from ' + char(10) +
        ' ( ' + char(10) + 
        'values '; -- Start of the values statement for the merge
        set @var_merge_cnt = 0;
        declare @cursor_mappings CURSOR;
        set @cursor_mappings = CURSOR FAST_FORWARD FOR
            select [ThemeableGroupVariableId], [ThemeableVariableId] from #temp_mappings;
        open @cursor_mappings;
        fetch next from @cursor_mappings into @ThemeableGroupVariableId, @ThemeableVariableId;
        while @@FETCH_STATUS = 0
        BEGIN
            set @var_merge_cnt += 1; -- Increment the variable count for each mapping processed
            if @var_merge_cnt < @mappingscnt
            begin 
                print '(''' + cast(@ThemeableGroupVariableId as nvarchar(36)) + ''', ''' + cast(@ThemeableVariableId as nvarchar(36)) + ''')' + ','; -- Print the values for the merge statement
            end
            ELSE
            begin
                print '(''' + cast(@ThemeableGroupVariableId as nvarchar(36)) + ''', ''' + cast(@ThemeableVariableId as nvarchar(36)) + ''')';
            END

            fetch next from @cursor_mappings into @ThemeableGroupVariableId, @ThemeableVariableId;
        END
        close @cursor_mappings;
        deallocate @cursor_mappings;

        SET @SQL = 'merge into  ['+@dbName+'].[dbo].[ThemeableGroupVariableMapping] as target
            using (SELECT src.* from ( ' + @temp_sql_values + ' ) as src ([ThemeableGroupVariableId], [ThemeableVariableId]) 
            inner join  ['+@dbName+'].[dbo].[ThemeableVariable] tv on src.[ThemeableVariableId] = tv.[Id]
            inner join  ['+@dbName+'].[dbo].[ThemeableGroupVariable] tgv on src.[ThemeableGroupVariableId] = tgv.[Id] ) as source
            ON target.[ThemeableGroupVariableId] = source.[ThemeableGroupVariableId] AND target.[ThemeableVariableId] = source.[ThemeableVariableId]
            WHEN NOT MATCHED THEN 
                INSERT ([ThemeableGroupVariableId], [ThemeableVariableId], [Author], [CreateDate], [Modifier], [ModifiedDate]) 
                VALUES (source.[ThemeableGroupVariableId], source.[ThemeableVariableId], ''SEED'', GETDATE(), ''SEED'', GETDATE());
            ';

        if @delete_existing_records_on_target = 1
        begin 
            print '/* Deleting remaining ThemeableGroupVariableMapping records in target database: ' + @dbName + ' that were not included in the source database. */' + char(10);
            print N'DELETE target' + char(10) +
            'FROM  ['+@dbName+'].[dbo].[ThemeableGroupVariableMapping] as target' + char(10) +
            'WHERE NOT EXISTS (' + char(10) +
            char(9)+'SELECT 1' + char(10) +
            char(9)+'FROM (' + char(10) +'values ';

            set @var_merge_cnt = 0;
            set @cursor_mappings = CURSOR FAST_FORWARD FOR
                select [ThemeableGroupVariableId], [ThemeableVariableId] from #temp_mappings;
            open @cursor_mappings;
            fetch next from @cursor_mappings into @ThemeableGroupVariableId, @ThemeableVariableId;
            while @@FETCH_STATUS = 0
            BEGIN
                set @var_merge_cnt += 1; -- Increment the variable count for each mapping processed
                if @var_merge_cnt < @mappingscnt
                begin 
                    print '(''' + cast(@ThemeableGroupVariableId as nvarchar(36)) + ''', ''' + cast(@ThemeableVariableId as nvarchar(36)) + ''')' + ','; -- Print the values for the merge statement
                end
                ELSE
                begin
                    print '(''' + cast(@ThemeableGroupVariableId as nvarchar(36)) + ''', ''' + cast(@ThemeableVariableId as nvarchar(36)) + ''')';
                END

                fetch next from @cursor_mappings into @ThemeableGroupVariableId, @ThemeableVariableId;
            END
            close @cursor_mappings;
            deallocate @cursor_mappings;

            print ') src ([ThemeableGroupVariableId], [ThemeableVariableId])' + char(10) + 
            'WHERE target.[ThemeableGroupVariableId] = src.[ThemeableGroupVariableId] AND target.[ThemeableVariableId] = src.[ThemeableVariableId]' + char(10) +
            ');' + char(10);
        end     
    end

    fetch next from @cursor into @dbName, @prod, 
        @target_variables_exists,
        @target_group_variables_exists,
        @target_palette_variables_exists,
        @target_mappings_exists;
end 
close @cursor;
deallocate @cursor;

print '-- *** FINISHED EXECUTABLE SQL ***'