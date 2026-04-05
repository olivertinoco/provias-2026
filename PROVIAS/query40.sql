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

create table #tmp001_space(
name varchar(50) collate database_default,
rows int,
reserved varchar(20) collate database_default,
data varchar(20) collate database_default,
index_size varchar(20) collate database_default,
unused varchar(20) collate database_default)



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

-- select @tablas = (select ';insert into #tmp001_space exec sys.sp_spaceused ''', tabla, ''''
-- from(select distinct tabla
-- from #tmp001_tablas)t
-- for xml path, type).value('.','varchar(max)')
-- exec(@tablas)
-- select*from #tmp001_space order by rows desc

set nocount on

-- NOTA: EXCLUIR DEL DELETE
-- SUS CAMPOS FECHA DE AUDITORIA ESTAN EN NULL
-- ================================================
select count(1) from Tramite.ExpedienteDocumentoAdjuntoFirmante
where isnull(FechaCreacionAuditoria, FechaActualizacionAuditoria) is null

-- TABLA EXCLUIDA TEMPORALMENTE X SUS 36 MILLONES DE REGISTROS
-- ===========================================================
-- Tramite.ExpedienteDocumentoVisualizacion
-- Tramite.ExpedienteDocumentoVisualizacion_Historico


select @tablas = (select
'select ''', tabla, ''', count(1) from ', tabla, ' where FechaCreacionAuditoria is null;'
from(select distinct tabla
from #tmp001_tablas)t
for xml path, type).value('.','varchar(max)')
select(@tablas)

-- select concat('GO delete t from ', tabla,
-- ' t where year(t.FechaCreacionAuditoria) != year(getdate());')
-- from #tmp001_tablas where column_id = 1
-- order by tabla


-- select concat('GO insert into ', tabla, '_Historico  select*from ', tabla)
-- from #tmp001_tablas where column_id = 1
-- order by tabla
