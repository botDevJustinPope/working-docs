select cssname_pieces_1.[Palette_Name], cssname_pieces_2.[direction], cssname_pieces_3.[order], tpv.CssName from [VeoSolutions_Dev].[dbo].[ThemeablePaletteVariable] tpv
    cross apply (
        select top 1
            s.Palette_Name
        from (
            select substring(tpv.CssName, 1, charindex('-',tpv.CssName,charindex('-',tpv.CssName)+1)) as [Palette_Name]
            union 
            select tpv.CssName  as [Palette_Name]
            where charindex('-',tpv.CssName,charindex('-',tpv.CssName)+1) = 0 ) s
        where s.Palette_Name <> ''
    ) cssname_pieces_1
    cross apply (
        select 'System' as [type]
        where cssname_pieces_1.Palette_name in ('palette-warning', 'palette-success', 'palette-error', 'semantic-negative','semantic-positive')
        union 
        select 'Palette' as [type]
        where cssname_pieces_1.Palette_name not in ('palette-warning', 'palette-success', 'palette-error', 'semantic-negative','semantic-positive')
    ) cssname_pieces_4
    cross apply ( select replace(tpv.CssName, cssname_pieces_1.Palette_Name, '') as backhalf) replace1
    cross apply (
        select
            substring(replace1.backhalf, 1, CHARINDEX('-', replace1.backhalf)) as direction
    ) cssname_pieces_2
    cross apply ( select replace(replace1.backhalf, cssname_pieces_2.direction, '') as [order] ) replace2
    cross apply (
        select 
            replace2.[order] as [order]
        where cssname_pieces_2.direction = 'light-'
        union 
        select 
            case 
                when replace2.[order] = '3' then '1'
                when replace2.[order] = '1' then '3'
                else replace2.[order]
            end as [order]
        where cssname_pieces_2.direction = 'dark-'
        union 
        select ''
        where cssname_pieces_2.direction not like '%-%'
            ) cssname_pieces_3
order by 
    cssname_pieces_4.[type] desc,
    cssname_pieces_1.[Palette_Name],
    cssname_pieces_2.[direction] desc,
    cssname_pieces_3.[order] desc