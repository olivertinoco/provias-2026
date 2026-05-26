ALTER PROCEDURE Tramite.paListarDocumentoPendienteJefatura_arq
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
SET TRAN ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON
SET LANGUAGE SPANISH

    DECLARE @vSql nvarchar(max), @vIdPeriodo varchar(4) = convert(varchar, @pIdPeriodo)
    DECLARE @vIdPersonaActual int=0,@vIdCargoJefeEsMio int,@vIdAreaJefeEsMio int,@vIdEmpresaJefeEsMio int,@vIdPersonaJefe int=0
    SELECT @vIdCargoJefeEsMio=IdCargo, @vIdAreaJefeEsMio=IdArea,@vIdEmpresaJefeEsMio=IdEmpresa,@vIdPersonaJefe=IdPersona
    FROM RecursoHumano.visPersonaJefe where IdArea=@pIdArea
    SELECT @vIdPersonaActual=IdPersona from Seguridad.Usuario where IdUsuario=@pIdUsuarioAuditoria AND EstadoAuditoria=1 AND Bloqueado=0
    DECLARE @vSiPariticipo int=0

    IF @pIdUsuarioAuditoria IN(
    select IdUsuario from Tramite.PermisoVisualizacionDocumentos
    where IdTipoFormulario=1 and EstadoAuditoria=1
    and convert(date, GETDATE() )between convert(date,FechaInicioPersmiso) and convert(date,FechaFinPersmiso)) BEGIN
    	SET @vSiPariticipo=1
    END ELSE BEGIN
        select @vSql = N'
    	SET @vSiPariticipo=(select COUNT(ED.IdPersonaEmisor)
    	FROM Tramite.ExpedienteDocumento_Historico_' + @vIdPeriodo + N' ED
    	INNER JOIN Tramite.ExpedienteDocumentoOrigen_Historico_' + @vIdPeriodo + N' EDO
        ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
    	INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino_Historico_' + @vIdPeriodo + N' EDOD
        ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen  AND EDO.EstadoAuditoria=1
    	WHERE ED.IdExpediente=@pIdExpediente AND((EDOD.IdAreaDestino=@vIdAreaJefeEsMio) OR (EDO.IdAreaOrigen=@vIdAreaJefeEsMio)))'
        exec sp_executesql @vSql,
            N'@pIdExpediente int, @vIdAreaJefeEsMio int, @vSiPariticipo int output',
            @pIdExpediente = @pIdExpediente,
            @vIdAreaJefeEsMio = @vIdAreaJefeEsMio,
            @vSiPariticipo = @vSiPariticipo output
    END
    DECLARE @vIdCargoJefe int=0
    DECLARE @vIdAreaJefe int=0
    DECLARE @vIdEmpresaJefe int=0
    SELECT @vIdCargoJefe=IdCargo, @vIdAreaJefe=IdArea,@vIdEmpresaJefe=IdEmpresa FROM RecursoHumano.visPersonaJefe where IdArea=@pIdArea

    select @vSql = null
    IF @pVerSoloMio=1
    BEGIN
        select @vSql = N'
    	SELECT Seguridad.funObtenerUsuario(edo.IdUsuarioCreacionAuditoria)Logueo,
    		Tramite.funPaseTieneAdjunto(EDO.IdExpedienteDocumentoOrigen) PaseTieneAdjunto,
    		Tramite.funDocumentoTieneAdjunto(ED.IdExpedienteDocumento) DocumentoTieneAdjunto,
    		CONCAT(SD.AbreviaturaSerieDocumentalExpediente +RIGHT(''000000''+CONVERT(VARCHAR,E.NumeroExpediente),6), ''-'', E.IdPeriodo,CASE WHEN COALESCE(ED.CorrelativoVinculado,0)=0 THEN '''' ELSE '' V-''+CONVERT(VARCHAR,ED.CorrelativoVinculado) END) NombreExpediente,
    		case when ED.FgEnEsperaFirmaDigital=1 and Ver.doc=0 then 0 else @vSiPariticipo end SiPariticipo,
    		ED.CorrelativoVinculado, EDO.EsVinculado,E.ExpedienteAnulado,E.IdExpediente,ED.IdExpedienteDocumento,EDOD.IdExpedienteDocumentoOrigenDestino,
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
            CASE WHEN CTEO.IdCatalogo=9 THEN ''(LOCADOR)'' ELSE COALESCE(CO.NombreCargo,'''') END NombreCargoOrigen,
            COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(EDO.IdPersonaOrigen),''sinfotoH.jpg'') RutaFotoPersona,
            COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(EDOD.IdPersonaDestino),''sinfotoH.jpg'') RutaFotoPersonaDestino,
            CASE WHEN EDO.IdPersonaOrigen=0 THEN EDO.NombreCompletoOrigen ELSE CASE WHEN CTM.IdCatalogo=71 THEN EDO.NombreCompletoOrigen  ELSE PO.NombreCompleto END END  NombrePersonaOrigen,
            COALESCE(EDOD.NumeroDiasAtencionAceptado,0)NumeroDiasAtencionAceptado,
            EDOD.Original,EDOD.Copia,EDOD.FechaDestino,EDOD.HoraDestino,EDO.FechaOrigen,EDO.HoraOrigen,
            COALESCE(EDOD.FechaDestinoEnvia,'''') FechaDestinoEnvia,
            COALESCE(EDOD.HoraDestinoEnvia,'''') HoraDestinoEnvia,
            COALESCE(EMD.NombreEmpresa,COALESCE(EDOD.DestinatarioDestino,'''')) NombreEmpresaDestino,
            COALESCE(AD.NombreArea,'''') NombreAreaDestino,
    		CASE WHEN CTED.IdCatalogo=9 THEN ''(LOCADOR)'' ELSE COALESCE(CD.NombreCargo,'''') END NombreCargoDestino,
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
            CASE WHEN EDOD.IdCargoDestino IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)) and EDOD.IdAreaDestino=@vIdAreaJefe and EDOD.IdEmpresaDestino=@vIdEmpresaJefe THEN 1 ELSE 0 END EsPropio,
            CASE WHEN ED.IdCargoEmisor IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)) and ED.IdAreaEmisor=@vIdAreaJefe and ED.IdEmpresaEmisor=@vIdEmpresaJefe THEN 1 ELSE 0 END EsMiDocumento,
            CASE WHEN EDO.IdCargoOrigen IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)) and EDO.IdAreaOrigen=@vIdAreaJefe and EDO.IdEmpresaOrigen=@vIdEmpresaJefe THEN 1 ELSE 0 END EsOrigen,
            CTD.Descripcion CatalogoTipoDocumento,CTD.IdCatalogo IdCatalogoTipoDocumento,
            CASE WHEN E.IdCatalogoTipoTramite IN (211,477,478,129,391) THEN 211 ELSE E.IdCatalogoTipoTramite  END IdCatalogoTipoTramite,
    		CASE WHEN ED.Correlativo=0 THEN  CONCAT( CTD.Descripcion,'' '', COALESCE(ED.NumeroDocumento,'''')) ELSE COALESCE(ED.NumeroDocumento,'''') END  NumeroDocumento,
            COALESCE(ED.AsuntoDocumento,'''') AsuntoDocumento,
            COALESCE(ED.RutaArchivoDocumento,'''') RutaArchivoDocumento,
    		isnull(FORMAT(ED.FechaCreacionAuditoria, ''dd/MM/yyyy HH:mm''),'''') FechaCreacionAuditoria,
            COALESCE(EDOD.FechaArchivado,'''')FechaArchivado,
            Tramite.funEsExtornable(EDOD.IdExpedienteDocumentoOrigen,EDOD.IdExpedienteDocumentoOrigenDestino) EsExtornable,EDOD.EsInicial,
    		COALESCE(EDO.Descripciondevolucion,'''') DescripcionDevolucion,
    		COALESCE(EDOD.MotivoArchivado,'''')MotivoArchivado,
    		COALESCE(EE.FechaEntregaDocumento,'''')FechaEntregaDocumento,
    		COALESCE(EE.HoraEntregaDocumento,'''')HoraEntregaDocumento,
    		COALESCE(EE.RutaArchivoCargo,'''')RutaArchivoCargo,
    		ED.FgEsObligatorioFirmaDigital,
    		ED.FgEnEsperaFirmaDigital,
    		ED.FlagParaDespacho,
    		CASE WHEN YEAR(DATEADD(MONTH,-1,ED.FechaCreacionAuditoria))=YEAR(GETDATE()) THEN '''' ELSE CONVERT(VARCHAR, YEAR(DATEADD(MONTH,-1,ED.FechaCreacionAuditoria))) END PeriodoCreadoDocumento
            FROM Tramite.Expediente_Historico_' + @vIdPeriodo + N' E
            INNER JOIN Tramite.ExpedienteDocumento_Historico_' + @vIdPeriodo + N' ED
            ON ED.IdExpediente=E.IdExpediente
            INNER JOIN Tramite.ExpedienteDocumentoOrigen_Historico_' + @vIdPeriodo + N' EDO
            ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1 AND E.EstadoAuditoria=1
            INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino_Historico_' + @vIdPeriodo + N' EDOD
            ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen  AND EDO.EstadoAuditoria=1  AND EDOD.EstadoAuditoria=1
            INNER JOIN Tramite.Catalogo CTD ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
            INNER JOIN Tramite.Catalogo CSM ON CSM.IdCatalogo=EDOD.IdCatalogoSituacionMovimientoDestino
            INNER JOIN Tramite.Catalogo CTM ON CTM.IdCatalogo=EDOD.IdCatalogoTipoMovimientoDestino
    		INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
    		outer apply(
    			select isnull(max(1),0) doc
    			from Tramite.ExpedienteDocumentoFirmante EDF
    			where EDF.IdExpedienteDocumento=ED.IdExpedienteDocumento and EDF.IdPersona=@vIdPersonaJefe and EDF.EstadoAuditoria=1
    		) Ver
            LEFT JOIN General.Empresa EMO ON EMO.IdEmpresa=EDO.IdEmpresaOrigen
            LEFT JOIN General.Area AO ON AO.IdArea= EDO.IdAreaOrigen
            LEFT JOIN General.Cargo CO ON CO.IdCargo=EDO.IdCargoOrigen
            LEFT JOIN General.Empresa EMD ON EMD.IdEmpresa=EDOD.IdEmpresaDestino
            LEFT JOIN General.Area AD ON AD.IdArea= EDOD.IdAreaDestino
            LEFT JOIN General.Cargo CD ON CD.IdCargo=EDOD.IdCargoDestino
    		LEFT JOIN RecursoHumano.Empleado EMPD ON EMPD.IdPersona=EDOD.IdPersonaDestino AND EMPD.EstadoAuditoria=1
    		LEFT JOIN General.Persona PD ON PD.IdPersona=EMPD.IdPersona AND PD.EstadoAuditoria=1
    		LEFT JOIN RecursoHumano.Catalogo CTED ON CTED.IdCatalogo=EMPD.IdCatalogoTipoEmpleado
    		LEFT JOIN RecursoHumano.Empleado EMPO ON EMPO.IdPersona=EDO.IdPersonaOrigen AND EMPO.EstadoAuditoria=1
    		LEFT JOIN General.Persona PO ON PO.IdPersona=EMPO.IdPersona AND PO.EstadoAuditoria=1
    		LEFT JOIN RecursoHumano.Catalogo CTEO ON CTEO.IdCatalogo=EMPO.IdCatalogoTipoEmpleado
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
            WHERE E.IdExpediente=@pIdExpediente
    		AND EDOD.IdCargoDestino IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34))
    		AND EDOD.IdAreaDestino=@vIdAreaJefe
    		AND EDOD.IdEmpresaDestino= @vIdEmpresaJefe
    		AND ED.CorrelativoVinculado= CASE WHEN @pCorrelativoVinculado>0 THEN @pCorrelativoVinculado ELSE ED.CorrelativoVinculado END
    		ORDER BY CONVERT(DATETIME,edo.FechaOrigen +'' '' + edo.HoraOrigen) DESC, EDOD.IdExpedienteDocumentoOrigenDestino DESC
    		OFFSET (@pNumeroPagina-1)*@pDimensionPagina ROWS
    		FETCH NEXT @pDimensionPagina ROWS ONLY'

            exec sp_executesql @vSql,
                N'@pIdExpediente int, @vIdEmpresaJefe int, @vIdAreaJefe int, @vIdPersonaJefe int, @pCorrelativoVinculado int, @vSiPariticipo int, @pNumeroPagina int, @pDimensionPagina int',
                @pIdExpediente = @pIdExpediente,
                @vIdEmpresaJefe = @vIdEmpresaJefe,
                @vIdAreaJefe = @vIdAreaJefe,
                @vIdPersonaJefe = @vIdPersonaJefe,
                @pCorrelativoVinculado = @pCorrelativoVinculado,
                @vSiPariticipo = @vSiPariticipo,
                @pNumeroPagina = @pNumeroPagina,
                @pDimensionPagina = @pDimensionPagina

            select @vSql = null
            select @vSql = N'
    		SELECT COUNT(*)
    		FROM Tramite.Expediente_Historico_' + @vIdPeriodo + N' E
            INNER JOIN Tramite.ExpedienteDocumento_Historico_' + @vIdPeriodo + N' ED
            ON ED.IdExpediente=E.IdExpediente
            INNER JOIN Tramite.ExpedienteDocumentoOrigen_Historico_' + @vIdPeriodo + N' EDO
            ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1 AND E.EstadoAuditoria=1
            INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino_Historico_' + @vIdPeriodo + N' EDOD
            ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
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
    		WHERE E.IdExpediente=@pIdExpediente
    		AND EDOD.IdCargoDestino IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34))
    		AND EDOD.IdAreaDestino=@vIdAreaJefe
    		AND EDOD.IdEmpresaDestino= @vIdEmpresaJefe
    		AND ED.CorrelativoVinculado= CASE WHEN @pCorrelativoVinculado>0 THEN @pCorrelativoVinculado ELSE ED.CorrelativoVinculado END'

            exec sp_executesql @vSql,
                N'@pIdExpediente int, @vIdEmpresaJefe int, @vIdAreaJefe int, @pCorrelativoVinculado int',
                @pIdExpediente = @pIdExpediente,
                @vIdEmpresaJefe = @vIdEmpresaJefe,
                @vIdAreaJefe = @vIdAreaJefe,
                @pCorrelativoVinculado = @pCorrelativoVinculado

    END ELSE BEGIN
        select @vSql = N'
  		select Seguridad.funObtenerUsuario(edo.IdUsuarioCreacionAuditoria)Logueo,
  		Tramite.funPaseTieneAdjunto(EDO.IdExpedienteDocumentoOrigen) PaseTieneAdjunto,
  		Tramite.funDocumentoTieneAdjunto(ED.IdExpedienteDocumento) DocumentoTieneAdjunto,
  		CONCAT(SD.AbreviaturaSerieDocumentalExpediente +RIGHT(''000000''+CONVERT(VARCHAR,E.NumeroExpediente),6), ''-'', E.IdPeriodo,CASE WHEN COALESCE(ED.CorrelativoVinculado,0)=0 THEN '''' ELSE '' V-''+CONVERT(VARCHAR,ED.CorrelativoVinculado) END) NombreExpediente,
  		case when ED.FgEnEsperaFirmaDigital=1 and Ver.doc=0 then 0 else @vSiPariticipo end SiPariticipo,
  		ED.CorrelativoVinculado, EDO.EsVinculado,E.ExpedienteAnulado,E.IdExpediente,ED.IdExpedienteDocumento,EDOD.IdExpedienteDocumentoOrigenDestino,
        EDOD.IdExpedienteDocumentoOrigen,
  		CASE WHEN EE.IdEnvio IS NULL THEN EDOD.IdCatalogoSituacionMovimientoDestino
  		ELSE CASE WHEN EE.IdCatalogoSituacionEnvio = 14 THEN EDOD.IdCatalogoSituacionMovimientoDestino ELSE EE.IdCatalogoSituacionEnvio END
  		END IdCatalogoSituacionMovimientoDestino,
  		CASE WHEN EE.IdEnvio IS NULL THEN CSM.Descripcion ELSE
  		CASE WHEN EE.IdCatalogoSituacionEnvio = 14 THEN CSM.Descripcion ELSE CSMEE.Descripcion END END CatalogoSituacionMovimientoDestino,
        EDOD.IdCatalogoTipoMovimientoDestino,CTM.Descripcion CatalogoTipoMovimientoDestino,
        COALESCE(EDO.IdCatalogoTipodevolucion,0) IdCatalogoTipoDevolucion,
        EDOD.NumeroDiasAtencionSolicitado,
        COALESCE(EDOD.FechaDestinoRecepciona,'''')FechaDestinoRecepciona,
        COALESCE(EDOD.HoraDestinoRecepciona,'''')HoraDestinoRecepciona,
        COALESCE(EMO.NombreEmpresa,'''') NombreEmpresaOrigen,
        COALESCE(AO.NombreArea,'''') NombreAreaOrigen,
        CASE WHEN CTEO.IdCatalogo=9 THEN ''(LOCADOR)'' ELSE COALESCE(CO.NombreCargo,'''') END NombreCargoOrigen,
        COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(EDO.IdPersonaOrigen),''sinfotoH.jpg'') RutaFotoPersona,
        COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(EDOD.IdPersonaDestino),''sinfotoH.jpg'') RutaFotoPersonaDestino,
        coalesce(CASE WHEN EDO.IdPersonaOrigen=0 THEN EDO.NombreCompletoOrigen ELSE CASE WHEN CTM.IdCatalogo=71 THEN EDO.NombreCompletoOrigen  ELSE PO.NombreCompleto END END ,'''') NombrePersonaOrigen,
        COALESCE(EDOD.NumeroDiasAtencionAceptado,0)NumeroDiasAtencionAceptado,
        EDOD.Original,EDOD.Copia,EDOD.FechaDestino,EDOD.HoraDestino,EDO.FechaOrigen,EDO.HoraOrigen,
        COALESCE(EDOD.FechaDestinoEnvia,'''') FechaDestinoEnvia,
        COALESCE(EDOD.HoraDestinoEnvia,'''') HoraDestinoEnvia,
        COALESCE(EMD.NombreEmpresa,COALESCE(EDOD.DestinatarioDestino,'''')) NombreEmpresaDestino,
        COALESCE(AD.NombreArea,'''') NombreAreaDestino,
  		CASE WHEN CTED.IdCatalogo=9 THEN ''(LOCADOR)'' ELSE COALESCE(CD.NombreCargo,'''') END NombreCargoDestino,
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
        CASE WHEN EDOD.IdCargoDestino IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)) and EDOD.IdAreaDestino=@vIdAreaJefe and EDOD.IdEmpresaDestino=@vIdEmpresaJefe THEN 1 ELSE 0 END EsPropio,
        CASE WHEN ED.IdCargoEmisor IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)) and ED.IdAreaEmisor=@vIdAreaJefe and ED.IdEmpresaEmisor=@vIdEmpresaJefe THEN 1 ELSE 0 END EsMiDocumento,
        CASE WHEN EDO.IdCargoOrigen IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)) and EDO.IdAreaOrigen=@vIdAreaJefe and EDO.IdEmpresaOrigen=@vIdEmpresaJefe THEN 1 ELSE 0 END EsOrigen,
        CTD.Descripcion CatalogoTipoDocumento,CTD.IdCatalogo IdCatalogoTipoDocumento,
        CASE WHEN E.IdCatalogoTipoTramite IN (211,477,478,129,391) THEN 211 ELSE E.IdCatalogoTipoTramite  END IdCatalogoTipoTramite,
  		CASE WHEN ED.Correlativo=0 THEN  CONCAT( CTD.Descripcion,'' '', COALESCE(ED.NumeroDocumento,'''')) ELSE COALESCE(ED.NumeroDocumento,'''') END  NumeroDocumento,
        COALESCE(ED.AsuntoDocumento,'''') AsuntoDocumento,
        COALESCE(ED.RutaArchivoDocumento,'''') RutaArchivoDocumento,
  		isnull(FORMAT(ED.FechaCreacionAuditoria, ''dd/MM/yyyy HH:mm''),'''') FechaCreacionAuditoria,
        COALESCE(EDOD.FechaArchivado,'''')FechaArchivado,
        Tramite.funEsExtornable(EDOD.IdExpedienteDocumentoOrigen,EDOD.IdExpedienteDocumentoOrigenDestino) EsExtornable,
        EDOD.EsInicial,COALESCE(EDO.Descripciondevolucion,'''') DescripcionDevolucion,
  		COALESCE(EDOD.MotivoArchivado,'''')MotivoArchivado,
  		COALESCE(EE.FechaEntregaDocumento,'''')FechaEntregaDocumento,
  		COALESCE(EE.HoraEntregaDocumento,'''')HoraEntregaDocumento,
  		COALESCE(EE.RutaArchivoCargo,'''')RutaArchivoCargo,
  		ED.FgEsObligatorioFirmaDigital,ED.FgEnEsperaFirmaDigital,ED.FlagParaDespacho,
  		COALESCE(CASE WHEN YEAR(DATEADD(MONTH,-1,EE.FechaCreacionAuditoria))=YEAR(GETDATE()) THEN '''' ELSE CONVERT(VARCHAR, YEAR(DATEADD(MONTH,-1,EE.FechaCreacionAuditoria))) END,'''') PeriodoCreadoDocumento
        FROM Tramite.Expediente_Historico_' + @vIdPeriodo + N' E
        INNER JOIN Tramite.ExpedienteDocumento_Historico_' + @vIdPeriodo + N' ED
        ON ED.IdExpediente=E.IdExpediente
        INNER JOIN Tramite.ExpedienteDocumentoOrigen_Historico_' + @vIdPeriodo + N' EDO
        ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1 AND E.EstadoAuditoria=1
        INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino_Historico_' + @vIdPeriodo + N' EDOD
        ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen  AND EDO.EstadoAuditoria=1  AND EDOD.EstadoAuditoria=1
        INNER JOIN Tramite.Catalogo CTD ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
        INNER JOIN Tramite.Catalogo CSM ON CSM.IdCatalogo=EDOD.IdCatalogoSituacionMovimientoDestino
        INNER JOIN Tramite.Catalogo CTM ON CTM.IdCatalogo=EDOD.IdCatalogoTipoMovimientoDestino
  		INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
  		outer apply(
 			select isnull(max(1),0) doc
 			from Tramite.ExpedienteDocumentoFirmante EDF
 			where EDF.IdExpedienteDocumento=ED.IdExpedienteDocumento and EDF.IdPersona=@vIdPersonaJefe and EDF.EstadoAuditoria=1
  		) Ver
        LEFT JOIN General.Empresa EMO ON EMO.IdEmpresa=EDO.IdEmpresaOrigen
        LEFT JOIN General.Area AO ON AO.IdArea= EDO.IdAreaOrigen
        LEFT JOIN General.Cargo CO ON CO.IdCargo=EDO.IdCargoOrigen
        LEFT JOIN General.Empresa EMD ON EMD.IdEmpresa=EDOD.IdEmpresaDestino
        LEFT JOIN General.Area AD ON AD.IdArea= EDOD.IdAreaDestino
        LEFT JOIN General.Cargo CD ON CD.IdCargo=EDOD.IdCargoDestino
  		LEFT JOIN RecursoHumano.Empleado EMPD ON EMPD.IdPersona=EDOD.IdPersonaDestino AND EMPD.EstadoAuditoria=1
  		LEFT JOIN General.Persona PD ON PD.IdPersona=EMPD.IdPersona AND PD.EstadoAuditoria=1
  		LEFT JOIN RecursoHumano.Catalogo CTED ON CTED.IdCatalogo=EMPD.IdCatalogoTipoEmpleado
  		LEFT JOIN RecursoHumano.Empleado EMPO ON EMPO.IdPersona=EDO.IdPersonaOrigen AND EMPO.EstadoAuditoria=1
  		LEFT JOIN General.Persona PO ON PO.IdPersona=EMPO.IdPersona AND PO.EstadoAuditoria=1
  		LEFT JOIN RecursoHumano.Catalogo CTEO ON CTEO.IdCatalogo=EMPO.IdCatalogoTipoEmpleado
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
        WHERE E.IdExpediente=@pIdExpediente AND ED.CorrelativoVinculado= CASE WHEN @pCorrelativoVinculado>0 THEN @pCorrelativoVinculado ELSE ED.CorrelativoVinculado END
  		ORDER BY CONVERT(DATETIME,edo.FechaOrigen +'' '' + edo.HoraOrigen) DESC, EDOD.IdExpedienteDocumentoOrigenDestino DESC
  		OFFSET (@pNumeroPagina-1)*@pDimensionPagina ROWS
  		FETCH NEXT @pDimensionPagina ROWS ONLY'

        exec sp_executesql @vSql,
            N'@pIdExpediente int, @vIdEmpresaJefe int, @vIdAreaJefe int, @vIdPersonaJefe int, @pCorrelativoVinculado int, @vSiPariticipo int, @pNumeroPagina int, @pDimensionPagina int',
            @pIdExpediente = @pIdExpediente,
            @vIdEmpresaJefe = @vIdEmpresaJefe,
            @vIdAreaJefe = @vIdAreaJefe,
            @vIdPersonaJefe = @vIdPersonaJefe,
            @pCorrelativoVinculado = @pCorrelativoVinculado,
            @vSiPariticipo = @vSiPariticipo,
            @pNumeroPagina = @pNumeroPagina,
            @pDimensionPagina = @pDimensionPagina

        select @vSql = null
        select @vSql = N'
  		SELECT COUNT(*) FROM Tramite.Expediente_Historico_' + @vIdPeriodo + N' E
        INNER JOIN Tramite.ExpedienteDocumento_Historico_' + @vIdPeriodo + N' ED
        ON ED.IdExpediente=E.IdExpediente
        INNER JOIN Tramite.ExpedienteDocumentoOrigen_Historico_' + @vIdPeriodo + N' EDO
        ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1 AND E.EstadoAuditoria=1
        INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino_Historico_' + @vIdPeriodo + N' EDOD
        ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen  AND EDO.EstadoAuditoria=1  AND EDOD.EstadoAuditoria=1
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
        WHERE E.IdExpediente=@pIdExpediente AND ED.CorrelativoVinculado= CASE WHEN @pCorrelativoVinculado>0 THEN @pCorrelativoVinculado ELSE ED.CorrelativoVinculado END'

        exec sp_executesql @vSql,
            N'@pIdExpediente int, @pCorrelativoVinculado int',
            @pIdExpediente = @pIdExpediente,
            @pCorrelativoVinculado = @pCorrelativoVinculado
    END

END TRY
BEGIN CATCH
    DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX) ,@ERROR_MESSAGE VARCHAR(MAX)
    SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE(),
    @ERROR_PROCEDURE='Tramite.paListarDocumentoPendienteJefatura_arq',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
    EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
END CATCH
END
GO


-- exec Tramite.paListarDocumentoPendienteJefatura_arq
-- @pIdExpediente= 506372,
-- @pIdArea=30,
-- @pIdUsuarioAuditoria=53721,
-- @pCampoOrdenado=NULL,
-- @pTipoOrdenacion=NULL,
-- @pNumeroPagina=1,
-- @pDimensionPagina=10,
-- @pBusquedaGeneral=NULL,
-- @pVerSoloMio=0,
-- @pCorrelativoVinculado=-1,
-- @pIdPeriodo = 2025
