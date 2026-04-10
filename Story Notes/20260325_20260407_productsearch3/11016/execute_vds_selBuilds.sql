declare @session_id UNIQUEIDENTIFIER = '103472b3-30c0-4683-ac1b-a3a9be1c3e9a',
	@area VARCHAR(100) = '',
	@sub_area VARCHAR(100) = '',
	@application VARCHAR(100) = 'Cabinets',
	@build_id INT = 0,
	@only_with_selections BIT = 0,
	@builder_overrides_enabled BIT = 0,
	@security_token UNIQUEIDENTIFIER = '01234567-89AB-CDEF-0000-123456789ABC';

execute [dbo].[vds_selBuilds] @session_id, @area, @sub_area, @application, @build_id, @only_with_selections, @builder_overrides_enabled, @security_token;