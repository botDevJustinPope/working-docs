with icon as (
    select * from [VeoSolutions_QA].[dbo].[icon]
)

merge into [VeoSolutions_DEV].[dbo].[icon] as target 
using icon as source 
on target.[id] = source.[id]
when matched then 
    update set 
        target.[name] = source.[name],
        target.[image] = source.[image],
        target.[mime_type] = source.[mime_type],
        modifier = 'justinpo@buildontechnologies.com',
        modified_date = getdate()
when not matched then
    insert ([id], [name], [image], [mime_type], [author], [create_date], [modifier], [modified_date])
    values (source.[id], source.[name], source.[image], source.[mime_type], 'justinpo@buildontechnologies.com', getdate(), 'justinpo@buildontechnologies.com', getdate());
go  

with icon_tags as (
    select * from [VeoSolutions_QA].[dbo].[icon_tags]
)
merge into [VeoSolutions_DEV].[dbo].[icon_tags] as target
using icon_tags as source
on target.[icon_id] = source.[icon_id] and target.[tag] = source.[tag]
when not matched then
    insert ([icon_id], [tag], [author], [create_date], [modifier], [modified_date])
    values (source.[icon_id], source.[tag], 'justinpo@buildontechnologies.com', getdate(), 'justinpo@buildontechnologies.com', getdate())
when not matched by source then
    delete;
go

with rooms as (
    select * from [VeoSolutions_QA].[dbo].[rooms]
)
merge into [VeoSolutions_DEV].[dbo].[rooms] as target
using rooms as source
on target.[id] = source.[id]
when matched then
    update set 
        target.[name] = source.[name],
        target.[icon_id] = source.[icon_id],
        target.[modifier] = 'justinpo@buildontechnologies.com',
        target.[modified_date] = getdate()
when not matched then
    insert ([id], [name], [icon_id], [author], [create_date], [modifier], [modified_date])
    values (source.[id], source.[name], source.[icon_id], 'justinpo@buildontechnologies.com', getdate(), 'justinpo@buildontechnologies.com', getdate());
go

with room_sections as (
    select * from [VeoSolutions_QA].[dbo].[room_sections]
)
merge into [VeoSolutions_DEV].[dbo].[room_sections] as target
using room_sections as source
on target.[id] = source.[id]
and target.[room_id] = source.[room_id]
when matched then
    update set 
        target.[area_id] = source.[area_id],
        target.[sub_area_id] = source.[sub_area_id],
        target.[modifier] = 'justinpo@buildontechnologies.com',
        target.[modified_date] = getdate()
when not matched then 
    insert ([id], [room_id], [area_id], [sub_area_id], [author], [create_date], [modifier], [modified_date])
    values (source.[id], source.[room_id], source.[area_id], source.[sub_area_id], 'justinpo@buildontechnologies.com', getdate(), 'justinpo@buildontechnologies.com', getdate());   
go