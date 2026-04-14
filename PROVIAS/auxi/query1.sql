-- CREATE view [Tramite].[visExpedienteCompleto]
-- as

SELECT
    E.HoraExpediente, E.IdCatalogoTipoPrioridad,E.IdExpediente,ed.IdExpedienteDocumento,
    EDOD.IdExpedienteDocumentoOrigenDestino,
    EDO.IdExpedienteDocumentoOrigen ,
    EDOD.IdAreaDestino,
    E.IdPeriodo,
    EDOD.IdCargoDestino,
    EDOD.IdEmpresaDestino,
    EDOD.IdCatalogoSituacionMovimientoDestino
    ,E.NTFechaExpediente
    ,ED.FgEnEsperaFirmaDigital
    ,E.NumeroExpediente
    ,EDOD.EsInicial
    ,E.IdSerieDocumentalExpediente
    ,EDO.EsVinculado
    ,EDOD.FechaDestinoRecepciona
    ,edo.IdAreaOrigen
    ,e.IdCatalogoTipoTramite
    ,edo.IdCargoOrigen
    ,EDO.FechaOrigen
    ,EDOD.FechaDestino
    ,EDOD.HoraDestinoEnvia
    ,EDO.IdPersonaOrigen
    ,ed.NombreCompletoEmisor
    ,EDO.IdempresaOrigen
    ,ED.IdCatalogoTipoDocumento
    ,ED.RutaArchivoDocumento
    ,ED.Correlativo
    ,ED.NumeroDocumento
    ,EDOD.MotivoArchivado
    ,EDO.IdCatalogoSituacionMovimientoOrigen
    ,EDOD.IdExpedienteDocumentoOrigenDestinoAnterior
    ,EDOD.IdPersonaDestino
    ,EDOD.FechaDestinoEnvia
    ,e.IdPersonaCreador
    ,EDO.HoraOrigen
    ,E.IdUsuarioCreacionAuditoria
FROM Tramite.Expediente E WITH (NOLOCK)
INNER JOIN Tramite.SerieDocumentalExpediente SD WITH (NOLOCK)
    ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente AND E.EstadoAuditoria=1
INNER JOIN Tramite.ExpedienteDocumento ED WITH (NOLOCK)
    ON E.IdExpediente=ED.IdExpediente AND ED.EstadoAuditoria=1 AND COALESCE(E.ExpedienteAnulado,0)=0
INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
    ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND EDO.EstadoAuditoria=1
INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
    ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen AND EDOD.EstadoAuditoria=1
