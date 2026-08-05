
insert into Tramite.ExpedienteSeguimiento_Historico_2022
select t.* from Tramite.ExpedienteSeguimiento t
WHERE t.FechaCreacionAuditoria >= '20220101'
    AND t.FechaCreacionAuditoria <  '20230101'
