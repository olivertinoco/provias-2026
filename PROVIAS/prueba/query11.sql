select*from tramite.expedienteDocumento where idExpedienteDocumento = 2135144
select*from tramite.expedienteDocumento where idExpediente = 663588

-- select*from tramite.expedienteDocumento where idExpedienteDocumento = 2148009
-- select*from tramite.expedienteDocumento where idExpediente = 695752





select distinct t4.IdCatalogoSituacionMovimientoDestino, t4.IdAreaDestino, t4.IdCargoDestino, t4.IdPersonaDestino, t2.*
from tramite.expedienteDocumento t2
inner join tramite.expedienteDocumentoOrigen t3
    on t3.idExpedienteDocumento = t2.idExpedienteDocumento and t3.EstadoAuditoria = 1
inner join tramite.expedienteDocumentoOrigenDestino t4
    on t4.idExpedienteDocumentoOrigen = t3.idExpedienteDocumentoOrigen and t4.EstadoAuditoria = 1
where t2.idExpediente = 663588
