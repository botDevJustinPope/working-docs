/*
*** 'DEV' DBS ***

USE [VeoSolutions_DEV]
use [VeoSolutions_QA]
use [VeoSolutions_Staging]
use [VeoSolutions_Preview]

*** Prod DBS ***

use [AFI_VEOSolutions]
use [CCDI_VEOSolutions]
use [EPLAN_VEOSolutions]
use [VEOSolutions]

*/

delete from dbo.features where [id] = 66;

insert into dbo.features ([id], [lookup_key], [name], [description])
values (66, 'use_enhanced_categories', 'Use Enhanced Product Categories', 'When ON VDS will support enhanced category features such as: custom names, nested categories and custom sort orders.');