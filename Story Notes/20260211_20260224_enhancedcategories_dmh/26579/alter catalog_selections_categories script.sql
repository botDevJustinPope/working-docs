/*
USE VeoSolutions_DEV
USE VeoSolutions_QA
USE VeoSolutions_PREVIEW
USE VeoSolutions_STAGING

USE AFI_VeoSolutions
USE CCDI_VeoSolutions
USE EPLAN_VEoSolutions
use VeoSolutions
*/

-- Add new column as nullable
alter table dbo.catalog_selections_categories
add has_non_estimated_options bit null;

alter table dbo.catalog_selections_categories
add has_estimated_options bit null;

-- set default value for existing records
update csc 
set csc.has_non_estimated_options = 0,
    csc.has_estimated_options = 0
from dbo.catalog_selections_categories csc

-- set value for records with non estimated options
update csc_sub 
set csc_sub.has_non_estimated_options = 1
from catalog_selections_categories csc_sub
inner join catalog_selections_categories csc_root on csc_sub.parent_category_id = csc_root.category_id
inner join catalog_selections cs on cs.source in ('catalog', 'user')
                                and cs.session_id = csc_sub.session_id
                                and (LOWER(cs.application) = LOWER(csc_root.category_name) OR LOWER(cs.application) = LOWER(csc_root.external_id))
                                and (LOWER(cs.product) = LOWER(csc_sub.category_name) OR LOWER(cs.product) = LOWER(csc_sub.external_id))

-- set value for records with estimated options
update csc_sub 
set csc_sub.has_estimated_options = 1
from catalog_selections_categories csc_sub
inner join catalog_selections_categories csc_root on csc_sub.parent_category_id = csc_root.category_id
inner join catalog_selections cs on cs.source in ('Prices Landed')
                                and cs.session_id = csc_sub.session_id
                                and (LOWER(cs.application) = LOWER(csc_root.category_name) OR LOWER(cs.application) = LOWER(csc_root.external_id))
                                and (LOWER(cs.product) = LOWER(csc_sub.category_name) OR LOWER(cs.product) = LOWER(csc_sub.external_id))


-- Alter columns to set as not null
alter table dbo.catalog_selections_categories
alter column has_non_estimated_options bit not null;

alter table dbo.catalog_selections_categories
alter column has_estimated_options bit not null;