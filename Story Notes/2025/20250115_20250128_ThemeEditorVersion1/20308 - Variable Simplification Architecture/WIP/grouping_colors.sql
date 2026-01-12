/*
select * from [dbo].[JKP_ThemeVariableValue_JustColors]
select * from [dbo].[JKP_ThemeVariableValue_Deltas]
*/


/*
based on the deltas of variable values I want to group them based on the HueDelta
*/

WITH PartitionedColors AS (
    SELECT 
        v.CssName,
        d.HDelta,
        v.Value,
        v.R,
        v.G,
        v.B,
        v.H,
        v.S,
        v.L,
        DENSE_RANK() OVER (ORDER BY d.HDelta / 12) AS PartitionID
    FROM 
        [dbo].[JKP_ThemeVariableValue_JustColors] AS v
    LEFT JOIN 
        [dbo].[JKP_ThemeVariableValue_Deltas] AS d 
    ON 
        v.CssName = d.CssName
    WHERE 
        d.HDelta <= 12
)
SELECT 
    PartitionID,
    AVG(R) AS AvgR,
    AVG(G) AS AvgG,
    AVG(B) AS AvgB,
    AVG(H) AS AvgH,
    AVG(S) AS AvgS,
    AVG(L) AS AvgL
FROM 
    PartitionedColors
GROUP BY 
    PartitionID
ORDER BY 
    PartitionID;