
delete from VeoSolutions_DEV.dbo.ThemeVideoLink where ThemeLookupKey = 'wild' and Category = 'DESIGNING_YOUR_HOME';

insert into VeoSolutions_DEV.dbo.ThemeVideoLink 
values (NEWID(), 'wild', 'DESIGNING_YOUR_HOME', 'https://www.youtube.com/embed/dQw4w9WgXcQ?si=MqaCigJq4agkuLCJ?rel=0&autoplay=1', 'Justin Pope', GETDATE(), 'Justin Pope', GETDATE());


select * from VeoSolutions_DEV.dbo.ThemeVideoLink