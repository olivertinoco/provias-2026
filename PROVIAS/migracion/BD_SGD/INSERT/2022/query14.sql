
insert into Tramite.ExpedienteDocumentoOrigenAdjunto_Historico_2022
select t.* from Tramite.ExpedienteDocumentoOrigenAdjunto t
WHERE t.FechaCreacionAuditoria >= '20220101'
    AND t.FechaCreacionAuditoria <  '20230101'
