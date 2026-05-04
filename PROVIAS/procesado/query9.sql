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
    from tramite.ExpedienteDocumentoOrigenDestino t4
    where   t4.EstadoAuditoria   = 1
        and t4.IdAreaDestino     = @pIdArea
        and t4.IdEmpresaDestino  = 2
        and t4.IdCatalogoSituacionMovimientoDestino in (4,5)
        and exists(
            select 1
            from tramite.ExpedienteDocumentoOrigen t3
            inner join tramite.ExpedienteDocumento t2
                on  t2.IdExpedienteDocumento = t3.IdExpedienteDocumento
                and t2.EstadoAuditoria = 1
                and t2.FgEnEsperaFirmaDigital = 0
            inner join tramite.Expediente t1
                on  t1.IdExpediente = t2.IdExpediente
                and t1.EstadoAuditoria   = 1
                and t1.ExpedienteAnulado = 0
                and t1.IdSerieDocumentalExpediente in (1,2)
            where   t3.IdExpedienteDocumentoOrigen = t4.IdExpedienteDocumentoOrigen
                and t3.EstadoAuditoria = 1
        )
        and exists(
            select 1
            from general.Cargo c
            where   c.IdCargo = t4.IdCargoDestino
                and c.IdCatalogoTipoCargo in (32,33,34)
        )

END TRY
BEGIN CATCH
    DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT, @ERROR_STATE INT, @ERROR_LINE INT, @ERROR_PROCEDURE VARCHAR(MAX), @ERROR_MESSAGE VARCHAR(MAX);
    SELECT @ERROR_NUMBER = ERROR_NUMBER(),@ERROR_SEVERITY = ERROR_SEVERITY(),@ERROR_STATE = ERROR_STATE(), @ERROR_PROCEDURE = 'Tramite.paObtenerEstadosExpedientesJefatura',@ERROR_LINE = ERROR_LINE(), @ERROR_MESSAGE = ERROR_MESSAGE();
    EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER, @ERROR_SEVERITY, @ERROR_STATE,@ERROR_PROCEDURE, @ERROR_LINE, @ERROR_MESSAGE, @pIdUsuarioAuditoria;
END CATCH
END
GO
