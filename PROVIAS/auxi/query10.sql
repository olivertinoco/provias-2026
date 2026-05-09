create table #tmp001_tablas(
id int identity,
schemas varchar(20) collate database_default,
name varchar(50) collate database_default,
rows int,
reserved varchar(20) collate database_default,
data varchar(20) collate database_default,
index_size varchar(20) collate database_default,
unused varchar(20) collate database_default)

select top 0
cast(null as varchar(20)) collate database_default schemas,
cast(null as varchar(50)) collate database_default name,
cast(null as int) nrocampo into #tmp002_tablas

set nocount on
declare @data varchar(max)=(
select (select ';insert into #tmp001_tablas(name,rows,reserved,data,index_size,unused)\
exec sys.sp_spaceused ''', schema_name(schema_id), '.', name, ''';\
update t set schemas = ''', schema_name(schema_id), ''' \
from #tmp001_tablas t where id = scope_identity()'
from sys.tables order by 1,2
for xml path, type).value('.','varchar(max)'))
exec(@data)

select @data = (select
'insert into #tmp002_tablas select distinct object_schema_name(object_id), object_name(object_id), count(1)over() from '+
'sys.columns where object_id=object_id(''', schema_name(schema_id), '.', name, ''');'
from sys.tables
for xml path, type).value('.','varchar(max)')
exec(@data)

select t.*, tt.nrocampo from #tmp001_tablas t, #tmp002_tablas tt
where t.schemas = tt.schemas and t.name = tt.name
order by t.rows desc
