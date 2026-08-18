ALTER PROCEDURE [Tramite].[paListarTreeExpedienteDocumentoOrigen]
    @pIdExpediente int,
    @pIdUsuarioAuditoria int,
    @pIdPeriodo int
AS
BEGIN
BEGIN TRY

    select ed.NumeroDocumento,
    e.NumeroExpediente,
	CONCAT(SD.AbreviaturaSerieDocumentalExpediente +RIGHT('000000'+CONVERT(VARCHAR,E.NumeroExpediente),6), '-', E.IdPeriodo, CASE WHEN COALESCE(ED.CorrelativoVinculado,0)=0 THEN '' ELSE '-'+LTRIM(ED.CorrelativoVinculado) END) NombreExpediente,
    e.IdPeriodo,
    o.IdExpedienteDocumentoOrigen ,
    CASE WHEN o.IdPersonaOrigen=0 THEN o.NombreCompletoOrigen ELSE p.NombreCompleto END NombreCompleto,coalesce(c.Descripcion,'') TipoMovimientoOrigen,
    ed.AsuntoDocumento,
    o.NumeroDiasAtencionSolicitado,
    ed.NumeroFoliosDocumento,
    Tramite.funTotalExpedienteDocumentoHijos(o.IdExpedienteDocumentoOrigen)Hijos,
    o.FechaOrigen,o.HoraOrigen
    from Tramite.ExpedienteDocumentoOrigen o
    INNER JOIN Tramite.ExpedienteDocumento ed on ed.IdExpedienteDocumento=o.IdExpedienteDocumento
    INNER JOIN Tramite.Expediente e on e.IdExpediente=ed.IdExpediente
	INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
    left join Tramite.Catalogo c on c.IdCatalogo=o.IdCatalogoTipoMovimientoOrigen
    left join General.Persona p on o.IdPersonaOrigen=p.IdPersona
    where o.EstadoAuditoria=1 and ed.IdExpediente=@pIdExpediente and o.EsCabecera = 1 AND ed.EstadoAuditoria=1 AND e.EstadoAuditoria=1

END TRY
BEGIN CATCH
    DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX),@ERROR_MESSAGE VARCHAR(MAX)
    SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE(),
    @ERROR_PROCEDURE='Tramite.paListarTreeExpedienteDocumentoOrigen',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
    EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
END CATCH
END
