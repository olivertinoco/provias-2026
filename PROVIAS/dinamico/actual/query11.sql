CREATE PROCEDURE [Tramite].[paListarMisDocumentosGeneradosJefatura]
    @pIdAreaEmisor int,
    @pIdPersona int,
    @pIdCatalogoTipoDocumento int,
    @pIdPeriodo int,
    @pAsuntoDocumento varchar(500),
    @pNumeroDocumento varchar(200),
    @pFechaDocumento varchar(10),
    @pIdUsuarioAuditoria int,
    @pCampoOrdenado varchar(50),
    @pTipoOrdenacion varchar(4),
    @pNumeroPagina INT,
    @pDimensionPagina  INT,
    @pBusquedaGeneral varchar(100)
AS
BEGIN TRY
set language 'spanish'
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
	IF COALESCE(@pIdPeriodo,0)<>0 BEGIN	SET  @vFiltroDocumento=@vFiltroDocumento+ ' AND X.IdPeriodo ='+CONVERT(VARCHAR,@pIdPeriodo) END
	IF COALESCE(@pIdPersona,0)<>0 BEGIN	SET  @vFiltroDocumento=@vFiltroDocumento+ ' AND X.IdPersonaEmisor ='+CONVERT(VARCHAR,@pIdPersona) END
	IF COALESCE(@pIdCatalogoTipoDocumento,0)<>0 BEGIN	SET @vFiltroDocumento =@vFiltroDocumento+ ' AND X.IdCatalogoTipoDocumento ='+CONVERT(VARCHAR,@pIdCatalogoTipoDocumento) END
	IF COALESCE(@pAsuntoDocumento,'')<>'' BEGIN	SET @vFiltroDocumento =@vFiltroDocumento+' AND X.AsuntoDocumento LIKE ''%'+@pAsuntoDocumento +'%'''END
	IF COALESCE(@pNumeroDocumento,'')<>'' BEGIN	SET @vFiltroDocumento =@vFiltroDocumento+' AND X.NumeroDocumento LIKE ''%'+@pNumeroDocumento +'%'''END
	IF COALESCE(@pFechaDocumento,'')<>'' BEGIN	SET @vFiltroDocumento =@vFiltroDocumento+' AND X.NFechaDocumento LIKE ''%'+@pFechaDocumento+'%''' END

        SET @Orden=' ORDER BY X.CatalogoTipoDocumento, X.Correlativo desc '
        SET @Offset= ' OFFSET ' +CONVERT(VARCHAR(10),(@pNumeroPagina-1)*@pDimensionPagina) + ' ROWS'
        SET @Fetch= ' FETCH NEXT '+CONVERT(VARCHAR(10),@pDimensionPagina) +' ROWS ONLY'
        print @vFiltroDocumento
        IF COALESCE(@pBusquedaGeneral,'')<>'' SET @Filtros =' AND (X.NombreExpediente LIKE ''%'+@pBusquedaGeneral +'%'' or X.AsuntoDocumento LIKE ''%'+@pBusquedaGeneral +'%'' or X.NumeroDocumento LIKE ''%'+@pBusquedaGeneral +'%'' or X.ObservacionesDocumento LIKE ''%'+@pBusquedaGeneral +'%'' or X.NFechaDocumento LIKE ''%'+@pBusquedaGeneral +'%''  or X.Destinatario LIKE ''%'+@pBusquedaGeneral +'%'')'
        PRINT @pBusquedaGeneral
        PRINT @Filtros
        SET @ConsultaTotal = N'SELECT @vpTotalRegistros = count(*)
        FROM (
       	SELECT
		DISTINCT
		COALESCE(EM.NombreEmpresa,''EXTERNO'')NombreEmpresa,
		COALESCE(A.NombreArea,'''')NombreArea,
		COALESCE(C.NombreCargo,'''')NombreCargo,
		COALESCE(P.NombreCompleto,'''')NombreCompleto,
		year(ED.NFechaDocumento) IdPeriodo,
		E.IdExpediente ,
		CONCAT(SD.AbreviaturaSerieDocumentalExpediente +RIGHT(''000000''+CONVERT(VARCHAR,E.NumeroExpediente),6), ''-'', E.IdPeriodo,CASE WHEN COALESCE(ED.CorrelativoVinculado,0)=0 THEN '''' ELSE '' V-''+CONVERT(VARCHAR,ED.CorrelativoVinculado) END) NombreExpediente,
		E.ExpedienteAnulado,
		COALESCE(ED.NumeroDocumento,'''') NumeroDocumento,
		ED.NFechaDocumento,
		UPPER(COALESCE(ED.AsuntoDocumento,'''')) AsuntoDocumento,
		COALESCE(ED.RutaArchivoDocumento,'''') RutaArchivoDocumento,
		COALESCE(ED.ObservacionesDocumento,'''') ObservacionesDocumento,
		Tramite.funMostrarDesatinatarios(EDO.IdExpedienteDocumentoOrigen) Destinatario,
		ED.IdExpedienteDocumento,

		CTD.Descripcion CatalogoTipoDocumento,
		ED.Correlativo,
		ED.IdCatalogoTipoDocumento,
		COALESCE(ES.IdExpedienteSeguimiento,0)IdExpedienteSeguimiento,
		ED.IdPersonaEmisor
		FROM
		Tramite.Expediente E with (nolock)
		INNER JOIN Tramite.SerieDocumentalExpediente SD  with (nolock)ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente	 and E.EstadoAuditoria=1	AND E.ExpedienteAnulado=0
		INNER JOIN Tramite.ExpedienteDocumento ED  with (nolock) ON ED.IdExpediente=E.IdExpediente and e.EstadoAuditoria=1
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO  with (nolock) ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD  with (nolock) ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen  AND EDO.EstadoAuditoria=1  and edod.EsInicial<>0
		INNER JOIN Tramite.Catalogo CTD ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
		LEFT JOIN Tramite.ExpedienteSeguimiento ES ON ES.IdExpediente= E.IdExpediente AND ES.EstadoAuditoria=1 AND ES.IdCargo=0 AND ES.IdPersona=0 AND ES.IdArea='+CONVERT(VARCHAR,@pIdAreaEmisor)+'
		LEFT JOIN General.Cargo C ON C.IdCargo=ED.IdCargoEmisor
		LEFT JOIN General.Area A ON A.IdArea=ED.IdAreaEmisor
		LEFT JOIN General.Empresa EM ON EM.IdEmpresa=ED.IdEmpresaEmisor
		LEFT JOIN General.Persona P ON P.IdPersona=ED.IdPersonaEmisor
		WHERE EDOD.EstadoAuditoria=1 and ED.IdAreaEmisor='+CONVERT(VARCHAR,@pIdAreaEmisor)+' '+@vFiltroJefe+'
		)X WHERE 1=1 '+@vFiltroDocumento
            +@Filtros
			print @ConsultaTotal
        SET @Parametros = N'@vpTotalRegistros int OUTPUT';
        EXECUTE sp_executesql @ConsultaTotal,@Parametros, @vpTotalRegistros = @pTotalRegistros OUTPUT

        SET @Consulta='
        SELECT * FROM (
       	SELECT
		DISTINCT
		COALESCE(EM.NombreEmpresa,''EXTERNO'')NombreEmpresa,
		COALESCE(A.NombreArea,'''')NombreArea,
		COALESCE(C.NombreCargo,'''')NombreCargo,
		COALESCE(P.NombreCompleto,'''')NombreCompleto,
		year( convert(date,ED.NFechaDocumento)) IdPeriodo,
		E.IdExpediente ,
		CONCAT(SD.AbreviaturaSerieDocumentalExpediente +RIGHT(''000000''+CONVERT(VARCHAR,E.NumeroExpediente),6), ''-'', E.IdPeriodo,CASE WHEN COALESCE(ED.CorrelativoVinculado,0)=0 THEN '''' ELSE '' V-''+CONVERT(VARCHAR,ED.CorrelativoVinculado) END) NombreExpediente,
		E.ExpedienteAnulado,
		COALESCE(ED.NumeroDocumento,'''') NumeroDocumento,
		ED.NFechaDocumento,
		UPPER(COALESCE(ED.AsuntoDocumento,'''')) AsuntoDocumento,
		COALESCE(ED.RutaArchivoDocumento,'''') RutaArchivoDocumento,
		COALESCE(ED.ObservacionesDocumento,'''') ObservacionesDocumento,
		Tramite.funMostrarDesatinatarios(EDO.IdExpedienteDocumentoOrigen) Destinatario,
		ED.IdExpedienteDocumento,
		CTD.Descripcion CatalogoTipoDocumento,
		ED.Correlativo,
		ED.IdCatalogoTipoDocumento,
		COALESCE(ES.IdExpedienteSeguimiento,0)IdExpedienteSeguimiento,
		ED.IdPersonaEmisor
		FROM
		Tramite.Expediente E  with (nolock)
		INNER JOIN Tramite.SerieDocumentalExpediente SD  with (nolock)ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente and E.EstadoAuditoria=1	AND E.ExpedienteAnulado=0
		INNER JOIN Tramite.ExpedienteDocumento ED  with (nolock)ON ED.IdExpediente=E.IdExpediente
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO  with (nolock) ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD  with (nolock) ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen  AND EDO.EstadoAuditoria=1  and edod.EsInicial<>0
		INNER JOIN Tramite.Catalogo CTD ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
		LEFT JOIN Tramite.ExpedienteSeguimiento ES ON ES.IdExpediente= E.IdExpediente AND ES.EstadoAuditoria=1 AND ES.IdCargo=0 AND ES.IdPersona=0 AND ES.IdArea='+CONVERT(VARCHAR,@pIdAreaEmisor)+'
		LEFT JOIN General.Cargo C ON C.IdCargo=ED.IdCargoEmisor
		LEFT JOIN General.Area A ON A.IdArea=ED.IdAreaEmisor
		LEFT JOIN General.Empresa EM ON EM.IdEmpresa=ED.IdEmpresaEmisor
		LEFT JOIN General.Persona P ON P.IdPersona=ED.IdPersonaEmisor
		WHERE EDOD.EstadoAuditoria=1 and ED.IdAreaEmisor='+CONVERT(VARCHAR,@pIdAreaEmisor)+' '+@vFiltroJefe+'
		)X WHERE 1=1 '+@vFiltroDocumento
        +@Filtros
        +@Orden
        +@Offset
        +@Fetch

        print @Consulta
        EXECUTE sp_executesql @Consulta
        select @pTotalRegistros--,@pDimensionPagina

END TRY
BEGIN CATCH
    DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX) ,@ERROR_MESSAGE VARCHAR(MAX)
    SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarMisDocumentosGeneradosJefatura',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
    EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
END CATCH
