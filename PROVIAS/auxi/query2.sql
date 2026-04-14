-- alter procedure tramite.paListarExpedientePendienteEspecialistaCreados_new
Declare
	@pConFiltroFecha bit,
	@pFechaInicio varchar(10),
	@pFechaFin varchar(10),
	@pConFiltroFechaMovimiento bit,
	@pFechaInicioMovimiento varchar(10),
	@pFechaFinMovimiento varchar(10),
	@pIdPersona int,
	@pIdEmpleadoPerfil int,
	@pIdCatalogoSituacionMovimientoDestino INT,
	@pTipoSituacionMovimiento int,
	@pIdAreaOrigen int,
    @pIdAreaDestino int,
    @pIdPeriodo int,
    @pIdCatalogoTipoPrioridad int,
    @pIdCatalogoTipoTramite int,
    @pIdCatalogoTipoDocumento int,
    @pNumeroExpediente varchar(100),
    @pNumeroDocumento varchar(100),
	@pPersonaDesde varchar(100),
	@pPersonaPara varchar(100),
	@pIdTipoIngreso int,
	@pFechaDocumento  varchar(100),
	@pEmisorExpediente varchar(100),
	@pAsuntoExpediente  varchar(100),
	@pIdUsuarioAuditoria int,
	@pCampoOrdenado varchar(50),
	@pTipoOrdenacion varchar(4),
	@pNumeroPagina INT,
	@pDimensionPagina  INT,
	@pBusquedaGeneral varchar(100),
	@pFlgBusqueda INT
-- as
-- begin
-- begin try
-- set tran isolation level read uncommitted
-- set nocount on


select
	@pConFiltroFecha = 0,
	@pFechaInicio = '13/04/2026',
	@pFechaFin = '13/04/2026',
	@pConFiltroFechaMovimiento = 0,
	@pFechaInicioMovimiento = '13/04/2026',
	@pFechaFinMovimiento = '13/04/2026',
	@pIdPersona = 728,
	@pIdEmpleadoPerfil = 727,
	@pIdCatalogoSituacionMovimientoDestino = 116,
	@pTipoSituacionMovimiento = 4,
	@pIdAreaOrigen = 0,
    @pIdAreaDestino = 0,
    @pIdPeriodo = 2026,
    @pIdCatalogoTipoPrioridad = 0,
    @pIdCatalogoTipoTramite = 0,
    @pIdCatalogoTipoDocumento = 0,
    @pNumeroExpediente = '',
    @pNumeroDocumento = '',
	@pPersonaDesde = '',
	@pPersonaPara = '',
	@pIdTipoIngreso = 0,
	@pFechaDocumento  = '',
	@pEmisorExpediente = '',
	@pAsuntoExpediente  = '',
	@pIdUsuarioAuditoria = 728,
	@pCampoOrdenado = null,
	@pTipoOrdenacion = null,
	@pNumeroPagina = 1,
	@pDimensionPagina = 10,
	@pBusquedaGeneral = null,
	@pFlgBusqueda = 0


create table #tmp001_idExpediente(IdExpediente int, FechaMovimiento datetime )
declare @vIdCargo int = 0, @vIdArea int = 0, @vIdEmpresa int = 0, @vBuscar int
select @vBuscar =
    case when @pBusquedaGeneral is not null or @pBusquedaGeneral != '' or isnumeric(@pBusquedaGeneral) = 1 then 1 else 0 end

select @vIdCargo = t.IdCargo, @vIdArea = t.IdArea, @vIdEmpresa = 2
from RecursoHumano.EmpleadoPerfil t
where t.IdEmpleadoPerfil = @pIdEmpleadoPerfil and t.EstadoAuditoria = 1 and t.Activo = 1
set language spanish

select t1.IdExpediente into #tmp011_idExpediente
from tramite.Expediente t1
where t1.EstadoAuditoria = 1 and t1.ExpedienteAnulado = 0 and t1.IdPeriodo = @pIdPeriodo
and t1.IdSerieDocumentalExpediente in (1,2) and (@vBuscar = 0 or t1.NumeroExpediente = @pBusquedaGeneral )
and exists(
    select 1
    from tramite.ExpedienteDocumentoOrigenDestino t4
    inner join tramite.ExpedienteDocumentoOrigen t3
        on  t3.IdExpedienteDocumentoOrigen = t4.IdExpedienteDocumentoOrigen
        and t3.EstadoAuditoria = 1
        and t3.IdPersonaOrigen = @pIdPersona
        and t3.IdAreaOrigen = @vIdArea
        and t3.IdCargoOrigen = @vIdCargo
        and t3.IdempresaOrigen = 2
        and t3.IdCatalogoSituacionMovimientoOrigen = 116
        and (@pConFiltroFecha != 1
            or cast(t3.FechaOrigen as date) between @pFechaInicio and @pFechaFin)
    inner join tramite.ExpedienteDocumento t2
        on t2.IdExpedienteDocumento = t3.IdExpedienteDocumento and t2.EstadoAuditoria = 1
        and t2.IdExpediente = t1.IdExpediente
)


insert into #tmp001_idExpediente
select t1.IdExpediente, t.FechaMovimiento
from #tmp011_idExpediente t1
cross apply (
    select top 1
        cast(t3.FechaOrigen + ' ' + t3.HoraOrigen as datetime) FechaMovimiento
    from Tramite.ExpedienteDocumento t2
    inner join Tramite.ExpedienteDocumentoOrigen t3
        on t3.IdExpedienteDocumento = t2.IdExpedienteDocumento
        and t2.EstadoAuditoria = 1
    where t2.IdExpediente = t1.IdExpediente
        and t3.EstadoAuditoria = 1
        and t3.IdPersonaOrigen = @pIdPersona
        and t3.IdAreaOrigen = @vIdArea
        and t3.IdCargoOrigen = @vIdCargo
        and t3.IdempresaOrigen = 2
        and t3.IdCatalogoSituacionMovimientoOrigen = 116
        and (@pConFiltroFecha != 1
             or cast(t3.FechaOrigen as date) between @pFechaInicio and @pFechaFin)
    order by FechaMovimiento desc
)t









-- END TRY
-- 	BEGIN CATCH
-- 			DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
-- 			SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarExpedientePendienteEspecialistaCreados',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
-- 			EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE, @pIdUsuarioAuditoria
-- 	 END CATCH
-- end
-- go




-- exec Tramite.paListarExpedientePendienteEspecialistaCreados
-- 0, '13/04/2026','13/04/2026',0,'13/04/2026','13/04/2026',728,727, 116, 4,0,0,2026,0,0,0,'','','','',0,'','','',728,null,null,1,10,null,0
