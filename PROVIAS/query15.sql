-- select top 0 cast(null as varchar(max)) collate database_default dato into #tmp001_usos
-- declare @data varchar(max) =(
-- select concat('select*from(values(''', replace(dato, '|', '''),('''), '''))t(dato)')
-- from(values('\
-- Tramite.Catalogo|\
-- General.Empresa|\
-- General.Area|\
-- General.Cargo|\
-- General.Persona\
-- '))t(dato))
-- insert into #tmp001_usos exec(@data)
-- select @data = (select ';select*from dbo.mastertable(''', dato, ''')'
-- from #tmp001_usos
-- for xml path, type).value('.','varchar(max)')
-- exec(@data)


-- return
-- select distinct idperiodo,  year(FechaCreacionAuditoria) from tramite.expediente


set rowcount 0
set language english

-- select*from Tramite.SerieDocumentalExpediente -- 2 reg



select t.NTFechaExpediente, t.HoraExpediente, t.idperiodo, t.FechaCreacionAuditoria
from tramite.Expediente t
cross apply tramite.ExpedienteDocumento tt
cross apply tramite.ExpedienteDocumentoOrigen ttt
cross apply tramite.ExpedienteDocumentoOrigenDestino tttt
cross apply(values(1),(2))sr(IdSerie)
cross apply(values(4),(5))ca(IdCatal)
where t.IdExpediente = tt.IdExpediente and t.ExpedienteAnulado = 0 and t.EstadoAuditoria = 1 and t.IdSerieDocumentalExpediente = sr.IdSerie
and tt.IdExpedienteDocumento = ttt.IdExpedienteDocumento and tt.EstadoAuditoria = 1
and ttt.IdExpedienteDocumentoOrigen = tttt.IdExpedienteDocumentoOrigen and ttt.EstadoAuditoria = 1 and tttt.EstadoAuditoria = 1
and tttt.IdCatalogoSituacionMovimientoDestino = ca.IdCatal and isnull(tttt.IdAreaDestino, 0) != 0


and left(convert(varchar, t.FechaCreacionAuditoria, 23),7) = '2026-02'
