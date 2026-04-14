-- if exists(select 1 from sys.sysobjects where id = object_id('[Tramite].[paListarExpedientePendienteEspecialistaPorRecibir_new]','p'))
-- drop procedure [Tramite].[paListarExpedientePendienteEspecialistaPorRecibir_new]
-- go
-- CREATE PROCEDURE [Tramite].[paListarExpedientePendienteEspecialistaPorRecibir_new]
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
-- As
-- begin
-- begin try
set tran isolation level read uncommitted
set nocount on

-- select
--     @pConFiltroFecha= 0,
-- 	@pFechaInicio= '14/04/2026',
-- 	@pFechaFin= '14/04/2026',
-- 	@pConFiltroFechaMovimiento= 0,
-- 	@pFechaInicioMovimiento= '14/04/2026',
-- 	@pFechaFinMovimiento= '14/04/2026',
-- 	@pIdPersona= 728,
-- 	@pIdEmpleadoPerfil= 727,
-- 	@pIdCatalogoSituacionMovimientoDestino= 4,
-- 	@pTipoSituacionMovimiento= 4,
-- 	@pIdAreaOrigen= 0,
-- 	@pIdAreaDestino= 0,
-- 	@pIdPeriodo= 2026,
-- 	@pIdCatalogoTipoPrioridad= 0,
-- 	@pIdCatalogoTipoTramite= 0,
-- 	@pIdCatalogoTipoDocumento= 0,
-- 	@pNumeroExpediente= '',
-- 	@pNumeroDocumento= '',
-- 	@pPersonaDesde= '',
-- 	@pPersonaPara= '',
-- 	@pIdTipoIngreso= 0,
-- 	@pFechaDocumento= '',
-- 	@pEmisorExpediente= '',
-- 	@pAsuntoExpediente= '',
-- 	@pIdUsuarioAuditoria= 728,
-- 	@pCampoOrdenado= null,
-- 	@pTipoOrdenacion= null,
-- 	@pNumeroPagina= 1,
-- 	@pDimensionPagina= 10,
-- 	@pBusquedaGeneral= null,
-- 	@pFlgBusqueda= 0


SELECT
@pConFiltroFecha=0,
@pFechaInicio='13/04/2026',
@pFechaFin='13/04/2026',
@pConFiltroFechaMovimiento=0,
@pFechaInicioMovimiento='13/04/2026',
@pFechaFinMovimiento='13/04/2026',
@pIdPersona=590,
@pIdEmpleadoPerfil=588,
@pIdCatalogoSituacionMovimientoDestino=4,
@pTipoSituacionMovimiento=4,
@pIdAreaOrigen=0,
@pIdAreaDestino=0,
@pIdPeriodo=2026,
@pIdCatalogoTipoPrioridad=0,
@pIdCatalogoTipoTramite=0,
@pIdCatalogoTipoDocumento=0,
@pNumeroExpediente='',
@pNumeroDocumento='',
@pPersonaDesde='',
@pPersonaPara='',
@pIdTipoIngreso=0,
@pFechaDocumento='',
@pEmisorExpediente='',
@pAsuntoExpediente='',
@pIdUsuarioAuditoria=590,
@pCampoOrdenado=NULL,
@pTipoOrdenacion=NULL,
@pNumeroPagina=1,
@pDimensionPagina=100,
@pBusquedaGeneral=NULL,
@pFlgBusqueda=0




create table #tmp001_expediente (
	IdExpediente int,
	ExpedienteConfidencial bit,
	NTFechaExpediente varchar (10),
	HoraExpediente varchar (5),
	IdCatalogoTipoPrioridad int,
	CatalogoTipoPrioridad varchar (100),
	CatalogoTipoTramite varchar (100),
	ColorCatalogoTipoTramite varchar (100),
	Logueo varchar (100),
	IdPersonaCreador int,
	AsuntoExpediente varchar (8000),
	NumeroFoliosExpediente int,
	ObservacionesExpediente varchar(4000),
	Fecha VARCHAR(20),
	NombreExpediente varchar (100),
	NombreCompletoCreador varchar (100),
	NumeroExpediente int,
	IdExpedienteSeguimiento int,
	NumeroExpedienteExterno varchar(100),
	FechaMovimiento datetime,
	IdCatalogoTipoOrigen int
)
create table #tmp001_matriz(
    IdExpediente int primary key,
    FechaMovimiento datetime
)
create table #tmp001_orden(
    item int identity,
    IdExpediente int
)

declare @vIdCargo int = 0, @vIdArea int = 0, @vIdEmpresa int = 2

select @vIdArea = t.IdArea, @vIdCargo = t.IdCargo, @pBusquedaGeneral = nullif(rtrim(ltrim(@pBusquedaGeneral)),'')
from RecursoHumano.EmpleadoPerfil t
where t.IdEmpresaSede = 1 and t.EstadoAuditoria = 1 and t.activo = 1 and t.IdEmpleadoPerfil = @pIdEmpleadoPerfil

if @pIdPersona > 0 and (try_convert(int, @pBusquedaGeneral) is not null or @pBusquedaGeneral is null) begin
    set language 'spanish'

    ;with tmp001_serieDocumental as(
        select*from(values(1,'E-'),(2,'I-'))sd(IdSerieDocumentalExpediente, AbreviaturaSerieDocumentalExpediente)
    )
    insert into #tmp001_matriz
    select top 1 with ties
        t1.IdExpediente, t4.fechaCreacionAuditoria
    from tramite.Expediente t1
    inner join tramite.ExpedienteDocumento t2
        on t2.idExpediente = t1.idExpediente and t2.EstadoAuditoria = 1 and t2.FgEnEsperaFirmaDigital = 0
    inner join tramite.ExpedienteDocumentoOrigen t3
        on t3.idExpedienteDocumento = t2.idExpedienteDocumento and t3.estadoAuditoria = 1
    inner join tramite.ExpedienteDocumentoOrigenDestino t4
        on t4.idExpedienteDocumentoOrigen = t3.idExpedienteDocumentoOrigen and t4.EstadoAuditoria = 1 and
            t4.IdPersonaDestino = @pIdPersona and
            t4.IdAreaDestino = @vIdArea and
            t4.IdCargoDestino = @vIdCargo and
            t4.IdEmpresaDestino = @vIdEmpresa and
            t4.IdCatalogoSituacionMovimientoDestino = 4
    inner join tmp001_serieDocumental sd on sd.IdSerieDocumentalExpediente = t1.IdSerieDocumentalExpediente
    where t1.estadoAuditoria = 1 and t1.ExpedienteAnulado = 0 and
            t1.NumeroExpediente = isnull(@pBusquedaGeneral, t1.NumeroExpediente)
    order by row_number()over(partition by t1.IdExpediente order by t4.fechaCreacionAuditoria desc)

    SELECT
        t.idExpediente,
        x.IdCatalogoTipoOrigen
    INTO #tmp001_catologoTipoOrigen
    FROM #tmp001_matriz t
    CROSS APPLY (
        SELECT TOP 1
            ed.idExpedienteDocumento,
            ed.IdCatalogoTipoOrigen
        FROM tramite.ExpedienteDocumento ed
        WHERE ed.idExpediente = t.idExpediente
        ORDER BY ed.idExpedienteDocumento ASC
    ) x

    ;with tmp001_serieDocumental as(
        select*from(values(1,'E-'),(2,'I-'))sd(IdSerieDocumentalExpediente, AbreviaturaSerieDocumentalExpediente)
    )
    insert into #tmp001_expediente
    select
        t.IdExpediente,
        t.ExpedienteConfidencial,
        convert(varchar, m.FechaMovimiento, 103)  NTFechaExpediente,
        convert(char(5), m.FechaMovimiento, 108) HoraExpediente,
        t.IdCatalogoTipoPrioridad,
        c1.descripcion CatalogoTipoPrioridad,
        c2.descripcion CatalogoTipoTramite,
        c2.detalle ColorCatalogoTipoTramite,
        su.Logueo,
        t.IdPersonaCreador,
        t.AsuntoExpediente,
        t.NumeroFoliosExpediente,
        isnull(t.ObservacionesExpediente, '') ObservacionesExpediente,
        concat(convert(varchar, t.fechaCreacionAuditoria, 103), ' ', convert(char(5), t.fechaCreacionAuditoria, 108)) Fecha,
        CONCAT(SD.AbreviaturaSerieDocumentalExpediente, RIGHT(1000000 + t.NumeroExpediente,6), '-', t.IdPeriodo) NombreExpediente,
        isnull(t.NombreCompletoCreador, pe.NombreCompleto) NombreCompletoCreador,
        t.NumeroExpediente,
        isnull(es.IdExpedienteSeguimiento, 0) IdExpedienteSeguimiento,
        t.NumeroExpedienteExterno,
        m.FechaMovimiento,
        tt.IdCatalogoTipoOrigen
    from  tramite.Expediente t
    inner join  #tmp001_matriz m  on m.idExpediente = t.idExpediente
    inner join Seguridad.Usuario su on su.IdUsuario = t.IdUsuarioCreacionAuditoria and su.EstadoAuditoria = 1
    inner join tmp001_serieDocumental sd on sd.IdSerieDocumentalExpediente = t.IdSerieDocumentalExpediente
    inner join #tmp001_catologoTipoOrigen tt on tt.idExpediente = t.idExpediente
    outer apply(select*from tramite.catalogo c1 where c1.IdCatalogo = t.IdCatalogoTipoPrioridad)c1
    outer apply(select*from Tramite.ExpedienteSeguimiento es
        where es.IdExpediente = t.IdExpediente and
        es.EstadoAuditoria = 1 and
        es.IdEmpresa = @vIdEmpresa and
        es.IdCargo = @vIdCargo and
        es.IdPersona = @pIdPersona and
        es.IdArea = @vIdArea
    )es
    outer apply(select*from General.Persona pe where pe.IdPersona = t.IdPersonaCreador)pe
    outer apply(select*from tramite.catalogo c2 where c2.IdCatalogo = t.IdCatalogoTipoTramite)c2
    order by m.FechaMovimiento desc
	OFFSET (@pNumeroPagina-1)*@pDimensionPagina ROWS
	FETCH NEXT @pDimensionPagina ROWS ONLY

	insert into #tmp001_orden
    select distinct idExpediente from #tmp001_expediente order by idExpediente desc

select
    isnull(convert(bit,case when pa1.cant>0 then 0 when pa2.cant>0 then 1 else 0 end),0) EsParaAnular,
    isnull(datediff(dd, convert(date, t3.FechaOrigen), getdate()), 0) DiasPendiente,
    concat(isnull(np.NombrePersonaOrigen,''), case isnull(np.NombrePersonaOrigen,'') when '' then '' else '; ' end)  NombrePersonaOrigen,
    isnull(nd.NumeroDocumento,'') NumeroDocumento,
    t2.IdExpedienteDocumento,
    isnull(case when enp.ExEnlazadoPri != '' then replace(replace(enp.ExEnlazadoPri,'&lt;','<'),'&gt;','>')
    else replace(replace(ens.ExEnlazadoSec,'&lt;','<'),'&gt;','>') end, '') NombreExpedientesEnlazados,
    isnull(convert(bit, case when ee.cantEnlaces > 0 then 1 else 0 end), 0) EsPrincipalEnlace,
    concat(c3.descripcion,' ', t.NumeroExpedienteExterno) CatalogoTipoOrigen,
    t.IdExpediente,
    t.ExpedienteConfidencial,
    t.NTFechaExpediente,
    t.HoraExpediente,
    isnull(t.IdCatalogoTipoPrioridad,0) IdCatalogoTipoPrioridad,
    t.CatalogoTipoPrioridad,
    t.CatalogoTipoTramite,
    t.ColorCatalogoTipoTramite,
    t.Logueo,
    iif(isnull(rfp.RutaArchivoFoto, '') = '', case when isnull(pe.sexo, 0) = 0 then 'sinfotoH.jpg' else 'sinfotoM.jpg' end,
    rfp.RutaArchivoFoto) RutaFotoPersona,
    t.AsuntoExpediente,
    isnull(t.NumeroFoliosExpediente, 0) NumeroFoliosExpediente,
    t.ObservacionesExpediente,
    t.Fecha,
    t.NombreExpediente,
    t.NombreCompletoCreador,
    t.NumeroExpediente,
    isnull(t.IdExpedienteSeguimiento,0) IdExpedienteSeguimiento,
    isnull(t.FechaMovimiento,'') FechaMovimiento,
    o.item
into #tmp001_resultset
from #tmp001_expediente t
inner join #tmp001_orden o
    on t.IdExpediente = o.IdExpediente
inner join tramite.ExpedienteDocumento t2 on t2.IdExpediente = t.IdExpediente and t2.EstadoAuditoria = 1
inner join tramite.ExpedienteDocumentoOrigen t3 on t3.idExpedienteDocumento = t2.idExpedienteDocumento and t3.estadoAuditoria = 1
inner join tramite.ExpedienteDocumentoOrigenDestino t4
    on t4.idExpedienteDocumentoOrigen = t3.idExpedienteDocumentoOrigen and t4.estadoAuditoria = 1
inner join tramite.catalogo c3 on c3.IdCatalogo = t.IdCatalogoTipoOrigen
left join tramite.catalogo c4 on c4.IdCatalogo = t2.IdCatalogoTipoDocumento
left join General.Persona pe on pe.IdPersona = t.IdPersonaCreador
outer apply(select max(1)over(partition by t.IdExpediente) doc from Tramite.ExpedienteDocumentoFirmante ef
    where ef.IdExpedienteDocumento = t2.IdExpedienteDocumento and ef.IdPersona = @pIdPersona and ef.EstadoAuditoria = 1)ef
outer apply(select distinct concat('<div style="margin: 2px;padding: 2px;" class="ui blue label">',
    t.NombreExpediente, '</div> ')ExEnlazadoPri
    from tramite.ExpedienteEnlazado ee where ee.IdExpedienteSecundario = t.IdExpediente and ee.EstadoAuditoria = 1)enp
outer apply(select distinct concat('<div style="margin: 2px;padding: 2px;" class="ui blue label">',
    t.NombreExpediente, '</div> ')ExEnlazadoSec
    from tramite.ExpedienteEnlazado ee where ee.IdExpediente = t.IdExpediente and ee.EstadoAuditoria = 1)ens
outer apply(select distinct t.IdExpediente, count(1)over(partition by ee.IdExpediente) cantEnlaces
    from tramite.ExpedienteEnlazado ee where ee.IdExpedienteSecundario = t.IdExpediente and ee.EstadoAuditoria = 1)ee
outer apply(select max(IdExpedienteSeguimiento)over(partition by t.IdExpediente) IdExpedienteSeguimiento
    from Tramite.ExpedienteSeguimiento es
    where es.IdExpediente = t.IdExpediente and
    es.IdEmpresa = @vIdEmpresa and
    es.IdArea = @vIdArea and
    es.IdCargo = @vIdCargo and
    es.IdPersona = @pIdPersona and
    es.EstadoAuditoria = 1
)es
outer apply(select max(a.NombreArea)over(partition by t.IdExpediente) NombreArea from General.Area a where a.IdArea = t3.IdAreaOrigen)a
outer apply(select max(rfp.RutaArchivoFoto)over(partition by t.IdExpediente) RutaArchivoFoto
    from Seguridad.Usuario rfp
    where rfp.IdPersona = pe.IdPersona and isnull(rfp.RutaArchivoFoto, '') != '' and rfp.EstadoAuditoria = 1 and rfp.Bloqueado = 0)rfp
outer apply(select sum(case when
    t4.EsInicial = 1 and
    t3.EsVinculado = 0 and
    t4.IdCatalogoSituacionMovimientoDestino != 4 and
    t4.FechaDestinoRecepciona = '' and
    t3.IdempresaOrigen = @vIdEmpresa and
    t3.IdAreaOrigen = @vIdArea and
    t3.IdCargoOrigen = @vIdCargo and
    t3.IdPersonaOrigen = @pIdPersona then 1 else 0 end
    )over(partition by t.IdExpediente) cant
)pa1
outer apply(select sum(case when
    t4.EsInicial = 1 and
    t3.EsVinculado = 0 and
    t4.FechaDestinoRecepciona = '' and
    t3.IdempresaOrigen = @vIdEmpresa and
    t3.IdAreaOrigen = @vIdArea and
    t3.IdCargoOrigen = @vIdCargo and
    t3.IdPersonaOrigen = @pIdPersona then 1 else 0 end
    )over(partition by t.IdExpediente) cant
)pa2
outer apply(select max(case when
    t4.IdCatalogoSituacionMovimientoDestino in (4,5) and
    isnull(t3.IdempresaOrigen, 0) = 0 and
    t4.IdAreaDestino = @vIdArea and
    t4.IdCargoDestino = @vIdCargo and
    t4.IdPersonaDestino = @pIdPersona then t2.NombreCompletoEmisor else a.NombreArea end
    )over(partition by t.IdExpediente) NombrePersonaOrigen
)np
outer apply(select max(case when
    t4.IdCatalogoSituacionMovimientoDestino = @pIdCatalogoSituacionMovimientoDestino and
    t4.IdAreaDestino = @vIdArea and
    t4.IdCargoDestino = @vIdCargo and
    t4.IdPersonaDestino = @pIdPersona then
        case when t2.FgEnEsperaFirmaDigital = 1 and ef.doc = 0 then
            concat('<label style="font-size:8px">',
            case t2.Correlativo when 0 then concat(c4.descripcion, ' ', t2.NumeroDocumento) else t2.NumeroDocumento end,
            '</label>')
        else
            concat('<button type="button" data-toggle="tooltip" title="',
            t4.MotivoArchivado, '" class="btn ui blue label" onclick="MostrarDocumentoPdfExp(''',
            t2.RutaArchivoDocumento, ''',', t2.IdExpedienteDocumento,
            ')"><i style="font-size:16px;" class="fa fa-file-text"></i></button><label style="font-size:8px">',
            case t2.Correlativo when 0 then concat(c4.descripcion, ' ', t2.NumeroDocumento) else t2.NumeroDocumento end,
            '</label>')
        end
    end)over(partition by t.IdExpediente) NumeroDocumento
)nd

select
    EsParaAnular,
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
from(select *, row_number()over(partition by item order by item, IdExpedienteDocumento desc, NumeroDocumento desc) nro
from #tmp001_resultset)t where t.nro = 1 order by t.item


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

-- END TRY
-- BEGIN CATCH
-- 		DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
-- 		SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarExpedientePendienteEspecialistaPorRecibir',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
-- 		EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE, @pIdUsuarioAuditoria
-- END CATCH
-- END
-- go
