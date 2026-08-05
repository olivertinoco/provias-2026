
insert into Tramite.ExpedienteDevuelto_Historico_2024
select t.* from Tramite.ExpedienteDevuelto t
WHERE t.FechaCreacionAuditoria >= '20240101'
    AND t.FechaCreacionAuditoria <  '20250101'
