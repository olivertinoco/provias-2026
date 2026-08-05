
insert into Tramite.ExpedienteDocumentoAdjunto_Historico_2025
select t.* from Tramite.ExpedienteDocumentoAdjunto t
WHERE t.FechaCreacionAuditoria >= '20250101'
    AND t.FechaCreacionAuditoria <  '20260101'
