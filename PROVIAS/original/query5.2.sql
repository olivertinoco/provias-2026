
-- CREATE OR ALTER PROCEDURE [Tramite].[paListarExpedientePendienteJefaturaPorRecibirFosCad]
declare
    @pConFiltroFecha bit,
    @pFechaInicio varchar(10),
    @pFechaFin varchar(10),
    @pConFiltroFechaMovimiento bit,
    @pFechaInicioMovimiento varchar(10),
    @pFechaFinMovimiento varchar(10),
    @pIdArea int,
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
    @pFlgBusqueda int
-- AS
-- BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    -- BEGIN TRY

    select
        @pConFiltroFecha=0,
        @pFechaInicio='15/04/2026',
        @pFechaFin='15/04/2026',
        @pConFiltroFechaMovimiento=0,
        @pFechaInicioMovimiento='15/04/2026',
        @pFechaFinMovimiento='15/04/2026',
        @pIdArea=30,
        @pIdCatalogoSituacionMovimientoDestino=4,
        @pTipoSituacionMovimiento=4,
        @pIdAreaOrigen=0,
        @pIdAreaDestino=0,
        @pIdPeriodo=0,
        @pIdCatalogoTipoPrioridad=0,
        @pIdCatalogoTipoTramite=0,
        @pIdCatalogoTipoDocumento=0,
        @pNumeroExpediente='',
        @pNumeroDocumento='',
        @pPersonaDesde='',
        @pPersonaPara='',
        @pIdTipoIngreso=0,
        @pFechaDocumento='',
        @pEmisorExpediente='',
        @pAsuntoExpediente='',
        @pIdUsuarioAuditoria=52939,
        @pCampoOrdenado=NULL,
        @pTipoOrdenacion=NULL,
        @pNumeroPagina=1,
        @pDimensionPagina=10,
        @pBusquedaGeneral=NULL,
        @pFlgBusqueda=0

        DECLARE @vIdAreaJefe int = 0, @vIdEmpresaJefe int = 0;

        IF @pIdPeriodo = 0
            SET @pIdPeriodo = YEAR(GETDATE());

        SELECT TOP 1
               @vIdAreaJefe    = IdArea,
               @vIdEmpresaJefe = IdEmpresa
        FROM RecursoHumano.visPersonaJefe
        WHERE IdArea = @pIdArea;

        CREATE TABLE #Expediente(
            IdExpediente          int          NOT NULL,
            FechaMovimiento       datetime     NULL,
            EsParaAnular          int          NOT NULL,
            DiasPendiente         int          NULL,
            NombrePersonaOrigen   varchar(max) NULL,
            NumeroDocumento       varchar(max) NULL,
            IdExpedienteDocumento int          NULL
        );

        IF TRY_CONVERT(int, @pBusquedaGeneral) IS NOT NULL
           OR @pBusquedaGeneral IS NULL
           OR @pBusquedaGeneral = ''
        BEGIN
            ;WITH Cargo_CTE AS
            (
                SELECT IdCargo
                FROM General.Cargo
                WHERE IdCatalogoTipoCargo IN (32,33,34)
            )
            INSERT INTO #Expediente
                (IdExpediente, FechaMovimiento, EsParaAnular, DiasPendiente,
                 NombrePersonaOrigen, NumeroDocumento, IdExpedienteDocumento)
            SELECT
                E.IdExpediente,
                MAX(CONVERT(datetime, EDOD.FechaDestino + ' ' + EDOD.HoraDestino))                                   AS FechaMovimiento,
                0                                                                                                    AS EsParaAnular,
                MAX(CASE WHEN COALESCE(EDOD.FechaDestinoRecepciona,'') = '' THEN
                         CASE WHEN DATEDIFF(DAY, CONVERT(date, EDO.FechaOrigen), GETDATE()) <= 0 THEN 0
                              ELSE DATEDIFF(DAY, CONVERT(date, EDOD.FechaDestino), GETDATE()) END
                         ELSE 0 END)                                                                                 AS DiasPendiente,
                MAX(CASE WHEN COALESCE(EDO.IdempresaOrigen,0) = 0 THEN ED.NombreCompletoEmisor ELSE A.NombreArea END) AS NombrePersonaOrigen,
                MAX('<button type="button" data-toggle="tooltip" title="'+COALESCE(EDOD.MotivoArchivado,'')+
                    '" class="btn ui blue label" onclick="MostrarDocumentoPdfExp('''+ED.RutaArchivoDocumento+''','+CONVERT(varchar,ED.IdExpedienteDocumento)+
                    ')"><i style="font-size:16px;" class="fa fa-file-text"></i></button><label style="font-size:10px;line-height:13px;padding-top:6px;">'+
                    CASE WHEN ED.Correlativo = 0 THEN CONCAT(CTD.Descripcion,' ',COALESCE(ED.NumeroDocumento,''))
                         ELSE COALESCE(ED.NumeroDocumento,'') END+'</label>')                                        AS NumeroDocumento,
                MAX(ED.IdExpedienteDocumento)                                                                        AS IdExpedienteDocumento
            FROM Tramite.ExpedienteDocumentoOrigenDestino EDOD
            INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO
                    ON EDO.IdExpedienteDocumentoOrigen = EDOD.IdExpedienteDocumentoOrigen
                   AND EDO.EstadoAuditoria = 1
            INNER JOIN Tramite.ExpedienteDocumento ED
                    ON ED.IdExpedienteDocumento = EDO.IdExpedienteDocumento
                   AND ED.EstadoAuditoria = 1
                   AND ED.FgEnEsperaFirmaDigital = 0
            INNER JOIN Tramite.Expediente E
                    ON E.IdExpediente = ED.IdExpediente
                   AND E.EstadoAuditoria = 1
                   AND (E.ExpedienteAnulado = 0 OR E.ExpedienteAnulado IS NULL)
            INNER JOIN Tramite.SerieDocumentalExpediente SD
                    ON SD.IdSerieDocumentalExpediente = E.IdSerieDocumentalExpediente
            LEFT JOIN General.Area A
                    ON A.IdArea = EDO.IdAreaOrigen
            LEFT JOIN Tramite.Catalogo CTD
                    ON CTD.IdCatalogo = ED.IdCatalogoTipoDocumento
            WHERE EDOD.IdCatalogoSituacionMovimientoDestino = 4
              AND EDOD.IdEmpresaDestino = @vIdEmpresaJefe
              AND EDOD.IdAreaDestino    = @vIdAreaJefe
              AND EDOD.EstadoAuditoria  = 1
              AND EDOD.IdCargoDestino IN (SELECT IdCargo FROM Cargo_CTE)
              AND (E.NumeroExpediente = @pBusquedaGeneral OR @pBusquedaGeneral IS NULL OR @pBusquedaGeneral = 0)
            GROUP BY E.IdExpediente
            OPTION (RECOMPILE);
        END

        CREATE CLUSTERED INDEX IX_Exp_Orden ON #Expediente (FechaMovimiento DESC, IdExpediente);

        DECLARE @vTotal int = (SELECT COUNT(*) FROM #Expediente);

        CREATE TABLE #Pagina(
            Secuencia             int IDENTITY(1,1) PRIMARY KEY,
            IdExpediente          int          NOT NULL,
            FechaMovimiento       datetime     NULL,
            EsParaAnular          int          NOT NULL,
            DiasPendiente         int          NULL,
            NombrePersonaOrigen   varchar(max) NULL,
            NumeroDocumento       varchar(max) NULL,
            IdExpedienteDocumento int          NULL
        );

        INSERT INTO #Pagina
            (IdExpediente, FechaMovimiento, EsParaAnular, DiasPendiente,
             NombrePersonaOrigen, NumeroDocumento, IdExpedienteDocumento)
        SELECT IdExpediente, FechaMovimiento, EsParaAnular, DiasPendiente,
               NombrePersonaOrigen, NumeroDocumento, IdExpedienteDocumento
        FROM #Expediente
        ORDER BY FechaMovimiento DESC, IdExpediente
        OFFSET (@pNumeroPagina - 1) * @pDimensionPagina ROWS
        FETCH NEXT @pDimensionPagina ROWS ONLY;

        SELECT
            CONVERT(varchar, @vTotal) + '¦' +
            ISNULL(STUFF((
                SELECT
                    '¬' + CONVERT(varchar, P.EsParaAnular),
                    '|' + CONVERT(varchar, P.DiasPendiente),
                    '|' + P.NombrePersonaOrigen,
                    '|' + REPLACE(P.NumeroDocumento, '|', ''),
                    '|' + CONVERT(varchar, P.IdExpedienteDocumento),
                    '|' + CASE WHEN ENP.ExEnlazadoPri <> '' THEN ENP.ExEnlazadoPri ELSE ENS.ExEnlazadoSec END,
                    '|' + CASE WHEN EE.cantEnlaces > 0 THEN '1' ELSE '0' END,
                    '|' + OID.CatalogoTipoOrigen,
                    '|' + CONVERT(varchar, E.IdExpediente),
                    '|' + CONVERT(varchar, E.ExpedienteConfidencial),
                    '|' + E.NTFechaExpediente,
                    '|' + E.HoraExpediente,
                    '|' + CONVERT(varchar, E.IdCatalogoTipoPrioridad),
                    '|' + COALESCE(CTP.Descripcion, ''),
                    '|' + COALESCE(CTT.Descripcion, ''),
                    '|' + COALESCE(CTT.Detalle, ''),
                    '|' + US.Logueo,
                    '|' + COALESCE(FT.RutaFoto, 'sinfotoH.jpg'),
                    '|' + UPPER(REPLACE(E.AsuntoExpediente, '|', ' ')),
                    '|' + CONVERT(varchar, COALESCE(E.NumeroFoliosExpediente, 0)),
                    '|' + COALESCE(REPLACE(E.ObservacionesExpediente, '|', ' '), ''),
                    '|' + CONCAT(E.NTFechaExpediente, ' ', E.HoraExpediente),
                    '|' + CONCAT(SD.AbreviaturaSerieDocumentalExpediente + RIGHT('000000' + CONVERT(varchar, E.NumeroExpediente), 6), '-', E.IdPeriodo),
                    '|' + CASE WHEN COALESCE(E.NombreCompletoCreador, '') <> '' THEN COALESCE(E.NombreCompletoCreador, '') ELSE PE.NombreCompleto END,
                    '|' + CONVERT(varchar, E.NumeroExpediente),
                    '|' + CONVERT(varchar, COALESCE(ES.IdExpedienteSeguimiento, 0)),
                    '|' + ISNULL(FORMAT(P.FechaMovimiento, 'dd/MM/yyyy HH:mm'), '')
                FROM #Pagina P
                INNER JOIN Tramite.Expediente E
                        ON E.IdExpediente = P.IdExpediente
                       AND E.EstadoAuditoria = 1
                       AND (E.ExpedienteAnulado = 0 OR E.ExpedienteAnulado IS NULL)
                INNER JOIN Seguridad.Usuario US
                        ON US.IdUsuario = E.IdUsuarioCreacionAuditoria
                INNER JOIN Tramite.SerieDocumentalExpediente SD
                        ON SD.IdSerieDocumentalExpediente = E.IdSerieDocumentalExpediente
                INNER JOIN Tramite.Catalogo CTP
                        ON CTP.IdCatalogo = E.IdCatalogoTipoPrioridad
                LEFT JOIN Tramite.ExpedienteSeguimiento ES
                        ON ES.IdExpediente = E.IdExpediente
                       AND ES.EstadoAuditoria = 1
                       AND ES.IdCargo = 0 AND ES.IdPersona = 0
                       AND ES.IdArea = @pIdArea
                LEFT JOIN General.Persona PE
                        ON PE.IdPersona = E.IdPersonaCreador
                LEFT JOIN Tramite.Catalogo CTT
                        ON CTT.IdCatalogo = E.IdCatalogoTipoTramite
                OUTER APPLY (
                    SELECT TOP 1 RutaFoto =
                    CASE WHEN COALESCE(U.RutaArchivoFoto,'') = ''
                    THEN CASE WHEN COALESCE(PR.Sexo,0) = 0 THEN 'sinfotoH.jpg' ELSE 'sinfotoM.jpg' END
                    ELSE U.RutaArchivoFoto END
                    FROM Seguridad.Usuario U
                    INNER JOIN General.Persona PR ON PR.IdPersona = U.IdPersona
                    WHERE U.EstadoAuditoria = 1 AND U.Bloqueado = 0 AND PR.IdPersona = E.IdPersonaCreador
                ) FT
                CROSS APPLY (
                    SELECT COUNT(EE.IdExpediente) AS cantEnlaces
                    FROM Tramite.ExpedienteEnlazado EE
                    INNER JOIN Tramite.Expediente ex
                            ON EE.IdExpedienteSecundario = ex.IdExpediente
                           AND ex.EstadoAuditoria = 1 AND ex.ExpedienteAnulado = 0
                    INNER JOIN Tramite.SerieDocumentalExpediente SD1
                            ON SD1.IdSerieDocumentalExpediente = ex.IdSerieDocumentalExpediente
                    WHERE EE.EstadoAuditoria = 1
                      AND EE.IdExpediente = E.IdExpediente
                ) EE
                CROSS APPLY (
                    SELECT TOP 1 CONCAT(COALESCE(c.Descripcion,''),' ',EX.NumeroExpedienteExterno) AS CatalogoTipoOrigen
                    FROM Tramite.ExpedienteDocumento ed1
                    INNER JOIN Tramite.Expediente EX ON EX.IdExpediente = ed1.IdExpediente
                    INNER JOIN Tramite.Catalogo c ON c.IdCatalogo = ed1.IdCatalogoTipoOrigen
                    WHERE ed1.EstadoAuditoria = 1
                      AND ed1.IdExpediente = E.IdExpediente
                    ORDER BY ed1.IdExpedienteDocumento
                ) OID
                CROSS APPLY (
                    SELECT ExEnlazadoPri = ISNULL((
                        SELECT STUFF((
                            SELECT DISTINCT '<div style="margin: 2px;padding: 2px;" class="ui blue label">'+
                                   CONCAT(SD1.AbreviaturaSerieDocumentalExpediente, RIGHT(CONCAT('000000', E1.NumeroExpediente),6), '-', E1.IdPeriodo)
                                   +'</div>'
                            FROM Tramite.ExpedienteEnlazado EE
                            INNER JOIN Tramite.Expediente e1
                                    ON EE.IdExpedienteSecundario = e1.IdExpediente
                                   AND e1.EstadoAuditoria = 1 AND e1.ExpedienteAnulado = 0
                            INNER JOIN Tramite.SerieDocumentalExpediente SD1
                                    ON SD1.IdSerieDocumentalExpediente = e1.IdSerieDocumentalExpediente
                            WHERE EE.EstadoAuditoria = 1
                              AND EE.IdExpediente = E.IdExpediente
                            FOR XML PATH('')), 1, 0, '')), '')
                ) ENP
                CROSS APPLY (
                    SELECT ExEnlazadoSec = ISNULL((
                        SELECT STUFF((
                            SELECT DISTINCT '<div style="margin: 2px;padding: 2px;" class="ui blue label">'+
                                   CONCAT(SD1.AbreviaturaSerieDocumentalExpediente, RIGHT(CONCAT('000000', E1.NumeroExpediente),6), '-', E1.IdPeriodo)
                                   +'</div>'
                            FROM Tramite.ExpedienteEnlazado EE
                            INNER JOIN Tramite.Expediente e1
                                    ON EE.IdExpediente = e1.IdExpediente
                                   AND e1.EstadoAuditoria = 1 AND e1.ExpedienteAnulado = 0
                            INNER JOIN Tramite.SerieDocumentalExpediente SD1
                                    ON SD1.IdSerieDocumentalExpediente = e1.IdSerieDocumentalExpediente
                            WHERE EE.EstadoAuditoria = 1
                              AND EE.IdExpedienteSecundario = E.IdExpediente
                            FOR XML PATH('')), 1, 0, '')), '')
                ) ENS
                ORDER BY P.Secuencia
                FOR XML PATH('')
            ), 1, 1, ''), '');

--     END TRY
--     BEGIN CATCH
--         DECLARE @ERROR_NUMBER int, @ERROR_SEVERITY int, @ERROR_STATE int, @ERROR_LINE int,
--                 @ERROR_PROCEDURE varchar(max), @ERROR_MESSAGE varchar(max);
--         SELECT @ERROR_NUMBER    = ERROR_NUMBER(),
--                @ERROR_SEVERITY  = ERROR_SEVERITY(),
--                @ERROR_STATE     = ERROR_STATE(),
--                @ERROR_PROCEDURE = 'Tramite.paListarExpedientePendienteJefaturaPorRecibirFosCad',
--                @ERROR_LINE      = ERROR_LINE(),
--                @ERROR_MESSAGE   = ERROR_MESSAGE();
--         EXEC Seguridad.paGuardarErroresEnTablaLog
--              @ERROR_NUMBER, @ERROR_SEVERITY, @ERROR_STATE, @ERROR_PROCEDURE, @ERROR_LINE, @ERROR_MESSAGE, @pIdUsuarioAuditoria;
--     END CATCH
-- END
