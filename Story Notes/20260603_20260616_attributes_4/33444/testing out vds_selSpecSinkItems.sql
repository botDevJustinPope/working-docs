use [Eplan_veosolutions];
go

declare @page_index int = 0,
        @page_size int = 200,
        @session_id uniqueidentifier = 'cf5b38b6-27b7-4ca0-975c-66f4ff1d29a5',
        @build_id int = 1005370599,
        @item_id VARCHAR(50) = 'EDGE',
        @search_criteria VARCHAR(255) = '',
        @selected_part_no VARCHAR(255) = '',
        @builder_overrides_enabled bit = 1,
        @security_token uniqueidentifier = '01234567-89AB-CDEF-0000-123456789ABC',
        @debug bit = 1;
/*
select * from [Eplan_VeoSolutions].[information_schema].[synonyms]

*/

execute [EPLAN_VEOSolutions].[dbo].[vds_selSpecSinkItems]   @page_index, 
                                                            @page_size, 
                                                            @session_id,
                                                            @build_id,
                                                            @item_id,
                                                            @search_criteria,
                                                            @selected_part_no,
                                                            @builder_overrides_enabled,
                                                            @security_token,
                                                            @debug;

-- =====================
-- Authentication
-- =====================
IF (dbo.vdsf_isValidSecurityToken(@security_token) = 0)
BEGIN
	RAISERROR('Access Denied.',16,1)
	RETURN
END

-- =========================
-- Parameter Cleanup
-- =========================
if len(@selected_part_no) > 0
	set @search_criteria = ''

-- ============================
-- Variable Declaration
-- ============================
declare @application_id varchar(10) = '2'
declare @product_id varchar(10) = 'O'
declare @item_class varchar(50) = 'sink'
declare @spec_id int
declare @area_id varchar(50)
declare @sub_area_id varchar(50)
declare @location_id int
declare @effective_date datetime
declare @external_organization_id varchar(20)

select
	@area_id = area_id,
	@sub_area_id = sub_area_id,
	@location_id = location_id,
	@spec_id = vpm.spec_id,
	@external_organization_id = builder_id
from
	veo_plan_builds vpb with (nolock)
	left join veo_plan_mstr vpm with (nolock) on vpm.plan_id = vpb.plan_id
	left join veo_spec_mstr vsm with (nolock) on vsm.spec_id = vpm.spec_id
where
	vpb.build_id_num = @build_id

select
	@effective_date = effective_date
from
	catalog_selections_areas csa with (nolock)
	left join catalog_selections cs with (nolock) on csa.session_id = cs.session_id and csa.selected_field_group = cs.row_id
	left join account_organization_user_profile_plan_catalog_sessions aouppcs with (nolock) on aouppcs.session_id = cs.session_id
where
	csa.session_id = @session_id
	and csa.build_id = @build_id

declare @colors table
(
	product_id varchar(10),
	style_id varchar(50),
	color_id varchar(50),
	part_no varchar(100),
	name varchar(100),
	part_no_override varchar(100),
	part_name_official varchar(150),
	image_id int null
)

-- =========================================
-- spec_items --> groups -> styles -> colors
-- =========================================
insert into @colors
select distinct
	c.product_id,
	c.style_id,
	c.color_id,
	c.part_no,
	c.name,
	cco.customer_reference_no,
	case
		when (@builder_overrides_enabled = 1 and DATALENGTH(cco.color_private_label) > 0)
			then (cco.color_private_label)
		else c.name
	end as part_name_official,
	cco.image_id
from
	veo_spec_items si with (nolock)
	left join veo_styles_groups sg with (nolock) on sg.group_id = si.item
	left join catalog_selections_group_detail sgd with (nolock) on session_id = @session_id and sgd.group_id = sg.group_id
	left join veo_styles s with (nolock) on s.product_id = sg.product_id and s.style_id = sgd.item
	left join veo_colors c with (nolock) on c.product_id = s.product_id and c.style_id = s.style_id
	left join veo_colors_customer_overrides cco with (nolock) on cco.part_no = c.part_no and cco.customer_id = @external_organization_id
where
	spec_id = @spec_id
	and sgd.item_type = 'style'
	AND ISNULL(sgd.area_id, '') in ('', @area_id)
	AND ISNULL(sgd.sub_area_id, '') in ('', @sub_area_id)
	and si.application_id = @application_id
	and si.product_id = @product_id
	and si.item_type = 'group'
	and s.class = @item_class

if @debug = 1
	SELECT 'spec_items -> groups -> styles -> colors' as selection, * FROM @colors

-- =========================================
-- spec_items --> groups -> colors
-- =========================================
MERGE @colors AS target
USING
(
	--insert into @colors
	select distinct
		c.product_id,
		c.style_id,
		c.color_id,
		c.part_no,
		c.name,
		cco.customer_reference_no,
		case
			when (@builder_overrides_enabled = 1 and DATALENGTH(cco.color_private_label) > 0)
				then (cco.color_private_label)
			else c.name
		end as part_name_official,
		cco.image_id
	from
		veo_spec_items si with (nolock)
		left join veo_styles_groups sg with (nolock) on sg.group_id = si.item
		left join catalog_selections_group_detail sgd with (nolock) on session_id = @session_id and sgd.group_id = sg.group_id
		left join veo_colors c with (nolock) on c.part_no = sgd.item
		left join veo_styles s with (nolock) on s.product_id = c.product_id and s.style_id = c.style_id
		left join veo_colors_customer_overrides cco with (nolock) on cco.part_no = c.part_no and cco.customer_id = @external_organization_id
	where
		spec_id = @spec_id
		and sgd.item_type = 'color'
		AND ISNULL(sgd.area_id, '') in ('', @area_id)
		AND ISNULL(sgd.sub_area_id, '') in ('', @sub_area_id)
		and si.application_id = @application_id
		and si.product_id = @product_id
		and si.item_type = 'group'
		and s.class = @item_class
) as source
ON target.part_no = source.part_no
WHEN NOT MATCHED THEN
	INSERT (product_id, style_id, color_id, part_no, name, part_no_override, part_name_official, image_id) VALUES (source.product_id, source.style_id, source.color_id, source.part_no, source.name, source.customer_reference_no, source.part_name_official, source.image_id);

if @debug = 1
	SELECT 'spec_items -> groups -> colors' as selection, * FROM @colors

-- =========================================
-- spec_items --> styles -> colors
-- =========================================
MERGE @colors AS target
USING
(
	select distinct
		c.product_id,
		c.style_id,
		c.color_id,
		c.part_no,
		c.name,
		cco.customer_reference_no,
		case
			when (@builder_overrides_enabled = 1 and DATALENGTH(cco.color_private_label) > 0)
				then (cco.color_private_label)
			else c.name
		end as part_name_official,
		cco.image_id
	from
		veo_spec_items si with (nolock)
		left join veo_colors c with (nolock) on c.product_id = si.product_id and c.style_id = si.item
		left join veo_styles s with (nolock) on s.product_id = c.product_id and s.style_id = c.style_id
		left join veo_colors_customer_overrides cco with (nolock) on cco.part_no = c.part_no and cco.customer_id = @external_organization_id
	where
		spec_id = @spec_id
		and si.application_id = @application_id
		and si.product_id = @product_id
		and si.item_type = 'style'
		and s.class = @item_class
) as source
ON target.part_no = source.part_no
WHEN NOT MATCHED THEN
	INSERT (product_id, style_id, color_id, part_no, name, part_no_override, part_name_official, image_id) VALUES (source.product_id, source.style_id, source.color_id, source.part_no, source.name, source.customer_reference_no, source.part_name_official, source.image_id);

if @debug = 1
	SELECT 'spec_items -> styles -> colors' as selection, * FROM @colors

-- =========================================
-- spec_items --> colors
-- =========================================
MERGE @colors AS target
USING
(
	--insert into @colors
	select distinct
		c.product_id,
		c.style_id,
		c.color_id,
		c.part_no,
		c.name,
		cco.customer_reference_no,
		case
			when (@builder_overrides_enabled = 1 and DATALENGTH(cco.color_private_label) > 0)
				then (cco.color_private_label)
			else c.name
		end as part_name_official,
		cco.image_id
	from
		veo_spec_items si with (nolock)
		left join veo_colors c with (nolock) on c.part_no = si.item
		left join veo_styles s with (nolock) on s.product_id = c.product_id and s.style_id = c.style_id
		left join veo_colors_customer_overrides cco with (nolock) on cco.part_no = c.part_no and cco.customer_id = @external_organization_id
	where
		spec_id = @spec_id
		and si.application_id = @application_id
		and si.product_id = @product_id
		and si.item_type = 'color'
		and s.class = @item_class
) as source
ON target.part_no = source.part_no
WHEN NOT MATCHED THEN
	INSERT (product_id, style_id, color_id, part_no, name, part_no_override, part_name_official, image_id) VALUES (source.product_id, source.style_id, source.color_id, source.part_no, source.name, source.customer_reference_no, source.part_name_official, source.image_id);

if @debug = 1
	SELECT 'spec_items -> colors' as selection, * FROM @colors

-- =======================================================
-- remove parts explicitly excluded from spec area
-- =======================================================
DELETE
	c
FROM
	@colors c
	INNER JOIN dbo.vdsf_selSpecAreaExcludedParts(@session_id, @spec_id, @application_id, @product_id, @area_id, @sub_area_id, @location_id, @item_id) saep ON saep.part_no = c.part_no

-- =======================================================
-- remove not designer_selectable parts --> colors
-- =======================================================
delete
	c
from
	@colors c
	inner join veo_colors c1 with (nolock) on c1.part_no = c.part_no
	inner join veo_stocking_codes vsc with (nolock) on vsc.code = c1.stocking_code
where
	vsc.designer_selectable = 0

-- ===================
-- return paged values
-- ===================
declare @results table
(
	product_id varchar(10),
	style_id varchar(50),
	color_id varchar(50),
	part_no varchar(100),
	name varchar(100),
	part_no_override varchar(100),
	part_name_official VARCHAR(150),
	image_id int null,
	[row_number] int,
	[row_count] int
)

insert into @results
select distinct
	c.*,
	ROW_NUMBER() over (order by part_name_official) as [row_number],
	COUNT(part_no) over() as row_count
from
	@colors c
where
	c.part_no is not null
	and (
		@search_criteria = ''
		or c.name like '%' + @search_criteria + '%'
		or c.part_no like '%' + @search_criteria + '%'
		or (
			@builder_overrides_enabled = 1
			and (
				c.part_name_official like '%' + @search_criteria + '%'
				or c.part_no_override like '%' + @search_criteria + '%'
			)
		)
	)
order by
	part_name_official

-- if a particular part is requested, return the page with that part by calculating a new value for @page_index
if len(@selected_part_no) > 0
begin
	-- determine the row of the part no
	DECLARE @row_no INT = null
	SELECT @row_no = [row_number] FROM @results WHERE part_no = @selected_part_no

	IF @row_no IS NULL
		SELECT @page_index = 0
	else
		SELECT @page_index = ((@row_no -1) / @page_size)
end

DELETE FROM @results
WHERE [row_number] <= @page_index * @page_size
	OR [row_number] > (@page_index + 1) * @page_size

select
	r.*,
	case
	when (@builder_overrides_enabled = 1 AND r.image_id IS NOT NULL)
		then (NULL)
		else (c.image_data)
	end as image_data
from
	@results r
	left join veo_colors c with (nolock) on c.part_no = r.part_no
order by
	r.part_name_official
