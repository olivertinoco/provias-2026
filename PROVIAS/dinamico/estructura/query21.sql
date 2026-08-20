ALTER PROCEDURE [Tramite].[paListarCarpetaDocumentosPorExpediente]
	@pIdExpediente int,
	@pIdUsuarioAuditoria int,
	@pIdPeriodo int
AS
BEGIN
BEGIN TRY

	SELECT distinct
	CONCAT(SD.AbreviaturaSerieDocumentalExpediente,RIGHT(CONCAT('000000',Ex.NumeroExpediente),6), '-', Ex.IdPeriodo) NombreExpediente,
	ed.IdExpedienteDocumento,
	ed.IdExpediente,
	ED.NFechaDocumento,
	ed.FechaCreacionAuditoria,
	EDA.FechaCreacionAuditoria,
	ed.AsuntoDocumento,
	CASE WHEN ED.Correlativo=0 THEN  CONCAT( CTD.Descripcion,' ', COALESCE(ED.NumeroDocumento,'''')) ELSE COALESCE(ED.NumeroDocumento,'''') END  NumeroDocumento,
	ED.RutaArchivoDocumento,
	coalesce(EDA.DescripcionDocumentoAdjunto,'S.DA.')DescripcionDocumentoAdjunto,
	COALESCE(EDA.RutaArchivoDocumentoAdjunto,'S.DA.')RutaArchivoDocumentoAdjunto,
	COALESCE(EDA.IdExpedienteDocumentoAdjunto,0)IdExpedienteDocumentoAdjunto,
	COALESCE(EDOA.IdExpedienteDocumentoOrigenAdjunto,0)IdExpedienteDocumentoOrigenAdjunto,
	COALESCE(EDOA.DescripcionDocumentoAdjuntoEDO,'S.DAM.')DescripcionDocumentoAdjuntoEDO,
	COALESCE(EDOA.RutaArchivoDocumentoAdjuntoEDO,'S.DAM.')RutaArchivoDocumentoAdjuntoEDO ,
	EX.NumeroExpediente,
	EX.IdPeriodo,
	SD.AbreviaturaSerieDocumentalExpediente,
	Tramite.funDevolverPeriodoDocumento(GETDATE(),ED.FechaCreacionAuditoria) PeriodoCreadoDocumento,
	ed.FgEsObligatorioFirmaDigital
	FROM Tramite.ExpedienteDocumento ED
	INNER JOIN Tramite.Expediente EX ON EX.IdExpediente=ED.IdExpediente AND EX.IdPeriodo = @pIdPeriodo
	INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente=EX.IdSerieDocumentalExpediente
	INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND EDO.EstadoAuditoria=1 AND ED.EstadoAuditoria=1 AND EDO.IdPeriodo = @pIdPeriodo
	LEFT JOIN Tramite.Catalogo CTD ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
	LEFT JOIN Tramite.ExpedienteDocumentoAdjunto EDA ON EDA.IdExpedienteDocumento=ED.IdExpedienteDocumento AND EDA.EstadoAuditoria=1 AND ED.EstadoAuditoria=1 AND EDA.IdPeriodo = @pIdPeriodo
	LEFT JOIN Tramite.ExpedienteDocumentoOrigenAdjunto EDOA ON EDOA.IdExpedienteDocumentoOrigenEDO=EDO.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1 AND EDOA.EstadoAuditoria=1 AND EDOA.IdPeriodo = @pIdPeriodo
	WHERE ED.IdExpediente=@pIdExpediente AND ED.IdPeriodo = @pIdPeriodo
	order by ed.FechaCreacionAuditoria desc

END TRY
BEGIN CATCH
	DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
	SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE(),
	@ERROR_PROCEDURE='Tramite.paListarCarpetaDocumentosPorExpediente',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE, @pIdUsuarioAuditoria
END CATCH
END
