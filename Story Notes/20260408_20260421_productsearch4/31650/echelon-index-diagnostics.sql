-- ============================================================
-- Story #31650 — Product Search Estimated Performance
-- Echelon/WBS Database Diagnostic Queries
-- Run these directly against the WBS/Echelon database
-- ============================================================


-- ============================================================
-- Query 1: SQL Server's accumulated missing index recommendations
-- Prioritized by estimated improvement impact.
-- These are built up from real query executions on this server.
-- ============================================================
SELECT
    migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans) AS improvement_measure,
    mid.statement AS table_name,
    mid.equality_columns,
    mid.inequality_columns,
    mid.included_columns
FROM
    sys.dm_db_missing_index_groups mig
    JOIN sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
    JOIN sys.dm_db_missing_index_details mid ON mid.index_handle = mig.index_handle
ORDER BY improvement_measure DESC;


-- ============================================================
-- Query 2: Existing indexes on the tables we care about
-- Confirms what is already indexed so we don't duplicate.
-- ============================================================
SELECT
    t.name AS table_name,
    i.name AS index_name,
    i.type_desc,
    STRING_AGG(c.name, ', ') WITHIN GROUP (ORDER BY ic.key_ordinal) AS key_columns
FROM
    sys.indexes i
    JOIN sys.tables t ON t.object_id = i.object_id
    JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id
    JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
WHERE
    ic.is_included_column = 0
    AND t.name IN (
        'wbs_prices_landed', 'wbs_plan_material', 'wbs_spec_items',
        'veo_colors', 'wbs_styles_groups_detail', 'spec_communities',
        'communities', 'spec_series'
    )
GROUP BY t.name, i.name, i.type_desc
ORDER BY t.name, i.name;


-- ============================================================
-- Query 3: Actual row counts on those tables
-- Validates the estimated row counts from the execution plan
-- and helps right-size index recommendations.
-- ============================================================
SELECT
    t.name AS table_name,
    p.rows AS row_count
FROM
    sys.tables t
    JOIN sys.partitions p ON p.object_id = t.object_id AND p.index_id IN (0, 1)
WHERE
    t.name IN (
        'wbs_prices_landed', 'wbs_plan_material', 'wbs_spec_items',
        'veo_colors', 'wbs_styles_groups_detail', 'spec_communities',
        'communities', 'spec_series'
    )
ORDER BY p.rows DESC;
