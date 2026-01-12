use [VeoSolutions_DEV]
go

/*
    Get a snapshot of the current state of the ThemeVariableValue table

        drop table if exists JKP_ThemeVariableValues
        select * 
        into JKP_ThemeVariableValue
        from dbo.ThemeVariableValue

    Worst case scenario, we can revert to this snapshot

        delete from dbo.ThemeVariableValue
        insert into dbo.ThemeVariableValue
        select *
        from JKP_ThemeVariableValue

*/

/*
    Intention of this script is to sanitize the values in ThemeVariableValues table:
    1) Replace all instances of variable ids with variable pointers
    2) If a variable is theme specific, resolve the value to the specific css value
    3) If a value is a variable pointer and the variable is theme specific, resolve the value to the specific css value

*/

drop table if exists #VariableIDS
drop table if exists #temp_ThemeVariableValue

select 
    v.Id,
    v.CssName,
    v.TargetThemeLookupKey,
    cast(v.Id as nvarchar(50)) as IdString
into #VariableIDS
from dbo.ThemeVariable v

select * into #temp_ThemeVariableValue from dbo.ThemeVariableValue

while exists(select * from #temp_ThemeVariableValue v inner join #VariableIDS i on v.[Value] like '%'+i.IdString+'%' )
begin

    update v
        set v.Value = replace(v.[Value],i.IdString,'var(--'+i.[CssName]+')')
    from #temp_ThemeVariableValue v 
        inner join #VariableIDS i on v.[Value] like '%'+i.IdString+'%' and i.TargetThemeLookupKey is null

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

    update v 
        set v.Value = replace(v.[Value], 'var(--'+i.[CssName]+')', resolutionValue.[Value])
    from #temp_ThemeVariableValue v
        inner join #VariableIDS i on v.[Value] like '%var(--'+i.[CssName]+'%)' and i.TargetThemeLookupKey is not null
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
    tvv2.ThemeLookupKey,
    tvv2.[Value] as [CurrentValue],
    tvvv1.[Value] as [NewValue]
from #temp_ThemeVariableValue tvvv1
    left join dbo.ThemeVariable tv on tv.Id = tvvv1.ThemeVariableId
    left join dbo.ThemeVariableValue tvv2 on tvv2.Id = tvvv1.Id
where tvvv1.[Value] <> tvv2.[Value]