
insert into Tramite.ExpedienteDocumento_Historico_2022
select t.* from Tramite.ExpedienteDocumento t
WHERE t.FechaCreacionAuditoria >= '20220101'
    AND t.FechaCreacionAuditoria <  '20230101'
