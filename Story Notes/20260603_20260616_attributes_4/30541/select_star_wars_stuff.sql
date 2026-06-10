select 
    cs.session_id,
    cs.row_id,
    cs.application,
    cs.product,
    cs.item_no,
    cs.item,
    cs.notes,
    cs.price,
    cs.qty,
    cs.selected,
    (
        select
            csa.[attribute_id],
            csa.[name],
            (
                select 
                    csav.[value_id],
                    csav.[value],
                    csav.[external_id],
                    csav.[gpc_id],
                    csav.[selected]
                from [VeoSolutions_DEV].[dbo].[catalog_selection_attribute_values] csav
                where csav.session_id = csa.session_id
                    and csav.row_id = csa.row_id
                    and csav.attribute_id = csa.attribute_id
                for json path
            ) [values]
        from [VeoSolutions_DEV].[dbo].[catalog_selection_attributes] csa
        where csa.session_id = cs.session_id
        and csa.row_id = cs.row_id
        for json path
    ) as [attributes] 
from [VeoSolutions_Dev].[dbo].[catalog_selections] cs 
where cs.session_id = '87cadbc1-dfee-4a19-933f-1839f6a62431'
and cs.application = 'Flying Things'

/*
update cs
set cs.is_package = 1--,
    --cs.price = 25000000,
    --cs.qty = 5,
    --cs.notes = notes.text
from [VeoSolutions_Dev].[dbo].[catalog_selections] cs 
--cross apply (
--    select 'User wants to purchase more than just the basic LN model, we need to implement more of the catalog provided by the vendor.' as text
--    where cs.row_id = '1be82a6d-4c02-4e15-bf46-9f36ed49a439'
--    union
--    select 'User wants to purchase the A-wing and B-wing models, we need to implement more of the catalog provided by the vendor.' as text
--    where cs.row_id = '868fd9ae-59ac-4a31-bc7e-3b26167984e3'
--) notes
where cs.session_id = '87cadbc1-dfee-4a19-933f-1839f6a62431'
and row_id in ( '868fd9ae-59ac-4a31-bc7e-3b26167984e3','1be82a6d-4c02-4e15-bf46-9f36ed49a439')

update csav 
set csav.selected = 1
from [VeoSolutions_DEV].[dbo].[catalog_selection_attribute_values] csav
where csav.session_id = '87cadbc1-dfee-4a19-933f-1839f6a62431'
and csav.row_id in ( '868fd9ae-59ac-4a31-bc7e-3b26167984e3','1be82a6d-4c02-4e15-bf46-9f36ed49a439')
*/