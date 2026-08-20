SELECT map_key, map_value
FROM sys.dm_xe_map_values
WHERE name = 'statement_recompile_cause'

SELECT * FROM sys.dm_xe_map_values
-- WHERE name = 'statement_recompile_cause'
