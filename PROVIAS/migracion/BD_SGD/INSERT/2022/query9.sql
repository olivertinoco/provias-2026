
insert into Tramite.NumeracionSeparada_Historico_2022
select t.* from Tramite.NumeracionSeparada t
WHERE t.FechaCreacionAuditoria >= '20220101'
    AND t.FechaCreacionAuditoria <  '20230101'
