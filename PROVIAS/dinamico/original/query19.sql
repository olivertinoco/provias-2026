ALTER PROCEDURE [Tramite].[paObtenerExpedienteDocumentoOrigenDestino]
    @pIdExpedienteDocumentoOrigenDestino INT,
    @pIdPeriodo int
AS
BEGIN
BEGIN TRY

	SELECT
	 Tramite.funObtenerNuevoPlazo(EDOD.NumeroDiasAtencionSolicitado,E.IdExpediente) NumeroDiasAtencionAceptado
	,EDOD.IdExpedienteDocumentoOrigenDestino
	,EDOD.IdExpedienteDocumentoOrigen
	,ED.IdExpedienteDocumento
	,EDOD.IdCatalogoSituacionMovimientoDestino
	,EDOD.IdCatalogoTipoMovimientoDestino
	,EDOD.Original
	,EDOD.Copia
	,EDOD.FechaDestino
	,EDOD.HoraDestino
	,COALESCE(EDOD.IdEmpresaDestinoRecepciona,0)IdEmpresaDestinoRecepciona
	,COALESCE(EDOD.IdAreaDestinoRecepciona,0)IdAreaDestinoRecepciona
	,COALESCE(EDOD.IdCargoDestinoRecepciona,0)IdCargoDestinoRecepciona
	,COALESCE(EDOD.IdPersonaDestinoRecepciona,0)IdPersonaDestinoRecepciona
	,EDOD.IdEmpresaDestino
	,EDOD.IdAreaDestino
	,EDOD.IdCargoDestino
	,EDOD.IdPersonaDestino
	,COALESCE(EDOD.IdEmpresaDestinoAtencion,0)IdEmpresaDestinoAtencion
	,COALESCE(EDOD.IdAreaDestinoAtencion,0)IdAreaDestinoAtencion
	,COALESCE(EDOD.IdCargoDestinoAtencion,0)IdCargoDestinoAtencion
	,COALESCE(EDOD.IdPersonaDestinoAtencion,0)IdPersonaDestinoAtencion
	,COALESCE(EDOD.IdEstanteArchivador,0)IdEstanteArchivador
	,COALESCE(EDOD.ObservacionesDestinatario,'')ObservacionesDestinatario
	,CONCAT(SD.AbreviaturaSerieDocumentalExpediente +RIGHT('0000'+CONVERT(VARCHAR,E.NumeroExpediente),5), '-', E.IdPeriodo,CASE WHEN COALESCE(ED.CorrelativoVinculado,0)=0 THEN '' ELSE '-V-'+CONVERT(VARCHAR,ED.CorrelativoVinculado) END) NombreExpediente
	,EDOD.NumeroDiasAtencionSolicitado
	,COALESCE(ED.ObservacionesDocumento,'')ObservacionesDocumento
	,COALESCE(E.AsuntoExpediente,'')AsuntoExpediente
	,COALESCE(E.IdCatalogoTipoTramite,0)IdCatalogoTipoTramite
	FROM Tramite.ExpedienteDocumentoOrigenDestino EDOD
	INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen and EDO.EstadoAuditoria=1
	INNER JOIN Tramite.ExpedienteDocumento ED ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
	INNER JOIN Tramite.Expediente E ON E.IdExpediente=ED.IdExpediente
	INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
	WHERE EDOD.IdExpedienteDocumentoOrigenDestino=@pIdExpedienteDocumentoOrigenDestino AND EDOD.EstadoAuditoria=1

END TRY
BEGIN CATCH
	DECLARE @ERROR_NUMBER INT
	DECLARE @ERROR_SEVERITY INT
	DECLARE @ERROR_STATE INT
	DECLARE @ERROR_PROCEDURE VARCHAR(MAX)
	DECLARE @ERROR_LINE INT
	DECLARE @ERROR_MESSAGE VARCHAR(MAX)
	SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE(),
	@ERROR_PROCEDURE='Tramite.paObtenerExpedienteDocumentoOrigenDestino',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
END CATCH
END
