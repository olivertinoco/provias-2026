
insert into Tramite.ExpedienteDocumentoAdjunto_Historico_2024
select t.* from Tramite.ExpedienteDocumentoAdjunto t
WHERE t.FechaCreacionAuditoria >= '20240101'
    AND t.FechaCreacionAuditoria <  '20250101'
