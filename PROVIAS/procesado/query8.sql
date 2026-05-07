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


;with tmp001_cabComp(grupo, cab1, cab2, cab3) as(
    select 2, '<button type="button" data-toggle="tooltip" class="btn ui blue label" onclick="MostrarDocumentoPdfExp(''',
        ')"><i style="font-size:16px;" class="fa fa-file-text"></i></button><label style="font-size:8px">', '</label>'
    union all
    select 3, '<button type="button" data-toggle="tooltip" class="btn ui blue label" onclick="MostrarDocumentoPdfExp(''',
        ')"><i style="font-size:16px;" class="fa fa-file-text"></i></button><label style="font-size:8px">', '</label>'
    union all
    select 1, '<button type="button" data-toggle="tooltip" title="xxx" class="btn ui blue label" onclick="MostrarDocumentoPdfExp(''',
        ')"><i style="font-size:16px;" class="fa fa-file-text"></i></button><label style="font-size:8px">', '</label>'
)
,tmp001_NombreExpediente(cab1, cab2)as(
    select '<div style="margin: 2px;padding: 2px;" class="ui blue label">', '</div> '
)
,tmp001_params as(
    select*from(values(4,1),(5,1),(112,1),(111,2),(3,2),(6,2),(116,3))t(pIdCatalogoSituacionMovimientoDestino,grupo)
)
select
    cast(tt.EsParaAnular as bit) EsParaAnular,
    dia.DiasPendiente,
    '' NombrePersonaOrigen,
    nro.NumeroDocumento,
    nro.IdExpedienteDocumento,
    isnull(x.NombreExpedientesEnlazados, '') NombreExpedientesEnlazados,
    cast(case when x.NombreExpedientesEnlazados is null then 0 else 1 end as bit) EsPrincipalEnlace,
    isnull(cat.CatalogoTipoOrigen, '') CatalogoTipoOrigen,
    t1.IdExpediente,
    cast(t1.ExpedienteConfidencial as bit) ExpedienteConfidencial,
    t1.NTFechaExpediente,
    t1.HoraExpediente,
    t1.IdCatalogoTipoPrioridad,
	c1.Descripcion CatalogoTipoPrioridad,
	isnull(c2.Descripcion,'') CatalogoTipoTramite,
	isnull(c2.Detalle,'') ColorCatalogoTipoTramite,
	su.Logueo,
    rf.RutaFotoPersona,
    t1.AsuntoExpediente,
	t1.NumeroFoliosExpediente,
	isnull(t1.ObservacionesExpediente,'') ObservacionesExpediente,
	concat(t1.NTFechaExpediente ,' ', t1.HoraExpediente) Fecha,
	t1.NombreExpediente,
	isnull(t1.NombreCompletoCreador, p.NombreCompleto) NombreCompletoCreador,
	t1.NumeroExpediente,
	isnull(ss.IdExpedienteSeguimiento, 0) IdExpedienteSeguimiento,
	t.FechaMovimiento
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
outer apply(
    select top 1
        case when u.RutaArchivoFoto is null or u.RutaArchivoFoto = ''
        then iif(p.sexo = 0, 'sinfotoH.jpg', 'sinfotoM.jpg') else u.RutaArchivoFoto end RutaFotoPersona
    from Seguridad.Usuario u
    where   u.IdPersona = p.IdPersona
        and u.EstadoAuditoria = 1
        and u.Bloqueado = 0
)rf
outer apply(
    select case
        when exists(
            select 1
            from Tramite.ExpedienteDocumento t2
            join Tramite.ExpedienteDocumentoOrigen t3
                on  t3.IdExpedienteDocumento = t2.IdExpedienteDocumento
                and t3.EstadoAuditoria = 1
            join Tramite.ExpedienteDocumentoOrigenDestino t4
                on  t4.IdExpedienteDocumentoOrigen = t3.IdExpedienteDocumentoOrigen
                and t4.EstadoAuditoria = 1
                and t4.EsInicial = 1
                and t4.FechaDestinoRecepciona is null
                and t4.IdCatalogoSituacionMovimientoDestino != 4
            where t2.IdExpediente     = t1.IdExpediente
              and t2.EstadoAuditoria  = 1
              and t2.EsVinculado      = 0
              and t3.IdPersonaOrigen  = @pIdPersona
              and t3.IdAreaOrigen     = @vIdArea
              and t3.IdCargoOrigen    = @vIdCargo
              and t3.IdempresaOrigen  = 2
        ) then 0
        when exists(
            select 1
            from Tramite.ExpedienteDocumento t2
            join Tramite.ExpedienteDocumentoOrigen t3
                on  t3.IdExpedienteDocumento = t2.IdExpedienteDocumento
                and t3.EstadoAuditoria = 1
            join Tramite.ExpedienteDocumentoOrigenDestino t4
                on  t4.IdExpedienteDocumentoOrigen = t3.IdExpedienteDocumentoOrigen
                and t4.EstadoAuditoria = 1
                and t4.EsInicial = 1
                and t4.FechaDestinoRecepciona is null
            where t2.IdExpediente     = t1.IdExpediente
              and t2.EstadoAuditoria  = 1
              and t2.EsVinculado      = 0
              and t3.IdPersonaOrigen  = @pIdPersona
              and t3.IdAreaOrigen     = @vIdArea
              and t3.IdCargoOrigen    = @vIdCargo
              and t3.IdempresaOrigen  = 2
        ) then 1
        else 0
    end EsParaAnular
) tt
outer apply(
    select top 1
        case @pIdCatalogoSituacionMovimientoDestino
        when 4 then iif(t4.FechaDestinoRecepciona is null, datediff(day, convert(date, t3.FechaOrigen), getdate()), 0)
        when 5 then isnull(datediff(day, convert(date, t4.FechaDestinoRecepciona), getdate()),0) else 0 end DiasPendiente
    from Tramite.ExpedienteDocumento t2
    inner join Tramite.ExpedienteDocumentoOrigen t3
        on  t3.IdExpedienteDocumento = t2.IdExpedienteDocumento
        and t3.EstadoAuditoria = 1
    inner join Tramite.ExpedienteDocumentoOrigenDestino t4
        on  t4.IdExpedienteDocumentoOrigen = t3.IdExpedienteDocumentoOrigen
        and t4.EstadoAuditoria = 1
    where   t2.IdExpediente    = t1.IdExpediente
        and t2.EstadoAuditoria = 1
        and t4.IdAreaDestino   = @vIdArea
        and t4.IdCargoDestino  = @vIdCargo
        and t4.IdEmpresaDestino= 2
        and t4.IdPersonaDestino= @pIdPersona
        and t4.IdCatalogoSituacionMovimientoDestino = @pIdCatalogoSituacionMovimientoDestino
)dia
outer apply(
    select top 1 t2.IdExpedienteDocumento,
        concat(case pp.grupo when 1 then replace(g.cab1, 'xxx', isnull(t4.MotivoArchivado, '')) else g.cab1 end,
        t2.RutaArchivoDocumento, ''',', t2.IdExpedienteDocumento, g.cab2,
        case t2.Correlativo when 0 then concat(c.Descripcion, ' ', t2.NumeroDocumento)
        else t2.NumeroDocumento end, g.cab3) NumeroDocumento
    from Tramite.ExpedienteDocumento t2
    inner join Tramite.ExpedienteDocumentoOrigen t3
        on  t3.IdExpedienteDocumento = t2.IdExpedienteDocumento
        and t3.EstadoAuditoria = 1
    inner join Tramite.ExpedienteDocumentoOrigenDestino t4
        on  t4.IdExpedienteDocumentoOrigen = t3.IdExpedienteDocumentoOrigen
        and t4.EstadoAuditoria = 1
    left join Tramite.Catalogo c
        on c.IdCatalogo = t2.IdCatalogoTipoDocumento
    left join tmp001_params pp
        on pp.pIdCatalogoSituacionMovimientoDestino = @pIdCatalogoSituacionMovimientoDestino
    left join tmp001_cabComp g
        on  g.grupo = pp.grupo
    where   t2.IdExpediente = t1.IdExpediente
        and t2.EstadoAuditoria = 1
        and case pp.grupo when 1 then t4.IdAreaDestino    else t3.IdAreaOrigen    end = @vIdArea
    	and case pp.grupo when 1 then t4.IdCargoDestino   else t3.IdCargoOrigen   end = @vIdCargo
    	and case pp.grupo when 1 then t4.IdPersonaDestino else t3.IdPersonaOrigen end = @pIdPersona
    	and (pp.grupo != 3 or t3.IdCatalogoSituacionMovimientoOrigen  = @pIdCatalogoSituacionMovimientoDestino)
    	and (pp.grupo != 1 or t4.IdCatalogoSituacionMovimientoDestino = @pIdCatalogoSituacionMovimientoDestino)
    order by case pp.grupo when 3 then t3.IdExpedienteDocumentoOrigen when 2 then t4.IdExpedienteDocumentoOrigenDestino end desc
)nro
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
WHERE t.eNroOrden Between @iPaginaRegInicio And @iPaginaRegFinal
order by t.eNroOrden

SELECT @iRegistroTotal


END TRY
BEGIN CATCH
	DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
	SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarExpedientePendienteEspecialistaV7',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE, @pIdUsuarioAuditoria
 END CATCH
END
GO
