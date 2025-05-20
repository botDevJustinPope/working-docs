/*
select 
    p.[product_id],
    p.[name] as [product],
    a.[application_id],
    a.[name] as [application]
from ERP.WBS.dbo.application_products ap
inner join ERP.WBS.dbo.products p on p.product_id = ap.product_id
inner join ERP.WBS.dbo.applications a on a.application_id = ap.application_id

*/


/*
    combined query to find estimated and non estimated items that are visualizable
*/
select 
    colors_combined.[Stack],
    colors_combined.[application],
    colors_combined.[product],
    colors_combined.[color],
    colors_combined.[part no.],
    da.gpcIds as [global product id],
    case when da.gpcIds is not null then 'Yes' else 'No' end as [Is Visualizable?]
from (
    select 
        'WBS - estimated items' as [Stack],
        ap.application_id,
        a.[name] as [application],
        ap.product_id,
        p.[name] as [product],
        c.[name] as [color],
        c.[part_no] as [part no.],
        cast(c.[global_product_id] as varchar(36)) as [global product id]
    from ERP.WBS.dbo.colors c
    inner join ERP.WBS.dbo.products p on p.product_id = c.product_id
    inner join ERP.WBS.dbo.application_products ap on ap.product_id = p.product_id
    inner join ERP.WBS.dbo.applications a on a.application_id = ap.application_id
    union
    select 
        'Echelon-EPP - estimated items' as [Stack],
        ap.application_id,
        a.[name] as [application],
        ap.product_id,
        p.[name] as [product],
        c.[name] as [color],
        c.[part_no] as [part no.],
        cast(c.[global_product_id] as varchar(36)) as [global product id]
    from ERP.[Echelon-Epp].dbo.colors c
    inner join ERP.[Echelon-Epp].dbo.products p on p.product_id = c.product_id
    inner join ERP.[Echelon-Epp].dbo.application_products ap on ap.product_id = p.product_id
    inner join ERP.[Echelon-Epp].dbo.applications a on a.application_id = ap.application_id 
    union
    select distinct
        'WBS - catalog item' as [Type],
        '' as [application_id],
        [application] as [application],
        '' as [product_id],
        product as [product],
        item_no as [item_no],
        item as [item],
        gpc
    from VDS_PROD.VeoSolutions.dbo.catalog_items
    UNION
    select distinct 
        'EPLAN - catalog item',
        '' as [application_id],
        [application] as [application],
        '' as [product_id],
        product as [product],
        item_no,
        item ,
        gpc
    from VDS_PROD.EPLAN_VeoSolutions.dbo.catalog_items
    UNION
    select distinct 
        'CCDI - catalog item',
        '' as [application_id],
        [application] as [application],
        '' as [product_id],
        product as [product],
        item_no,
        item,
        gpc
    from VDS_PROD.CCDI_VeoSolutions.dbo.catalog_items
    union 
    select distinct 
        'AFI - catalog item',
        '' as [application_id],
        [application] as [application],
        '' as [product_id],
        product as [product],
        item_no,
        item,
        gpc
    from VDS_PROD.AFI_VeoSolutions.dbo.catalog_items
    ) as colors_combined
INNER join master.dbo.aareas_digital_assets da on da.gpcIds = colors_combined.[global product id]
where -- colors_combined.[application_id] = '1' and colors_combined.[product_id] = '6'
colors_combined.color like '%dishwasher%'
--and colors_combined.[global product id] in ('92ea1dc1-84cb-4654-984d-78dd77b77de9', '')
--and colors_combined.[color] like '%fin%granite%uba%tuba%'
--and c.color_id = '01900'
/* for cabinets */
/*AND C.style_id in (
select style_id from ERP.WBS.dbo.styles
where [product_id] = 'Y'
    and [description] like '%fairfield%'
    and class = 'field' )*/
--and colors_combined.[part no.] like 'OG0UBTF3/1/1'

/*
query to find the style_id for a cabinet

select * from ERP.[Echelon-Epp].dbo.styles
where [product_id] = 'Y'
    and [description] like '%madison%'
    and class = 'field'

query to find the color_id for a cabinet
select * from ERP.[Echelon-Epp].dbo.cabinet_colors
where [color_name] like '%rye%'
*/

/*
query to find catalog items that are visualizable
*/
select 
    ci.*,
    case when da.gpcIds is not null then 'Yes' else 'No' end as [Is Visualizable?]
from (
    select distinct
        'WBS - catalog item' as [Type],
        '' as [application_id],
        [application] as [application],
        '' as [product_id],
        product as [product],
        item_no as [item_no],
        item as [item],
        gpc
    from VDS_PROD.VeoSolutions.dbo.catalog_items
    UNION
    select distinct 
        'EPLAN - catalog item',
        '' as [application_id],
        [application] as [application],
        '' as [product_id],
        product as [product],
        item_no,
        item ,
        gpc
    from VDS_PROD.EPLAN_VeoSolutions.dbo.catalog_items
    UNION
    select distinct 
        'CCDI - catalog item',
        '' as [application_id],
        [application] as [application],
        '' as [product_id],
        product as [product],
        item_no,
        item,
        gpc
    from VDS_PROD.CCDI_VeoSolutions.dbo.catalog_items
    union 
    select distinct 
        'AFI - catalog item',
        '' as [application_id],
        [application] as [application],
        '' as [product_id],
        product as [product],
        item_no,
        item,
        gpc
    from VDS_PROD.AFI_VeoSolutions.dbo.catalog_items
) ci 
inner join master.dbo.aareas_digital_assets da on cast(da.gpcIds as varchar(36)) = ci.gpc 
where /*
and product = 'Appliances' and application = 'A La Cartes'
item like '%GE%Free%standing%' and item not like '%Microwave%'*/ 
ci.product like '%dishwasher%'