ALTER PROCEDURE [Tramite].[paListarDocumentoPendienteJefatura]
    @pIdExpediente int,
    @pIdArea int,
    @pIdUsuarioAuditoria int,
    @pCampoOrdenado varchar(50),
    @pTipoOrdenacion varchar(4),
    @pNumeroPagina INT,
    @pDimensionPagina  INT,
    @pBusquedaGeneral varchar(100),
    @pVerSoloMio INT,
    @pCorrelativoVinculado int,
    @pIdPeriodo int
AS
BEGIN
BEGIN TRY
SET LANGUAGE SPANISH;

	DECLARE @vIdPersonaActual int=0,@vIdCargoJefeEsMio int,@vIdAreaJefeEsMio int,@vIdEmpresaJefeEsMio int
	SELECT @vIdCargoJefeEsMio=IdCargo, @vIdAreaJefeEsMio=IdArea,@vIdEmpresaJefeEsMio=IdEmpresa FROM RecursoHumano.visPersonaJefe where IdArea=@pIdArea

	SELECT @vIdPersonaActual=IdPersona from Seguridad.Usuario where IdUsuario=@pIdUsuarioAuditoria AND EstadoAuditoria=1 AND Bloqueado=0

	DECLARE @vSiPariticipo int=0

	IF @pIdUsuarioAuditoria IN(select IdUsuario from Tramite.[PermisoVisualizacionDocumentos] where IdTipoFormulario=1 and EstadoAuditoria=1 and convert(date, GETDATE() )between convert(date,FechaInicioPersmiso) and convert(date,FechaFinPersmiso))
	BEGIN
		SET @vSiPariticipo=1
	END
	ELSE
	BEGIN
		SET @vSiPariticipo=(select COUNT(ED.IdPersonaEmisor) FROM Tramite.ExpedienteDocumento ED
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1 AND EDO.IdPeriodo = @pIdPeriodo
		INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen  AND EDO.EstadoAuditoria=1 AND EDOD.IdPeriodo = @pIdPeriodo
		WHERE ED.IdPeriodo = @pIdPeriodo AND ED.IdExpediente=@pIdExpediente AND
		(
		(EDOD.IdAreaDestino=@vIdAreaJefeEsMio) OR (EDO.IdAreaOrigen=@vIdAreaJefeEsMio))
		)
	END

    DECLARE @vIdCargoJefe int=0
    DECLARE @vIdAreaJefe int=0
    DECLARE @vIdEmpresaJefe int=0

    SELECT @vIdCargoJefe=IdCargo, @vIdAreaJefe=IdArea,@vIdEmpresaJefe=IdEmpresa FROM RecursoHumano.visPersonaJefe where IdArea=@pIdArea
	DECLARE @vCargoJefe VARCHAR(MAX)='';

	 SET @vCargoJefe='SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)'

    DECLARE @Consulta Nvarchar(max)=''
    DECLARE @ConsultaTotal Nvarchar(max)=''
    DECLARE @Filtros Nvarchar(max)=''
    DECLARE @Offset NVARCHAR(MAX)='';
    DECLARE @Fetch NVARCHAR(MAX)='';
    DECLARE @Orden NVARCHAR(MAX)='';
    DECLARE @Parametros NVARCHAR(MAX)='';
    DECLARE @pTotalRegistros  INT;
    DECLARE @vCondicionVerSoloMio nVARCHAR(200)=''
    DECLARE @vCondicionVinculado nVARCHAR(200)=''

	IF @pVerSoloMio=1
    BEGIN
    	SET @vCondicionVerSoloMio=' AND CASE WHEN EDOD.IdCargoDestino IN('+@vCargoJefe+') and EDOD.IdAreaDestino='+CONVERT(Nvarchar,@vIdAreaJefe)+
    	' and EDOD.IdEmpresaDestino='+CONVERT(Nvarchar,@vIdEmpresaJefe)+' THEN 1 ELSE 0 END=1'
    END

    IF @pCorrelativoVinculado>=0
    BEGIN
    	SET @vCondicionVinculado=' AND ED.CorrelativoVinculado ='+CONVERT(Nvarchar,@pCorrelativoVinculado)
    END

    SET @Orden=' ORDER BY CONVERT(DATETIME,edo.FechaOrigen +'' '' + edo.HoraOrigen) DESC, EDOD.IdExpedienteDocumentoOrigenDestino DESC '
    SET @Offset= ' OFFSET ' +CONVERT(VARCHAR(10),(@pNumeroPagina-1)*@pDimensionPagina) + ' ROWS'
    SET @Fetch= ' FETCH NEXT '+CONVERT(VARCHAR(10),@pDimensionPagina) +' ROWS ONLY'

    IF COALESCE(@pBusquedaGeneral,'')<>'' SET @Filtros =' AND (CSM.Descripcion LIKE ''%'+@pBusquedaGeneral +'%'')'
    SET @ConsultaTotal = N'SELECT @vpTotalRegistros = count(*)
    FROM Tramite.Expediente E
    INNER JOIN Tramite.ExpedienteDocumento ED ON ED.IdExpediente=E.IdExpediente AND ED.IdPeriodo = @pIdPeriodo
    INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1 AND EDO.IdPeriodo = @pIdPeriodo
    INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen  AND EDO.EstadoAuditoria=1 AND EDOD.IdPeriodo = @pIdPeriodo
    INNER JOIN Tramite.Catalogo CTD ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
    INNER JOIN Tramite.Catalogo CSM ON CSM.IdCatalogo=EDOD.IdCatalogoSituacionMovimientoDestino
    INNER JOIN Tramite.Catalogo CTM ON CTM.IdCatalogo=EDOD.IdCatalogoTipoMovimientoDestino
	INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
    LEFT JOIN General.Empresa EMO ON EMO.IdEmpresa=EDO.IdEmpresaOrigen
    LEFT JOIN General.Area AO ON AO.IdArea= EDO.IdAreaOrigen
    LEFT JOIN General.Cargo CO ON CO.IdCargo=EDO.IdCargoOrigen
    LEFT JOIN General.Empresa EMD ON EMD.IdEmpresa=EDOD.IdEmpresaDestino
    LEFT JOIN General.Area AD ON AD.IdArea= EDOD.IdAreaDestino
    LEFT JOIN General.Cargo CD ON CD.IdCargo=EDOD.IdCargoDestino
    LEFT JOIN General.Persona PD ON PD.IdPersona=EDOD.IdPersonaDestino
    LEFT JOIN General.Persona PO ON PO.IdPersona=EDO.IdPersonaOrigen
    LEFT JOIN General.Empresa EMR ON EMR.IdEmpresa=EDOD.IdEmpresaDestinoRecepciona
    LEFT JOIN General.Area AR ON AR.IdArea= EDOD.IdAreaDestinoRecepciona
    LEFT JOIN General.Cargo CR ON CR.IdCargo=EDOD.IdCargoDestinoRecepciona
    LEFT JOIN General.Persona PR ON PR.IdPersona=EDOD.IdPersonaDestinoRecepciona
    LEFT JOIN General.Empresa EMA ON EMA.IdEmpresa=EDOD.IdEmpresaDestinoAtencion
    LEFT JOIN General.Area AA ON AA.IdArea= EDOD.IdAreaDestinoAtencion
    LEFT JOIN General.Cargo CA ON CA.IdCargo=EDOD.IdCargoDestinoAtencion
    LEFT JOIN General.Persona PA ON PA.IdPersona=EDOD.IdPersonaDestinoAtencion
	LEFT JOIN Courrier.Envio EE ON EE.IdExpedienteDocumentoOrigenDestino =	EDOD.IdExpedienteDocumentoOrigenDestino AND EE.EstadoAuditoria=1 AND FgEntregado=0
	LEFT JOIN Courrier.Catalogo CSMEE ON CSMEE.IdCatalogo=EE.IdCatalogoSituacionEnvio
    WHERE E.IdPeriodo = @pIdPeriodo AND EDOD.EstadoAuditoria=1 AND E.IdExpediente='+CONVERT(NVARCHAR,@pIdExpediente)
    +@Filtros + @vCondicionVerSoloMio + @vCondicionVinculado

    SET @Parametros = N'@pIdPeriodo int, @vpTotalRegistros int OUTPUT';
    EXECUTE sp_executesql @ConsultaTotal,@Parametros, @pIdPeriodo = @pIdPeriodo, @vpTotalRegistros = @pTotalRegistros OUTPUT

    DECLARE @vCampoExtra NVARCHAR(MAX)=N'\
    Seguridad.funObtenerUsuario(edo.IdUsuarioCreacionAuditoria)Logueo,Tramite.funPaseTieneAdjunto(EDO.IdExpedienteDocumentoOrigen) PaseTieneAdjunto,Tramite.funDocumentoTieneAdjunto(ED.IdExpedienteDocumento) DocumentoTieneAdjunto,CONCAT(SD.AbreviaturaSerieDocumentalExpediente +RIGHT(''000000''+CONVERT(VARCHAR,E.NumeroExpediente),6), ''-'', E.IdPeriodo,CASE WHEN COALESCE(ED.CorrelativoVinculado,0)=0 THEN '''' ELSE '' V-''+CONVERT(VARCHAR,ED.CorrelativoVinculado) END) NombreExpediente, '

    SET @Consulta='SELECT '+
    @vCampoExtra+
	CONVERT(VARCHAR,@vSiPariticipo) +' SiPariticipo,
	ED.CorrelativoVinculado ,
	EDO.EsVinculado,
	E.ExpedienteAnulado,
    E.IdExpediente,
    ED.IdExpedienteDocumento,
    EDOD.IdExpedienteDocumentoOrigenDestino,
    EDOD.IdExpedienteDocumentoOrigen,
	CASE WHEN EE.IdEnvio IS NULL THEN EDOD.IdCatalogoSituacionMovimientoDestino
	ELSE CASE WHEN EE.IdCatalogoSituacionEnvio = 14 THEN EDOD.IdCatalogoSituacionMovimientoDestino ELSE EE.IdCatalogoSituacionEnvio END
	END IdCatalogoSituacionMovimientoDestino,
	CASE WHEN EE.IdEnvio IS NULL THEN CSM.Descripcion ELSE
	CASE WHEN EE.IdCatalogoSituacionEnvio = 14 THEN CSM.Descripcion ELSE CSMEE.Descripcion END END CatalogoSituacionMovimientoDestino,
    EDOD.IdCatalogoTipoMovimientoDestino,
    CTM.Descripcion CatalogoTipoMovimientoDestino,
    COALESCE(EDO.IdCatalogoTipodevolucion,0) IdCatalogoTipoDevolucion,
    EDOD.NumeroDiasAtencionSolicitado,
    COALESCE(EDOD.FechaDestinoRecepciona,'''')FechaDestinoRecepciona,
    COALESCE(EDOD.HoraDestinoRecepciona,'''')HoraDestinoRecepciona,
    COALESCE(EMO.NombreEmpresa,'''') NombreEmpresaOrigen,
    COALESCE(AO.NombreArea,'''') NombreAreaOrigen,
    COALESCE(CO.NombreCargo,'''') NombreCargoOrigen,
    COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(EDO.IdPersonaOrigen),''sinfotoH.jpg'') RutaFotoPersona,
    COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(EDOD.IdPersonaDestino),''sinfotoH.jpg'') RutaFotoPersonaDestino,
    CASE WHEN EDO.IdPersonaOrigen=0 THEN EDO.NombreCompletoOrigen ELSE CASE WHEN CTM.IdCatalogo=71 THEN EDO.NombreCompletoOrigen  ELSE PO.NombreCompleto END END  NombrePersonaOrigen,
    COALESCE(EDOD.NumeroDiasAtencionAceptado,0)NumeroDiasAtencionAceptado,
    EDOD.Original,
    EDOD.Copia,
    EDOD.FechaDestino,
    EDOD.HoraDestino,
	EDO.FechaOrigen,
    EDO.HoraOrigen,
    COALESCE(EDOD.FechaDestinoEnvia,'''') FechaDestinoEnvia,
    COALESCE(EDOD.HoraDestinoEnvia,'''') HoraDestinoEnvia,
    COALESCE(EMD.NombreEmpresa,COALESCE(EDOD.DestinatarioDestino,'''')) NombreEmpresaDestino,
    COALESCE(AD.NombreArea,'''') NombreAreaDestino,
    COALESCE(CD.NombreCargo,'''') NombreCargoDestino,
    COALESCE(PD.NombreCompleto,'''') NombrePersonaDestino,
    COALESCE(EMR.NombreEmpresa,''EXTERNO'') NombreEmpresaDestinoRecepciona,
    COALESCE(AR.NombreArea,'''') NombreAreaDestinoRecepciona,
    COALESCE(CR.NombreCargo,'''') NombreCargoDestinoRecepciona,
    COALESCE(PR.NombreCompleto,'''') NombrePersonaDestinoRecepciona,
    COALESCE(EMA.NombreEmpresa,''EXTERNO'') NombreEmpresaDestinoAtencion,
    COALESCE(AA.NombreArea,'''') NombreAreaDestinoAtencion,
    COALESCE(CA.NombreCargo,'''') NombreCargoDestinoAtencion,
    COALESCE(PA.NombreCompleto,'''') NombrePersonaDestinoAtencion,
    COALESCE(EDOD.ObservacionesDestinatario,'''') ObservacionesDestinatario,
    Tramite.funMostrarAccionesPorDestino(EDOD.IdExpedienteDocumentoOrigenDestino) Acciones,
    CASE WHEN EDOD.IdCargoDestino IN('+@vCargoJefe+') and EDOD.IdAreaDestino='+CONVERT(Nvarchar,@vIdAreaJefe)+' and EDOD.IdEmpresaDestino='+CONVERT(Nvarchar,@vIdEmpresaJefe)+' THEN 1 ELSE 0 END EsPropio,
    CASE WHEN ED.IdCargoEmisor IN('+@vCargoJefe+') and ED.IdAreaEmisor='+CONVERT(Nvarchar,@vIdAreaJefe)+' and ED.IdEmpresaEmisor='+CONVERT(Nvarchar,@vIdEmpresaJefe)+' THEN 1 ELSE 0 END EsMiDocumento,
    CASE WHEN EDO.IdCargoOrigen IN('+@vCargoJefe+') and EDO.IdAreaOrigen='+CONVERT(Nvarchar,@vIdAreaJefe)+' and EDO.IdEmpresaOrigen='+CONVERT(Nvarchar,@vIdEmpresaJefe)+' THEN 1 ELSE 0 END EsOrigen,
    CTD.Descripcion CatalogoTipoDocumento,
	CTD.IdCatalogo IdCatalogoTipoDocumento,
    E.IdCatalogoTipoTramite,
	CASE WHEN ED.Correlativo=0 THEN  CONCAT( CTD.Descripcion,'' '', COALESCE(ED.NumeroDocumento,'''')) ELSE COALESCE(ED.NumeroDocumento,'''') END  NumeroDocumento,
    COALESCE(ED.AsuntoDocumento,'''') AsuntoDocumento,
    COALESCE(ED.RutaArchivoDocumento,'''') RutaArchivoDocumento,
    COALESCE(EDOD.FechaArchivado,'''')FechaArchivado,
    Tramite.funEsExtornable(EDOD.IdExpedienteDocumentoOrigen,EDOD.IdExpedienteDocumentoOrigenDestino) EsExtornable,
    EDOD.EsInicial,
	COALESCE(EDO.Descripciondevolucion,'''') DescripcionDevolucion,
	COALESCE(EDOD.MotivoArchivado,'''')MotivoArchivado,
	COALESCE(EE.FechaEntregaDocumento,'''')FechaEntregaDocumento,
	COALESCE(EE.HoraEntregaDocumento,'''')HoraEntregaDocumento,
	COALESCE(EE.RutaArchivoCargo,'''')RutaArchivoCargo,
	ED.FgEsObligatorioFirmaDigital,
	ED.FgEnEsperaFirmaDigital,
	ED.FlagParaDespacho
    FROM Tramite.Expediente E
    INNER JOIN Tramite.ExpedienteDocumento ED ON ED.IdExpediente=E.IdExpediente AND ED.IdPeriodo = @pIdPeriodo
    INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1 AND EDO.IdPeriodo = @pIdPeriodo
    INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen  AND EDO.EstadoAuditoria=1 AND EDOD.IdPeriodo = @pIdPeriodo
    INNER JOIN Tramite.Catalogo CTD ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
    INNER JOIN Tramite.Catalogo CSM ON CSM.IdCatalogo=EDOD.IdCatalogoSituacionMovimientoDestino
    INNER JOIN Tramite.Catalogo CTM ON CTM.IdCatalogo=EDOD.IdCatalogoTipoMovimientoDestino
	INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
    LEFT JOIN General.Empresa EMO ON EMO.IdEmpresa=EDO.IdEmpresaOrigen
    LEFT JOIN General.Area AO ON AO.IdArea= EDO.IdAreaOrigen
    LEFT JOIN General.Cargo CO ON CO.IdCargo=EDO.IdCargoOrigen
    LEFT JOIN General.Empresa EMD ON EMD.IdEmpresa=EDOD.IdEmpresaDestino
    LEFT JOIN General.Area AD ON AD.IdArea= EDOD.IdAreaDestino
    LEFT JOIN General.Cargo CD ON CD.IdCargo=EDOD.IdCargoDestino
    LEFT JOIN General.Persona PD ON PD.IdPersona=EDOD.IdPersonaDestino
    LEFT JOIN General.Persona PO ON PO.IdPersona=EDO.IdPersonaOrigen
    LEFT JOIN General.Empresa EMR ON EMR.IdEmpresa=EDOD.IdEmpresaDestinoRecepciona
    LEFT JOIN General.Area AR ON AR.IdArea= EDOD.IdAreaDestinoRecepciona
    LEFT JOIN General.Cargo CR ON CR.IdCargo=EDOD.IdCargoDestinoRecepciona
    LEFT JOIN General.Persona PR ON PR.IdPersona=EDOD.IdPersonaDestinoRecepciona
    LEFT JOIN General.Empresa EMA ON EMA.IdEmpresa=EDOD.IdEmpresaDestinoAtencion
    LEFT JOIN General.Area AA ON AA.IdArea= EDOD.IdAreaDestinoAtencion
    LEFT JOIN General.Cargo CA ON CA.IdCargo=EDOD.IdCargoDestinoAtencion
    LEFT JOIN General.Persona PA ON PA.IdPersona=EDOD.IdPersonaDestinoAtencion
	LEFT JOIN Courrier.Envio EE ON EE.IdExpedienteDocumentoOrigenDestino =	EDOD.IdExpedienteDocumentoOrigenDestino AND EE.EstadoAuditoria=1 AND FgEntregado=0
	LEFT JOIN Courrier.Catalogo CSMEE ON CSMEE.IdCatalogo=EE.IdCatalogoSituacionEnvio
    WHERE E.IdPeriodo = @pIdPeriodo AND EDOD.EstadoAuditoria=1 AND E.IdExpediente='+CONVERT(NVARCHAR,@pIdExpediente)
    +@Filtros + @vCondicionVerSoloMio + @vCondicionVinculado + @Orden + @Offset + @Fetch

    EXECUTE sp_executesql @Consulta, N'@pIdPeriodo int', @pIdPeriodo
    select @pTotalRegistros

END TRY
BEGIN CATCH
    DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX) ,@ERROR_MESSAGE VARCHAR(MAX)
    SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE(),
    @ERROR_PROCEDURE='Tramite.paListarDocumentoPendienteJefatura',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
    EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
END CATCH
END
