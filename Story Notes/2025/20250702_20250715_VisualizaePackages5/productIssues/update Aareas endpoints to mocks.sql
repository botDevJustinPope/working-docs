/*

-- DEV DATABASES

use [VeoSolutions_DEV];
go
use [VeoSolutions_QA];
go
use [VEOSolutions_PREVIEW];
go
use [VEOSolutions_STAGING];
go
*/
/*

-- PROD DATABASES

use [VEOSolutions];
GO
use [AFI_VEOSolutions];
GO
use [CCDI_VEOSolutions];
go
use [EPLAN_VEOSolutions];
GO
*/

/*

-- this reverts the Aareas Provider back to the mock endpoints

update dbo.VisualizationProvider
set GetAllPackagesUrl = 'https://ef4a476a-a264-4e77-9d82-cbec39747858.mock.pstmn.io/GetAllPackages',
    RenderableProductUrl = 'https://ef4a476a-a264-4e77-9d82-cbec39747858.mock.pstmn.io/api/ClientProduct/GetClientProductlist/BuildOn'
where Id = 'cc4c17fb-25ed-47f2-af05-af576bbaf6ee'

*/


/*

-- this reverts the Aareas Provider back to the normal endpoints

update dbo.VisualizationProvider
set GetAllPackagesUrl = 'https://apirc.aareas.com/api/ClientProduct/GetClientProductPackageList/false/veodesignstudio/b73ce491-bc27-42a7-ad85-6463eca43bfd',
    RenderableProductUrl = 'https://apirc.aareas.com/api/ClientProduct/GetClientProductlist/BuildOn'
where Id = 'cc4c17fb-25ed-47f2-af05-af576bbaf6ee'

*/