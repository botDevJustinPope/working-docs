declare @sql nvarchar(max) = '';
declare @db_name sysname;

drop table if exists #temp_dbs;
drop table if exists #temp_tablestocheck;
drop table if exists #temp_OnlyCheckDBS;


create table #temp_tablestocheck (
    [name] sysname not null
);
insert into #temp_tablestocheck
values ('ThemeableVariableValue'),
       ('ThemeableVariable'),
       ('Theme');

create table #temp_OnlyCheckDBS (
    [name] sysname not null
);
/*
-- Uncomment and add the databases you want to check
insert into #temp_OnlyCheckDBS
values ('VeoSolutions_DEV'), ('master');
*/

create table #temp_dbs (
    [name] sysname not null
);


declare @db_cursor cursor
set @db_cursor = cursor fast_forward for
select name from sys.databases where state = 0 and 
                            (
                                (select count([name]) from #temp_OnlyCheckDBS) = 0 
                                or 
                                name in (select [name] from #temp_OnlyCheckDBS))
open @db_cursor
fetch next from @db_cursor into @db_name
while @@fetch_status = 0
begin 
    set @sql =  'USE [' + @db_name + ']; 
                INSERT INTO #temp_dbs ([name])
                SELECT ''' + @db_name + '''
                FROM (
                    select 
                        count(t.name) as tCnt
                    from sys.tables t 
                    where t.name in (select [name] from #temp_tablestocheck) ) AS [table]
                where [table].tCnt = (select count([name]) from #temp_tablestocheck)';
    exec sp_executesql @sql
    fetch next from @db_cursor into @db_name
end

close @db_cursor
deallocate @db_cursor

select * from #temp_dbs

set @db_cursor = cursor fast_forward for
select [name] from #temp_dbs
open @db_cursor
fetch next from @db_cursor into @db_name
while @@fetch_status = 0
begin 
    set @sql =  'USE [' + @db_name + ']; 
                delete tvv
                from ThemeableVariableValue tvv 
                    inner join ThemeableVariable tv on tv.Id = tvv.ThemeableVariableId
                    inner join Theme t on t.Id = tvv.ThemeId
                where t.LookupKey not in (''default'', ''wild'')
                    and tv.cssname in (''color-profileStatus-complete'',
                                        ''color-profileStatus-bustout'',
                                        ''color-profileStatus-contracted'',
                                        ''color-profileStatus-other'')';
    exec sp_executesql @sql

    set @sql = 'USE [' + @db_name + ']; 
                select 
                    '''+@db_name+''' as [db],
                    t.name,
                    tv.cssname,
                    tvv.Value
                from ThemeableVariableValue tvv 
                    inner join ThemeableVariable tv on tv.Id = tvv.ThemeableVariableId
                    inner join Theme t on t.Id = tvv.ThemeId
                where tv.cssname in (''color-profileStatus-complete'',
                                        ''color-profileStatus-bustout'',
                                        ''color-profileStatus-contracted'',
                                        ''color-profileStatus-other'')';
    exec sp_executesql @sql

    fetch next from @db_cursor into @db_name
end
CLOSE @db_cursor
DEALLOCATE @db_cursor
