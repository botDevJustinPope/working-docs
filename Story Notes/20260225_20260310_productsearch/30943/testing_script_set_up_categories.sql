/*
use VeoSolution_DEV;
use VeoSolution_QA;
use VeoSolution_PREVIEW;
use VeoSolution_Staging;

This script is used to set up a sessions categories for testing changes in 30943
The scenario is that for a session the categories do not return off the procedure vds_selCatalogSelectionsCategories

*/

Declare @session_id UNIQUEIDENTIFIER;

declare @EXECUTION_VALUE_DELETE_CATEGORIES varchar(200) = 'delete_categories';
DECLARE @EXECUTION_VALUE_SET_HAS_OPTIONS_FIELDS_TO_FALSE varchar(200) = 'set_has_options_fields_to_false';

Declare @execution varchar(200); -- use this variable to set the execution value for testing purposes. Possible values are 'delete_categories' and 'set_has_options_fields_to_false'

if @execution = @EXECUTION_VALUE_DELETE_CATEGORIES
BEGIN 

    delete from dbo.[catalog_selections_categories] where session_id = @session_id;

END
else if @execution = @EXECUTION_VALUE_SET_HAS_OPTIONS_FIELDS_TO_FALSE
BEGIN
    
    update dbo.[catalog_selections_categories] 
    set has_estimated_options = 0,
        has_non_estimated_options = 0
    where session_id = @session_id;

END
