if exists(select 1 from sys.sysobjects where id = object_id('tramite.paListarExpedientePendienteEspecialistaCreados', 'p'))
drop procedure tramite.paListarExpedientePendienteEspecialistaCreados
go
create procedure tramite.paListarExpedientePendienteEspecialistaCreados
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
as
begin
begin try
set tran isolation level read uncommitted
set nocount on


create table #tmp001_idExpediente(IdExpediente int, FechaMovimiento datetime )
declare @vIdCargo int = 0, @vIdArea int = 0, @vIdEmpresa int = 0, @vBuscar int
select @vBuscar =
    case when @pBusquedaGeneral is not null or @pBusquedaGeneral != '' or isnumeric(@pBusquedaGeneral) = 1 then 1 else 0 end

select @vIdCargo = t.IdCargo, @vIdArea = t.IdArea, @vIdEmpresa = 2
from RecursoHumano.EmpleadoPerfil t
where   t.IdEmpleadoPerfil = @pIdEmpleadoPerfil
    and t.EstadoAuditoria = 1
    and t.Activo = 1

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
        and t3.IdAreaOrigen    = @vIdArea
        and t3.IdCargoOrigen   = @vIdCargo
        and t3.IdempresaOrigen = 2
        and t3.IdCatalogoSituacionMovimientoOrigen = 116
        and (@pConFiltroFecha != 1 or cast(t3.FechaOrigen as date) between @pFechaInicio and @pFechaFin)
    inner join tramite.ExpedienteDocumento t2
        on  t2.IdExpedienteDocumento = t3.IdExpedienteDocumento
        and t2.EstadoAuditoria = 1
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
        on  t3.IdExpedienteDocumento = t2.IdExpedienteDocumento
        and t2.EstadoAuditoria = 1
    where   t2.IdExpediente    = t1.IdExpediente
        and t3.EstadoAuditoria = 1
        and t3.IdPersonaOrigen = @pIdPersona
        and t3.IdAreaOrigen    = @vIdArea
        and t3.IdCargoOrigen   = @vIdCargo
        and t3.IdempresaOrigen = 2
        and t3.IdCatalogoSituacionMovimientoOrigen = 116
        and (@pConFiltroFecha != 1
             or cast(t3.FechaOrigen as date) between @pFechaInicio and @pFechaFin)
    order by FechaMovimiento desc
)t


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
    ex.IdExpediente,
    ex.FechaMovimiento,
    isnull(tt.EsParaAnular, 0) EsParaAnular,
    isnull(cat.CatalogoTipoOrigen, '') CatalogoTipoOrigen,
    isnull(nro.NumeroDocumento, '') NumeroDocumento,
    isnull(nro.IdExpedienteDocumento, 0) IdExpedienteDocumento,
    isnull(x.NombreExpedientesEnlazados, '') NombreExpedientesEnlazados,
    case when x.NombreExpedientesEnlazados is null then 0 else 1 end EsPrincipalEnlace
into #tmp001_EpedienteResum
from #tmp001_idExpediente ex
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
            where t2.IdExpediente     = ex.IdExpediente
              and t2.EstadoAuditoria  = 1
              and t2.EsVinculado      = 0
              and t3.IdPersonaOrigen  = @pIdPersona
              and t3.IdAreaOrigen     = @vIdArea
              and t3.IdCargoOrigen    = @vIdCargo
              and t3.IdempresaOrigen  = @vIdEmpresa
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
            where t2.IdExpediente    = ex.IdExpediente
              and t2.EstadoAuditoria  = 1
              and t2.EsVinculado      = 0
              and t3.IdPersonaOrigen  = @pIdPersona
              and t3.IdAreaOrigen     = @vIdArea
              and t3.IdCargoOrigen    = @vIdCargo
              and t3.IdempresaOrigen  = @vIdEmpresa
        ) then 1
        else 0
    end EsParaAnular
) tt
outer apply(
    select top 1 concat(c.Descripcion, ' ', e.NumeroExpedienteExterno) CatalogoTipoOrigen
    from Tramite.Expediente e
    inner join Tramite.ExpedienteDocumento tt
        on  tt.IdExpediente = e.IdExpediente
        and tt.EstadoAuditoria = 1
    inner join Tramite.Catalogo c
        on c.IdCatalogo = tt.IdCatalogoTipoOrigen
    where   e.IdExpediente = ex.IdExpediente
        and e.EstadoAuditoria = 1
    order by tt.IdExpedienteDocumento
)cat
outer apply(
    select top 1 t2.IdExpedienteDocumento,
        concat(case pp.grupo when 1 then replace(g.cab1, 'xxx', t4.MotivoArchivado) else g.cab1 end,
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
    where   t2.IdExpediente = ex.IdExpediente
        and t2.EstadoAuditoria = 1
        and case pp.grupo when 1 then t4.IdAreaDestino    else t3.IdAreaOrigen    end = @vIdArea
    	and case pp.grupo when 1 then t4.IdCargoDestino   else t3.IdCargoOrigen   end = @vIdCargo
    	and case pp.grupo when 1 then t4.IdPersonaDestino else t3.IdPersonaOrigen end = @pIdPersona
    	and (pp.grupo != 3 or t3.IdCatalogoSituacionMovimientoOrigen  = @pIdCatalogoSituacionMovimientoDestino)
    	and (pp.grupo != 1 or t4.IdCatalogoSituacionMovimientoDestino = @pIdCatalogoSituacionMovimientoDestino)
    order by case pp.grupo when 3 then t3.IdExpedienteDocumentoOrigen when 2 then t4.IdExpedienteDocumentoOrigenDestino end desc
)nro
outer apply (
    SELECT TOP 1 concat(cb.cab1, NombreExpediente, cb.cab2) NombreExpedientesEnlazados
    FROM (
        SELECT t1.NombreExpediente, 1 orden
        FROM Tramite.ExpedienteEnlazado ee
        INNER JOIN Tramite.Expediente t1
            ON  t1.IdExpediente = ee.IdExpedienteSecundario
            AND t1.EstadoAuditoria = 1
            AND t1.ExpedienteAnulado = 0
        WHERE ee.IdExpediente = ex.IdExpediente
            AND ee.EstadoAuditoria = 1
        UNION ALL
        SELECT t1.NombreExpediente, 2
        FROM Tramite.ExpedienteEnlazado ee
        INNER JOIN Tramite.Expediente t1
            ON  t1.IdExpediente = ee.IdExpediente
            AND t1.EstadoAuditoria = 1
            AND t1.ExpedienteAnulado = 0
        WHERE ee.IdExpedienteSecundario = ex.IdExpediente
            AND ee.EstadoAuditoria = 1
    ) Q cross apply tmp001_NombreExpediente cb
    ORDER BY orden
)x


;with tmp001_serieDocumental as(
    select*from(values(1,'E-'),(2,'I-'))sd(IdSerieDocumentalExpediente, AbreviaturaSerieDocumentalExpediente)
)
select
    t.CatalogoTipoOrigen,
    t.EsParaAnular,
    0 DiasPendiente,
    '' NombrePersonaOrigen,
    t.NumeroDocumento,
    t.IdExpedienteDocumento,
    t.NombreExpedientesEnlazados,
    t.EsPrincipalEnlace,
    t.IdExpediente,
    t1.ExpedienteConfidencial,
    t1.NTFechaExpediente,
    t1.HoraExpediente,
    t1.IdCatalogoTipoPrioridad,
    c1.Descripcion CatalogoTipoPrioridad,
    isnull(c2.Descripcion,'') CatalogoTipoTramite,
    isnull(c2.Detalle,'') ColorCatalogoTipoTramite,
    su.Logueo,
    r.RutaFotoPersona RutaFotoPersona,
    t1.AsuntoExpediente,
    t1.NumeroFoliosExpediente,
    isnull(t1.ObservacionesExpediente,'') ObservacionesExpediente,
    CONCAT(t1.NTFechaExpediente ,' ', t1.HoraExpediente) Fecha,
    CONCAT(sd.AbreviaturaSerieDocumentalExpediente, RIGHT(1000000 + t1.NumeroExpediente,6), '-', t1.IdPeriodo) NombreExpediente,
    CASE WHEN t1.NombreCompletoCreador is not null and t1.NombreCompletoCreador != '' THEN isnull(t1.NombreCompletoCreador,'')
        ELSE pe.NombreCompleto END NombreCompletoCreador,
    t1.NumeroExpediente,
    isnull(es.IdExpedienteSeguimiento,0) IdExpedienteSeguimiento,
    t.FechaMovimiento
into #tmp001_EpedienteRespuesta
from #tmp001_EpedienteResum t
inner join Tramite.Expediente t1
    on  t1.IdExpediente = t.IdExpediente
    and t1.EstadoAuditoria = 1
    and t1.ExpedienteAnulado = 0
inner join Seguridad.Usuario su
    on su.IdUsuario = t1.IdUsuarioCreacionAuditoria
inner join Tramite.Catalogo c1
    on c1.IdCatalogo = t1.IdCatalogoTipoPrioridad
inner join Tramite.Catalogo c2
    on c2.IdCatalogo = t1.IdCatalogoTipoTramite
inner join tmp001_serieDocumental sd
    on sd.IdSerieDocumentalExpediente = t1.IdSerieDocumentalExpediente
left join General.Persona pe
    on pe.IdPersona = t1.IdPersonaCreador
left join Tramite.ExpedienteSeguimiento es
    on  es.IdExpediente = t1.IdExpediente
    and es.EstadoAuditoria = 1
    and es.IdEmpresa = @vIdEmpresa
    and es.IdArea    = @vIdArea
    and es.IdCargo   = @vIdCargo
    and es.IdPersona = @pIdPersona
outer apply(
    select top 1
        case when u.RutaArchivoFoto is null and u.RutaArchivoFoto = ''
        then iif(p.sexo = 0, 'sinfotoH.jpg', 'sinfotoM.jpg') else u.RutaArchivoFoto end RutaFotoPersona
    from General.Persona p
    inner join Seguridad.Usuario u
        on  u.IdPersona = p.IdPersona
        and u.EstadoAuditoria = 1
        and u.Bloqueado = 0
    where p.IdPersona = t1.IdPersonaCreador
)r


select
    EsParaAnular,
    CatalogoTipoOrigen,
    DiasPendiente,
    NombrePersonaOrigen,
    NumeroDocumento,
    IdExpedienteDocumento,
    NombreExpedientesEnlazados,
    EsPrincipalEnlace,
    CatalogoTipoOrigen,
    IdExpediente,
    ExpedienteConfidencial,
    NTFechaExpediente,
    HoraExpediente,
    IdCatalogoTipoPrioridad,
    CatalogoTipoPrioridad,
    CatalogoTipoTramite,
    ColorCatalogoTipoTramite,
    Logueo,
    RutaFotoPersona,
    AsuntoExpediente,
    NumeroFoliosExpediente,
    ObservacionesExpediente,
    Fecha,
    NombreExpediente,
    NombreCompletoCreador,
    NumeroExpediente,
    IdExpedienteSeguimiento,
    FechaMovimiento
from #tmp001_EpedienteRespuesta
order by FechaMovimiento desc
OFFSET (@pNumeroPagina-1)*@pDimensionPagina ROWS
FETCH NEXT @pDimensionPagina ROWS ONLY


select count(1) from #tmp001_EpedienteRespuesta


END TRY
	BEGIN CATCH
			DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
			SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarExpedientePendienteEspecialistaCreados',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
			EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE, @pIdUsuarioAuditoria
	 END CATCH
end
go
