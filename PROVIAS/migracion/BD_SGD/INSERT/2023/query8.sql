
insert into Tramite.ExpedienteSeguimiento_Historico_2023
select t.* from Tramite.ExpedienteSeguimiento t
WHERE t.FechaCreacionAuditoria >= '20230101'
    AND t.FechaCreacionAuditoria <  '20240101'
