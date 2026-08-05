
insert into Tramite.ExpedienteDocumentoOrigen_Historico_2022
select t.* from Tramite.ExpedienteDocumentoOrigen t
WHERE t.FechaCreacionAuditoria >= '20220101'
    AND t.FechaCreacionAuditoria <  '20230101'
