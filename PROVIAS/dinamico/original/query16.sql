CREATE PROCEDURE [Tramite].[paListarDocumentoPendienteCourrierJefatura]
       @pIdExpediente int,
       @pIdArea int,
       @pIdUsuarioAuditoria int,
       @pCampoOrdenado varchar(50),
       @pTipoOrdenacion varchar(4),
       @pNumeroPagina INT,
       @pDimensionPagina  INT,
       @pBusquedaGeneral varchar(100),
	   @pVerSoloMio INT
AS
BEGIN TRY
	SET LANGUAGE SPANISH;

    DECLARE @vIdCargoJefe int=0
    DECLARE @vIdAreaJefe int=0
    DECLARE @vIdEmpresaJefe int=0

    SELECT @vIdCargoJefe=IdCargo, @vIdAreaJefe=IdArea,@vIdEmpresaJefe=IdEmpresa FROM RecursoHumano.visPersonaJefe where IdArea=@pIdArea
	DECLARE @vCargoJefe VARCHAR(MAX)=''

		SET @vCargoJefe='SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)'

        DECLARE @Consulta Nvarchar(max)=''
        DECLARE @ConsultaTotal Nvarchar(max)=''
        DECLARE @Filtros Nvarchar(max)=''
        DECLARE @Offset NVARCHAR(MAX)='';
        DECLARE @Fetch NVARCHAR(MAX)='';
        DECLARE @Orden NVARCHAR(MAX)='';
        DECLARE @Parametros NVARCHAR(MAX)='';
        DECLARE @pTotalRegistros  INT;
        DECLARE @vCondicionVerSoloMio VARCHAR(200)=''


        SET @Orden=' ORDER BY CONVERT(DATETIME,edo.FechaOrigen +'' '' + edo.HoraOrigen) DESC, EDOD.IdExpedienteDocumentoOrigenDestino DESC '
        SET @Offset= ' OFFSET ' +CONVERT(VARCHAR(10),(@pNumeroPagina-1)*@pDimensionPagina) + ' ROWS'
        SET @Fetch= ' FETCH NEXT '+CONVERT(VARCHAR(10),@pDimensionPagina) +' ROWS ONLY'

        IF COALESCE(@pBusquedaGeneral,'')<>'' SET @Filtros =' AND (CSM.Descripcion LIKE ''%'+@pBusquedaGeneral +'%'')'
        SET @ConsultaTotal = N'SELECT @vpTotalRegistros = count(*)
        FROM Tramite.Expediente E
        INNER JOIN Tramite.ExpedienteDocumento ED ON ED.IdExpediente=E.IdExpediente
        INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
        INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen  AND EDO.EstadoAuditoria=1
        INNER JOIN Tramite.Catalogo CTD ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
        INNER JOIN Tramite.Catalogo CSM ON CSM.IdCatalogo=EDOD.IdCatalogoSituacionMovimientoDestino
        INNER JOIN Tramite.Catalogo CTM ON CTM.IdCatalogo=EDOD.IdCatalogoTipoMovimientoDestino
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
		LEFT JOIN Courrier.Envio EE ON EE.IdExpedienteDocumentoOrigenDestino =	EDOD.IdExpedienteDocumentoOrigenDestino AND EE.EstadoAuditoria=1 AND COALESCE(EE.FgEntregado,0)=0
		LEFT JOIN Courrier.Courriers CU ON CU.IdCourriers =EE.IdCourriers
		LEFT JOIN Courrier.Catalogo CSMEE ON CSMEE.IdCatalogo=EE.IdCatalogoSituacionEnvio
		LEFT JOIN Courrier.Destino DM ON DM.PersonaDestino= CASE WHEN CHARINDEX('''',COALESCE(EDOD.DestinatarioDestino,''0''))=0 THEN COALESCE(EDOD.DestinatarioDestino,'''') ELSE  RTRIM(LTRIM(REPLACE( SUBSTRING(COALESCE(EDOD.DestinatarioDestino,''''),1, CHARINDEX('''',COALESCE(EDOD.DestinatarioDestino,''0''))  ),'''',''''))) END AND DM.EstadoAuditoria=1
        WHERE EDOD.EstadoAuditoria=1 AND EDOD.IdCatalogoTipoMovimientoDestino=72 AND E.IdExpediente='+CONVERT(NVARCHAR,@pIdExpediente) +' AND EDO.IdAreaOrigenEnvia='+CONVERT(VARCHAR,@pIdArea)
        +@Filtros
		+@vCondicionVerSoloMio
		print @ConsultaTotal
        SET @Parametros = N'@vpTotalRegistros int OUTPUT';
        EXECUTE sp_executesql @ConsultaTotal,@Parametros, @vpTotalRegistros = @pTotalRegistros OUTPUT

        SET @Consulta='
			SELECT
			ED.CorrelativoVinculado ,
			EDO.EsVinculado,
			E.ExpedienteAnulado,
            E.IdExpediente,
            ED.IdExpedienteDocumento,
            EDOD.IdExpedienteDocumentoOrigenDestino,
            EDOD.IdExpedienteDocumentoOrigen,
            CASE WHEN EE.IdEnvio IS NULL THEN EDOD.IdCatalogoSituacionMovimientoDestino ELSE EE.IdCatalogoSituacionEnvio END IdCatalogoSituacionMovimientoDestino,
			COALESCE(CASE WHEN EE.IdEnvio IS NULL THEN CSM.Descripcion ELSE CSMEE.Descripcion END,'''') CatalogoSituacionMovimientoDestino,
            EDOD.IdCatalogoTipoMovimientoDestino,
            COALESCE(CTM.Descripcion,'''') CatalogoTipoMovimientoDestino,
            COALESCE(EDO.IdCatalogoTipodevolucion,0) IdCatalogoTipoDevolucion,
            EDOD.NumeroDiasAtencionSolicitado,
            COALESCE(EDOD.FechaDestinoRecepciona,'''')FechaDestinoRecepciona,
            COALESCE(EDOD.HoraDestinoRecepciona,'''')HoraDestinoRecepciona,
            COALESCE(EMO.NombreEmpresa,'''') NombreEmpresaOrigen,
            COALESCE(AO.NombreArea,'''') NombreAreaOrigen,
            COALESCE(CO.NombreCargo,'''') NombreCargoOrigen,
            COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(EDO.IdPersonaOrigen),''sinfotoH.jpg'') RutaFotoPersona,
            COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(EDOD.IdPersonaDestino),''sinfotoH.jpg'') RutaFotoPersonaDestino,
            CASE WHEN EDO.IdPersonaOrigen=0 THEN EDO.NombreCompletoOrigen ELSE PO.NombreCompleto END  NombrePersonaOrigen,
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
            COALESCE(EDOD.ObservacionesDestinatario,'''') +'' ''+ CASE WHEN CU.NombreCompletoCourriers IS NULL THEN '''' ELSE '' Courrier: '' END   +''''+ COALESCE(CU.NombreCompletoCourriers,'''') ObservacionesDestinatario,
            Tramite.funMostrarAccionesPorDestino(EDOD.IdExpedienteDocumentoOrigenDestino) Acciones,
            CASE WHEN EDOD.IdCargoDestino IN('+@vCargoJefe+') and EDOD.IdAreaDestino='+CONVERT(Nvarchar,@vIdAreaJefe)+' and EDOD.IdEmpresaDestino='+CONVERT(Nvarchar,@vIdEmpresaJefe)+' THEN 1 ELSE 0 END EsPropio,
            CASE WHEN ED.IdCargoEmisor IN('+@vCargoJefe+') and ED.IdAreaEmisor='+CONVERT(Nvarchar,@vIdAreaJefe)+' and ED.IdEmpresaEmisor='+CONVERT(Nvarchar,@vIdEmpresaJefe)+' THEN 1 ELSE 0 END EsMiDocumento,
            CASE WHEN EDO.IdCargoOrigen IN('+@vCargoJefe+') and EDO.IdAreaOrigen='+CONVERT(Nvarchar,@vIdAreaJefe)+' and EDO.IdEmpresaOrigen='+CONVERT(Nvarchar,@vIdEmpresaJefe)+' THEN 1 ELSE 0 END EsOrigen,
            CTD.Descripcion CatalogoTipoDocumento,
            COALESCE(ED.NumeroDocumento,'''') NumeroDocumento,
            COALESCE(ED.AsuntoDocumento,'''') AsuntoDocumento,
            COALESCE(ED.RutaArchivoDocumento,'''') RutaArchivoDocumento,
            COALESCE(EDOD.FechaArchivado,'''')FechaArchivado,
            EDOD.EsInicial,
			COALESCE(EDO.Descripciondevolucion,'''') DescripcionDevolucion,
			COALESCE(EDOD.MotivoArchivado,'''')MotivoArchivado,
			COALESCE(EE.IdEnvio,0)IdEnvio,
			COALESCE(DM.IdDestino,0)IdDestino
            FROM Tramite.Expediente E
            INNER JOIN Tramite.ExpedienteDocumento ED ON ED.IdExpediente=E.IdExpediente
            INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
            INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen  AND EDO.EstadoAuditoria=1
            INNER JOIN Tramite.Catalogo CTD ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
            INNER JOIN Tramite.Catalogo CSM ON CSM.IdCatalogo=EDOD.IdCatalogoSituacionMovimientoDestino
            INNER JOIN Tramite.Catalogo CTM ON CTM.IdCatalogo=EDOD.IdCatalogoTipoMovimientoDestino
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
			LEFT JOIN Courrier.Envio EE ON EE.IdExpedienteDocumentoOrigenDestino =	EDOD.IdExpedienteDocumentoOrigenDestino AND EE.EstadoAuditoria=1 AND COALESCE(EE.FgEntregado,0)=0
			LEFT JOIN Courrier.Courriers CU ON CU.IdCourriers =EE.IdCourriers
			LEFT JOIN Courrier.Catalogo CSMEE ON CSMEE.IdCatalogo=EE.IdCatalogoSituacionEnvio
			LEFT JOIN Courrier.Destino DM ON DM.PersonaDestino= CASE WHEN CHARINDEX('''',COALESCE(EDOD.DestinatarioDestino,''0''))=0 THEN COALESCE(EDOD.DestinatarioDestino,'''') ELSE  RTRIM(LTRIM(REPLACE( SUBSTRING(COALESCE(EDOD.DestinatarioDestino,''''),1, CHARINDEX('''',COALESCE(EDOD.DestinatarioDestino,''0''))  ),'''',''''))) END AND DM.EstadoAuditoria=1
            WHERE EDOD.EstadoAuditoria=1 AND EDOD.IdCatalogoTipoMovimientoDestino=72 AND E.IdExpediente='+CONVERT(NVARCHAR,@pIdExpediente) +' AND EDO.IdAreaOrigenEnvia='+CONVERT(VARCHAR,@pIdArea)
        +@Filtros
        +@Orden
        +@Offset
        +@Fetch
        EXECUTE sp_executesql @Consulta
        select @pTotalRegistros

END TRY
BEGIN CATCH
    DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX) ,@ERROR_MESSAGE VARCHAR(MAX)
    SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarDocumentoPendienteCourrierJefatura',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
    EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
END CATCH
