
-- SELECT
--     fk.name AS foreign_key,
--     OBJECT_NAME(fk.parent_object_id) AS tabla_hija,
--     OBJECT_NAME(fk.referenced_object_id) AS tabla_padre
-- FROM sys.foreign_keys fk
-- WHERE fk.referenced_object_id = OBJECT_ID('tramite.ExpedienteBloqueado');


select*from mastertable('tramite.ExpedienteDocumentoVisualizacion')


select concat(object_schema_name(object_id), '.', object_name(object_id)) sp, create_date
from sys.procedures order by create_date desc


SELECT
    fk.name AS foreign_key,
    OBJECT_NAME(fk.parent_object_id) AS tabla_hija,
    OBJECT_NAME(fk.referenced_object_id) AS tabla_padre
FROM sys.foreign_keys fk
WHERE fk.referenced_object_id = OBJECT_ID('tramite.ExpedienteDocumentoVisualizacion')


-- select*from tramite.ExpedienteBloqueado_historico
-- select*from Tramite.ExpedienteBloqueadoHistorialResponsables_historico
-- select*from Tramite.ExpedienteBloqueadoPersonaVisualiza_historico

-- ALTER TABLE tramite.ExpedienteBloqueado
-- DROP CONSTRAINT fkIdExpedienteBloqueado;



-- OBSERVACIONES PARA que se corra antes que el query8

-- exec sys.sp_spaceused 'Tramite.ExpedienteBloqueadoPersonaVisualiza'
-- select*into Tramite.ExpedienteBloqueadoPersonaVisualiza_historico
-- from Tramite.ExpedienteBloqueadoPersonaVisualiza
-- delete Tramite.ExpedienteBloqueadoPersonaVisualiza


-- select*into tramite.ExpedienteBloqueado_historico from tramite.ExpedienteBloqueado

-- delete tramite.ExpedienteBloqueado


-- select*from tramite.ExpedienteBloqueado_historico
-- select*from Tramite.ExpedienteBloqueadoHistorialResponsables_historico
-- select*from Tramite.ExpedienteBloqueadoPersonaVisualiza_historico
