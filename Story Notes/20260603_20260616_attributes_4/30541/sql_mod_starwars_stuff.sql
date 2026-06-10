--==============================================================================================
-- Clear the attribute value selections for Hull Color & Primary Weapons for the target session
--
-- Enter the session_id for a specific target session (or use one of the pre-created target sessions below).
--=================================================================================================================
--declare @session_id uniqueidentifier = '6d6ea981-0db7-41f7-8850-f5e338ef6784'; --DEV
--declare @session_id uniqueidentifier = '713209c3-2991-438a-9cfb-d587253c2514';  --QA
--declare @session_id uniqueidentifier = 'a9d7e809-9314-4abf-bb5e-72dd27f638b7';  --PREVIEW

declare @session_id uniqueidentifier = '87cadbc1-dfee-4a19-933f-1839f6a62431';

declare @hull_color_attribute_id uniqueidentifier = '019E6A1B-CCAA-710F-84EE-26B781638318';
declare @primary_weapons_attribute_id uniqueidentifier = '019E6A1D-A207-7D5E-96EA-4518075D9E81';
declare @s_foil_config_id uniqueidentifier = '019E6A1D-1892-73B8-B258-7ADA0C4CF9B5';
declare @astromech_droid_id uniqueidentifier = '019E6A1C-8B42-7A81-9A0D-81DB3CBA80E5';

--HULL COLOR
update catalog_selection_attribute_values
	set gpc_id = 'b1afd637-35de-4156-8a46-6bbeed91823a',
		selected = 0
	where session_id = @session_id
		and attribute_id = @hull_color_attribute_id
		and value_id = '019E6A22-7D24-7007-9F0C-5F980284B03A' --Alliance Orange

update catalog_selection_attribute_values
	set gpc_id = 'e08d86f8-f0bb-41b9-a085-ad86f5d75ad8',
		selected = 0
	where session_id = @session_id
		and attribute_id = @hull_color_attribute_id
		and value_id = '019E6A22-ACAF-7177-8BCD-DA5266D0725C' --Battle Gray

update catalog_selection_attribute_values
	set gpc_id = '25e65a8f-d2d2-4300-89f0-0c05419778e0',
		selected = 0
	where session_id = @session_id
		and attribute_id = @hull_color_attribute_id
		and value_id = '019E6A22-E269-71D4-AB51-A2BABC2153A9' --Stealth Matte Black

--PRIMARY WEAPONS
update catalog_selection_attribute_values
	set gpc_id = '7d482475-8045-4efc-86ee-e723352a346a',
		selected = 0
	where session_id = @session_id
		and attribute_id = @primary_weapons_attribute_id
		and value_id = '019E6A23-4E5C-7962-8E21-67AAB414CB3D' --x4 KX9 Laser Cannons

update catalog_selection_attribute_values
	set gpc_id = '11dcbc8a-7b61-4a22-94ab-6d08519f3310',
		selected = 0
	where session_id = @session_id
		and attribute_id = @primary_weapons_attribute_id
		and value_id = '019E6A23-B066-73E4-B790-D4719E621E5B' --+2x MG7 Proton Torepedoes

update catalog_selection_attribute_values
	set gpc_id = '5d101d9c-34b8-4bf3-b348-18ab944ac6c7',
		selected = 0
	where session_id = @session_id
		and attribute_id = @primary_weapons_attribute_id
		and value_id = '019E6A24-283D-722D-9583-06E6C0C30C61' --+Concussion Missile Pod

--S FOIL CONFIG
update catalog_selection_attribute_values
    set gpc_id = '7d882850-ad45-4918-9e39-979edd37e7e4',
        selected = 0
    where session_id = @session_id
        and attribute_id = @s_foil_config_id
        and value_id = '019E6A25-2127-766E-A432-666D6EFB66B2' --4 wing (t65)

update catalog_selection_attribute_values
    set gpc_id = '36f27b9f-1d0b-4391-b6a4-e6c31becadbf',
        selected = 0
    where session_id = @session_id
        and attribute_id = @s_foil_config_id
        and value_id = '019E6A24-C34E-78D7-AEFB-84580681E796' --two wing config (Z-95

-- ASTROMECH DROID
update catalog_selection_attribute_values
    set gpc_id = '96a923f6-8a08-4f09-8765-c8bcda6486a3',
        selected = 0
    where session_id = @session_id
        and attribute_id = @astromech_droid_id
        and value_id = '019E6A21-E5F6-79B4-8B22-39D741EC7896' --R5-D4

update catalog_selection_attribute_values
    set gpc_id = null,
        selected = 0
    where session_id = @session_id
        and attribute_id = @astromech_droid_id
        and value_id = '019E6A22-3CAC-7183-AA09-812B9C47A889' --none

update catalog_selection_attribute_values
    set gpc_id = '7f146b3d-f6fe-4295-885b-11bd597a665e',
        selected = 0
    where session_id = @session_id
        and attribute_id = @astromech_droid_id
        and value_id = '019E6A21-BB3F-7D94-9B47-9191C3814ED5' --R2-D2

update catalog_selection_attribute_values
    set gpc_id = '2ecc33ee-cd0e-405c-b5d5-965b51debaec',
        selected = 0
    where session_id = @session_id
        and attribute_id = @astromech_droid_id
        and value_id = '019E6A22-1702-79B4-9739-C35E36B4A6B1' --R4-P17
