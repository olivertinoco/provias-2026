set rowcount 0
set nocount on

-- select FechaCreacionAuditoria, *from tramite.expediente_historico_2024
select top 0
cast(null as int) ano,
cast(null as int) cantReg into #tmp001_cantidades

insert into #tmp001_cantidades
select 2022, count(1) from tramite.expediente e
WHERE e.FechaCreacionAuditoria >= '20220101' AND e.FechaCreacionAuditoria <  '20230101'

insert into #tmp001_cantidades
select 2023, count(1) from tramite.expediente e
WHERE e.FechaCreacionAuditoria >= '20230101' AND e.FechaCreacionAuditoria <  '20240101'

insert into #tmp001_cantidades
select 2024, count(1) from tramite.expediente e
WHERE e.FechaCreacionAuditoria >= '20240101' AND e.FechaCreacionAuditoria <  '20250101'

insert into #tmp001_cantidades
select 2025, count(1) from tramite.expediente e
WHERE e.FechaCreacionAuditoria >= '20250101' AND e.FechaCreacionAuditoria <  '20260101'

insert into #tmp001_cantidades
select 2026, count(1) from tramite.expediente e
WHERE e.FechaCreacionAuditoria >= '20260101' AND e.FechaCreacionAuditoria <  '20270101'

select*from #tmp001_cantidades order by ano

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
