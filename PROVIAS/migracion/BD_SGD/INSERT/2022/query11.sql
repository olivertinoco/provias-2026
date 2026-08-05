
insert into Tramite.ExpedienteDocumentoAdjunto_Historico_2022
select t.* from Tramite.ExpedienteDocumentoAdjunto t
WHERE t.FechaCreacionAuditoria >= '20220101'
    AND t.FechaCreacionAuditoria <  '20230101'
