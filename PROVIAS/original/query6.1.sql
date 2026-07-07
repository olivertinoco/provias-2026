CREATE OR ALTER PROCEDURE Tramite.paListarExpedientePendienteEspecialistaCreados_new
    @pConFiltroFecha bit,
    @pFechaInicio varchar(10),
    @pFechaFin varchar(10),
    @pConFiltroFechaMovimiento bit,
    @pFechaInicioMovimiento varchar(10),
    @pFechaFinMovimiento varchar(10),
    @pIdPersona int,
    @pIdEmpleadoPerfil int,
    @pIdCatalogoSituacionMovimientoDestino INT,
    @pTipoSituacionMovimiento int,
    @pIdAreaOrigen int,
    @pIdAreaDestino int,
    @pIdPeriodo int,
    @pIdCatalogoTipoPrioridad int,
    @pIdCatalogoTipoTramite int,
    @pIdCatalogoTipoDocumento int,
    @pNumeroExpediente varchar(100),
    @pNumeroDocumento varchar(100),
    @pPersonaDesde varchar(100),
    @pPersonaPara varchar(100),
    @pIdTipoIngreso int,
    @pFechaDocumento  varchar(100),
    @pEmisorExpediente varchar(100),
    @pAsuntoExpediente  varchar(100),
    @pIdUsuarioAuditoria int,
    @pCampoOrdenado varchar(50),
    @pTipoOrdenacion varchar(4),
    @pNumeroPagina INT,
    @pDimensionPagina  INT,
    @pBusquedaGeneral varchar(100),
    @pFlgBusqueda INT
AS
BEGIN
    SET NOCOUNT ON;
BEGIN TRY

    SET LANGUAGE 'SPANISH';

    DECLARE @vIdCargo int = 0, @vIdArea int = 0, @vIdEmpresa int = 0;

    SELECT @vIdCargo = EP.IdCargo, @vIdArea = EP.IdArea, @vIdEmpresa = ES.IdEmpresa
    FROM RecursoHumano.EmpleadoPerfil EP
    INNER JOIN General.EmpresaSede ES ON ES.IdEmpresaSede = EP.IdEmpresaSede
    WHERE EP.IdEmpleadoPerfil = @pIdEmpleadoPerfil AND EP.EstadoAuditoria = 1 AND EP.Activo = 1;

    /* Parametros normalizados UNA sola vez (sargabilidad) */
    DECLARE @vBusquedaNumero int =
        CASE WHEN ISNUMERIC(@pBusquedaGeneral) = 1 THEN TRY_CONVERT(int, @pBusquedaGeneral) ELSE NULL END;
    DECLARE @vFechaIni datetime = TRY_CONVERT(datetime, @pFechaInicio);
    DECLARE @vFechaFin datetime = TRY_CONVERT(datetime, @pFechaFin);

    /* #temp con estadisticas reales en lugar de variable de tabla */
    CREATE TABLE #Tmp (IdExpediente int NOT NULL, FechaMovimiento datetime NOT NULL);

    /* Se conserva la compuerta original: si la busqueda es texto no numerico, no se lista nada */
    IF ISNUMERIC(@pBusquedaGeneral) = 1 OR @pBusquedaGeneral IS NULL OR @pBusquedaGeneral = ''
    BEGIN
        INSERT INTO #Tmp (IdExpediente, FechaMovimiento)
        SELECT E.IdExpediente,
               MAX(CONVERT(datetime, EDO.FechaOrigen + ' ' + EDO.HoraOrigen))
        FROM Tramite.Expediente E WITH (NOLOCK)
        INNER JOIN Tramite.ExpedienteDocumento ED WITH (NOLOCK)
            ON ED.IdExpediente = E.IdExpediente AND ED.EstadoAuditoria = 1
        INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
            ON EDO.IdExpedienteDocumento = ED.IdExpedienteDocumento AND EDO.EstadoAuditoria = 1
        WHERE E.EstadoAuditoria = 1 AND COALESCE(E.ExpedienteAnulado,0) = 0
          AND EDO.IdPersonaOrigen = @pIdPersona
          AND EDO.IdAreaOrigen    = @vIdArea
          AND EDO.IdCargoOrigen   = @vIdCargo
          AND EDO.IdEmpresaOrigen = @vIdEmpresa
          AND E.IdPeriodo         = @pIdPeriodo
          AND EDO.IdCatalogoSituacionMovimientoOrigen = 116
          /* filtro de fecha condicional (se omite por completo si no aplica) */
          AND (@pConFiltroFecha = 0
               OR CONVERT(datetime, EDO.FechaOrigen) BETWEEN @vFechaIni AND @vFechaFin)
          /* busqueda general solo cuando es numerica */
          AND (@vBusquedaNumero IS NULL OR E.NumeroExpediente = @vBusquedaNumero)
          /* se conserva el semantico "debe existir EDOD" sin el JOIN que multiplicaba filas */
          AND EXISTS (SELECT 1 FROM Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
                      WHERE EDOD.IdExpedienteDocumentoOrigen = EDO.IdExpedienteDocumentoOrigen
                        AND EDOD.EstadoAuditoria = 1)
        GROUP BY E.IdExpediente
        OPTION (RECOMPILE);
    END

    CREATE CLUSTERED INDEX IX_Tmp ON #Tmp (FechaMovimiento DESC, IdExpediente);

    SELECT
        E.IdExpediente,
        E.IdPersonaCreador,
        E.ExpedienteConfidencial,
        E.NTFechaExpediente,
        E.HoraExpediente,
        E.IdCatalogoTipoPrioridad,
        CatalogoTipoPrioridad   = CTP.Descripcion,
        CatalogoTipoTramite     = COALESCE(CTT.Descripcion,''),
        ColorCatalogoTipoTramite= COALESCE(CTT.Detalle,''),
        US.Logueo,
        E.AsuntoExpediente,
        E.NumeroFoliosExpediente,
        ObservacionesExpediente = COALESCE(E.ObservacionesExpediente,''),
        Fecha                   = CONCAT(E.NTFechaExpediente,' ',E.HoraExpediente),
        NombreExpediente        = CONCAT(SD.AbreviaturaSerieDocumentalExpediente, RIGHT(CONCAT('000000',E.NumeroExpediente),6), '-', E.IdPeriodo),
        NombreCompletoCreador   = CASE WHEN COALESCE(E.NombreCompletoCreador,'') <> '' THEN COALESCE(E.NombreCompletoCreador,'') ELSE PE.NombreCompleto END,
        E.NumeroExpediente,
        IdExpedienteSeguimiento = COALESCE(ES.IdExpedienteSeguimiento,0),
        EX.FechaMovimiento
    INTO #Pagina
    FROM Tramite.Expediente E WITH (NOLOCK)
    INNER JOIN #Tmp EX                              ON EX.IdExpediente = E.IdExpediente
    INNER JOIN Seguridad.Usuario US                ON US.IdUsuario = E.IdUsuarioCreacionAuditoria AND E.EstadoAuditoria = 1 AND COALESCE(E.ExpedienteAnulado,0) = 0
    INNER JOIN Tramite.SerieDocumentalExpediente SD WITH (NOLOCK) ON SD.IdSerieDocumentalExpediente = E.IdSerieDocumentalExpediente
    INNER JOIN Tramite.Catalogo CTP                ON CTP.IdCatalogo = E.IdCatalogoTipoPrioridad
    INNER JOIN Tramite.Catalogo CTT                ON CTT.IdCatalogo = E.IdCatalogoTipoTramite
    LEFT  JOIN General.Persona PE                  ON PE.IdPersona = E.IdPersonaCreador
    LEFT  JOIN Tramite.ExpedienteSeguimiento ES WITH (NOLOCK)
           ON ES.IdExpediente = E.IdExpediente AND ES.EstadoAuditoria = 1
          AND ES.IdEmpresa = @vIdEmpresa AND ES.IdCargo = @vIdCargo AND ES.IdPersona = @pIdPersona AND ES.IdArea = @vIdArea
    ORDER BY EX.FechaMovimiento DESC
    OFFSET (@pNumeroPagina - 1) * @pDimensionPagina ROWS
    FETCH NEXT @pDimensionPagina ROWS ONLY;


    SELECT
        anul.EsParaAnular,
        CatalogoTipoOrigen = oi.CatalogoTipoOrigen,
        DiasPendiente = 0,
        NombrePersonaOrigen = '',
        NumeroDocumento = COALESCE(nd.NumeroDocumento,''),
        IdExpedienteDocumento = COALESCE(ide.IdExpedienteDocumento,0),
        NombreExpedientesEnlazados = enl.Lista,
        EsPrincipalEnlace = CAST(CASE WHEN EXISTS (SELECT 1 FROM Tramite.ExpedienteEnlazado EE WITH (NOLOCK)
                                                   WHERE EE.IdExpediente = P.IdExpediente AND EE.EstadoAuditoria = 1)
                                      THEN 1 ELSE 0 END AS BIT),
        CatalogoTipoOrigen = oi.CatalogoTipoOrigen,   -- segunda columna, mismo valor (shape original)
        P.IdExpediente,
        P.ExpedienteConfidencial,
        P.NTFechaExpediente,
        P.HoraExpediente,
        P.IdCatalogoTipoPrioridad,
        P.CatalogoTipoPrioridad,
        P.CatalogoTipoTramite,
        P.ColorCatalogoTipoTramite,
        P.Logueo,
        RutaFotoPersona = COALESCE(foto.RutaFoto,'sinfotoH.jpg'),
        P.AsuntoExpediente,
        P.NumeroFoliosExpediente,
        P.ObservacionesExpediente,
        P.Fecha,
        P.NombreExpediente,
        P.NombreCompletoCreador,
        P.NumeroExpediente,
        P.IdExpedienteSeguimiento,
        P.FechaMovimiento
    FROM #Pagina P
    CROSS APPLY Tramite.tvfParaAnularEspecialista(P.IdExpediente, @pIdPersona, @vIdEmpresa, @vIdArea, @vIdCargo) anul
    OUTER APPLY Tramite.tvfOrigenInicialDocumento(P.IdExpediente) oi
    OUTER APPLY Tramite.tvfNumeroDocumentoEspecialista(P.IdExpediente, @vIdArea, @vIdCargo, @pIdPersona, @pIdCatalogoSituacionMovimientoDestino) nd
    OUTER APPLY Tramite.tvfIdExpedienteDocumentoEspecialista(P.IdExpediente, @vIdArea, @vIdCargo, @pIdPersona, @pIdCatalogoSituacionMovimientoDestino) ide
    OUTER APPLY Tramite.tvfExpedientesEnlazados(P.IdExpediente) enl
    OUTER APPLY Seguridad.tvfRutaFotoPorIdPersona(P.IdPersonaCreador) foto
    ORDER BY P.FechaMovimiento DESC;

    /*--------------------------------------------------------------------------------------
      Segundo result set: total (mismos INNER JOIN que la pagina, sin funciones)
    --------------------------------------------------------------------------------------*/
    SELECT COUNT(*)
    FROM Tramite.Expediente E WITH (NOLOCK)
    INNER JOIN #Tmp EX                              ON EX.IdExpediente = E.IdExpediente
    INNER JOIN Seguridad.Usuario US                ON US.IdUsuario = E.IdUsuarioCreacionAuditoria AND E.EstadoAuditoria = 1 AND COALESCE(E.ExpedienteAnulado,0) = 0
    INNER JOIN Tramite.SerieDocumentalExpediente SD WITH (NOLOCK) ON SD.IdSerieDocumentalExpediente = E.IdSerieDocumentalExpediente
    INNER JOIN Tramite.Catalogo CTP                ON CTP.IdCatalogo = E.IdCatalogoTipoPrioridad
    INNER JOIN Tramite.Catalogo CTT                ON CTT.IdCatalogo = E.IdCatalogoTipoTramite;


END TRY
BEGIN CATCH
    DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT, @ERROR_STATE INT, @ERROR_LINE INT,
            @ERROR_PROCEDURE VARCHAR(MAX), @ERROR_MESSAGE VARCHAR(MAX);
    SELECT @ERROR_NUMBER = ERROR_NUMBER(), @ERROR_SEVERITY = ERROR_SEVERITY(), @ERROR_STATE = ERROR_STATE(),
           @ERROR_PROCEDURE = 'Tramite.paListarExpedientePendienteEspecialistaCreados_new',
           @ERROR_LINE = ERROR_LINE(), @ERROR_MESSAGE = ERROR_MESSAGE();
    EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER, @ERROR_SEVERITY, @ERROR_STATE, @ERROR_PROCEDURE, @ERROR_LINE, @ERROR_MESSAGE, @pIdUsuarioAuditoria;
END CATCH
END
GO







/*==========================================================================================
  3. INDICES SUGERIDOS (evaluar en pre-produccion; habilitan Index Seek en la poblacion)
==========================================================================================*/
/*
CREATE NONCLUSTERED INDEX IX_EDO_Especialista
ON Tramite.ExpedienteDocumentoOrigen
    (IdPersonaOrigen, IdAreaOrigen, IdCargoOrigen, IdEmpresaOrigen,
     IdCatalogoSituacionMovimientoOrigen, EstadoAuditoria)
INCLUDE (IdExpedienteDocumento, FechaOrigen, HoraOrigen);

-- Apoya la rama por Destino de tvfNumeroDocumento / tvfIdExpedienteDocumento (sit 4,5,112)
CREATE NONCLUSTERED INDEX IX_EDOD_Destino
ON Tramite.ExpedienteDocumentoOrigenDestino
    (IdAreaDestino, IdCargoDestino, IdPersonaDestino, IdCatalogoSituacionMovimientoDestino, EstadoAuditoria)
INCLUDE (IdExpedienteDocumentoOrigen, IdExpedienteDocumentoOrigenDestinoAnterior, MotivoArchivado);
*/



set statistics io on
set statistics time on


EXEC Tramite.paListarExpedientePendienteEspecialistaCreados_new
0, '23/04/2026','23/04/2026',0,'23/04/2026','23/04/2026',978,977,116,4,0,0,2026,0,0,0,'','','','',0,'','','',978,null,null,1,10,null,0



set statistics io off
set statistics time off


-- EXEC Tramite.paListarExpedientePendienteEspecialistaCreados_new
-- 0, '23/04/2026','23/04/2026',0,'23/04/2026','23/04/2026',350,2260,116,4,0,0,2026,0,0,0,'','','','',0,'','','',350,null,null,1,10,null,0
