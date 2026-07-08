
-- func1: foto por persona ------------------------------------------------------------------
CREATE OR ALTER FUNCTION Seguridad.tvfRutaFotoPorIdPersona (@pIdPersona INT)
RETURNS TABLE
AS RETURN
(
    SELECT TOP (1)
        RutaFoto = CASE WHEN COALESCE(U.RutaArchivoFoto,'') = ''
                        THEN CASE WHEN COALESCE(PR.Sexo,0) = 0 THEN 'sinfotoH.jpg' ELSE 'sinfotoM.jpg' END
                        ELSE U.RutaArchivoFoto END
    FROM Seguridad.Usuario U
    INNER JOIN General.Persona PR ON PR.IdPersona = U.IdPersona
    WHERE U.EstadoAuditoria = 1 AND PR.IdPersona = @pIdPersona AND U.Bloqueado = 0
);
GO

-- func3: origen inicial del documento -------------------------------------------------------
CREATE OR ALTER FUNCTION Tramite.tvfOrigenInicialDocumento (@pIdExpediente INT)
RETURNS TABLE
AS RETURN
(
    SELECT TOP (1)
        CatalogoTipoOrigen = CONCAT(COALESCE(c.Descripcion,''),' ',EX.NumeroExpedienteExterno)
    FROM Tramite.ExpedienteDocumento e WITH (NOLOCK)
    INNER JOIN Tramite.Expediente EX WITH (NOLOCK) ON EX.IdExpediente = e.IdExpediente
    INNER JOIN Tramite.Catalogo c        ON c.IdCatalogo = e.IdCatalogoTipoOrigen
    WHERE e.EstadoAuditoria = 1 AND e.IdExpediente = @pIdExpediente
    ORDER BY e.IdExpedienteDocumento
);
GO

-- func7 / func2 combinados en util de anulacion --------------------------------------------
CREATE OR ALTER FUNCTION Tramite.tvfParaAnularEspecialista
(@pIdExpediente INT, @pIdPersona INT, @pIdEmpresa INT, @pIdArea INT, @pIdCargo INT)
RETURNS TABLE
AS RETURN
(
    SELECT EsParaAnular =
        CASE
            WHEN EXISTS
            (
                SELECT 1
                FROM Tramite.ExpedienteDocumento ED WITH (NOLOCK)
                INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
                    ON EDO.IdExpedienteDocumento = ED.IdExpedienteDocumento AND ED.EstadoAuditoria = 1
                INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
                    ON EDOD.IdExpedienteDocumentoOrigen = EDO.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria = 1
                WHERE ED.IdExpediente = @pIdExpediente AND EDOD.EsInicial = 1 AND ED.EsVinculado = 0
                  AND EDOD.IdCatalogoSituacionMovimientoDestino <> 4
                  AND EDOD.FechaDestinoRecepciona IS NULL
                  AND EDO.IdAreaOrigen = @pIdArea AND EDO.IdPersonaOrigen = @pIdPersona
                  AND EDO.IdCargoOrigen = @pIdCargo AND EDO.IdempresaOrigen = @pIdEmpresa
            ) THEN CAST(0 AS BIT)
            WHEN EXISTS
            (
                SELECT 1
                FROM Tramite.ExpedienteDocumento ED WITH (NOLOCK)
                INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
                    ON EDO.IdExpedienteDocumento = ED.IdExpedienteDocumento AND ED.EstadoAuditoria = 1
                INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
                    ON EDOD.IdExpedienteDocumentoOrigen = EDO.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria = 1
                WHERE ED.IdExpediente = @pIdExpediente AND EDOD.EsInicial = 1 AND ED.EsVinculado = 0
                  AND EDOD.FechaDestinoRecepciona IS NULL
                  AND EDO.IdAreaOrigen = @pIdArea AND EDO.IdPersonaOrigen = @pIdPersona
                  AND EDO.IdCargoOrigen = @pIdCargo AND EDO.IdempresaOrigen = @pIdEmpresa
            ) THEN CAST(1 AS BIT)
            ELSE CAST(0 AS BIT)
        END
);
GO

-- func6: expedientes enlazados (con fallback de direccion) ----------------------------------
CREATE OR ALTER FUNCTION Tramite.tvfExpedientesEnlazados (@pIdExpediente INT)
RETURNS TABLE
AS RETURN
(
    SELECT Lista = COALESCE
    (
        (   SELECT STRING_AGG(CONVERT(VARCHAR(MAX),
                '<div style="margin: 2px;padding: 2px;" class="ui blue label">' + e.NombreExpediente + '</div> '), '')
                   WITHIN GROUP (ORDER BY e.NombreExpediente)
            FROM Tramite.ExpedienteEnlazado EE WITH (NOLOCK)
            INNER JOIN Tramite.Expediente e WITH (NOLOCK)
                ON EE.IdExpedienteSecundario = e.IdExpediente
               AND e.EstadoAuditoria = 1 AND e.ExpedienteAnulado = 0 AND EE.EstadoAuditoria = 1
            WHERE EE.IdExpediente = @pIdExpediente ),
        (   SELECT STRING_AGG(CONVERT(VARCHAR(MAX),
                '<div style="margin: 2px;padding: 2px;" class="ui blue label">' + e.NombreExpediente + '</div> '), '')
                   WITHIN GROUP (ORDER BY e.NombreExpediente)
            FROM Tramite.ExpedienteEnlazado EE WITH (NOLOCK)
            INNER JOIN Tramite.Expediente e WITH (NOLOCK)
                ON EE.IdExpediente = e.IdExpediente
               AND e.EstadoAuditoria = 1 AND e.ExpedienteAnulado = 0 AND EE.EstadoAuditoria = 1
            WHERE EE.IdExpedienteSecundario = @pIdExpediente ),
        ''
    )
);
GO

-- func4: HTML del numero de documento (4 ramas fieles) --------------------------------------
CREATE OR ALTER FUNCTION Tramite.tvfNumeroDocumentoEspecialista
(@pIdExpediente INT, @pIdArea INT, @pIdCargo INT, @pIdPersona INT, @pSit INT)
RETURNS TABLE
AS RETURN
(
    SELECT TOP (1) NumeroDocumento
    FROM
    (
        -- Rama 4,5,112 (POR RECIBIR / PENDIENTES / CREADOS) -> filtro por Destino, con title=Motivo
        SELECT NumeroDocumento FROM
        (
            SELECT TOP (1) NumeroDocumento =
                '<button type="button" data-toggle="tooltip" title="' + COALESCE(EDOD.MotivoArchivado,'') +
                '" class="btn ui blue label" onclick="MostrarDocumentoPdfExp(''' + ED.RutaArchivoDocumento + ''',' +
                CONVERT(VARCHAR, ED.IdExpedienteDocumento) + ')"><i style="font-size:16px;" class="fa fa-file-text"></i></button>' +
                '<label style="font-size:8px">' +
                CASE WHEN ED.Correlativo = 0 THEN CONCAT(CTD.Descripcion,' ',COALESCE(ED.NumeroDocumento,'')) ELSE COALESCE(ED.NumeroDocumento,'') END +
                '</label>'
            FROM Tramite.ExpedienteDocumento ED WITH (NOLOCK)
            INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
                ON ED.IdExpedienteDocumento = EDO.IdExpedienteDocumento AND ED.EstadoAuditoria = 1
            INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
                ON EDO.IdExpedienteDocumentoOrigen = EDOD.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria = 1 AND EDOD.EstadoAuditoria = 1
            LEFT JOIN Tramite.Catalogo CTD ON CTD.IdCatalogo = ED.IdCatalogoTipoDocumento
            WHERE @pSit IN (4,5,112) AND ED.IdExpediente = @pIdExpediente
              AND EDOD.IdAreaDestino = @pIdArea AND EDOD.IdCargoDestino = @pIdCargo AND EDOD.IdPersonaDestino = @pIdPersona
              AND EDOD.IdCatalogoSituacionMovimientoDestino = @pSit
        ) r45112
        UNION ALL
        -- Rama 111 / 3,6 (REENVIADOS / RESPONDIDOS / DEVUELTOS) -> filtro por Origen, orden desc
        SELECT NumeroDocumento FROM
        (
            SELECT TOP (1) NumeroDocumento =
                '<button type="button" data-toggle="tooltip" class="btn ui blue label" onclick="MostrarDocumentoPdfExp(''' +
                ED.RutaArchivoDocumento + ''',' + CONVERT(VARCHAR, ED.IdExpedienteDocumento) +
                ')"><i style="font-size:16px;" class="fa fa-file-text"></i></button>' +
                '<label style="font-size:8px">' +
                CASE WHEN ED.Correlativo = 0 THEN CONCAT(CTD.Descripcion,' ',COALESCE(ED.NumeroDocumento,'')) ELSE COALESCE(ED.NumeroDocumento,'') END +
                '</label>'
            FROM Tramite.ExpedienteDocumento ED WITH (NOLOCK)
            INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
                ON ED.IdExpedienteDocumento = EDO.IdExpedienteDocumento AND ED.EstadoAuditoria = 1
            INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
                ON EDO.IdExpedienteDocumentoOrigen = EDOD.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria = 1 AND EDOD.EstadoAuditoria = 1
            INNER JOIN Tramite.Catalogo CTD ON CTD.IdCatalogo = ED.IdCatalogoTipoDocumento
            WHERE @pSit IN (111,3,6) AND ED.IdExpediente = @pIdExpediente
              AND EDO.IdAreaOrigen = @pIdArea AND EDO.IdCargoOrigen = @pIdCargo AND EDO.IdPersonaOrigen = @pIdPersona
            ORDER BY EDOD.IdExpedienteDocumentoOrigenDestino DESC
        ) r11136
        UNION ALL
        -- Rama 116 (TODOS / POR RECIBIR / PENDIENTES) -> filtro por Origen + situacion origen
        SELECT NumeroDocumento FROM
        (
            SELECT TOP (1) NumeroDocumento =
                '<button type="button" data-toggle="tooltip" class="btn ui blue label" onclick="MostrarDocumentoPdfExp(''' +
                ED.RutaArchivoDocumento + ''',' + CONVERT(VARCHAR, ED.IdExpedienteDocumento) +
                ')"><i style="font-size:16px;" class="fa fa-file-text"></i></button>' +
                '<label style="font-size:8px">' +
                CASE WHEN ED.Correlativo = 0 THEN CONCAT(CTD.Descripcion,' ',COALESCE(ED.NumeroDocumento,'')) ELSE COALESCE(ED.NumeroDocumento,'') END +
                '</label>'
            FROM Tramite.ExpedienteDocumento ED WITH (NOLOCK)
            INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
                ON ED.IdExpedienteDocumento = EDO.IdExpedienteDocumento AND ED.EstadoAuditoria = 1
            INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
                ON EDO.IdExpedienteDocumentoOrigen = EDOD.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria = 1 AND EDOD.EstadoAuditoria = 1
            LEFT JOIN Tramite.Catalogo CTD ON CTD.IdCatalogo = ED.IdCatalogoTipoDocumento
            WHERE @pSit = 116 AND ED.IdExpediente = @pIdExpediente
              AND EDO.IdAreaOrigen = @pIdArea AND EDO.IdCargoOrigen = @pIdCargo AND EDO.IdPersonaOrigen = @pIdPersona
              AND EDO.IdCatalogoSituacionMovimientoOrigen = @pSit
            ORDER BY EDO.IdExpedienteDocumentoOrigen DESC
        ) r116
    ) u
);
GO

-- func5: Id del ExpedienteDocumento (4 ramas fieles, incluida la cadena Anterior) -----------
CREATE OR ALTER FUNCTION Tramite.tvfIdExpedienteDocumentoEspecialista
(@pIdExpediente INT, @pIdArea INT, @pIdCargo INT, @pIdPersona INT, @pSit INT)
RETURNS TABLE
AS RETURN
(
    SELECT TOP (1) IdExpedienteDocumento
    FROM
    (
        -- Rama 4,5,112
        SELECT IdExpedienteDocumento FROM
        (
            SELECT TOP (1) IdExpedienteDocumento = ED.IdExpedienteDocumento
            FROM Tramite.ExpedienteDocumento ED WITH (NOLOCK)
            INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
                ON ED.IdExpedienteDocumento = EDO.IdExpedienteDocumento AND ED.EstadoAuditoria = 1
            INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
                ON EDO.IdExpedienteDocumentoOrigen = EDOD.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria = 1 AND EDOD.EstadoAuditoria = 1
            WHERE @pSit IN (4,5,112) AND ED.IdExpediente = @pIdExpediente
              AND EDOD.IdAreaDestino = @pIdArea AND EDOD.IdCargoDestino = @pIdCargo AND EDOD.IdPersonaDestino = @pIdPersona
              AND EDOD.IdCatalogoSituacionMovimientoDestino = @pSit
        ) r45112
        UNION ALL
        -- Rama 111 / 3,6 -> documento cuyo ...OrigenDestinoAnterior = top(OrigenDestino por Destino)
        SELECT IdExpedienteDocumento FROM
        (
            SELECT TOP (1) IdExpedienteDocumento = ED.IdExpedienteDocumento
            FROM Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
            INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
                ON EDO.IdExpedienteDocumentoOrigen = EDOD.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria = 1
            INNER JOIN Tramite.ExpedienteDocumento ED WITH (NOLOCK)
                ON ED.IdExpedienteDocumento = EDO.IdExpedienteDocumento AND ED.EstadoAuditoria = 1
            WHERE @pSit IN (111,3,6)
              AND EDOD.IdExpedienteDocumentoOrigenDestinoAnterior =
              (
                    SELECT TOP (1) EDOD2.IdExpedienteDocumentoOrigenDestino
                    FROM Tramite.ExpedienteDocumento ED2 WITH (NOLOCK)
                    INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO2 WITH (NOLOCK)
                        ON ED2.IdExpedienteDocumento = EDO2.IdExpedienteDocumento AND ED2.EstadoAuditoria = 1
                    INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD2 WITH (NOLOCK)
                        ON EDO2.IdExpedienteDocumentoOrigen = EDOD2.IdExpedienteDocumentoOrigen AND EDO2.EstadoAuditoria = 1 AND EDOD2.EstadoAuditoria = 1
                    WHERE ED2.IdExpediente = @pIdExpediente
                      AND EDOD2.IdAreaDestino = @pIdArea AND EDOD2.IdCargoDestino = @pIdCargo AND EDOD2.IdPersonaDestino = @pIdPersona
                      AND EDOD2.IdCatalogoSituacionMovimientoDestino = @pSit
                    ORDER BY EDOD2.IdExpedienteDocumentoOrigenDestino DESC
              )
        ) r11136
        UNION ALL
        -- Rama 116 -> por Origen + situacion origen
        SELECT IdExpedienteDocumento FROM
        (
            SELECT TOP (1) IdExpedienteDocumento = ED.IdExpedienteDocumento
            FROM Tramite.ExpedienteDocumento ED WITH (NOLOCK)
            INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
                ON ED.IdExpedienteDocumento = EDO.IdExpedienteDocumento AND ED.EstadoAuditoria = 1
            WHERE @pSit = 116 AND ED.IdExpediente = @pIdExpediente
              AND EDO.IdAreaOrigen = @pIdArea AND EDO.IdCargoOrigen = @pIdCargo AND EDO.IdPersonaOrigen = @pIdPersona
              AND EDO.IdCatalogoSituacionMovimientoOrigen = @pSit
            ORDER BY EDO.IdExpedienteDocumentoOrigen DESC
        ) r116
    ) u
);
GO


CREATE OR ALTER FUNCTION Tramite.tvfDiasPendienteEspecialista
(
    @pIdExpediente INT,
    @pIdPersona    INT,
    @pIdEmpresa    INT,
    @pIdArea       INT,
    @pIdCargo      INT,
    @pSit          INT
)
RETURNS TABLE
AS RETURN
(
    SELECT DiasPendiente = COALESCE(
    (
        SELECT TOP (1)
            CASE
                -- Rama situacion 4 (POR RECIBIR): dias desde FechaOrigen si aun no recepciona
                WHEN @pSit = 4 THEN
                    CASE WHEN COALESCE(EDOD.FechaDestinoRecepciona,'') = ''
                         THEN CASE WHEN DATEDIFF(DAY, CONVERT(DATE, EDO.FechaOrigen), GETDATE()) < 0
                                   THEN 0
                                   ELSE DATEDIFF(DAY, CONVERT(DATE, EDO.FechaOrigen), GETDATE()) END
                         ELSE 0 END
                -- Rama situacion 5 (PENDIENTES): dias desde que recepciono
                WHEN @pSit = 5 THEN
                    CASE WHEN COALESCE(EDOD.FechaDestinoRecepciona,'') <> ''
                         THEN DATEDIFF(DAY, CONVERT(DATE, EDOD.FechaDestinoRecepciona), GETDATE())
                         ELSE 0 END
                ELSE 0
            END
        FROM Tramite.ExpedienteDocumento ED WITH (NOLOCK)
        INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
            ON ED.IdExpedienteDocumento = EDO.IdExpedienteDocumento AND ED.EstadoAuditoria = 1
        INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
            ON EDO.IdExpedienteDocumentoOrigen = EDOD.IdExpedienteDocumentoOrigen
           AND EDO.EstadoAuditoria = 1 AND EDOD.EstadoAuditoria = 1
        WHERE @pSit IN (4,5)
          AND ED.IdExpediente = @pIdExpediente
          AND EDOD.IdAreaDestino    = @pIdArea
          AND EDOD.IdCargoDestino   = @pIdCargo
          AND EDOD.IdEmpresaDestino = @pIdEmpresa
          AND EDOD.IdPersonaDestino = @pIdPersona
          AND EDOD.IdCatalogoSituacionMovimientoDestino = @pSit
    ), 0)
);
GO

/*==========================================================================================
  [A.2] TVF FALTANTE  -> reemplaza  Tramite.funEsPrincipalEnlace
==========================================================================================*/
CREATE OR ALTER FUNCTION Tramite.tvfEsPrincipalEnlace
(
    @pIdExpediente INT
)
RETURNS TABLE
AS RETURN
(
    SELECT EsPrincipalEnlace =
        CASE WHEN EXISTS
        (
            SELECT 1
            FROM Tramite.ExpedienteEnlazado EE WITH (NOLOCK)
            WHERE EE.IdExpediente = @pIdExpediente AND EE.EstadoAuditoria = 1
        ) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
);
GO
