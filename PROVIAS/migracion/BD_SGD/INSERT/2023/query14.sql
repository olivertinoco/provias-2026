
insert into Tramite.ExpedienteDocumentoOrigenAdjunto_Historico_2023
select t.* from Tramite.ExpedienteDocumentoOrigenAdjunto t
WHERE t.FechaCreacionAuditoria >= '20230101'
    AND t.FechaCreacionAuditoria <  '20240101'
