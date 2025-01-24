use [VeoSolutions_DEV]
go

/*
    Copy to revert this


    select * 
    into JKP_ThemeVariableValue
    from dbo.ThemeVariableValue

    delete from dbo.ThemeVariableValue
    insert into dbo.ThemeVariableValue
    select *
    from JKP_ThemeVariableValue

*/

drop table if exists #VariableIDS
drop table if exists #temp_ThemeVariableValue

select 
    v.Id,
    v.CssName,
    cast(v.Id as nvarchar(50)) as IdString
into #VariableIDS
from dbo.ThemeVariable v

select * into #temp_ThemeVariableValue from dbo.ThemeVariableValue

while exists(select * from #temp_ThemeVariableValue v inner join #VariableIDS i on v.[Value] like '%'+i.IdString+'%' )
begin
    update v
        set v.Value = replace(v.[Value],i.IdString, resolutionValue.[Value])
    from #temp_ThemeVariableValue v 
        inner join #VariableIDS i on v.[Value] like '%'+i.IdString+'%'
        cross apply (
            select top 1 v.[Value] from (
            select *, 1 as [Rank] from #temp_ThemeVariableValue v2 
            where v2.ThemeVariableId = i.Id and v2.ThemeLookupKey = v.ThemeLookupKey
            union
            select *, 2 as [Rank] from #temp_ThemeVariableValue v2 
            where v2.ThemeVariableId = i.Id and v2.ThemeLookupKey = 'default' ) v
            order by v.[Rank]
        ) resolutionValue
end




select 
    tv.CssName,
    tvv.ThemeLookupKey,
    tvv.[Value] as [CurrentValue],
    #temp_ThemeVariableValue.[Value] as [NewValue]
from #temp_ThemeVariableValue
    left join dbo.ThemeVariable tv on tv.Id = #temp_ThemeVariableValue.ThemeVariableId
    left join dbo.ThemeVariableValue tvv on tvv.Id = #temp_ThemeVariableValue.Id
where tvv.[Value] <> #temp_ThemeVariableValue.[Value]