-- NOTA: PARA HISTORICOS 2025

CREATE NONCLUSTERED INDEX IX_Hist_Completo_OrigenDestino
ON Tramite.ExpedienteDocumentoOrigenDestino_historico_2025 (IdExpedienteDocumentoOrigen, EstadoAuditoria, IdCatalogoSituacionMovimientoDestino)
WITH (ONLINE = ON, FILLFACTOR = 90);

-- NOTA: PARA HISTORICOS 2024


CREATE NONCLUSTERED INDEX IX_Hist_Completo_OrigenDestino
ON Tramite.ExpedienteDocumentoOrigenDestino_historico_2024 (IdExpedienteDocumentoOrigen, EstadoAuditoria, IdCatalogoSituacionMovimientoDestino)
WITH (ONLINE = ON, FILLFACTOR = 90);


-- NOTA: PARA HISTORICOS 2023


CREATE NONCLUSTERED INDEX IX_Hist_Completo_OrigenDestino
ON Tramite.ExpedienteDocumentoOrigenDestino_historico_2023 (IdExpedienteDocumentoOrigen, EstadoAuditoria, IdCatalogoSituacionMovimientoDestino)
WITH (ONLINE = ON, FILLFACTOR = 90);

-- NOTA: PARA HISTORICOS 2022


CREATE NONCLUSTERED INDEX IX_Hist_Completo_OrigenDestino
ON Tramite.ExpedienteDocumentoOrigenDestino_historico_2022 (IdExpedienteDocumentoOrigen, EstadoAuditoria, IdCatalogoSituacionMovimientoDestino)
WITH (ONLINE = ON, FILLFACTOR = 90);
