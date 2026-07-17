create OR ALTER PROCEDURE Tramite.paListarTreeExpedienteDocumentoOrigen_arq
    @pIdExpediente int,
    @pIdUsuarioAuditoria int,
    @pIdPeriodo int
AS
BEGIN
BEGIN TRY
SET NOCOUNT ON
SET TRAN ISOLATION LEVEL READ UNCOMMITTED

if @pIdPeriodo = year(getdate())begin
    RAISERROR('El periodo no debe ser el actual o vacio', 10, 1) with nowait;
    return;
end;

create table #tmp001_expediente001(
    NumeroExpediente int,
    IdPeriodo int,
    AbreviaturaSerieDocumentalExpediente varchar(2) collate database_default,
    NumeroDocumento varchar(200) collate database_default,
    CorrelativoVinculado int,
    NumeroFoliosDocumento int,
    AsuntoDocumento varchar(8000) collate database_default,
    IdCatalogoTipoMovimientoOrigen int,
    IdExpedienteDocumentoOrigen int,
    IdPersonaOrigen int,
    NombreCompletoOrigen varchar(100) collate database_default,
    NumeroDiasAtencionSolicitado int,
    FechaOrigen varchar(10) collate database_default,
    HoraOrigen varchar(5) collate database_default,
    Hijos int
)

    DECLARE @vSql nvarchar(max),@vIdPeriodo varchar(4)= convert(varchar, @pIdPeriodo)

    select @vSql = N'\
    ;with tmp001_serieDocumental as(
        select*from(values(1,''E-''),(2,''I-''))sd(IdSerieDocumentalExpediente, AbreviaturaSerieDocumentalExpediente)
    )
    insert into #tmp001_expediente001 select
        e.NumeroExpediente,
        e.IdPeriodo,
        SD.AbreviaturaSerieDocumentalExpediente,
        ed.NumeroDocumento,
		ed.CorrelativoVinculado,
		ed.NumeroFoliosDocumento,
        ed.AsuntoDocumento,
        o.IdCatalogoTipoMovimientoOrigen,
        o.IdExpedienteDocumentoOrigen,
        o.IdPersonaOrigen,
        o.NombreCompletoOrigen,
        o.NumeroDiasAtencionSolicitado,
        o.FechaOrigen,
        o.HoraOrigen,
        d.Hijos
    from Tramite.Expediente_historico_'+ @vIdPeriodo +N' e
        INNER JOIN Tramite.ExpedienteDocumento_historico_'+ @vIdPeriodo +N' ed ON ed.IdExpediente = e.IdExpediente and ed.EstadoAuditoria = 1
        INNER JOIN Tramite.ExpedienteDocumentoOrigen_historico_'+ @vIdPeriodo +N' o ON o.IdExpedienteDocumento = ed.IdExpedienteDocumento and o.EstadoAuditoria=1 and o.EsCabecera = 1
        INNER JOIN tmp001_serieDocumental SD ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
    outer apply(
        select count(1) Hijos
        from Tramite.ExpedienteDocumentoOrigenDestino_historico_'+ @vIdPeriodo +N' edod where edod.IdExpedienteDocumentoOrigen = o.IdExpedienteDocumentoOrigen and edod.EstadoAuditoria=1
    )d where e.IdExpediente=@pIdExpediente and e.EstadoAuditoria=1'

    EXEC sp_executesql @vSql, N'@pIdExpediente int', @pIdExpediente = @pIdExpediente

    select
        t.NumeroDocumento,
        t.NumeroExpediente,
		CONCAT(t.AbreviaturaSerieDocumentalExpediente, RIGHT(1000000+t.NumeroExpediente,6), '-', t.IdPeriodo,
		CASE WHEN COALESCE(t.CorrelativoVinculado,0)=0 THEN '' ELSE '-'+LTRIM(t.CorrelativoVinculado) END) NombreExpediente,
        t.IdPeriodo,
        t.IdExpedienteDocumentoOrigen ,
        CASE WHEN t.IdPersonaOrigen=0 THEN t.NombreCompletoOrigen ELSE p.NombreCompleto END NombreCompleto,
        coalesce(c.Descripcion,'') TipoMovimientoOrigen,
        t.AsuntoDocumento,
        t.NumeroDiasAtencionSolicitado,
        t.NumeroFoliosDocumento,
        t.Hijos,
        t.FechaOrigen,
        t.HoraOrigen
    from #tmp001_expediente001 t
    left join Tramite.Catalogo c on c.IdCatalogo = t.IdCatalogoTipoMovimientoOrigen
    left join General.Persona p on p.IdPersona = t.IdPersonaOrigen


END TRY
BEGIN CATCH
    DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX) ,@ERROR_MESSAGE VARCHAR(MAX)
    SELECT @ERROR_NUMBER=ERROR_NUMBER(), @ERROR_SEVERITY=ERROR_SEVERITY(), @ERROR_STATE=ERROR_STATE(),
    @ERROR_PROCEDURE='Tramite.paListarTreeExpedienteDocumentoOrigen_arq',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
    EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
END CATCH
END
GO


EXECUTE Tramite.paListarTreeExpedienteDocumentoOrigen_arq 805042,642, 2026
EXECUTE Tramite.paListarTreeExpedienteDocumentoOrigen_arq 727745,642, 2025
