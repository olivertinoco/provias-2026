
insert into Tramite.NumeracionSeparada_Historico_2025
select t.* from Tramite.NumeracionSeparada t
WHERE t.FechaCreacionAuditoria >= '20250101'
    AND t.FechaCreacionAuditoria <  '20260101'
