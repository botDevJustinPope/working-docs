/*
    This script generates a list of community names to be used to insert into dbo.[account_organization_communities].
    The community names are created by combining base community names with suffixes from property widths.
    The community names are set in a table and inserted into the database for a specified organization.
    The script includes an option to either print the generated community names or execute the insert statements into the database.

    Setup:
    1. Ensure you are connecte to the right database (defaulted to VeoSolutionsSecurity_DEV).
    2. Adjust the organization name in the @org_name variable if needed.
    3. Adjust the author variable if desired.
    4. Adjust the list of community names and property widths as needed.
    5. Set @executeInsert to 1 if you want to execute insert statements (currently set to 0 for safety).

*/

use [VeoSolutionsSecurity_DEV];
go

set XACT_ABORT on;

-- Configuration
declare @org_name NVARCHAR(255) = 'STAGGERED-QA';
declare @author NVARCHAR(50) = 'ChatGPT';
declare @executeInsert bit = 1;  -- Set to 1 to execute insert statements


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

print('Setting up communities for organization: ' + @orgName);

declare @communities table (name NVARCHAR(255), combinations INT);
insert into @communities (name) VALUES
('Amberwood Grove'),
('Willowcrest Village'),
('Brookstone Ridge'),
('Cedar Hollow Estates'),
('Magnolia Trails'),
('Oakview Preserve'),
('Silverleaf Springs'),
('Pinehaven Meadows'),
('Stonegate Crossing'),
('Riverbend Landing'),
('Briarwood Commons'),
('Sunfield Terrace'),
('Maple Run Heights'),
('Westhaven Park'),
('Highland Orchard'),
('Foxglove Falls'),
('Lakewind Point'),
('Copperstone Farms'),
('Meadowlark Ridge'),
('Hearthstone Creek'),
('Birchwood Manor'),
('Wildflower Junction'),
('Saddlebrook Reserve'),
('Timberline Court'),
('Rosemont Valley'),
('Cypress Bluff'),
('Arbor Terrace'),
('Indigo Hills'),
('Clearwater Haven'),
('Granite Creek Village'),
('Autumn Ridge Estates'),
('Golden Prairie Crossing'),
('Whispering Pines Cove'),
('Vista Lake Retreat'),
('Northgate Meadows'),
('Palisade Park'),
('Juniper Springs'),
('Horizon Pointe'),
('Redbud Hollow'),
('Legacy Oaks');

-- Update combinations to a random number between 1 and 5
update @communities
set combinations = CAST((RAND(CHECKSUM(NEWID())) * 5) + 1 as int);


declare @propertyWidths table (width NVARCHAR(50));
insert into @propertyWidths (width) VALUES
('35'),
('40'),
('45'),
('50'),
('55'),
('60'),
('65'),
('70'),
('75'),
('80'),
('85'),
('90');

declare @NewCommunityNames table (community_name NVARCHAR(255));
insert into @NewCommunityNames (community_name)
select 
    c.name + ' - ' + pw.width as community_name
from @communities as c 
cross apply (
    select top (c.combinations)
        width 
    from @propertyWidths 
    order by NEWID()
) pw
order by c.name, pw.width;



if @executeInsert = 1
BEGIN 
    BEGIN TRY
        BEGIN TRANSACTION

        insert into dbo.[account_organization_communities] (
            account_id,
            organization_id,
            community_id,
            name,
            echelon_community_id,
            archive,
            author,
            create_date,
            modifier,
            modified_date
        )
        select 
            @accountId, -- account_id
            @orgId, -- organization_id
            NEWID(), -- community_id
            n.community_name, -- name
            0, -- echelon_community_id
            0, -- archive
            @author, -- author
            GETDATE(), -- create_date
            @author, -- modifier
            GETDATE()  -- modified_date
        from @NewCommunityNames n;

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
    SELECT @count = COUNT(*) FROM @NewCommunityNames;
    PRINT(CAST(@count AS NVARCHAR(20)) + ' names generated but not executed.');

    DECLARE @name NVARCHAR(255);

    DECLARE name_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT [community_name] FROM @NewCommunityNames ORDER BY [community_name];

    OPEN name_cursor;
    FETCH NEXT FROM name_cursor INTO @name;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT(@name);
        FETCH NEXT FROM name_cursor INTO @name;
    END

    CLOSE name_cursor;
    DEALLOCATE name_cursor;

    print('Set @executeInsert to 1 to execute insert into communities.');
END
