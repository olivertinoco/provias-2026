-- CREATE PROCEDURE [Tramite].[paListarExpedientePendienteEspecialistaPorRecibir]
declare
    @pConFiltroFecha bit = 0,
	@pFechaInicio varchar(10) = '24/03/2026',
	@pFechaFin varchar(10) = '24/03/2026',
	@pConFiltroFechaMovimiento bit = 0,
	@pFechaInicioMovimiento varchar(10) = '24/03/2026',
	@pFechaFinMovimiento varchar(10) = '24/03/2026',
	@pIdPersona int= 845,
	@pIdEmpleadoPerfil int= 2051,
	@pIdCatalogoSituacionMovimientoDestino INT=4,
	@pTipoSituacionMovimiento int=4,
	@pIdAreaOrigen int=0,
    @pIdAreaDestino int=0,
    @pIdPeriodo int = 2026,
    @pIdCatalogoTipoPrioridad int=0,
    @pIdCatalogoTipoTramite int=0,
    @pIdCatalogoTipoDocumento int=0,
    @pNumeroExpediente varchar(100)='',
    @pNumeroDocumento varchar(100)='',
	@pPersonaDesde varchar(100)='',
	@pPersonaPara varchar(100)='',
	@pIdTipoIngreso int = 0,
	@pFechaDocumento  varchar(100)='',
	@pEmisorExpediente varchar(100)='',
	@pAsuntoExpediente  varchar(100)='',
	@pIdUsuarioAuditoria int = 845,
	@pCampoOrdenado varchar(50)=null,
	@pTipoOrdenacion varchar(4)=null,
	@pNumeroPagina INT=1,
	@pDimensionPagina  INT=10,
	@pBusquedaGeneral varchar(100)=null,
	@pFlgBusqueda INT=0

set tran isolation level read uncommitted
set nocount off
set language spanish
-- set statistics xml on
-- set statistics io on
-- set statistics time on


select
    @pConFiltroFecha pConFiltroFecha,
    @pFechaInicio pFechaInicio,
    @pFechaFin pFechaFin,
    @pConFiltroFechaMovimiento pConFiltroFechaMovimiento,
    @pFechaInicioMovimiento pFechaInicioMovimiento,
    @pFechaFinMovimiento pFechaFinMovimiento,
    @pIdPersona pIdPersona,
    @pIdEmpleadoPerfil pIdEmpleadoPerfil,
    @pIdCatalogoSituacionMovimientoDestino pIdCatalogoSituacionMovimientoDestino,
    @pTipoSituacionMovimiento pTipoSituacionMovimiento,
    @pIdAreaOrigen pIdAreaOrigen,
    @pIdAreaDestino pIdAreaDestino,
    isnull(nullif(@pIdPeriodo,0), year(getdate())) pIdPeriodo,
    @pIdCatalogoTipoPrioridad pIdCatalogoTipoPrioridad,
    @pIdCatalogoTipoTramite pIdCatalogoTipoTramite,
    @pIdCatalogoTipoDocumento pIdCatalogoTipoDocumento,
    @pNumeroExpediente pNumeroExpediente,
    @pNumeroDocumento pNumeroDocumento,
    @pPersonaDesde pPersonaDesde,
    @pPersonaPara pPersonaPara,
    @pIdTipoIngreso pIdTipoIngreso,
    @pFechaDocumento pFechaDocumento,
    @pEmisorExpediente pEmisorExpediente,
    @pAsuntoExpediente pAsuntoExpediente,
    @pIdUsuarioAuditoria pIdUsuarioAuditoria,
    @pCampoOrdenado pCampoOrdenado,
    @pTipoOrdenacion pTipoOrdenacion,
    @pNumeroPagina pNumeroPagina,
    @pDimensionPagina pDimensionPagina,
    nullif(ltrim(rtrim(@pBusquedaGeneral)),'') pBusquedaGeneral,
    @pFlgBusqueda pFlgBusqueda,
    cast(null as int) vIdArea,
    cast(null as int) vIdCargo,
	cast(null as int) vIdEmpresa into #tmp001_params

update pp set pp.vIdArea = t.IdArea, pp.vIdCargo = t.IdCargo, pp.vIdEmpresa = tt.IdEmpresa
from RecursoHumano.EmpleadoPerfil t, (values(1,2))tt(IdEmpresaSede, IdEmpresa), #tmp001_params pp
where t.IdEmpresaSede = tt.IdEmpresaSede and t.EstadoAuditoria = 1 and t.activo = 1 and t.IdEmpleadoPerfil = pp.pIdEmpleadoPerfil

if exists(select 1 from #tmp001_params where pIdPersona > 0)begin

with tmp001_serieDocumental as(
    select*from(values(1,'E-'),(2,'I-'))sd(IdSerieDocumentalExpediente, AbreviaturaSerieDocumentalExpediente)
)
,tmp001_expedienteDocumento as(
    select*from tramite.ExpedienteDocumento where EstadoAuditoria = 1
)
select top 1 with ties
    t1.IdExpediente,
    t1.IdCatalogoTipoPrioridad,
    t1.IdPersonaCreador,
    t1.NumeroExpediente,
    t1.NumeroFoliosExpediente,
    t1.IdUsuarioCreacionAuditoria,
    t1.IdCatalogoTipoTramite,
    t2.IdExpedienteDocumento,
    t2.IdCatalogoTipoDocumento,
    t2.Correlativo,
    aux.IdCatalogoTipoOrigen,
    t3.IdAreaOrigen,
    t3.IdPersonaOrigen,
    t3.IdCargoOrigen,
    t3.IdempresaOrigen,
    t4.IdCatalogoSituacionMovimientoDestino,
    t4.IdAreaDestino,
    t4.IdPersonaDestino,
    t4.IdCargoDestino,
    t4.IdempresaDestino,
    t4.EsInicial,
    t1.ExpedienteConfidencial,
    t2.EsVinculado,
    t2.FgEnEsperaFirmaDigital,
    t1.fechaCreacionAuditoria,
    t4.fechaCreacionAuditoria FechaMovimiento,
    CONCAT(sd.AbreviaturaSerieDocumentalExpediente,RIGHT(CONCAT('000000',t1.NumeroExpediente),6), '-', t1.IdPeriodo) NombreExpediente,
    t3.FechaOrigen,
    isnull(t4.FechaDestinoRecepciona,'') FechaDestinoRecepciona,
    t1.NumeroExpedienteExterno,
    t1.NombreCompletoCreador,
    t2.NombreCompletoEmisor,
    t2.RutaArchivoDocumento,
    t2.NumeroDocumento,
    replace(replace(t1.ObservacionesExpediente, char(10), ''), char(13), '') ObservacionesExpediente,
    replace(replace(t1.AsuntoExpediente, char(10), ''), char(13), '') AsuntoExpediente,
    t4.MotivoArchivado
    into #tmp001_matriz
    from tramite.Expediente t1 cross apply #tmp001_params pp
    cross apply(select*from tmp001_expedienteDocumento t2
        where t2.idExpediente = t1.idExpediente and t2.FgEnEsperaFirmaDigital = 0)t2
    cross apply(select*from tramite.ExpedienteDocumentoOrigen t3
        where t3.idExpedienteDocumento = t2.idExpedienteDocumento and t3.estadoAuditoria = 1)t3
    cross apply(select*from tramite.ExpedienteDocumentoOrigenDestino t4
        where t4.idExpedienteDocumentoOrigen = t3.idExpedienteDocumentoOrigen and
            t4.IdEmpresaDestino = pp.vIdEmpresa and
            t4.IdAreaDestino = pp.vIdArea and
            t4.IdCargoDestino = pp.vIdCargo and
            t4.IdPersonaDestino = pp.pIdPersona and
            t4.EstadoAuditoria = 1 and
            t4.IdCatalogoSituacionMovimientoDestino = pp.pIdCatalogoSituacionMovimientoDestino)t4
    cross apply(select*from tmp001_serieDocumental sd where sd.IdSerieDocumentalExpediente = t1.IdSerieDocumentalExpediente)sd
    cross apply(
        select top 1 aux.IdCatalogoTipoOrigen
        from tmp001_expedienteDocumento aux
        where aux.IdExpediente = t1.IdExpediente
        order by aux.IdExpedienteDocumento
    )aux
    where isnull(t1.ExpedienteAnulado,0) = 0 and t1.estadoAuditoria = 1 and
    t1.NumeroExpediente = isnull(pp.pBusquedaGeneral, t1.NumeroExpediente)
    order by row_number()over(partition by t1.IdExpediente order by t4.fechaCreacionAuditoria desc)

;with tmp001_catalog as(
    select IdCatalogo, Descripcion, Detalle from tramite.Catalogo
)
,tmp001_expedienteEnlazado as(
    select*from tramite.ExpedienteEnlazado where EstadoAuditoria = 1
)
,tmp001_seguridadUsuario as(
    select*from Seguridad.Usuario where EstadoAuditoria = 1 and Bloqueado = 0
)
select
    convert(bit,case when pa1.cant>0 then 0 when pa2.cant>0 then 1 else 0 end) EsParaAnular,
    isnull(dp.DiasPendiente, 0) DiasPendiente,
    isnull(np.NombrePersonaOrigen,'') NombrePersonaOrigen,
    isnull(nd.NumeroDocumento,'') NumeroDocumento,
    ied.IdExpedienteDocumento,
    isnull(case when enp.ExEnlazadoPri != '' then replace(replace(enp.ExEnlazadoPri,'&lt;','<'),'&gt;','>')
    else replace(replace(ens.ExEnlazadoSec,'&lt;','<'),'&gt;','>') end, '') NombreExpedientesEnlazados,
    convert(bit, case when ee.cantEnlaces > 0 then 1 else 0 end) EsPrincipalEnlace,
    concat(c3.descripcion,' ', t.NumeroExpedienteExterno) CatalogoTipoOrigen,
    t.IdExpediente,
    t.ExpedienteConfidencial,
    convert(varchar, t.fechaCreacionAuditoria, 103)  NTFechaExpediente,
    convert(char(5), t.fechaCreacionAuditoria, 108) HoraExpediente,
    t.IdCatalogoTipoPrioridad,
    c1.descripcion CatalogoTipoPrioridad,
    c2.descripcion CatalogoTipoTramite,
    c2.detalle ColorCatalogoTipoTramite,
    su.Logueo,
    iif(isnull(rfp.RutaArchivoFoto, '') = '', case when isnull(pe.sexo, 0) = 0 then 'sinfotoH.jpg' else 'sinfotoM.jpg' end,
    rfp.RutaArchivoFoto) RutaFotoPersona,
    t.AsuntoExpediente,
    t.NumeroFoliosExpediente,
    t.ObservacionesExpediente,
    concat(convert(varchar, t.fechaCreacionAuditoria, 103), ' ', convert(char(5), t.fechaCreacionAuditoria, 108)) Fecha,
    t.NombreExpediente,
    isnull(t.NombreCompletoCreador, pe.NombreCompleto) NombreCompletoCreador,
    t.NumeroExpediente,
    isnull(es.IdExpedienteSeguimiento, 0) IdExpedienteSeguimiento,
    t.FechaMovimiento
from #tmp001_matriz t
cross apply #tmp001_params pp
cross apply(select*from tmp001_seguridadUsuario su where su.IdUsuario = t.IdUsuarioCreacionAuditoria)su
cross apply(select datediff(day, cast(t.FechaOrigen as date), getdate()) diasPass)dia
outer apply(select max(1)over(partition by t.IdExpediente) doc from Tramite.ExpedienteDocumentoFirmante ef
    where ef.IdExpedienteDocumento = t.IdExpedienteDocumento and ef.IdPersona = pp.pIdPersona and ef.EstadoAuditoria = 1)ef
outer apply(select distinct concat('<div style="margin: 2px;padding: 2px;" class="ui blue label">',
    t.NombreExpediente, '</div> ')ExEnlazadoPri
    from tmp001_expedienteEnlazado ee where ee.IdExpedienteSecundario = t.IdExpediente)enp
outer apply(select distinct concat('<div style="margin: 2px;padding: 2px;" class="ui blue label">',
    t.NombreExpediente, '</div> ')ExEnlazadoSec
    from tmp001_expedienteEnlazado ee where ee.IdExpediente = t.IdExpediente)ens
outer apply(select distinct t.IdExpediente, count(1)over(partition by ee.IdExpediente) cantEnlaces
    from tmp001_expedienteEnlazado ee where ee.IdExpedienteSecundario = t.IdExpediente)ee
outer apply(select*from tmp001_catalog c1 where c1.IdCatalogo = t.IdCatalogoTipoPrioridad)c1
outer apply(select*from tmp001_catalog c2 where c2.IdCatalogo = t.IdCatalogoTipoTramite)c2
outer apply(select*from tmp001_catalog c3 where c3.IdCatalogo = t.IdCatalogoTipoOrigen)c3
outer apply(select*from tmp001_catalog c4 where c4.IdCatalogo = t.IdCatalogoTipoDocumento)c4
outer apply(select*from General.Persona pe where pe.IdPersona = t.IdPersonaCreador)pe
outer apply(select max(IdExpedienteSeguimiento)over(partition by t.IdExpediente) IdExpedienteSeguimiento
    from Tramite.ExpedienteSeguimiento es
    where es.IdExpediente = t.IdExpediente and
    es.IdEmpresa = pp.vIdEmpresa and
    es.IdArea = pp.vIdArea and
    es.IdCargo = pp.vIdCargo and
    es.IdPersona = pp.pIdPersona and
    es.EstadoAuditoria = 1
)es
outer apply(select max(a.NombreArea)over(partition by t.IdExpediente) NombreArea from General.Area a where a.IdArea = t.IdAreaOrigen)a
outer apply(select max(rfp.RutaArchivoFoto)over(partition by t.IdExpediente) RutaArchivoFoto
    from tmp001_seguridadUsuario rfp
    where rfp.IdPersona = pe.IdPersona and isnull(rfp.RutaArchivoFoto, '') != '')rfp
outer apply(select sum(case when
    t.EsInicial = 1 and
    t.EsVinculado = 0 and
    t.IdCatalogoSituacionMovimientoDestino != 4 and
    t.FechaDestinoRecepciona = '' and
    t.IdempresaOrigen = pp.vIdEmpresa and
    t.IdAreaOrigen = pp.vIdArea and
    t.IdCargoOrigen = pp.vIdCargo and
    t.IdPersonaOrigen = pp.pIdPersona then 1 else 0 end
    )over(partition by t.IdExpediente) cant
)pa1
outer apply(select sum(case when
    t.EsInicial = 1 and
    t.EsVinculado = 0 and
    t.FechaDestinoRecepciona = '' and
    t.IdempresaOrigen = pp.vIdEmpresa and
    t.IdAreaOrigen = pp.vIdArea and
    t.IdCargoOrigen = pp.vIdCargo and
    t.IdPersonaOrigen = pp.pIdPersona then 1 else 0 end
    )over(partition by t.IdExpediente) cant
)pa2
outer apply(select max(case when
    t.IdCatalogoSituacionMovimientoDestino = pp.pIdCatalogoSituacionMovimientoDestino and
    t.FechaDestinoRecepciona = '' and
    t.IdAreaDestino = pp.vIdArea and
    t.IdPersonaDestino = pp.pIdPersona and
    t.IdCargoDestino = pp.vIdCargo and
    t.IdEmpresaDestino = pp.vIdEmpresa then iif(dia.diasPass < 0 , 0, dia.diasPass) else 0 end
    )over(partition by t.IdExpediente) DiasPendiente
)dp
outer apply(select concat(max(case when
    t.IdCatalogoSituacionMovimientoDestino in (4,5) and
    t.IdAreaDestino = pp.vIdArea and
    t.IdPersonaDestino = pp.pIdPersona and
    t.IdCargoDestino = pp.vIdCargo and
    isnull(t.IdempresaOrigen, 0) = 0 then t.NombreCompletoEmisor else a.NombreArea end
    )over(partition by t.IdExpediente), '; ') NombrePersonaOrigen
)np
outer apply(select max(case when
    t.IdCatalogoSituacionMovimientoDestino = pp.pIdCatalogoSituacionMovimientoDestino and
    t.IdAreaDestino = pp.vIdArea and
    t.IdPersonaDestino = pp.pIdPersona and
    t.IdCargoDestino = pp.vIdCargo then t.IdExpedienteDocumento end
    )over(partition by t.IdExpediente) IdExpedienteDocumento
)ied
outer apply(select max(case when
    t.IdCatalogoSituacionMovimientoDestino = pp.pIdCatalogoSituacionMovimientoDestino and
    t.IdAreaDestino = pp.vIdArea and
    t.IdPersonaDestino = pp.pIdPersona and
    t.IdCargoDestino = pp.vIdCargo then
        case when t.FgEnEsperaFirmaDigital = 1 and ef.doc = 0 then
            concat('<label style="font-size:8px">',
            case t.Correlativo when 0 then concat(c4.descripcion, ' ', t.NumeroDocumento) else t.NumeroDocumento end, '</label>')
        else
            concat('<button type="button" data-toggle="tooltip" title="',
            t.MotivoArchivado, '" class="btn ui blue label" onclick="MostrarDocumentoPdfExp(''',
            t.RutaArchivoDocumento, ''',', t.IdExpedienteDocumento,
            ')"><i style="font-size:16px;" class="fa fa-file-text"></i></button><label style="font-size:8px">',
            case t.Correlativo when 0 then concat(c4.descripcion, ' ', t.NumeroDocumento) else t.NumeroDocumento end, '</label>')
        end
    end)over(partition by t.IdExpediente) NumeroDocumento
)nd
order by t.FechaMovimiento desc
OFFSET (@pNumeroPagina-1)*@pDimensionPagina ROWS FETCH NEXT @pDimensionPagina ROWS ONLY

select count(1) from #tmp001_matriz

end else begin
    select
		 0 EsParaAnular,
		 0 DiasPendiente,
		'' NombrePersonaOrigen,
		'' NumeroDocumento,
		0 IdExpedienteDocumento,
		'' NombreExpedientesEnlazados,
		0 EsPrincipalEnlace,
		'' CatalogoTipoOrigen,
		0 IdExpediente,
		'' ExpedienteConfidencial,
		'' NTFechaExpediente,
		'' HoraExpediente,
		0 IdCatalogoTipoPrioridad,
		'' CatalogoTipoPrioridad,
		'' CatalogoTipoTramite,
		'' ColorCatalogoTipoTramite,
		'' Logueo,
		'sinfotoH.jpg' RutaFotoPersona,
		'' AsuntoExpediente,
		0 NumeroFoliosExpediente,
		'' ObservacionesExpediente,
		'' Fecha,
		'' NombreExpediente,
		'' NombreCompletoCreador,
		'' NumeroExpediente,
		0 IdExpedienteSeguimiento,
		'' FechaMovimiento
	select 0
end

-- set statistics xml off
-- set statistics io off
-- set statistics time off
