/*
    This script generates a list of series names to be used to insert into dbo.[account_organization_series].
    The series names are set in a table and inserted into the database for a specified organization.
    The script includes an option to either print the generated series names or execute the insert statements into the database.

    Setup:
    1. Ensure you are connecte to the right database (defaulted to VeoSolutionsSecurity_DEV).
    2. Adjust the organization name in the @org_name variable if needed.
    3. Adjust the author variable if desired.
    4. Adjust the list of series names and property widths as needed.
    5. Set @executeInsert to 1 if you want to execute insert statements (currently set to 0 for safety).

*/

use [VeoSolutionsSecurity_DEV];
go

set XACT_ABORT on;

-- Configuration
declare @org_name NVARCHAR(255) = 'STAGGERED-QA';
declare @author NVARCHAR(50) = 'ChatGPT';
declare @executeInsert bit = 0;  -- Set to 1 to execute insert statements


declare @orgId UNIQUEIDENTIFIER,
        @accountId UNIQUEIDENTIFIER,
        @orgName NVARCHAR(255);

select 
    @orgId = o.organization_id,
    @accountId = ao.account_id,
    @orgName = o.name
from dbo.[account_organizations] ao 
inner join dbo.[organizations] o on ao.organization_id = o.organization_id
where o.name like @org_name;

print('Setting up series for organization: ' + @orgName);

declare @series table (name NVARCHAR(255), combinations INT);
insert into @series (name) VALUES
('Summit'),
('Heritage'),
('Vista'),
('Signature'),
('Reserve'),
('Classic'),
('Craftsman'),
('Modern Living'),
('Cottage'),
('Prime'),
('Founders'),
('Evergreen'),
('Highlands'),
('Lakeside'),
('Townhome'),
('Courtyard'),
('Landmark'),
('Parkside'),
('Horizon'),
('Meadow'),
('Artisan'),
('Keystone'),
('Pinnacle'),
('Orchard'),
('Brookside'),
('Ridgeview'),
('Elevation'),
('Willow'),
('Haven'),
('Trailhead');

if @executeInsert = 1
BEGIN 
    BEGIN TRY
        BEGIN TRANSACTION

        insert into dbo.[account_organization_series] (
            account_id,
            organization_id,
            series_id,
            name,
            archive,
            author,
            create_date,
            modifier,
            modified_date
        )
        select 
            @accountId, -- account_id
            @orgId, -- organization_id
            NEWID(), -- series_id
            n.name, -- name
            0, -- archive
            @author, -- author
            GETDATE(), -- create_date
            @author, -- modifier
            GETDATE()  -- modified_date
        from @series n;

        COMMIT TRANSACTION
        print('Insert statements executed successfully.');
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION

        PRINT('Error occurred: ' + ERROR_MESSAGE());
        THROW;
    END CATCH
END
ELSE
BEGIN
    DECLARE @count INT;
    SELECT @count = COUNT(*) FROM @series;
    PRINT(CAST(@count AS NVARCHAR(20)) + ' names generated but not executed.');

    DECLARE @name NVARCHAR(255);

    DECLARE name_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT [name] FROM @series ORDER BY [name];

    OPEN name_cursor;
    FETCH NEXT FROM name_cursor INTO @name;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT(@name);
        FETCH NEXT FROM name_cursor INTO @name;
    END

    CLOSE name_cursor;
    DEALLOCATE name_cursor;

    print('Set @executeInsert to 1 to execute insert into series.');
END
