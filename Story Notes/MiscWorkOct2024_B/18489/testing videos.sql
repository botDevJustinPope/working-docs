--use [VEOSolutions_DEV];
use [VEOSolutions_QA];
go
/*
    modify the db for the environment
    these records are added for testing emdedded videos
*/
declare @tempVideos table (ThemeLookupKey nvarchar(50), Category nvarchar(50), [URL] nvarchar(500), Author nvarchar(50))
insert into @tempVideos (ThemeLookupKey, Category, [URL], Author)
values   
       ('wild', 'DESIGNING_YOUR_HOME', 'https://www.youtube.com/embed/dQw4w9WgXcQ?si=MqaCigJq4agkuLCJ?rel=0', 'Justin Pope'),
       ('wild', 'UNDERSTANDING_YOUR_BUDGET', 'https://www.youtube.com/embed/7LuwPdp-_4c?si=yG6HAfvHCog4ZkVc?rel=0', 'Justin Pope'),
       ('sith', 'DESIGNING_YOUR_HOME', 'https://www.youtube.com/embed/S3OtoO5zjjU?si=NCie8mTIas2bpjYn?rel=0', 'Justin Pope'),
       ('sith', 'UNDERSTANDING_YOUR_BUDGET', 'https://www.youtube.com/embed/BTP-PXeG9Fg?si=k601dOv0erNe6bAN?rel=0', 'Justin Pope')

merge into [dbo].[ThemeVideoLink] as target
using @tempVideos as source
on target.ThemeLookupKey = source.ThemeLookupKey and target.Category = source.Category
when matched then
    update set [URL] = source.[URL], Modifier = source.Author, ModifiedDate = getdate()
when not matched then
    insert (ID, ThemeLookupKey, Category, [URL], Author, CreateDate, Modifier, ModifiedDate)
    values (newid(), source.ThemeLookupKey, source.Category, source.[URL], source.Author, getdate(), source.Author, getdate());

select * from [dbo].[ThemeVideoLink]

