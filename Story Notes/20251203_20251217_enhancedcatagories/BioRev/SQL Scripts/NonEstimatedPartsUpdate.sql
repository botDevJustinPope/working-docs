

with desired_parts as (
select * from (values 
('REFR0927108',     'f07b076f-00a4-41ef-97ab-3686f696687b'),
('REFR0927089',     'cd79e53c-996a-4778-ba23-19737f641f8f'),
('OVEN0200',        '2a9474ec-72b3-4c29-b573-f5626be288f9'),
('OVEN09270005',    '2a9474ec-72b3-4c29-b573-f5626be288f9'))as vals(item_no, desired_gpc_id) ) 

update ci 
    set gpc = dp.desired_gpc_id
from [VeoSolutions_DEV].dbo.catalog_items ci
inner join desired_parts dp on ci.item_no = dp.item_no
where ci.organization_id = '8aaecc3a-2d9e-4500-b0cf-d79d947d33a7'
and ci.community = 'Lakes of Pine Forest'
and ci.[plan] = 'Aransas'