-- set rowcount 50

-- exec sp_who2
-- -- select*from sys.dm_os_wait_stats order by wait_time_ms desc

-- select*from sys.dm_exec_requests -- where blocking_session_id != 0

-- -- select*from sys.dm_db_index_physical_stats(db_id('BD_SGD'),null,null,null,'LIMITED')

-- SELECT
--     OBJECT_NAME(object_id) AS tabla,
--     index_id,
--     avg_fragmentation_in_percent,
--     page_count
-- FROM sys.dm_db_index_physical_stats (
--     DB_ID('BD_SGD'),
--     NULL,
--     NULL,
--     NULL,
--     'LIMITED'
-- )
-- WHERE page_count > 1000
-- ORDER BY avg_fragmentation_in_percent DESC;


SELECT actual_state_desc FROM sys.database_query_store_options;
-- (debe decir READ_WRITE)


SELECT
    qsq.query_id,
    qt.query_sql_text,
    rs.avg_logical_io_reads,
    p.query_plan
FROM sys.query_store_query qsq
JOIN sys.query_store_query_text qt
    ON qsq.query_text_id = qt.query_text_id
JOIN sys.query_store_plan p
    ON qsq.query_id = p.query_id
JOIN sys.query_store_runtime_stats rs
    ON p.plan_id = rs.plan_id
WHERE qsq.object_id = OBJECT_ID('tramite.paListarExpedientePendienteEspecialistaV7');


SELECT
    qsq.query_id,
    qt.query_sql_text
FROM sys.query_store_query qsq
JOIN sys.query_store_query_text qt
    ON qsq.query_text_id = qt.query_text_id;
