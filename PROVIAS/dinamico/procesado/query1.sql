ALTER PROCEDURE [Tramite].[paListarExpedientePendienteEspecialistaTodos_arq]
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
	@pDimensionPagina INT,
	@pBusquedaGeneral varchar(100),
	@pFlgBusqueda INT
AS
BEGIN
BEGIN TRY
set tran isolation level read uncommitted
set nocount on

create table #tmp001_expedientePendEsp (
    EsParaAnular bit,
    DiasPendiente int,
    NombrePersonaOrigen varchar(1) collate database_default,
    NumeroDocumento varchar(1) collate database_default,
    IdExpedienteDocumento int,
    NombreExpedientesEnlazados varchar(max) collate database_default,
    EsPrincipalEnlace bit,
    CatalogoTipoOrigen varchar(501) collate database_default,
    IdExpediente int,
    ExpedienteConfidencial bit,
    NTFechaExpediente varchar(10) collate database_default,
    HoraExpediente varchar(5) collate database_default,
    IdCatalogoTipoPrioridad int,
    CatalogoTipoPrioridad varchar(100) collate database_default,
    CatalogoTipoTramite varchar(100) collate database_default,
    ColorCatalogoTipoTramite varchar(100) collate database_default,
    Logueo varchar(100) collate database_default,
    RutaFotoPersona varchar(50) collate database_default,
    AsuntoExpediente varchar(8000) collate database_default,
    NumeroFoliosExpediente int,
    ObservacionesExpediente varchar(4000) collate database_default,
    Fecha varchar(20) collate database_default,
    NombreExpediente varchar(100) collate database_default,
    NombreCompletoCreador varchar(100) collate database_default,
    NumeroExpediente int,
    IdExpedienteSeguimiento int,
    FechaMovimiento datetime
)

    declare @conBus int, @vIdCargo int=0, @vIdArea int=0
    select @conBus = case when @pBusquedaGeneral is null or @pBusquedaGeneral = '' or isnumeric(@pBusquedaGeneral) = 0 then 1 else 0 end

    select @vIdCargo = IdCargo, @vIdArea = IdArea
    from recursoHumano.EmpleadoPerfil
    where   IdEmpresaSede   = 1
        and EstadoAuditoria = 1
        and Activo = 1
        and IdEmpleadoPerfil = @pIdEmpleadoPerfil

	create table #MITABLA(
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
    	FechaMovimiento datetime,
        sexo bit,
     )

	if @conBus = 1
    begin
    	select
    	    0 EsParaAnular,
    		0 DiasPendiente,
    		'' NombrePersonaOrigen,
    		'' NumeroDocumento,
    		0 IdExpedienteDocumento,
    		''NombreExpedientesEnlazados,
    		CONVERT(BIT,0) EsPrincipalEnlace,
    		'' CatalogoTipoOrigen,
    		0 IdExpediente,
    		0 ExpedienteConfidencial,
    		'' NTFechaExpediente,
    		'' HoraExpediente,
    		0 IdCatalogoTipoPrioridad,
    		'' CatalogoTipoPrioridad,
    		'' CatalogoTipoTramite,
    		'' ColorCatalogoTipoTramite,
    		'' Logueo,
    		'' RutaFotoPersona,
    		'' AsuntoExpediente,
    		0 NumeroFoliosExpediente,
    		'' ObservacionesExpediente,
    		'' Fecha,
    		'' NombreExpediente,
    		'' NombreCompletoCreador,
    		0 NumeroExpediente,
    		0 IdExpedienteSeguimiento,
    		null FechaMovimiento
    	select 0
    	return;
    end
	SET LANGUAGE SPANISH

	DECLARE @sql NVARCHAR(MAX) = N'
	;with tmp001_serieDocumental as(
    select*from(values(1,''E-''),(2,''I-''))sd(IdSerieDocumentalExpediente, AbreviaturaSerieDocumentalExpediente))
	insert into #MITABLA select top 1000
       t1.IdExpediente,
       t1.ExpedienteConfidencial,
       t1.NTFechaExpediente,
       t1.HoraExpediente,
       t1.IdCatalogoTipoPrioridad,
       isnull(c1.Descripcion,'''') CatalogoTipoPrioridad,
       isnull(c2.Descripcion,'''') CatalogoTipoTramite,
       isnull(c2.Detalle,'''') ColorCatalogoTipoTramite,
       isnull(su.Logueo, '''') Logueo,
       t1.IdPersonaCreador,
       UPPER(t1.AsuntoExpediente) AsuntoExpediente,
       isnull(t1.NumeroFoliosExpediente,0)NumeroFoliosExpediente,
       isnull(t1.ObservacionesExpediente,'''') ObservacionesExpediente,
       concat(t1.NTFechaExpediente ,'' '', t1.HoraExpediente) Fecha,
       concat(sd.AbreviaturaSerieDocumentalExpediente, right(1000000+t1.NumeroExpediente,6),''-'', t1.IdPeriodo) NombreExpediente,
       isnull(t1.NombreCompletoCreador, p.NombreCompleto) NombreCompletoCreador,
       t1.NumeroExpediente,
       isnull(ss.IdExpedienteSeguimiento, 0 )IdExpedienteSeguimiento,
       NULL FechaMovimiento,
       p.sexo
	from Tramite.Expediente_Historico_' + cast(@pIdPeriodo as varchar) + N' t1
    inner join tmp001_serieDocumental sd
        on sd.IdSerieDocumentalExpediente = t1.IdSerieDocumentalExpediente
    inner join Seguridad.Usuario su
        on su.IdUsuario = t1.IdUsuarioCreacionAuditoria
    inner join Tramite.Catalogo c1
        on c1.IdCatalogo = t1.IdCatalogoTipoPrioridad
    left join Tramite.Catalogo c2
        on c2.IdCatalogo = t1.IdCatalogoTipoTramite
    left join General.Persona p
        on p.IdPersona = t1.IdPersonaCreador
    left join Tramite.ExpedienteSeguimiento_Historico_' + cast(@pIdPeriodo as varchar) + N' ss
        on  ss.IdExpediente = t1.IdExpediente
        and ss.IdArea    = @vIdArea
        and ss.IdCargo   = @vIdCargo
        and ss.IdPersona = @pIdPersona
        and ss.EstadoAuditoria   = 1
        and ss.IdEmpresa = 2
    where   t1.EstadoAuditoria   = 1
        and t1.ExpedienteAnulado = 0
        and t1.IdSerieDocumentalExpediente in (1,2)
        and t1.NumeroExpediente = @pBusquedaGeneral
    order by t1.IdExpediente desc'

    EXEC sp_executesql @sql,
        N'@vIdArea INT, @vIdCargo INT, @pIdPersona INT, @pBusquedaGeneral varchar(100)',
        @vIdArea = @vIdArea,
        @vIdCargo = @vIdCargo,
        @pIdPersona = @pIdPersona,
        @pBusquedaGeneral = @pBusquedaGeneral

    select @sql = null
    select @sql = N'
    ;with tmp001_serieDocumental as(
        select*from(values(1,''E-''),(2,''I-''))sd(IdSerieDocumentalExpediente, AbreviaturaSerieDocumentalExpediente))
    ,tmp001_NombreExpediente(cab1, cab2)as(
        select ''<div style="margin: 2px;padding: 2px;" class="ui blue label">'', ''</div>'')
    insert into #tmp001_expedientePendEsp
    select
        0 EsParaAnular, 0 DiasPendiente,'''' NombrePersonaOrigen,'''' NumeroDocumento,
        0 IdExpedienteDocumento, isnull(x.NombreExpedientesEnlazados, '''') NombreExpedientesEnlazados,
        case when x.NombreExpedientesEnlazados is null then 0 else 1 end EsPrincipalEnlace,
        cat.CatalogoTipoOrigen,t.IdExpediente,t.ExpedienteConfidencial,
  		t.NTFechaExpediente,t.HoraExpediente,t.IdCatalogoTipoPrioridad,t.CatalogoTipoPrioridad,
  		t.CatalogoTipoTramite,t.ColorCatalogoTipoTramite,t.Logueo,rf.RutaFotoPersona,t.AsuntoExpediente,
  		t.NumeroFoliosExpediente,t.ObservacionesExpediente,t.Fecha,t.NombreExpediente,t.NombreCompletoCreador,
  		t.NumeroExpediente,t.IdExpedienteSeguimiento,t.FechaMovimiento
    from #MITABLA t
    outer apply (
        SELECT (select cb.cab1, AbreviaturaSerieDocumentalExpediente, right(1000000+NumeroExpediente,6),''-'', IdPeriodo, cb.cab2
        FROM (
            SELECT ex.NumeroExpediente, ex.IdPeriodo, s.AbreviaturaSerieDocumentalExpediente, ee.IdExpedienteEnlazado orden
            FROM Tramite.ExpedienteEnlazado_Historico_' + cast(@pIdPeriodo as varchar) + N' ee
            INNER JOIN Tramite.Expediente_Historico_' + cast(@pIdPeriodo as varchar) + N' ex
                ON  ex.IdExpediente = ee.IdExpedienteSecundario
                AND ex.EstadoAuditoria   = 1
                AND ex.ExpedienteAnulado = 0
                AND ex.IdSerieDocumentalExpediente in (1,2)
            INNER JOIN tmp001_serieDocumental s
                ON s.IdSerieDocumentalExpediente = ex.IdSerieDocumentalExpediente
            WHERE ee.IdExpediente = t.IdExpediente
                AND ee.EstadoAuditoria = 1
            UNION ALL
            SELECT ex.NumeroExpediente, ex.IdPeriodo, s.AbreviaturaSerieDocumentalExpediente, ee.IdExpedienteEnlazado
            FROM Tramite.ExpedienteEnlazado_Historico_' + cast(@pIdPeriodo as varchar) + N' ee
            INNER JOIN Tramite.Expediente_Historico_' + cast(@pIdPeriodo as varchar) + N' ex
                ON  ex.IdExpediente = ee.IdExpediente
                AND ex.EstadoAuditoria   = 1
                AND ex.ExpedienteAnulado = 0
                AND ex.IdSerieDocumentalExpediente in (1,2)
            INNER JOIN tmp001_serieDocumental s
                ON s.IdSerieDocumentalExpediente = ex.IdSerieDocumentalExpediente
            WHERE ee.IdExpedienteSecundario = t.IdExpediente
                AND ee.EstadoAuditoria = 1
        )Q cross apply tmp001_NombreExpediente cb
        ORDER BY orden
        for xml path, type).value(''.'',''varchar(max)'') NombreExpedientesEnlazados
    )x
    outer apply(
        select top 1 concat(c.Descripcion, '' '', e.NumeroExpedienteExterno) CatalogoTipoOrigen
        from Tramite.Expediente_Historico_' + cast(@pIdPeriodo as varchar) + N' e
        inner join Tramite.ExpedienteDocumento_Historico_' + cast(@pIdPeriodo as varchar) + N' tt
            on  tt.IdExpediente = e.IdExpediente
            and tt.EstadoAuditoria = 1
        inner join Tramite.Catalogo c
            on  c.IdCatalogo   = tt.IdCatalogoTipoOrigen
        where   e.IdExpediente = t.IdExpediente
            and e.EstadoAuditoria = 1
        order by tt.IdExpedienteDocumento
    )cat
    outer apply(
        select top 1
            case when u.RutaArchivoFoto is null or u.RutaArchivoFoto = ''''
            then iif(t.sexo = 0, ''sinfotoH.jpg'', ''sinfotoM.jpg'') else u.RutaArchivoFoto end RutaFotoPersona
        from Seguridad.Usuario u
        where   u.IdPersona = t.IdPersonaCreador
            and u.EstadoAuditoria = 1
            and u.Bloqueado = 0
    )rf
    ORDER BY IdExpediente DESC
    OFFSET (@pNumeroPagina-1)*@pDimensionPagina ROWS
    FETCH NEXT @pDimensionPagina ROWS ONLY'

    EXEC sp_executesql @sql,
            N'@pNumeroPagina INT, @pDimensionPagina INT',
            @pNumeroPagina = @pNumeroPagina,
            @pDimensionPagina = @pDimensionPagina

    select*from #tmp001_expedientePendEsp
    select count(*) from #MITABLA

END TRY
BEGIN CATCH
	DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
	SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarExpedientePendienteEspecialistaTodos_arq',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE, @pIdUsuarioAuditoria
END CATCH
END
GO


-- exec Tramite.paListarExpedientePendienteEspecialistaTodos_arq
-- @pConFiltroFecha=0,
-- @pFechaInicio='19/05/2026',
-- @pFechaFin='19/05/2026',
-- @pConFiltroFechaMovimiento=1,
-- @pFechaInicioMovimiento='19/05/2026',
-- @pFechaFinMovimiento='19/05/2026',
-- @pIdPersona=350,
-- @pIdEmpleadoPerfil=2260,
-- @pIdCatalogoSituacionMovimientoDestino=0,
-- @pTipoSituacionMovimiento=0,
-- @pIdAreaOrigen=0,
-- @pIdAreaDestino=0,
-- @pIdPeriodo=2025,
-- @pIdCatalogoTipoPrioridad=0,
-- @pIdCatalogoTipoTramite=0,
-- @pIdCatalogoTipoDocumento=0,
-- @pNumeroExpediente='',
-- @pNumeroDocumento='',
-- @pPersonaDesde='',
-- @pPersonaPara='',
-- @pIdTipoIngreso=0,
-- @pFechaDocumento='',
-- @pEmisorExpediente='',
-- @pAsuntoExpediente='',
-- @pIdUsuarioAuditoria=350,
-- @pCampoOrdenado=NULL,
-- @pTipoOrdenacion=NULL,
-- @pNumeroPagina=1,
-- @pDimensionPagina=10,
-- @pBusquedaGeneral='11477',
-- @pFlgBusqueda=0
