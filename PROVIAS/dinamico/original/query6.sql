ALTER PROCEDURE [Tramite].[paListarDemoraAtencionPorExpediente]
	@pIdExpediente int,
	@pIdUsuarioAuditoria int,
	@pCampoOrdenado varchar(50),
	@pTipoOrdenacion varchar(4),
	@pNumeroPagina INT,
	@pDimensionPagina  INT,
	@pBusquedaGeneral varchar(100),
	@pIdPeriodo int
AS
BEGIN
BEGIN TRY

    DECLARE @vSiPariticipo int=0
    SELECT * from Tramite.visDemoraAtencionPorExpediente
    WHERE IdExpediente = @pIdExpediente and(
    (AsuntoDocumento LIKE '%'+@pBusquedaGeneral +'%'  OR @pBusquedaGeneral IS NULL OR @pBusquedaGeneral='') OR
    (NumeroDocumento LIKE '%'+@pBusquedaGeneral +'%'  OR @pBusquedaGeneral IS NULL OR @pBusquedaGeneral='')
    )
    ORDER BY idexpedientedocumentoorigendestino desc
    OFFSET (@pNumeroPagina-1)*@pDimensionPagina ROWS
    FETCH NEXT @pDimensionPagina ROWS ONLY

    SELECT COUNT(*) from Tramite.visDemoraAtencionPorExpediente WHERE IdExpediente=@pIdExpediente

END TRY
BEGIN CATCH
	DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
	SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE(),
	@ERROR_PROCEDURE='Tramite.paListarDemoraAtencionPorExpediente',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE ,@pIdUsuarioAuditoria
END CATCH
END
