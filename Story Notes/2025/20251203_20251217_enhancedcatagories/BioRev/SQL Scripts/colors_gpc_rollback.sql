
drop table if exists #revert_parts;

begin TRANSACTION

select * 
into #revert_parts
from (
values
('YDAMS/TRF',       'dfb0b7f7-5328-4c29-aa30-17dd0a208480'),
('YDAMS/MID',       '4b437007-7c84-47cc-b4a7-9901785964ff'),
('YDAMS/BRY',       '224584de-8abf-47f3-bddd-eafaa3cdee6f'),
('OG001R3/6',       '7b73cf99-6105-4fb7-ab38-173c337ec52e'),
('OG0BGR3/1',       'f56ea5ef-196e-4934-b0a1-a3d0d60cdd16'),
('OG0WYF3/1',       '045505c5-60bc-4905-b824-f88eb6f36b10'),
('OPF1.6CM/13',     '42241a97-d636-411e-bdf1-29921b7e652e'),
('12454/25210',     '9f152889-ee65-41dc-8c01-a5daee0fda45'),
('1BP93B/720',      '857243e0-e029-4ed6-bf76-62bfd6da82ec'),
('19736/825',       '957b516b-c900-4f16-addb-bb541eca89a7'),
('19736/858',       'eedb3cdc-cc5f-402b-80e1-af1de3366cb2'),
('6RR20/RR98',      '25bb6b50-38ed-475f-932a-2eee8e9eb60a'),
('6DV20/DV99',      '472f83d6-1d0c-493b-ac87-c1eda2676067'),
('6AL/AL05',        '460b0898-bbd7-4f7c-877f-b1fb3ad87bfb'),
('6BRI18/CO',       'a9c8ef2c-98ed-45c8-b759-5121c425b9d6'),
('6AD24/BB',        '959a07ab-d7dd-42e9-8a5d-0365423bd5ef'),
('6BRI18/AS',       'e044d8b7-adea-4ec8-ae8a-9e6c3f745347'),
('6MDM/GS',         '8b74b1bc-f802-4d2a-96a5-44b22beee4db'),
('6MDM/NB',         '466241f8-4ebf-4b94-8f14-2e5859c808ce'),
('6CHL/CHL1B',      'a9df8509-ee2e-43d9-9f8e-3af11666fda7'),
('6CW3/CW14',       '36f8492b-b2db-47ce-bafa-040d3d13e951'),
('6BVM/218',        '2ea546c6-88d0-498b-9b31-70fbbbcaae23'),
('6CW3/CW12',       '77d1a632-2c41-4dd1-a777-e00b378be9ec'),
('6MHB/251',        'ef22f888-52a4-4198-95b2-b4fb30a8ed0a'),
('6MHB/584',        'dfe87ab8-74bf-4076-b046-97e8b779a6ac'),
('6MHB/252',        '3ece1db0-e714-4f4e-b9b6-ce70eff420de'),
('3SENMAP7/PAS',    '84c98e05-94bc-44bf-9e8b-f41e05da91ff'),
('3VE230/00157',    '305f6a14-04a9-4068-94b5-16e00465cada'),
('3CTM456/Syr',     'ba4c00fc-cb57-49d0-9463-d26010cea9c7'),
('3AA759/00510',    '920cf461-7e4f-4f01-8dce-5d60a4c8bbff'),
('3AA759/97E22',    'a7088e25-5078-4f5e-826d-ff367c20c143'),
('3ATHC5A/0781',    '63e4ac96-1f28-418f-8724-8c5150f19549')) as t (part_no, gpc_id) 

update c 
    set global_product_id = rp.gpc_id 
from [WBS_staging].dbo.colors as c
inner join #revert_parts as rp on c.part_no = rp.part_no;

update c 
    set global_product_id = rp.gpc_id 
from [VEO_DEV].dbo.colors as c
inner join #revert_parts as rp on c.part_no = rp.part_no;

rollback TRANSACTION;
--commit transaction;

drop table if exists #revert_parts;