
drop table if exists #part_updates;

begin TRANSACTION

select 
    *
into #part_updates
from 
( values
    ('e18f29b6-c4f3-4899-adeb-cc71225cd50e','YDAMS/TRF'),
    ('e53597de-bec5-4a52-b446-b3b7233785e3','YDAMS/MID'),
    ('7fdfdff4-c67d-4bf4-a234-1d7db5669396','YDAMS/BRY'),
    ('d3708f7a-c8aa-4020-b0c5-f7423e005caf','OG001R3/6'),
    ('beba38d2-351e-413e-b664-98f49f753187','OG0BGR3/1'),
    ('40e0ec0d-f220-4744-85b7-90476eb8e677','OG0WYF3/1'),
    ('d321f141-4a5e-468c-9ddb-8dbe835f9a28','OPF1.6CM/13'),
    ('8585724b-9936-43ac-89d6-7f673ecc5d50','12454/25210'),
    ('eed3e512-c4e6-49a7-a72b-96f79010647d','1BP93B/720'),
    ('3241ada9-fc65-44d4-b112-561476a0c8af','19736/825'),
    ('a7725d67-20e7-41e7-8f56-14d9f34f2e2a','19736/858'),
    ('60076cb4-3cfc-41df-9f54-7aef8a433753','6RR20/RR98'),
    ('bf76e7d6-4d69-4181-b748-5de94dee42ec','6DV20/DV99'),
    ('d5b2cf01-6833-4b1e-a1cb-8ef6f24aa3f1','6AL/AL05'),
    ('b1441c06-7c18-4053-a2dd-2b0c4bec7388','6BRI18/CO'),
    ('7b188a18-cfc5-44be-88f8-ec3c8bd982ca','6AD24/BB'),
    ('e074818d-3349-4a6e-9591-d599a8c99570','6BRI18/AS'),
    ('58d32eb4-955d-40d5-acdc-d48aefc16883','6MDM/GS'),
    ('09484c63-4fe5-4035-a82f-13ddf4c334ae','6MDM/NB'),
    ('866d14ff-fcf0-4cde-80fa-3788884b0d9a','6CHL/CHL1B'),
    ('342f363e-17ae-419b-a69b-c8a2fca93cc9','6CW3/CW14'),
    ('b22c8836-d66c-4b30-a551-93a407f05fc9','6BVM/218'),
    ('e93d2e59-f9bd-4375-85f5-6c2a38307a3f','6CW3/CW12'),
    ('770ff5b0-008a-47ad-a325-9e4094c84a77','6MHB/251'),
    ('86700884-5a2d-4dab-ab2e-e847f2e7c84f','6MHB/584'),
    ('8efc77f8-60ca-4ff2-b46d-ae567978d2db','6MHB/252'),
    ('b1a9d749-c63a-4f9e-8b9c-5914da9b6e7f','3SENMAP7/PAS'),
    ('eae657dc-8c45-4acc-9f56-c24cfe2eb4c8','3VE230/00157'),
    ('ed734719-3128-4908-9d14-466fc4b2ec35','3CTM456/Syr'),
    ('b87ca763-af40-4609-a9d5-4d70e108766a','3AA759/00510'),
    ('e042035d-45b7-4050-8bff-cf106e5fcd60','3AA759/97E22'),
    ('fbcc0984-0874-4f5d-801d-3eeb7c361673','3ATHC5A/0781') ) as t (gpc_id, part_no);

update c 
    set global_product_id = rp.gpc_id 
from [WBS_staging].dbo.colors as c
inner join #part_updates as rp on c.part_no = rp.part_no;

update c 
    set global_product_id = rp.gpc_id 
from [VEO_DEV].dbo.colors as c
inner join #part_updates as rp on c.part_no = rp.part_no;

--rollback TRANSACTION;
commit transaction;

drop table if exists #part_updates;