if exists(select 1 from sys.sysobjects where id = object_id('dbo.udf_objeto_referenciados', 'if'))
drop function dbo.udf_objeto_referenciados
go
create function dbo.udf_objeto_referenciados(
@Objeto SYSNAME
)returns table as return(
    select concat(
        ';SELECT DISTINCT o.type, CONCAT(s.name,''.'',o.name) tablas, ''', @Objeto, ''' procedure_name
        FROM sys.sql_expression_dependencies d INNER JOIN sys.objects o ON d.referenced_id = o.object_id
        INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
        WHERE d.referencing_id = OBJECT_ID(''', @Objeto, ''')
        ORDER BY tablas'
    ) referencias
)
go
set nocount on
select top 0
cast(null as varchar(2)) collate database_default type,
cast(null as varchar(300)) collate database_default objeto,
cast(null as varchar(300)) collate database_default procedure_name into #tmp001_objetos_en_procedures
select concat(schema_name(schema_id),'.', name) procedimiento into #tmp001_procedures
from sys.procedures
where concat(schema_name(schema_id),'.', name)
= 'tramite.paListarExpedientePendienteEspecialistaTodos'


declare @datos varchar(max)
select @datos = 'select referencias from #tmp001_procedures t cross apply dbo.udf_objeto_referenciados(t.procedimiento)'

select top 0 cast(null as varchar(1000)) dato into #tmp001_datosvarios
insert into #tmp001_datosvarios exec(@datos)
select @datos = (select dato from #tmp001_datosvarios
for xml path, type).value('.','varchar(max)')
insert into #tmp001_objetos_en_procedures exec(@datos)

select procedure_name, type, objeto
from #tmp001_objetos_en_procedures
order by procedure_name, type, objeto
