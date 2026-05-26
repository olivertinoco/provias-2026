ALTER PROCEDURE Tramite.paListarDocumentoOrigenDestinoHojaRuta_arq
	@pIdExpediente int,
	@pIdArea int,
	@pEsVinculado int,
	@pCorrelativoVinculado int,
	@pIdUsuarioAuditoria int,
	@pIdPeriodo int
AS
BEGIN
BEGIN TRY
SET LANGUAGE SPANISH
set nocount on
set tran isolation level read uncommitted

create table #tmp001_Expediente(
    IdExpediente int,
    CelularNotificacion varchar(100) collate database_default,
    EmailNotificacion varchar(100) collate database_default,
    NumeroExpediente int,
    NTFechaExpediente varchar(10) collate database_default,
    NombreExpediente varchar(45) collate database_default,
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
    NombrePersonaOrigen varchar(400) collate database_default,
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
    Acciones varchar(8000) collate database_default,
    CatalogoTipoDocumento varchar(400) collate database_default,
    NumeroDocumento varchar(601) collate database_default,
    AsuntoDocumento varchar(8000) collate database_default,
    RutaArchivoDocumento varchar(150) collate database_default,
    NumeroExpedienteExterno varchar(100) collate database_default,
    Correlativo int
)
Declare @vSql nvarchar(max), @vIdPeriodo varchar(4) = convert(varchar, @pIdPeriodo)

    select @vSql = N'
    insert into #tmp001_Expediente
	SELECT
	E.IdExpediente,
	E.CelularNotificacion,
	E.EmailNotificacion,
	E.NumeroExpediente,
	E.NTFechaExpediente,
	CONCAT(SD.AbreviaturaSerieDocumentalExpediente, RIGHT(''000000''+CONVERT(VARCHAR,E.NumeroExpediente),6), ''-'', E.IdPeriodo,
	CASE WHEN ED.EsVinculado=1 THEN CONCAT(''- V-'',ED.CorrelativoVinculado) else '''' END)NombreExpediente,
	ED.ObservacionesDocumento,
	ED.IdExpedienteDocumento,
	EDOD.IdExpedienteDocumentoOrigenDestino,
	EDOD.IdExpedienteDocumentoOrigen,
	EDOD.IdCatalogoSituacionMovimientoDestino,
	CSM.Descripcion,
	EDOD.IdCatalogoTipoMovimientoDestino,
	CTM.Descripcion,
	EDO.IdCatalogoTipodevolucion,
	EDOD.NumeroDiasAtencionSolicitado,
	EDOD.FechaDestinoRecepciona,
	EDOD.HoraDestinoRecepciona,
	EMO.NombreEmpresa,
	AO.NombreArea,
	CO.NombreCargo,
	CASE WHEN EDO.IdPersonaOrigen = 0 THEN ISNULL(EDO.NombreCompletoOrigen, '''') ELSE
	COALESCE(NULLIF(EDO.NombreCompletoOrigen, ''''), PO.NombreCompleto, '''') END,
	EDOD.NumeroDiasAtencionAceptado,
	EDOD.Original,
	EDOD.Copia,
	EDOD.FechaDestino,
	EDOD.HoraDestino,
	EDOD.FechaDestinoEnvia,
	EDOD.HoraDestinoEnvia,
	EMD.NombreEmpresa,
	AD.NombreArea,
	CD.NombreCargo,
	COALESCE(PD.NombreCompleto,EDOD.DestinatarioDestino,''''),
	EMR.NombreEmpresa,
	AR.NombreArea,
	CR.NombreCargo,
	PR.NombreCompleto,
	EMA.NombreEmpresa,
	AA.NombreArea,
	CA.NombreCargo,
	PA.NombreCompleto,
	EDOD.ObservacionesDestinatario,
	Tramite.funMostrarAccionesPorDestinoSoloCodigos(EDOD.IdExpedienteDocumentoOrigenDestino),
	CTD.Descripcion,
	ED.NumeroDocumento,
	ED.AsuntoDocumento,
	ED.RutaArchivoDocumento,
	e.NumeroExpedienteExterno,
	ED.Correlativo
	FROM Tramite.Expediente_Historico_' + @vIdPeriodo + N' E
	INNER JOIN Tramite.ExpedienteDocumento_Historico_' + @vIdPeriodo + N' ED
	    ON ED.IdExpediente = E.IdExpediente
		AND ED.EstadoAuditoria = 1
	INNER JOIN Tramite.ExpedienteDocumentoOrigen_Historico_' + @vIdPeriodo + N' EDO
	    ON EDO.IdExpedienteDocumento = ED.IdExpedienteDocumento
		AND EDO.EstadoAuditoria = 1
	INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino_Historico_' + @vIdPeriodo + N' EDOD
	    ON EDOD.IdExpedienteDocumentoOrigen = EDO.IdExpedienteDocumentoOrigen
		AND EDOD.EstadoAuditoria = 1
	INNER JOIN Tramite.Catalogo CTD
	    ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
	INNER JOIN Tramite.Catalogo CSM
	    ON CSM.IdCatalogo=EDOD.IdCatalogoSituacionMovimientoDestino
	INNER JOIN Tramite.Catalogo CTM
	    ON CTM.IdCatalogo=EDOD.IdCatalogoTipoMovimientoDestino
	INNER JOIN Tramite.SerieDocumentalExpediente SD
	    ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
	LEFT JOIN General.Empresa EMO
	    ON EMO.IdEmpresa=EDO.IdEmpresaOrigen
	LEFT JOIN General.Area AO
	    ON AO.IdArea= EDO.IdAreaOrigen
	LEFT JOIN General.Cargo CO
	    ON CO.IdCargo=EDO.IdCargoOrigen
	LEFT JOIN General.Empresa EMD
	    ON EMD.IdEmpresa=EDOD.IdEmpresaDestino
	LEFT JOIN General.Area AD
	    ON AD.IdArea= EDOD.IdAreaDestino
	LEFT JOIN General.Cargo CD
	    ON CD.IdCargo=EDOD.IdCargoDestino
	LEFT JOIN General.Persona PD
	    ON PD.IdPersona=EDOD.IdPersonaDestino
	LEFT JOIN General.Persona PO
	    ON PO.IdPersona=EDO.IdPersonaOrigen
	LEFT JOIN General.Empresa EMR
	    ON EMR.IdEmpresa=EDOD.IdEmpresaDestinoRecepciona
	LEFT JOIN General.Area AR
	    ON AR.IdArea= EDOD.IdAreaDestinoRecepciona
	LEFT JOIN General.Cargo CR
	    ON CR.IdCargo=EDOD.IdCargoDestinoRecepciona
	LEFT JOIN General.Persona PR
	    ON PR.IdPersona=EDOD.IdPersonaDestinoRecepciona
	LEFT JOIN General.Empresa EMA
	    ON EMA.IdEmpresa=EDOD.IdEmpresaDestinoAtencion
	LEFT JOIN General.Area AA
	    ON AA.IdArea= EDOD.IdAreaDestinoAtencion
	LEFT JOIN General.Cargo CA
	    ON CA.IdCargo=EDOD.IdCargoDestinoAtencion
	LEFT JOIN General.Persona PA
	    ON PA.IdPersona=EDOD.IdPersonaDestinoAtencion
	WHERE E.EstadoAuditoria=1
	    AND E.IdExpediente=@pIdExpediente
		AND coalesce(ED.CorrelativoVinculado,0)=@pCorrelativoVinculado'

	EXEC sp_executesql @vSql,
	    N'@pIdExpediente int, @pCorrelativoVinculado int',
		@pIdExpediente = @pIdExpediente,
		@pCorrelativoVinculado = @pCorrelativoVinculado


	select
    IdExpediente,
    isnull(CelularNotificacion,'') CelularNotificacion,
    isnull(EmailNotificacion,'') EmailNotificacion,
    NumeroExpediente,
    isnull(NTFechaExpediente,'') NTFechaExpediente,
    NombreExpediente,
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
    isnull(NombreEmpresaOrigen, 'EXTERNO') NombreEmpresaOrigen,
    isnull(NombreAreaOrigen, '') NombreAreaOrigen,
    isnull(NombreCargoOrigen, '') NombreCargoOrigen,
    NombrePersonaOrigen,
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
    NombrePersonaDestino,
    isnull(NombreEmpresaDestinoRecepciona, 'EXTERNO') NombreEmpresaDestinoRecepciona,
    isnull(NombreAreaDestinoRecepciona,'') NombreAreaDestinoRecepciona,
    isnull(NombreCargoDestinoRecepciona,'') NombreCargoDestinoRecepciona,
    isnull(NombrePersonaDestinoRecepciona,'') NombrePersonaDestinoRecepciona,
    isnull(NombreEmpresaDestinoAtencion, 'EXTERNO') NombreEmpresaDestinoAtencion,
    isnull(NombreAreaDestinoAtencion, '') NombreAreaDestinoAtencion,
    isnull(NombreCargoDestinoAtencion, '') NombreCargoDestinoAtencion,
    isnull(NombrePersonaDestinoAtencion, '') NombrePersonaDestinoAtencion,
    isnull(ObservacionesDestinatario, '') ObservacionesDestinatario,
    Acciones,
    CatalogoTipoDocumento,
    case Correlativo when 0 then concat(CatalogoTipoDocumento,' ', NumeroDocumento) else NumeroDocumento end NumeroDocumento,
    isnull(AsuntoDocumento,'') AsuntoDocumento,
    isnull(RutaArchivoDocumento,'') RutaArchivoDocumento,
    isnull(NumeroExpedienteExterno,'') NumeroExpedienteExterno
from #tmp001_Expediente
ORDER BY convert(datetime,FechaDestino +' '+ HoraDestino)


END TRY
BEGIN CATCH
	DECLARE @ERROR_NUMBER INT
	DECLARE @ERROR_SEVERITY INT
	DECLARE @ERROR_STATE INT
	DECLARE @ERROR_PROCEDURE VARCHAR(MAX)
	DECLARE @ERROR_LINE INT
	DECLARE @ERROR_MESSAGE VARCHAR(MAX)
	SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE(),
	@ERROR_PROCEDURE='Tramite.paListarDocumentoOrigenDestinoHojaRuta_arq',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
END CATCH
END
GO


-- exec tramite.paListarDocumentoOrigenDestinoHojaRuta_arq 506370, null, null, 0, null, 2025
