create PROCEDURE Tramite.paListarDocumentoHojaRuta_arq
	@pIdExpediente int,
	@pIdArea int,
	@pIdUsuarioAuditoria int,
	@pIdPeriodo int
AS
BEGIN
BEGIN TRY
SET TRAN ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON
SET LANGUAGE SPANISH

create table #tmp001_expedienteHojaRuta(
    IdExpediente int,
    CelularNotificacion varchar(100) collate database_default,
    EmailNotificacion varchar(100) collate database_default,
    NTFechaExpediente varchar(10) collate database_default,
    FechaEnvioDocumento varchar(19) collate database_default,
    NumeroExpediente int,
    AbreviaturaSerieDocumentalExpediente varchar(10) collate database_default,
    IdPeriodo int,
    EsVinculado int,
    CorrelativoVinculado int,
    ObservacionesExpediente varchar(4000) collate database_default,
    IdExpedienteDocumento int,
    IdExpedienteDocumentoOrigenDestino int,
    IdExpedienteDocumentoOrigen int,
    IdCatalogoSituacionMovimientoDestino int,
    CatalogoSituacionMovimientoDestino varchar(400) collate database_default,
    IdCatalogoTipoMovimientoDestino int,
    CatalogoTipoMovimientoDestino varchar(400) collate database_default,
    IdCatalogoTipoDevolucion int,
    NumeroDiasAtencionSolicitado int,
    FechaDestinoRecepciona varchar(10) collate database_default,
    HoraDestinoRecepciona varchar(5) collate database_default,
    NombreEmpresaOrigen varchar(100) collate database_default,
    NombreAreaOrigen varchar(500) collate database_default,
    NombreCargoOrigen varchar(200) collate database_default,
    IdPersonaOrigen int,
    NombreCompletoOrigen varchar(100) collate database_default,
    NombreCompleto varchar(400) collate database_default,
    NumeroDiasAtencionAceptado int,
    Original bit,
    Copia bit,
    FechaDestino varchar(10) collate database_default,
    HoraDestino varchar(5) collate database_default,
    FechaDestinoEnvia varchar(10) collate database_default,
    HoraDestinoEnvia varchar(5) collate database_default,
    NombreEmpresaDestino varchar(100) collate database_default,
    NombreAreaDestino varchar(500) collate database_default,
    NombreCargoDestino varchar(200) collate database_default,
    NombrePersonaDestino varchar(800) collate database_default,
    NombreEmpresaDestinoRecepciona varchar(100) collate database_default,
    NombreAreaDestinoRecepciona varchar(500) collate database_default,
    NombreCargoDestinoRecepciona varchar(200) collate database_default,
    NombrePersonaDestinoRecepciona varchar(400) collate database_default,
    NombreEmpresaDestinoAtencion varchar(100) collate database_default,
    NombreAreaDestinoAtencion varchar(500) collate database_default,
    NombreCargoDestinoAtencion varchar(200) collate database_default,
    NombrePersonaDestinoAtencion varchar(400) collate database_default,
    ObservacionesDestinatario varchar(4000) collate database_default,
    Acciones varchar(max) collate database_default,
    CatalogoTipoDocumento varchar(400) collate database_default,
    NumeroDocumento varchar(601) collate database_default,
    AsuntoDocumento varchar(8000) collate database_default,
    RutaArchivoDocumento varchar(150) collate database_default,
    NumeroExpedienteExterno varchar(100) collate database_default,
    Correlativo int
)

    Declare @vSql nvarchar(max), @vIdPeriodo varchar(4) = cast(@pIdPeriodo as varchar)
    select @vSql = N'
    insert into #tmp001_expedienteHojaRuta
    SELECT E.IdExpediente,E.CelularNotificacion,E.EmailNotificacion,E.NTFechaExpediente,
    ED.FechaEnvioDocumento,E.NumeroExpediente,SD.AbreviaturaSerieDocumentalExpediente,
    E.IdPeriodo,ED.EsVinculado,ED.CorrelativoVinculado,ED.ObservacionesDocumento,
    ED.IdExpedienteDocumento,EDOD.IdExpedienteDocumentoOrigenDestino,EDOD.IdExpedienteDocumentoOrigen,
    EDOD.IdCatalogoSituacionMovimientoDestino,CSM.Descripcion,EDOD.IdCatalogoTipoMovimientoDestino,
    CTM.Descripcion,EDO.IdCatalogoTipodevolucion,EDOD.NumeroDiasAtencionSolicitado,EDOD.FechaDestinoRecepciona,
    EDOD.HoraDestinoRecepciona,EMO.NombreEmpresa,AO.NombreArea,CO.NombreCargo,EDO.IdPersonaOrigen,
    EDO.NombreCompletoOrigen,PO.NombreCompleto,EDOD.NumeroDiasAtencionAceptado,EDOD.Original,EDOD.Copia,
    EDOD.FechaDestino,EDOD.HoraDestino,EDOD.FechaDestinoEnvia,EDOD.HoraDestinoEnvia,EMD.NombreEmpresa,AD.NombreArea,
    CD.NombreCargo,isnull(PD.NombreCompleto, EDOD.DestinatarioDestino),EMR.NombreEmpresa,AR.NombreArea,CR.NombreCargo,
    PR.NombreCompleto,EMA.NombreEmpresa,AA.NombreArea,CA.NombreCargo,PA.NombreCompleto,EDOD.ObservacionesDestinatario,
    Tramite.funMostrarAccionesPorDestinoSoloCodigos(EDOD.IdExpedienteDocumentoOrigenDestino),
    CTD.Descripcion,ED.NumeroDocumento,ED.AsuntoDocumento,ED.RutaArchivoDocumento,E.NumeroExpedienteExterno,ED.Correlativo
    FROM Tramite.Expediente_Historico_' + @vIdPeriodo + N' E
    INNER JOIN Tramite.ExpedienteDocumento_Historico_' + @vIdPeriodo + N' ED
        ON ED.IdExpediente=E.IdExpediente and ED.EstadoAuditoria=1
    INNER JOIN Tramite.ExpedienteDocumentoOrigen_Historico_' + @vIdPeriodo + N' EDO
        ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND EDO.EstadoAuditoria=1
    INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino_Historico_' + @vIdPeriodo + N' EDOD
        ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen AND EDOD.EstadoAuditoria=1
    INNER JOIN Tramite.Catalogo CTD ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
    INNER JOIN Tramite.Catalogo CSM ON CSM.IdCatalogo=EDOD.IdCatalogoSituacionMovimientoDestino
    INNER JOIN Tramite.Catalogo CTM ON CTM.IdCatalogo=EDOD.IdCatalogoTipoMovimientoDestino
    INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
    LEFT JOIN General.Empresa EMO ON EMO.IdEmpresa=EDO.IdEmpresaOrigen
    LEFT JOIN General.Area AO ON AO.IdArea= EDO.IdAreaOrigen
    LEFT JOIN General.Cargo CO ON CO.IdCargo=EDO.IdCargoOrigen
    LEFT JOIN General.Empresa EMD ON EMD.IdEmpresa=EDOD.IdEmpresaDestino
    LEFT JOIN General.Area AD ON AD.IdArea= EDOD.IdAreaDestino
    LEFT JOIN General.Cargo CD ON CD.IdCargo=EDOD.IdCargoDestino
    LEFT JOIN General.Persona PD ON PD.IdPersona=EDOD.IdPersonaDestino
    LEFT JOIN General.Persona PO ON PO.IdPersona=EDO.IdPersonaOrigen
    LEFT JOIN General.Empresa EMR ON EMR.IdEmpresa=EDOD.IdEmpresaDestinoRecepciona
    LEFT JOIN General.Area AR ON AR.IdArea= EDOD.IdAreaDestinoRecepciona
    LEFT JOIN General.Cargo CR ON CR.IdCargo=EDOD.IdCargoDestinoRecepciona
    LEFT JOIN General.Persona PR ON PR.IdPersona=EDOD.IdPersonaDestinoRecepciona
    LEFT JOIN General.Empresa EMA ON EMA.IdEmpresa=EDOD.IdEmpresaDestinoAtencion
    LEFT JOIN General.Area AA ON AA.IdArea= EDOD.IdAreaDestinoAtencion
    LEFT JOIN General.Cargo CA ON CA.IdCargo=EDOD.IdCargoDestinoAtencion
    LEFT JOIN General.Persona PA ON PA.IdPersona=EDOD.IdPersonaDestinoAtencion
    WHERE EDOD.EstadoAuditoria=1 AND E.IdExpediente=@pIdExpediente AND E.EstadoAuditoria=1'

    EXEC sp_executesql @vSql,
    N'@pIdExpediente int',
    @pIdExpediente = @pIdExpediente

    select
    IdExpediente,
    isnull(CelularNotificacion, '') CelularNotificacion,
    isnull(EmailNotificacion,'') EmailNotificacion,
    isnull(NTFechaExpediente,'') NTFechaExpediente,
    isnull(concat(convert(varchar(10), FechaEnvioDocumento, 103), ' ', convert(varchar(8), FechaEnvioDocumento, 108)),'') FechaEnvioDocumento,
    NumeroExpediente,
    concat(AbreviaturaSerieDocumentalExpediente, right(1000000 + NumeroExpediente, 6), '-', IdPeriodo,
    case EsVinculado when 1 then concat('-V-', CorrelativoVinculado) else '' end) NombreExpediente,
    isnull(ObservacionesExpediente,'') ObservacionesExpediente,
    IdExpedienteDocumento,
    IdExpedienteDocumentoOrigenDestino,
    IdExpedienteDocumentoOrigen,
    IdCatalogoSituacionMovimientoDestino,
    CatalogoSituacionMovimientoDestino,
    IdCatalogoTipoMovimientoDestino,
    CatalogoTipoMovimientoDestino,
    isnull(IdCatalogoTipoDevolucion, 0) IdCatalogoTipoDevolucion,
    NumeroDiasAtencionSolicitado,
    isnull(FechaDestinoRecepciona,'') FechaDestinoRecepciona,
    isnull(HoraDestinoRecepciona,'') HoraDestinoRecepciona,
    isnull(NombreEmpresaOrigen,'EXTERNO') NombreEmpresaOrigen,
    isnull(NombreAreaOrigen,'') NombreAreaOrigen,
    isnull(NombreCargoOrigen,'') NombreCargoOrigen,
    isnull(NombreCompletoOrigen, case when IdPersonaOrigen != 0 then isnull(NombreCompleto,'') else '' end) NombrePersonaOrigen,
    NumeroDiasAtencionAceptado,
    Original,
    Copia,
    FechaDestino,
    HoraDestino,
    isnull(FechaDestinoEnvia,'') FechaDestinoEnvia,
    isnull(HoraDestinoEnvia,'') HoraDestinoEnvia,
    isnull(NombreEmpresaDestino,'') NombreEmpresaDestino,
    isnull(NombreAreaDestino,'') NombreAreaDestino,
    isnull(NombreCargoDestino,'') NombreCargoDestino,
    isnull(NombrePersonaDestino,'') NombrePersonaDestino,
    isnull(NombreEmpresaDestinoRecepciona,'EXTERNO') NombreEmpresaDestinoRecepciona,
    isnull(NombreAreaDestinoRecepciona,'') NombreAreaDestinoRecepciona,
    isnull(NombreCargoDestinoRecepciona,'') NombreCargoDestinoRecepciona,
    isnull(NombrePersonaDestinoRecepciona,'') NombrePersonaDestinoRecepciona,
    isnull(NombreEmpresaDestinoAtencion,'EXTERNO') NombreEmpresaDestinoAtencion,
    isnull(NombreAreaDestinoAtencion,'') NombreAreaDestinoAtencion,
    isnull(NombreCargoDestinoAtencion,'') NombreCargoDestinoAtencion,
    isnull(NombrePersonaDestinoAtencion,'') NombrePersonaDestinoAtencion,
    isnull(ObservacionesDestinatario,'') ObservacionesDestinatario,
    Acciones,
    isnull(CatalogoTipoDocumento,'') CatalogoTipoDocumento,
    case Correlativo when 0 then concat(CatalogoTipoDocumento, ' ',NumeroDocumento) else isnull(NumeroDocumento,'') end NumeroDocumento,
    isnull(AsuntoDocumento,'') AsuntoDocumento,
    isnull(RutaArchivoDocumento,'') RutaArchivoDocumento,
    isnull(NumeroExpedienteExterno,'') NumeroExpedienteExterno
    from #tmp001_expedienteHojaRuta
    order by convert(datetime, FechaDestino +' '+ HoraDestino)


END TRY
BEGIN CATCH
    DECLARE @ERROR_NUMBER INT
    DECLARE @ERROR_SEVERITY INT
    DECLARE @ERROR_STATE INT
    DECLARE @ERROR_PROCEDURE VARCHAR(MAX)
    DECLARE @ERROR_LINE INT
    DECLARE @ERROR_MESSAGE VARCHAR(MAX)
    SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() ,
    @ERROR_PROCEDURE='Tramite.paListarDocumentoHojaRuta_arq',
    @ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
    EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
END CATCH
END
go

exec Tramite.paListarDocumentoHojaRuta_arq 570251,79,1059, 2025


-- cross apply(
--     select concat(convert(varchar(10), FechaEnvioDocumento, 103), ' ', convert(varchar(8), FechaEnvioDocumento, 108))fecha
-- )f
