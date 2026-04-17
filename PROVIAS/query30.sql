
GO
DROP INDEX IX_EDOD_Filtro ON Tramite.ExpedienteDocumentoOrigenDestino
GO
-- CREATE NONCLUSTERED INDEX IX_EDOD_Filtro
-- ON Tramite.ExpedienteDocumentoOrigenDestino
-- (
--     IdAreaDestino,
--     IdEmpresaDestino,
--     IdCatalogoSituacionMovimientoDestino,
--     IdCargoDestino,
--     IdExpedienteDocumentoOrigen
-- )
-- WHERE EstadoAuditoria = 1;


GO
DROP INDEX IX_EDO_Join ON Tramite.ExpedienteDocumentoOrigen
GO
-- CREATE NONCLUSTERED INDEX IX_EDO_Join
-- ON Tramite.ExpedienteDocumentoOrigen
-- (
--     IdExpedienteDocumento
-- )
-- INCLUDE (IdExpedienteDocumentoOrigen)
-- WHERE EstadoAuditoria = 1;


GO
DROP INDEX IX_ED_Filtro ON Tramite.ExpedienteDocumento
GO
-- CREATE NONCLUSTERED INDEX IX_ED_Filtro
-- ON Tramite.ExpedienteDocumento
-- (
--     IdExpediente
-- )
-- INCLUDE (IdExpedienteDocumento)
-- WHERE EstadoAuditoria = 1;



GO
DROP INDEX IX_Expediente_Base ON Tramite.Expediente
GO
-- CREATE NONCLUSTERED INDEX IX_Expediente_Base
-- ON Tramite.Expediente
-- (
--     IdExpediente
-- )
-- INCLUDE (EstadoAuditoria, ExpedienteAnulado, IdSerieDocumentalExpediente);


GO
DROP INDEX IX_Cargo_TipoCargo_Only ON GENERAL.CARGO
GO
-- CREATE NONCLUSTERED INDEX IX_Cargo_TipoCargo_Only
-- ON General.Cargo (IdCatalogoTipoCargo, IdCargo)
-- WITH (DATA_COMPRESSION = PAGE);
