POSIBLES PROPUESTOS
===================
tengo las tablas y sus pks
traminte.Expediente_historico_2025 pk: idExpediente
traminte.ExpedienteDocumento_historico_2025 pk: idExpedienteDocumento
traminte.ExpedienteDocumentoOrigen_historico_2025 pk: idExpedienteDocumentoOrigen
traminte.ExpedienteDocumentoOrigenDestino_historico_2025 pk: idExpedienteDocumentoOrigenDestino

para una mejor performance como tendria que crearle los indices nonclustered en los historicos
bajo esta consulta comun

select <campos>
from traminte.Expediente_historico_2025 t1
inner join traminte.ExpedienteDocumento_historico_2025 t2
    on t2.idExpediente = t1.idExpediente and t2.EstadoAuditoria = 1
inner join traminte.ExpedienteDocumentoOrigen_historico_2025 t3
    on t3.idExpedienteDocumento = t2.idExpedienteDocumento and t3.EstadoAuditoria = 1
inner join traminte.ExpedienteDocumentoOrigenDestino_historico_2025 t4
    on t4.idExpedienteDocumentoOrigen = t3.idExpedienteDocumentoOrigen and t4.EstadoAuditoria = 1
where t1.idExpediente = @idExpediente and t1.EstadoAuditoria = 1 and t1.ExpedienteAnulado = 0

===================


CREATE NONCLUSTERED INDEX IX_ExpDoc_Historico2025_IdExpediente_Estado
ON traminte.ExpedienteDocumento_historico_2025 (IdExpediente, EstadoAuditoria)
INCLUDE (IdExpedienteDocumento, NumeroDocumento, CorrelativoVinculado,NumeroFoliosDocumento)

CREATE NONCLUSTERED INDEX IX_ExpDocOrigen_Historico2025_IdExpDoc_Estado
ON traminte.ExpedienteDocumentoOrigen_historico_2025 (IdExpedienteDocumento, EstadoAuditoria)
INCLUDE (IdExpedienteDocumentoOrigen, IdCatalogoTipoMovimientoOrigen, IdExpedienteDocumentoOrigen, IdPersonaOrigen)


CREATE NONCLUSTERED INDEX IX_ExpDocOrigenDest_Historico2025_IdOrigen_Estado
ON traminte.ExpedienteDocumentoOrigenDestino_historico_2025 (IdExpedienteDocumentoOrigen, EstadoAuditoria)
INCLUDE(IdExpedienteDocumentoOrigenDestino,FechaDestino,HoraDestino)

CREATE NONCLUSTERED INDEX IX_Expediente_Historico2025_IdExpediente_Estado
ON traminte.Expediente_historico_2025 (IdExpediente, EstadoAuditoria, ExpedienteAnulado)
INCLUDE (NumeroExpediente, IdPeriodo, IdSerieDocumentalExpediente)



REVISAR LA DEFRAGMENTACION DE LOS INDICES....


-- Analizar la Fragmentacion cada semana:
SELECT
    OBJECT_NAME(ips.object_id) AS NombreTabla,
    i.name AS NombreIndice,
    ips.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.avg_fragmentation_in_percent > 5;


-- Ver page splits (eventos de partición)
SELECT
    OBJECT_NAME(ips.object_id) AS Tabla,
    i.name AS Indice,
    ips.avg_fragmentation_in_percent,
    ips.page_count,
    ips.avg_page_space_used_in_percent  -- Qué % de cada página está ocupado
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'DETAILED') ips
JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE i.name LIKE 'IX_Hist%';
