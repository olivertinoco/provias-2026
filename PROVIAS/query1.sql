create table #tmp001_tablas(
id int identity,
schemas varchar(20) collate database_default,
name varchar(50) collate database_default,
rows int,
reserved varchar(20) collate database_default,
data varchar(20) collate database_default,
index_size varchar(20) collate database_default,
unused varchar(20) collate database_default)

set nocount on
declare @data varchar(max)=(
select (select ';insert into #tmp001_tablas(name,rows,reserved,data,index_size,unused)\
exec sys.sp_spaceused ''', schema_name(schema_id), '.', name, ''';\
update t set schemas = ''', schema_name(schema_id), ''' \
from #tmp001_tablas t where id = scope_identity()'
from sys.tables order by 1,2
for xml path, type).value('.','varchar(max)'))
exec(@data)

-- select*from #tmp001_tablas order by rows desc

if exists(select 1 from sys.sysobjects where id = object_id('dbo.udf_objeto_referenciados', 'if'))
drop function dbo.udf_objeto_referenciados
go
create function dbo.udf_objeto_referenciados(
@Objeto SYSNAME
)returns table as return(
    select concat(';SELECT DISTINCT o.type, concat(r.referenced_schema_name, ''.'', r.referenced_entity_name) tablas, ''', @Objeto, ''' procedure_name \
    FROM sys.dm_sql_referenced_entities(''', @Objeto, ''',''OBJECT'') r, sys.objects o, sys.schemas s \
    WHERE r.referenced_class_desc = ''OBJECT_OR_COLUMN'' \
    and r.referenced_minor_name IS NULL \
    and r.referenced_entity_name = o.name \
    and r.referenced_schema_name = s.name \
    and o.schema_id = s.schema_id ORDER BY tablas') referencias
)
go


declare @datos varchar(max) =
'Tramite.paListarExpedienteMesaParteDespachadosV1|\
Tramite.paListarExpedientePendienteEspecialistaPorRecibir|\
Tramite.paListarExpedienteBusquedaPendiente|\
Tramite.paListarPendientesPorAreaV1|\
Tramite.paListarExpedienteMesaParteDespachadosVirtualesV1|\
General.paListarComboAutocompleteMesaParte|\
Tramite.paListarDocumentoPendienteEspecialistaV1|\
Tramite.paListarDocumentoPendienteJefaturaV1|\
Tramite.paListarCargoOrigenBusquedaExpediente|\
Tramite.paListarComboAutocompleteDestinatariosJefaturaV1|\
[Tramite].[paListarPeriodoBusquedaExpediente]|\
[Tramite].[paListarComboAreaPorAreaPadrePendientes]|\
[Tramite].[paListarComboPersonaPorAreaPadrePendientes]|\



-- declare @datos varchar(max) =
-- 'Tramite.paListarExpedientePendienteEspecialistaV7|\
-- Tramite.paListarExpedientePendienteEspecialistaPorRecibirConBusqueda|\
-- Tramite.paListarExpedientePendienteEspecialistaTodos|\
-- Tramite.paListarExpedientePendienteEspecialistaTodosConBusqueda|\
-- Tramite.paListarExpedientePendienteEspecialistaMisExpedientes|\
-- Tramite.paListarExpedientePendienteEspecialistaReenviados|\
-- Tramite.paListarExpedientePendienteEspecialistaArchivados|\
-- Tramite.paListarExpedientePendienteEspecialistaSeguimiento|\
-- Tramite.paListarExpedientePendienteEspecialistaCreados|\
-- Tramite.paObtenerEstadosExpedientesEspecialista'


select @datos = concat('select referencias from(values(''', replace(@datos,'|','''),('''), '''))t(obj)cross apply dbo.udf_objeto_referenciados(t.obj)')
select top 0 cast(null as varchar(1000)) dato into #tmp001_datosvarios
insert into #tmp001_datosvarios exec(@datos)
select @datos = (select dato from #tmp001_datosvarios
for xml path, type).value('.','varchar(max)')
exec(@datos)



-- DECLARE @Objeto SYSNAME =
-- 'Tramite.paListarExpedientePendienteEspecialistaV7';
-- SELECT DISTINCT
--     o.type, concat(r.referenced_schema_name, '.', r.referenced_entity_name) tablas, @Objeto procedure_name
-- FROM sys.dm_sql_referenced_entities(@Objeto, 'OBJECT') r, sys.objects o, sys.schemas s
-- WHERE r.referenced_class_desc = 'OBJECT_OR_COLUMN'
-- and r.referenced_minor_name IS NULL
-- and r.referenced_entity_name = o.name
-- and r.referenced_schema_name = s.name
-- and o.schema_id = s.schema_id
-- ORDER BY tablas

-- select text  from sys.syscomments where id = object_id('Tramite.fnObtenerOrigenInicialDocumento','fn')
