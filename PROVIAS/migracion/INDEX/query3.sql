-- NOTA: PARA HISTORICOS 2025

CREATE NONCLUSTERED INDEX IX_EDF_Doc_Estado_Firmado
ON Tramite.ExpedienteDocumentoFirmante_historico_2025
    (IdExpedienteDocumento, EstadoAuditoria, FlagFirmado)
INCLUDE
    (IdArea, IdCargo, IdCatalogoTipoFirmante, IdEmpleadoPerfilFirmante,
     PosicionX, PosicionY, IdExpedienteDocumentoFirmante)
WITH (ONLINE = ON, FILLFACTOR = 90);


CREATE NONCLUSTERED INDEX IX_ED_PendienteFirma_Filtrado
ON Tramite.ExpedienteDocumento_historico_2025 (IdExpediente)
INCLUDE
    (IdExpedienteDocumento, IdAreaEmisor, IdCargoEmisor, IdEmpresaEmisor, IdPersonaEmisor,
     IdUsuarioEnProcesoFirma, EnProcesoFirma,
     NumeroDocumento, NFechaDocumento, NumeroFoliosDocumento, RutaArchivoDocumento,
     FechaCreacionAuditoria)
WHERE EstadoAuditoria = 1
  AND FgEnEsperaFirmaDigital = 1
  AND FlagParaDespacho = 1
  AND FgEsObligatorioFirmaDigital = 1
WITH (ONLINE = ON, FILLFACTOR = 90);

CREATE NONCLUSTERED INDEX IX_Expediente_IdExp_Estado_Anulado
ON Tramite.Expediente_historico_2025 (IdExpediente, EstadoAuditoria, ExpedienteAnulado)
INCLUDE (NumeroExpediente, IdPeriodo, IdSerieDocumentalExpediente)
WITH (ONLINE = ON, FILLFACTOR = 90);


-- NOTA: PARA HISTORICOS 2024

CREATE NONCLUSTERED INDEX IX_EDF_Doc_Estado_Firmado
ON Tramite.ExpedienteDocumentoFirmante_historico_2024
    (IdExpedienteDocumento, EstadoAuditoria, FlagFirmado)
INCLUDE
    (IdArea, IdCargo, IdCatalogoTipoFirmante, IdEmpleadoPerfilFirmante,
     PosicionX, PosicionY, IdExpedienteDocumentoFirmante)
WITH (ONLINE = ON, FILLFACTOR = 90);


CREATE NONCLUSTERED INDEX IX_ED_PendienteFirma_Filtrado
ON Tramite.ExpedienteDocumento_historico_2024 (IdExpediente)
INCLUDE
    (IdExpedienteDocumento, IdAreaEmisor, IdCargoEmisor, IdEmpresaEmisor, IdPersonaEmisor,
     IdUsuarioEnProcesoFirma, EnProcesoFirma,
     NumeroDocumento, NFechaDocumento, NumeroFoliosDocumento, RutaArchivoDocumento,
     FechaCreacionAuditoria)
WHERE EstadoAuditoria = 1
  AND FgEnEsperaFirmaDigital = 1
  AND FlagParaDespacho = 1
  AND FgEsObligatorioFirmaDigital = 1
WITH (ONLINE = ON, FILLFACTOR = 90);

CREATE NONCLUSTERED INDEX IX_Expediente_IdExp_Estado_Anulado
ON Tramite.Expediente_historico_2024 (IdExpediente, EstadoAuditoria, ExpedienteAnulado)
INCLUDE (NumeroExpediente, IdPeriodo, IdSerieDocumentalExpediente)
WITH (ONLINE = ON, FILLFACTOR = 90);


-- NOTA: PARA HISTORICOS 2023

CREATE NONCLUSTERED INDEX IX_EDF_Doc_Estado_Firmado
ON Tramite.ExpedienteDocumentoFirmante_historico_2023
    (IdExpedienteDocumento, EstadoAuditoria, FlagFirmado)
INCLUDE
    (IdArea, IdCargo, IdCatalogoTipoFirmante, IdEmpleadoPerfilFirmante,
     PosicionX, PosicionY, IdExpedienteDocumentoFirmante)
WITH (ONLINE = ON, FILLFACTOR = 90);


CREATE NONCLUSTERED INDEX IX_ED_PendienteFirma_Filtrado
ON Tramite.ExpedienteDocumento_historico_2023 (IdExpediente)
INCLUDE
    (IdExpedienteDocumento, IdAreaEmisor, IdCargoEmisor, IdEmpresaEmisor, IdPersonaEmisor,
     IdUsuarioEnProcesoFirma, EnProcesoFirma,
     NumeroDocumento, NFechaDocumento, NumeroFoliosDocumento, RutaArchivoDocumento,
     FechaCreacionAuditoria)
WHERE EstadoAuditoria = 1
  AND FgEnEsperaFirmaDigital = 1
  AND FlagParaDespacho = 1
  AND FgEsObligatorioFirmaDigital = 1
WITH (ONLINE = ON, FILLFACTOR = 90);

CREATE NONCLUSTERED INDEX IX_Expediente_IdExp_Estado_Anulado
ON Tramite.Expediente_historico_2023 (IdExpediente, EstadoAuditoria, ExpedienteAnulado)
INCLUDE (NumeroExpediente, IdPeriodo, IdSerieDocumentalExpediente)
WITH (ONLINE = ON, FILLFACTOR = 90);


-- NOTA: PARA HISTORICOS 2022

CREATE NONCLUSTERED INDEX IX_EDF_Doc_Estado_Firmado
ON Tramite.ExpedienteDocumentoFirmante_historico_2022
    (IdExpedienteDocumento, EstadoAuditoria, FlagFirmado)
INCLUDE
    (IdArea, IdCargo, IdCatalogoTipoFirmante, IdEmpleadoPerfilFirmante,
     PosicionX, PosicionY, IdExpedienteDocumentoFirmante)
WITH (ONLINE = ON, FILLFACTOR = 90);


CREATE NONCLUSTERED INDEX IX_ED_PendienteFirma_Filtrado
ON Tramite.ExpedienteDocumento_historico_2022 (IdExpediente)
INCLUDE
    (IdExpedienteDocumento, IdAreaEmisor, IdCargoEmisor, IdEmpresaEmisor, IdPersonaEmisor,
     IdUsuarioEnProcesoFirma, EnProcesoFirma,
     NumeroDocumento, NFechaDocumento, NumeroFoliosDocumento, RutaArchivoDocumento,
     FechaCreacionAuditoria)
WHERE EstadoAuditoria = 1
  AND FgEnEsperaFirmaDigital = 1
  AND FlagParaDespacho = 1
  AND FgEsObligatorioFirmaDigital = 1
WITH (ONLINE = ON, FILLFACTOR = 90);

CREATE NONCLUSTERED INDEX IX_Expediente_IdExp_Estado_Anulado
ON Tramite.Expediente_historico_2022 (IdExpediente, EstadoAuditoria, ExpedienteAnulado)
INCLUDE (NumeroExpediente, IdPeriodo, IdSerieDocumentalExpediente)
WITH (ONLINE = ON, FILLFACTOR = 90);
