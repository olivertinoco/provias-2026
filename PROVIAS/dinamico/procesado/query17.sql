alter PROCEDURE [Tramite].[paObtenerExpedienteDocumento_arq]
	@pIdExpedienteDocumento INT,
	@pIdPeriodo int
AS
BEGIN
BEGIN TRY
SET TRAN ISOLATION LEVEL READ UNCOMMITTED
SET LANGUAGE SPANISH
SET NOCOUNT ON

create table #tmp001_expediete876(
    IdExpedienteDocumento int,
    IdExpediente int,
    IdCatalogoTipoDocumento int,
    IdCatalogoTipoMovimientoDocumento int,
    IdEmpresaEmisor int,
    IdAreaEmisor int,
    IdCargoEmisor int,
    IdPersonaEmisor int,
    NombreCompletoEmisor varchar(100) collate database_default,
    NumeroDocumento varchar(200) collate database_default,
    NumeroFoliosDocumento int,
    AsuntoDocumento varchar(8000) collate database_default,
    NFechaDocumento varchar(10) collate database_default,
    FgEsObservado bit,
    FgEsCorregido bit,
    RutaArchivoDocumentoCorregido varchar(200) collate database_default,
    RutaArchivoDocumento varchar(150) collate database_default,
    ObservacionesDocumento varchar(4000) collate database_default,
    LinkArchivoCompartido varchar(max) collate database_default,
    DescripcionCorreccion varchar(1000) collate database_default,
    DescripcionObervacionIngresada varchar(1000) collate database_default,
    NFechaDocumentoCorregido varchar(10) collate database_default,
    FechaEnvioDocumentoCorregido datetime,
    FechaEnvioDocumento datetime,
    FgEnEsperaFirmaDigital bit,
    FgEsObligatorioFirmaDigital bit,
    FechaHoraFirmaDigital varchar(16) collate database_default,
    FlagParaDespacho bit,
    Correlativo int,
    FechaCreacionAuditoria datetime,
    AsuntoExpediente varchar(8000) collate database_default,
    NumeroFoliosExpediente int,
    FgTramiteVirtual bit,
    NumeroExpediente int,
    IdPeriodo int,
    Descripcion varchar(400) collate database_default,
    AbreviaturaSerieDocumentalExpediente varchar(2),
    NombreCompletoNoticado varchar(100) collate database_default,
    EmailNotificacion varchar(100) collate database_default,
    CelularNotificacion varchar(100) collate database_default,
    TelefonoNotificacion varchar(100) collate database_default,
    DireccionNotificacion varchar(100) collate database_default
)

    DECLARE @vSql nvarchar(max),@vCtaDocumento int,@vExpediente varchar(50)='',@vAnno int = year(getdate())
    if(@vAnno != @pIdPeriodo)select @vExpediente = concat('_historico_', @pIdPeriodo)

    select @vSql = N'\
    select  @vCtaDocumento = case when count(1)>0 then 1 else 0 end \
    from Tramite.ExpedienteDocumento'+ @vExpediente +N' t inner join Tramite.PermisoActualizacionDocumento p \
    on p.IdArea = t.IdAreaEmisor and p.IdCargo = t.IdCargoEmisor and p.IdPersona = t.IdPersonaEmisor and p.Activo = 1 and p.EstadoAuditoria = 1 \
    where t.IdExpediente = @pIdExpedienteDocumento \
    if(@vCtaDocumento = 0) \
        SELECT @vCtaDocumento=case when count(1) > 0 then 1 else 0 end \
        FROM Tramite.ExpedienteDocumentoOrigen'+ @vExpediente +N' EDO \
        INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino'+ @vExpediente +N' EDOD \
        ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen and EDOD.EstadoAuditoria=1 and EDOD.IdCatalogoSituacionMovimientoDestino != 4 \
        where EDO.IdExpedienteDocumento=@pIdExpedienteDocumento and EDO.EstadoAuditoria=1'

    EXEC sp_executesql @vSql,
        N'@pIdExpedienteDocumento int, @vCtaDocumento int output',
    	@pIdExpedienteDocumento = @pIdExpedienteDocumento,
    	@vCtaDocumento = @vCtaDocumento output

    select @vSql = N'\
    ;with tmp001_serieDocumental as(
        select*from(values(1,''E-''),(2,''I-''))sd(IdSerieDocumentalExpediente, AbreviaturaSerieDocumentalExpediente)
    )
    insert into #tmp001_expediete876 SELECT
    E.IdExpedienteDocumento,
    E.IdExpediente,
    E.IdCatalogoTipoDocumento,
    E.IdCatalogoTipoMovimientoDocumento,
    E.IdEmpresaEmisor,
    E.IdAreaEmisor,
    E.IdCargoEmisor,
    E.IdPersonaEmisor,
    E.NombreCompletoEmisor,
    E.NumeroDocumento,
    E.NumeroFoliosDocumento,
    E.AsuntoDocumento,
    E.NFechaDocumento,
    E.FgEsObservado,
    E.FgEsCorregido,
    E.RutaArchivoDocumentoCorregido,
    E.RutaArchivoDocumento,
    E.ObservacionesDocumento,
	E.LinkArchivoCompartido,
	E.DescripcionCorreccion,
	E.DescripcionObervacionIngresada,
	E.NFechaDocumentoCorregido,
	E.FechaEnvioDocumentoCorregido,
	E.FechaEnvioDocumento,
	E.FgEnEsperaFirmaDigital,
	E.FgEsObligatorioFirmaDigital,
	E.FechaHoraFirmaDigital,
	E.FlagParaDespacho,
	E.Correlativo,
	E.FechaCreacionAuditoria,
	EX.AsuntoExpediente,
	EX.NumeroFoliosExpediente,
	EX.FgTramiteVirtual,
	EX.NumeroExpediente,
	EX.IdPeriodo,
	C.Descripcion,
	SD.AbreviaturaSerieDocumentalExpediente,
    EXV.NombreCompletoNoticado,
    EXV.EmailNotificacion,
    EXV.CelularNotificacion,
    EXV.TelefonoNotificacion,
    EXV.DireccionNotificacion
    FROM Tramite.ExpedienteDocumento'+ @vExpediente +N' E
        INNER JOIN Tramite.Expediente'+ @vExpediente +N' EX on EX.IdExpediente=E.IdExpediente
        INNER JOIN Tramite.Catalogo C on C.IdCatalogo=E.IdCatalogoTipoDocumento
    	INNER JOIN tmp001_serieDocumental SD ON SD.IdSerieDocumentalExpediente=EX.IdSerieDocumentalExpediente
        LEFT JOIN  Tramite.Expediente'+ @vExpediente +N' EXV on EXV.IdExpediente=E.IdExpedienteVirtual
    WHERE E.IdExpedienteDocumento=@pIdExpedienteDocumento AND E.EstadoAuditoria=1'

    EXEC sp_executesql @vSql, N'@pIdExpedienteDocumento int', @pIdExpedienteDocumento = @pIdExpedienteDocumento

    select
        @vCtaDocumento EsRecepcionado,
        E.IdExpedienteDocumento,
        E.IdExpediente,
        E.AsuntoExpediente,
        E.IdCatalogoTipoDocumento,
        E.Descripcion CatalogoTipoDocumento,
        coalesce(E.IdCatalogoTipoMovimientoDocumento,0)IdCatalogoTipoMovimientoDocumento,
        coalesce(CTM.Descripcion ,'')CatalogoTipoMovimientoDocumento,
        E.IdEmpresaEmisor,
        COALESCE(EM.NombreEmpresa,'') NombreEmpresa,
        E.IdAreaEmisor,
        COALESCE(AE.NombreArea,'')NombreArea,
        E.IdCargoEmisor,
        COALESCE(CE.NombreCargo,'')NombreCargo,
        E.IdPersonaEmisor,
        coalesce(CASE WHEN E.IdPersonaEmisor=0 THEN E.NombreCompletoEmisor ELSE PM.NombreCompleto END,'')NombreCompletoEmisor,
        CASE WHEN E.Correlativo=0 THEN  CONCAT( E.Descripcion,' ', COALESCE(E.NumeroDocumento,'')) ELSE COALESCE(E.NumeroDocumento,'') END  NumeroDocumento,
        case when (E.NumeroFoliosDocumento=0) then E.NumeroFoliosExpediente else E.NumeroFoliosDocumento end NumeroFoliosDocumento,
        E.AsuntoDocumento,
        E.NFechaDocumento,
        CASE WHEN E.FgEsObservado=1 THEN CASE WHEN E.FgEsCorregido=1 THEN E.RutaArchivoDocumentoCorregido ELSE E.RutaArchivoDocumento END ELSE E.RutaArchivoDocumento END RutaArchivoDocumento,
        E.ObservacionesDocumento,
        coalesce(E.LinkArchivoCompartido,'')LinkArchivoCompartido,
        E.FgTramiteVirtual,
        CONCAT(E.AbreviaturaSerieDocumentalExpediente +RIGHT('000000'+CONVERT(VARCHAR,E.NumeroExpediente),6), '-', E.IdPeriodo)NombreExpediente,
        coalesce(E.DescripcionCorreccion,'')DescripcionCorreccion,
        coalesce(E.DescripcionObervacionIngresada,'')DescripcionObervacionIngresada,
        coalesce(E.NFechaDocumentoCorregido,'')NFechaDocumentoCorregido,
        coalesce(convert(varchar,E.FechaEnvioDocumentoCorregido,103),'') + ' '+ coalesce(CONVERT(varchar,E.FechaEnvioDocumentoCorregido,108),'')FechaEnvioDocumentoCorregido,
        concat(coalesce(convert(varchar(10),E.FechaEnvioDocumento,103),''),' ',coalesce(convert(varchar(10),E.FechaEnvioDocumento,108),'') )FechaEnvioDocumento,
        coalesce(E.NombreCompletoNoticado,coalesce(E.NombreCompletoNoticado,''))NombreCompletoNoticado,
        coalesce(E.EmailNotificacion,coalesce(E.EmailNotificacion,''))EmailNotificacion,
        coalesce(E.CelularNotificacion,coalesce(E.CelularNotificacion,''))CelularNotificacion,
        coalesce(E.TelefonoNotificacion,coalesce(E.TelefonoNotificacion,''))TelefonoNotificacion,
        coalesce(E.DireccionNotificacion,coalesce(E.DireccionNotificacion,''))DireccionNotificacion,
        E.FgEnEsperaFirmaDigital,
        E.FgEsObligatorioFirmaDigital,
        COALESCE(E.FechaHoraFirmaDigital,'')FechaHoraFirmaDigital,
        E.FlagParaDespacho,
        E.Correlativo,
        Tramite.funDevolverPeriodoDocumento(GETDATE(),E.FechaCreacionAuditoria) PeriodoCreadoDocumento
    from #tmp001_expediete876 E
    left join General.Empresa EM on EM.IdEmpresa=E.IdEmpresaEmisor
    left join General.Area AE on AE.IdArea=E.IdAreaEmisor
    left join General.Cargo CE on CE.IdCargo=E.IdCargoEmisor
    left join General.Persona PM on PM.IdPersona=E.IdPersonaEmisor
    left join Tramite.Catalogo CTM on CTM.IdCatalogo=E.IdCatalogoTipoMovimientoDocumento


END TRY
BEGIN CATCH
	DECLARE @ERROR_NUMBER INT
	DECLARE @ERROR_SEVERITY INT
	DECLARE @ERROR_STATE INT
	DECLARE @ERROR_PROCEDURE VARCHAR(MAX)
	DECLARE @ERROR_LINE INT
	DECLARE @ERROR_MESSAGE VARCHAR(MAX)
	SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE(),
	@ERROR_PROCEDURE='Tramite.paObtenerExpedienteDocumento_arq',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
END CATCH
END
GO



exec tramite.paObtenerExpedienteDocumento_arq
@pIdExpedienteDocumento = 2253103,
@pIdPeriodo=2026


exec tramite.paObtenerExpedienteDocumento_arq
@pIdExpedienteDocumento = 503064,
@pIdPeriodo=2023


exec tramite.paObtenerExpedienteDocumento_arq
@pIdExpedienteDocumento = 503064,
@pIdPeriodo=2024
