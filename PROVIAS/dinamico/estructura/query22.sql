ALTER PROCEDURE [Tramite].[paListarPendienteFirmaDigitalJefaturaV2]
	@pIdArea int,
	@pIdUsuarioAuditoria int,
	@pCampoOrdenado varchar(50),
	@pTipoOrdenacion varchar(4),
	@pNumeroPagina INT,
	@pDimensionPagina  INT,
	@pBusquedaGeneral varchar(20),
	@pIdPeriodo int
AS
BEGIN
BEGIN TRY
SET LANGUAGE SPANISH

		SELECT
		E.IdExpediente,
		ED.IdExpedienteDocumento,
		CONCAT(SD.AbreviaturaSerieDocumentalExpediente +RIGHT('000000'+CONVERT(VARCHAR,E.NumeroExpediente),6), '-', E.IdPeriodo) NombreExpediente,
		ED.NumeroDocumento,
		ED.NFechaDocumento,
		ED.AsuntoDocumento,
		COALESCE(ED.NumeroFoliosDocumento,1)NumeroFoliosDocumento,
		ED.RutaArchivoDocumento,
		COALESCE(ED.ObservacionesDocumento,'''') ObservacionesDocumento,
		EDF.IdExpedienteDocumentoFirmante,
		COALESCE(EDF.PosicionX,0)PosicionX,
		COALESCE(EDF.PosicionY,0)PosicionY,
		CASE WHEN ED.IdCargoEmisor IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)) and ED.IdAreaEmisor=@pIdArea and ED.IdEmpresaEmisor=2 THEN 1 ELSE 0 END EsMiDocumento,
		CASE EDF.IdCatalogoTipoFirmante WHEN 296 THEN 'FIRMAR' ELSE 'VISTO BUENO' END+'¦'+F.FaltaFirma TipoFirma,
		(SELECT COUNT(IdExpedienteDocumento) FROM Tramite.ExpedienteDocumento WHERE IdUsuarioEnProcesoFirma =@pIdUsuarioAuditoria AND EnProcesoFirma=1 AND IdExpedienteDocumento=ED.IdExpedienteDocumento AND EstadoAuditoria=1 AND IdPeriodo = @pIdPeriodo) EsLiberado,
		A.NombreArea AreaEmisor,P.NombreCompleto PersonaEmisor,
		isnull(case when EB.FechaHoraBloquea is null then  '0'
		else
			 case when EB.FechaHoraBloquea<=ED.FechaCreacionAuditoria then '1' else '0' end
		end,'0') ExpedienteBloqueado,
		isnull(EB1.PersonaVisualiza,'0') PersonaVisualiza
		FROM Tramite.Expediente E WITH (NOLOCK)
		INNER JOIN Tramite.SerieDocumentalExpediente SD  WITH (NOLOCK) ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente	AND E.ExpedienteAnulado=0
		INNER JOIN Tramite.ExpedienteDocumento ED  WITH (NOLOCK) ON ED.IdExpediente=E.IdExpediente  and e.EstadoAuditoria=1 AND ED.EstadoAuditoria=1 AND ED.FgEnEsperaFirmaDigital=1 AND ED.IdPeriodo = @pIdPeriodo
		INNER JOIN Tramite.ExpedienteDocumentoFirmante EDF  WITH (NOLOCK) ON ED.IdExpedienteDocumento=EDF.IdExpedienteDocumento AND EDF.EstadoAuditoria=1 AND EDF.FlagFirmado=0 AND EDF.IdCargo IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)) AND EDF.IdArea=@pIdArea AND EDF.IdPeriodo = @pIdPeriodo
		INNER JOIN [General].[Area] A ON ED.IdAreaEmisor=A.IdArea
		INNER JOIN [General].[Persona] P ON ED.IdPersonaEmisor=p.IdPersona
		OUTER APPLY(
			select EB.IdExpedienteBloqueado,EB.FechaHoraBloquea
			from Tramite.ExpedienteBloqueado EB
			where ED.IdExpediente=EB.IdExpediente and EB.EstadoAuditoria=1 and EB.EstadoBloqueo=1
		)EB
		OUTER APPLY(
			select '1' PersonaVisualiza
			from Tramite.ExpedienteBloqueadoPersonaVisualiza EBPV
			inner join Seguridad.Usuario U on EBPV.IdPersonaVisualiza=U.IdPersona and U.IdUsuario=@pIdUsuarioAuditoria
			where EB.IdExpedienteBloqueado=EBPV.IdExpedienteBloqueado and EBPV.EstadoAuditoria=1
		)EB1
		CROSS APPLY(
			select
			(SELECT convert(varchar,count(*))
			FROM Tramite.ExpedienteDocumentoFirmante EDF
			WHERE EDF.EstadoAuditoria=1 and EDF.IdExpedienteDocumento=ED.IdExpedienteDocumento and EDF.FlagFirmado=0 AND EDF.IdPeriodo = @pIdPeriodo)+'¦'+
			(select STUFF((
			SELECT
			'¬'+COALESCE(Ep.NombreCompleto,'''')
			FROM Tramite.ExpedienteDocumentoFirmante EDF
			INNER JOIN RecursoHumano.visEmpleadoPerfilPersona EP ON EP.IdEmpleadoPerfil=EDF.IdEmpleadoPerfilFirmante
			WHERE EDF.EstadoAuditoria=1 and EDF.IdExpedienteDocumento=ED.IdExpedienteDocumento and EDF.FlagFirmado=0 AND EDF.IdPeriodo = @pIdPeriodo
			FOR XML PATH('')), 1, 1, '')) FaltaFirma
		)F
		WHERE ED.FlagParaDespacho=1 AND ED.FgEsObligatorioFirmaDigital=1
		AND CONCAT(SD.AbreviaturaSerieDocumentalExpediente, RIGHT(1000000+E.NumeroExpediente,6), '-', E.IdPeriodo) LIKE  case when COALESCE(@pBusquedaGeneral,'')<>'' THEN '%'+@pBusquedaGeneral +'%' ELSE '%' END
		AND E.IdPeriodo = @pIdPeriodo
		ORDER BY ED.IdExpedienteDocumento DESC
        OFFSET (@pNumeroPagina-1)*@pDimensionPagina ROWS
        FETCH NEXT @pDimensionPagina ROWS ONLY

		SELECT COUNT(*)FROM
		Tramite.Expediente E  WITH (NOLOCK)
		INNER JOIN Tramite.SerieDocumentalExpediente SD  WITH (NOLOCK) ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente	AND E.ExpedienteAnulado=0
		INNER JOIN Tramite.ExpedienteDocumento ED  WITH (NOLOCK) ON ED.IdExpediente=E.IdExpediente  and e.EstadoAuditoria=1 AND ED.EstadoAuditoria=1 AND ED.FgEnEsperaFirmaDigital=1 AND ED.IdPeriodo = @pIdPeriodo
		INNER JOIN Tramite.ExpedienteDocumentoFirmante EDF  WITH (NOLOCK) ON ED.IdExpedienteDocumento=EDF.IdExpedienteDocumento AND EDF.EstadoAuditoria=1 AND EDF.FlagFirmado=0 AND EDF.IdCargo IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)) AND EDF.IdArea=@pIdArea AND EDF.IdPeriodo = @pIdPeriodo
		INNER JOIN [General].[Area] A ON ED.IdAreaEmisor=A.IdArea
		INNER JOIN [General].[Persona] P ON ED.IdPersonaEmisor=p.IdPersona
		WHERE ED.FlagParaDespacho=1 AND ED.FgEsObligatorioFirmaDigital=1
		AND CONCAT(SD.AbreviaturaSerieDocumentalExpediente, RIGHT(1000000+E.NumeroExpediente,6), '-', E.IdPeriodo) LIKE  case when COALESCE(@pBusquedaGeneral,'')<>'' THEN '%'+@pBusquedaGeneral +'%' ELSE '%' END
        AND E.IdPeriodo = @pIdPeriodo

END TRY
BEGIN CATCH
	DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
	SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE(),
	@ERROR_PROCEDURE='Tramite.paListarPendienteFirmaDigitalJefaturaV2',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE ,@pIdUsuarioAuditoria
END CATCH
END
