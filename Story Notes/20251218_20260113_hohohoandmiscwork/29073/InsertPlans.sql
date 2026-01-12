/*
    This script generates a list of plan names to be used to insert into dbo.[account_organization_plans].
    The plan names are created by combining base plan names with suffixes from two types: "Names" and "Versions".
    The combination type and number of combinations are determined randomly for each base plan name.
    The script includes an option to either print the generated plan names or execute the insert statements into the database.

    Setup:
    1. Ensure you are connecte to the right database (defaulted to VeoSolutionsSecurity_DEV).
    2. Adjust the organization name in the @org_name variable if needed.
    3. Adjust the author variable if desired.
    4. Adjust the list of plan names and property widths as needed.
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

print('Setting up plans for organization: ' + @orgName);

declare @type_Names varchar(10) = 'Names';
declare @type_Versions varchar(10) = 'Versions';
declare @type_blank varchar(10) = 'Blank';

declare @plans table (name NVARCHAR(255), combinationType varchar(10), combinations int);
insert into @plans (name) VALUES
('Aspen'),
('Birch'),
('Cedar'),
('Dogwood'),
('Elm'),
('Fir'),
('Hawthorn'),
('Juniper'),
('Laurel'),
('Magnolia'),
('Oakmont'),
('Pinecrest'),
('Redwood'),
('Sequoia'),
('Sycamore'),
('Willow'),
('Alder'),
('Briar'),
('Cypress'),
('Driftwood'),
('Everglade'),
('Fernbrook'),
('Glenwood'),
('Highland'),
('Ivy Ridge'),
('Kingston'),
('Lakeshore'),
('Meadowbrook'),
('Northfield'),
('Orchard'),
('Parkview'),
('Quail Run'),
('Riverstone'),
('Sandstone'),
('Timberline'),
('Vista'),
('Westbrook'),
('Brookhaven'),
('Clearwater'),
('Fairview'),
('Grandview'),
('Harbor'),
('Ironwood'),
('Maplewood'),
('Palisade'),
('Ridgecrest'),
('Stonehaven'),
('Summit'),
('Trailside'),
('Valleyview');

declare @type_Names_values table ([values] NVARCHAR(50));
insert into @type_Names_values ([values]) VALUES
('Standard'),
('Deluxe'),
('Premium'),
('Modern'),
('Contemporary'),
('Executive'),
('Farmhouse'),
('Industrial'),
('Minimalist'),
('Rustic'),
('Luxury');

declare @type_Versions_values table ([values] NVARCHAR(50));
insert into @type_Versions_values ([values]) VALUES
('A'),
('B'),
('C'),
('D'),
('E'),
('F');

-- Update plans to set cominationType
-- random number between 0 and 10
-- 0-2 = Blank
-- 3-6 = Names
-- 7-10 = Versions
update p
set combinationType = 
    CASE 
        WHEN randTable.rnum BETWEEN 0 AND 2 THEN @type_blank
        WHEN randTable.rnum BETWEEN 3 AND 6 THEN @type_Names
        ELSE @type_Versions
    END
from @plans as p
cross apply
(
    select 
        CAST(RAND(CHECKSUM(NEWID())) * 10 as int) as rnum
    from @plans
) as randTable;

-- update combinations based on combinationType
update p
set combinations = 
    CASE 
        WHEN p.combinationType = @type_Names 
            THEN CAST((RAND(CHECKSUM(NEWID())) * (select count(*) from @type_Names_values)) + 1 as int)
        WHEN p.combinationType = @type_Versions 
            THEN CAST((RAND(CHECKSUM(NEWID())) * (select count(*) from @type_Versions_values)) + 1 as int)
        ELSE 1
    END
from @plans as p;

declare @NewPlanNames table (plan_name NVARCHAR(255));
insert into @NewPlanNames (plan_name)
select
    p.name + v.[value] as plan_name
from @plans as p 
cross apply (
    select top (p.combinations)
        [values] as [value]
    from 
        (   select  ' ' + [values] as [values] from @type_Names_values
            where p.combinationType = @type_Names
            union all
            select  ' ' + [values] as [values] from @type_Versions_values
            where p.combinationType = @type_Versions
            union all 
            select '' as [values]
            where p.combinationType = @type_blank
        ) as v
) v

if @executeInsert = 1
BEGIN 
    BEGIN TRY
        BEGIN TRANSACTION

        insert into dbo.[account_organization_plans] (
            account_id,
            organization_id,
            plan_id,
            name,
            address_specific,
            archive,
            author,
            create_date,
            modifier,
            modified_date
        )
        select 
            @accountId, -- account_id
            @orgId, -- organization_id
            NEWID(), -- plan_id
            n.plan_name, -- name
            0, -- address_specific
            0, -- archive
            @author, -- author
            GETDATE(), -- create_date
            @author, -- modifier
            GETDATE()  -- modified_date
        from @NewPlanNames n;

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
    SELECT @count = COUNT(*) FROM @NewPlanNames;
    PRINT(CAST(@count AS NVARCHAR(20)) + ' names generated but not executed.');

    DECLARE @name NVARCHAR(255);

    DECLARE name_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT plan_name FROM @NewPlanNames ORDER BY plan_name;

    OPEN name_cursor;
    FETCH NEXT FROM name_cursor INTO @name;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT(@name);
        FETCH NEXT FROM name_cursor INTO @name;
    END

    CLOSE name_cursor;
    DEALLOCATE name_cursor;

    print('Set @executeInsert to 1 to execute insert into plans.');
END
