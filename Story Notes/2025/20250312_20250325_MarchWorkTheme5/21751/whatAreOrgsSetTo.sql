declare @sql nvarchar(max) = '';
declare @db_name sysname;

drop table if exists #temp_orgs_theme_status 
drop table if exists #temp_dbs

create table #temp_orgs_theme_status (
    [DB Name] sysname not null,
    [Org ID] UNIQUEIDENTIFIER not null,
    [Org Name] nvarchar(50) null,
    [Theme Name] nvarchar(50) null,
    [DB Theme Flag Status] nvarchar(10) null
)

create table #temp_dbs (
    [name] sysname not null
)

declare @db_cursor cursor
set @db_cursor = cursor fast_forward for
select name from sys.databases where state = 0
open @db_cursor
fetch next from @db_cursor into @db_name
while @@fetch_status = 0
begin 
    set @sql =  'USE [' + @db_name + ']; 
                INSERT INTO #temp_dbs ([name])
                SELECT ''' + @db_name + '''
                from sys.tables t
                where t.name = ''Theme'' '
    exec sp_executesql @sql
    fetch next from @db_cursor into @db_name
end

close @db_cursor
deallocate @db_cursor


set @db_cursor = cursor fast_forward for
select [name] from #temp_dbs
open @db_cursor
fetch next from @db_cursor into @db_name
while @@fetch_status = 0
BEGIN

    set @sql = 'USE ['+@db_name+']; 
                insert into #temp_orgs_theme_status ([DB Name], [Org ID], [Org Name], [Theme Name], [DB Theme Flag Status])
                select 
                    '''+@db_name+''' as [DB Name],
                    o.organization_id as [Org ID],
                    o.name as [Org Name],
                    t.Name as [Theme Name],
                    case 
                        when bf.flag is not null then ''On''
                        else ''Off''
                    end as [DB Theme Flag Status]
                from dbo.VeoSolutionsSecurity_organizations o
                    left join dbo.Theme t on o.theme_lookup_key = t.LookupKey
                    left join ( select
                                    1 as flag,
                                    bf.organization_id
                                from dbo.builder_features bf 
                                where  bf.feature_id = 65 and [value] = 1 ) as bf on bf.organization_id = o.organization_id'
    exec sp_executesql @sql
    fetch next from @db_cursor into @db_name
end 
