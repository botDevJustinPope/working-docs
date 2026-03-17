SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[vds_selGroupLevelParts_Yukon]
	@application_id VARCHAR(10),
	@product_id VARCHAR(10),
	@item_type VARCHAR(20),
	@item_id VARCHAR(50),
	@spec_id INT,
	@external_organization_id VARCHAR(15),
	@builder_overrides_enabled BIT = 0
AS
/*
	Procedure:	vds_selGroupLevelParts_yukon
	Author:		Richard Gladstone
	Date:		11/11/2016
	Purpose:	Retrieves the list of parts for which to show images in VDS Option Pricing
	Usage:

	vds_selGroupLevelParts_Yukon '12', 'B', 'style', 'Capri02', 2990, 'TMAU2008'
	vds_selGroupLevelParts_Yukon '12', 'B', 'color', 'BCapri02/PRL', 3569, 'RYL1000'

	History: RIG 20161111 when a single color is passed in, nothing was returned; added marked section

	Modified:		Roger Wang
	Date:			5/13/2021
	Description:	Returns only stocking codes that are homebuyer selectable

	Modified:		Roger Wang
	Date:			9/29/2021
	Description:	Tunes the query to perform better
*/

SET NOCOUNT ON

DECLARE @styles TABLE
(
	product_id VARCHAR(10),
	style_id VARCHAR(100),
	found_in_spec BIT
)

DECLARE @colors TABLE
(
	part_no VARCHAR(81),
	product_id VARCHAR(10),
	style_id VARCHAR(100),
	color_id VARCHAR(100),
	found_in_spec BIT,
	spec_id INT,
	found_pass VARCHAR(20),
	group_id INT,
	stocking_code VARCHAR(10)
)

IF @item_type = 'group'
BEGIN
	INSERT INTO @styles (product_id, style_id, found_in_spec)
	SELECT DISTINCT product_id, item , 1
	FROM
		styles_groups_detail sgd WITH (NOLOCK)
		LEFT JOIN styles_groups sg WITH (NOLOCK) ON sg.group_id = sgd.group_id
	WHERE
		item_type = 'style'
		AND sgd.customer_id = @external_organization_id
		AND sgd.group_id = CAST(@item_id AS INT)
		AND effective_date <= GETDATE()
		AND (end_date >= GETDATE() OR end_date IS NULL)

	INSERT INTO @colors (part_no, product_id, style_id, color_id, stocking_code, found_in_spec)
	SELECT DISTINCT c.part_no, c.product_id, c.style_id, c.color_id, c.stocking_code, 1
	FROM
		styles_groups_detail sgd WITH (NOLOCK)
		INNER JOIN styles_groups sg WITH (NOLOCK) ON sg.group_id = sgd.group_id
		INNER JOIN colors c WITH (NOLOCK) ON c.part_no = sgd.item
		INNER JOIN stocking_codes sc WITH (NOLOCK) ON sc.code = c.stocking_code
	WHERE
		item_type = 'color'
		AND sgd.customer_id = @external_organization_id
		AND sgd.group_id = CAST(@item_id AS INT)
		AND effective_date <= GETDATE()
		AND (end_date >= GETDATE() OR end_date IS NULL)
		AND sc.homebuyer_selectable = 1
END

IF @item_type = 'style'
BEGIN
	INSERT INTO @styles (product_id, style_id, found_in_spec)
	SELECT DISTINCT product_id, style_id, 1
	FROM
		styles
	WHERE
		style_id = @item_id
END

-- RIG 20161111 added check for item_type 'color'
if @item_type = 'color'
begin
	INSERT INTO @colors (part_no, product_id, style_id, color_id, stocking_code, found_in_spec, spec_id)
	SELECT c.part_no, c.product_id, c.style_id, c.color_id, c.stocking_code, 1, 0
	FROM
		colors c WITH (NOLOCK)
		INNER JOIN stocking_codes sc WITH (NOLOCK) ON sc.code = c.stocking_code
	where
		c.part_no = @item_id
		AND sc.homebuyer_selectable = 1
end
else
begin
	INSERT INTO @colors (part_no, product_id, style_id, color_id, stocking_code, found_in_spec, spec_id)
	SELECT c.part_no, c.product_id, c.style_id, c.color_id, c.stocking_code, isnull(s.found_in_spec, 0), 0
	FROM
		@styles s
		JOIN colors c WITH (NOLOCK) ON c.product_id = s.product_id AND c.style_id = s.style_id
		INNER JOIN stocking_codes sc WITH (NOLOCK) ON sc.code = c.stocking_code
	where
		sc.homebuyer_selectable = 1
end
/*
 filter the color list for the builder involved in the query
*/
-- all spec_items COLORS are included
UPDATE
	@colors
SET
	found_in_spec = 1 , spec_id = sm.spec_id, found_pass = 'colors'
from
	spec_mstr sm WITH (NOLOCK)
	join spec_items si WITH (NOLOCK) ON si.spec_id = sm.spec_id
	join @colors c on c.part_no = si.item
where
	sm.builder_id = @external_organization_id
	and si.product_id = @product_id
	and sm.active = 1 and sm.end_date >= GETDATE()
	and si.item_type = 'color'

-- all spec_items STYLES are included
UPDATE
	@colors
SET
	found_in_spec = 1 , spec_id = sm.spec_id, found_pass = 'styles'
from
	spec_mstr sm WITH (NOLOCK)
	join spec_items si WITH (NOLOCK) ON si.spec_id = sm.spec_id
	join styles s WITH (NOLOCK) ON s.product_id + s.style_id = si.item
	join colors c WITH (NOLOCK) ON c.product_id = s.product_id and c.style_id = s.style_id
	join @colors c2 on c2.part_no = c.part_no
where
	sm.builder_id = @external_organization_id
	and si.product_id = @product_id
	and sm.active = 1 and sm.end_date >= GETDATE()
	and si.item_type = 'style'

declare @spec_items table
(
	item varchar(81)
)

insert into
	@spec_items
SELECT DISTINCT
	si.item
FROM
	spec_mstr sm
	join spec_items si on si.spec_id = sm.spec_id
WHERE
	sm.active = 1
	and sm.builder_id = @external_organization_id and sm.end_date >= GETDATE()
	and product_id = @product_id
	and application_id not in ('3', '11') -- no wall or fireplace tile at this time
	and si.item_type = 'group'
	and si.product_id = @product_id

declare @active_items table
(
	group_id int,
	application_id varchar(10),
	product_id varchar(10),
	item_type varchar(10),
	item varchar(81)
)

insert into
	@active_items
select
	sgd.group_id, sg.application_id, sg.product_id, sgd.item_type, sgd.item
from
	@spec_items si
	inner join styles_groups sg on sg.group_id = si.item
	inner join styles_groups_detail sgd on sgd.group_id = sg.group_id
where
	sgd.customer_id = @external_organization_id
	and cast(sgd.effective_date as date) <= cast(GETDATE()  as date)
	and ( cast(sgd.end_date as date) > cast(GETDATE() as date) or sgd.end_date is null)
group by
	sgd.group_id, sg.application_id, sg.product_id, sgd.item_type, sgd.item
having
	COUNT(1) = 1

UPDATE
	@colors SET found_in_spec = 1 , spec_id = @spec_id, found_pass = 'groups', group_id = a.group_id
from
	@colors c
	join @active_items a on a.item = c.part_no
where a.item_type = 'color'

UPDATE
	@colors SET found_in_spec = 1 , spec_id = @spec_id, found_pass = 'groups', group_id = a.group_id
from
	@colors c
	join @active_items a on a.item = c.style_id and a.product_id = c.product_id
where a.item_type = 'style'

--
-- SELECT overrides into a TABLE variable
--
DECLARE @overrides TABLE
(
	part_no VARCHAR(81),
	customer_reference_no VARCHAR(100),
	color_private_label VARCHAR(150)
)

IF @builder_overrides_enabled = 1
BEGIN
	INSERT INTO @overrides
	SELECT
		c.part_no, cco.customer_reference_no, cco.color_private_label
	FROM
		@colors c
	INNER JOIN
		colors_customer_overrides cco ON cco.part_no = c.part_no AND cco.customer_id = @external_organization_id
END

--
-- SELECT dataset into a TABLE variable (will have to add price level later)
--
DECLARE @results TABLE
(
	part_no VARCHAR(81),
	product_id VARCHAR(10),
	style_id VARCHAR(100),
	color_id VARCHAR(100),
	stocking_code VARCHAR(10),
	attribute_id VARCHAR(100),
	value_description VARCHAR(max),
	attribute_description VARCHAR(max),
	image_data varbinary(max)
)

INSERT INTO @results (part_no, product_id, style_id, color_id, stocking_code, attribute_id, value_description, attribute_description, image_data)
SELECT
	c2.part_no, c2.product_id, c2.style_id, c2.color_id, c2.stocking_code, 'photo_repository_count' as attribute_id, '' as value_description,
	(SELECT CAST(count(photo_id) as VARCHAR(10)) from photo_attributes_values where attribute_id = 7 and value = c2.part_no) as [attribute_description],
	null as image_data
from
	@colors c
	join colors c2 WITH (NOLOCK) ON c2.part_no = c.part_no
where
	c.found_in_spec = 1

union

SELECT
	c.part_no, c.product_id, c.style_id, c.color_id , c.stocking_code, 'style_name' as attribute_id, s.[description] as value_id, 'style_name' as [description], null as image_data
from
	@colors c
	join styles s on s.product_id = c.product_id and s.style_id = c.style_id
where
	c.found_in_spec = 1

union

SELECT
	c.part_no, c.product_id, c.style_id, c.color_id, c.stocking_code, 'color_name' as attribute_id, dbo.ef_selStyleColorNameWithAttributes(c.product_id, c.style_id, c.color_id) as value_id, 'color_name' as [description], null as image_data
from
	@colors c
where
	c.found_in_spec = 1

union

-- color attributes
SELECT
	c.part_no, c.product_id, c.style_id, c.color_id, c.stocking_code, ca.attribute_id, isnull(pav.description, ca.value_id) as value_id, isnull(pa.description, ''), null
from
	@colors c
	join colors_attributes ca WITH (NOLOCK) ON ca.product_id = c.product_id and ca.style_id = c.style_id and ca.color_id = c.color_id
	join products_attributes pa WITH (NOLOCK) ON pa.product_id = c.product_id and pa.attribute_id = ca.attribute_id and pa.type = 'color'
	LEFT JOIN products_attributes_values pav WITH (NOLOCK) ON pav.product_id = ca.product_id and pav.attribute_id = ca.attribute_id and pav.value_id = ca.value_id
where
	c.found_in_spec = 1
	and pa.homebuyer_searchable = 1

union

-- style attributes
SELECT
	c.part_no, c.product_id, c.style_id, c.color_id, c.stocking_code, sa.attribute_id, isnull(pav.description, sa.value_id) as value_id, isnull(pa2.description, ''), null
from
	@colors c
	join styles_attributes sa WITH (NOLOCK) ON sa.product_id = c.product_id and sa.style_id = c.style_id
	join products_attributes pa2 WITH (NOLOCK) ON pa2.product_id = sa.product_id and pa2.attribute_id = sa.attribute_id and pa2.type = 'style'
	LEFT JOIN products_attributes_values pav WITH (NOLOCK) ON pav.product_id = sa.product_id and pav.attribute_id = sa.attribute_id and pav.value_id = sa.value_id
where
	c.found_in_spec = 1
	and pa2.homebuyer_searchable = 1


-- added check for style_out color & style attachments
union

SELECT
	c.part_no, c.product_id, c.style_id, c.color_id, c.stocking_code, 'style_out',
	str((SELECT count(*) from colors_attachments atch where atch.style_id = c.style_id and c.color_id = atch.color_id and atch.product_id = c.product_id )) ,
	'color_attachment',  null
from
	@colors c
	join styles_attributes sa WITH (NOLOCK) ON sa.product_id = c.product_id and sa.style_id = c.style_id
where
	c.found_in_spec = 1

union

SELECT
	c.part_no, c.product_id, c.style_id, c.color_id, c.stocking_code, 'style_out',
	str((SELECT count(*) from styles_attachments atch where atch.style_id = c.style_id and atch.product_id = c.product_id)),
	'style_attachment',  null
from
	@colors c
	join styles_attributes sa WITH (NOLOCK) ON sa.product_id = c.product_id and sa.style_id = c.style_id
where
	c.found_in_spec = 1

-- colors customer overrides
union

SELECT
	c.part_no, c.product_id, c.style_id, c.color_id , c.stocking_code, 'customer_reference_no' as attribute_id, o.customer_reference_no as value_id, 'customer_reference_no' as [description], null as image_data
from
	@colors c
	join @overrides o on o.part_no = c.part_no
where
	c.found_in_spec = 1
	and o.customer_reference_no is not null

union

SELECT
	c.part_no, c.product_id, c.style_id, c.color_id , c.stocking_code, 'color_private_label' as attribute_id, o.color_private_label as value_id, 'color_private_label' as [description], null as image_data
from
	@colors c
	join @overrides o on o.part_no = c.part_no
where
	c.found_in_spec = 1
	and o.color_private_label is not null


DECLARE @c_spec_id INT
DECLARE @c_part_no VARCHAR(81)
DECLARE @c_product_id VARCHAR(10)
DECLARE @c_style_id VARCHAR(50)
DECLARE @c_color_id VARCHAR(50)

-- join with styles in styles_groups_detail
DECLARE colors_cursor CURSOR for
SELECT DISTINCT spec_id, part_no, product_id, style_id, color_id from @colors where found_in_spec = 1

open colors_cursor
fetch next from colors_cursor into @c_spec_id, @c_part_no, @c_product_id, @c_style_id, @c_color_id
while @@FETCH_STATUS = 0
begin

	INSERT INTO @results (part_no, product_id, style_id, color_id, stocking_code, attribute_id, value_description, attribute_description, image_data)
	SELECT top 1
		@c_part_no,
		@c_product_id,
		@c_style_id,
		@c_color_id,
		c.stocking_code,
		sg.group_id,
		(
			SELECT top 1
				isnull(bs.builder_style_name, sg.group_name)
			from
				builder_styles bs WITH (NOLOCK)
			where
				bs.spec_id = @c_spec_id
				and bs.application_id = sg.application_id
				and bs.product_id = sg.product_id
				and bs.item_type = 'group'
				and bs.item = sg.group_id
			ORDER BY
				bs.effective_date desc
		),
		'Price Level',
		null
	from
		styles_groups_detail sgd WITH (NOLOCK)
		inner join styles_groups sg WITH (NOLOCK) ON sg.group_id = sgd.group_id
		inner join colors c WITH (NOLOCK) ON c.part_no = @c_part_no
		INNER JOIN stocking_codes sc WITH (NOLOCK) ON sc.code = c.stocking_code
	where
		sgd.customer_id = @external_organization_id
		and sgd.item_type = 'style'
		and sg.product_id = @c_product_id
		and sgd.item = @c_style_id
		and sgd.effective_date <= GETDATE()
		and (sgd.end_date >= GETDATE() or sgd.end_date IS NULL)
		AND sc.homebuyer_selectable = 1
	ORDER BY
		sgd.effective_date

	fetch next from colors_cursor into @c_spec_id, @c_part_no, @c_product_id, @c_style_id, @c_color_id
end

close colors_cursor
deallocate colors_cursor

-- join with colors in styles_groups_detail
DECLARE colors_cursor CURSOR for
SELECT DISTINCT spec_id, part_no, product_id, style_id, color_id from @colors where found_in_spec = 1
open colors_cursor
fetch next from colors_cursor into @c_spec_id, @c_part_no, @c_product_id, @c_style_id, @c_color_id
while @@FETCH_STATUS = 0
begin

	INSERT INTO @results (part_no, product_id, style_id, color_id, stocking_code, attribute_id, value_description, attribute_description, image_data)
	SELECT top 1
		@c_part_no,
		@c_product_id,
		@c_style_id,
		@c_color_id,
		c.stocking_code,
		sg.group_id,
		(
			SELECT top 1
				isnull(bs.builder_style_name, sg.group_name)
			from
				builder_styles bs WITH (NOLOCK)
			where
				bs.spec_id = @c_spec_id
				and bs.application_id = sg.application_id
				and bs.product_id = sg.product_id
				and bs.item_type = 'group'
				and bs.item = sg.group_id
			ORDER BY
				bs.effective_date desc
		),
		'Price Level',
		null
	from
		styles_groups_detail sgd WITH (NOLOCK)
		INNER join styles_groups sg WITH (NOLOCK) ON sg.group_id = sgd.group_id
		INNER join colors c WITH (NOLOCK) ON c.part_no = @c_part_no
		INNER JOIN stocking_codes sc WITH (NOLOCK) ON sc.code = c.stocking_code
	where
		sgd.customer_id = @external_organization_id
		and sgd.item_type = 'color'
		and sgd.item = @c_product_id + @c_style_id + '/' + @c_color_id
		and sgd.effective_date <= GETDATE()
		and (sgd.end_date >= GETDATE() or sgd.end_date IS NULL)
		AND sc.homebuyer_selectable = 1
	ORDER BY
		sgd.effective_date

	fetch next from colors_cursor into @c_spec_id, @c_part_no, @c_product_id, @c_style_id, @c_color_id
end

close colors_cursor
deallocate colors_cursor

SELECT
	r.*
FROM
	@results r
	INNER JOIN stocking_codes sc on sc.code = r.stocking_code
WHERE
	r.product_id IS NOT NULL
	AND sc.homebuyer_selectable = 1
ORDER BY
	r.product_id, r.style_id, r.color_id, r.attribute_id

SET NOCOUNT OFF
GO
