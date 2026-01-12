drop table if exists ##onlineDBS;
drop table if exists ##partNumbers;
drop table if exists ##temp_colors;

declare @sql nvarchar(max);

create table ##partNumbers (PartNumber nvarchar(50), global_product_id UNIQUEIDENTIFIER);
insert into ##partNumbers (PartNumber, global_product_id) values
('YDAMS/TRF','dfb0b7f7-5328-4c29-aa30-17dd0a208480'),
    ('YDAMS/MID','4B437007-7C84-47CC-B4A7-9901785964FF'),
    ('YDAMS/BRY','224584DE-8ABF-47F3-BDDD-EAFAA3CDEE6F'),
    ('OG001R3/6','7B73CF99-6105-4FB7-AB38-173C337EC52E'),
    ('OG0BGR3/1','F56EA5EF-196E-4934-B0A1-A3D0D60CDD16'),
    ('OG0WYF3/1','045505C5-60BC-4905-B824-F88EB6F36B10'),
    ('OPF1.6CM/13','42241A97-D636-411E-BDF1-29921B7E652E'),
    ('12454/25210','9F152889-EE65-41DC-8C01-A5DAEE0FDA45'),
    ('1BP93B/720','857243E0-E029-4ED6-BF76-62BFD6DA82EC'),
    ('19736/825','957B516B-C900-4F16-ADDB-BB541ECA89A7'),
    ('19736/858','EEDB3CDC-CC5F-402B-80E1-AF1DE3366CB2'),
    ('6RR20/RR98','25BB6B50-38ED-475F-932A-2EEE8E9EB60A'),
    ('6DV20/DV99','472F83D6-1D0C-493B-AC87-C1EDA2676067'),
    ('6AL/AL05','460B0898-BBD7-4F7C-877F-B1FB3AD87BFB'),
    ('6BRI18/CO','A9C8EF2C-98ED-45C8-B759-5121C425B9D6'),
    ('6AD24/BB','959A07AB-D7DD-42E9-8A5D-0365423BD5EF'),
    ('6BRI18/AS','E044D8B7-ADEA-4EC8-AE8A-9E6C3F745347'),
    ('6MDM/GS','8B74B1BC-F802-4D2A-96A5-44B22BEEE4DB'),
    ('6MDM/NB','466241F8-4EBF-4B94-8F14-2E5859C808CE'),
    ('6CHL/CHL1B','A9DF8509-EE2E-43D9-9F8E-3AF11666FDA7'),
    ('6CW3/CW14','36F8492B-B2DB-47CE-BAFA-040D3D13E951'),
    ('6BVM/218','2EA546C6-88D0-498B-9B31-70FBBBCAAE23'),
    ('6CW3/CW12','77D1A632-2C41-4DD1-A777-E00B378BE9EC'),
    ('6MHB/251','EF22F888-52A4-4198-95B2-B4FB30A8ED0A'),
    ('6MHB/584','DFE87AB8-74BF-4076-B046-97E8B779A6AC'),
    ('6MHB/252','3ECE1DB0-E714-4F4E-B9B6-CE70EFF420DE'),
    ('3SENMAP7/PAS','84C98E05-94BC-44BF-9E8B-F41E05DA91FF'),
    ('3VE230/00157','305F6A14-04A9-4068-94B5-16E00465CADA'),
    ('3CTM456/Syr','BA4C00FC-CB57-49D0-9463-D26010CEA9C7'),
    ('3AA759/00510','920CF461-7E4F-4F01-8DCE-5D60A4C8BBFF'),
    ('3AA759/97E22','A7088E25-5078-4F5E-826D-FF367C20C143'),
    ('3ATHC5A/0781','63E4AC96-1F28-418F-8724-8C5150F19549');

create table ##temp_colors (db nvarchar(256), part_no nvarchar(50), [name] nvarchar(256), colors_gpc_id UNIQUEIDENTIFIER, desired_gpc_id UNIQUEIDENTIFIER);


Select * 
into ##onlineDBS
from [master].[sys].[databases] where state_desc = 'ONLINE';


declare db_cursor cursor for
select [name] from ##onlineDBS

open db_cursor
declare @DBName nvarchar(256)
fetch next from db_cursor into @DBName
while @@FETCH_STATUS = 0
BEGIN 

    print @DBName;

    set @sql = 'USE [' + @DBName + '];' + CHAR(13) + CHAR(10) +
               'IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''colors'')' + CHAR(13) + CHAR(10) +
               'BEGIN' + CHAR(13) + CHAR(10) +
               '    insert into ##temp_colors (db, part_no, [name], colors_gpc_id, desired_gpc_id) ' + CHAR(13) + CHAR(10) +
               '    select ''' + @DBName + ''' as [db], c.[part_no], c.[name], c.[global_product_id] as [colors_gpc_id], p.[global_product_id] as [desired_gpc_id] ' + CHAR(13) + CHAR(10) +
               '    from [dbo].[colors] c ' + CHAR(13) + CHAR(10) +
               '        inner join ##partNumbers p on c.part_no = p.PartNumber' + CHAR(13) + CHAR(10) +
               'END';

    print @sql;
    exec sp_executesql @sql;

    print 'Done with ' + @DBName;

    fetch next from db_cursor into @DBName
END

close db_cursor
deallocate db_cursor


select * from ##temp_colors where colors_gpc_id <> desired_gpc_id order by db, part_no;
