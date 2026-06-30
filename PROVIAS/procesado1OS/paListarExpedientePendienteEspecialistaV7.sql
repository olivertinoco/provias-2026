alter PROCEDURE Tramite.paListarExpedientePendienteEspecialistaV7
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
AS
BEGIN
BEGIN TRY
set nocount on
set tran isolation level read uncommitted


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
select t1.IdExpediente, max(convert(datetime, t4.FechaDestinoEnvia  +' '+ t4.HoraDestinoEnvia)) FechaMovimiento
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

select @iRegistroTotal = (Select Count(1) From #vTablaExpediente)
SELECT @iPaginaRegInicio = c.iStartRow, @iPaginaRegFinal = c.iEndrow
FROM General.fnObtenerPaginacion(@pDimensionPagina, @pNumeroPagina, @iRegistroTotal) c


select
    '' NombrePersonaOrigen,
    t1.IdExpediente,
    cast(t1.ExpedienteConfidencial as bit) ExpedienteConfidencial,
    t1.NTFechaExpediente,
    t1.HoraExpediente,
    t1.IdCatalogoTipoPrioridad,
	c1.Descripcion CatalogoTipoPrioridad,
	isnull(c2.Descripcion,'') CatalogoTipoTramite,
	isnull(c2.Detalle,'') ColorCatalogoTipoTramite,
	su.Logueo,
    t1.AsuntoExpediente,
	t1.NumeroFoliosExpediente,
	isnull(t1.ObservacionesExpediente,'') ObservacionesExpediente,
	concat(t1.NTFechaExpediente ,' ', t1.HoraExpediente) Fecha,
	t1.NombreExpediente,
	isnull(t1.NombreCompletoCreador, p.NombreCompleto) NombreCompletoCreador,
	t1.NumeroExpediente,
	isnull(ss.IdExpedienteSeguimiento, 0) IdExpedienteSeguimiento,
	t.FechaMovimiento,
	p.sexo,
	p.IdPersona,
	t.eNroOrden,
	Tramite.funObtenerNumeroDocumentoEnExpedienteEspecialistaV1(t.IdExpediente,@vIdArea,@vIdCargo,@pIdPersona,@pIdCatalogoSituacionMovimientoDestino) NumeroDocumento,
	Tramite.funObtenerIdExpedienteDocumentoEnExpedienteEspecialista(t.IdExpediente,@vIdArea,@vIdCargo,@pIdPersona,@pIdCatalogoSituacionMovimientoDestino) IdExpedienteDocumento
into #tmp001_resultset
from #vTablaExpediente t
inner join Tramite.Expediente t1
    on t1.IdExpediente = t.IdExpediente and t1.EstadoAuditoria = 1
inner join Seguridad.Usuario su
    on su.IdUsuario = t1.IdUsuarioCreacionAuditoria
inner join Tramite.Catalogo c1
    on c1.IdCatalogo = t1.IdCatalogoTipoPrioridad
inner join Tramite.Catalogo c2
    on c2.IdCatalogo = t1.IdCatalogoTipoTramite
left join General.Persona p
    on p.IdPersona = t1.IdPersonaCreador
left join Tramite.ExpedienteSeguimiento ss
    on  ss.IdExpediente = t1.IdExpediente
    and ss.EstadoAuditoria = 1
   	and ss.IdEmpresa = 2
   	and ss.IdCargo   = @vIdCargo
   	and ss.IdPersona = @pIdPersona
   	and ss.IdArea    = @vIdArea
WHERE t.eNroOrden Between @iPaginaRegInicio And @iPaginaRegFinal
order by t.eNroOrden


select t1.*,
    cast(isnull(pre.EsParaAnular, 0) as bit) EsParaAnular,
    isnull(rf.RutaFotoPersona, iif(rf.sexo = 0, 'sinfotoH.jpg', 'sinfotoM.jpg')) RutaFotoPersona,
    Tramite.funObtenerDiasPendienteEspecislista(t1.IdExpediente,@pIdPersona, 2,@vIdArea,@vIdCargo,@pIdCatalogoSituacionMovimientoDestino) DiasPendiente
into #tmp002_resultset
from #tmp001_resultset t1
left join (
    select t2.IdExpediente, case
        when max(case when IdCatalogoSituacionMovimientoDestino = 4 then 1 else 0 end) = 1 then 0
        when max(case when IdCatalogoSituacionMovimientoDestino != 4 then 1 else 0 end) = 1 then 1
        else 0 end as EsParaAnular
    from Tramite.ExpedienteDocumento t2
    inner join Tramite.ExpedienteDocumentoOrigen t3
        on t3.IdExpedienteDocumento = t2.IdExpedienteDocumento
        and t3.IdempresaOrigen = 2
        and t3.IdAreaOrigen    = @vIdArea
        and t3.IdCargoOrigen   = @vIdCargo
        and t3.IdPersonaOrigen = @pIdPersona
        and t3.EstadoAuditoria = 1
    inner join Tramite.ExpedienteDocumentoOrigenDestino t4
        on t4.IdExpedienteDocumentoOrigen = t3.IdExpedienteDocumentoOrigen
        and t4.EstadoAuditoria = 1
        and t4.EsInicial = 1
        and t4.FechaDestinoRecepciona is null
    where t2.EstadoAuditoria = 1 and t2.EsVinculado = 0
    group by t2.IdExpediente
)pre on pre.IdExpediente = t1.IdExpediente
outer apply(
    select top 1
        isnull(t1.sexo, 0) sexo, nullif(u.RutaArchivoFoto, '') RutaFotoPersona
    from Seguridad.Usuario u
    where   u.IdPersona = t1.IdPersona
        and u.EstadoAuditoria = 1
        and u.Bloqueado = 0
    order by u.RutaArchivoFoto desc
)rf


;with tmp001_NombreExpediente(cab1, cab2)as(
    select '<div style="margin: 2px;padding: 2px;" class="ui blue label">', '</div> '
)
select
    t1.EsParaAnular,
    t1.DiasPendiente,
    t1.NombrePersonaOrigen,
    t1.NumeroDocumento,
    t1.IdExpedienteDocumento,
    isnull(x.NombreExpedientesEnlazados, '') NombreExpedientesEnlazados,
    cast(case when x.NombreExpedientesEnlazados is null then 0 else 1 end as bit) EsPrincipalEnlace,
    isnull(cat.CatalogoTipoOrigen, '') CatalogoTipoOrigen,
    t1.IdExpediente,
    t1.ExpedienteConfidencial,
    t1.NTFechaExpediente,
    t1.HoraExpediente,
    t1.IdCatalogoTipoPrioridad,
	t1.CatalogoTipoPrioridad,
	t1.CatalogoTipoTramite,
	t1.ColorCatalogoTipoTramite,
	t1.Logueo,
    t1.RutaFotoPersona,
    t1.AsuntoExpediente,
	t1.NumeroFoliosExpediente,
	t1.ObservacionesExpediente,
	t1.Fecha,
	t1.NombreExpediente,
	t1.NombreCompletoCreador,
	t1.NumeroExpediente,
	t1.IdExpedienteSeguimiento,
	t1.FechaMovimiento
from #tmp002_resultset t1
outer apply (
    SELECT (select cb.cab1, NombreExpediente, cb.cab2
    FROM (
        SELECT ex.NombreExpediente, ee.IdExpedienteEnlazado orden
        FROM Tramite.ExpedienteEnlazado ee
        INNER JOIN Tramite.Expediente ex
            ON  ex.IdExpediente = ee.IdExpedienteSecundario
            AND ex.EstadoAuditoria = 1
            AND ex.ExpedienteAnulado = 0
        WHERE ee.IdExpediente = t1.IdExpediente
            AND ee.EstadoAuditoria = 1
        UNION ALL
        SELECT ex.NombreExpediente, ee.IdExpedienteEnlazado
        FROM Tramite.ExpedienteEnlazado ee
        INNER JOIN Tramite.Expediente ex
            ON  ex.IdExpediente = ee.IdExpediente
            AND ex.EstadoAuditoria = 1
            AND ex.ExpedienteAnulado = 0
        WHERE ee.IdExpedienteSecundario = t1.IdExpediente
            AND ee.EstadoAuditoria = 1
    ) Q cross apply tmp001_NombreExpediente cb
    ORDER BY orden desc
    for xml path, type).value('.','varchar(max)') NombreExpedientesEnlazados
)x
outer apply(
    select top 1 concat(c.Descripcion, ' ', e.NumeroExpedienteExterno) CatalogoTipoOrigen
    from Tramite.Expediente e
    inner join Tramite.ExpedienteDocumento tt
        on  tt.IdExpediente = e.IdExpediente
        and tt.EstadoAuditoria = 1
    inner join Tramite.Catalogo c
        on c.IdCatalogo = tt.IdCatalogoTipoOrigen
    where   e.IdExpediente = t1.IdExpediente
        and e.EstadoAuditoria = 1
    order by tt.IdExpedienteDocumento
)cat
order by t1.eNroOrden

SELECT @iRegistroTotal

END TRY
BEGIN CATCH
	DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
	SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarExpedientePendienteEspecialistaV7',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE, @pIdUsuarioAuditoria
 END CATCH
END
GO
