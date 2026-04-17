declare @data varchar(max)='\
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
Tramite.ExpedienteEnlazado|\
Tramite.ExpedienteSeguimiento|\
Tramite.NumeracionSeparada'

set nocount on
select top 0
    cast(null as int) anno,
    cast(null as varchar(100)) tabla,
    cast(null as int) nroReg into #tmp001_datos

declare @annio int = 2022, @iteracion varchar(max)

while @annio < 2026 begin
    select @iteracion = ''
    select @iteracion =(select
    ';insert into #tmp001_datos select ''', @annio, ''',''', value, ''', count(1) from ', value,
    ' where year(FechaCreacionAuditoria) = ', @annio,
    ' and FechaActualizacionAuditoria is not null',
    ' and FechaActualizacionAuditoria != ''''',
    ' and year(FechaActualizacionAuditoria) != year(FechaCreacionAuditoria)'
    from dbo.udf_split(@data, default)
    for xml path, type).value('.','varchar(max)')
    exec(@iteracion)

    waitfor delay '00:00:2'
    select @annio += 1
end

select*from #tmp001_datos

-- select count(1) from tramite.expediente where fechacreacionauditoria
-- between convert(datetime, '2026-04-01 12:14:33', 120) and convert(datetime, '2026-04-12 10:20:14', 120)

-- select count(1)over(), fechacreacionauditoria
-- from tramite.expediente where cast(fechacreacionauditoria as date) between '2026-04-01' and '2026-04-12'

return
select  count(1)
from Tramite.Expediente
where year(FechaCreacionAuditoria) = 2023
and FechaActualizacionAuditoria is not null
and FechaActualizacionAuditoria != ''
and year(FechaActualizacionAuditoria) != year(FechaCreacionAuditoria)



return
-- FechaActualizacionAuditoria


-- select*from sys.sysobjects where id = object_id('Tramite.ExpedienteBloqueado')
-- select*from sys.sysobjects where id = object_id('Tramite.ExpedienteBloqueadoHistorialResponsables')
-- select*from sys.sysobjects where id = object_id('Tramite.ExpedienteBloqueadoPersonaVisualiza')

-- exec sys.sp_spaceused 'Tramite.ExpedienteBloqueado'
-- exec sys.sp_spaceused 'Tramite.ExpedienteBloqueadoHistorialResponsables'
-- exec sys.sp_spaceused 'Tramite.ExpedienteBloqueadoPersonaVisualiza'


select concat(schema_name(schema_id), '.', name)
from sys.procedures where schema_id = 9 order by name


return

SELECT
    OBJECT_SCHEMA_NAME(d.referencing_id) AS esquema,
    OBJECT_NAME(d.referencing_id) AS objeto,
    o.type_desc
FROM sys.sql_expression_dependencies d
JOIN sys.objects o
    ON d.referencing_id = o.object_id
WHERE
    d.referenced_entity_name = 'ExpedienteBloqueado'
    AND d.referenced_schema_name = 'tramite';




SELECT
    OBJECT_SCHEMA_NAME(d.referencing_id) AS esquema,
    OBJECT_NAME(d.referencing_id) AS objeto,
    o.type_desc
FROM sys.sql_expression_dependencies d
JOIN sys.objects o
    ON d.referencing_id = o.object_id
WHERE
    d.referenced_entity_name = 'ExpedienteBloqueadoHistorialResponsables'
    AND d.referenced_schema_name = 'tramite';



    SELECT
        OBJECT_SCHEMA_NAME(d.referencing_id) AS esquema,
        OBJECT_NAME(d.referencing_id) AS objeto,
        o.type_desc
    FROM sys.sql_expression_dependencies d
    JOIN sys.objects o
        ON d.referencing_id = o.object_id
    WHERE
        d.referenced_entity_name = 'ExpedienteBloqueadoPersonaVisualiza'
        AND d.referenced_schema_name = 'tramite';
