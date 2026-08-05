
insert into Tramite.ExpedienteDevuelto_Historico_2023
select t.* from Tramite.ExpedienteDevuelto t
WHERE t.FechaCreacionAuditoria >= '20230101'
    AND t.FechaCreacionAuditoria <  '20240101'
