CREATE PROCEDURE [Tramite].[paObtenerEstadosExpedientesJefatura]
    @pIdArea int,
    @pIdUsuarioAuditoria int
AS
BEGIN TRY

    DECLARE @vTod int = 0;
    DECLARE @vEmpresaDestino int = 2;

    SELECT
        0 AS Res,
        ISNULL(SUM(CASE WHEN X.IdCatalogoSituacionMovimientoDestino = 4 THEN 1 ELSE 0 END), 0) AS Rec,
        ISNULL(SUM(CASE WHEN X.IdCatalogoSituacionMovimientoDestino = 5 THEN 1 ELSE 0 END), 0) AS Pen,
        0 AS Dev,
        0 AS Ree,
        0 AS Arc,
        0 AS Env,
        0 AS Seg,
        0 AS Mis,
        @vTod AS Tod
    FROM (
        SELECT
            DISTINCT
            E.IdExpediente,
            EDOD.IdCatalogoSituacionMovimientoDestino
        FROM Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
            INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
                ON EDO.IdExpedienteDocumentoOrigen = EDOD.IdExpedienteDocumentoOrigen
                AND EDO.EstadoAuditoria = 1
            INNER JOIN Tramite.ExpedienteDocumento ED WITH (NOLOCK)
                ON ED.IdExpedienteDocumento = EDO.IdExpedienteDocumento
                AND ED.EstadoAuditoria = 1
                AND ED.FgEnEsperaFirmaDigital = 0
            INNER JOIN Tramite.Expediente E WITH (NOLOCK)
                ON E.IdExpediente = ED.IdExpediente
                AND E.EstadoAuditoria = 1
                AND E.ExpedienteAnulado = 0
        WHERE
            EDOD.IdAreaDestino = @pIdArea
            AND EDOD.IdEmpresaDestino = @vEmpresaDestino
            AND EDOD.EstadoAuditoria = 1
            AND EDOD.IdCatalogoSituacionMovimientoDestino IN (4, 5)
            AND EXISTS (
                SELECT 1
                FROM General.Cargo C WITH (NOLOCK)
                WHERE C.IdCargo = EDOD.IdCargoDestino
                AND C.IdCatalogoTipoCargo IN (32, 33, 34)
            )
    ) X;

END TRY
BEGIN CATCH
    DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT, @ERROR_STATE INT, @ERROR_LINE INT, @ERROR_PROCEDURE VARCHAR(MAX), @ERROR_MESSAGE VARCHAR(MAX);
    SELECT @ERROR_NUMBER = ERROR_NUMBER(),@ERROR_SEVERITY = ERROR_SEVERITY(),@ERROR_STATE = ERROR_STATE(), @ERROR_PROCEDURE = 'Tramite.paObtenerEstadosExpedientesJefatura',@ERROR_LINE = ERROR_LINE(), @ERROR_MESSAGE = ERROR_MESSAGE();
    EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER, @ERROR_SEVERITY, @ERROR_STATE,@ERROR_PROCEDURE, @ERROR_LINE, @ERROR_MESSAGE, @pIdUsuarioAuditoria;
END CATCH
