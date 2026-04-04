declare @tablas varchar(max) = '\
Tramite.Expediente|\
Tramite.ExpedienteDevuelto|\
Tramite.ExpedienteDocumento|\
Tramite.ExpedienteDocumentoAdjunto|\
Tramite.ExpedienteDocumentoAdjuntoFirmante|\
Tramite.ExpedienteDocumentoAdjuntoTemporal|\
Tramite.ExpedienteDocumentoFirmante|\
Tramite.ExpedienteDocumentoOrigen|\
Tramite.ExpedienteDocumentoOrigenAdjunto|\
Tramite.ExpedienteDocumentoOrigenDestino|\
Tramite.ExpedienteDocumentoOrigenDestinoAccion|\
Tramite.ExpedienteDocumentoOrigenDestinoTemporal|\
Tramite.ExpedienteDocumentoVisualizacion|\
Tramite.ExpedienteEnlazado|\
Tramite.ExpedienteSeguimiento|\
Tramite.NumeracionSeparada'

select top 0
    cast(null as varchar(50)) tabla,
    cast(null as varchar(50)) name,
    cast(null as varchar(50)) type,
    cast(null as int) max_length,
    cast(null as varchar(50)) collation_name,
    cast(null as int) column_id into #tmp001_tablas


select @tablas = (select
'select tabla, name, type, max_length, collation_name, column_id from dbo.mastertable(''',
value, ''')order by column_id;'
from dbo.udf_split(@tablas, default)
for xml path, type).value('.','varchar(max)')
insert into #tmp001_tablas exec(@tablas)


select concat('GO delete t from ', tabla,
' t where year(t.FechaCreacionAuditoria) != year(getdate());')
from #tmp001_tablas where column_id = 1
order by tabla


-- select concat('GO insert into ', tabla, '_Historico  select*from ', tabla)
-- from #tmp001_tablas where column_id = 1
-- order by tabla



-- select concat(
-- case column_id when 1 then concat(');GO create table ', tabla, '_Historico (') end,
-- name,
-- concat(' ', rtrim(type)),
-- case column_id when 1 then ' not null primary key,' end,
-- case when collation_name is not null then concat(' (', max_length, '),') when column_id != 1 then ',' end)
-- from #tmp001_tablas
-- order by tabla, column_id
