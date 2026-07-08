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
SET TRAN ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON
SET LANGUAGE SPANISH

        DECLARE @vIdCargo int = 0, @vIdArea int = 0, @vIdEmpresa int = 0,
                @iRegistroTotal int, @iPaginaRegInicio int, @iPaginaRegFinal int;

        /*--- Contexto del especialista (sin cambios) -----------------------------------------*/
        SELECT @vIdCargo   = EP.IdCargo,
               @vIdArea    = EP.IdArea,
               @vIdEmpresa = ES.IdEmpresa
        FROM RecursoHumano.EmpleadoPerfil EP
            INNER JOIN General.EmpresaSede ES  ON ES.IdEmpresaSede = EP.IdEmpresaSede
        WHERE EP.IdEmpleadoPerfil = @pIdEmpleadoPerfil
          AND EP.EstadoAuditoria = 1
          AND EP.Activo = 1;

        /*------------------------------------------------------------------------------------
          [1] PAGINACION (misma logica set-based del original).
        ------------------------------------------------------------------------------------*/
        CREATE TABLE #vTablaExpediente(IdExpediente BIGINT, FechaMovimiento DATETIME, eNroOrden INT,
            INDEX IX_vTablaExpediente_eNroOrden CLUSTERED (eNroOrden));

        IF (ISNUMERIC(@pBusquedaGeneral) = 1 AND CAST(@pBusquedaGeneral AS VARCHAR(5)) NOT LIKE '%.%')
            OR ISNULL(@pBusquedaGeneral, '') = ''
        BEGIN
            IF ISNULL(@pBusquedaGeneral, '') <> ''
            BEGIN
                INSERT INTO #vTablaExpediente(IdExpediente, FechaMovimiento, eNroOrden)
                SELECT SE.IdExpediente, SE.FechaMovimiento,
                       ROW_NUMBER() OVER(ORDER BY SE.FechaMovimiento DESC)
                FROM
                (
                    SELECT E.IdExpediente,
                           MAX(CONVERT(DATETIME, EDOD.FechaDestinoEnvia + ' ' + EDOD.HoraDestinoEnvia)) AS FechaMovimiento
                    FROM Tramite.Expediente E
                        INNER JOIN Tramite.ExpedienteDocumento ED
                            ON E.IdExpediente = ED.IdExpediente AND ED.EstadoAuditoria = E.EstadoAuditoria
                        INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO
                            ON EDO.IdExpedienteDocumento = ED.IdExpedienteDocumento AND EDO.EstadoAuditoria = E.EstadoAuditoria
                        INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD
                            ON EDOD.IdExpedienteDocumentoOrigen = EDO.IdExpedienteDocumentoOrigen AND EDOD.EstadoAuditoria = E.EstadoAuditoria
                    WHERE E.EstadoAuditoria = 1
                      AND E.ExpedienteAnulado = 0
                      AND EDOD.IdPersonaDestino = @pIdPersona
                      AND EDOD.IdAreaDestino    = @vIdArea
                      AND EDOD.IdCargoDestino   = @vIdCargo
                      AND EDOD.IdEmpresaDestino = @vIdEmpresa
                      AND ED.FgEnEsperaFirmaDigital = 0
                      AND EDOD.IdCatalogoSituacionMovimientoDestino = @pIdCatalogoSituacionMovimientoDestino
                      AND EDOD.FechaDestino BETWEEN CASE WHEN @pConFiltroFecha = 1 THEN @pFechaInicio ELSE EDOD.FechaDestino END
                                                AND CASE WHEN @pConFiltroFecha = 1 THEN @pFechaFin    ELSE EDOD.FechaDestino END
                      AND E.NumeroExpediente = @pBusquedaGeneral
                    GROUP BY E.IdExpediente
                ) SE
                OPTION (MAXDOP 2);
            END
            ELSE
            BEGIN
                INSERT INTO #vTablaExpediente(IdExpediente, FechaMovimiento, eNroOrden)
                SELECT SE.IdExpediente, SE.FechaMovimiento,
                       ROW_NUMBER() OVER(ORDER BY SE.FechaMovimiento DESC)
                FROM
                (
                    SELECT E.IdExpediente,
                           MAX(CONVERT(DATETIME, EDOD.FechaDestinoEnvia + ' ' + EDOD.HoraDestinoEnvia)) AS FechaMovimiento
                    FROM Tramite.Expediente E
                        INNER JOIN Tramite.ExpedienteDocumento ED
                            ON E.IdExpediente = ED.IdExpediente AND ED.EstadoAuditoria = E.EstadoAuditoria
                        INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO
                            ON EDO.IdExpedienteDocumento = ED.IdExpedienteDocumento AND EDO.EstadoAuditoria = E.EstadoAuditoria
                        INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD
                            ON EDOD.IdExpedienteDocumentoOrigen = EDO.IdExpedienteDocumentoOrigen AND EDOD.EstadoAuditoria = E.EstadoAuditoria
                    WHERE E.EstadoAuditoria = 1
                      AND E.ExpedienteAnulado = 0
                      AND EDOD.IdPersonaDestino = @pIdPersona
                      AND EDOD.IdAreaDestino    = @vIdArea
                      AND EDOD.IdCargoDestino   = @vIdCargo
                      AND EDOD.IdEmpresaDestino = @vIdEmpresa
                      AND ED.FgEnEsperaFirmaDigital = 0
                      AND EDOD.IdCatalogoSituacionMovimientoDestino = @pIdCatalogoSituacionMovimientoDestino
                      AND EDOD.FechaDestino BETWEEN CASE WHEN @pConFiltroFecha = 1 THEN @pFechaInicio ELSE EDOD.FechaDestino END
                                                AND CASE WHEN @pConFiltroFecha = 1 THEN @pFechaFin    ELSE EDOD.FechaDestino END
                    GROUP BY E.IdExpediente
                ) SE
                OPTION (MAXDOP 2);
            END
        END


        /*--- Paginacion (sin cambios) --------------------------------------------------------*/
        SET @iRegistroTotal = (SELECT COUNT(1) FROM #vTablaExpediente);

        SELECT @iPaginaRegInicio = c.iStartRow,
               @iPaginaRegFinal  = c.iEndrow
        FROM General.fnObtenerPaginacion(@pDimensionPagina, @pNumeroPagina, @iRegistroTotal) c;

        /*------------------------------------------------------------------------------------
          [2] MATERIALIZAR SOLO LA PAGINA (25-50 filas). Driver fisico y acotado del enriquecimiento.
              Los 3 campos derivados de documento se rellenaran despues (defaults conservan el
              COALESCE del original: '' y 0).
        ------------------------------------------------------------------------------------*/
        CREATE TABLE #Pagina
        (
            IdExpediente          BIGINT       NOT NULL PRIMARY KEY,
            eNroOrden             INT          NOT NULL,
            FechaMovimiento       DATETIME     NULL,
            NumeroDocumento       VARCHAR(4000) NOT NULL DEFAULT(''),
            IdExpedienteDocumento INT          NOT NULL DEFAULT(0),
            DiasPendiente         INT          NOT NULL DEFAULT(0)
        );

        INSERT INTO #Pagina(IdExpediente, eNroOrden, FechaMovimiento)
        SELECT EX.IdExpediente, EX.eNroOrden, EX.FechaMovimiento
        FROM #vTablaExpediente EX
        WHERE EX.eNroOrden BETWEEN @iPaginaRegInicio AND @iPaginaRegFinal;

        /*------------------------------------------------------------------------------------
          [3] ENRIQUECIMIENTO DE DOCUMENTO (Numero + Id + Dias)
              Camino caliente Destino (@pSit IN 4,5,112): UNA sola pasada set-based sobre la
              pagina. Reemplaza 3 recorridos escalares por fila con 1 recorrido por pagina.
        ------------------------------------------------------------------------------------*/
        IF @pIdCatalogoSituacionMovimientoDestino IN (4, 5, 112)
        BEGIN
            ;WITH DocDestino AS
            (
                SELECT
                    ED.IdExpediente,
                    ED.IdExpedienteDocumento,
                    ED.RutaArchivoDocumento,
                    ED.Correlativo,
                    ED.NumeroDocumento              AS NumDoc,
                    CTD.Descripcion                 AS DescTipoDoc,
                    EDOD.MotivoArchivado,
                    EDOD.FechaDestinoRecepciona,
                    EDO.FechaOrigen,
                    rn = ROW_NUMBER() OVER (PARTITION BY ED.IdExpediente
                                            ORDER BY EDOD.IdExpedienteDocumentoOrigenDestino DESC)
                FROM #Pagina P
                    INNER JOIN Tramite.ExpedienteDocumento ED
                        ON ED.IdExpediente = P.IdExpediente AND ED.EstadoAuditoria = 1
                    INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO
                        ON EDO.IdExpedienteDocumento = ED.IdExpedienteDocumento AND EDO.EstadoAuditoria = 1
                    INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD
                        ON EDOD.IdExpedienteDocumentoOrigen = EDO.IdExpedienteDocumentoOrigen AND EDOD.EstadoAuditoria = 1
                    LEFT JOIN Tramite.Catalogo CTD
                        ON CTD.IdCatalogo = ED.IdCatalogoTipoDocumento
                WHERE EDOD.IdAreaDestino    = @vIdArea
                  AND EDOD.IdCargoDestino   = @vIdCargo
                  AND EDOD.IdPersonaDestino = @pIdPersona
                  AND EDOD.IdEmpresaDestino = @vIdEmpresa   -- exigido por Dias; no-op practico para Num/Id
                  AND EDOD.IdCatalogoSituacionMovimientoDestino = @pIdCatalogoSituacionMovimientoDestino
            )
            UPDATE P
               SET P.NumeroDocumento =
                       '<button type="button" data-toggle="tooltip" title="' + COALESCE(D.MotivoArchivado,'') +
                       '" class="btn ui blue label" onclick="MostrarDocumentoPdfExp(''' + D.RutaArchivoDocumento + ''',' +
                       CONVERT(VARCHAR, D.IdExpedienteDocumento) +
                       ')"><i style="font-size:16px;" class="fa fa-file-text"></i></button>' +
                       '<label style="font-size:8px">' +
                       CASE WHEN D.Correlativo = 0 THEN CONCAT(D.DescTipoDoc, ' ', COALESCE(D.NumDoc,''))
                            ELSE COALESCE(D.NumDoc,'') END +
                       '</label>',
                   P.IdExpedienteDocumento = D.IdExpedienteDocumento,
                   P.DiasPendiente =
                       CASE
                           WHEN @pIdCatalogoSituacionMovimientoDestino = 4 THEN
                                CASE WHEN COALESCE(D.FechaDestinoRecepciona,'') = ''
                                     THEN CASE WHEN DATEDIFF(DAY, CONVERT(DATE, D.FechaOrigen), GETDATE()) < 0 THEN 0
                                               ELSE DATEDIFF(DAY, CONVERT(DATE, D.FechaOrigen), GETDATE()) END
                                     ELSE 0 END
                           WHEN @pIdCatalogoSituacionMovimientoDestino = 5 THEN
                                CASE WHEN COALESCE(D.FechaDestinoRecepciona,'') <> ''
                                     THEN DATEDIFF(DAY, CONVERT(DATE, D.FechaDestinoRecepciona), GETDATE())
                                     ELSE 0 END
                           ELSE 0
                       END
            FROM #Pagina P
                INNER JOIN DocDestino D ON D.IdExpediente = P.IdExpediente AND D.rn = 1;
        END
        ELSE
        BEGIN
            /*--------------------------------------------------------------------------------
              Ramas raras (@pSit IN 111,3,6,116 y cualquier otro): se reutilizan los escalares
              EXISTENTES, pero SOLO sobre la pagina (25-50 filas). Mismo costo y mismo resultado
              exacto que el original para estos casos -> riesgo de regresion = 0.
              (La cadena "Anterior" de la rama 111/3/6 es dificil de reescribir fielmente en set;
               se prefiere fidelidad total sobre un microajuste de un camino poco frecuente.)
            --------------------------------------------------------------------------------*/
            UPDATE P
               SET P.NumeroDocumento       = Tramite.funObtenerNumeroDocumentoEnExpedienteEspecialistaV1
                                             (P.IdExpediente, @vIdArea, @vIdCargo, @pIdPersona, @pIdCatalogoSituacionMovimientoDestino),
                   P.IdExpedienteDocumento = Tramite.funObtenerIdExpedienteDocumentoEnExpedienteEspecialista
                                             (P.IdExpediente, @vIdArea, @vIdCargo, @pIdPersona, @pIdCatalogoSituacionMovimientoDestino),
                   P.DiasPendiente         = Tramite.funObtenerDiasPendienteEspecislista
                                             (P.IdExpediente, @pIdPersona, @vIdEmpresa, @vIdArea, @vIdCargo, @pIdCatalogoSituacionMovimientoDestino)
            FROM #Pagina P;
        END

        /*------------------------------------------------------------------------------------
          [4] PROYECCION FINAL. Se lee lo derivado desde #Pagina. Los 4 lookups triviales de un
              solo seek (EsParaAnular, Enlazados, EsPrincipal, OrigenInicial) y la Foto se resuelven
              SOLO sobre la pagina: baratos, y candidatos a Scalar UDF Inlining (Froid) en 2019+.
              No hay ningun OUTER APPLY apilado sobre las tablas grandes; imposible sobre-evaluar.
        ------------------------------------------------------------------------------------*/
        SELECT
            Tramite.funParaAnularEspecialista(E.IdExpediente, @pIdPersona, @vIdEmpresa, @vIdArea, @vIdCargo) AS EsParaAnular,
            P.DiasPendiente                                                                                 AS DiasPendiente,
            ''                                                                                              AS NombrePersonaOrigen,
            P.NumeroDocumento                                                                               AS NumeroDocumento,
            P.IdExpedienteDocumento                                                                         AS IdExpedienteDocumento,
            Tramite.funObtenerExpedientesEnlazados(E.IdExpediente)                                          AS NombreExpedientesEnlazados,
            Tramite.funEsPrincipalEnlace(E.IdExpediente)                                                    AS EsPrincipalEnlace,
            Tramite.fnObtenerOrigenInicialDocumento(E.IdExpediente)                                         AS CatalogoTipoOrigen,
            E.IdExpediente,
            E.ExpedienteConfidencial,
            E.NTFechaExpediente,
            E.HoraExpediente,
            E.IdCatalogoTipoPrioridad,
            CTP.Descripcion                                                                                 AS CatalogoTipoPrioridad,
            COALESCE(CTT.Descripcion, '')                                                                   AS CatalogoTipoTramite,
            COALESCE(CTT.Detalle, '')                                                                       AS ColorCatalogoTipoTramite,
            US.Logueo,
            CASE WHEN COALESCE(SFU.RutaArchivoFoto, '') = ''
                 THEN CASE WHEN COALESCE(PE.Sexo, 0) = 0 THEN 'sinfotoH.jpg' ELSE 'sinfotoM.jpg' END
                 ELSE SFU.RutaArchivoFoto END                                                               AS RutaFotoPersona,
            E.AsuntoExpediente,
            E.NumeroFoliosExpediente,
            COALESCE(E.ObservacionesExpediente, '')                                                         AS ObservacionesExpediente,
            CONCAT(E.NTFechaExpediente, ' ', E.HoraExpediente)                                              AS Fecha,
            E.NombreExpediente,
            CASE WHEN COALESCE(E.NombreCompletoCreador, '') <> '' THEN COALESCE(E.NombreCompletoCreador, '')
                 ELSE PE.NombreCompleto END                                                                 AS NombreCompletoCreador,
            E.NumeroExpediente,
            COALESCE(ES.IdExpedienteSeguimiento, 0)                                                         AS IdExpedienteSeguimiento,
            P.FechaMovimiento
        FROM #Pagina P
            INNER JOIN Tramite.Expediente E
                ON E.IdExpediente = P.IdExpediente
            INNER JOIN Seguridad.Usuario US
                ON US.IdUsuario = E.IdUsuarioCreacionAuditoria
            INNER JOIN Tramite.Catalogo CTP
                ON CTP.IdCatalogo = E.IdCatalogoTipoPrioridad
            INNER JOIN Tramite.Catalogo CTT
                ON CTT.IdCatalogo = E.IdCatalogoTipoTramite
            LEFT JOIN General.Persona PE
                ON PE.IdPersona = E.IdPersonaCreador
            LEFT JOIN Tramite.ExpedienteSeguimiento ES
                ON ES.IdExpediente = E.IdExpediente
               AND ES.EstadoAuditoria = 1
               AND ES.IdEmpresa = @vIdEmpresa
               AND ES.IdCargo   = @vIdCargo
               AND ES.IdPersona = @pIdPersona
               AND ES.IdArea    = @vIdArea
            OUTER APPLY
            (
                SELECT TOP 1 FU.RutaArchivoFoto
                FROM Seguridad.Usuario FU
                WHERE FU.IdPersona = PE.IdPersona AND FU.EstadoAuditoria = 1 AND FU.Bloqueado = 0
                ORDER BY FU.RutaArchivoFoto DESC
            ) SFU
        ORDER BY P.eNroOrden ASC;

        SELECT @iRegistroTotal;

    END TRY
    BEGIN CATCH
        DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT, @ERROR_STATE INT, @ERROR_LINE INT,
                @ERROR_PROCEDURE VARCHAR(MAX), @ERROR_MESSAGE VARCHAR(MAX);
        SELECT @ERROR_NUMBER    = ERROR_NUMBER(),
               @ERROR_SEVERITY  = ERROR_SEVERITY(),
               @ERROR_STATE     = ERROR_STATE(),
               @ERROR_PROCEDURE = 'Tramite.paListarExpedientePendienteEspecialistaV7_new',
               @ERROR_LINE      = ERROR_LINE(),
               @ERROR_MESSAGE   = ERROR_MESSAGE();
        EXEC Seguridad.paGuardarErroresEnTablaLog
             @ERROR_NUMBER, @ERROR_SEVERITY, @ERROR_STATE, @ERROR_PROCEDURE, @ERROR_LINE, @ERROR_MESSAGE, @pIdUsuarioAuditoria;
    END CATCH
END;
GO




-- set statistics io on
-- set statistics time on


exec tramite.paListarExpedientePendienteEspecialistaV7_new
0,'10/03/2026','10/03/2026',0,'10/03/2026','10/03/2026',1309,3158,3,4,0,0,2026,0,0,0,'','','','',0,'','','',26766,NULL,NULL,2,100,NULL,0


-- set statistics io off
-- set statistics time off


-- exec tramite.paListarExpedientePendienteEspecialistaV7
-- 0,'10/03/2026','10/03/2026',0,'10/03/2026','10/03/2026',1309,3158,3,4,0,0,2026,0,0,0,'','','','',0,'','','',26766,NULL,NULL,2,100,NULL,0
