declare @procedures varchar(500)
-- = 'exec Tramite.paListarExpedientePendienteEspecialistaV7'
= 'Tramite.paListarExpedienteMesaParteDespachadosV1'
-- = 'Tramite.paListarExpedienteMesaParteDespachadosV1'
-- = 'exec Tramite.paListarExpedientePendienteJefaturaPorRecibirFosCad'

declare
    @pIdArea int =116,
    @pIdUsuarioAuditoria int=56784,
    @pCampoOrdenado varchar(50) = null,
    @pTipoOrdenacion varchar(4) = null,
    @pNumeroPagina INT =1,
    @pDimensionPagina  INT =10,
    @pBusquedaGeneral varchar(100)='000228'


select @pIdArea pIdArea, @pIdUsuarioAuditoria pIdUsuarioAuditoria, @pBusquedaGeneral pBusquedaGeneral into #tmp001_datos

select*from #tmp001_datos






-- SELECT
--     p.parameter_id,
--     replace(p.name, '@', '') AS parametro,
--     t.name AS tipo_dato,
--     p.max_length,
--     p.precision,
--     p.scale,
--     p.is_output
--     -- into #tmp001_reg_param22
-- FROM sys.parameters p, sys.types t
-- WHERE p.user_type_id = t.user_type_id
-- and p.object_id = OBJECT_ID(@procedures)
-- ORDER BY p.parameter_id


select distinct concat(esquema, '.', store)
from(select object_schema_name(object_id) esquema, object_name(object_id) store
FROM sys.parameters WHERE name in ('@pNumeroPagina', '@pDimensionPagina'))t where esquema = 'tramite'
