-- select*from dbo.mastertable('Tramite.Expediente')
-- select*from dbo.mastertable('Tramite.ExpedienteDocumento')
use tempdb
go

if exists(select 1 from sys.sysobjects where id = object_id('mastertable','if'))
drop function mastertable
go
create function mastertable(
    @par_nombreTabla varchar(max)
)returns table as return(
  select top 1000 convert(varchar(50), @par_nombreTabla) tabla,
  convert(varchar(60), c.name) name,
  c.column_id,
  convert(varchar(10),type_name(c.system_type_id)) type,
  c.max_length,
  case
    when type_name(c.system_type_id) in ('decimal','numeric','float')
    then c.precision else null end precision,
  case
    when type_name(c.system_type_id) in ('decimal','numeric')
    then c.scale else null end scale,
  convert(varchar,c.collation_name) collation_name,
  c.is_nullable, c.is_identity, c.default_object_id, i.is_primary_key
  from sys.columns c outer apply(select coalesce((
  select i.is_primary_key from sys.index_columns ic cross apply sys.indexes i
  where  i.object_id       = ic.object_id and
         i.index_id        = ic.index_id  and
         i.is_primary_key  = 1            and
         ic.object_id      = c.object_id  and
         ic.column_id      = c.column_id), 0) is_primary_key)i
  where c.object_id = object_id(@par_nombreTabla, 'U') order by c.column_id
)
go
