
insert into Tramite.ExpedienteDocumentoOrigen_Historico_2024
select t.* from Tramite.ExpedienteDocumentoOrigen t
WHERE t.FechaCreacionAuditoria >= '20240101'
    AND t.FechaCreacionAuditoria <  '20250101'
