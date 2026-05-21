/* ============================================================================
   #30534 - Seed catalog_selection_attributes data: X-Wing + TIE Fighter
   ============================================================================


    Target Database:
    use VeoSolutions_DEV;
    use VeoSolutions_QA;
    use VeoSolutions_Preview;
    use VeoSolutions_Staging;

   Tables touched:
       dbo.catalog_selections                 (2 rows)
       dbo.catalog_selection_attributes       (8 rows)
       dbo.catalog_selection_attribute_values (22 rows)

   Usage:
       1. Paste a valid session_id and the matching organization_id into the
          two variables below. Both must already exist in DEV
          (the ot_ins_catalog_selections trigger inserts into
          catalog_selections_area_details_change_log, which FKs to
          account_organization_user_profile_plan_catalog_sessions).
       2. Run the entire script in SSMS.
       3. Idempotent: re-running deletes the X-Wing and TIE rows from
          catalog_selections first; ON DELETE CASCADE cleans the two child
          tables automatically before the inserts re-run.
   ============================================================================ */

DECLARE @session_id      UNIQUEIDENTIFIER = 'b03980a1-56a3-4121-ad88-adbc727f8a74'; -- <-- REPLACE with a valid session_id from DEV
DECLARE @organization_id UNIQUEIDENTIFIER; -- This will be looked up from the session table, but you can paste it here too if you want to be sure it's correct before running.
DECLARE @account_id      UNIQUEIDENTIFIER; -- This will be looked up from the session table, but you can paste it here too if you want to be sure it's correct before running.

-- Stable row_ids so re-runs are cleanly idempotent.
DECLARE @xwing_row_id    UNIQUEIDENTIFIER = '00000001-0000-0000-0000-000000000001';
DECLARE @tie_row_id      UNIQUEIDENTIFIER = '00000002-0000-0000-0000-000000000002';

-- X-Wing attribute IDs
DECLARE @xw_attr_hull      UNIQUEIDENTIFIER = 'A0000001-0000-0000-0000-AAAAAAAAAAA1';
DECLARE @xw_attr_sfoil     UNIQUEIDENTIFIER = 'A0000001-0000-0000-0000-AAAAAAAAAAA2';
DECLARE @xw_attr_astromech UNIQUEIDENTIFIER = 'A0000001-0000-0000-0000-AAAAAAAAAAA3';
DECLARE @xw_attr_weapons   UNIQUEIDENTIFIER = 'A0000001-0000-0000-0000-AAAAAAAAAAA4';

-- TIE Fighter attribute IDs
DECLARE @tie_attr_panels   UNIQUEIDENTIFIER = 'B0000002-0000-0000-0000-BBBBBBBBBBB1';
DECLARE @tie_attr_hull     UNIQUEIDENTIFIER = 'B0000002-0000-0000-0000-BBBBBBBBBBB2';
DECLARE @tie_attr_cockpit  UNIQUEIDENTIFIER = 'B0000002-0000-0000-0000-BBBBBBBBBBB3';
DECLARE @tie_attr_engines  UNIQUEIDENTIFIER = 'B0000002-0000-0000-0000-BBBBBBBBBBB4';

----------------------------------------------------------------------
-- 1. Resolve organization_id and account_id from the session.
----------------------------------------------------------------------
select
    @organization_id = organization_id,
    @account_id = account_id
from dbo.account_organization_user_profile_plan_catalog_sessions
where session_id = @session_id;

if @organization_id is null or @account_id is null
begin
    declare @session_id_str varchar(36) = convert(varchar(36), @session_id);
    raiserror('Session ID %s not found in account_organization_user_profile_plan_catalog_sessions', 16, 1, @session_id_str);
    return;
end

----------------------------------------------------------------------
-- 2. Clean prior seed data. CASCADE handles attributes / values.
----------------------------------------------------------------------
DELETE FROM dbo.catalog_selections
WHERE session_id = @session_id
  AND row_id IN (@xwing_row_id, @tie_row_id);

----------------------------------------------------------------------
-- 3. catalog_selections (parent rows for the two starfighters).
----------------------------------------------------------------------
INSERT INTO dbo.catalog_selections
    ([session_id], [row_id], [account_id], [organization_id],
     [community], [series], [plan], [application], [product], [area], [sub_area],
     [item_no], [item], [vendor], [standard],
     [qty], [source], [selected], [notes])
VALUES
    (@session_id, @xwing_row_id, @account_id, @organization_id,
     'Galactic Catalog Demo', 'Starfighter Showcase', 'Combined Fleet Plan',
     'Starships', 'Starfighter', 'Hangar', 'Display Bay',
     'T-65', 'X-Wing Starfighter (T-65)',
     'Incom Corporation',
     '4x Taim & Bak KX9 Laser Cannons, 2x Krupx MG7 Proton Torpedoes, Class 1 Hyperdrive',
     1, 'catalog', 0, ''),
    (@session_id, @tie_row_id, @account_id, @organization_id,
     'Galactic Catalog Demo', 'Starfighter Showcase', 'Combined Fleet Plan',
     'Starships', 'Starfighter', 'Hangar', 'Display Bay',
     'TIE/LN', 'TIE/LN Fighter',
     'Sienar Fleet Systems',
     '2x SFS L-s1 Laser Cannons, Solar Panel Array, No Hyperdrive',
     1, 'catalog', 0, '');

----------------------------------------------------------------------
-- 4. catalog_selection_attributes (8 rows: 4 per fighter).
----------------------------------------------------------------------
INSERT INTO dbo.catalog_selection_attributes
    ([session_id], [row_id], [attribute_id], [name], [display_order])
VALUES
    -- X-Wing
    (@session_id, @xwing_row_id, @xw_attr_hull,      'Hull Color',           1),
    (@session_id, @xwing_row_id, @xw_attr_sfoil,     'S-Foil Configuration', 2),
    (@session_id, @xwing_row_id, @xw_attr_astromech, 'Astromech Companion',  3),
    (@session_id, @xwing_row_id, @xw_attr_weapons,   'Primary Weapons',      4),
    -- TIE Fighter
    (@session_id, @tie_row_id,   @tie_attr_panels,   'Solar Panel Pattern',  1),
    (@session_id, @tie_row_id,   @tie_attr_hull,     'Hull Color',           2),
    (@session_id, @tie_row_id,   @tie_attr_cockpit,  'Cockpit Type',         3),
    (@session_id, @tie_row_id,   @tie_attr_engines,  'Engine Tuning',        4);

----------------------------------------------------------------------
-- 5. catalog_selection_attribute_values (22 rows; all selected = 0).
----------------------------------------------------------------------
INSERT INTO dbo.catalog_selection_attribute_values
    ([session_id], [row_id], [attribute_id], [value_id], [value], [display_order], [selected])
VALUES
    -- X-Wing :: Hull Color
    (@session_id, @xwing_row_id, @xw_attr_hull, 'A0000001-0001-0000-0000-AAAAAAAAA001', 'Alliance Orange',         1, 0),
    (@session_id, @xwing_row_id, @xw_attr_hull, 'A0000001-0001-0000-0000-AAAAAAAAA002', 'Battle Gray',             2, 0),
    (@session_id, @xwing_row_id, @xw_attr_hull, 'A0000001-0001-0000-0000-AAAAAAAAA003', 'Stealth Matte Black',     3, 0),

    -- X-Wing :: S-Foil Configuration
    (@session_id, @xwing_row_id, @xw_attr_sfoil, 'A0000001-0002-0000-0000-AAAAAAAAA001', 'Attack Position (Open)',    1, 0),
    (@session_id, @xwing_row_id, @xw_attr_sfoil, 'A0000001-0002-0000-0000-AAAAAAAAA002', 'Cruise Position (Closed)',  2, 0),

    -- X-Wing :: Astromech Companion
    (@session_id, @xwing_row_id, @xw_attr_astromech, 'A0000001-0003-0000-0000-AAAAAAAAA001', 'R2-D2',         1, 0),
    (@session_id, @xwing_row_id, @xw_attr_astromech, 'A0000001-0003-0000-0000-AAAAAAAAA002', 'R5-D4',         2, 0),
    (@session_id, @xwing_row_id, @xw_attr_astromech, 'A0000001-0003-0000-0000-AAAAAAAAA003', 'R4-P17',        3, 0),
    (@session_id, @xwing_row_id, @xw_attr_astromech, 'A0000001-0003-0000-0000-AAAAAAAAA004', 'No Astromech',  4, 0),

    -- X-Wing :: Primary Weapons
    (@session_id, @xwing_row_id, @xw_attr_weapons, 'A0000001-0004-0000-0000-AAAAAAAAA001', '4x KX9 Laser Cannons',     1, 0),
    (@session_id, @xwing_row_id, @xw_attr_weapons, 'A0000001-0004-0000-0000-AAAAAAAAA002', '+2x MG7 Proton Torpedoes', 2, 0),
    (@session_id, @xwing_row_id, @xw_attr_weapons, 'A0000001-0004-0000-0000-AAAAAAAAA003', '+Concussion Missile Pod',  3, 0),

    -- TIE Fighter :: Solar Panel Pattern
    (@session_id, @tie_row_id, @tie_attr_panels, 'B0000002-0001-0000-0000-BBBBBBBBB001', 'Standard Hex',       1, 0),
    (@session_id, @tie_row_id, @tie_attr_panels, 'B0000002-0001-0000-0000-BBBBBBBBB002', 'Bent Hex (TIE/sa)',  2, 0),

    -- TIE Fighter :: Hull Color
    (@session_id, @tie_row_id, @tie_attr_hull, 'B0000002-0002-0000-0000-BBBBBBBBB001', 'Imperial Black',         1, 0),
    (@session_id, @tie_row_id, @tie_attr_hull, 'B0000002-0002-0000-0000-BBBBBBBBB002', 'Storm Gray',             2, 0),
    (@session_id, @tie_row_id, @tie_attr_hull, 'B0000002-0002-0000-0000-BBBBBBBBB003', 'Crimson (Royal Guard)',  3, 0),

    -- TIE Fighter :: Cockpit Type
    (@session_id, @tie_row_id, @tie_attr_cockpit, 'B0000002-0003-0000-0000-BBBBBBBBB001', 'Standard Pod',   1, 0),
    (@session_id, @tie_row_id, @tie_attr_cockpit, 'B0000002-0003-0000-0000-BBBBBBBBB002', 'Bubble Canopy',  2, 0),

    -- TIE Fighter :: Engine Tuning
    (@session_id, @tie_row_id, @tie_attr_engines, 'B0000002-0004-0000-0000-BBBBBBBBB001', 'Standard Twin Ion Engines', 1, 0),
    (@session_id, @tie_row_id, @tie_attr_engines, 'B0000002-0004-0000-0000-BBBBBBBBB002', 'Performance Tune (TIE/in)', 2, 0),
    (@session_id, @tie_row_id, @tie_attr_engines, 'B0000002-0004-0000-0000-BBBBBBBBB003', 'High-G Maneuverability',    3, 0);

----------------------------------------------------------------------
-- 6. Verification queries.
----------------------------------------------------------------------
 SELECT * FROM dbo.catalog_selections
  WHERE session_id = @session_id
    AND row_id IN (@xwing_row_id, @tie_row_id);

 SELECT * FROM dbo.catalog_selection_attributes
  WHERE session_id = @session_id
  ORDER BY row_id, display_order;

 SELECT * FROM dbo.catalog_selection_attribute_values
  WHERE session_id = @session_id
  ORDER BY row_id, attribute_id, display_order;
