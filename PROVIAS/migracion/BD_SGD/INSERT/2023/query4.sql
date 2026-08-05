
insert into Tramite.ExpedienteDocumentoOrigen_Historico_2023
select t.* from Tramite.ExpedienteDocumentoOrigen t
WHERE t.FechaCreacionAuditoria >= '20230101'
    AND t.FechaCreacionAuditoria <  '20240101'
