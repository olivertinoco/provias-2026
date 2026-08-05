CREATE PROCEDURE [Tramite].[paListarDocumentoOrigenDestinoHojaRuta]
    @pIdExpediente int,
    @pIdArea int,
    @pEsVinculado int,
    @pCorrelativoVinculado int,
    @pIdUsuarioAuditoria int
AS
BEGIN
SET LANGUAGE 'SPANISH'
BEGIN TRY

        SELECT
        E.IdExpediente,
		COALESCE(E.CelularNotificacion,'')CelularNotificacion,
		COALESCE(E.EmailNotificacion,'')EmailNotificacion,
		E.NumeroExpediente,
		COALESCE(E.NTFechaExpediente,'')NTFechaExpediente,
		CONCAT(SD.AbreviaturaSerieDocumentalExpediente +RIGHT('000000'+CONVERT(VARCHAR,E.NumeroExpediente),6), '-', E.IdPeriodo,CASE WHEN ED.EsVinculado=1 THEN CONCAT('- V-',ED.CorrelativoVinculado) else '' END)NombreExpediente,
        COALESCE(ED.ObservacionesDocumento,'')ObservacionesExpediente,
        ED.IdExpedienteDocumento,
        EDOD.IdExpedienteDocumentoOrigenDestino,
        EDOD.IdExpedienteDocumentoOrigen,
        EDOD.IdCatalogoSituacionMovimientoDestino,
        CSM.Descripcion CatalogoSituacionMovimientoDestino,
        EDOD.IdCatalogoTipoMovimientoDestino,
        CTM.Descripcion CatalogoTipoMovimientoDestino,
        COALESCE(EDO.IdCatalogoTipodevolucion,0) IdCatalogoTipoDevolucion,
        EDOD.NumeroDiasAtencionSolicitado,
        COALESCE(EDOD.FechaDestinoRecepciona,'')FechaDestinoRecepciona,
        COALESCE(EDOD.HoraDestinoRecepciona,'')HoraDestinoRecepciona,
        COALESCE(EMO.NombreEmpresa,'EXTERNO') NombreEmpresaOrigen,
        COALESCE(AO.NombreArea,'') NombreAreaOrigen,
        COALESCE(CO.NombreCargo,'') NombreCargoOrigen,
        CASE WHEN EDO.IdPersonaOrigen=0 THEN EDO.NombreCompletoOrigen ELSE PO.NombreCompleto END  NombrePersonaOrigen,
        EDOD.NumeroDiasAtencionAceptado,
        EDOD.Original,
        EDOD.Copia,
        EDOD.FechaDestino,
        EDOD.HoraDestino,
        COALESCE(EDOD.FechaDestinoEnvia,'') FechaDestinoEnvia,
        COALESCE(EDOD.HoraDestinoEnvia,'') HoraDestinoEnvia,

		COALESCE(EMD.NombreEmpresa,'') NombreEmpresaDestino,
        COALESCE(AD.NombreArea,'') NombreAreaDestino,
        COALESCE(CD.NombreCargo,'') NombreCargoDestino,
        COALESCE(PD.NombreCompleto,COALESCE(EDOD.DestinatarioDestino,'')) NombrePersonaDestino,
        COALESCE(EMR.NombreEmpresa,'EXTERNO') NombreEmpresaDestinoRecepciona,
        COALESCE(AR.NombreArea,'') NombreAreaDestinoRecepciona,
        COALESCE(CR.NombreCargo,'') NombreCargoDestinoRecepciona,
        COALESCE(PR.NombreCompleto,'') NombrePersonaDestinoRecepciona,
        COALESCE(EMA.NombreEmpresa,'EXTERNO') NombreEmpresaDestinoAtencion,
        COALESCE(AA.NombreArea,'') NombreAreaDestinoAtencion,
        COALESCE(CA.NombreCargo,'') NombreCargoDestinoAtencion,
        COALESCE(PA.NombreCompleto,'') NombrePersonaDestinoAtencion,
        COALESCE(EDOD.ObservacionesDestinatario,'') ObservacionesDestinatario,
        Tramite.funMostrarAccionesPorDestinoConCodigo(EDOD.IdExpedienteDocumentoOrigenDestino) Acciones,

        CTD.Descripcion CatalogoTipoDocumento,
        CASE WHEN ED.Correlativo=0 THEN  CONCAT( CTD.Descripcion,' ', COALESCE(ED.NumeroDocumento,'')) ELSE COALESCE(ED.NumeroDocumento,'') END  NumeroDocumento,
        COALESCE(ED.AsuntoDocumento,'') AsuntoDocumento,
        COALESCE(ED.RutaArchivoDocumento,'') RutaArchivoDocumento,
		COALESCE(e.NumeroExpedienteExterno,'') NumeroExpedienteExterno
        FROM Tramite.Expediente E
        INNER JOIN Tramite.ExpedienteDocumento ED ON ED.IdExpediente=E.IdExpediente and ED.EstadoAuditoria=1
        INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND EDO.EstadoAuditoria=1
        INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen  AND EDOD.EstadoAuditoria=1
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
        WHERE E.EstadoAuditoria=1 AND E.IdExpediente=@pIdExpediente and /*coalesce(ED.EsVinculado,0)=@pEsVinculado AND*/ coalesce(ED.CorrelativoVinculado,0)=@pCorrelativoVinculado
    ORDER BY   convert(datetime,EDOD.FechaDestino +' '+ EDOD.HoraDestino)

END TRY
BEGIN CATCH
    DECLARE @ERROR_NUMBER INT
    DECLARE @ERROR_SEVERITY INT
    DECLARE @ERROR_STATE INT
    DECLARE @ERROR_PROCEDURE VARCHAR(MAX)
    DECLARE @ERROR_LINE INT
    DECLARE @ERROR_MESSAGE VARCHAR(MAX)
    SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarDocumentoOrigenDestinoHojaRuta',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
    EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
END CATCH
END
