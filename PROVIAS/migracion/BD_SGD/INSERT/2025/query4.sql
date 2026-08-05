
insert into Tramite.ExpedienteDocumentoOrigen_Historico_2025
select t.* from Tramite.ExpedienteDocumentoOrigen t
WHERE t.FechaCreacionAuditoria >= '20250101'
    AND t.FechaCreacionAuditoria <  '20260101'
