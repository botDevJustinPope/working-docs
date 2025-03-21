merge VeoSolutions_DEV.dbo.Theme as target 
using (
    select * from (
    values 
        ('82725f4d-2434-4bd9-8e13-bd804226eaef', 'taylor_morrison_spooky', 'Taylor Morrison - Skeleton', 'This is an attempt to put palette colors on Taylor Morrison and see it through the Themeable Skeleton.', 'theme-taylorMorrison-spooky', 'justinp', GETDATE(), null),
        ('feba4d63-7a02-4c49-812e-e2b7dc0143e1', 'flintrock_spooky', 'Flintrock - Skeleton', 'This is an attempt to put palette colors on Flintrock and see it through the Themeable Skeleton.', 'theme-flintrock-spooky', 'justinp', GETDATE(), null) 
        ) as source ([Id], [LookupKey], [Name], [Description], [CssClass], [CreatedBy], [CreatedDate], [BaseThemeId]) 
) as source on TARGET.Id = source.Id 
when not matched by target then
    insert ([Id], [LookupKey], [Name], [Description], [CssClass], [Author], [CreateDate], [Modifier], [ModifiedDate], [BaseThemeId])
    values (source.[Id], source.[LookupKey], source.[Name], source.[Description], source.[CssClass], source.[CreatedBy], source.[CreatedDate], source.[CreatedBy], source.[CreatedDate], source.[BaseThemeId]);

merge VeoSolutions_DEV.dbo.ThemeablePaletteVariableValue as target
using (
    select * from (
        values
            ('82725f4d-2434-4bd9-8e13-bd804226eaef', 'ff2925c1-0fd9-4e54-bf41-cce684b42987',	'color-mix(in srgb, var(--palette-tertiary) 10%, white)'),
            ('82725f4d-2434-4bd9-8e13-bd804226eaef', '07658b7c-412d-465b-b05b-eb9b62da3e87',	'color-mix(in srgb, var(--palette-tertiary) 40%, white)'),
            ('82725f4d-2434-4bd9-8e13-bd804226eaef', '502c9f8e-11ce-48b9-91ba-6e6307d85b7a',	'color-mix(in srgb, var(--palette-tertiary) 70%, white)'),
            ('82725f4d-2434-4bd9-8e13-bd804226eaef', '09c70019-aed9-4b75-bd5c-10d4e507f4ed',	'#d31245'),
            ('82725f4d-2434-4bd9-8e13-bd804226eaef', '762969f0-0f11-406a-8b31-67575e31e5ff',	'color-mix(in srgb, var(--palette-tertiary) 70%, black)'),  
            ('82725f4d-2434-4bd9-8e13-bd804226eaef', 'a7839364-983a-40f0-bf73-e6551cb5301c',	'color-mix(in srgb, var(--palette-tertiary) 40%, black)'),  
            ('82725f4d-2434-4bd9-8e13-bd804226eaef', 'a52a86e3-85ba-4c25-b05a-45838d862cf5',	'color-mix(in srgb, var(--palette-tertiary) 10%, black)'),  
            ('82725f4d-2434-4bd9-8e13-bd804226eaef', 'ac1c86c0-4a5f-4b5b-9570-77a5b86bac5b',	'color-mix(in srgb, var(--palette-secondary) 10%, white)'), 
            ('82725f4d-2434-4bd9-8e13-bd804226eaef', '45134d8b-77e9-4b65-83e1-bb4917d2aafc',	'color-mix(in srgb, var(--palette-secondary) 40%, white)'), 
            ('82725f4d-2434-4bd9-8e13-bd804226eaef', 'c16f5c46-3e28-40ac-b6dd-1335721c75f5',	'color-mix(in srgb, var(--palette-secondary) 70%, white)'), 
            ('82725f4d-2434-4bd9-8e13-bd804226eaef', 'e46e8ff1-5516-4da2-b00a-2fc60cc5d6ca',	'#c8c0ae'),      
            ('82725f4d-2434-4bd9-8e13-bd804226eaef', '7604a405-b2ab-42be-9f2b-f708306f449f',	'color-mix(in srgb, var(--palette-secondary) 70%, black)'), 
            ('82725f4d-2434-4bd9-8e13-bd804226eaef', 'e899f216-0e75-45e2-bff1-51ef1acab6de',	'color-mix(in srgb, var(--palette-secondary) 40%, black)'),
            ('82725f4d-2434-4bd9-8e13-bd804226eaef', '48ab0b15-802b-4aa3-ae51-ad5734298ee7',	'color-mix(in srgb, var(--palette-secondary) 10%, black)'), 
            ('82725f4d-2434-4bd9-8e13-bd804226eaef', 'b1f5f82d-14ec-4e19-b416-ee417c6d91dc',	'color-mix(in srgb, var(--palette-primary) 10%, white)'),
            ('82725f4d-2434-4bd9-8e13-bd804226eaef', '0551d16c-184b-4097-aa01-aa95897f3c77',	'color-mix(in srgb, var(--palette-primary) 40%, white)'),
            ('82725f4d-2434-4bd9-8e13-bd804226eaef', '0f1500e8-a7c3-4168-a2bc-77e65e2e0881',	'color-mix(in srgb, var(--palette-primary) 70%, white)'),
            ('82725f4d-2434-4bd9-8e13-bd804226eaef', '2b93185b-03e9-498c-b088-9a44c17d097a',	'#d31245'),
            ('82725f4d-2434-4bd9-8e13-bd804226eaef', '37eb8e93-af0a-478a-adb1-4037cc610058',	'color-mix(in srgb, var(--palette-primary) 70%, black)'),
            ('82725f4d-2434-4bd9-8e13-bd804226eaef', '86640572-d907-4baa-983b-69758cc7dfb7',	'color-mix(in srgb, var(--palette-primary) 40%, black)'),
            ('82725f4d-2434-4bd9-8e13-bd804226eaef', '0f6e37ef-f322-404b-8149-550316d0f23f',	'color-mix(in srgb, var(--palette-primary) 10%, black)'),
            ('feba4d63-7a02-4c49-812e-e2b7dc0143e1', 'ff2925c1-0fd9-4e54-bf41-cce684b42987',	'color-mix(in srgb, var(--palette-tertiary) 10%, white)'),
            ('feba4d63-7a02-4c49-812e-e2b7dc0143e1', '07658b7c-412d-465b-b05b-eb9b62da3e87',	'color-mix(in srgb, var(--palette-tertiary) 40%, white)'),
            ('feba4d63-7a02-4c49-812e-e2b7dc0143e1', '502c9f8e-11ce-48b9-91ba-6e6307d85b7a',	'color-mix(in srgb, var(--palette-tertiary) 70%, white)'),
            ('feba4d63-7a02-4c49-812e-e2b7dc0143e1', '09c70019-aed9-4b75-bd5c-10d4e507f4ed',	'#265a94'),
            ('feba4d63-7a02-4c49-812e-e2b7dc0143e1', '762969f0-0f11-406a-8b31-67575e31e5ff',	'color-mix(in srgb, var(--palette-tertiary) 70%, black)'),  
            ('feba4d63-7a02-4c49-812e-e2b7dc0143e1', 'a7839364-983a-40f0-bf73-e6551cb5301c',	'color-mix(in srgb, var(--palette-tertiary) 40%, black)'),  
            ('feba4d63-7a02-4c49-812e-e2b7dc0143e1', 'a52a86e3-85ba-4c25-b05a-45838d862cf5',	'color-mix(in srgb, var(--palette-tertiary) 10%, black)'),  
            ('feba4d63-7a02-4c49-812e-e2b7dc0143e1', 'ac1c86c0-4a5f-4b5b-9570-77a5b86bac5b',	'color-mix(in srgb, var(--palette-secondary) 10%, white)'), 
            ('feba4d63-7a02-4c49-812e-e2b7dc0143e1', '45134d8b-77e9-4b65-83e1-bb4917d2aafc',	'color-mix(in srgb, var(--palette-secondary) 40%, white)'), 
            ('feba4d63-7a02-4c49-812e-e2b7dc0143e1', 'c16f5c46-3e28-40ac-b6dd-1335721c75f5',	'color-mix(in srgb, var(--palette-secondary) 70%, white)'), 
            ('feba4d63-7a02-4c49-812e-e2b7dc0143e1', 'e46e8ff1-5516-4da2-b00a-2fc60cc5d6ca',	'#de9c46'),      
            ('feba4d63-7a02-4c49-812e-e2b7dc0143e1', '7604a405-b2ab-42be-9f2b-f708306f449f',	'color-mix(in srgb, var(--palette-secondary) 70%, black)'), 
            ('feba4d63-7a02-4c49-812e-e2b7dc0143e1', 'e899f216-0e75-45e2-bff1-51ef1acab6de',	'color-mix(in srgb, var(--palette-secondary) 40%, black)'),
            ('feba4d63-7a02-4c49-812e-e2b7dc0143e1', '48ab0b15-802b-4aa3-ae51-ad5734298ee7',	'color-mix(in srgb, var(--palette-secondary) 10%, black)'), 
            ('feba4d63-7a02-4c49-812e-e2b7dc0143e1', 'b1f5f82d-14ec-4e19-b416-ee417c6d91dc',	'color-mix(in srgb, var(--palette-primary) 10%, white)'),
            ('feba4d63-7a02-4c49-812e-e2b7dc0143e1', '0551d16c-184b-4097-aa01-aa95897f3c77',	'color-mix(in srgb, var(--palette-primary) 40%, white)'),
            ('feba4d63-7a02-4c49-812e-e2b7dc0143e1', '0f1500e8-a7c3-4168-a2bc-77e65e2e0881',	'color-mix(in srgb, var(--palette-primary) 70%, white)'),
            ('feba4d63-7a02-4c49-812e-e2b7dc0143e1', '2b93185b-03e9-498c-b088-9a44c17d097a',	'#265a94'),
            ('feba4d63-7a02-4c49-812e-e2b7dc0143e1', '37eb8e93-af0a-478a-adb1-4037cc610058',	'color-mix(in srgb, var(--palette-primary) 70%, black)'),
            ('feba4d63-7a02-4c49-812e-e2b7dc0143e1', '86640572-d907-4baa-983b-69758cc7dfb7',	'color-mix(in srgb, var(--palette-primary) 40%, black)'),
            ('feba4d63-7a02-4c49-812e-e2b7dc0143e1', '0f6e37ef-f322-404b-8149-550316d0f23f',	'color-mix(in srgb, var(--palette-primary) 10%, black)') 
        ) as source ([ThemeId], [ThemeablePaletteVariableId], [Value]) ) as source on TARGET.ThemeId = source.ThemeId and TARGET.ThemeablePaletteVariableId = source.ThemeablePaletteVariableId
    when not matched by target THEN
        insert ([ThemeId], [ThemeablePaletteVariableId], [Value], [Author], [CreateDate], [Modifier], [ModifiedDate])
        values (source.[ThemeId], source.[ThemeablePaletteVariableId], source.[Value], 'justinp', GETDATE(), 'justinp', GETDATE())
    when matched then
        update set 
            TARGET.Value = source.Value,
            TARGET.Modifier = 'justinp',
            TARGET.ModifiedDate = GETDATE();


select * from dbo.Theme t where t.[Name] like '%Skeleton%'

select 
     t.[Name] as [Theme Name],
     tpv.[Name] as [Palette Variable Name],
     tpv.[CssName] as [Palette Variable CssName],
     tpvv.*
from dbo.ThemeablePaletteVariableValue tpvv
    inner join dbo.ThemeablePaletteVariable tpv on tpv.Id = tpvv.ThemeablePaletteVariableId
    inner join dbo.Theme t on t.Id = tpvv.ThemeId
where t.Id = 'feba4d63-7a02-4c49-812e-e2b7dc0143e1'

/*

these update statements can be used to update the values to confirm that caching is working

-- tertiary update
update dbo.ThemeablePaletteVariableValue
    set [Value] = '#0000FF',
        [Modifier] = 'justinp',
        [ModifiedDate] = GETDATE()
where ThemeId = 'feba4d63-7a02-4c49-812e-e2b7dc0143e1'
    and ThemeablePaletteVariableId = '09c70019-aed9-4b75-bd5c-10d4e507f4ed'

--secondary update
update dbo.ThemeablePaletteVariableValue
    set [Value] = '#00FF00',
        [Modifier] = 'justinp',
        [ModifiedDate] = GETDATE()
where ThemeId = 'feba4d63-7a02-4c49-812e-e2b7dc0143e1'
    and ThemeablePaletteVariableId = 'e46e8ff1-5516-4da2-b00a-2fc60cc5d6ca'

--primary update
update dbo.ThemeablePaletteVariableValue
    set [Value] = '#FFA500',
        [Modifier] = 'justinp',
        [ModifiedDate] = GETDATE()
where ThemeId = 'feba4d63-7a02-4c49-812e-e2b7dc0143e1'
    and ThemeablePaletteVariableId = '2b93185b-03e9-498c-b088-9a44c17d097a'

    */