
insert into Tramite.NumeracionSeparada_Historico_2023
select t.* from Tramite.NumeracionSeparada t
WHERE t.FechaCreacionAuditoria >= '20230101'
    AND t.FechaCreacionAuditoria <  '20240101'
