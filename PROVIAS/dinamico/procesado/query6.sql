create PROCEDURE [Tramite].[paListarDemoraAtencionPorExpediente_arq]
	@pIdExpediente int,
	@pIdUsuarioAuditoria int,
	@pCampoOrdenado varchar(50),
	@pTipoOrdenacion varchar(4),
	@pNumeroPagina INT,
	@pDimensionPagina INT,
	@pBusquedaGeneral varchar(100),
	@pIdPeriodo int
AS
BEGIN
BEGIN TRY
set nocount on
set tran isolation level read uncommitted
    Declare @vSql nvarchar(max)
    select @pBusquedaGeneral = isnull(rtrim(ltrim(@pBusquedaGeneral)), '')

    create table #tmp001_Expediente(
        IdExpediente int,
        NombreExpediente varchar(28) collate database_default,
        NumeroDocumento varchar(200) collate database_default,
        NFechaDocumento varchar(10) collate database_default,
        IdExpedienteDocumento int,
        IdExpedienteDocumentoOrigenDestino int,
        AsuntoDocumento varchar(8000) collate database_default,
        NombreEmpleadoPerfilEmisor varchar(626) collate database_default,
        NombreEmpleadoPerfilDestinatario varchar(1026) collate database_default,
        FechaDestino varchar(10) collate database_default,
        FechaDestinoRecepciona varchar(10) collate database_default,
        FechaDestinoEnvia varchar(10) collate database_default,
        SolicitadoAceptado varchar(61) collate database_default,
        DemoraDias int,
        CatalogoSituacionMovimientoDestino varchar(412) collate database_default,
        IdCatalogoSituacionMovimientoDestino int,
        RutaFotoPersona varchar(50) collate database_default,
        RutaFotoPersonaDestino varchar(50) collate database_default
    )

    select @vSql = N'
    insert into #tmp001_Expediente
	SELECT e.IdExpediente,
	CONCAT(SD.AbreviaturaSerieDocumentalExpediente +
	RIGHT(''0000'' + CONVERT(VARCHAR, E.NumeroExpediente), 5), ''-'', E.IdPeriodo) NombreExpediente,
	ED.NumeroDocumento,
	ed.NFechaDocumento,
	ed.IdExpedienteDocumento,
	edod.IdExpedienteDocumentoOrigenDestino,
	UPPER(ED.AsuntoDocumento)AsuntoDocumento,
	CASE WHEN EDO.IdPersonaOrigen = 0 THEN EDO.NombreCompletoOrigen ELSE PO.NombreCompleto END +
	'' - '' + COALESCE (CO.NombreCargo, '''') + '' - '' + COALESCE (AO.Abreviatura, '''') NombreEmpleadoPerfilEmisor,
	CASE WHEN EDOD.IdPersonaDestino = 0 THEN EDOD.DestinatarioDestino ELSE PD.NombreCompleto END +
	'' - '' + COALESCE (CD.NombreCargo, '''') + '' - '' + COALESCE (AD.Abreviatura, '''') NombreEmpleadoPerfilDestinatario,
	EDOD.FechaDestino ,
	EDOD.FechaDestinoRecepciona,
	CASE WHEN COALESCE(EDOD.FechaArchivado,'''')<>'''' THEN EDOD.FechaArchivado ELSE  EDOD.FechaDestinoEnvia END FechaDestinoEnvia,
	CONVERT(VARCHAR, EDOD.NumeroDiasAtencionSolicitado) + ''-'' + CONVERT(VARCHAR, EDOD.NumeroDiasAtencionAceptado) SolicitadoAceptado,
	CASE WHEN
	COALESCE (EDOD.FechaDestinoRecepciona, '''') <> ''''
	THEN DATEDIFF(DAY, CONVERT(DATE, EDOD.FechaDestino), CONVERT(DATE,
		CASE
		WHEN COALESCE(EDOD.FechaArchivado,'''')<>''''
		THEN EDOD.FechaArchivado
		ELSE CASE WHEN COALESCE(EDOD.FechaDestinoEnvia,'''')='''' THEN GETDATE() ELSE EDOD.FechaDestinoEnvia END
		END))
	ELSE DATEDIFF(DAY, CONVERT(DATE, EDOD.FechaDestino),getdate())
	END DemoraDias
	,CSD.Descripcion + COALESCE ('' '' + EDOD.FechaDestinoRecepciona + '''', '''') CatalogoSituacionMovimientoDestino
	,CSD.IdCatalogo IdCatalogoSituacionMovimientoDestino
	,COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(EDO.IdPersonaOrigen),''sinfotoH.jpg'') RutaFotoPersona
    ,COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(EDOD.IdPersonaDestino),''sinfotoH.jpg'') RutaFotoPersonaDestino
	FROM Tramite.Expediente_Historico_' + cast(@pIdPeriodo as varchar) + N' E
	INNER JOIN Tramite.SerieDocumentalExpediente SD
	    ON SD.IdSerieDocumentalExpediente = E.IdSerieDocumentalExpediente
		AND E.ExpedienteAnulado = 0
	INNER JOIN Tramite.ExpedienteDocumento_Historico_' + cast(@pIdPeriodo as varchar) + N' ED
	    ON ED.IdExpediente = E.IdExpediente
		AND e.EstadoAuditoria = 1
	INNER JOIN Tramite.ExpedienteDocumentoOrigen_Historico_' + cast(@pIdPeriodo as varchar) + N' EDO
	    ON ED.IdExpedienteDocumento = EDO.IdExpedienteDocumento
		AND ED.EstadoAuditoria = 1
	INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino_Historico_' + cast(@pIdPeriodo as varchar) + N' EDOD
	    ON EDO.IdExpedienteDocumentoOrigen = EDOD.IdExpedienteDocumentoOrigen
		AND EDO.EstadoAuditoria = 1
		AND EDOD.EstadoAuditoria = 1
	INNER JOIN Tramite.Catalogo CSD
	    ON CSD.IdCatalogo = EDOD.IdCatalogoSituacionMovimientoDestino
	LEFT JOIN General.Area AO
	    ON AO.IdArea = EDO.IdAreaOrigen
	LEFT JOIN General.Cargo CO
	    ON CO.IdCargo = EDO.IdCargoOrigen
	LEFT JOIN General.Persona PO
	    ON PO.IdPersona = EDO.IdPersonaOrigen
	LEFT JOIN General.Area AD
	    ON AD.IdArea = EDOD.IdAreaDestino
	LEFT JOIN General.Area ADP
	    ON ADP.IdArea = AD.IdArea
	LEFT JOIN General.Cargo CD
	    ON CD.IdCargo = EDOD.IdCargoDestino
	LEFT JOIN General.Persona PD
	    ON PD.IdPersona = EDOD.IdPersonaDestino
	where E.IdExpediente = @pIdExpediente'

	EXEC sp_executesql @vSql,
	    N'@pIdExpediente int',
		@pIdExpediente = @pIdExpediente

	select*from #tmp001_Expediente
	where (AsuntoDocumento LIKE concat('%',@pBusquedaGeneral,'%') OR NumeroDocumento LIKE concat('%', @pBusquedaGeneral, '%'))
	ORDER BY idexpedientedocumentoorigendestino desc
	OFFSET (@pNumeroPagina-1)*@pDimensionPagina ROWS
	FETCH NEXT @pDimensionPagina ROWS ONLY

    select count(1) from #tmp001_Expediente

END TRY
BEGIN CATCH
	DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
	SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Obras.paListarProyecto',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE ,@pIdUsuarioAuditoria
END CATCH
END
GO
