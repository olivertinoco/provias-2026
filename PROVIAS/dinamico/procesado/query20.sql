-- original
CREATE PROCEDURE Tramite.paListarDetalleBusquedaExpedienteGeneral
    @pIdExpediente int,
    @pIdArea int,
    @pIdUsuarioAuditoria int,
    @pCampoOrdenado varchar(50),
    @pTipoOrdenacion varchar(4),
    @pNumeroPagina INT,
    @pDimensionPagina  INT,
    @pBusquedaGeneral varchar(100),
    @pCorrelativoVinculado int
AS
BEGIN
BEGIN TRY
SET TRAN ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON
SET LANGUAGE SPANISH

    DECLARE @Consulta Nvarchar(max)=''
    DECLARE @ConsultaTotal Nvarchar(max)=''
    DECLARE @Filtros varchar(max)=''
    DECLARE @Offset NVARCHAR(MAX)='';
    DECLARE @Fetch NVARCHAR(MAX)='';
    DECLARE @Orden NVARCHAR(MAX)='';
    DECLARE @Parametros NVARCHAR(MAX)='';
    DECLARE @pTotalRegistros  INT;
	DECLARE @vCondicionVinculado nVARCHAR(200)=''
	DECLARE @vSiPariticipo int=0

	DECLARE @vIdPersonaActual int=0,@vIdCargoJefeEsMio int,@vIdAreaJefeEsMio int,@vIdEmpresaJefeEsMio int
	SELECT @vIdPersonaActual=IdPersona from Seguridad.Usuario where IdUsuario=@pIdUsuarioAuditoria AND EstadoAuditoria=1 AND Bloqueado=0

	DECLARE @vIdTipoFormulario INT=0
	SELECT @vIdTipoFormulario=COUNT(IdTipoFormulario)
	FROM Tramite.PermisoVisualizacionDocumentos
	WHERE EstadoAuditoria=1 and IdPersona=@vIdPersonaActual AND IdTipoFormulario=3 and
	convert(date, GETDATE() )between convert(date,FechaInicioPersmiso) and convert(date,FechaFinPersmiso)

	IF @vIdTipoFormulario>0
	BEGIN
		SET @vSiPariticipo=1
	END
	ELSE
		BEGIN
		    IF(SELECT COUNT(*) FROM RecursoHumano.visPersonaJefe WHERE IdPersona = @vIdPersonaActual AND IdArea=@pIdArea)>0
    		BEGIN
          		SELECT @vIdCargoJefeEsMio=IdCargo, @vIdAreaJefeEsMio=IdArea,@vIdEmpresaJefeEsMio=IdEmpresa
          		FROM RecursoHumano.visPersonaJefe where IdArea=@pIdArea AND IdPersona = @vIdPersonaActual

           	    SET @vSiPariticipo=(select COUNT(ED.IdPersonaEmisor)
          		FROM Tramite.ExpedienteDocumento ED
          		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO
          		ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
          		INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD
          		ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen  AND EDO.EstadoAuditoria=1
          		WHERE ED.IdExpediente=@pIdExpediente
          		AND((EDOD.IdCargoDestino = @vIdCargoJefeEsMio and EDOD.IdAreaDestino=@vIdAreaJefeEsMio)
          		OR (EDO.IdCargoOrigen=@vIdCargoJefeEsMio or EDO.IdAreaOrigen=@vIdAreaJefeEsMio)))

      		END ELSE BEGIN
     			SET @vSiPariticipo=(select COUNT(ED.IdPersonaEmisor)
     			FROM Tramite.ExpedienteDocumento ED
     			INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO
     			ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
     			INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD
     			ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen  AND EDO.EstadoAuditoria=1
     			WHERE ED.IdExpediente=@pIdExpediente
     			AND (EDOD.IdPersonaDestino = @vIdPersonaActual OR EDO.IdPersonaOrigen=@vIdPersonaActual))
            END
	END
    IF @pCorrelativoVinculado>=0
	BEGIN
		SET @vCondicionVinculado=' AND ED.CorrelativoVinculado ='+CONVERT(Nvarchar,@pCorrelativoVinculado)
	END
    SET @Orden=' ORDER BY CONVERT(DATETIME,EDO.FechaOrigen+'' ''+EDO.HoraOrigen)  DESC '
    SET @Offset= ' OFFSET ' +CONVERT(VARCHAR(10),(@pNumeroPagina-1)*@pDimensionPagina) + ' ROWS '
    SET @Fetch= ' FETCH NEXT '+CONVERT(VARCHAR(10),@pDimensionPagina) +' ROWS ONLY '

    IF COALESCE(@pBusquedaGeneral,'')<>'' SET @Filtros =' AND (CSM.Descripcion LIKE ''%'+@pBusquedaGeneral +'%'')'
    SET @ConsultaTotal = N'
    SELECT @vpTotalRegistros = count(*)
    FROM Tramite.Expediente E
    INNER JOIN Tramite.ExpedienteDocumento ED
    ON ED.IdExpediente=E.IdExpediente
    INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO
    ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
    INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD
    ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen  AND EDO.EstadoAuditoria=1
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
	LEFT JOIN Courrier.Envio EE ON EE.IdExpedienteDocumentoOrigenDestino =	EDOD.IdExpedienteDocumentoOrigenDestino AND EE.EstadoAuditoria=1 AND FgEntregado=0
    WHERE EDOD.EstadoAuditoria=1 AND E.IdExpediente='
    +CONVERT(VARCHAR,@pIdExpediente)
    +@Filtros
	+@vCondicionVinculado
    SET @Parametros = N'@vpTotalRegistros int OUTPUT';
    EXECUTE sp_executesql @ConsultaTotal,@Parametros, @vpTotalRegistros = @pTotalRegistros OUTPUT

    SET @Consulta= N'
    SELECT case when ED.FgEnEsperaFirmaDigital=1 and Ver.doc=0 then 0 else '+
	CONVERT(VARCHAR,@vSiPariticipo) + N' end SiPariticipo,
    EDO.EsVinculado,E.ExpedienteAnulado,E.IdExpediente,ED.IdExpedienteDocumento,EDOD.IdExpedienteDocumentoOrigenDestino,
    EDOD.IdExpedienteDocumentoOrigen,EDOD.IdCatalogoSituacionMovimientoDestino,CSM.Descripcion CatalogoSituacionMovimientoDestino,
    EDOD.IdCatalogoTipoMovimientoDestino,CTM.Descripcion CatalogoTipoMovimientoDestino,
    COALESCE(EDO.IdCatalogoTipodevolucion,0) IdCatalogoTipoDevolucion,
    EDOD.NumeroDiasAtencionSolicitado,COALESCE(EDOD.FechaDestinoRecepciona,'''')FechaDestinoRecepciona,
    COALESCE(EDOD.HoraDestinoRecepciona,'''')HoraDestinoRecepciona,
    COALESCE(EMO.NombreEmpresa,'''') NombreEmpresaOrigen,
    COALESCE(AO.NombreArea,'''') NombreAreaOrigen,
    COALESCE(CO.NombreCargo,'''') NombreCargoOrigen,
    COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(EDO.IdPersonaOrigen),''sinfotoH.jpg'') RutaFotoPersona,
    COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(EDOD.IdPersonaDestino),''sinfotoH.jpg'') RutaFotoPersonaDestino,
    CASE WHEN EDO.IdPersonaOrigen=0 THEN EDO.NombreCompletoOrigen ELSE PO.NombreCompleto END  NombrePersonaOrigen,
    COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(EDOD.IdPersonaDestino),''sinfotoH.jpg'') RutaFotoPersonaDestino,
    EDOD.NumeroDiasAtencionAceptado,EDOD.Original,EDOD.Copia,EDOD.FechaDestino,EDOD.HoraDestino,
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
    ED.IdExpedienteDocumento,CTD.Descripcion CatalogoTipoDocumento,
    COALESCE(ED.NumeroDocumento,'''') NumeroDocumento,
    COALESCE(ED.AsuntoDocumento,'''') AsuntoDocumento,
    COALESCE(ED.RutaArchivoDocumento,'''') RutaArchivoDocumento,
    COALESCE(EDOD.FechaArchivado,'''')+'' ''+ COALESCE(EDOD.MotivoArchivado,'''')FechaArchivado,
    COALESCE(EDO.Descripciondevolucion,'''') DescripcionDevolucion,
    Tramite.funEsExtornable(EDOD.IdExpedienteDocumentoOrigen,EDOD.IdExpedienteDocumentoOrigenDestino) EsExtornable,
    EDOD.EsInicial,COALESCE(EDO.Descripciondevolucion,'''') DescripcionDevolucion,
    COALESCE(EDOD.MotivoArchivado,'''')MotivoArchivado,
    COALESCE(EE.FechaEntregaDocumento,'''')FechaEntregaDocumento,
    COALESCE(EE.HoraEntregaDocumento,'''')HoraEntregaDocumento,
    COALESCE(EE.RutaArchivoCargo,'''')RutaArchivoCargo,
    ED.CorrelativoVinculado,CTD.Descripcion CatalogoTipoDocumento,CTD.IdCatalogo IdCatalogoTipoDocumento,
    ED.FgEsObligatorioFirmaDigital,ED.FgEnEsperaFirmaDigital,ED.FlagParaDespacho,COALESCE(ED.IdExpedienteVirtual,0) IdExpedienteVirtual
    FROM Tramite.Expediente E
    INNER JOIN Tramite.ExpedienteDocumento ED
    ON ED.IdExpediente=E.IdExpediente
    INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO
    ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
    INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD
    ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen  AND EDO.EstadoAuditoria=1
    INNER JOIN Tramite.Catalogo CTD ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
    INNER JOIN Tramite.Catalogo CSM ON CSM.IdCatalogo=EDOD.IdCatalogoSituacionMovimientoDestino
    INNER JOIN Tramite.Catalogo CTM ON CTM.IdCatalogo=EDOD.IdCatalogoTipoMovimientoDestino
    outer apply(
    		select isnull(max(1),0) doc
    		from Tramite.ExpedienteDocumentoFirmante EDF
    		where EDF.IdExpedienteDocumento=ED.IdExpedienteDocumento and EDF.IdPersona= ' +
    		convert(varchar,@vIdPersonaActual) + ' and EDF.EstadoAuditoria=1
    ) Ver
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
    LEFT JOIN Courrier.Envio EE ON EE.IdExpedienteDocumentoOrigenDestino =	EDOD.IdExpedienteDocumentoOrigenDestino AND EE.EstadoAuditoria=
1 AND FgEntregado=0
    WHERE EDOD.EstadoAuditoria=1 AND E.IdExpediente='
    + CONVERT(VARCHAR,@pIdExpediente)
    +@Filtros
	+@vCondicionVinculado
    +@Orden
    +@Offset
    +@Fetch

    EXECUTE sp_executesql @Consulta
    select @pTotalRegistros

END TRY
BEGIN CATCH
    DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX) ,@ERROR_MESSAGE VARCHAR(MAX)
    SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE(),
    @ERROR_PROCEDURE='Tramite.paListarDetalleBusquedaExpedienteGeneral',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
    EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
END CATCH
END
