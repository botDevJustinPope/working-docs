/*
USE VeoSolutions_DEV
USE VeoSolutions_QA
USE VeoSolutions_PREVIEW
USE VeoSolutions_STAGING

USE AFI_VeoSolutions
USE EPLAN_VeoSolutions
USE CCDI_VeoSolutions
USE VeoSolutions
*/

INSERT INTO AFI_VeoSolutions.dbo.features ([id],[lookup_key],[description],[name])
VALUES(69, 'assigned_communities', 'When this flag is ON, and a user is assigned to at least one community, they cannot see or generate data for any communities outside those assigned. This includes: user registration, impersonation, plan creation and viewing options data.', 'Restrict Users to Assigned Communities');
go

INSERT INTO EPLAN_VeoSolutions.dbo.features ([id],[lookup_key],[description],[name])
VALUES(69, 'assigned_communities', 'When this flag is ON, and a user is assigned to at least one community, they cannot see or generate data for any communities outside those assigned. This includes: user registration, impersonation, plan creation and viewing options data.', 'Restrict Users to Assigned Communities');
go

INSERT INTO CCDI_VeoSolutions.dbo.features ([id],[lookup_key],[description],[name])
VALUES(69, 'assigned_communities', 'When this flag is ON, and a user is assigned to at least one community, they cannot see or generate data for any communities outside those assigned. This includes: user registration, impersonation, plan creation and viewing options data.', 'Restrict Users to Assigned Communities');
go

INSERT INTO VeoSolutions.dbo.features ([id],[lookup_key],[description],[name])
VALUES(69, 'assigned_communities', 'When this flag is ON, and a user is assigned to at least one community, they cannot see or generate data for any communities outside those assigned. This includes: user registration, impersonation, plan creation and viewing options data.', 'Restrict Users to Assigned Communities');
go