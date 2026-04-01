-- sys.dm_db_missing_index_details

FECHA SIN SEGUNDOS NI MILISEGUNDOS:
select dateadd(mi, datediff(mi, 0, getdate()), 0)

declare @tabla varchar(max)='\
tramite.expediente|\
tramite.expedienteDocumento|\
tramite.expedienteDocumentoOrigen|\
tramite.expedienteDocumentoOrigenDestino'

select top 0 cast(null as varchar(200)) collate database_default tabla into #tmp001_tabla
select @tabla = concat('select*from(values(''', replace(@tabla,'|', '''),('''), '''))t(a)')
insert into #tmp001_tabla exec(@tabla)

select*from #tmp001_tabla

select concat(object_schema_name(t.object_id),'.',object_name(t.object_id)) tabla, tt.name, tt.column_id, tt.max_length
from sys.fulltext_index_columns t, sys.columns tt, #tmp001_tabla pp
where t.object_id = tt.object_id and t.column_id = tt.column_id and t.object_id = object_id(pp.tabla)


SELECT concat(object_schema_name(i.object_id),'.',object_name(i.object_id)) tabla,
    i.name AS index_name,
    c.name AS column_name,
    ic.key_ordinal,
    ic.is_included_column
FROM sys.indexes i
INNER JOIN sys.index_columns ic
    ON i.object_id = ic.object_id
   AND i.index_id = ic.index_id
INNER JOIN sys.columns c cross apply #tmp001_tabla pp
    ON ic.object_id = c.object_id
   AND ic.column_id = c.column_id
WHERE i.object_id = OBJECT_ID(pp.tabla)
ORDER BY i.object_id, i.name, ic.key_ordinal;


-- set statistics xml on
-- set statistics io on
-- set statistics time on





-- SELECT *
-- FROM sys.dm_db_missing_index_details;

-- NO HAY PERMISO PARA USAR ESTAS VISTAS DE TABLA
-- SELECT
--     i.name,
--     s.user_seeks,
--     s.user_scans,
--     s.user_lookups,
--     s.user_updates
-- FROM sys.indexes i
-- LEFT JOIN sys.dm_db_index_usage_stats s
--     ON i.object_id = s.object_id
--    AND i.index_id = s.index_id
-- WHERE i.object_id = OBJECT_ID('Tramite.Expediente');
