
insert into Tramite.ExpedienteDocumentoOrigenAdjunto_Historico_2025
select t.* from Tramite.ExpedienteDocumentoOrigenAdjunto t
WHERE t.FechaCreacionAuditoria >= '20250101'
    AND t.FechaCreacionAuditoria <  '20260101'
