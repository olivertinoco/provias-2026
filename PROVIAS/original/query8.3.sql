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
    SET NOCOUNT ON;
    BEGIN TRY

        DECLARE @vIdCargo int = 0, @vIdArea int = 0, @vIdEmpresa int = 0,
                @iRegistroTotal Int, @iPaginaRegInicio Int, @iPaginaRegFinal Int;

        SELECT @vIdCargo   = EP.IdCargo,
               @vIdArea    = EP.IdArea,
               @vIdEmpresa = ES.IdEmpresa
        FROM RecursoHumano.EmpleadoPerfil EP WITH (NOLOCK)
            INNER JOIN General.EmpresaSede ES WITH (NOLOCK) ON ES.IdEmpresaSede = EP.IdEmpresaSede
        WHERE EP.IdEmpleadoPerfil = @pIdEmpleadoPerfil
          AND EP.EstadoAuditoria = 1
          AND EP.Activo = 1;

        CREATE TABLE #vTablaExpediente(IdExpediente BigInt, FechaMovimiento DATETIME, eNroOrden Int);

        /*------------------------------------------------------------------------------
          Carga de la pagina de expedientes (misma logica original; CONVERT con estilo
          103 para hacer determinista dd/mm/yyyy sin depender de SET LANGUAGE).
        ------------------------------------------------------------------------------*/
        IF (ISNUMERIC(@pBusquedaGeneral) = 1 AND CAST(@pBusquedaGeneral AS VARCHAR(5)) NOT LIKE '%.%')
            OR ISNULL(@pBusquedaGeneral, '') = ''
        BEGIN
            IF ISNULL(@pBusquedaGeneral, '') <> ''
            BEGIN
                INSERT INTO #vTablaExpediente(IdExpediente, FechaMovimiento, eNroOrden)
                SELECT
                    SE.IdExpediente,
                    SE.FechaMovimiento,
                    ROW_NUMBER() OVER(ORDER BY SE.FechaMovimiento DESC) AS eNroOrden
                FROM
                (
                    SELECT E.IdExpediente,
                           MAX(CONVERT(DATETIME, EDOD.FechaDestinoEnvia + ' ' + EDOD.HoraDestinoEnvia, 103)) AS FechaMovimiento
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
                      AND EDOD.IdAreaDestino = @vIdArea
                      AND EDOD.IdCargoDestino = @vIdCargo
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
                SELECT
                    SE.IdExpediente,
                    SE.FechaMovimiento,
                    ROW_NUMBER() OVER(ORDER BY SE.FechaMovimiento DESC) AS eNroOrden
                FROM
                (
                    SELECT E.IdExpediente,
                           MAX(CONVERT(DATETIME, EDOD.FechaDestinoEnvia + ' ' + EDOD.HoraDestinoEnvia, 103)) AS FechaMovimiento
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
                      AND EDOD.IdAreaDestino = @vIdArea
                      AND EDOD.IdCargoDestino = @vIdCargo
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

        /*--- Paginacion ---------------------------------------------------------------*/
        SET @iRegistroTotal = (SELECT COUNT(1) FROM #vTablaExpediente);

        SELECT @iPaginaRegInicio = c.iStartRow,
               @iPaginaRegFinal  = c.iEndrow
        FROM General.fnObtenerPaginacion(@pDimensionPagina, @pNumeroPagina, @iRegistroTotal) c;

        /*------------------------------------------------------------------------------
          Proyeccion final. Los 7 escalares se reemplazan por OUTER APPLY a Inline TVFs.
          Se aplican SOLO sobre la pagina (25-50 filas), no sobre todo el universo.
        ------------------------------------------------------------------------------*/
        SELECT
            para.EsParaAnular                              AS EsParaAnular,
            dias.DiasPendiente                             AS DiasPendiente,
            ''                                             AS NombrePersonaOrigen,
            COALESCE(ndoc.NumeroDocumento, '')             AS NumeroDocumento,
            COALESCE(iddoc.IdExpedienteDocumento, 0)       AS IdExpedienteDocumento,
            enl.Lista                                      AS NombreExpedientesEnlazados,
            prin.EsPrincipalEnlace                         AS EsPrincipalEnlace,
            COALESCE(orig.CatalogoTipoOrigen, '')          AS CatalogoTipoOrigen,
            E.IdExpediente,
            E.ExpedienteConfidencial,
            E.NTFechaExpediente,
            E.HoraExpediente,
            E.IdCatalogoTipoPrioridad,
            CTP.Descripcion                                AS CatalogoTipoPrioridad,
            COALESCE(CTT.Descripcion, '')                  AS CatalogoTipoTramite,
            COALESCE(CTT.Detalle, '')                      AS ColorCatalogoTipoTramite,
            US.Logueo,
            CASE WHEN COALESCE(SFU.RutaArchivoFoto, '') = ''
                 THEN CASE WHEN COALESCE(PE.Sexo, 0) = 0 THEN 'sinfotoH.jpg' ELSE 'sinfotoM.jpg' END
                 ELSE SFU.RutaArchivoFoto END              AS RutaFotoPersona,
            E.AsuntoExpediente,
            E.NumeroFoliosExpediente,
            COALESCE(E.ObservacionesExpediente, '')        AS ObservacionesExpediente,
            CONCAT(E.NTFechaExpediente, ' ', E.HoraExpediente) AS Fecha,
            E.NombreExpediente,
            CASE WHEN COALESCE(E.NombreCompletoCreador, '') <> ''
                 THEN COALESCE(E.NombreCompletoCreador, '')
                 ELSE PE.NombreCompleto END                AS NombreCompletoCreador,
            E.NumeroExpediente,
            COALESCE(ES.IdExpedienteSeguimiento, 0)        AS IdExpedienteSeguimiento,
            EX.FechaMovimiento
        FROM Tramite.Expediente E WITH (NOLOCK)
            INNER JOIN #vTablaExpediente EX
                ON EX.IdExpediente = E.IdExpediente
            INNER JOIN Seguridad.Usuario US
                ON US.IdUsuario = E.IdUsuarioCreacionAuditoria
            INNER JOIN Tramite.Catalogo CTP
                ON CTP.IdCatalogo = E.IdCatalogoTipoPrioridad
            INNER JOIN Tramite.Catalogo CTT
                ON CTT.IdCatalogo = E.IdCatalogoTipoTramite
            LEFT JOIN General.Persona PE
                ON PE.IdPersona = E.IdPersonaCreador
            LEFT JOIN Tramite.ExpedienteSeguimiento ES WITH (NOLOCK)
                ON ES.IdExpediente = E.IdExpediente
               AND ES.EstadoAuditoria = 1
               AND ES.IdEmpresa = @vIdEmpresa
               AND ES.IdCargo = @vIdCargo
               AND ES.IdPersona = @pIdPersona
               AND ES.IdArea = @vIdArea
            OUTER APPLY
            (
                SELECT TOP 1 FU.RutaArchivoFoto
                FROM Seguridad.Usuario FU
                WHERE FU.IdPersona = PE.IdPersona AND FU.EstadoAuditoria = 1 AND FU.Bloqueado = 0
                ORDER BY FU.RutaArchivoFoto DESC
            ) SFU
            /*--- Reemplazo de las 7 UDFs escalares por Inline TVFs -----------------*/
            OUTER APPLY Tramite.tvfParaAnularEspecialista
                        (E.IdExpediente, @pIdPersona, @vIdEmpresa, @vIdArea, @vIdCargo) para
            OUTER APPLY Tramite.tvfDiasPendienteEspecialista
                        (E.IdExpediente, @pIdPersona, @vIdEmpresa, @vIdArea, @vIdCargo, @pIdCatalogoSituacionMovimientoDestino) dias
            OUTER APPLY Tramite.tvfNumeroDocumentoEspecialista
                        (E.IdExpediente, @vIdArea, @vIdCargo, @pIdPersona, @pIdCatalogoSituacionMovimientoDestino) ndoc
            OUTER APPLY Tramite.tvfIdExpedienteDocumentoEspecialista
                        (E.IdExpediente, @vIdArea, @vIdCargo, @pIdPersona, @pIdCatalogoSituacionMovimientoDestino) iddoc
            OUTER APPLY Tramite.tvfExpedientesEnlazados
                        (E.IdExpediente) enl
            OUTER APPLY Tramite.tvfEsPrincipalEnlace
                        (E.IdExpediente) prin
            OUTER APPLY Tramite.tvfOrigenInicialDocumento
                        (E.IdExpediente) orig
        WHERE EX.eNroOrden BETWEEN @iPaginaRegInicio AND @iPaginaRegFinal
        ORDER BY EX.eNroOrden ASC;

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



set statistics io on
set statistics time on


exec tramite.paListarExpedientePendienteEspecialistaV7_new
0,'10/03/2026','10/03/2026',0,'10/03/2026','10/03/2026',1309,3158,3,4,0,0,2026,0,0,0,'','','','',0,'','','',26766,NULL,NULL,2,100,NULL,0


set statistics io off
set statistics time off


-- exec tramite.paListarExpedientePendienteEspecialistaV7
-- 0,'10/03/2026','10/03/2026',0,'10/03/2026','10/03/2026',1309,3158,3,4,0,0,2026,0,0,0,'','','','',0,'','','',26766,NULL,NULL,2,100,NULL,0
