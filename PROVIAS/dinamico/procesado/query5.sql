ALTER PROCEDURE [Tramite].[paListarExpedienteDocumentoHojaRuta_arq]
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
SET TRAN ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON
BEGIN TRY
		DECLARE @Consulta Nvarchar(max)=''
		DECLARE @ConsultaTotal Nvarchar(max)=''
		DECLARE @Filtros varchar(max)=''
		DECLARE @Offset NVARCHAR(MAX)='';
		DECLARE @Fetch NVARCHAR(MAX)='';
		DECLARE @Orden NVARCHAR(MAX)='';
		DECLARE @Parametros NVARCHAR(MAX)='';
		DECLARE @pTotalRegistros  INT;

		SET @Orden = ' ORDER BY ' + COALESCE(@pCampoOrdenado,'1') + ' ' + COALESCE(@pTipoOrdenacion,'ASC')
		SET @Offset = ' OFFSET ' + CONVERT(VARCHAR(10),(@pNumeroPagina-1)*@pDimensionPagina) + ' ROWS'
		SET @Fetch = ' FETCH NEXT ' + CONVERT(VARCHAR(10),@pDimensionPagina) + ' ROWS ONLY'

		IF COALESCE(@pBusquedaGeneral,'')<>''
		    SET @Filtros ='AND (ED.NumeroDocumento LIKE ''%'+@pBusquedaGeneral +'%'' or ED.AsuntoDocumento LIKE ''%'+ @pBusquedaGeneral +'%'')'
		SET @ConsultaTotal = N'
		SELECT @vpTotalRegistros = count(distinct ED.IdExpedienteDocumento)
		FROM Tramite.Expediente_Historico_' + cast(@pIdPeriodo as varchar) + N' E
		INNER JOIN Tramite.ExpedienteDocumento_Historico_' + cast(@pIdPeriodo as varchar) + N' ED
		    ON ED.IdExpediente=E.IdExpediente
		INNER JOIN Tramite.ExpedienteDocumentoOrigen_Historico_' + cast(@pIdPeriodo as varchar) + N' EDO
		    ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento
			and ED.EstadoAuditoria=1
		INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino_Historico_' + cast(@pIdPeriodo as varchar) + N' EDOD
		    ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen
			and EDO.EstadoAuditoria=1
			and EDOd.EstadoAuditoria=1
		LEFT JOIN Tramite.Catalogo CTD
		    ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
		LEFT JOIN General.Persona p
		    ON p.IdPersona=EDO.IdPersonaOrigen
		LEFT JOIN General.Cargo c
		    ON c.IdCargo=EDO.IdCargoOrigen
		LEFT JOIN General.Area a
		    ON a.IdArea=EDO.IdAreaOrigen
		LEFT JOIN General.Empresa em
		    ON em.IdEmpresa=EDO.IdEmpresaOrigen
		WHERE E.IdExpediente='+LTRIM(@pIdExpediente)+
		' AND EDOD.IdExpedienteDocumentoOrigenDestinoAnterior=0 AND EDOD.IdExpedienteDocumentoOrigenAnterior=0 AND E.EstadoAuditoria=1 AND ED.EstadoAuditoria=1'
		+@Filtros

		SET @Parametros = N'@vpTotalRegistros int OUTPUT';
		EXECUTE sp_executesql @ConsultaTotal,@Parametros, @vpTotalRegistros = @pTotalRegistros OUTPUT

		SET @Consulta= N'
		select distinct
    		E.IdExpediente, ED.IdExpedienteDocumento,COALESCE(EDO.NombreCompletoOrigen,p.NombreCompleto)NombreCompleto,
    		COALESCE(c.NombreCargo,'''')NombreCargo,
    		COALESCE(a.NombreArea,'''')NombreArea,
    		COALESCE(a.Abreviatura,'''')Abrev,
    		COALESCE(em.NombreEmpresa,'''')NombreEmpresa,
    		COALESCE(a.IdArea,0)IdArea,
    		ED.EsVinculado,
    		EDO.FechaOrigen,EDO.HoraOrigen,
    		CASE WHEN ED.Correlativo=0 THEN  CONCAT( CTD.Descripcion,'' '', COALESCE(ED.NumeroDocumento,'''')) ELSE COALESCE(ED.NumeroDocumento,'''') END  NumeroDocumento,
    		ED.AsuntoDocumento,
    		COALESCE(ED.CorrelativoVinculado,'''')CorrelativoVinculado
		FROM Tramite.Expediente_Historico_' + cast(@pIdPeriodo as varchar) + N' E
		INNER JOIN Tramite.ExpedienteDocumento_Historico_' + cast(@pIdPeriodo as varchar) + N' ED
		    ON ED.IdExpediente=E.IdExpediente
		INNER JOIN Tramite.ExpedienteDocumentoOrigen_Historico_' + cast(@pIdPeriodo as varchar) + N' EDO
		    ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento
			and ED.EstadoAuditoria=1
		INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino_Historico_' + cast(@pIdPeriodo as varchar) + N' EDOD
		    ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen
			and EDO.EstadoAuditoria=1
			and EDOd.EstadoAuditoria=1
		LEFT JOIN Tramite.Catalogo CTD
		    ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
		LEFT JOIN General.Persona p
		    ON p.IdPersona=EDO.IdPersonaOrigen
		LEFT JOIN General.Cargo c
		    ON c.IdCargo=EDO.IdCargoOrigen
		LEFT JOIN General.Area a
		    ON a.IdArea=EDO.IdAreaOrigen
		LEFT JOIN General.Empresa em
		    ON em.IdEmpresa=EDO.IdEmpresaOrigen
		WHERE E.IdExpediente='+LTRIM(@pIdExpediente)+
		' AND EDOD.IdExpedienteDocumentoOrigenDestinoAnterior=0 AND EDOD.IdExpedienteDocumentoOrigenAnterior=0 AND E.EstadoAuditoria=1 AND ED.EstadoAuditoria=1'
		+@Filtros
		+@Orden
		+@Offset
		+@Fetch
		EXECUTE sp_executesql @Consulta
		select @pTotalRegistros

END TRY
BEGIN CATCH
	DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
	SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() ,
	@ERROR_PROCEDURE='Tramite.paListarExpedienteDocumentoHojaRuta_arq',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
END CATCH
END
GO

-- EXEC Tramite.paListarExpedienteDocumentoHojaRuta_arq 570251,1059,NULL,NULL,1,10,NULL, 2025
