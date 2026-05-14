-- SELECT
--     s.session_id,
--     s.login_name,
--     r.status,
--     r.command,
--     DB_NAME(r.database_id) AS database_name,
--     r.cpu_time,
--     r.total_elapsed_time,
--     CAST(r.total_elapsed_time / 1000.0 / 60 AS DECIMAL(10,2)) AS minutos,
--     DATEADD(MILLISECOND, -r.total_elapsed_time, GETDATE()) AS hora_inicio
-- FROM sys.dm_exec_sessions s
-- INNER JOIN sys.dm_exec_requests r
--     ON s.session_id = r.session_id
-- WHERE s.login_name = 'U_SgdDesa';

-- SELECT
--     r.session_id,
--     t.text
-- FROM sys.dm_exec_requests r
-- CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
-- WHERE r.session_id = 53;

-- SELECT
--     session_id,
--     status,
--     command,
--     wait_type,
--     wait_time,
--     wait_resource,
--     blocking_session_id
-- FROM sys.dm_exec_requests
-- WHERE session_id = 53;



declare @cta int = 1
while @cta < 20 begin
SELECT
    session_id,
    cpu_time,
    total_elapsed_time,
    reads,
    writes,
    logical_reads,
    row_count
FROM sys.dm_exec_requests
WHERE session_id = 53;

waitfor delay '00:00:02'
select @cta +=1
end
