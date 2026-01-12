declare @sql nvarchar(max) = '';
declare @db_name sysname;

drop table if exists #temp_dbs

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
                where t.name = ''ThemeablePaletteVariable'' '
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
				merge into dbo.ThemeablePaletteVariable as target
				using (
					select * from (
						VALUES
							(''0f6e37ef-f322-404b-8149-550316d0f23f'', ''palette-primary-light-3'', ''Primary Color Tint 3'', ''The third tint of the primary color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''86640572-d907-4baa-983b-69758cc7dfb7'', ''palette-primary-light-2'', ''Primary Color Tint 2'', ''The second tint of the primary color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''37eb8e93-af0a-478a-adb1-4037cc610058'', ''palette-primary-light-1'', ''Primary Color Tint 1'', ''The first tint of the primary color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''2b93185b-03e9-498c-b088-9a44c17d097a'', ''palette-primary'', ''Primary Color'', ''The primary color of the theme'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''0f1500e8-a7c3-4168-a2bc-77e65e2e0881'', ''palette-primary-dark-1'', ''Primary Color Shade 1'', ''The first shade of the primary color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''0551d16c-184b-4097-aa01-aa95897f3c77'', ''palette-primary-dark-2'', ''Primary Color Shade 2'', ''The second shade of the primary color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''b1f5f82d-14ec-4e19-b416-ee417c6d91dc'', ''palette-primary-dark-3'', ''Primary Color Shade 3'', ''The third shade of the primary color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''ac1c86c0-4a5f-4b5b-9570-77a5b86bac5b'', ''palette-secondary-light-3'', ''Secondary Color Tint 3'', ''The third tint of the secondary color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''45134d8b-77e9-4b65-83e1-bb4917d2aafc'', ''palette-secondary-light-2'', ''Secondary Color Tint 2'', ''The second tint of the secondary color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''c16f5c46-3e28-40ac-b6dd-1335721c75f5'', ''palette-secondary-light-1'', ''Secondary Color Tint 1'', ''The first tint of the secondary color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''e46e8ff1-5516-4da2-b00a-2fc60cc5d6ca'', ''palette-secondary'', ''Secondary Color'', ''The secondary color of the theme'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''7604a405-b2ab-42be-9f2b-f708306f449f'', ''palette-secondary-dark-1'', ''Secondary Color Shade 1'', ''The first shade of the secondary color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''e899f216-0e75-45e2-bff1-51ef1acab6de'', ''palette-secondary-dark-2'', ''Secondary Color Shade 2'', ''The second shade of the secondary color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''48ab0b15-802b-4aa3-ae51-ad5734298ee7'', ''palette-secondary-dark-3'', ''Secondary Color Shade 3'', ''The third shade of the secondary color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''ff2925c1-0fd9-4e54-bf41-cce684b42987'', ''palette-tertiary-light-3'', ''Tertiary Color Tint 3'', ''The third tint of the tertiary color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''07658b7c-412d-465b-b05b-eb9b62da3e87'', ''palette-tertiary-light-2'', ''Tertiary Color Tint 2'', ''The second tint of the tertiary color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''502c9f8e-11ce-48b9-91ba-6e6307d85b7a'', ''palette-tertiary-light-1'', ''Tertiary Color Tint 1'', ''The first tint of the tertiary color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''09c70019-aed9-4b75-bd5c-10d4e507f4ed'', ''palette-tertiary'', ''Tertiary Color'', ''The tertiary color of the theme'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''762969f0-0f11-406a-8b31-67575e31e5ff'', ''palette-tertiary-dark-1'', ''Tertiary Color Shade 1'', ''The first shade of the tertiary color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''a7839364-983a-40f0-bf73-e6551cb5301c'', ''palette-tertiary-dark-2'', ''Tertiary Color Shade 2'', ''The second shade of the tertiary color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''a52a86e3-85ba-4c25-b05a-45838d862cf5'', ''palette-tertiary-dark-3'', ''Tertiary Color Shade 3'', ''The third shade of the tertiary color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''5c6d7e8f-9a0b-1c2d-3e4f-5a6b7c8d9e0f'', ''palette-neutral-light-3'', ''Neutral Color Tint 3'', ''The third tint of the neutral color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''7e8f9a0b-1c2d-3e4f-5a6b-7c8d9e0f1a2b'', ''palette-neutral-light-2'', ''Neutral Color Tint 2'', ''The second tint of the neutral color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''2a3b4c5d-6e7f-8a9b-0c1d-2e3f4a5b6c7d'', ''palette-neutral-light-1'', ''Neutral Color Tint 1'', ''The first tint of the neutral color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''9f8e7d6c-5b4a-3e2f-1d0c-9b8a7e6f5d4c'', ''palette-neutral'', ''Neutral Color'', ''The neutral color of the theme'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''4d5e6f7a-8b9c-0d1e-2f3a-4b5c6d7e8f9a'', ''palette-neutral-dark-1'', ''Neutral Color Shade 1'', ''The first shade of the neutral color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''8a7c9b0d-1e2f-3a4b-5c6d-7e8f9a0b1c2d'', ''palette-neutral-dark-2'', ''Neutral Color Shade 2'', ''The second shade of the neutral color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''3f2e8a1b-5c4d-4b8a-9f2e-1a3b4c5d6e7f'', ''palette-neutral-dark-3'', ''Neutral Color Shade 3'', ''The third shade of the neutral color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''6ef5c697-b9c0-4d9f-88a7-70772a5ed92e'', ''palette-success-light-3'', ''Success Color Tint 3'', ''The third tint of the success color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''ceadb347-9fa3-4c08-8815-133df9c8635e'', ''palette-success-light-2'', ''Success Color Tint 2'', ''The second tint of the success color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''90f5b29f-e4b9-4867-ae9f-78554f05b951'', ''palette-success-light-1'', ''Success Color Tint 1'', ''The first tint of the success color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''aad6311b-14b7-40f6-8019-0c96130ed159'', ''palette-success'', ''Success Color'', ''The success color of the theme'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''c996861d-a92c-46ab-b598-43b3eba6df67'', ''palette-success-dark-1'', ''Success Color Shade 1'', ''The first shade of the success color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''2ec424c4-7d6a-4c01-a19d-8b89023cd37d'', ''palette-success-dark-2'', ''Success Color Shade 2'', ''The second shade of the success color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''f757b471-1d00-46d7-b13d-dfa028170c5c'', ''palette-success-dark-3'', ''Success Color Shade 3'', ''The third shade of the success color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''09f24199-23fa-480f-abea-fc06a52fd556'', ''palette-warning-light-3'', ''Warning Color Tint 3'', ''The third tint of the warning color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''ab1f0531-cb62-4ec0-bf0f-6ffdf4853984'', ''palette-warning-light-2'', ''Warning Color Tint 2'', ''The second tint of the warning color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''79675242-1dd2-4cb5-b50c-e2b9f783bf52'', ''palette-warning-light-1'', ''Warning Color Tint 1'', ''The first tint of the warning color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''1ac77a50-3fd6-405c-a9dd-ce73e81d642b'', ''palette-warning'', ''Warning Color'', ''The warning color of the theme'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''f56b7d6c-7229-4497-985c-d2822240108e'', ''palette-warning-dark-1'', ''Warning Color Shade 1'', ''The first shade of the warning color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''e0f8b177-333e-483c-87f2-2765e15996c6'', ''palette-warning-dark-2'', ''Warning Color Shade 2'', ''The second shade of the warning color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''801bf210-419b-4b1a-bc38-9e058dcddf49'', ''palette-warning-dark-3'', ''Warning Color Shade 3'', ''The third shade of the warning color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''c2eb6554-89fe-4cab-87c1-b7bcf32ae1f8'', ''palette-error-light-3'', ''Error Color Tint 3'', ''The third tint of the error color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''73496ce5-e89b-4377-af2a-acd8c5ba8b59'', ''palette-error-light-2'', ''Error Color Tint 2'', ''The second tint of the error color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''bacbb094-304c-413c-812c-01f8cdce7009'', ''palette-error-light-1'', ''Error Color Tint 1'', ''The first tint of the error color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''fc7192fa-d066-4092-922a-8dbed459c377'', ''palette-error'', ''Error Color'', ''The error color of the theme'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''42b647a5-25be-449c-a92f-25c32f9cf193'', ''palette-error-dark-1'', ''Error Color Shade 1'', ''The first shade of the error color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''953167f8-096f-4d68-9174-b58876432871'', ''palette-error-dark-2'', ''Error Color Shade 2'', ''The second shade of the error color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''9141be46-f533-4285-adc8-e2f931e69b91'', ''palette-error-dark-3'', ''Error Color Shade 3'', ''The third shade of the error color'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''a00019d2-77f2-4b2e-b90a-d0018a50e77b'', ''semantic-negative'', ''Semantic Negative Color'', ''Semantic negative color for contrast'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
    						(''73f2f74c-c822-49bd-bebf-f366b2b3aad9'', ''semantic-positive'', ''Semantic Positive Color'', ''Semantic positive color for contrast'', ''SEED'', GETDATE(), ''SEED'' ,GETDATE()),
    						(''cdf281a9-169d-46a0-868f-864635401bc7'', ''palette-gradient-neutral-light'', ''Neutral Gradient Light'', ''A light gradient using the neutral color palette'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''e9f9f14f-3515-4ba9-9f2d-177a99ac1f48'', ''palette-gradient-neutral'', ''Neutral Gradient'', ''A gradient using the neutral color palette'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''7c834379-c873-4af1-b18c-f7f8293fe041'', ''palette-gradient-neutral-dark'', ''Neutral Gradient Dark'', ''A dark gradient using the neutral color palette'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''ddb7a9af-50ea-49b9-b513-15544da2c639'', ''palette-gradient-primary-light'', ''Primary Gradient Light'', ''A light gradient using the primary color palette'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''d07f9e3b-3398-4fc1-8445-a3d1f10ae484'', ''palette-gradient-primary'', ''Primary Gradient'', ''A gradient using the primary color palette'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''cb1786bd-7862-4122-8a57-d20e169bc81f'', ''palette-gradient-primary-dark'', ''Primary Gradient Dark'', ''A dark gradient using the primary color palette'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''172d7dc5-bc78-4fae-9e20-5e0fb874e4a2'', ''palette-gradient-secondary-light'', ''Secondary Gradient Light'', ''A light gradient using the secondary color palette'', ''SEED'', GETDATE(), ''SEED'', GETDATE()),
							(''d58e99bb-3519-4e0d-bec1-542b29508cae'' ,''palette-gradient-secondary'' ,''Secondary Gradient'' ,''A gradient using the secondary color palette'' ,''SEED'' ,GETDATE() ,''SEED'' ,GETDATE()),
							(''e1f8b2c3-4d5e-4f6a-8b7c-9d0e1f2a3b4c'', ''palette-gradient-secondary-dark'', ''Secondary Gradient Dark'', ''A dark gradient using the secondary color palette'', ''SEED'', GETDATE(), ''SEED'', GETDATE())
						) as src (Id, CssName, Name, Description, Author, CreateDate, Modifier, ModifiedDate) 
                        ) as source on target.Id = source.Id
					WHEN MATCHED THEN
						UPDATE 
							SET target.CssName = source.CssName,
								target.Name = source.Name,
								target.Description = source.Description,
								target.Modifier = source.Modifier,
								target.ModifiedDate = source.ModifiedDate
					WHEN NOT MATCHED BY TARGET THEN
						INSERT (Id, CssName, Name, Description, Author, CreateDate, Modifier, ModifiedDate)
						VALUES (source.Id, source.CssName, source.Name, source.Description, source.Author, source.CreateDate, source.Modifier, source.ModifiedDate)
					WHEN NOT MATCHED BY SOURCE THEN
						DELETE;'
	exec sp_executesql @sql
	FETCH next from @db_cursor into @db_name
end 

close @db_cursor
deallocate @db_cursor