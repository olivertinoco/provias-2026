
insert into Tramite.ExpedienteDevuelto_Historico_2025
select t.* from Tramite.ExpedienteDevuelto t
WHERE t.FechaCreacionAuditoria >= '20250101'
    AND t.FechaCreacionAuditoria <  '20260101'
