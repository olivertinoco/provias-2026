-- SELECT
--     event_data,
--     file_name,
--     file_offset
-- FROM sys.fn_xe_file_target_read_file('C:\Ruta\Al\Archivo*.xel', NULL, NULL, NULL);

-- ============================================
-- Crear e iniciar la sesión de Extended Events
-- ============================================
-- Si existe una versión previa, la eliminamos
IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = 'Auditoria_SPs_BD_SGD')
    DROP EVENT SESSION [Auditoria_SPs_BD_SGD] ON SERVER;
GO

CREATE EVENT SESSION [Auditoria_SPs_BD_SGD] ON SERVER
ADD EVENT sqlserver.module_end(
    SET collect_statement = (1) -- Captura la sentencia exacta si lo necesitas
    ACTION(
        sqlserver.database_name,
        sqlserver.username,
        sqlserver.client_app_name,
        sqlserver.client_hostname,
        sqlserver.sql_text
    )
    WHERE (
        -- Filtro 1: Solo la base de datos BD_SGD
        [sqlserver].[database_name] = N'BD_SGD'
        -- Filtro 2: Solo procedimientos almacenados (P = Stored Procedure)
        AND [object_type] = 'P'
    )
)
ADD TARGET package0.event_file(
    SET filename = N'C:\LogsSQL\Auditoria_BD_SGD.xel',
    max_file_size = (10),      -- Tamaño máximo por archivo en MB
    max_rollover_files = (5)   -- Guarda hasta 5 archivos rotativos para no saturar el disco
)
WITH (
    MAX_MEMORY = 4096 KB,
    EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS,
    MAX_DISPATCH_LATENCY = 5 SECONDS, -- Escribe al archivo cada 5 segundos
    MEMORY_PARTITION_MODE = NONE,
    TRACK_CAUSALITY = OFF,
    STARTUP_STATE = ON -- Se inicia automáticamente si se reinicia SQL Server
);
GO

-- Iniciar la sesión
ALTER EVENT SESSION [Auditoria_SPs_BD_SGD] ON SERVER STATE = START;
GO


-- -- ============================================
-- Cómo consultar los datos guardados en el archivo .xel
-- -- ============================================

SELECT
    event_data.value('(event/@timestamp)[1]', 'DATETIME2') AS FechaHora_UTC,
    DATEADD(HOUR, DATEDIFF(HOUR, GETUTCDATE(), GETDATE()),
            event_data.value('(event/@timestamp)[1]', 'DATETIME2')) AS FechaHora_Local,
    event_data.value('(event/action[@name="database_name"]/value)[1]', 'VARCHAR(100)') AS BaseDeDatos,
    event_data.value('(event/data[@name="object_name"]/value)[1]', 'VARCHAR(150)') AS Procedimiento,
    event_data.value('(event/action[@name="username"]/value)[1]', 'VARCHAR(100)') AS Usuario,
    event_data.value('(event/action[@name="client_hostname"]/value)[1]', 'VARCHAR(100)') AS HostCliente,
    event_data.value('(event/action[@name="client_app_name"]/value)[1]', 'VARCHAR(100)') AS Aplicacion,
    event_data.value('(event/data[@name="duration"]/value)[1]', 'BIGINT') / 1000 AS Duracion_Milisegundos
FROM (
    SELECT CAST(event_data AS XML) AS event_data
    FROM sys.fn_xe_file_target_read_file(
        'C:\LogsSQL\Auditoria_BD_SGD*.xel',
        NULL, NULL, NULL
    )
) AS xEvents
ORDER BY FechaHora_UTC DESC;


-- -- ============================================
-- Comandos útiles para administrar la sesión
-- -- ============================================
ALTER EVENT SESSION [Auditoria_SPs_BD_SGD] ON SERVER STATE = STOP;
GO
DROP EVENT SESSION [Auditoria_SPs_BD_SGD] ON SERVER;
