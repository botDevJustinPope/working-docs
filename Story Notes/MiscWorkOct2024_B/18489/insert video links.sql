declare @tempTable table (id uniqueidentifier, ThemeLookUpKey nvarchar(50), VideoCategory varchar(50), [Url] nvarchar(2048));
insert into @tempTable (id, ThemeLookUpKey, VideoCategory, [Url])
VALUES ('', 'Theme1', 'Category1', 'http://www.google.com'),
       ('', 'Theme2', 'Category2', 'http://www.yahoo.com'),
       ('', 'Theme3', 'Category3', 'http://www.bing.com');