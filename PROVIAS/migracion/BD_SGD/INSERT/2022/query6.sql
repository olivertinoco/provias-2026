
insert into Tramite.ExpedienteDevuelto_Historico_2022
select t.* from Tramite.ExpedienteDevuelto t
WHERE t.FechaCreacionAuditoria >= '20220101'
    AND t.FechaCreacionAuditoria <  '20230101'
