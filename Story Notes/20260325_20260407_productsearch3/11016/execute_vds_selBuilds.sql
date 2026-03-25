declare @session_id UNIQUEIDENTIFIER = '94791a2a-5798-4dcd-b2e0-af0c2eb0d26b',
	@area VARCHAR(100) = '',
	@sub_area VARCHAR(100) = '',
	@application VARCHAR(100) = '',
	@build_id INT = 12239175,
	@only_with_selections BIT = 0,
	@builder_overrides_enabled BIT = 0,
	@security_token UNIQUEIDENTIFIER = '01234567-89AB-CDEF-0000-123456789ABC';

execute [VeoSolutions_Staging].[dbo].[vds_selBuilds] @session_id, @area, @sub_area, @application, @build_id, @only_with_selections, @builder_overrides_enabled, @security_token;