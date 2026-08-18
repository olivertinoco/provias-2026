ALTER PROCEDURE [Tramite].[paListarPendienteFirmaDigitalEspecialistaV1]
    @pIdArea int,
    @pIdCargo int,
    @pIdPersona int,
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
SET NOCOUNT ON;

    DECLARE @Consulta Nvarchar(max)=''
    DECLARE @ConsultaTotal Nvarchar(max)=''
    DECLARE @Filtros varchar(max)=''
    DECLARE @Offset NVARCHAR(MAX)='';
    DECLARE @Fetch NVARCHAR(MAX)='';
    DECLARE @Orden NVARCHAR(MAX)='';
    DECLARE @Parametros NVARCHAR(MAX)='';
    DECLARE @pTotalRegistros  INT;
    DECLARE @vIdAreaJefe INT=0;

    SET @Orden=' ORDER BY ED.IdExpedienteDocumento DESC '
    SET @Offset= ' OFFSET ' +CONVERT(VARCHAR(10),(@pNumeroPagina-1)*@pDimensionPagina) + ' ROWS'
    SET @Fetch= ' FETCH NEXT '+CONVERT(VARCHAR(10),@pDimensionPagina) +' ROWS ONLY'

	IF COALESCE(@pBusquedaGeneral,'')<>'' SET @Filtros ='AND (CONCAT(SD.AbreviaturaSerieDocumentalExpediente +RIGHT(''000000''+CONVERT(VARCHAR,E.NumeroExpediente),6), ''-'', E.IdPeriodo) LIKE ''%'+@pBusquedaGeneral +'%'')'

	SET @ConsultaTotal = N'SELECT @vpTotalRegistros = count(*)
	FROM Tramite.Expediente E
	INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente	AND E.ExpedienteAnulado=0
	INNER JOIN Tramite.ExpedienteDocumento ED ON ED.IdExpediente=E.IdExpediente  and e.EstadoAuditoria=1 AND ED.EstadoAuditoria=1 AND ED.FgEnEsperaFirmaDigital=1
	INNER JOIN Tramite.ExpedienteDocumentoFirmante EDF ON ED.IdExpedienteDocumento=EDF.IdExpedienteDocumento AND EDF.EstadoAuditoria=1 AND EDF.IdArea='+convert(varchar,@pIdArea)+' AND EDF.IdCargo='+convert(varchar,@pIdCargo)+' AND EDF.IdPersona='+convert(varchar,@pIdPersona)
	+' WHERE 1=1 AND EDF.FlagFirmado=0 AND FgEsObligatorioFirmaDigital=1 ' + @Filtros

	SET @Parametros = N'@vpTotalRegistros int OUTPUT';
	EXECUTE sp_executesql @ConsultaTotal,@Parametros, @vpTotalRegistros = @pTotalRegistros OUTPUT

	SET @Consulta=' SELECT
	E.IdExpediente,
	ED.IdExpedienteDocumento,
	EDF.IdExpedienteDocumentoFirmante,
	CONCAT(SD.AbreviaturaSerieDocumentalExpediente +RIGHT(''000000''+CONVERT(VARCHAR,E.NumeroExpediente),6), ''-'', E.IdPeriodo) NombreExpediente,
	ED.NumeroDocumento,
	ED.NFechaDocumento,
	ED.AsuntoDocumento,
	COALESCE(ED.NumeroFoliosDocumento,1)NumeroFoliosDocumento,
	ED.RutaArchivoDocumento,
	COALESCE(ED.ObservacionesDocumento,'''') ObservacionesDocumento,
	COALESCE(EDF.PosicionX,0)PosicionX,
	COALESCE(EDF.PosicionY,0)PosicionY,
	CASE EDF.IdCatalogoTipoFirmante WHEN 296 THEN ''FIRMAR'' ELSE ''VISTO BUENO'' END TipoFirma,
	(SELECT COUNT(IdExpedienteDocumento) FROM Tramite.ExpedienteDocumento WHERE IdUsuarioEnProcesoFirma ='+CONVERT(varchar,@pIdUsuarioAuditoria)+' AND EnProcesoFirma=1 AND IdExpedienteDocumento=ED.IdExpedienteDocumento AND EstadoAuditoria=1) EsLiberado,
	isnull(case when EB.FechaHoraBloquea is null then  ''0''
	else
		 case when EB.FechaHoraBloquea<=ED.FechaCreacionAuditoria then ''1'' else ''0'' end
	end,''0'') ExpedienteBloqueado,
	isnull(EB1.PersonaVisualiza,''0'') PersonaVisualiza
	FROM
	Tramite.Expediente E
	INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente	AND E.ExpedienteAnulado=0
	INNER JOIN Tramite.ExpedienteDocumento ED ON ED.IdExpediente=E.IdExpediente  and e.EstadoAuditoria=1 AND ED.EstadoAuditoria=1 AND ED.FgEnEsperaFirmaDigital=1
	INNER JOIN Tramite.ExpedienteDocumentoFirmante EDF ON ED.IdExpedienteDocumento=EDF.IdExpedienteDocumento AND EDF.EstadoAuditoria=1 AND EDF.IdArea='+convert(varchar,@pIdArea)+' AND EDF.IdCargo='+convert(varchar,@pIdCargo)+' AND EDF.IdPersona='+convert(varchar,@pIdPersona)
	+' OUTER APPLY(
		select EB.IdExpedienteBloqueado,EB.FechaHoraBloquea
		from Tramite.ExpedienteBloqueado EB
		where ED.IdExpediente=EB.IdExpediente and EB.EstadoAuditoria=1 and EB.EstadoBloqueo=1
	)EB
	OUTER APPLY(
		select ''1'' PersonaVisualiza
		from Tramite.ExpedienteBloqueadoPersonaVisualiza EBPV
		inner join Seguridad.Usuario U on EBPV.IdPersonaVisualiza=U.IdPersona and U.IdUsuario='+CONVERT(varchar,@pIdUsuarioAuditoria)+'
		where EB.IdExpedienteBloqueado=EBPV.IdExpedienteBloqueado and EBPV.EstadoAuditoria=1
	)EB1
	WHERE 1=1 AND EDF.FlagFirmado=0 AND FgEsObligatorioFirmaDigital=1 ' + @Filtros + @Orden + @Offset + @Fetch

	EXECUTE sp_executesql @Consulta
	SELECT @pTotalRegistros TotalRegistros

END TRY
BEGIN CATCH
	DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
	SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE(),
	@ERROR_PROCEDURE='Tramite.paListarPendienteFirmaDigitalEspecialistaV1',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE ,@pIdUsuarioAuditoria
END CATCH
END
