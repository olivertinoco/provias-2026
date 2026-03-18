NOTA: OBJETOS A MODIFICAR QUE TIENE LAS TABLAS CATALOGO
======================================================
HAY QUE MODIFICAR EL NOMBRE DEL OBJETO U


SELECT
    OBJECT_SCHEMA_NAME(d.referencing_id) AS esquema,
    OBJECT_NAME(d.referencing_id) AS objeto,
    o.type_desc
FROM sys.sql_expression_dependencies d
JOIN sys.objects o
    ON d.referencing_id = o.object_id
WHERE
    d.referenced_entity_name = 'expediente'
    AND d.referenced_schema_name = 'tramite';



    --TRAMITE DOCUMENTAL
    select top(20) * from Tramite.ExpedienteArq where NumeroExpediente = '0167783' and EstadoAuditoria = 1
    select top(20) * from Tramite.ExpedienteDocumento where IdExpediente = '68672'  and EstadoAuditoria = 1

    --DATOS DEL EXPEDIENTE AL MOMENTO DE GUARDARLO
    select top(20) * from Tramite.ExpedienteDocumento order by IdExpedienteDocumento desc
    select top(20) * from Tramite.ExpedienteDocumentoOrigen order by IdExpedienteDocumentoOrigen desc
    select top(20) * from Tramite.ExpedienteDocumentoOrigenDestino order by IdExpedienteDocumentoOrigenDestino desc
    select top(20) * from Tramite.ExpedienteDocumentoOrigenDestinoAccion order by IdExpedienteDocumentoOrigenDestinoAccion desc
    select top(200) * from Tramite.visExpedienteCompleto

    --DATOS DE: ARCHIVOS ADJUNTOS DEL DOCUMENTO
    select top(5) * from Tramite.ExpedienteDocumentoAdjuntoTemporal order by IdExpedienteDocumentoAdjuntoTemporal desc
    --DATOS DE: DESTINATARIOS
    select top(5) * from Tramite.ExpedienteDocumentoOrigenDestinoTemporal order by IdExpedienteDocumentoOrigenDestinoTemporal desc
