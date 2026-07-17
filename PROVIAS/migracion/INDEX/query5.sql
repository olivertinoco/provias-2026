-- NOTA: PARA HISTORICOS 2025

CREATE NONCLUSTERED INDEX IX_EDODAccion_Hist_EDOD_Estado
ON Tramite.ExpedienteDocumentoOrigenDestinoAccion_Historico_2025 (IdExpedienteDocumentoOrigenDestino, EstadoAuditoria)
INCLUDE (IdCatalogoTipoAccion)
WITH (FILLFACTOR = 90);

CREATE NONCLUSTERED INDEX IX_EDOD_Hist_Anterior_Estado
ON Tramite.ExpedienteDocumentoOrigenDestino_Historico_2025 (IdExpedienteDocumentoOrigenDestinoAnterior, EstadoAuditoria)
INCLUDE (FechaDestinoRecepciona)
WITH (FILLFACTOR = 90);


-- NOTA: PARA HISTORICOS 2024

CREATE NONCLUSTERED INDEX IX_EDODAccion_Hist_EDOD_Estado
ON Tramite.ExpedienteDocumentoOrigenDestinoAccion_Historico_2024 (IdExpedienteDocumentoOrigenDestino, EstadoAuditoria)
INCLUDE (IdCatalogoTipoAccion)
WITH (FILLFACTOR = 90);

CREATE NONCLUSTERED INDEX IX_EDOD_Hist_Anterior_Estado
ON Tramite.ExpedienteDocumentoOrigenDestino_Historico_2024 (IdExpedienteDocumentoOrigenDestinoAnterior, EstadoAuditoria)
INCLUDE (FechaDestinoRecepciona)
WITH (FILLFACTOR = 90);



-- NOTA: PARA HISTORICOS 2023

CREATE NONCLUSTERED INDEX IX_EDODAccion_Hist_EDOD_Estado
ON Tramite.ExpedienteDocumentoOrigenDestinoAccion_Historico_2023 (IdExpedienteDocumentoOrigenDestino, EstadoAuditoria)
INCLUDE (IdCatalogoTipoAccion)
WITH (FILLFACTOR = 90);

CREATE NONCLUSTERED INDEX IX_EDOD_Hist_Anterior_Estado
ON Tramite.ExpedienteDocumentoOrigenDestino_Historico_2023 (IdExpedienteDocumentoOrigenDestinoAnterior, EstadoAuditoria)
INCLUDE (FechaDestinoRecepciona)
WITH (FILLFACTOR = 90);



-- NOTA: PARA HISTORICOS 2022

CREATE NONCLUSTERED INDEX IX_EDODAccion_Hist_EDOD_Estado
ON Tramite.ExpedienteDocumentoOrigenDestinoAccion_Historico_2022 (IdExpedienteDocumentoOrigenDestino, EstadoAuditoria)
INCLUDE (IdCatalogoTipoAccion)
WITH (FILLFACTOR = 90);

CREATE NONCLUSTERED INDEX IX_EDOD_Hist_Anterior_Estado
ON Tramite.ExpedienteDocumentoOrigenDestino_Historico_2022 (IdExpedienteDocumentoOrigenDestinoAnterior, EstadoAuditoria)
INCLUDE (FechaDestinoRecepciona)
WITH (FILLFACTOR = 90);
