-- NOTA: PARA HISTORICOS 2025

CREATE NONCLUSTERED INDEX IX_ExpDoc_Historico2025_IdExpediente_Estado
ON Tramite.ExpedienteDocumento_historico_2025 (IdExpediente, EstadoAuditoria)
INCLUDE (IdExpedienteDocumento, NumeroDocumento, CorrelativoVinculado,NumeroFoliosDocumento)
WITH (ONLINE = ON, FILLFACTOR = 90);

CREATE NONCLUSTERED INDEX IX_ExpDocOrigen_Historico2025_IdExpDoc_Estado
ON Tramite.ExpedienteDocumentoOrigen_historico_2025 (IdExpedienteDocumento, EstadoAuditoria)
INCLUDE (IdExpedienteDocumentoOrigen, IdCatalogoTipoMovimientoOrigen, IdPersonaOrigen, FechaOrigen, HoraOrigen)
WITH (ONLINE = ON, FILLFACTOR = 90);


CREATE NONCLUSTERED INDEX IX_ExpDocOrigenDest_Historico2025_IdOrigen_Estado
ON Tramite.ExpedienteDocumentoOrigenDestino_historico_2025 (IdExpedienteDocumentoOrigen, EstadoAuditoria)
INCLUDE(IdExpedienteDocumentoOrigenDestino,FechaDestino,HoraDestino)
WITH (ONLINE = ON, FILLFACTOR = 90);


CREATE NONCLUSTERED INDEX IX_Expediente_Historico2025_IdExpediente_Estado
ON Tramite.Expediente_historico_2025 (IdExpediente, EstadoAuditoria, ExpedienteAnulado)
INCLUDE (NumeroExpediente, IdPeriodo, IdSerieDocumentalExpediente)
WITH (ONLINE = ON, FILLFACTOR = 90);


-- NOTA: PARA HISTORICOS 2024

CREATE NONCLUSTERED INDEX IX_ExpDoc_Historico2025_IdExpediente_Estado
ON Tramite.ExpedienteDocumento_historico_2024 (IdExpediente, EstadoAuditoria)
INCLUDE (IdExpedienteDocumento, NumeroDocumento, CorrelativoVinculado,NumeroFoliosDocumento)
WITH (ONLINE = ON, FILLFACTOR = 90);

CREATE NONCLUSTERED INDEX IX_ExpDocOrigen_Historico2025_IdExpDoc_Estado
ON Tramite.ExpedienteDocumentoOrigen_historico_2024 (IdExpedienteDocumento, EstadoAuditoria)
INCLUDE (IdExpedienteDocumentoOrigen, IdCatalogoTipoMovimientoOrigen, IdPersonaOrigen, FechaOrigen, HoraOrigen)
WITH (ONLINE = ON, FILLFACTOR = 90);


CREATE NONCLUSTERED INDEX IX_ExpDocOrigenDest_Historico2025_IdOrigen_Estado
ON Tramite.ExpedienteDocumentoOrigenDestino_historico_2024 (IdExpedienteDocumentoOrigen, EstadoAuditoria)
INCLUDE(IdExpedienteDocumentoOrigenDestino,FechaDestino,HoraDestino)
WITH (ONLINE = ON, FILLFACTOR = 90);


CREATE NONCLUSTERED INDEX IX_Expediente_Historico2025_IdExpediente_Estado
ON Tramite.Expediente_historico_2024 (IdExpediente, EstadoAuditoria, ExpedienteAnulado)
INCLUDE (NumeroExpediente, IdPeriodo, IdSerieDocumentalExpediente)
WITH (ONLINE = ON, FILLFACTOR = 90);


-- NOTA: PARA HISTORICOS 2023


CREATE NONCLUSTERED INDEX IX_ExpDoc_Historico2025_IdExpediente_Estado
ON Tramite.ExpedienteDocumento_historico_2023 (IdExpediente, EstadoAuditoria)
INCLUDE (IdExpedienteDocumento, NumeroDocumento, CorrelativoVinculado,NumeroFoliosDocumento)
WITH (ONLINE = ON, FILLFACTOR = 90);

CREATE NONCLUSTERED INDEX IX_ExpDocOrigen_Historico2025_IdExpDoc_Estado
ON Tramite.ExpedienteDocumentoOrigen_historico_2023 (IdExpedienteDocumento, EstadoAuditoria)
INCLUDE (IdExpedienteDocumentoOrigen, IdCatalogoTipoMovimientoOrigen, IdPersonaOrigen, FechaOrigen, HoraOrigen)
WITH (ONLINE = ON, FILLFACTOR = 90);


CREATE NONCLUSTERED INDEX IX_ExpDocOrigenDest_Historico2025_IdOrigen_Estado
ON Tramite.ExpedienteDocumentoOrigenDestino_historico_2023 (IdExpedienteDocumentoOrigen, EstadoAuditoria)
INCLUDE(IdExpedienteDocumentoOrigenDestino,FechaDestino,HoraDestino)
WITH (ONLINE = ON, FILLFACTOR = 90);


CREATE NONCLUSTERED INDEX IX_Expediente_Historico2025_IdExpediente_Estado
ON Tramite.Expediente_historico_2023 (IdExpediente, EstadoAuditoria, ExpedienteAnulado)
INCLUDE (NumeroExpediente, IdPeriodo, IdSerieDocumentalExpediente)
WITH (ONLINE = ON, FILLFACTOR = 90);



-- NOTA: PARA HISTORICOS 2022

CREATE NONCLUSTERED INDEX IX_ExpDoc_Historico2025_IdExpediente_Estado
ON Tramite.ExpedienteDocumento_historico_2022 (IdExpediente, EstadoAuditoria)
INCLUDE (IdExpedienteDocumento, NumeroDocumento, CorrelativoVinculado,NumeroFoliosDocumento)
WITH (ONLINE = ON, FILLFACTOR = 90);

CREATE NONCLUSTERED INDEX IX_ExpDocOrigen_Historico2025_IdExpDoc_Estado
ON Tramite.ExpedienteDocumentoOrigen_historico_2022 (IdExpedienteDocumento, EstadoAuditoria)
INCLUDE (IdExpedienteDocumentoOrigen, IdCatalogoTipoMovimientoOrigen, IdPersonaOrigen, FechaOrigen, HoraOrigen)
WITH (ONLINE = ON, FILLFACTOR = 90);


CREATE NONCLUSTERED INDEX IX_ExpDocOrigenDest_Historico2025_IdOrigen_Estado
ON Tramite.ExpedienteDocumentoOrigenDestino_historico_2022 (IdExpedienteDocumentoOrigen, EstadoAuditoria)
INCLUDE(IdExpedienteDocumentoOrigenDestino,FechaDestino,HoraDestino)
WITH (ONLINE = ON, FILLFACTOR = 90);


CREATE NONCLUSTERED INDEX IX_Expediente_Historico2025_IdExpediente_Estado
ON Tramite.Expediente_historico_2022 (IdExpediente, EstadoAuditoria, ExpedienteAnulado)
INCLUDE (NumeroExpediente, IdPeriodo, IdSerieDocumentalExpediente)
WITH (ONLINE = ON, FILLFACTOR = 90);
