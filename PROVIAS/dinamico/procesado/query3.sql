create OR ALTER PROCEDURE Tramite.paListarMisDocumentosGeneradosEspecialistaV1_arq
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
BEGIN TRY
set tran isolation level read uncommitted
set language spanish
set nocount on

if @pIdPeriodo = year(getdate())begin
    RAISERROR('El periodo no debe ser el actual o vacio', 10, 1) with nowait;
    return;
end;

    Declare @vIdPeriodo char(4) = convert(varchar, @pIdPeriodo)

    DECLARE @Consulta Nvarchar(max)=''
    DECLARE @ConsultaTotal Nvarchar(max)=''
    DECLARE @Filtros varchar(max)=''
    DECLARE @Offset NVARCHAR(MAX)='';
    DECLARE @Fetch NVARCHAR(MAX)='';
    DECLARE @Orden NVARCHAR(MAX)='';
    DECLARE @pTotalRegistros  INT;
    DECLARE @vFiltroDocumento NVARCHAR(MAX)='';

	declare @vFechaInicial varchaR(10)
	declare @vFechaFinal varchaR(10)

	IF COALESCE(@pFechaDocumento,'')<>''
	begin
		SET @vFechaInicial=left(@pFechaDocumento,10)
		SET @vFechaFinal=RIGHT(@pFechaDocumento,10)
	end


	SET  @vFiltroDocumento= concat(' AND X.IdPeriodo =',@vIdPeriodo)

	IF COALESCE(@pIdCatalogoTipoDocumento,0)<>0 BEGIN
	    SET @vFiltroDocumento =@vFiltroDocumento+ ' AND X.IdCatalogoTipoDocumento ='+CONVERT(VARCHAR,@pIdCatalogoTipoDocumento)
	END
	IF COALESCE(@pAsuntoDocumento,'')<>'' BEGIN
	    SET @vFiltroDocumento =@vFiltroDocumento+' AND X.AsuntoDocumento LIKE ''%'+@pAsuntoDocumento +'%'''
	END
	IF COALESCE(@pNumeroDocumento,'')<>'' BEGIN
	    SET @vFiltroDocumento =@vFiltroDocumento+' AND X.NumeroDocumento LIKE ''%'+@pNumeroDocumento +'%'''
	END
	IF COALESCE(@pFechaDocumento,'')<>'' BEGIN
	    SET @vFiltroDocumento =@vFiltroDocumento+' AND convert(date,X.NFechaDocumento) between '''+@vFechaInicial+''' AND '''+@vFechaFinal+''''
	END

    SET @Orden=' ORDER BY X.CatalogoTipoDocumento, X.Correlativo '
    SET @Offset= ' OFFSET ' +CONVERT(VARCHAR(10),(@pNumeroPagina-1)*@pDimensionPagina) + ' ROWS'
    SET @Fetch= ' FETCH NEXT '+CONVERT(VARCHAR(10),@pDimensionPagina) +' ROWS ONLY'

    IF COALESCE(@pBusquedaGeneral,'')<>''
        SET @Filtros =' AND (X.NombreExpediente LIKE ''%'+@pBusquedaGeneral +'%'' or X.AsuntoDocumento LIKE ''%'+@pBusquedaGeneral +
        '%'' or X.NumeroDocumento LIKE ''%'+@pBusquedaGeneral +'%'' or X.ObservacionesDocumento LIKE ''%'+@pBusquedaGeneral +
        '%'' or X.NFechaDocumento LIKE ''%'+@pBusquedaGeneral +'%'')'

        SET @ConsultaTotal = N'
        SELECT @vpTotalRegistros = count(1) FROM(SELECT DISTINCT
    		ED.IdExpedienteDocumento, COALESCE(ES.IdExpedienteSeguimiento,0) IdExpedienteSeguimiento
		FROM Tramite.Expediente_Historico_' + @vIdPeriodo + N' E
		INNER JOIN Tramite.SerieDocumentalExpediente SD
		    ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
		INNER JOIN Tramite.ExpedienteDocumento_Historico_' + @vIdPeriodo + N' ED
		    ON ED.IdExpediente=E.IdExpediente
		INNER JOIN Tramite.ExpedienteDocumentoOrigen_Historico_' + @vIdPeriodo + N' EDO
		    ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento
			AND ED.EstadoAuditoria=1
		INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino_Historico_' + @vIdPeriodo + N' EDOD
		    ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen
			AND EDO.EstadoAuditoria=1
			AND edod.EsInicial<>0
		INNER JOIN Tramite.Catalogo CTD
		    ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
		LEFT JOIN Tramite.ExpedienteSeguimiento ES
		    ON ES.IdExpediente= E.IdExpediente
			AND ES.EstadoAuditoria=1
			AND ES.IdEmpresa=2
			AND ES.IdPersona=@pIdPersona
		WHERE EDOD.EstadoAuditoria=1
		    AND ED.IdPersonaEmisor=@pIdPersona
		)X WHERE 1=1 '+
		@vFiltroDocumento + @Filtros

        EXECUTE sp_executesql @ConsultaTotal, N'@pIdPersona int, @vpTotalRegistros int OUTPUT',
            @pIdPersona = @pIdPersona,
            @vpTotalRegistros = @pTotalRegistros OUTPUT

        SET @Consulta= N'
        SELECT * FROM (
       	SELECT DISTINCT
    		COALESCE(EM.NombreEmpresa,''EXTERNO'')NombreEmpresa,
    		COALESCE(A.NombreArea,'''')NombreArea,
    		COALESCE(C.NombreCargo,'''')NombreCargo,
    		E.IdPeriodo,
    		E.IdExpediente ,
    		CONCAT(SD.AbreviaturaSerieDocumentalExpediente, RIGHT(1000000+E.NumeroExpediente,6), ''-'', E.IdPeriodo) NombreExpediente,
    		E.ExpedienteAnulado,
    		COALESCE(ED.NumeroDocumento,'''') NumeroDocumento,
    		ED.NFechaDocumento,
    		UPPER(COALESCE(ED.AsuntoDocumento,'''')) AsuntoDocumento,
    		COALESCE(ED.RutaArchivoDocumento,'''') RutaArchivoDocumento,
    		COALESCE(ED.ObservacionesDocumento,'''') ObservacionesDocumento,
    		''''Destinatario,
    		ED.IdExpedienteDocumento,
    		CTD.Descripcion CatalogoTipoDocumento,
    		COALESCE(ED.Correlativo,'''')Correlativo,
    		ED.IdCatalogoTipoDocumento,
    		COALESCE(ES.IdExpedienteSeguimiento,0) IdExpedienteSeguimiento
		FROM Tramite.Expediente_Historico_' + @vIdPeriodo + N' E
		INNER JOIN Tramite.SerieDocumentalExpediente SD
		    ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
		INNER JOIN Tramite.ExpedienteDocumento_Historico_' + @vIdPeriodo + N' ED
		    ON ED.IdExpediente=E.IdExpediente
		INNER JOIN Tramite.ExpedienteDocumentoOrigen_Historico_' + @vIdPeriodo + N' EDO
		    ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento
			AND ED.EstadoAuditoria=1
		INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino_Historico_' + @vIdPeriodo + N' EDOD
		    ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen
			AND EDO.EstadoAuditoria=1
			AND edod.EsInicial<>0
		INNER JOIN Tramite.Catalogo CTD
		    ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
		LEFT JOIN Tramite.ExpedienteSeguimiento ES
		    ON ES.IdExpediente= E.IdExpediente
			AND ES.EstadoAuditoria=1
			AND ES.IdEmpresa=2
			AND ES.IdPersona=@pIdPersona
		LEFT JOIN General.Cargo C
		    ON C.IdCargo=ED.IdCargoEmisor
		LEFT JOIN General.Area A
		    ON A.IdArea=ED.IdAreaEmisor
		LEFT JOIN General.Empresa EM
		    ON EM.IdEmpresa=ED.IdEmpresaEmisor
		WHERE EDOD.EstadoAuditoria=1 AND ED.IdPersonaEmisor=@pIdPersona
		)X WHERE 1=1 '+@vFiltroDocumento
        +@Filtros
        +@Orden
        +@Offset
        +@Fetch

        EXECUTE sp_executesql @Consulta, N'@pIdPersona int', @pIdPersona

        select @pTotalRegistros

END TRY
BEGIN CATCH
    DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX) ,@ERROR_MESSAGE VARCHAR(MAX)
    SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() ,
    @ERROR_PROCEDURE='Tramite.paListarMisDocumentosGeneradosEspecialista',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
    EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
END CATCH
GO
