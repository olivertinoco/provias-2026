ALTER PROCEDURE [Tramite].[paListarExpedienteBusquedaPendiente_arq]
	@pIdUsuarioAuditoria int,
	@pCampoOrdenado varchar(50),
	@pTipoOrdenacion varchar(4),
	@pNumeroPagina INT,
	@pDimensionPagina  INT,
	@pBusquedaGeneral varchar(100),
	@pIdPeriodo INT,
	@pIdSerieDocumental INT,
    @pNombreProyecto varchar(1000),
    @pNumeroExpediente  varchar(1000),
    @pFechaExpediente  varchar(1000),
    @pAsuntoExpediente  varchar(1000),
    @pIdCatategoriaExpediente INT,
    @pIdPrioridadExpediente INT,
    @pNumeroDocumento varchar(50),
    @pFechaDocumento varchar(10),
    @pIdCatalogoTipoDocumento INT,
    @pAsuntoDocumento varchar(1000),
	@pIdAreaOrigen INT,
	@pIdAreaDestino INT,
	@pIdCargoOrigen INT,
	@pIdCargoDestino INT,
	@pEmisor varchar(1000),
    @pDestinatario  varchar(1000)
AS
BEGIN
BEGIN TRY
SET TRAN ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON
SET LANGUAGE SPANISH

	DECLARE @vIdPeriodo varchar(4)= convert(varchar, @pIdPeriodo)
	DECLARE @Consulta Nvarchar(max)=''
	DECLARE @ConsultaTotal Nvarchar(max)=''
	DECLARE @Filtros varchar(max)=''
	DECLARE @Offset NVARCHAR(MAX)='';
	DECLARE @Fetch NVARCHAR(MAX)='';
	DECLARE @Orden NVARCHAR(MAX)='';
	DECLARE @Parametros NVARCHAR(MAX)='';
	DECLARE @Documentos NVARCHAR(MAX)='';
	DECLARE @pTotalRegistros  INT;
	DECLARE @FiltroExpediente varchar(max)=''

	IF COALESCE(@pIdAreaDestino,0)<>0
	BEGIN
		IF @pIdAreaDestino=-1
			SET @FiltroExpediente =@FiltroExpediente+ ' AND EDOD.IdAreaDestino =0'
		ELSE
			SET @FiltroExpediente =@FiltroExpediente+ ' AND EDOD.IdAreaDestino ='+CONVERT(VARCHAR,@pIdAreaDestino)
	END
	IF COALESCE(@pIdCargoDestino,0)<>0
	BEGIN
		IF @pIdCargoDestino=-1
			SET @FiltroExpediente =@FiltroExpediente+ ' AND EDOD.IdCargoDestino =0'
		ELSE
			SET @FiltroExpediente =@FiltroExpediente+ ' AND EDOD.IdCargoDestino ='+CONVERT(VARCHAR,@pIdCargoDestino)
	END
	IF COALESCE(@pIdAreaOrigen,0)<>0
	BEGIN
		IF @pIdAreaOrigen=-1
			SET @FiltroExpediente =@FiltroExpediente+ ' AND EDO.IdAreaOrigen =0'
		ELSE
			SET @FiltroExpediente =@FiltroExpediente+ ' AND ED.IdAreaEmisor ='+CONVERT(VARCHAR,@pIdAreaOrigen)
	END
	IF COALESCE(@pIdCargoOrigen,0)<>0
	BEGIN
		IF @pIdCargoOrigen=-1
			SET @FiltroExpediente =@FiltroExpediente+ ' AND EDO.IdCargoOrigen =0'
		ELSE
			SET @FiltroExpediente =@FiltroExpediente+ ' AND ED.IdCargoEmisor ='+CONVERT(VARCHAR,@pIdCargoOrigen)
	END

	DECLARE @vIdPersonaU int
	SELECT @vIdPersonaU=IdPersona FROM Seguridad.Usuario WHERE IdUsuario= @pIdUsuarioAuditoria

	IF COALESCE(@pIdPeriodo,0)<>0 BEGIN
	SET @FiltroExpediente =@FiltroExpediente+ ' AND E.IdPeriodo ='+CONVERT(VARCHAR,@pIdPeriodo) END
	IF COALESCE(@pIdSerieDocumental,0)<>0 BEGIN
	SET @FiltroExpediente =@FiltroExpediente+ ' AND E.IdSerieDocumentalExpediente ='+CONVERT(VARCHAR,@pIdSerieDocumental) END
	IF COALESCE(@pIdCatategoriaExpediente,0)<>0 BEGIN
	SET @FiltroExpediente =@FiltroExpediente+ ' AND E.IdCatalogoTipoTramite ='+CONVERT(VARCHAR,@pIdCatategoriaExpediente) END
	IF COALESCE(@pIdPrioridadExpediente,0)<>0 BEGIN
	SET @FiltroExpediente =@FiltroExpediente+ ' AND E.IdCatalogoTipoPrioridad ='+CONVERT(VARCHAR,@pIdPrioridadExpediente) END
	IF COALESCE(@pIdCatalogoTipoDocumento,0)<>0 BEGIN
	SET @FiltroExpediente =@FiltroExpediente+ ' AND ED.IdCatalogoTipoDocumento ='+CONVERT(VARCHAR,@pIdCatalogoTipoDocumento) END
	IF COALESCE(@pAsuntoExpediente,'')<>'' BEGIN
	SET @FiltroExpediente =@FiltroExpediente+' AND E.AsuntoExpediente LIKE ''%'+@pAsuntoExpediente +'%'''END
	IF COALESCE(@pAsuntoDocumento,'')<>'' BEGIN
	SET @FiltroExpediente =@FiltroExpediente+' AND ED.AsuntoDocumento LIKE ''%'+@pAsuntoDocumento +'%'''END
	IF COALESCE(@pFechaDocumento,'')<>'' BEGIN
	SET @FiltroExpediente =@FiltroExpediente+' AND ED.NFechaDocumento LIKE ''%'+@pFechaDocumento+'%''' END
	IF COALESCE(@pNumeroDocumento,'')<>'' BEGIN
	SET @FiltroExpediente =@FiltroExpediente+' AND ED.NumeroDocumento LIKE ''%'+@pNumeroDocumento +'%'''END
	IF COALESCE(@pNumeroExpediente,'')<>'' BEGIN
	SET @FiltroExpediente =@FiltroExpediente+' AND SD.AbreviaturaSerieDocumentalExpediente +RIGHT(''000000''+CONVERT(VARCHAR,E.NumeroExpediente),6) LIKE ''%' +@pNumeroExpediente+'%''' END
	IF COALESCE(@pEmisor,'')<>'' BEGIN
	SET @FiltroExpediente =@FiltroExpediente+' AND (PD.NombreCompleto LIKE ''%'+@pEmisor +'%'' or  E.NombreCompletoCreador LIKE ''%'+@pEmisor +'%'')' END

	SET @Orden=' ORDER BY E.IdExpediente desc'
	SET @Offset= ' OFFSET ' +CONVERT(VARCHAR(10),(@pNumeroPagina-1)*@pDimensionPagina) + ' ROWS '
	SET @Fetch= ' FETCH NEXT '+CONVERT(VARCHAR(10),@pDimensionPagina) +' ROWS ONLY'

	if ISNUMERIC(@pBusquedaGeneral)=1
	begin
		IF COALESCE(@pBusquedaGeneral,'')<>'' SET @Filtros ='AND (E.NumeroExpediente LIKE ''%'+@pBusquedaGeneral +'%'')'
	end
	else
	begin
		IF COALESCE(@pBusquedaGeneral,'')<>''
		SET @Filtros ='AND (CONCAT(SD.AbreviaturaSerieDocumentalExpediente +RIGHT(''000000''+CONVERT(VARCHAR,E.NumeroExpediente),6), ''-'', E.IdPeriodo) LIKE ''%'+
		@pBusquedaGeneral +'%''  OR E.AsuntoExpediente LIKE ''%'+@pBusquedaGeneral +'%'' or PD.NombreCompleto LIKE ''%'+
		@pBusquedaGeneral +'%'' or  E.NombreCompletoCreador LIKE ''%'+@pBusquedaGeneral +'%'')'
	end

	DECLARE @vIdTipoFormulario INT=0
	DECLARE @Filtrospermisos VARCHAR(MAX)
	SELECT @vIdTipoFormulario=COUNT(IdTipoFormulario)
	FROM Tramite.PermisoVisualizacionDocumentos
	WHERE IdPersona=@vIdPersonaU AND IdTipoFormulario=4 and convert(date, GETDATE() )between convert(date,FechaInicioPersmiso) and convert(date,FechaFinPersmiso)
	SET @vIdTipoFormulario=4
	IF @vIdTipoFormulario>=1
	BEGIN
		SET @Filtrospermisos =' WHERE  E.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1 '+@FiltroExpediente+' '
	END ELSE BEGIN
		IF @FiltroExpediente=''
		BEGIN
	 		IF @Filtros=''
			BEGIN
			 SET @FiltroExpediente=' AND E.IdPeriodo = 0'
			END
		END
		SET @Filtrospermisos =' WHERE  E.EstadoAuditoria=1 AND (EDO.IdAreaOrigen IN (SELECT IdArea FROM RecursoHumano.visEmpleadoPerfilPersona WHERE IdPersona='+
		LTRIM(@vIdPersonaU)+' AND Activo=1)  or EDOD.IdAreaDestino IN (SELECT IdArea FROM RecursoHumano.visEmpleadoPerfilPersona WHERE IdPersona='+
		LTRIM(@vIdPersonaU)+' AND Activo=1)) AND EDOD.EstadoAuditoria=1 '+@FiltroExpediente+' '
	END

	IF COALESCE(@pNumeroDocumento,'')<>''
	BEGIN
		SET @Documentos =
		' select max(ED.NumeroDocumento) documento from Tramite.ExpedienteDocumento_Historico_' + @vIdPeriodo + N' ED where ED.IdExpediente=E.IdExpediente AND ED.NumeroDocumento LIKE ''%'+@pNumeroDocumento +'%'''
	END
	ELSE
	BEGIN
		SET @Documentos = ' select '''' documento '
	END

	SET @ConsultaTotal = N'
		DECLARE @vTablaExpediente TABLE(IdExpediente int)
	    INSERT INTO @vTablaExpediente
		SELECT top 100 E.IdExpediente
		FROM Tramite.Expediente_Historico_' + @vIdPeriodo + N' E
		INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
		INNER JOIN Tramite.ExpedienteDocumento_Historico_' + @vIdPeriodo + N' ED
		ON E.IdExpediente=ED.IdExpediente and E.EstadoAuditoria=1 and E.ExpedienteAnulado=0
		INNER JOIN Tramite.ExpedienteDocumentoOrigen_Historico_' + @vIdPeriodo + N' EDO
		ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino_Historico_' + @vIdPeriodo + N' EDOD
		ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen  AND EDO.EstadoAuditoria=1
		LEFT JOIN General.Persona PD ON E.IdPersonaCreador=PD.IdPersona '
		+ @Filtrospermisos
		+ @Filtros
		+ ' group by E.IdExpediente order by E.IdExpediente desc '

	SET @Consulta= @ConsultaTotal + N'
    SELECT E.ExpedienteAnulado,
    COALESCE(E.MotivoExpedienteAnulado,'''')MotivoExpedienteAnulado,
    COALESCE(E.NFechaAnulacionExpediente,'''')NFechaAnulacionExpediente,
    COALESCE(E.HoraAnulacionExpediente,'''')HoraAnulacionExpediente,
	E.IdExpediente, E.ExpedienteConfidencial, E.NTFechaExpediente, E.HoraExpediente, E.IdCatalogoTipoPrioridad,
	CTP.Descripcion CatalogoTipoPrioridad, COALESCE(CTT.Descripcion,'''') CatalogoTipoTramite,
	case when COALESCE(PD.NombreCompleto,'''')='''' then COALESCE(NombreCompletoCreador,'''') else  COALESCE(PD.NombreCompleto,'''') END +'': ''+CASE WHEN COALESCE(E.AsuntoExpediente,'''')='''' THEN ''SIN ASUNTO'' ELSE E.AsuntoExpediente END AsuntoExpediente,
	E.NumeroFoliosExpediente, COALESCE(E.ObservacionesExpediente,'''') ObservacionesExpediente,
	CONVERT(DATETIME,E.NTFechaExpediente +'' ''+ E.HoraExpediente) Fecha,
	CONCAT(SD.AbreviaturaSerieDocumentalExpediente +RIGHT(''000000''+CONVERT(VARCHAR,E.NumeroExpediente),6), ''-'', E.IdPeriodo) NombreExpediente,
	COALESCE(ED.documento,'''') NumeroDocumento
	FROM Tramite.Expediente_Historico_' + @vIdPeriodo + N' E
	INNER JOIN @vTablaExpediente E1 ON E.IdExpediente=E1.IdExpediente
	INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
	INNER JOIN Tramite.Catalogo CTP ON CTP.IdCatalogo=E.IdCatalogoTipoPrioridad
	INNER JOIN Tramite.Catalogo CTT ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
	LEFT JOIN General.Empresa EMD ON E.IdEmpresaCreador=EMD.IdEmpresa
	LEFT JOIN General.Area AD ON E.IdAreaCreador= AD.IdArea
	LEFT JOIN General.Cargo CD ON E.IdCargoCreador=CD.IdCargo
	LEFT JOIN General.Persona PD ON E.IdPersonaCreador=PD.IdPersona'
	+' cross apply( '
	+@Documentos
	+' ) ED '
	+@Orden
	+@Offset
	+@Fetch
	+' select count(*) from @vTablaExpediente'
	EXECUTE sp_executesql @Consulta
END TRY
BEGIN CATCH
    DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
    SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarExpedienteBusquedaPendiente',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
    EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
END CATCH
END
GO




EXECUTE Tramite.paListarExpedienteBusquedaPendiente_arq 349,null,null,1,10,null,2025,0,'','','','',0,0,'','',0,'',0,0,0,0,'',''
