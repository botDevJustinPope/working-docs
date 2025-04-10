declare @sql nvarchar(max) = N'';
declare @verbose bit = 0;

drop TABLE if EXISTS #temp_dbs;
create table #temp_dbs (
    [name] SYSNAME
);

insert into #temp_dbs 
values --('VeoSolutionsSecurity_DEV')
       --,('VeoSolutionsSecurity_QA')
       --,('VeoSolutionsSecurity_STAGING')
       --,
       ('VeoSolutionsSecurity_PREVIEW')
       --,('VeoSolutionsSecurity')
       --,('AFI_VeoSolutionsSecurity')
       --,('CCDI_VeoSolutionsSecurity')
       --,('EPLAN_VeoSolutionsSecurity')

declare @execute bit =0;
declare @dbCursor CURSOR;
set @dbCursor = CURSOR FAST_FORWARD FOR 
select [name] from #temp_dbs;
declare @dbName SYSNAME, @dbSolutions SYSNAME;

open @dbCursor;
fetch next from @dbCursor into @dbName;
while @@FETCH_STATUS = 0
BEGIN

    set @dbSolutions = REPLACE(@dbName, 'VeoSolutionsSecurity', 'VeoSolutions');
    print 'Checking for database: (' + @dbname + ', ' + @dbSolutions + ')';
    select 
        @execute = 1
    from master.sys.databases d
       inner join master.sys.databases d2 on 1=1 and d2.name = @dbSolutions
    where d.name = @dbName;   


    if @execute = 1
    BEGIN        

        print 'Executing for database: ' + @dbname;
        set @sql = N'USE [' + @dbName + '];'+char(10)+
        'update [dbo].[organizations]'+char(10)+
        'set theme_id = t.[Id], theme_version_number = 1'+char(10)+
        'from [dbo].[organizations] o'+char(10)+
        'join ['+@dbSolutions+'].[dbo].[Theme] t on t.[LookupKey] = o.[theme_lookup_key];'+char(10)+
        'update [dbo].[organizations]'+char(10)+
        'set theme_id = null, theme_version_number = null'+char(10)+
        'where [theme_lookup_key] = '''';'+char(10)+
        'select o.[name], o.[theme_lookup_key], o.[theme_id], o.[theme_version_number], t.[Id], t.[name] from [dbo].[organizations] o 
        left join ['+@dbSolutions+'].[dbo].[Theme] t on t.[Id] = o.[theme_id];';
        if @verbose = 1 print @sql 
        else EXECUTE sp_executesql @sql;

        print 'Deleting feature flag if it exists in ['+@dbSolutions+'].[dbo].[feature]';
        set @sql = N'USE [' + @dbSolutions + '];'+char(10)+
        'delete from [dbo].[features] where id = 65;';
        if @verbose = 1 print @sql 
        else EXECUTE sp_executesql @sql;

    END
    
    set @execute = 0;
    fetch next from @dbCursor into @dbName;

end
close @dbCursor;
DEALLOCATE @dbCursor;