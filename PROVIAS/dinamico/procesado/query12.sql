ALTER PROCEDURE Tramite.paListarDetalleBusquedaExpedienteGeneralPorAnno_arq
    @pIdExpediente int,
    @pIdArea int,
    @pIdUsuarioAuditoria int,
    @pCampoOrdenado varchar(50),
    @pTipoOrdenacion varchar(4),
    @pNumeroPagina INT,
    @pDimensionPagina  INT,
    @pBusquedaGeneral varchar(100),
    @pCorrelativoVinculado int,
    @pIdPeriodo int
AS
BEGIN
BEGIN TRY
SET TRAN ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON
SET LANGUAGE SPANISH

    DECLARE @vIdPeriodo varchar(20)
    if(year(getdate()) = @pIdPeriodo) select @vIdPeriodo = '' else select @vIdPeriodo = concat('_Historico_', @pIdPeriodo)

    DECLARE @Consulta Nvarchar(max)=''
    DECLARE @ConsultaTotal Nvarchar(max)=''
    DECLARE @Filtros varchar(max)=''
    DECLARE @Offset NVARCHAR(MAX)='';
    DECLARE @Fetch NVARCHAR(MAX)='';
    DECLARE @Orden NVARCHAR(MAX)='';
    DECLARE @Parametros NVARCHAR(MAX)='';
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
	END ELSE BEGIN
	    IF(SELECT COUNT(*) FROM RecursoHumano.visPersonaJefe WHERE IdPersona = @vIdPersonaActual AND IdArea=@pIdArea)>0
  		BEGIN
      		SELECT @vIdCargoJefeEsMio=IdCargo, @vIdAreaJefeEsMio=IdArea,@vIdEmpresaJefeEsMio=IdEmpresa
      		FROM RecursoHumano.visPersonaJefe where IdArea=@pIdArea AND IdPersona = @vIdPersonaActual

            select @Consulta = N'
       	    SET @vSiPariticipo=(select COUNT(ED.IdPersonaEmisor)
      		FROM Tramite.ExpedienteDocumento' + @vIdPeriodo + N' ED
      		INNER JOIN Tramite.ExpedienteDocumentoOrigen' + @vIdPeriodo + N' EDO
      		ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
      		INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino' + @vIdPeriodo + N' EDOD
      		ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen  AND EDO.EstadoAuditoria=1
      		WHERE ED.IdExpediente=@pIdExpediente
      		AND((EDOD.IdCargoDestino = @vIdCargoJefeEsMio and EDOD.IdAreaDestino=@vIdAreaJefeEsMio)
      		OR (EDO.IdCargoOrigen=@vIdCargoJefeEsMio or EDO.IdAreaOrigen=@vIdAreaJefeEsMio)))'

            exec sp_executesql @Consulta,
                N'@pIdExpediente int, @vIdCargoJefeEsMio int, @vIdAreaJefeEsMio int, @vSiPariticipo int output',
                @pIdExpediente = @pIdExpediente,
                @vIdCargoJefeEsMio = @vIdCargoJefeEsMio,
                @vIdAreaJefeEsMio = @vIdAreaJefeEsMio,
                @vSiPariticipo = @vSiPariticipo output
  		END ELSE BEGIN
            select @Consulta = N'
 			SET @vSiPariticipo=(select COUNT(ED.IdPersonaEmisor)
 			FROM Tramite.ExpedienteDocumento ED
 			INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO
 			ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
 			INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD
 			ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen  AND EDO.EstadoAuditoria=1
 			WHERE ED.IdExpediente=@pIdExpediente
 			AND (EDOD.IdPersonaDestino = @vIdPersonaActual OR EDO.IdPersonaOrigen=@vIdPersonaActual))'

            exec sp_executesql @Consulta,
                N'@pIdExpediente int, @vIdPersonaActual int, @vSiPariticipo int output',
                @pIdExpediente = @pIdExpediente,
                @vIdPersonaActual = @vIdPersonaActual,
                @vSiPariticipo = @vSiPariticipo output
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

    select @Consulta = null
    select @Consulta= N'
    insert into #tmp001_expediente_listar SELECT
    case when ED.FgEnEsperaFirmaDigital=1 then 0 else @vSiPariticipo end SiPariticipo,EDO.EsVinculado,E.ExpedienteAnulado,E.IdExpediente,ED.IdExpedienteDocumento,EDOD.IdExpedienteDocumentoOrigenDestino,
    EDOD.IdExpedienteDocumentoOrigen,EDOD.IdCatalogoSituacionMovimientoDestino,CSM.Descripcion,EDOD.IdCatalogoTipoMovimientoDestino,CTM.Descripcion,EDO.IdCatalogoTipodevolucion,EDOD.NumeroDiasAtencionSolicitado,EDOD.FechaDestinoRecepciona,
    EDOD.HoraDestinoRecepciona,EMO.NombreEmpresa,AO.NombreArea,CO.NombreCargo,Seguridad.funObtenerRutaFotoPorIdPersona(EDO.IdPersonaOrigen),
    Seguridad.funObtenerRutaFotoPorIdPersona(EDOD.IdPersonaDestino),CASE WHEN EDO.IdPersonaOrigen=0 THEN EDO.NombreCompletoOrigen ELSE PO.NombreCompleto END, null,EDOD.NumeroDiasAtencionAceptado,EDOD.Original,EDOD.Copia,EDOD.FechaDestino,EDOD.HoraDestino,EDOD.FechaDestinoEnvia,EDOD.HoraDestinoEnvia,COALESCE(EMD.NombreEmpresa,EDOD.DestinatarioDestino,''''),AD.NombreArea,CD.NombreCargo,PD.NombreCompleto,EMR.NombreEmpresa,AR.NombreArea, CR.NombreCargo,
    PR.NombreCompleto,EMA.NombreEmpresa,AA.NombreArea,CA.NombreCargo,PA.NombreCompleto,EDOD.ObservacionesDestinatario,Tramite.funMostrarAccionesPorDestino(EDOD.IdExpedienteDocumentoOrigenDestino), null,
    CTD.Descripcion,ED.NumeroDocumento,ED.AsuntoDocumento,ED.RutaArchivoDocumento,EDOD.FechaArchivado, EDOD.HoraArchivado, EDO.Descripciondevolucion,
    Tramite.funEsExtornable(EDOD.IdExpedienteDocumentoOrigen,EDOD.IdExpedienteDocumentoOrigenDestino),EDOD.EsInicial,null,EDOD.MotivoArchivado,EE.FechaEntregaDocumento,EE.HoraEntregaDocumento,EE.RutaArchivoCargo,ED.CorrelativoVinculado,null,CTD.IdCatalogo,
    ED.FgEsObligatorioFirmaDigital,ED.FgEnEsperaFirmaDigital,ED.FlagParaDespacho,ED.IdExpedienteVirtual,concat(EDO.FechaOrigen,EDO.HoraOrigen)
    FROM Tramite.Expediente' + @vIdPeriodo + N' E
    INNER JOIN Tramite.ExpedienteDocumento' + @vIdPeriodo + N' ED ON ED.IdExpediente=E.IdExpediente
    INNER JOIN Tramite.ExpedienteDocumentoOrigen' + @vIdPeriodo + N' EDO ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
    INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino' + @vIdPeriodo + N' EDOD ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen  AND EDO.EstadoAuditoria=1
    INNER JOIN Tramite.Catalogo CTD ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento INNER JOIN Tramite.Catalogo CSM ON CSM.IdCatalogo=EDOD.IdCatalogoSituacionMovimientoDestino
    INNER JOIN Tramite.Catalogo CTM ON CTM.IdCatalogo=EDOD.IdCatalogoTipoMovimientoDestino
    LEFT JOIN General.Empresa EMO ON EMO.IdEmpresa=EDO.IdEmpresaOrigen LEFT JOIN General.Area AO ON AO.IdArea= EDO.IdAreaOrigen
    LEFT JOIN General.Cargo CO ON CO.IdCargo=EDO.IdCargoOrigen LEFT JOIN General.Empresa EMD ON EMD.IdEmpresa=EDOD.IdEmpresaDestino
    LEFT JOIN General.Area AD ON AD.IdArea= EDOD.IdAreaDestino LEFT JOIN General.Cargo CD ON CD.IdCargo=EDOD.IdCargoDestino
    LEFT JOIN General.Persona PD ON PD.IdPersona=EDOD.IdPersonaDestino LEFT JOIN General.Persona PO ON PO.IdPersona=EDO.IdPersonaOrigen
    LEFT JOIN General.Empresa EMR ON EMR.IdEmpresa=EDOD.IdEmpresaDestinoRecepciona LEFT JOIN General.Area AR ON AR.IdArea= EDOD.IdAreaDestinoRecepciona
    LEFT JOIN General.Cargo CR ON CR.IdCargo=EDOD.IdCargoDestinoRecepciona LEFT JOIN General.Persona PR ON PR.IdPersona=EDOD.IdPersonaDestinoRecepciona
    LEFT JOIN General.Empresa EMA ON EMA.IdEmpresa=EDOD.IdEmpresaDestinoAtencion LEFT JOIN General.Area AA ON AA.IdArea= EDOD.IdAreaDestinoAtencion
    LEFT JOIN General.Cargo CA ON CA.IdCargo=EDOD.IdCargoDestinoAtencion LEFT JOIN General.Persona PA ON PA.IdPersona=EDOD.IdPersonaDestinoAtencion
    LEFT JOIN Courrier.Envio EE ON EE.IdExpedienteDocumentoOrigenDestino =	EDOD.IdExpedienteDocumentoOrigenDestino AND EE.EstadoAuditoria=1 AND FgEntregado=0
    WHERE EDOD.EstadoAuditoria=1 AND E.IdExpediente=@pIdExpediente '
    +@Filtros
   	+@vCondicionVinculado

    EXECUTE sp_executesql @Consulta,
    N'@pIdExpediente int, @vIdPersonaActual int, @vSiPariticipo int',
    @pIdExpediente = @pIdExpediente,
    @vIdPersonaActual = @vIdPersonaActual,
    @vSiPariticipo = @vSiPariticipo

END TRY
BEGIN CATCH
    DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX) ,@ERROR_MESSAGE VARCHAR(MAX)
    SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE(),
    @ERROR_PROCEDURE='Tramite.paListarDetalleBusquedaExpedienteGeneralPorAnno_arq',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
    EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
END CATCH
END
GO


-- EXECUTE Tramite.paListarDetalleBusquedaExpedienteGeneralPorAnno_arq 727730,79,349,null,null,1,25,null,-1, 2025
-- EXECUTE Tramite.paListarDetalleBusquedaExpedienteGeneral_arq 797442,79,349,null,null,1,25,null,-1, 2025
-- EXECUTE Tramite.paListarDetalleBusquedaExpedienteGeneral_arq 506369,79,349,null,null,1,25,null,-1, 2025



-- SELECT
-- @pIdExpediente= 727730,  -- 797442, --
-- @pIdArea=79,
-- @pIdUsuarioAuditoria=349,
-- @pCampoOrdenado=null,
-- @pTipoOrdenacion=null,
-- @pNumeroPagina= 1,
-- @pDimensionPagina= 25,
-- @pBusquedaGeneral= null,
-- @pCorrelativoVinculado= -1,
-- @pIdPeriodo= 2025
