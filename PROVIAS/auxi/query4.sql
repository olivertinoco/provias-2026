-- CREATE PROCEDURE [Tramite].[paListarExpedientePendienteEspecialistaV7]
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

-- AS
-- 	BEGIN TRY
set nocount on
set tran isolation level read uncommitted


select
@pConFiltroFecha = 0,
@pFechaInicio = '22/04/2026',
@pFechaFin = '22/04/2026',
@pConFiltroFechaMovimiento = 0,
@pFechaInicioMovimiento = '22/04/2026',
@pFechaFinMovimiento = '22/04/2026',
@pIdPersona = 350,
@pIdEmpleadoPerfil = 2260,
@pIdCatalogoSituacionMovimientoDestino = 4,
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
@pFechaDocumento = '',
@pEmisorExpediente = '',
@pAsuntoExpediente = '',
@pIdUsuarioAuditoria = 350,
@pCampoOrdenado = null,
@pTipoOrdenacion = null,
@pNumeroPagina = 1,
@pDimensionPagina = 10,
@pBusquedaGeneral = null,
@pFlgBusqueda = 0


Declare @vIdCargo int= 0, @vIdArea int= 0, @iRegistroTotal Int, @iPaginaRegInicio Int, @iPaginaRegFinal Int, @conBus int
select @conBus = case when @pBusquedaGeneral is null or @pBusquedaGeneral = '' then 1 else 0 end

create table #vTablaExpediente(
    eNroOrden int identity,
    IdExpediente BigInt,
    FechaMovimiento DATETIME
)

select @vIdCargo = IdCargo, @vIdArea = IdArea
from recursoHumano.EmpleadoPerfil
where   IdEmpresaSede = 1
    and EstadoAuditoria = 1
    and Activo = 1
    and IdEmpleadoPerfil = @pIdEmpleadoPerfil
set language spanish

insert into #vTablaExpediente
select t1.IdExpediente, max(convert(datetime, concat(t4.FechaDestinoEnvia, ' ', t4.HoraDestinoEnvia))) FechaMovimiento
from Tramite.Expediente t1
inner join Tramite.ExpedienteDocumento t2
    on  t2.IdExpediente = t1.IdExpediente
    and t2.EstadoAuditoria = 1
    and t2.FgEnEsperaFirmaDigital = 0
inner join Tramite.ExpedienteDocumentoOrigen t3
    on  t3.IdExpedienteDocumento = t2.IdExpedienteDocumento
    and t3.EstadoAuditoria = 1
inner join Tramite.ExpedienteDocumentoOrigenDestino t4
    on  t4.IdExpedienteDocumentoOrigen = t3.IdExpedienteDocumentoOrigen
    and t4.EstadoAuditoria   = 1
where   t1.EstadoAuditoria   = 1
    and t1.ExpedienteAnulado = 0
    and t4.IdPersonaDestino  = @pIdPersona
    and t4.IdAreaDestino     = @vIdArea
    and t4.IdCargoDestino    = @vIdCargo
    and t4.IdEmpresaDestino  = 2
    and t4.IdCatalogoSituacionMovimientoDestino = @pIdCatalogoSituacionMovimientoDestino
    and (@pConFiltroFecha != 1 or t4.FechaDestino between @pFechaInicio and @pFechaFin)
    and (@conBus = 1 or t1.NumeroExpediente = @pBusquedaGeneral)
group by t1.IdExpediente
order by FechaMovimiento desc, t1.IdExpediente desc


select*from #vTablaExpediente
