CREATE OR ALTER PROCEDURE Tramite.paListarExpedientePendienteEspecialistaReenviados_new
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
BEGIN TRY
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

        DECLARE @vIdCargo   int = 0,
                @vIdArea    int = 0,
                @vIdEmpresa int = 0;

        -- Contexto del especialista (empresa/area/cargo)
        SELECT @vIdCargo = EP.IdCargo,
               @vIdArea  = EP.IdArea,
               @vIdEmpresa = ES.IdEmpresa
        FROM RecursoHumano.EmpleadoPerfil EP
        INNER JOIN General.EmpresaSede ES
               ON ES.IdEmpresaSede = EP.IdEmpresaSede
        WHERE EP.IdEmpleadoPerfil = @pIdEmpleadoPerfil
          AND EP.EstadoAuditoria = 1
          AND EP.Activo = 1;

        SET LANGUAGE 'SPANISH';

        -- Fronteras de fecha tipadas (fuera de la columna -> predicado sargable/condicional)
        DECLARE @vFechaIni datetime = NULL,
                @vFechaFin datetime = NULL;
        IF @pConFiltroFecha = 1
        BEGIN
            SET @vFechaIni = CONVERT(datetime, @pFechaInicio);
            SET @vFechaFin = CONVERT(datetime, @pFechaFin);
        END

        /*------------------------------------------------------------------------------------------
          PASO 1: Movimientos base (IdExpediente + FechaMovimiento) desde la vista de negocio.
          #temp en lugar de variable de tabla -> estadísticas reales para los joins posteriores.
        ------------------------------------------------------------------------------------------*/
        IF OBJECT_ID('tempdb..#Movs') IS NOT NULL DROP TABLE #Movs;
        CREATE TABLE #Movs
        (
            IdExpediente    int         NOT NULL,
            FechaMovimiento datetime    NULL,
            PRIMARY KEY (IdExpediente)
        );

        IF ISNUMERIC(@pBusquedaGeneral) = 1 OR @pBusquedaGeneral IS NULL OR @pBusquedaGeneral = ''
        BEGIN
            INSERT INTO #Movs (IdExpediente, FechaMovimiento)
            SELECT EDOD.IdExpediente,
                   MAX(CONVERT(DATETIME, EDOD.FechaDestinoEnvia + ' ' + EDOD.HoraDestinoEnvia)) AS FechaMovimiento
            FROM Tramite.visExpedienteCompleto EDOD
            WHERE EDOD.IdPersonaDestino = @pIdPersona
              AND EDOD.IdAreaDestino    = @vIdArea
              AND EDOD.IdCargoDestino   = @vIdCargo
              AND EDOD.IdEmpresaDestino = @vIdEmpresa
              AND EDOD.IdCatalogoSituacionMovimientoDestino = 111
              -- Filtro de fecha solo cuando aplica; con RECOMPILE la rama inactiva se elimina.
              AND (@pConFiltroFecha = 0
                   OR CONVERT(DATETIME, EDOD.FechaDestinoEnvia) BETWEEN @vFechaIni AND @vFechaFin)
              -- Filtro por número de expediente solo cuando se envía.
              AND (@pBusquedaGeneral IS NULL OR @pBusquedaGeneral = 0 OR EDOD.NumeroExpediente = @pBusquedaGeneral)
              AND YEAR(CONVERT(DATETIME, EDOD.FechaDestinoEnvia)) = @pIdPeriodo
            GROUP BY EDOD.IdExpediente
            OPTION (RECOMPILE);
        END

        /*------------------------------------------------------------------------------------------
          PASO 2: Se materializa UNA sola vez el conjunto base con las columnas de salida.
          De aquí salen tanto el conteo como la página (evita el doble join del original).
          Estructura idéntica (nombre/tipo/orden) a la @MITABLA original.
        ------------------------------------------------------------------------------------------*/
        IF OBJECT_ID('tempdb..#Base') IS NOT NULL DROP TABLE #Base;
        CREATE TABLE #Base
        (
            IdExpediente             int           NOT NULL,
            ExpedienteConfidencial   bit           NULL,
            NTFechaExpediente        varchar(10)   NULL,
            HoraExpediente           varchar(5)    NULL,
            IdCatalogoTipoPrioridad  int           NULL,
            CatalogoTipoPrioridad    varchar(100)  NULL,
            CatalogoTipoTramite      varchar(100)  NULL,
            ColorCatalogoTipoTramite varchar(100)  NULL,
            Logueo                   varchar(100)  NULL,
            IdPersonaCreador         int           NULL,
            AsuntoExpediente         varchar(8000) NULL,
            NumeroFoliosExpediente   int           NULL,
            ObservacionesExpediente  varchar(4000) NULL,
            Fecha                    varchar(20)   NULL,
            NombreExpediente         varchar(100)  NULL,
            NombreCompletoCreador    varchar(100)  NULL,
            NumeroExpediente         int           NULL,
            IdExpedienteSeguimiento  int           NULL,
            FechaMovimiento          datetime      NULL
        );

        INSERT INTO #Base
        (
            IdExpediente, ExpedienteConfidencial, NTFechaExpediente, HoraExpediente,
            IdCatalogoTipoPrioridad, CatalogoTipoPrioridad, CatalogoTipoTramite, ColorCatalogoTipoTramite,
            Logueo, IdPersonaCreador, AsuntoExpediente, NumeroFoliosExpediente, ObservacionesExpediente,
            Fecha, NombreExpediente, NombreCompletoCreador, NumeroExpediente, IdExpedienteSeguimiento, FechaMovimiento
        )
        SELECT
            E.IdExpediente,
            E.ExpedienteConfidencial,
            E.NTFechaExpediente,
            E.HoraExpediente,
            E.IdCatalogoTipoPrioridad,
            CTP.Descripcion,
            COALESCE(CTT.Descripcion, ''),
            COALESCE(CTT.Detalle, ''),
            US.Logueo,
            E.IdPersonaCreador,
            E.AsuntoExpediente,
            E.NumeroFoliosExpediente,
            COALESCE(E.ObservacionesExpediente, ''),
            CONCAT(E.NTFechaExpediente, ' ', E.HoraExpediente),
            CONCAT(SD.AbreviaturaSerieDocumentalExpediente, RIGHT(CONCAT('000000', E.NumeroExpediente), 6), '-', E.IdPeriodo),
            CASE WHEN COALESCE(E.NombreCompletoCreador, '') <> '' THEN COALESCE(E.NombreCompletoCreador, '')
                 ELSE PE.NombreCompleto END,
            E.NumeroExpediente,
            COALESCE(ES.IdExpedienteSeguimiento, 0),
            M.FechaMovimiento
        FROM Tramite.Expediente E
        INNER JOIN #Movs M
               ON M.IdExpediente = E.IdExpediente
        INNER JOIN Seguridad.Usuario US
               ON US.IdUsuario = E.IdUsuarioCreacionAuditoria
              AND E.EstadoAuditoria = 1
              AND COALESCE(E.ExpedienteAnulado, 0) = 0
        INNER JOIN Tramite.SerieDocumentalExpediente SD
               ON SD.IdSerieDocumentalExpediente = E.IdSerieDocumentalExpediente
        INNER JOIN Tramite.Catalogo CTP
               ON CTP.IdCatalogo = E.IdCatalogoTipoPrioridad
        LEFT JOIN Tramite.ExpedienteSeguimiento ES
               ON ES.IdExpediente = E.IdExpediente
              AND ES.EstadoAuditoria = 1
              AND ES.IdEmpresa = @vIdEmpresa
              AND ES.IdCargo   = @vIdCargo
              AND ES.IdPersona = @pIdPersona
              AND ES.IdArea    = @vIdArea
        LEFT JOIN General.Persona PE
               ON PE.IdPersona = E.IdPersonaCreador
        LEFT JOIN Tramite.Catalogo CTT
               ON CTT.IdCatalogo = E.IdCatalogoTipoTramite
        WHERE E.EstadoAuditoria = 1
        OPTION (RECOMPILE);

        /*------------------------------------------------------------------------------------------
          RESULT SET 1: DATOS (página). Las ITVF (tus funciones propuestas) se invocan
          por OUTER APPLY SOLO sobre las filas de la página, no sobre todo el conjunto base.
          Los COALESCE reproducen exactamente el valor por defecto del escalar original
          ('' para textos, 0 para ids, 'sinfotoH.jpg' para la foto).
        ------------------------------------------------------------------------------------------*/
        SELECT
            EsParaAnular            = CONVERT(BIT, 0),   -- literal (idéntico al original)
            DiasPendiente           = 0,                 -- literal (idéntico al original)
            NombrePersonaOrigen     = '',                -- literal (idéntico al original)
            NumeroDocumento         = COALESCE(nd.NumeroDocumento, ''),
            IdExpedienteDocumento   = COALESCE(idd.IdExpedienteDocumento, 0),
            NombreExpedientesEnlazados = COALESCE(enl.Lista, ''),
            EsPrincipalEnlace       = pri.EsPrincipalEnlace,
            CatalogoTipoOrigen      = COALESCE(ori.CatalogoTipoOrigen, ''),
            RutaFotoPersona         = COALESCE(foto.RutaFoto, 'sinfotoH.jpg'),
            P.IdExpediente,
            P.ExpedienteConfidencial,
            P.NTFechaExpediente,
            P.HoraExpediente,
            P.IdCatalogoTipoPrioridad,
            P.CatalogoTipoPrioridad,
            P.CatalogoTipoTramite,
            P.ColorCatalogoTipoTramite,
            P.Logueo,
            P.IdPersonaCreador,
            P.AsuntoExpediente,
            P.NumeroFoliosExpediente,
            P.ObservacionesExpediente,
            P.Fecha,
            P.NombreExpediente,
            P.NombreCompletoCreador,
            P.NumeroExpediente,
            P.IdExpedienteSeguimiento,
            P.FechaMovimiento
        FROM
        (
            SELECT
                B.IdExpediente, B.ExpedienteConfidencial, B.NTFechaExpediente, B.HoraExpediente,
                B.IdCatalogoTipoPrioridad, B.CatalogoTipoPrioridad, B.CatalogoTipoTramite, B.ColorCatalogoTipoTramite,
                B.Logueo, B.IdPersonaCreador, B.AsuntoExpediente, B.NumeroFoliosExpediente, B.ObservacionesExpediente,
                B.Fecha, B.NombreExpediente, B.NombreCompletoCreador, B.NumeroExpediente, B.IdExpedienteSeguimiento,
                B.FechaMovimiento
            FROM #Base B
            ORDER BY B.FechaMovimiento DESC
            OFFSET (@pNumeroPagina - 1) * @pDimensionPagina ROWS
            FETCH NEXT @pDimensionPagina ROWS ONLY
        ) P
        OUTER APPLY Tramite.tvfNumeroDocumentoEspecialista
                    (P.IdExpediente, @vIdArea, @vIdCargo, @pIdPersona, @pIdCatalogoSituacionMovimientoDestino) nd
        OUTER APPLY Tramite.tvfIdExpedienteDocumentoEspecialista
                    (P.IdExpediente, @vIdArea, @vIdCargo, @pIdPersona, @pIdCatalogoSituacionMovimientoDestino) idd
        OUTER APPLY Tramite.tvfExpedientesEnlazados (P.IdExpediente) enl
        OUTER APPLY Tramite.tvfEsPrincipalEnlace   (P.IdExpediente) pri
        OUTER APPLY Tramite.tvfOrigenInicialDocumento (P.IdExpediente) ori
        OUTER APPLY Tramite.tvfRutaFotoPorIdPersona (P.IdPersonaCreador) foto
        OPTION (RECOMPILE);

        /*------------------------------------------------------------------------------------------
          RESULT SET 2: CONTEO total (mismo cardinal que el original), pero SIN re-ejecutar
          el join: sale directo del conjunto ya materializado.
        ------------------------------------------------------------------------------------------*/
        SELECT COUNT(*) FROM #Base;

END TRY
BEGIN CATCH
    DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT, @ERROR_STATE INT, @ERROR_LINE INT,
            @ERROR_PROCEDURE VARCHAR(MAX), @ERROR_MESSAGE VARCHAR(MAX);
    SELECT @ERROR_NUMBER = ERROR_NUMBER(), @ERROR_SEVERITY = ERROR_SEVERITY(), @ERROR_STATE = ERROR_STATE(),
           @ERROR_PROCEDURE = 'Tramite.paListarExpedientePendienteEspecialistaReenviados',
           @ERROR_LINE = ERROR_LINE(), @ERROR_MESSAGE = ERROR_MESSAGE();
    EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER, @ERROR_SEVERITY, @ERROR_STATE,
           @ERROR_PROCEDURE, @ERROR_LINE, @ERROR_MESSAGE, @pIdUsuarioAuditoria;
END CATCH
END
GO



-- set statistics io on
-- set statistics time on


exec tramite.paListarExpedientePendienteEspecialistaReenviados_new  0,'01/04/2026','01/04/2026',0,'01/04/2026','01/04/2026',637,636,111,4,0,0,2026,0,0,0,'','','','',0,'','','',637,NULL,NULL,2,10,NULL,0


-- set statistics io off
-- set statistics time off


exec tramite.paListarExpedientePendienteEspecialistaReenviados  0,'01/04/2026','01/04/2026',0,'01/04/2026','01/04/2026',637,636,111,4,0,0,2026,0,0,0,'','','','',0,'','','',637,NULL,NULL,2,10,NULL,0
