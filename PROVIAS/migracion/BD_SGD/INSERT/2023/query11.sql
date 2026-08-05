
insert into Tramite.ExpedienteDocumentoAdjunto_Historico_2023
select t.* from Tramite.ExpedienteDocumentoAdjunto t
WHERE t.FechaCreacionAuditoria >= '20230101'
    AND t.FechaCreacionAuditoria <  '20240101'
