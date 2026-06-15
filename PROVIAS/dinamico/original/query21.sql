CREATE PROCEDURE [Tramite].[paListarCarpetaDocumentosPorExpedienteV1]
	@pIdExpediente int,
	@pIdUsuarioAuditoria int
AS
BEGIN TRY

	DECLARE @vIdPersonaActual int=0
	SELECT @vIdPersonaActual=IdPersona from Seguridad.Usuario where IdUsuario=@pIdUsuarioAuditoria AND EstadoAuditoria=1 AND Bloqueado=0

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
	Tramite.funDevolverPeriodoDocumento(GETDATE(),ED.FechaCreacionAuditoria) PeriodoCreadoDocumento
	,ed.FgEsObligatorioFirmaDigital
	FROM
	Tramite.ExpedienteDocumento ED
	INNER JOIN Tramite.Expediente EX ON EX.IdExpediente=ED.IdExpediente
	INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente=EX.IdSerieDocumentalExpediente
	INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND EDO.EstadoAuditoria=1 AND ED.EstadoAuditoria=1
	LEFT JOIN Tramite.Catalogo CTD ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
	LEFT JOIN Tramite.ExpedienteDocumentoAdjunto EDA ON EDA.IdExpedienteDocumento=ED.IdExpedienteDocumento AND EDA.EstadoAuditoria=1 AND ED.EstadoAuditoria=1
	LEFT JOIN Tramite.ExpedienteDocumentoOrigenAdjunto EDOA ON EDOA.IdExpedienteDocumentoOrigenEDO=EDO.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1 AND EDOA.EstadoAuditoria=1
	OUTER APPLY(
		select EB.IdExpedienteBloqueado,EB.FechaHoraBloquea
		from Tramite.ExpedienteBloqueado EB
		where ED.IdExpediente=EB.IdExpediente and EB.EstadoAuditoria=1 and EB.EstadoBloqueo=1
	)EB
	OUTER APPLY(
		select '1' PersonaVisualiza
		from Tramite.ExpedienteBloqueadoPersonaVisualiza EBPV --and EBPV.IdPersonaVisualiza=@pIdPersona
		inner join Seguridad.Usuario U on EBPV.IdPersonaVisualiza=U.IdPersona and U.IdUsuario=@pIdUsuarioAuditoria
		where EB.IdExpedienteBloqueado=EBPV.IdExpedienteBloqueado and EBPV.EstadoAuditoria=1
	)EB1
	cross apply(
		select isnull(max(1),0) doc
		from Tramite.ExpedienteDocumentoFirmante EDF
		where EDF.IdExpedienteDocumento=ED.IdExpedienteDocumento and EDF.IdPersona=@vIdPersonaActual and EDF.EstadoAuditoria=1
	) Ver
	WHERE ED.IdExpediente=@pIdExpediente
	and (isnull(EB.FechaHoraBloquea,dateadd(day,1,ed.FechaCreacionAuditoria))>ed.FechaCreacionAuditoria or isnull(EB1.PersonaVisualiza,'0') ='1')
    and not (ED.FgEnEsperaFirmaDigital=1 and Ver.doc=0)
	order by ed.FechaCreacionAuditoria desc
END TRY
BEGIN CATCH
	DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
	SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarExpedientePendienteEspecialista',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE, @pIdUsuarioAuditoria
END CATCH
