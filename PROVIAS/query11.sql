declare @procedures varchar(500)
-- = 'exec Tramite.paListarExpedientePendienteEspecialistaV7'
= 'Tramite.paListarExpedientePendienteJefaturaV8FosCad'
-- = 'Tramite.paListarExpedienteMesaParteDespachadosV1'
-- = 'exec Tramite.paListarExpedientePendienteJefaturaPorRecibirFosCad'


revisa tus actividades para tu segundo entregable: Actividades para el 2do entregable
************************************************************************************
Tramite.paListarExpedientePendienteEspecialistaCreados
Tramite.paObtenerEstadosExpedientesEspecialista
Tramite.paListarExpedientePendienteJefaturaPorRecibirConBusqueda
Tramite.paListarExpedientePendienteJefaturaTodosConBusquedaFosCad
Tramite.paListarExpedientePendienteEspecialistaPorRecibir

Modificar todos los objetos de base de datos involucrados en el proceso de trámite documentario agregándole la columna: Período (Año)

Crear el flujo de tablas temporales con rangos de tiempo para optimizar la vista de la paginación de las grillas del SGD



set statistics xml on
set statistics io on
set statistics time on





set statistics xml off
set statistics io off
set statistics time off


-- select concat(object_schema_name(object_id), '.', object_name(object_id)) sp, create_date from sys.procedures order by create_date desc
go



SELECT
    p.parameter_id,
    replace(p.name, '@', '') AS parametro,
    t.name AS tipo_dato,
    p.max_length,
    p.precision,
    p.scale,
    p.is_output into #tmp001_reg_param22
FROM sys.parameters p, sys.types t
WHERE p.user_type_id = t.user_type_id and p.object_id = OBJECT_ID(@procedures)
ORDER BY p.parameter_id




select concat(stuff((select ',@', t.parametro
from #tmp001_reg_param22 t
order by t.parameter_id
for xml path, type).value('.','varchar(max)'),1,1,'select*from(values('),'))t(', t.dato,')')
from(
    select stuff((select ',a',parameter_id
    from #tmp001_reg_param22 order by parameter_id
    for xml path, type).value('.','varchar(max)'),1,1,'') dato
)t


exec Tramite.paListarExpedienteMesaParteDespachadosV1
@pIdArea=116,
@pIdUsuarioAuditoria=56784,
@pCampoOrdenado=NULL,
@pTipoOrdenacion=NULL,
@pNumeroPagina=1,
@pDimensionPagina=10,
@pBusquedaGeneral='000228'


exec Tramite.paListarExpedienteMesaParteDespachadosV1
@pIdArea=116,
@pIdUsuarioAuditoria=56784,
@pCampoOrdenado=NULL,
@pTipoOrdenacion=NULL,
@pNumeroPagina=1,
@pDimensionPagina=10,
@pBusquedaGeneral='000228'

return

-- set rowcount 100000
-- select*from tramite.ExpedienteDocumento where contains(NFechaDocumento, '000228')

set rowcount 10

select NumeroDocumento
from tramite.ExpedienteDocumento ed
-- where ED.NFechaDocumento LIKE '%'+@pBusquedaGeneral +'%'
where try_convert(date, NFechaDocumento, 103) is null

select AsuntoExpediente, NombreExpediente, NombreCompletoCreador
from tramite.expediente




-- exec sp_helpindex 'Tramite.ExpedienteDocumento'

-- set rowcount 10
-- select*from Tramite.ExpedienteDocumento

return

-- select text from sys.syscomments where id = object_id(@procedures, 'p')

-- select*from sys.procedures order by 1


--  exec Tramite.paListarExpedientePendienteJefaturaPorRecibirFosCad 0, '10/03/2026', '10/03/2026', 0, '10/03/2026', '10/03/2026', 30, 4, 0, 0, 0, 0, 0, 0, 0, '', '', '', '', 0, '', '', '', 39212, null, null, 1, 10, null, 0
--  exec Tramite.paListarExpedientePendienteJefaturaPorRecibirFosCad 0, '10/03/2026', '10/03/2026', 0, '10/03/2026', '10/03/2026', 30, 4, 0, 0, 0, 0, 0, 0, 0, '', '', '', '', 0, '', '', '', 53721, null, null, 1, 10, null, 0

--  exec Tramite.paListarExpedientePendienteJefaturaV8FosCad 0, '10/03/2026', '10/03/2026', 0, '10/03/2026', '10/03/2026', 30, 5, 4, 0, 0, 2026, 0, 0, 0, '', '', '', '', 0, '', '', '', 53721, null, null, 1, 10, null, 0

--  exec Tramite.paListarExpedientePendienteJefaturaCreadosFosCad 0, '10/03/2026', '10/03/2026', 0, '10/03/2026', '10/03/2026', 30, 116, 4, 0, 0, 2026, 0, 0, 0, '', '', '', '', 0, '', '', '', 53721, null, null, 1, 10, null, 0

--  exec Tramite.paListarExpedientePendienteJefaturaV8FosCad 0, '10/03/2026', '10/03/2026', 0, '10/03/2026', '10/03/2026', 30, 6, 4, 0, 0, 2026, 0, 0, 0, '', '', '', '', 0, '', '', '', 53721, null, null, 1, 10, null, 0

--  exec Tramite.paListarExpedientePendienteJefaturaV8FosCad 0, '10/03/2026', '10/03/2026', 0, '10/03/2026', '10/03/2026', 30, 3, 4, 0, 0, 2026, 0, 0, 0, '', '', '', '', 0, '', '', '', 53721, null, null, 1, 10, null, 0



-- las bandejas COMO JEFE:
--Optimizar en el SGD
--bandeja por recibir
exec Tramite.paListarExpedientePendienteJefaturaPorRecibirFosCad 0, '10/03/2026', '10/03/2026',  0, '10/03/2026', '10/03/2026', 30, 4, 0, 0, 0, 0, 0, 0, 0, '', '', '', '', 0, '', '', '', 53721, null, null, 1, 10, null, 0

--bandeja pendientes
exec Tramite.paListarExpedientePendienteJefaturaV8FosCad 0, '10/03/2026', '10/03/2026',  0, '10/03/2026', '10/03/2026', 30, 5, 4, 0, 0, 2026, 0, 0, 0, '', '', '', '', 0, '', '', '', 53721, null, null, 1, 10, null, 0

-- --bandeja creados
exec Tramite.paListarExpedientePendienteJefaturaCreadosFosCad 0, '10/03/2026', '10/03/2026',  0, '10/03/2026', '10/03/2026', 30, 116, 4, 0, 0, 2026, 0, 0, 0, '', '', '', '', 0, '', '', '', 53721, null, null, 1, 10, null, 0

-- --bandeja devueltos
exec Tramite.paListarExpedientePendienteJefaturaV8FosCad 0, '10/03/2026', '10/03/2026',  0, '10/03/2026', '10/03/2026', 30, 6, 4, 0, 0, 2026, 0, 0, 0, '', '', '', '', 0, '', '', '', 53721, null, null, 1, 10, null, 0

-- --bandeja respondidos
exec Tramite.paListarExpedientePendienteJefaturaV8FosCad 0, '10/03/2026', '10/03/2026',  0, '10/03/2026', '10/03/2026', 30, 3, 4, 0, 0, 2026, 0, 0, 0, '', '', '', '', 0, '', '', '', 53721, null, null, 1, 10, null, 0

-- --bandeja reenviados
exec Tramite.paListarExpedientePendienteJefaturaReenviadosFosCad 0, '10/03/2026', '10/03/2026',  0, '10/03/2026', '10/03/2026', 30, 111, 4, 0, 0, 2026, 0, 0, 0, '', '', '', '', 0, '', '', '', 53721, null, null, 1, 10, null, 0

-- --bandeja archivados
exec Tramite.paListarExpedientePendienteJefaturaArchivadosFosCad 0, '10/03/2026', '10/03/2026',  0, '10/03/2026', '10/03/2026', 30, 112, 4, 0, 0, 2026, 0, 0, 0, '', '', '', '', 0, '', '', '', 53721, null, null, 1, 10, null, 0

-- --bandeka mis expedientes
exec Tramite.paListarExpedientePendienteJefaturaMisExpedientesFosCad 0, '10/03/2026', '10/03/2026',  0, '10/03/2026', '10/03/2026', 30, -1, 4, 0, 0, 2026, 0, 0, 0, '', '', '', '', 0, '', '', '', 53721, null, null, 1, 10, null, 0

-- --bandeja seguimiento
exec Tramite.paListarExpedientePendienteJefaturaSeguimientoFosCad 0, '10/03/2026', '10/03/2026',  0, '10/03/2026', '10/03/2026', 30, -2, 4, 0, 0, 2026, 0, 0, 0, '', '', '', '', 0, '', '', '', 53721, null, null, 1, 10, null, 0

-- --bandeja todos
exec Tramite.paListarExpedientePendienteJefaturaTodosFosCad 0, '10/03/2026', '10/03/2026',  0, '10/03/2026', '10/03/2026', 30, 0, 4, 0, 0, 2026, 0, 0, 0, '', '', '', '', 0, '', '', '', 53721, null, null, 1, 10, null, 0

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- +****************************************************************************++++++++++++++++++++++++


--OPTIMIZAR EN EL SGD - JEFATURA
--bandeja por recibir
exec Tramite.paListarExpedientePendienteJefaturaPorRecibirFosCad 0, '10/03/2026', '10/03/2026',  0, '10/03/2026', '10/03/2026', 30, 4, 0, 0, 0, 0, 0, 0, 0, '', '', '', '', 0, '', '', '', 53721, null, null, 1, 10, null, 0

--bandeja pendientes
exec Tramite.paListarExpedientePendienteJefaturaV8FosCad 0, '10/03/2026', '10/03/2026',  0, '10/03/2026', '10/03/2026', 30, 5, 4, 0, 0, 2026, 0, 0, 0, '', '', '', '', 0, '', '', '', 53721, null, null, 1, 10, null, 0

--bandeja creados
exec Tramite.paListarExpedientePendienteJefaturaCreadosFosCad 0, '10/03/2026', '10/03/2026',  0, '10/03/2026', '10/03/2026', 30, 116, 4, 0, 0, 2026, 0, 0, 0, '', '', '', '', 0, '', '', '', 53721, null, null, 1, 10, null, 0

--bandeja devueltos
exec Tramite.paListarExpedientePendienteJefaturaV8FosCad 0, '10/03/2026', '10/03/2026',  0, '10/03/2026', '10/03/2026', 30, 6, 4, 0, 0, 2026, 0, 0, 0, '', '', '', '', 0, '', '', '', 53721, null, null, 1, 10, null, 0

--bandeja respondidos
exec Tramite.paListarExpedientePendienteJefaturaV8FosCad 0, '10/03/2026', '10/03/2026',  0, '10/03/2026', '10/03/2026', 30, 3, 4, 0, 0, 2026, 0, 0, 0, '', '', '', '', 0, '', '', '', 53721, null, null, 1, 10, null, 0

--bandeja reenviados
exec Tramite.paListarExpedientePendienteJefaturaReenviadosFosCad 0, '10/03/2026', '10/03/2026',  0, '10/03/2026', '10/03/2026', 30, 111, 4, 0, 0, 2026, 0, 0, 0, '', '', '', '', 0, '', '', '', 53721, null, null, 1, 10, null, 0

--bandeja archivados
exec Tramite.paListarExpedientePendienteJefaturaArchivadosFosCad 0, '10/03/2026', '10/03/2026',  0, '10/03/2026', '10/03/2026', 30, 112, 4, 0, 0, 2026, 0, 0, 0, '', '', '', '', 0, '', '', '', 53721, null, null, 1, 10, null, 0

--bandeka mis expedientes
exec Tramite.paListarExpedientePendienteJefaturaMisExpedientesFosCad 0, '10/03/2026', '10/03/2026',  0, '10/03/2026', '10/03/2026', 30, -1, 4, 0, 0, 2026, 0, 0, 0, '', '', '', '', 0, '', '', '', 53721, null, null, 1, 10, null, 0

--bandeja seguimiento
exec Tramite.paListarExpedientePendienteJefaturaSeguimientoFosCad 0, '10/03/2026', '10/03/2026',  0, '10/03/2026', '10/03/2026', 30, -2, 4, 0, 0, 2026, 0, 0, 0, '', '', '', '', 0, '', '', '', 53721, null, null, 1, 10, null, 0

--bandeja todos
exec Tramite.paListarExpedientePendienteJefaturaTodosFosCad 0, '10/03/2026', '10/03/2026',  0, '10/03/2026', '10/03/2026', 30, 0, 4, 0, 0, 2026, 0, 0, 0, '', '', '', '', 0, '', '', '', 53721, null, null, 1, 10, null, 0



--OPTIMIZAR EN EL SGD - ESPECIALISTA
--bandeja por recibir
	exec Tramite.paListarExpedientePendienteEspecialistaPorRecibir 0, '10/03/2026', '10/03/2026',  0, '10/03/2026', '10/03/2026', 226, 2261, 4, 4, 0, 0, 2026, 0, 0, 0, '', '', '', '', 0, '', '', '', 226, null, null, 1, 10, null, 0

--bandeja pendientes
	exec Tramite.paListarExpedientePendienteEspecialistaV7 0, '10/03/2026', '10/03/2026',  0, '10/03/2026', '10/03/2026', 226, 2261, 116, 5, 0, 0, 2026, 0, 0, 0, '', '', '', '', 0, '', '', '', 226, null, null, 1, 10, null, 0

--bandeja creados
	exec Tramite.paListarExpedientePendienteEspecialistaCreados 0, '10/03/2026', '10/03/2026',  0, '10/03/2026', '10/03/2026', 226, 2261, 116, 4, 0, 0, 2026, 0, 0, 0, '', '', '', '', 0, '', '', '', 226, null, null, 1, 10, null, 0

--bandeja devueltos
	exec Tramite.paListarExpedientePendienteEspecialistaV7 0, '10/03/2026', '10/03/2026',  0, '10/03/2026', '10/03/2026', 226, 2261, 6, 4, 0, 0, 2026, 0, 0, 0, '', '', '', '', 0, '', '', '', 226, null, null, 1, 10, null, 0

--bandeja respondidos
	exec Tramite.paListarExpedientePendienteEspecialistaV7 0, '10/03/2026', '10/03/2026',  0, '10/03/2026', '10/03/2026', 226, 2261, 3, 4, 0, 0, 2026, 0, 0, 0, '', '', '', '', 0, '', '', '', 226, null, null, 1, 10, null, 0

--bandeja reenviados
	exec Tramite.paListarExpedientePendienteEspecialistaReenviados 0, '10/03/2026', '10/03/2026',  0, '10/03/2026', '10/03/2026', 226, 2261, 111, 4, 0, 0, 2026, 0, 0, 0, '', '', '', '', 0, '', '', '', 226, null, null, 1, 10, null, 0

--bandeja archivados
	exec Tramite.paListarExpedientePendienteEspecialistaArchivados 0, '10/03/2026', '10/03/2026',  0, '10/03/2026', '10/03/2026', 226, 2261, 112, 4, 0, 0, 2026, 0, 0, 0, '', '', '', '', 0, '', '', '', 226, null, null, 1, 10, null, 0

--bandeka mis expedientes
	exec Tramite.paListarExpedientePendienteEspecialistaMisExpedientes 0, '10/03/2026', '10/03/2026',  0, '10/03/2026', '10/03/2026', 226, 2261, -1, 4, 0, 0, 2026, 0, 0, 0, '', '', '', '', 0, '', '', '', 226, null, null, 1, 10, null, 0

--bandeja seguimiento
	exec Tramite.paListarExpedientePendienteEspecialistaSeguimiento 0, '10/03/2026', '10/03/2026',  0, '10/03/2026', '10/03/2026', 226, 2261, -2, 4, 0, 0, 2026, 0, 0, 0, '', '', '', '', 0, '', '', '', 226, null, null, 1, 10, null, 0

--bandeja todos
	exec Tramite.paListarExpedientePendienteEspecialistaTodos 0, '10/03/2026', '10/03/2026',  0, '10/03/2026', '10/03/2026', 226, 2261, 0, 4, 0, 0, 2026, 0, 0, 0, '', '', '', '', 0, '', '', '', 226, null, null, 1, 10, null, 0
