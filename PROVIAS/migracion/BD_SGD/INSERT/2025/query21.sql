insert into Tramite.Expediente_Historico_2025
select*from Tramite.Expediente t
WHERE t.FechaCreacionAuditoria >= '20250101'
    AND t.FechaCreacionAuditoria <  '20260101'

insert into Tramite.ExpedienteDocumento_Historico_2025
select t.* from Tramite.ExpedienteDocumento t
WHERE t.FechaCreacionAuditoria >= '20250101'
    AND t.FechaCreacionAuditoria <  '20260101'

insert into Tramite.ExpedienteDocumentoOrigen_Historico_2025
select t.* from Tramite.ExpedienteDocumentoOrigen t
WHERE t.FechaCreacionAuditoria >= '20250101'
    AND t.FechaCreacionAuditoria <  '20260101'

insert into Tramite.ExpedienteDocumentoOrigenDestino_Historico_2025
select t.* from Tramite.ExpedienteDocumentoOrigenDestino t
WHERE t.FechaCreacionAuditoria >= '20250101'
    AND t.FechaCreacionAuditoria <  '20260101'






insert into Tramite.ExpedienteDevuelto_Historico_2025
select t.* from Tramite.ExpedienteDevuelto t
WHERE t.FechaCreacionAuditoria >= '20250101'
    AND t.FechaCreacionAuditoria <  '20260101'

insert into Tramite.ExpedienteEnlazado_Historico_2025
select t.* from Tramite.ExpedienteEnlazado t
WHERE t.FechaCreacionAuditoria >= '20250101'
    AND t.FechaCreacionAuditoria <  '20260101'

insert into Tramite.ExpedienteSeguimiento_Historico_2025
select t.* from Tramite.ExpedienteSeguimiento t
WHERE t.FechaCreacionAuditoria >= '20250101'
    AND t.FechaCreacionAuditoria <  '20260101'

insert into Tramite.NumeracionSeparada_Historico_2025
select t.* from Tramite.NumeracionSeparada t
WHERE t.FechaCreacionAuditoria >= '20250101'
    AND t.FechaCreacionAuditoria <  '20260101'





insert into Tramite.ExpedienteDocumentoFirmante_Historico_2025
select t.* from Tramite.ExpedienteDocumentoFirmante t
WHERE t.FechaCreacionAuditoria >= '20250101'
    AND t.FechaCreacionAuditoria <  '20260101'

insert into Tramite.ExpedienteDocumentoAdjunto_Historico_2025
select t.* from Tramite.ExpedienteDocumentoAdjunto t
WHERE t.FechaCreacionAuditoria >= '20250101'
    AND t.FechaCreacionAuditoria <  '20260101'

insert into Tramite.ExpedienteDocumentoAdjuntoFirmante_Historico_2025
select t.* from Tramite.ExpedienteDocumentoAdjuntoFirmante t
WHERE t.FechaCreacionAuditoria >= '20250101'
    AND t.FechaCreacionAuditoria <  '20260101'

insert into Tramite.ExpedienteDocumentoAdjuntoTemporal_Historico_2025
select t.* from Tramite.ExpedienteDocumentoAdjuntoTemporal t
WHERE t.FechaCreacionAuditoria >= '20250101'
    AND t.FechaCreacionAuditoria <  '20260101'





insert into Tramite.ExpedienteDocumentoOrigenAdjunto_Historico_2025
select t.* from Tramite.ExpedienteDocumentoOrigenAdjunto t
WHERE t.FechaCreacionAuditoria >= '20250101'
    AND t.FechaCreacionAuditoria <  '20260101'





insert into Tramite.ExpedienteDocumentoOrigenDestinoAccion_Historico_2025
select t.* from Tramite.ExpedienteDocumentoOrigenDestinoAccion t
WHERE t.FechaCreacionAuditoria >= '20250101'
    AND t.FechaCreacionAuditoria <  '20260101'

insert into Tramite.ExpedienteDocumentoOrigenDestinoTemporal_Historico_2025
select t.* from Tramite.ExpedienteDocumentoOrigenDestinoTemporal t
WHERE t.FechaCreacionAuditoria >= '20250101'
    AND t.FechaCreacionAuditoria <  '20260101'
