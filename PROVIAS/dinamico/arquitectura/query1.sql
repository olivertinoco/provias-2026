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






-- CREATE NONCLUSTERED INDEX [_dta_index_
-- SalesOrderDetail_5_807673925__K3_1_4_5]
-- ON [dbo].[SalesOrderDetail]
-- (
-- [CarrierTrackingNumber] ASC
-- )
-- INCLUDE ([SalesOrderID],
-- [OrderQty],
-- [ProductID]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF,
-- ONLINE = OFF)
-- ON [PRIMARY]
--


-- SELECT a.index_id, name, avg_fragmentation_in_percent,
-- fragment_count,
-- avg_fragment_size_in_pages
-- FROM sys.dm_db_index_physical_stats (DB_ID('AdventureWorks2019'),OBJECT_ID('Sales.SalesOrderDetail'), NULL, NULL, NULL) AS a
-- JOIN sys.indexes AS b ON a.object_id = b.object_id AND a.index_id = b.index_id

-- >10 index reorganize
-- >30 index rebuild

-- verificar los indices no usados
-- ================================
-- sys.dm_db_index_usage_stats


-- SELECT DB_NAME(database_id) AS database_name,
-- OBJECT_NAME(s.object_id) AS object_name, i.name, s.*
-- FROM sys.dm_db_index_usage_stats s
-- JOIN sys.indexes i ON s.object_id = i.object_id AND s.index_id = i.index_id AND OBJECT_ID('dbo.SalesOrderDetail') = s.object_id


-- CREAR UNA BASE DE DATOS PARA OPTIMIZARLA
-- ========================================

-- CREATE DATABASE Test
-- ON PRIMARY (NAME = Test_data,
-- FILENAME = 'C:\DATA\Test_data.mdf', SIZE=500MB)
-- LOG ON (NAME = Test_log, Filename='C:\DATA\Test_log.ldf',
-- SIZE=500MB)
-- GO
-- ALTER DATABASE Test ADD FILEGROUP Test_fg CONTAINS MEMORY_
-- OPTIMIZED_DATA
-- GO
-- ALTER DATABASE Test ADD FILE (NAME = Test_fg, FILENAME = N'C:\
-- DATA\Test_fg')
-- TO FILEGROUP Test_fg
-- GO


-- CREATE TABLE <tbl_prueba>(
--     ....  NOT NULL PRIMARY KEY NONCLUSTERED HASH WITH(BUCKET_COUNT = 100000),
-- ) WITH (MEMORY_OPTIMIZED = ON)




-- CREATE TABLE TransactionHistoryArchive (
-- TransactionID int NOT NULL,
-- ProductID int NOT NULL,
-- ReferenceOrderID int NOT NULL,
-- ReferenceOrderLineID int NOT NULL,
-- TransactionDate datetime NOT NULL,
-- TransactionType nchar(1) NOT NULL,
-- Quantity int NOT NULL,
-- ActualCost money NOT NULL,
-- ModifiedDate datetime NOT NULL,
-- CONSTRAINT PK_TransactionID_ProductID PRIMARY KEY NONCLUSTERED
-- HASH (TransactionID, ProductID) WITH (BUCKET_COUNT = 100000)
-- ) WITH (MEMORY_OPTIMIZED = ON)
