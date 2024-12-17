select 
    'VeoSolutions' as [stack],
    o.organization_id,
    o.name,
    o.external_organization_id,
    c.custnmbr
from [VEOSolutionsSecurity].[dbo].[organizations] o 
    left join [VeoSolutions].[dbo].[Veo_customers] c on o.external_organization_id = c.custnmbr
where (c.image_data is null or c.custnmbr is null)                        
union 
select 
    'AFI' as [stack],
    o.organization_id,
    o.name,
    o.external_organization_id,
    c.custnmbr
from [AFI_VEOSolutionsSecurity].[dbo].[organizations] o 
    left join [AFI_Veo].[dbo].[customers] c on o.external_organization_id = c.custnmbr
where (c.image_data is null or c.custnmbr is null) 
UNION
select 
    'CCDI' as [stack],
    o.organization_id,
    o.name,
    o.external_organization_id,
    c.custnmbr
from [CCDI_VEOSolutionsSecurity].[dbo].[organizations] o 
    left join [CCDI_VeoSolutions].[dbo].[Veo_customers] c on o.external_organization_id = c.custnmbr
where (c.image_data is null or c.custnmbr is null)       
UNION
select 
    'EPLAN' as [stack],
    o.organization_id,
    o.name,
    o.external_organization_id,
    c.custnmbr
from [EPLAN_VEOSolutionsSecurity].[dbo].[organizations] o 
    left join [EPLAN_VeoSolutions].[dbo].[Veo_customers] c on o.external_organization_id = c.custnmbr
where (c.image_data is null or c.custnmbr is null)       