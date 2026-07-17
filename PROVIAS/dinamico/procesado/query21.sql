create or alter PROCEDURE Tramite.paListarCarpetaDocumentosPorExpediente_arq
	@pIdExpediente int,
	@pIdUsuarioAuditoria int,
	@pIdPeriodo int
AS
BEGIN
BEGIN TRY
SET TRAN ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

if @pIdPeriodo = year(getdate())begin
    RAISERROR('El periodo no debe ser el actual o vacio', 10, 1) with nowait;
    return;
end;

create table #tmp001_expedienteTramite(
    NumeroExpediente int,
    IdPeriodo int,
    IdSerieDocumentalExpediente int,
    IdExpedienteDocumento int,
    IdExpediente int,
    IdCatalogoTipoDocumento int,
    NFechaDocumento varchar(10) collate database_default,
    FechaCreacionAuditoria8 datetime,
    AsuntoDocumento varchar(8000) collate database_default,
    Correlativo int,
    NumeroDocumento varchar(200) collate database_default,
    FgEsObligatorioFirmaDigital bit,
    RutaArchivoDocumento varchar(150) collate database_default,
    DescripcionDocumentoAdjunto varchar(4000) collate database_default,
    RutaArchivoDocumentoAdjunto varchar(200) collate database_default,
    IdExpedienteDocumentoAdjunto int,
    FechaCreacionAuditoria datetime,
    IdExpedienteDocumentoOrigenAdjunto int,
    DescripcionDocumentoAdjuntoEDO varchar(4000) collate database_default,
    RutaArchivoDocumentoAdjuntoEDO varchar(50) collate database_default,
    PeriodoCreadoDocumento varchar(4) collate database_default,
    IdCatalogoTipoAdjunto int
)

    DECLARE @vSql nvarchar(max),@vIdPeriodo varchar(4)= convert(varchar,@pIdPeriodo)

	DECLARE @vIdPersonaActual int=0
	SELECT @vIdPersonaActual=IdPersona from Seguridad.Usuario where IdUsuario=@pIdUsuarioAuditoria AND EstadoAuditoria=1 AND Bloqueado=0

	select @vSql = N'\
	insert into #tmp001_expedienteTramite SELECT distinct
	EX.NumeroExpediente,
	EX.IdPeriodo,
	EX.IdSerieDocumentalExpediente,
	ED.IdExpedienteDocumento,
	ED.IdExpediente,
	ED.IdCatalogoTipoDocumento,
	ED.NFechaDocumento,
	ED.FechaCreacionAuditoria,
	ED.AsuntoDocumento,
	ED.Correlativo,
	ED.NumeroDocumento,
	ED.FgEsObligatorioFirmaDigital,
	ED.RutaArchivoDocumento,
	EDA.DescripcionDocumentoAdjunto,
	EDA.RutaArchivoDocumentoAdjunto,
	EDA.IdExpedienteDocumentoAdjunto,
	EDA.FechaCreacionAuditoria,
	EDOA.IdExpedienteDocumentoOrigenAdjunto,
	EDOA.DescripcionDocumentoAdjuntoEDO,
	EDOA.RutaArchivoDocumentoAdjuntoEDO,
	Tramite.funDevolverPeriodoDocumento(GETDATE(),ED.FechaCreacionAuditoria),
	EDA.IdCatalogoTipoAdjunto
	FROM Tramite.ExpedienteDocumento_historico_'+ @vIdPeriodo +N' ED
	INNER JOIN Tramite.Expediente_historico_'+ @vIdPeriodo +N' EX ON EX.IdExpediente=ED.IdExpediente
	INNER JOIN Tramite.ExpedienteDocumentoOrigen_historico_'+ @vIdPeriodo +N' EDO ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND EDO.EstadoAuditoria=1 AND ED.EstadoAuditoria=1
	LEFT JOIN Tramite.ExpedienteDocumentoAdjunto_historico_'+ @vIdPeriodo +N' EDA ON EDA.IdExpedienteDocumento=ED.IdExpedienteDocumento AND EDA.EstadoAuditoria=1 AND ED.EstadoAuditoria=1
	LEFT JOIN Tramite.ExpedienteDocumentoOrigenAdjunto_historico_'+ @vIdPeriodo +N' EDOA ON EDOA.IdExpedienteDocumentoOrigenEDO=EDO.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1 AND EDOA.EstadoAuditoria=1
	WHERE ED.IdExpediente=@pIdExpediente
    and not (ED.FgEnEsperaFirmaDigital=1
	and not exists(
	    select 1
        from Tramite.ExpedienteDocumentoFirmante_historico_'+ @vIdPeriodo +N' EDF
        where EDF.IdExpedienteDocumento=ED.IdExpedienteDocumento and EDF.IdPersona=@vIdPersonaActual and EDF.EstadoAuditoria=1))'

    exec sp_executesql @vSql, N'@pIdExpediente int,@vIdPersonaActual int', @pIdExpediente = @pIdExpediente, @vIdPersonaActual = @vIdPersonaActual

    ;with tmp001_serieDocumental as(
        select*from(values(1,'E-'),(2,'I-'))sd(IdSerieDocumentalExpediente, AbreviaturaSerieDocumentalExpediente)
    )
    select
    CONCAT(SD.AbreviaturaSerieDocumentalExpediente,RIGHT(1000000+t.NumeroExpediente,6), '-', t.IdPeriodo) NombreExpediente,
	t.IdExpedienteDocumento,
	t.IdExpediente,
	t.NFechaDocumento,
	t.FechaCreacionAuditoria8 FechaCreacionAuditoria,
	t.FechaCreacionAuditoria,
	t.AsuntoDocumento,
	CASE WHEN t.Correlativo=0 THEN CONCAT( CTD.Descripcion,' ', COALESCE(t.NumeroDocumento,'')) ELSE COALESCE(t.NumeroDocumento,'')END  NumeroDocumento,
	t.RutaArchivoDocumento,
	coalesce(t.DescripcionDocumentoAdjunto,'S.DA.')DescripcionDocumentoAdjunto,
	COALESCE(t.RutaArchivoDocumentoAdjunto,'S.DA.')RutaArchivoDocumentoAdjunto,
	COALESCE(t.IdExpedienteDocumentoAdjunto,0)IdExpedienteDocumentoAdjunto,
	COALESCE(t.IdExpedienteDocumentoOrigenAdjunto,0)IdExpedienteDocumentoOrigenAdjunto,
	COALESCE(t.DescripcionDocumentoAdjuntoEDO,'S.DAM.')DescripcionDocumentoAdjuntoEDO,
	COALESCE(t.RutaArchivoDocumentoAdjuntoEDO,'S.DAM.')RutaArchivoDocumentoAdjuntoEDO,
	t.NumeroExpediente,
	t.IdPeriodo,
	SD.AbreviaturaSerieDocumentalExpediente,
	t.PeriodoCreadoDocumento,
	t.FgEsObligatorioFirmaDigital,
	isnull(TC.Descripcion,'') Descripcion
    from #tmp001_expedienteTramite t
    inner join tmp001_serieDocumental SD ON SD.IdSerieDocumentalExpediente=t.IdSerieDocumentalExpediente
    left join Tramite.Catalogo CTD ON CTD.IdCatalogo=t.IdCatalogoTipoDocumento
    left join Tramite.Catalogo TC ON TC.IdCatalogo = t.IdCatalogoTipoAdjunto
    OUTER APPLY(
    	select EB.IdExpedienteBloqueado,EB.FechaHoraBloquea
    	from Tramite.ExpedienteBloqueado EB
    	where EB.IdExpediente = t.IdExpediente and EB.EstadoAuditoria=1 and EB.EstadoBloqueo=1
    )EB
    OUTER APPLY(
    	select 1 PersonaVisualiza
    	from Tramite.ExpedienteBloqueadoPersonaVisualiza EBPV
    	inner join Seguridad.Usuario U on EBPV.IdPersonaVisualiza=U.IdPersona and U.IdUsuario=@pIdUsuarioAuditoria
    	where EBPV.IdExpedienteBloqueado = EB.IdExpedienteBloqueado and EBPV.EstadoAuditoria=1
    )EB1
    where isnull(EB.FechaHoraBloquea,dateadd(day,1,t.FechaCreacionAuditoria8))>t.FechaCreacionAuditoria8 or isnull(EB1.PersonaVisualiza,0)=1
    order by FechaCreacionAuditoria8 desc

END TRY
BEGIN CATCH
	DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
	SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE(),
	@ERROR_PROCEDURE='Tramite.paListarCarpetaDocumentosPorExpediente_arq',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE, @pIdUsuarioAuditoria
END CATCH
END
GO


exec Tramite.paListarCarpetaDocumentosPorExpediente_arq 629834,1059, 2025
exec Tramite.paListarCarpetaDocumentosPorExpediente_arq 831321,1059,2026
