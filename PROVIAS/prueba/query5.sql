set rowcount 50

exec sp_who2
select*from sys.dm_os_wait_stats order by wait_time_ms desc

select*from sys.dm_exec_requests -- where blocking_session_id != 0

-- select*from sys.dm_db_index_physical_stats(db_id('BD_SGD'),null,null,null,'LIMITED')

SELECT
    OBJECT_NAME(object_id) AS tabla,
    index_id,
    avg_fragmentation_in_percent,
    page_count
FROM sys.dm_db_index_physical_stats (
    DB_ID('BD_SGD'),
    NULL,
    NULL,
    NULL,
    'LIMITED'
)
WHERE page_count > 1000
ORDER BY avg_fragmentation_in_percent DESC;
