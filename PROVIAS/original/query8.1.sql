CREATE OR ALTER PROCEDURE Tramite.paListarExpedientePendienteEspecialistaV7_new
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
    @pFechaDocumento varchar(100),
    @pEmisorExpediente varchar(100),
    @pAsuntoExpediente varchar(100),
    @pIdUsuarioAuditoria int,
    @pCampoOrdenado varchar(50),
    @pTipoOrdenacion varchar(4),
    @pNumeroPagina INT,
    @pDimensionPagina INT,
    @pBusquedaGeneral varchar(100),
    @pFlgBusqueda INT
AS
BEGIN
BEGIN TRY
SET NOCOUNT ON;

        DECLARE @vIdCargo int = 0, @vIdArea int = 0, @vIdEmpresa int = 0,
                @iRegistroTotal int, @iPaginaRegInicio int, @iPaginaRegFinal int;

        SELECT @vIdCargo = EP.IdCargo,
               @vIdArea  = EP.IdArea,
               @vIdEmpresa = ES.IdEmpresa
        FROM RecursoHumano.EmpleadoPerfil EP WITH (NOLOCK)
        INNER JOIN General.EmpresaSede ES WITH (NOLOCK)
            ON ES.IdEmpresaSede = EP.IdEmpresaSede
        WHERE EP.IdEmpleadoPerfil = @pIdEmpleadoPerfil
          AND EP.EstadoAuditoria = 1
          AND EP.Activo = 1;

        SET LANGUAGE SPANISH;

        CREATE TABLE #vTablaExpediente
        (
            IdExpediente    BIGINT,
            FechaMovimiento DATETIME,
            eNroOrden       INT
        );

        /* -------------------------------------------------------------------------------
           Poblado de la tabla temporal.
           Se conserva el guard original: solo se ejecuta si @pBusquedaGeneral es numerico
           (sin punto) o esta vacio. Las dos ramas duplicadas del V7 se unifican en un solo
           INSERT usando un predicado sargable para el filtro por numero de expediente.
        --------------------------------------------------------------------------------*/
        IF (ISNUMERIC(@pBusquedaGeneral) = 1 AND CAST(@pBusquedaGeneral AS VARCHAR(5)) NOT LIKE '%.%')
           OR COALESCE(@pBusquedaGeneral,'') = ''
        BEGIN
            INSERT INTO #vTablaExpediente (IdExpediente, FechaMovimiento, eNroOrden)
            SELECT
                SE.IdExpediente,
                SE.FechaMovimiento,
                ROW_NUMBER() OVER (ORDER BY SE.FechaMovimiento DESC) AS eNroOrden
            FROM
            (
                SELECT E.IdExpediente,
                       MAX(CONVERT(DATETIME, EDOD.FechaDestinoEnvia + ' ' + EDOD.HoraDestinoEnvia)) AS FechaMovimiento
                FROM Tramite.Expediente E WITH (NOLOCK)
                INNER JOIN Tramite.ExpedienteDocumento ED WITH (NOLOCK)
                    ON E.IdExpediente = ED.IdExpediente AND ED.EstadoAuditoria = E.EstadoAuditoria
                INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
                    ON EDO.IdExpedienteDocumento = ED.IdExpedienteDocumento AND EDO.EstadoAuditoria = E.EstadoAuditoria
                INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
                    ON EDOD.IdExpedienteDocumentoOrigen = EDO.IdExpedienteDocumentoOrigen AND EDOD.EstadoAuditoria = E.EstadoAuditoria
                WHERE E.EstadoAuditoria = 1
                  AND E.ExpedienteAnulado = 0
                  AND EDOD.IdPersonaDestino = @pIdPersona
                  AND EDOD.IdAreaDestino    = @vIdArea
                  AND EDOD.IdCargoDestino   = @vIdCargo
                  AND EDOD.IdEmpresaDestino = @vIdEmpresa
                  AND ED.FgEnEsperaFirmaDigital = 0
                  AND EDOD.IdCatalogoSituacionMovimientoDestino = @pIdCatalogoSituacionMovimientoDestino
                  -- SARGABLE: filtro de fecha sin referenciar la columna dentro del CASE
                  AND (@pConFiltroFecha = 0 OR EDOD.FechaDestino BETWEEN @pFechaInicio AND @pFechaFin)
                  -- SARGABLE: filtro por numero de expediente unificado (equivale a las 2 ramas del V7)
                  AND (COALESCE(@pBusquedaGeneral,'') = '' OR E.NumeroExpediente = @pBusquedaGeneral)
                GROUP BY E.IdExpediente
            ) SE
            OPTION (RECOMPILE, MAXDOP 2);
        END

        --Calculando Paginacion
        SET @iRegistroTotal = (SELECT COUNT(1) FROM #vTablaExpediente);

        SELECT @iPaginaRegInicio = c.iStartRow,
               @iPaginaRegFinal  = c.iEndrow
        FROM General.fnObtenerPaginacion(@pDimensionPagina, @pNumeroPagina, @iRegistroTotal) c;

        /* -------------------------------------------------------------------------------
           SELECT final: se elimina el row-by-row de las 7 Scalar UDFs.
           Cada UDF se sustituye por una Inline TVF invocada con APPLY, que el optimizador
           integra al plan (sin context-switching y habilitando paralelismo).
           IMPORTANTE: primero se pagina (#vTablaExpediente EX) y recien luego se aplican
           las TVFs, de modo que solo se evaluan las N filas de la pagina, no las 765.
        --------------------------------------------------------------------------------*/
        SELECT
            anular.EsParaAnular,
            dias.DiasPendiente,
            '' AS NombrePersonaOrigen,
            numdoc.NumeroDocumento,
            iddoc.IdExpedienteDocumento,
            enl.Lista AS NombreExpedientesEnlazados,
            prin.EsPrincipalEnlace,
            orig.CatalogoTipoOrigen,
            E.IdExpediente,
            E.ExpedienteConfidencial,
            E.NTFechaExpediente,
            E.HoraExpediente,
            E.IdCatalogoTipoPrioridad,
            CTP.Descripcion AS CatalogoTipoPrioridad,
            COALESCE(CTT.Descripcion,'') AS CatalogoTipoTramite,
            COALESCE(CTT.Detalle,'')     AS ColorCatalogoTipoTramite,
            US.Logueo,
            -- Fiel al V7: si la TVF no devuelve foto, se usa el default por sexo.
            COALESCE(foto.RutaFoto,
                     CASE WHEN COALESCE(PE.Sexo,0) = 0 THEN 'sinfotoH.jpg' ELSE 'sinfotoM.jpg' END
            ) AS RutaFotoPersona,
            E.AsuntoExpediente,
            E.NumeroFoliosExpediente,
            COALESCE(E.ObservacionesExpediente,'') AS ObservacionesExpediente,
            CONCAT(E.NTFechaExpediente,' ', E.HoraExpediente) AS Fecha,
            E.NombreExpediente,
            CASE WHEN COALESCE(E.NombreCompletoCreador,'') <> ''
                 THEN COALESCE(E.NombreCompletoCreador,'')
                 ELSE PE.NombreCompleto END AS NombreCompletoCreador,
            E.NumeroExpediente,
            COALESCE(ES.IdExpedienteSeguimiento,0) AS IdExpedienteSeguimiento,
            EX.FechaMovimiento
        FROM #vTablaExpediente EX
        INNER JOIN Tramite.Expediente E WITH (NOLOCK)
            ON E.IdExpediente = EX.IdExpediente
        INNER JOIN Seguridad.Usuario US WITH (NOLOCK)
            ON US.IdUsuario = E.IdUsuarioCreacionAuditoria
        INNER JOIN Tramite.Catalogo CTP WITH (NOLOCK)
            ON CTP.IdCatalogo = E.IdCatalogoTipoPrioridad
        INNER JOIN Tramite.Catalogo CTT WITH (NOLOCK)
            ON CTT.IdCatalogo = E.IdCatalogoTipoTramite
        LEFT JOIN General.Persona PE WITH (NOLOCK)
            ON PE.IdPersona = E.IdPersonaCreador
        LEFT JOIN Tramite.ExpedienteSeguimiento ES WITH (NOLOCK)
            ON ES.IdExpediente = E.IdExpediente AND ES.EstadoAuditoria = 1
           AND ES.IdEmpresa = @vIdEmpresa AND ES.IdCargo = @vIdCargo
           AND ES.IdPersona = @pIdPersona AND ES.IdArea = @vIdArea
        -- Inline TVFs (reemplazan a las Scalar UDFs del V7)
        CROSS APPLY Tramite.tvfParaAnularEspecialista(E.IdExpediente, @pIdPersona, @vIdEmpresa, @vIdArea, @vIdCargo) anular
        CROSS APPLY Tramite.tvfDiasPendienteEspecialista(E.IdExpediente, @pIdPersona, @vIdEmpresa, @vIdArea, @vIdCargo, @pIdCatalogoSituacionMovimientoDestino) dias
        OUTER APPLY Tramite.tvfNumeroDocumentoEspecialista(E.IdExpediente, @vIdArea, @vIdCargo, @pIdPersona, @pIdCatalogoSituacionMovimientoDestino) numdoc
        OUTER APPLY Tramite.tvfIdExpedienteDocumentoEspecialista(E.IdExpediente, @vIdArea, @vIdCargo, @pIdPersona, @pIdCatalogoSituacionMovimientoDestino) iddoc
        OUTER APPLY Tramite.tvfExpedientesEnlazados(E.IdExpediente) enl
        CROSS APPLY Tramite.tvfEsPrincipalEnlace(E.IdExpediente) prin
        OUTER APPLY Tramite.tvfOrigenInicialDocumento(E.IdExpediente) orig
        OUTER APPLY Seguridad.tvfRutaFotoPorIdPersona(E.IdPersonaCreador) foto
        WHERE EX.eNroOrden BETWEEN @iPaginaRegInicio AND @iPaginaRegFinal
        ORDER BY EX.eNroOrden ASC

        SELECT @iRegistroTotal;

    END TRY
    BEGIN CATCH
        DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT, @ERROR_STATE INT, @ERROR_LINE INT,
                @ERROR_PROCEDURE VARCHAR(MAX), @ERROR_MESSAGE VARCHAR(MAX);
        SELECT @ERROR_NUMBER = ERROR_NUMBER(), @ERROR_SEVERITY = ERROR_SEVERITY(),
               @ERROR_STATE = ERROR_STATE(),   @ERROR_LINE = ERROR_LINE(),
               @ERROR_PROCEDURE = 'Tramite.paListarExpedientePendienteEspecialistaV7_new',
               @ERROR_MESSAGE = ERROR_MESSAGE();
        EXEC Seguridad.paGuardarErroresEnTablaLog
             @ERROR_NUMBER, @ERROR_SEVERITY, @ERROR_STATE, @ERROR_PROCEDURE,
             @ERROR_LINE, @ERROR_MESSAGE, @pIdUsuarioAuditoria;
    END CATCH
END;
GO



set statistics io on
set statistics time on


exec tramite.paListarExpedientePendienteEspecialistaV7_new
0,'10/03/2026','10/03/2026',0,'10/03/2026','10/03/2026',1309,3158,3,4,0,0,2026,0,0,0,'','','','',0,'','','',26766,NULL,NULL,2,100,NULL,0


set statistics io off
set statistics time off


-- exec tramite.paListarExpedientePendienteEspecialistaV7
-- 0,'10/03/2026','10/03/2026',0,'10/03/2026','10/03/2026',1309,3158,3,4,0,0,2026,0,0,0,'','','','',0,'','','',26766,NULL,NULL,2,100,NULL,0
