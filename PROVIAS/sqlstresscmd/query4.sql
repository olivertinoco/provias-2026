select
    t1.IdExpediente,
    t2.IdExpedienteDocumento,
    t3.IdExpedienteDocumentoOrigen,
    t4.IdExpedienteDocumentoOrigenDestino,

    t3.FechaOrigen,
    t3.HoraOrigen,
    t3.IdPersonaOrigen,
    t3.IdAreaOrigen,
    t3.IdCargoOrigen,
    t3.IdempresaOrigen,
    t3.IdCatalogoSituacionMovimientoOrigen,

    t4.IdAreaDestino,
    t4.IdCargoDestino,
    t4.IdPersonaDestino,
    t4.IdCatalogoSituacionMovimientoDestino,
    t4.FechaDestinoRecepciona,
    t4.EsInicial

into #baseCuarteto
from tramite.Expediente t1
inner join tramite.ExpedienteDocumento t2
    on t2.IdExpediente = t1.IdExpediente and t2.EstadoAuditoria = 1
inner join tramite.ExpedienteDocumentoOrigen t3
    on t3.IdExpedienteDocumento = t2.IdExpedienteDocumento
    and t3.EstadoAuditoria = 1
inner join tramite.ExpedienteDocumentoOrigenDestino t4
    on t4.IdExpedienteDocumentoOrigen = t3.IdExpedienteDocumentoOrigen
    and t4.EstadoAuditoria = 1
where t1.EstadoAuditoria = 1
and t1.ExpedienteAnulado = 0
and t1.IdSerieDocumentalExpediente in (1,2)

CREATE CLUSTERED INDEX IX_base
ON #baseCuarteto (IdExpediente);

CREATE NONCLUSTERED INDEX IX_base_filtros
ON #baseCuarteto (
    IdPersonaOrigen,
    IdAreaOrigen,
    IdCargoOrigen,
    IdempresaOrigen,
    IdCatalogoSituacionMovimientoOrigen
);
