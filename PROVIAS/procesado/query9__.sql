ALTER PROCEDURE [Tramite].[paObtenerEstadosExpedientesJefatura]
    @pIdArea int,
    @pIdUsuarioAuditoria int
AS
BEGIN
BEGIN TRY
set nocount on
set tran isolation level read uncommitted

    select
        0 Res,
        count(case t4.IdCatalogoSituacionMovimientoDestino when 4 then 1 end) Rec,
        count(case t4.IdCatalogoSituacionMovimientoDestino when 5 then 1 end) Pen,
        0 Dev,
       	0 Ree,
       	0 Arc,
       	0 Env,
       	0 Seg,
       	0 Mis,
       	0 Tod
        FROM Tramite.ExpedienteDocumentoOrigenDestino t4
            INNER JOIN Tramite.ExpedienteDocumentoOrigen t3
                ON t3.IdExpedienteDocumentoOrigen = t4.IdExpedienteDocumentoOrigen
                AND t3.EstadoAuditoria = 1
            INNER JOIN Tramite.ExpedienteDocumento t2
                ON t2.IdExpedienteDocumento = t3.IdExpedienteDocumento
                AND t2.EstadoAuditoria = 1
                AND t2.FgEnEsperaFirmaDigital = 0
            INNER JOIN Tramite.Expediente t1
                ON t1.IdExpediente = t2.IdExpediente
                AND t1.EstadoAuditoria = 1
                AND t1.ExpedienteAnulado = 0
        WHERE t4.IdAreaDestino = @pIdArea
            AND t4.IdEmpresaDestino = 2
            AND t4.EstadoAuditoria = 1
            AND t4.IdCatalogoSituacionMovimientoDestino IN (4, 5)
            AND EXISTS (
                SELECT 1
                FROM General.Cargo C
                WHERE C.IdCargo = t4.IdCargoDestino
                AND C.IdCatalogoTipoCargo IN (32, 33, 34)
            )

END TRY
BEGIN CATCH
    DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT, @ERROR_STATE INT, @ERROR_LINE INT, @ERROR_PROCEDURE VARCHAR(MAX), @ERROR_MESSAGE VARCHAR(MAX);
    SELECT @ERROR_NUMBER = ERROR_NUMBER(),@ERROR_SEVERITY = ERROR_SEVERITY(),@ERROR_STATE = ERROR_STATE(), @ERROR_PROCEDURE = 'Tramite.paObtenerEstadosExpedientesJefatura',@ERROR_LINE = ERROR_LINE(), @ERROR_MESSAGE = ERROR_MESSAGE();
    EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER, @ERROR_SEVERITY, @ERROR_STATE,@ERROR_PROCEDURE, @ERROR_LINE, @ERROR_MESSAGE, @pIdUsuarioAuditoria;
END CATCH
END
GO
