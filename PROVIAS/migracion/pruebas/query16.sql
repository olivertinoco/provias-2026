-- select * from [Tramite].[Expediente]
-- select * from [Tramite].[ExpedienteDevuelto]
-- select * from [Tramite].[ExpedienteDocumento]
-- select * from [Tramite].[ExpedienteDocumentoAdjunto]
-- select * from [Tramite].[ExpedienteDocumentoAdjuntoFirmante]
-- select * from [Tramite].[ExpedienteDocumentoAdjuntoTemporal]
-- select * from [Tramite].[ExpedienteDocumentoFirmante]
-- select * from [Tramite].[ExpedienteDocumentoOrigen]
-- select * from [Tramite].[ExpedienteDocumentoOrigenAdjunto]
-- select * from [Tramite].[ExpedienteDocumentoOrigenDestino]
-- select * from [Tramite].[ExpedienteDocumentoOrigenDestinoAccion]
-- select * from [Tramite].[ExpedienteDocumentoOrigenDestinoTemporal]
-- select * from [Tramite].[ExpedienteDocumentoVisualizacion]
-- select * from [Tramite].[ExpedienteEnlazado]
-- select * from [Tramite].[ExpedienteSeguimiento]
-- select * from [Tramite].[NumeracionSeparada]


TABLAS DE SGD



declare @tablas varchar(max) = '\
Tramite.Expediente|\
Tramite.ExpedienteDevuelto|\
Tramite.ExpedienteDocumento|\
Tramite.ExpedienteDocumentoAdjunto|\
Tramite.ExpedienteDocumentoAdjuntoFirmante|\
Tramite.ExpedienteDocumentoAdjuntoTemporal|\
Tramite.ExpedienteDocumentoFirmante|\
Tramite.ExpedienteDocumentoOrigen|\
Tramite.ExpedienteDocumentoOrigenAdjunto|\
Tramite.ExpedienteDocumentoOrigenDestino|\
Tramite.ExpedienteDocumentoOrigenDestinoAccion|\
Tramite.ExpedienteDocumentoOrigenDestinoTemporal|\
Tramite.ExpedienteDocumentoVisualizacion|\
Tramite.ExpedienteEnlazado|\
Tramite.ExpedienteSeguimiento|\
Tramite.NumeracionSeparada'
