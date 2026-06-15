set rowcount 0
set nocount on

select count(1), 'Expediente' from Tramite.Expediente
select count(1), 'ExpedienteDevuelto' from Tramite.ExpedienteDevuelto
select count(1), 'ExpedienteDocumento' from Tramite.ExpedienteDocumento
select count(1), 'ExpedienteDocumentoAdjunto' from Tramite.ExpedienteDocumentoAdjunto
select count(1), 'ExpedienteDocumentoAdjuntoFirmante' from Tramite.ExpedienteDocumentoAdjuntoFirmante
select count(1), 'ExpedienteDocumentoAdjuntoTemporal' from Tramite.ExpedienteDocumentoAdjuntoTemporal
select count(1), 'ExpedienteDocumentoFirmante' from Tramite.ExpedienteDocumentoFirmante
select count(1), 'ExpedienteDocumentoOrigen' from Tramite.ExpedienteDocumentoOrigen
select count(1), 'ExpedienteDocumentoOrigenAdjunto' from Tramite.ExpedienteDocumentoOrigenAdjunto
select count(1), 'ExpedienteDocumentoOrigenDestino' from Tramite.ExpedienteDocumentoOrigenDestino
select count(1), 'ExpedienteDocumentoOrigenDestinoAccion' from Tramite.ExpedienteDocumentoOrigenDestinoAccion
select count(1), 'ExpedienteDocumentoOrigenDestinoTemporal' from Tramite.ExpedienteDocumentoOrigenDestinoTemporal
select count(1), 'ExpedienteEnlazado' from Tramite.ExpedienteEnlazado
select count(1), 'ExpedienteSeguimiento' from Tramite.ExpedienteSeguimiento
select count(1), 'NumeracionSeparada' from Tramite.NumeracionSeparada
