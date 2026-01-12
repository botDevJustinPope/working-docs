/*
    I want to compare variable css values to each other to get diffs to be able to group variables together
*/
drop table if exists #ThemeVariableValue
drop table if exists #ThemeVariable 
drop table if exists #ThemeVariableDelta
drop table if exists #NonColorVariableValues

select 
    tv.Id as [VariableID],
    cast(tv.Id as varchar(36)) as [VarcharVariableID],
    tv.CssName
into #ThemeVariable
from VeoSolutions_DEV.dbo.ThemeVariable tv

SELECT 
    t.[LookupKey] as [Theme],
    tv.Id as [VariableID],
    tv.CssName,
    tvv.[Value]
into #ThemeVariableValue
from VeoSolutions_DEV.dbo.Theme t 
    inner join VeoSolutions_DEV.dbo.ThemeVariableValue tvv on t.LookupKey = tvv.ThemeLookupKey
    inner join VeoSolutions_DEV.dbo.ThemeVariable tv on tvv.ThemeVariableId = tv.Id
where t.LookupKey = 'default'

-- Extract GUIDs and join with the table to get the corresponding CSS values
update tvv1
    set [VALUE] = tvv2.[VALUE]
from #ThemeVariableValue tvv1
    inner join #ThemeVariable tv on tvv1.Value = tv.VarcharVariableID
    inner join #ThemeVariableValue tvv2 on tvv2.VariableID = tv.VariableID
where PATINDEX('%[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]%-[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]%-[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]%-[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]%-[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]%', tvv1.Value) > 0

select * from #ThemeVariableValue tvv
where PATINDEX('%[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]%-[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]%-[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]%-[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]%-[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]%', tvv.Value) > 0



--Query variable values of hex, rgb, or rgba values
select * 
into JKP_ThemeVariableValue_JustColors
from #ThemeVariableValue tvv