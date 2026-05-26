ALTER PROCEDURE [Tramite].[paListarMisDocumentosGeneradosJefatura_arq]
       @pIdAreaEmisor int,
	   @pIdPersona int,
	   @pIdCatalogoTipoDocumento int,
	   @pIdPeriodo int,
	   @pAsuntoDocumento varchar(500),
	   @pNumeroDocumento varchar(200),
	   @pFechaDocumento varchar(30),
       @pIdUsuarioAuditoria int,
       @pCampoOrdenado varchar(50),
       @pTipoOrdenacion varchar(4),
       @pNumeroPagina INT,
       @pDimensionPagina  INT,
       @pBusquedaGeneral varchar(100)
AS
BEGIN
BEGIN TRY
SET TRAN ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON
set language spanish

	DECLARE @vIdPeriodo varchar(4) = convert(varchar, @pIdPeriodo)
    DECLARE @Consulta Nvarchar(max)=''
    DECLARE @ConsultaTotal Nvarchar(max)=''
    DECLARE @Filtros varchar(max)=''
    DECLARE @Offset NVARCHAR(MAX)='';
    DECLARE @Fetch NVARCHAR(MAX)='';
    DECLARE @Orden NVARCHAR(MAX)='';
    DECLARE @Parametros NVARCHAR(MAX)='';
    DECLARE @pTotalRegistros  INT;
    DECLARE @vFiltroDocumento NVARCHAR(MAX)='';
	DECLARE @vFiltroJefe NVARCHAR(MAX)='';
	declare @vFechaInicial varchaR(10)
	declare @vFechaFinal varchaR(10)

	IF COALESCE(@pFechaDocumento,'')<>''
	begin
		SET @vFechaInicial=left(@pFechaDocumento,10)
		SET @vFechaFinal=RIGHT(@pFechaDocumento,10)
	end

	DECLARE @vIdPersonaActual int=0
    SELECT @vIdPersonaActual=IdPersona from Seguridad.Usuario where IdUsuario=@pIdUsuarioAuditoria AND EstadoAuditoria=1 AND Bloqueado=0
	IF COALESCE(@pIdPeriodo,0)<>0 BEGIN	SET  @vFiltroDocumento=@vFiltroDocumento+ ' AND year(ED.NFechaDocumento) ='+CONVERT(VARCHAR,@pIdPeriodo) END
	IF COALESCE(@pIdPersona,0)<>0 BEGIN	SET  @vFiltroDocumento=@vFiltroDocumento+ ' AND ED.IdPersonaEmisor ='+CONVERT(VARCHAR,@pIdPersona) END
	IF COALESCE(@pIdCatalogoTipoDocumento,0)<>0 BEGIN	SET @vFiltroDocumento =@vFiltroDocumento+ ' AND ED.IdCatalogoTipoDocumento ='+CONVERT(VARCHAR,@pIdCatalogoTipoDocumento) END
	IF COALESCE(@pAsuntoDocumento,'')<>'' BEGIN	SET @vFiltroDocumento =@vFiltroDocumento+' AND ED.AsuntoDocumento LIKE ''%'+@pAsuntoDocumento +'%'''END
	IF COALESCE(@pNumeroDocumento,'')<>'' BEGIN	SET @vFiltroDocumento =@vFiltroDocumento+' AND ED.NumeroDocumento LIKE ''%'+@pNumeroDocumento +'%'''END
	IF COALESCE(@pFechaDocumento,'')<>'' BEGIN	SET @vFiltroDocumento =@vFiltroDocumento+' AND convert(date,ED.NFechaDocumento) between '''+@vFechaInicial+''' AND '''+@vFechaFinal+'''' END
    SET @Orden=' ORDER BY NumeroDocumento desc '
    SET @Offset= ' OFFSET '+ CONVERT(VARCHAR(10),(@pNumeroPagina-1)*@pDimensionPagina) +' ROWS '
    SET @Fetch= ' FETCH NEXT '+ CONVERT(VARCHAR(10),@pDimensionPagina) +' ROWS ONLY '
	 IF COALESCE(@pBusquedaGeneral,'')<>''
		SET @Filtros =' AND (CONCAT(SD.AbreviaturaSerieDocumentalExpediente +RIGHT(''000000''+CONVERT(VARCHAR,E.NumeroExpediente),6), ''-'', E.IdPeriodo,
		CASE WHEN COALESCE(ED.CorrelativoVinculado,0)=0 THEN '''' ELSE '' V-''+
		CONVERT(VARCHAR,ED.CorrelativoVinculado) END) LIKE ''%'+@pBusquedaGeneral +'%'' or UPPER(COALESCE(ED.AsuntoDocumento,'''')) LIKE ''%'+
		@pBusquedaGeneral +'%'' or COALESCE(ED.NumeroDocumento,'''') LIKE ''%'+
		@pBusquedaGeneral +'%'' or COALESCE(ED.ObservacionesDocumento,'''') LIKE ''%'+@pBusquedaGeneral +'%'' or ED.NFechaDocumento LIKE ''%'+
		@pBusquedaGeneral +'%''  or Tramite.funMostrarDesatinatarios(EDO.IdExpedienteDocumentoOrigen) LIKE ''%'+@pBusquedaGeneral +'%'')'
	 SET @Consulta= N'
		declare @tabla1 table (NumeroDocumento varchar(200),IdExpediente int,IdExpedienteDocumento int,IdExpedienteDocumentoOrigen int)
		declare @tabla2 table (IdExpediente int,IdExpedienteDocumento int,IdExpedienteDocumentoOrigen int)
		insert into @tabla1
       	SELECT ED.NumeroDocumento,E.IdExpediente,ED.IdExpedienteDocumento,EDO.IdExpedienteDocumentoOrigen
		FROM Tramite.Expediente_Historico_' + @vIdPeriodo + N' E
		INNER JOIN Tramite.SerieDocumentalExpediente SD  ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente and E.EstadoAuditoria=1 AND E.ExpedienteAnulado=0
		INNER JOIN Tramite.ExpedienteDocumento_Historico_' + @vIdPeriodo + N' ED
		ON ED.IdExpediente=E.IdExpediente
		INNER JOIN Tramite.ExpedienteDocumentoOrigen_Historico_' + @vIdPeriodo + N' EDO
		ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino_Historico_' + @vIdPeriodo + N' EDOD
		ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen  AND EDO.EstadoAuditoria=1  and edod.EsInicial<>0
		LEFT JOIN Tramite.ExpedienteSeguimiento ES ON ES.IdExpediente= E.IdExpediente AND ES.EstadoAuditoria=1 AND ES.IdCargo=0 AND ES.IdPersona=0 AND ES.IdArea='+CONVERT(VARCHAR,@pIdAreaEmisor)+'
		WHERE EDOD.EstadoAuditoria=1 and ED.IdAreaEmisor='+CONVERT(VARCHAR,@pIdAreaEmisor)+' '+@vFiltroJefe+'
		 ' +@vFiltroDocumento
        +@Filtros
        + ' group by ED.NumeroDocumento,E.IdExpediente,ED.IdExpedienteDocumento,EDO.IdExpedienteDocumentoOrigen '
        + ' insert into @tabla2 select IdExpediente,IdExpedienteDocumento,IdExpedienteDocumentoOrigen from @tabla1'
        +@Orden
        +@Offset
        +@Fetch
        + N'SELECT
		COALESCE(EM.NombreEmpresa,''EXTERNO'')NombreEmpresa,COALESCE(A.NombreArea,'''')NombreArea,COALESCE(C.NombreCargo,'''')NombreCargo,COALESCE(P.NombreCompleto,'''')NombreCompleto,
		year( convert(date,ED.NFechaDocumento)) IdPeriodo,E.IdExpediente,
		CONCAT(SD.AbreviaturaSerieDocumentalExpediente +RIGHT(''000000''+CONVERT(VARCHAR,E.NumeroExpediente),6), ''-'',
		E.IdPeriodo,CASE WHEN COALESCE(ED.CorrelativoVinculado,0)=0 THEN '''' ELSE '' V-''+CONVERT(VARCHAR,ED.CorrelativoVinculado) END) NombreExpediente,
		E.ExpedienteAnulado,COALESCE(ED.NumeroDocumento,'''') NumeroDocumento,ED.NFechaDocumento,
		UPPER(COALESCE(ED.AsuntoDocumento,'''')) AsuntoDocumento, case when ED.FgEnEsperaFirmaDigital=1 and Ver.doc=0 then '''' else
		COALESCE(ED.RutaArchivoDocumento,'''') end RutaArchivoDocumento,
		COALESCE(ED.ObservacionesDocumento,'''') ObservacionesDocumento,
		Tramite.funMostrarDesatinatarios(EDO.IdExpedienteDocumentoOrigen) Destinatario,
		case when ED.FgEnEsperaFirmaDigital=1 and Ver.doc=0 then 0 else
		ED.IdExpedienteDocumento end IdExpedienteDocumento,CTD.Descripcion CatalogoTipoDocumento,ED.Correlativo,ED.IdCatalogoTipoDocumento,
		COALESCE(ES.IdExpedienteSeguimiento,0)IdExpedienteSeguimiento,ED.IdPersonaEmisor
		FROM @tabla2 t2
		INNER JOIN Tramite.Expediente_Historico_' + @vIdPeriodo + N' E
		ON E.IdExpediente = t2.IdExpediente
		INNER JOIN Tramite.SerieDocumentalExpediente SD  ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
		INNER JOIN Tramite.ExpedienteDocumento_Historico_' + @vIdPeriodo + N' ED
		ON ED.IdExpedienteDocumento = t2.IdExpedienteDocumento
		INNER JOIN Tramite.ExpedienteDocumentoOrigen_Historico_' + @vIdPeriodo + N' EDO
		ON EDO.IdExpedienteDocumentoOrigen = t2.IdExpedienteDocumentoOrigen
		outer apply(
			select isnull(max(1),0) doc
			from Tramite.ExpedienteDocumentoFirmante_Historico_' + @vIdPeriodo + N' EDF
			where EDF.IdExpedienteDocumento=ED.IdExpedienteDocumento and EDF.IdPersona=' + CONVERT(varchar,@vIdPersonaActual) + ' and EDF.EstadoAuditoria=1
		) Ver
		INNER JOIN Tramite.Catalogo CTD ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
		LEFT JOIN Tramite.ExpedienteSeguimiento ES ON ES.IdExpediente= E.IdExpediente AND ES.EstadoAuditoria=1
		AND ES.IdCargo=0 AND ES.IdPersona=0 AND ES.IdArea='+CONVERT(VARCHAR,@pIdAreaEmisor)+'
		LEFT JOIN General.Cargo C ON C.IdCargo=ED.IdCargoEmisor
		LEFT JOIN General.Area A ON A.IdArea=ED.IdAreaEmisor
		LEFT JOIN General.Empresa EM ON EM.IdEmpresa=ED.IdEmpresaEmisor
		LEFT JOIN General.Persona P ON P.IdPersona=ED.IdPersonaEmisor'
		+@Orden
		+ ' select count(*) from @tabla1 '
        EXECUTE sp_executesql @Consulta

END TRY
BEGIN CATCH
    DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX) ,@ERROR_MESSAGE VARCHAR(MAX)
    SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE(),
    @ERROR_PROCEDURE='Tramite.paListarMisDocumentosGeneradosJefatura',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
    EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
END CATCH
END
GO


EXECUTE tramite.paListarMisDocumentosGeneradosJefatura_arq 79,0,0,2025,'','','',349,NULL,NULL,1,10,null


-- SELECT
-- @pIdAreaEmisor= 79,
-- @pIdPersona=0,
-- @pIdCatalogoTipoDocumento=0,
-- @pIdPeriodo= 2025,
-- @pAsuntoDocumento='',
-- @pNumeroDocumento='',
-- @pFechaDocumento='',
-- @pIdUsuarioAuditoria=349,
-- @pCampoOrdenado=NULL,
-- @pTipoOrdenacion=NULL,
-- @pNumeroPagina=1,
-- @pDimensionPagina=10,
-- @pBusquedaGeneral=NULL
