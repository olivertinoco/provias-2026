set rowcount 0

-- select FechaCreacionAuditoria, *from tramite.expediente_historico_2024

select count(1) from tramite.expediente_historico_2022 e
WHERE e.FechaCreacionAuditoria >= '20250101' AND e.FechaCreacionAuditoria <  '20260101'

select count(1) from tramite.expediente_historico_2023 e
WHERE e.FechaCreacionAuditoria >= '20250101' AND e.FechaCreacionAuditoria <  '20260101'

select count(1) from tramite.expediente_historico_2024 e
WHERE e.FechaCreacionAuditoria >= '20250101' AND e.FechaCreacionAuditoria <  '20260101'

select count(1) from tramite.expediente_historico_2025 e
WHERE e.FechaCreacionAuditoria >= '20250101' AND e.FechaCreacionAuditoria <  '20260101'

select count(1) from tramite.expediente e
WHERE e.FechaCreacionAuditoria >= '20250101' AND e.FechaCreacionAuditoria <  '20260101'


return
select distinct year(FechaCreacionAuditoria) from tramite.expediente_historico_2022 order by 1
select distinct year(FechaCreacionAuditoria) from tramite.expediente_historico_2023 order by 1
select distinct year(FechaCreacionAuditoria) from tramite.expediente_historico_2024 order by 1
select distinct year(FechaCreacionAuditoria) from tramite.expediente_historico_2025 order by 1
select distinct year(FechaCreacionAuditoria) from tramite.expediente  order by 1



select distinct idperiodo, count(1)over(partition by idperiodo) from tramite.expediente_historico_2022 order by 1
select distinct idperiodo, count(1)over(partition by idperiodo) from tramite.expediente_historico_2023 order by 1
select distinct idperiodo, count(1)over(partition by idperiodo) from tramite.expediente_historico_2024 order by 1
select distinct idperiodo, count(1)over(partition by idperiodo) from tramite.expediente_historico_2025 order by 1
select distinct idperiodo, count(1)over(partition by idperiodo) from tramite.expediente  order by 1
