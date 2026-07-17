-- NOTA: PARA HISTORICOS 2025

CREATE NONCLUSTERED INDEX IX_EDODAccion_Hist_EDOD_Filtrado
ON Tramite.ExpedienteDocumentoOrigenDestinoAccion_Historico_2025 (IdExpedienteDocumentoOrigenDestino)
INCLUDE (IdCatalogoTipoAccion)
WHERE EstadoAuditoria = 1
WITH (FILLFACTOR = 90, DATA_COMPRESSION = PAGE);


-- NOTA: PARA HISTORICOS 2024

CREATE NONCLUSTERED INDEX IX_EDODAccion_Hist_EDOD_Filtrado
ON Tramite.ExpedienteDocumentoOrigenDestinoAccion_Historico_2024 (IdExpedienteDocumentoOrigenDestino)
INCLUDE (IdCatalogoTipoAccion)
WHERE EstadoAuditoria = 1
WITH (FILLFACTOR = 90, DATA_COMPRESSION = PAGE);


-- NOTA: PARA HISTORICOS 2023

CREATE NONCLUSTERED INDEX IX_EDODAccion_Hist_EDOD_Filtrado
ON Tramite.ExpedienteDocumentoOrigenDestinoAccion_Historico_2023 (IdExpedienteDocumentoOrigenDestino)
INCLUDE (IdCatalogoTipoAccion)
WHERE EstadoAuditoria = 1
WITH (FILLFACTOR = 90, DATA_COMPRESSION = PAGE);



-- NOTA: PARA HISTORICOS 2022

CREATE NONCLUSTERED INDEX IX_EDODAccion_Hist_EDOD_Filtrado
ON Tramite.ExpedienteDocumentoOrigenDestinoAccion_Historico_2022 (IdExpedienteDocumentoOrigenDestino)
INCLUDE (IdCatalogoTipoAccion)
WHERE EstadoAuditoria = 1
WITH (FILLFACTOR = 90, DATA_COMPRESSION = PAGE);
