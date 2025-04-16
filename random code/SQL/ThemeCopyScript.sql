
/*
    Theme Export/Import Script
    This script is used to export and import themes from one database to another.

    THIS SHOULD BE RAN FROM THE DEV SQL SERVER, ALWAYS!!!

    Things this copies:
    1. Theme
    2. ThemeVersion
    2. ThemeableVariableValue
    3. ThemeableGroupVariableValue
    4. ThemeablePaletteVariableValue

    Things this does not copy:
    1. ThemeImage
    2. ThemeVideoLink

    This script will merge the data into the destination database, so it will update existing records and insert new ones if they do not exist.
    This script will also check if the source and destination databases exist, and if the theme exists in the source database.
    This script will also check if the destination database has the necessary tables to import the data into.
    This script will also check if the source database is a production database or not, and will adjust the queries accordingly.
    This script will also print out messages to the console to indicate the progress of the export/import process.
    This script will also handle the case where the source database is a production database, and will adjust the queries accordingly.

    Things that need to be configured before running this script:
    1. #temp_input_themestocopy - The ID(s) of the theme(s) you want to export.
    2. @source_DB - The name of the source database you want to export from.
    3. @source_DB_PROD - A bit flag indicating if the source database is a production database (1 for production, 0 for non-production).
    4. bit flags for exporting data:
        - @export_variablevalues = 1 (to export ThemeableVariableValue)
        - @export_groupvariablevalues = 1 (to export ThemeableGroupVariableValue)
        - @export_palettevariablevalues = 1 (to export ThemeablePaletteVariableValue)
    5. The destination databases are hardcoded in the script, you can add or remove databases as needed in the #temp_input_destination_db table.
    6. Make sure to run this script in the context of the master database, as it will check for the existence of the source database and destination databases.
*/

use [master];
go

-- configure the source database name
declare @source_DB NVARCHAR(50) = 'VeoSolutions_DEV';
declare @source_DB_PROD bit = 1;
-- utilize these bit flags to configure what data you want to export
declare @export_variablevalues bit = 1,
        @export_groupvariablevalues bit = 1,
        @export_palettevariablevalues bit = 1;
-- utilize the following bit flag to indicate to delete outlier records in the destination database if they exist and are not in the source database.
declare @delete_outliers bit = 0;
-- sql variable to execute
declare @sql NVARCHAR(MAX) = '',
        @messages nvarchar(max) = '';

drop table if exists #temp_source_db;
drop table if exists #temp_input_themestocopy;
drop table if exists #temp_input_destination_db;
drop table if exists #temp_destination_db;
drop table if exists #temp_theme;
drop table if exists #temp_theme_version;
drop table if exists #temp_themeablevariableValues;
drop table if exists #temp_themeablegroupvariablevalues;
drop table if exists #temp_themeablepalettevariablevalues;

create table #temp_input_themestocopy (
    [themeId] UNIQUEIDENTIFIER
)
insert into #temp_input_themestocopy
values 
('82725f4d-2434-4bd9-8e13-bd804226eaef')
,('feba4d63-7a02-4c49-812e-e2b7dc0143e1')

create table #temp_source_db (
    [dbName] sysname,
    [prod] bit
);

create table #temp_input_destination_db (
    [dbName] sysname,
    [prod] bit
);
/*
    temp_input_destination_db table is used to store the destination database name and whether it is a production database or not.
*/
insert into #temp_input_destination_db
values --
('VeoSolutions_QA', 0) 
       --,('VeoSolutions_DEV', 0)
       --,('VeoSolutions_STAGING', 0)
       --,('VeoSolutions_PREVIEW', 0)
       --,('VeoSolutions', 1)
       --,('AFI_VeoSolutions', 1)
       --,('CCDI_VeoSolutions', 1)
       --,('EPLAN_VeoSolutions', 1)
       ;

print '/*';
print 'Starting Theme Export/Import Script...';

print 'Checking if source database ' + @source_DB + ' exists...';
-- check if source database exists
set @SQL = 'insert into #temp_source_db
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

create table #temp_destination_db (
    [dbName] sysname,
    [prod] bit,
    [ThemeVersion_Exists] bit,
    [ThemeableVariableValue_Exists] bit,
    [ThemeableGroupVariableValue_Exists] bit,
    [ThemeablePaletteVariableValue_Exists] bit
);

-- check if destination database exists
-- and check tables on destination db
print 'Checking destination databases for existence and required tables...';
declare @cursor cursor;
declare @prod bit;
declare @destination_DB NVARCHAR(50);
set @cursor = cursor fast_forward for
select [dbName], [prod] from #temp_input_destination_db;
open @cursor;
fetch next from @cursor into @destination_DB, @prod;
while @@fetch_status = 0
begin 

    print 'Checking destination database: '+@destination_DB+' for existence...';
    set @SQL = 'insert into #temp_destination_db (dbName, prod)
    select '''+@destination_DB+''' as dbName, '''+cast(@prod as nvarchar(1))+''' as prod
    from '+case when @prod = 1 then '[VDS_PROD].' else '' end + '[master].[sys].[databases] where name = '''+@destination_DB+''' ';

    exec sp_executesql @SQL;

    if (select count(*) from #temp_destination_db where dbName = @destination_DB) = 0
    begin
        if @prod = 1
        begin
            set @messages = 'Destination database '+@destination_DB+' does not exist in PROD.';
        end
        else
        begin
            set @messages = 'Destination database '+@destination_DB+' does not exist in DEV.';
        end
        RAISERROR(@messages, 16, 1);
        fetch next from @cursor into @destination_DB, @prod;
        continue; -- skip to the next destination database if it doesn't exist
    end

    print 'Checking for required tables in destination database: '+@destination_DB+'...';

    set @SQL = 'update #temp_destination_db set
    [ThemeableVariableValue_Exists] = (select count([name]) from '+case when @prod = 1 then '[VDS_PROD].' else '' end +@destination_DB+'.sys.tables where name = ''ThemeableVariableValue''),
    [ThemeableGroupVariableValue_Exists] = (select count([name]) from '+case when @prod = 1 then '[VDS_PROD].' else '' end +@destination_DB+'.sys.tables where name = ''ThemeableGroupVariableValue''),
    [ThemeablePaletteVariableValue_Exists] = (select count([name]) from '+case when @prod = 1 then '[VDS_PROD].' else '' end +@destination_DB+'.sys.tables where name = ''ThemeablePaletteVariableValue'')
    where dbName = '''+@destination_DB+''' ';

    exec sp_executesql @SQL;

    fetch next from @cursor into @destination_DB, @prod;
end
CLOSE @cursor;
DEALLOCATE @cursor;

if (select count(*) from #temp_destination_db) = 0
begin
    set @messages = 'No destination database exists.';
    RAISERROR(@messages, 16, 1);
    return;
end


declare @varcnt int = 0;
create table #temp_theme (
    [Id] UNIQUEIDENTIFIER,
    [LookupKey] NVARCHAR(50),
    [Name] NVARCHAR(50),
    [Description] NVARCHAR(500),
    [CssClass] NVARCHAR(50)
);

print 'Exporting Themes from source database: '+@source_DB+'...';

set @SQL = 'insert into #temp_theme
select t.[Id], t.[LookupKey], t.[Name], t.[Description], t.[CssClass]
from '+case when @source_DB_PROD = 1 then '[VDS_PROD].[' else '[' end + @source_DB +'].[dbo].[Theme] t
inner join #temp_input_themestocopy tc on tc.themeId = t.[Id]';
exec sp_executesql @SQL;

if (select count(*) from #temp_theme) = 0
begin
    if @source_DB_PROD = 1
    begin
        set @messages = 'Source theme does not exists on '+@source_DB+' in PROD.';
    end
    else
    begin
        set @messages = 'Source theme does not exists on '+@source_DB+' in DEV.';
    end
    RAISERROR(@messages, 16, 1);
    return;
end

set @varcnt = (select count(*) from #temp_theme); -- Get the count of themes exported
print 'Total Theme records exported: ' + cast(@varcnt as nvarchar(10));

create table #temp_theme_version (
    [ThemeId] UNIQUEIDENTIFIER,
    [Number] int,
    [BaseThemeId] UNIQUEIDENTIFIER null,
    [BaseVersion] int null
)

print 'Exporting ThemeVersion from source database: ' + @source_db;
set @SQL = N'insert into #temp_theme_version
select tv.[ThemeId], tv.[Number], tv.[BaseThemeId], tv.[BaseVersion] from ' + case when @source_DB_prod = 1 then '[VDS_PROD].['+@source_db+'].[' else '['+@source_db+'].[' end + 'dbo].[ThemeVersion] tv
inner join #temp_theme t on t.[Id] = tv.[ThemeId];';
exec sp_executesql @SQL;

set @varcnt = (select count(*) from #temp_theme_version); -- Get the count of themes exported
print 'Total ThemeVersion records exported: ' + cast(@varcnt as nvarchar(10));

create table #temp_themeablevariableValues (
    [ThemeId] UNIQUEIDENTIFIER,
    [ThemeVersionNumber] int,
    [ThemeableVariableId] UNIQUEIDENTIFIER,
    [Value] NVARCHAR(500)
);

if @export_variablevalues = 1
begin 
    print 'Exporting ThemeableVariableValues';

    set @SQL = 'insert into #temp_themeablevariableValues
    select tvv.[ThemeId], tvv.[ThemeVersionNumber], tvv.[ThemeableVariableId], tvv.[Value]
    from '+case when @source_DB_PROD = 1 then '[VDS_PROD].[' else '[' end + @source_DB +'].[dbo].[ThemeableVariableValue] tvv
    inner join #temp_theme_version tv on tv.[ThemeId] = tvv.[ThemeId] and tv.[Number] = tvv.[ThemeVersionNumber] ';
    exec sp_executesql @SQL;

    set @varcnt = (select count(*) from #temp_themeablevariableValues);
    print 'Exported '+cast(@varcnt as nvarchar(10))+' ThemeableVariableValues';
end

create table #temp_themeablegroupvariablevalues (
    [ThemeId] UNIQUEIDENTIFIER,
    [ThemeVersionNumber] int,
    [ThemeableGroupVariableId] UNIQUEIDENTIFIER,
    [Value] NVARCHAR(500)
);

declare @groupvarcnt int = 0;
if @export_groupvariablevalues = 1
begin 
    print 'Exporting ThemeableGroupVariableValues';

    set @SQL = 'insert into #temp_themeablegroupvariablevalues
    select tgvv.[ThemeId], tgvv.[ThemeVersionNumber], tgvv.[ThemeableGroupVariableId], tgvv.[Value]
    from '+case when @source_DB_PROD = 1 then '[VDS_PROD].[' else '[' end + @source_DB +'].[dbo].[ThemeableGroupVariableValue] tgvv
    inner join #temp_theme_version tv on tv.[ThemeId] = tgvv.[ThemeId] and tv.[Number] = tgvv.[ThemeVersionNumber] ';
    exec sp_executesql @SQL;

    set @groupvarcnt = (select count(*) from #temp_themeablegroupvariablevalues);
    print 'Exported '+cast(@groupvarcnt as nvarchar(10))+' ThemeableGroupVariableValues';
end

create table #temp_themeablepalettevariablevalues (
    [ThemeId] UNIQUEIDENTIFIER,
    [ThemeVersionNumber] int,
    [ThemeablePaletteVariableId] UNIQUEIDENTIFIER,
    [Value] NVARCHAR(500)
);

declare @palettevarcnt int = 0;
if @export_palettevariablevalues = 1
begin 
    print 'Exporting ThemeablePaletteVariableValues';

    set @SQL = 'insert into #temp_themeablepalettevariablevalues
    select tpvv.[ThemeId], tpvv.[ThemeVersionNumber], tpvv.[ThemeablePaletteVariableId], tpvv.[Value]
    from '+case when @source_DB_PROD = 1 then '[VDS_PROD].[' else '[' end + @source_DB +'].[dbo].[ThemeablePaletteVariableValue] tpvv
    inner join #temp_theme_version tv on tv.[ThemeId] = tpvv.[ThemeId] and tv.[Number] = tpvv.[ThemeVersionNumber] ';
    exec sp_executesql @SQL;

    set @palettevarcnt = (select count(*) from #temp_themeablepalettevariablevalues);
    print 'Exported '+cast(@palettevarcnt as nvarchar(10))+' ThemeablePaletteVariableValues';
end

print '*/';

print '-- *** BEGINNING EXECUTABLE SQL ***'

declare @themeablevariablevalues_exists bit = 0,
        @themeablegroupvariablevalues_exists bit = 0,
        @themeablepalettevariablevalues_exists bit = 0,
        @var_merge_cnt int = 0;

set @cursor = cursor fast_forward for
select [dbName], [prod], [ThemeableVariableValue_Exists], [ThemeableGroupVariableValue_Exists], [ThemeablePaletteVariableValue_Exists] from #temp_destination_db;
open @cursor;
fetch next from @cursor into @destination_DB, @prod, @themeablevariablevalues_exists, @themeablegroupvariablevalues_exists, @themeablepalettevariablevalues_exists;
while @@fetch_status = 0
begin 
    print 'USE ['+@destination_DB+'];'+char(10)+'go'+char(10);

    print '/* Merging Theme into destination database: '+@destination_DB+'... */'+char(10);

    print 'merge into [dbo].[Theme] as [TARGET]'+ char(10) + 
          'using ( select * from ( values '
    set @SQL = ( select stuff( (
                select N', '+char(10)+'(''' + ISNULL(CAST(Id AS NVARCHAR(36)), '') + ''', ''' + ISNULL(LookupKey, '') + N''', ''' + ISNULL([Name], '') + N''', ''' + ISNULL([Description], '') + N''', ''' + ISNULL(CssClass, '') + N''') '
        from #temp_theme
        for xml path(''), type).value('.', 'NVARCHAR(MAX)'), 1, 2, '') );
    print @SQL;
    print ') as src ([Id], [LookupKey], [Name], [Description], [CssClass])) as [SOURCE] on [TARGET].[Id] = [SOURCE].[Id]'+ char(10) + 
          'when matched then'+ char(10) + 
          'update set'+ char(10) + 
          '[TARGET].[LookupKey] = [SOURCE].[LookupKey],'+ char(10) + 
          '[TARGET].[Name] = [SOURCE].[Name],'+ char(10) + 
          '[TARGET].[Description] = [SOURCE].[Description],'+ char(10) + 
          '[TARGET].[CssClass] = [SOURCE].[CssClass],'+ char(10) + 
          '[TARGET].[Modifier] = ''SEED'','+ char(10) + 
          '[TARGET].[ModifiedDate] = GETDATE() '+ char(10) + 
          'when not matched then'+ char(10) + 
          'insert([Id],[LookupKey],[Name],[Description],[CssClass],[Author],[Modifier],[CreateDate],[ModifiedDate])'+ char(10) + 
          'values ([SOURCE].[Id],[SOURCE].[LookupKey],[SOURCE].[Name],[SOURCE].[Description],[SOURCE].[CssClass],''SEED'', ''SEED'', GETDATE(), GETDATE());'+ char(10) + 
          'go'+char(10);

    print '/* Merging ThemeVersion into destination database: '+@destination_DB+'... */'+char(10);
    print 'merge into [dbo].[ThemeVersion] as [TARGET]'+ char(10) + 
          'using ( select * from ( values '
    set @sql = ( select stuff( (
                select N', '+char(10)+'(''' + ISNULL(CAST(ThemeId AS NVARCHAR(36)), '') + ''', ''' + ISNULL(CAST(Number AS NVARCHAR(10)), '') + N''', ''' + ISNULL(CAST(BaseThemeId AS NVARCHAR(36)), 'null') + N''', ''' + ISNULL(CAST(BaseVersion AS NVARCHAR(10)), 'null') + N''') '
        from #temp_theme_version
        for xml path(''), type).value('.', 'NVARCHAR(MAX)'), 1, 2, '') );
    print @sql;
    print ') as src ([ThemeId], [Number], [BaseThemeId], [BaseVersion])) as [SOURCE] on [TARGET].[ThemeId] = [SOURCE].[ThemeId] and [TARGET].[Number] = [SOURCE].[Number]'+ char(10) + 
          'when matched then'+ char(10) + 
          'update set'+ char(10) + 
          '[TARGET].[BaseThemeId] = [SOURCE].[BaseThemeId],'+ char(10) + 
          '[TARGET].[BaseVersion] = [SOURCE].[BaseVersion],'+ char(10) + 
          '[TARGET].[Modifier] = ''SEED'','+ char(10) + 
          '[TARGET].[ModifiedDate] = GETDATE() '+ char(10) + 
          'when not matched then'+ char(10) + 
          'insert([ThemeId],[Number],[BaseThemeId],[BaseVersion],[Author],[Modifier],[CreateDate],[ModifiedDate])'+ char(10) + 
          'values ([SOURCE].[ThemeId],[SOURCE].[Number],[SOURCE].[BaseThemeId],[SOURCE].[BaseVersion],''SEED'', ''SEED'', GETDATE(), GETDATE());'+ char(10) + 
          'go'+char(10);

    print '/* Delete versions that are not in source db */'
    print 'DELETE FROM [dbo].[ThemeVersion] tgt'+char(10)+
          'WHERE NOT EXISTS ('+char(10)+
          'SELECT 1 '+char(10)+
          'FROM ( select src.* from ( values '+char(10);
    set @sql = ( select stuff( (
                select N', '+char(10)+'(''' + ISNULL(CAST(ThemeId AS NVARCHAR(36)), '') + ''', ''' + ISNULL(CAST(Number AS NVARCHAR(10)), '') + N''', ''' + ISNULL(CAST(BaseThemeId AS NVARCHAR(36)), 'null') + N''', ''' + ISNULL(CAST(BaseVersion AS NVARCHAR(10)), 'null') + N''') '
        from #temp_theme_version
        for xml path(''), type).value('.', 'NVARCHAR(MAX)'), 1, 2, '') );
    print @sql;
    print ' ) as src ([ThemeId], [Number], [BaseThemeId], [BaseVersion]) ) '+char(10)+
          'src'+char(10)+
          'WHERE src.ThemeId = tgt.ThemeId '+char(10)+
          'AND src.Number = tgt.Number' + char(10)+
          ');'+char(10);

    if @export_variablevalues = 1 and @themeablevariablevalues_exists = 1 and @varcnt > 0
    begin 
        print '/* Merging '+cast(@varcnt as nvarchar(100))+' ThemeableVariableValues into destination database: '+@destination_DB+' */' + char(10);
        print 'merge into [dbo].[ThemeableVariableValue] as [TARGET]'+char(10)+
              'using ( select src.* from ( values '+char(10)
        
        -- have to use a cursor to iterate over each themevariablevalue
        set @var_merge_cnt = 0;
        declare varval_cursor cursor fast_forward for 
        select [ThemeId], [ThemeVersionNumber], [ThemeableVariableId], [Value] from #temp_themeablevariableValues;
        open varval_cursor;
        declare @varThemeId UNIQUEIDENTIFIER, @varThemeVersion int, @varThemeableVariableId UNIQUEIDENTIFIER, @varValue NVARCHAR(500);
        fetch next from varval_cursor into @varThemeId, @varThemeVersion, @varThemeableVariableId, @varValue;
        while @@fetch_status = 0
        begin 
            set @var_merge_cnt += 1;
            if @var_merge_cnt < @varcnt
            begin 
                print '('''+cast(@varThemeId as nvarchar(50))+''', '+cast(@varThemeVersion as nvarchar(100))+', '''+cast(@varThemeableVariableId as nvarchar(50))+''', '''+REPLACE(ISNULL(cast(@varValue as nvarchar(500)),''),'''','''''')+'''), '; -- first value, no comma
            end
            else
            begin
                print '('''+cast(@varThemeId as nvarchar(50))+''', '''+cast(@varThemeableVariableId as nvarchar(50))+''', '''+REPLACE(ISNULL(cast(@varValue as nvarchar(500)),''),'''','''''')+''')';
            end
            fetch next from varval_cursor into @varThemeId, @varThemeVersion, @varThemeableVariableId, @varValue;
        end
        close varval_cursor;
        deallocate varval_cursor;

        print ') as src ([ThemeId], [ThemeVersionNumber], [ThemeableVariableId], [Value])'+char(10)+
              'inner join [dbo].[ThemeableVariable] tv on tv.[Id] = src.[ThemeableVariableId] ) as [SOURCE] on [TARGET].ThemeId = [SOURCE].ThemeId'+char(10)+
              'and [TARGET].[ThemeableVariableId] = [SOURCE].[ThemeableVariableId] and [TARGET].[ThemeVersionNumber] = [SOURCE].[ThemeVersionNumber]'+char(10)+
              'when matched then'+char(10)+
              'update set [TARGET].Value = [SOURCE].Value,'+char(10)+
              '[TARGET].Modifier = ''seed'','+char(10)+
              '[TARGET].ModifiedDate = GETDATE()'+char(10)+
              'when not matched then'+char(10)+
              'insert ([ThemeId], [ThemeVersionNumber], [ThemeableVariableId], [Value], [Author], [CreateDate], [Modifier], [ModifiedDate])'+char(10)+
              'values ([SOURCE].[ThemeId], [SOURCE].[ThemeVersionNumber], [SOURCE].[ThemeableVariableId], [SOURCE].[Value], ''seed'', GETDATE(), ''seed'', GETDATE());'+char(10)+
              'go'+char(10);

        if @delete_outliers = 1
        BEGIN
            print '/* Deleting outlier ThemeableVariableValues from destination database: '+@destination_DB+'.*/'+char(10);

            print 'DELETE FROM [dbo].[ThemeableVariableValue] tgt'+char(10)+
                  'WHERE NOT EXISTS ('+char(10)+
                  'SELECT 1 '+char(10)+
                  'FROM ( select * from ( values '+char(10);
                 
            set @var_merge_cnt = 0;

            declare del_varval_cursor cursor fast_forward for
            select [ThemeId], [ThemeVersionNumber], [ThemeableVariableId], [Value] from #temp_themeablevariableValues; -- re-declare cursor to avoid conflicts
            open del_varval_cursor;
            fetch next from del_varval_cursor into @varThemeId, @varThemeVersion, @varThemeableVariableId, @varValue;
            while @@fetch_status = 0
            begin 
                set @var_merge_cnt += 1;
                if @var_merge_cnt = 1
                begin 
                    print '('''+cast(@varThemeId as nvarchar(50))+''', '+cast(@varThemeVersion as nvarchar(100))+', '''+cast(@varThemeableVariableId as nvarchar(50))+''')'; -- first value, no comma
                end
                else
                begin
                    print ', '+char(10)+'('''+cast(@varThemeId as nvarchar(50))+''', '+cast(@varThemeVersion as nvarchar(100))+', '''+cast(@varThemeableVariableId as nvarchar(50))+''')';
                end
                fetch next from del_varval_cursor into @varThemeId, @varThemeVersion, @varThemeableVariableId, @varValue;
            end
            close del_varval_cursor;
            deallocate del_varval_cursor;

            print ' ) as src ([ThemeId], [ThemeVersionNumber], [ThemeableVariableId]) ) '+char(10)+
                    'src'+char(10)+
                  'WHERE src.ThemeId = tgt.ThemeId '+char(10)+
                  'AND src.ThemeVersionNumber = tgt.ThemeVersionNumber ' + char(10)+
                  'AND src.ThemeableVariableId = tgt.ThemeableVariableId' + char(10)+
                  ');';
        end
    end

    if @export_groupvariablevalues = 1 and @themeablegroupvariablevalues_exists = 1 and @groupvarcnt > 0
    begin 
        print '/* Merging '+cast(@groupvarcnt as nvarchar(100))+' ThemeableGroupVariableValues into destination database: '+@destination_DB+' */';

        print 'merge into [dbo].[ThemeableGroupVariableValue] as [TARGET]
        using ( select src.* from ( values ';
        
        set @var_merge_cnt = 0;

        -- have to use a cursor to iterate over each themegroupvariablevalue
        declare groupvar_cursor cursor fast_forward for
        select [ThemeId], [ThemeVersionNumber], [ThemeableGroupVariableId], [Value] from #temp_themeablegroupvariablevalues;
        open groupvar_cursor;
        declare @groupThemeId UNIQUEIDENTIFIER, @groupThemeableGroupVariableId UNIQUEIDENTIFIER, @groupValue NVARCHAR(500);
        fetch next from groupvar_cursor into @groupThemeId, @varThemeVersion, @groupThemeableGroupVariableId, @groupValue;
        while @@fetch_status = 0
        begin 
            set @var_merge_cnt += 1;
            if @var_merge_cnt = 1
            begin 
                print '('''+cast(@groupThemeId as nvarchar(50))+''', '+cast(@varThemeVersion as nvarchar(100))+', '''+cast(@groupThemeableGroupVariableId as nvarchar(50))+''', '''+REPLACE(ISNULL(cast(@groupValue as nvarchar(500)),''),'''','''''')+''')'; -- first value, no comma
            end
            else
            begin
                print ', '+char(10)+'('''+cast(@groupThemeId as nvarchar(50))+''', '+cast(@varThemeVersion as nvarchar(100))+', '''+cast(@groupThemeableGroupVariableId as nvarchar(50))+''', '''+REPLACE(ISNULL(cast(@groupValue as nvarchar(500)),''),'''','''''')+''')';
            end
            fetch next from groupvar_cursor into @groupThemeId, @varThemeVersion, @groupThemeableGroupVariableId, @groupValue;
        end
        close groupvar_cursor;
        deallocate groupvar_cursor;

        print ') as src ([ThemeId], [ThemeVersionNumber], [ThemeableGroupVariableId], [Value])'+char(10)+
        'inner join [dbo].[ThemeableGroupVariable] tv on tv.[Id] = src.[ThemeableGroupVariableId]'+char(10)+
        ') as [SOURCE] on [TARGET].ThemeId = [SOURCE].ThemeId '+char(10)+
        'and [TARGET].[ThemeVersionNumber] = [SOURCE].[ThemeVersionNumber]'+char(10)+
        'and [TARGET].[ThemeableGroupVariableId] = [SOURCE].[ThemeableGroupVariableId]'+char(10)+
        'when matched then'+char(10)+
        'update set [TARGET].Value = [SOURCE].Value,'+char(10)+
        '[TARGET].Modifier = ''seed'','+char(10)+
        '[TARGET].ModifiedDate = GETDATE()'+char(10)+
        'when not matched then'+char(10)+
        'insert ([ThemeId], [ThemeVersionNumber], [ThemeableGroupVariableId], [Value], [Author], [CreateDate], [Modifier], [ModifiedDate])'+char(10)+
        'values ([SOURCE].[ThemeId], [SOURCE].[ThemeVersionNumber], [SOURCE].[ThemeableGroupVariableId], [SOURCE].[Value], ''seed'', GETDATE(), ''seed'', GETDATE());'+char(10)+
        'go'+char(10);

        if @delete_outliers = 1
        BEGIN
            print '/*Deleting outlier ThemeableGroupVariableValues from destination database: '+@destination_DB+'*/'+char(10);

            print 'DELETE FROM [dbo].[ThemeableGroupVariableValue] tgt'+char(10)+
                  'WHERE NOT EXISTS ('+char(10)+
                  'SELECT 1 '+char(10)+
                  'FROM ( select src.* from ( values ';
            
            set @var_merge_cnt = 0;

            -- have to use a cursor to iterate over each themegroupvariablevalue again for the delete outliers
            declare del_groupvar_cursor cursor fast_forward for
            select [ThemeId], [ThemeVersionNumber], [ThemeableGroupVariableId], [Value] from #temp_themeablegroupvariablevalues; -- re-declare cursor to avoid conflicts
            open del_groupvar_cursor;
            fetch next from del_groupvar_cursor into @groupThemeId, @varThemeVersion, @groupThemeableGroupVariableId, @groupValue;
            while @@fetch_status = 0
            begin 
                set @var_merge_cnt += 1;
                if @var_merge_cnt = 1
                begin 
                    print '('''+cast(@groupThemeId as nvarchar(50))+''', '+cast(@varThemeVersion as nvarchar(100))+', '''+cast(@groupThemeableGroupVariableId as nvarchar(50))+''', '''+REPLACE(ISNULL(cast(@groupValue as nvarchar(500)),''),'''','''''')+''')'; -- first value, no comma
                end
                else
                begin
                    print ', '+char(10)+'('''+cast(@groupThemeId as nvarchar(50))+''', '+cast(@varThemeVersion as nvarchar(100))+', '''+cast(@groupThemeableGroupVariableId as nvarchar(50))+''', '''+REPLACE(ISNULL(cast(@groupValue as nvarchar(500)),''),'''','''''')+''')';
                end
                fetch next from del_groupvar_cursor into @groupThemeId, @varThemeVersion, @groupThemeableGroupVariableId, @groupValue;
            end
            close del_groupvar_cursor;
            deallocate del_groupvar_cursor;            

            print ') as src ([ThemeId], [ThemeVersionNumber], [ThemeableGroupVariableId], [Value])'+char(10)+
                  ') src '+char(10)+
                  'WHERE src.ThemeId = tgt.ThemeId '+char(10)+
                  'AND src.ThemeVersionNumber = tgt.ThemeVersionNumber ' + char(10)+
                  'AND src.ThemeableGroupVariableId = tgt.ThemeableGroupVariableId '+char(10)+
                  ');'+char(10)+
                  'go'+char(10);
        end
    end

    if @export_palettevariablevalues = 1 and @themeablepalettevariablevalues_exists = 1 and @palettevarcnt > 0
    begin 
        print '/* Merging '+cast(@palettevarcnt as nvarchar(10))+' ThemeablePaletteVariableValues into destination database: '+@destination_DB+' */'+char(10);

        print 'merge into [dbo].[ThemeablePaletteVariableValue] as [TARGET] '+char(10)+
              'using ( select src.* from ( values ';
        
        set @var_merge_cnt = 0;

        -- have to use a cursor to iterate over each themepalettevariablevalue
        declare palettevar_cursor cursor fast_forward for
        select [ThemeId], [ThemeVersionNumber], [ThemeablePaletteVariableId], [Value] from #temp_themeablepalettevariablevalues;
        open palettevar_cursor;
        declare @paletteThemeId UNIQUEIDENTIFIER, @paletteThemeablePaletteVariableId UNIQUEIDENTIFIER, @paletteValue NVARCHAR(500);
        fetch next from palettevar_cursor into @paletteThemeId, @varThemeVersion, @paletteThemeablePaletteVariableId, @paletteValue;
        while @@fetch_status = 0
        begin 
            set @var_merge_cnt += 1;
            if @var_merge_cnt = 1
            begin 
                print '('''+cast(@paletteThemeId as nvarchar(50))+''', '+cast(@varThemeVersion as nvarchar(100))+', '''+cast(@paletteThemeablePaletteVariableId as nvarchar(50))+''', '''+REPLACE(ISNULL(cast(@paletteValue as nvarchar(500)),''),'''','''''')+''')'; -- first value, no comma
            end
            else
            begin
                print ', '+char(10)+'('''+cast(@paletteThemeId as nvarchar(50))+''', '+cast(@varThemeVersion as nvarchar(100))+', '''+cast(@paletteThemeablePaletteVariableId as nvarchar(50))+''', '''+REPLACE(ISNULL(cast(@paletteValue as nvarchar(500)),''),'''','''''')+''')';
            end
            fetch next from palettevar_cursor into @paletteThemeId, @varThemeVersion, @paletteThemeablePaletteVariableId, @paletteValue;
        end
        close palettevar_cursor;
        deallocate palettevar_cursor;

        print ') as src ([ThemeId], [ThemeVersionNumber], [ThemeablePaletteVariableId], [Value])'+char(10)+
              'inner join [dbo].[ThemeablePaletteVariable] tv on tv.[Id] = src.[ThemeablePaletteVariableId] '+char(10)+
              ') as [SOURCE] on [TARGET].ThemeId = [SOURCE].ThemeId '+char(10)+
              'and [TARGET].[ThemeVersionNumber] = [SOURCE].[ThemeVersionNumber]'+char(10)+
              'and [TARGET].[ThemeablePaletteVariableId] = [SOURCE].[ThemeablePaletteVariableId] '+char(10)+
              'when matched then'+char(10)+
              'update set [TARGET].Value = [SOURCE].Value,'+char(10)+
              '[TARGET].Modifier = ''seed'','+char(10)+
              '[TARGET].ModifiedDate = GETDATE()'+char(10)+
              'when not matched by target then'+char(10)+
              'insert ([ThemeId], [ThemeVersionNumber], [ThemeablePaletteVariableId], [Value], [Author], [CreateDate], [Modifier], [ModifiedDate])'+char(10)+
              'values ([SOURCE].[ThemeId], [SOURCE].[ThemeVersionNumber], [SOURCE].[ThemeablePaletteVariableId], [SOURCE].[Value], ''seed'', GETDATE(), ''seed'', GETDATE());'+char(10)+
              'GO'+char(10);

        if @delete_outliers = 1
        BEGIN
            print '/*Deleting outlier ThemeablePaletteVariableValues from destination database: '+@destination_DB+'*/'+char(10);
            PRINT 'DELETE FROM [dbo].[ThemeablePaletteVariableValue] tgt '+CHAR(10)+
                  'WHERE NOT EXISTS ('+CHAR(10)+
                  'SELECT 1'+CHAR(10)+
                  'FROM ( select src.* from ( values ';
            
            set @var_merge_cnt = 0;
            -- have to use a cursor to iterate over each themepalettevariablevalue again for the delete outliers
            declare del_palettevar_cursor cursor fast_forward for
            select [ThemeId], [ThemeVersionNumber], [ThemeablePaletteVariableId], [Value] from #temp_themeablepalettevariablevalues; -- re-declare cursor to avoid conflicts
            open del_palettevar_cursor;
            fetch next from del_palettevar_cursor into @paletteThemeId, @varThemeVersion, @paletteThemeablePaletteVariableId, @paletteValue;
            while @@fetch_status = 0
            begin 
                set @var_merge_cnt += 1;
                if @var_merge_cnt = 1
                begin 
                    print '('''+cast(@paletteThemeId as nvarchar(50))+''', '+cast(@varThemeVersion as nvarchar(100))+', '''+cast(@paletteThemeablePaletteVariableId as nvarchar(50))+''')'; -- first value, no comma
                end
                else
                begin
                    print ', '+char(10)+'('''+cast(@paletteThemeId as nvarchar(50))+''', '+cast(@varThemeVersion as nvarchar(100))+', '''+cast(@paletteThemeablePaletteVariableId as nvarchar(50))+''')';
                end
                fetch next from del_palettevar_cursor into @paletteThemeId, @varThemeVersion, @paletteThemeablePaletteVariableId, @paletteValue;
            end
            close del_palettevar_cursor;
            deallocate del_palettevar_cursor;

            print ') as src ([ThemeId], [ThemeVersionNumber], [ThemeablePaletteVariableId], [Value]) '+char(10)+
                  ') src'+CHAR(10)+
                  'WHERE src.ThemeId = tgt.ThemeId '+CHAR(10)+
                  'AND src.ThemeVersionNumber = tgt.ThemeVersionNumber '+CHAR(10)+
                  'AND src.ThemeablePaletteVariableId = tgt.ThemeablePaletteVariableId);'+CHAR(10)+
                  'go'+CHAR(10);
        end
    end
    
    fetch next from @cursor into @destination_DB, @prod, @themeablevariablevalues_exists, @themeablegroupvariablevalues_exists, @themeablepalettevariablevalues_exists;

end 
CLOSE @cursor;
DEALLOCATE @cursor;

print '-- *** END OF EXECUTABLE SQL ***'