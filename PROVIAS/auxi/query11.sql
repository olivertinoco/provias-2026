declare @Objeto varchar(200) = 'expediente'

SELECT distinct
    Referenciado = @Objeto,
    EsquemaReferenciador =
        OBJECT_SCHEMA_NAME(d.referencing_id),
    ObjetoReferenciador =
        OBJECT_NAME(d.referencing_id),
    TipoObjeto = o.type_desc,
    BaseDatosReferenciada = d.referenced_database_name,
    EsquemaReferenciado = d.referenced_schema_name,
    ObjetoReferenciado = d.referenced_entity_name
FROM sys.sql_expression_dependencies d
INNER JOIN sys.objects o
    ON o.object_id = d.referencing_id
WHERE d.referenced_entity_name = @Objeto
ORDER BY EsquemaReferenciador, ObjetoReferenciador;
