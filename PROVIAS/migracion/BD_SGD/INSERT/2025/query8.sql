
insert into Tramite.ExpedienteSeguimiento_Historico_2025
select t.* from Tramite.ExpedienteSeguimiento t
WHERE t.FechaCreacionAuditoria >= '20250101'
    AND t.FechaCreacionAuditoria <  '20260101'
