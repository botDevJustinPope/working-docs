declare @session_id uniqueidentifier = '4de6c539-1044-462c-bb42-ebcebf8a265b';

select
    s.[session_id]
from [VEOSolutions].[dbo].[account_organization_user_profile_plan_catalog_sessions] s
where s.[session_id] = @session_id

select * from [VEOSolutions].[dbo].[catalog_selections]
where [session_id] = @session_id
    and [source] = 'catalog'

select * from [VEOSolutions].[dbo].[session_changes]
where [session_id] = @session_id