CREATE PROCEDURE [Tramite].[paObtenerExpedienteDocumento]
	@pIdExpedienteDocumento INT
AS
BEGIN
BEGIN TRY
SET LANGUAGE 'SPANISH'

     SELECT
	 Tramite.funTieneMovimiento(E.IdExpedienteDocumento) EsRecepcionado,
        E.IdExpedienteDocumento
        ,E.IdExpediente
        ,EX.AsuntoExpediente
        ,E.IdCatalogoTipoDocumento
        ,C.Descripcion CatalogoTipoDocumento
        ,coalesce(E.IdCatalogoTipoMovimientoDocumento,0)IdCatalogoTipoMovimientoDocumento
        ,coalesce(CTM.Descripcion ,'')CatalogoTipoMovimientoDocumento
        ,E.IdEmpresaEmisor
        ,COALESCE(EM.NombreEmpresa,'') NombreEmpresa
        ,E.IdAreaEmisor
        ,COALESCE(AE.NombreArea,'')NombreArea
        ,E.IdCargoEmisor
        ,COALESCE(CE.NombreCargo,'')NombreCargo
        ,E.IdPersonaEmisor
        ,coalesce(CASE WHEN E.IdPersonaEmisor=0 THEN E.NombreCompletoEmisor ELSE PM.NombreCompleto END,'')NombreCompletoEmisor
        --,PM.NombreCompleto NombreCompletoEmisor
        ,CASE WHEN E.Correlativo=0 THEN  CONCAT( C.Descripcion,' ', COALESCE(E.NumeroDocumento,'')) ELSE COALESCE(E.NumeroDocumento,'') END  NumeroDocumento
        ,case when (E.NumeroFoliosDocumento=0) then EX.NumeroFoliosExpediente else E.NumeroFoliosDocumento end NumeroFoliosDocumento
        ,E.AsuntoDocumento
        ,E.NFechaDocumento
        ,CASE WHEN E.FgEsObservado=1 THEN CASE WHEN E.FgEsCorregido=1 THEN E.RutaArchivoDocumentoCorregido ELSE E.RutaArchivoDocumento END ELSE E.RutaArchivoDocumento END RutaArchivoDocumento
        ,E.ObservacionesDocumento
	 ,coalesce(E.LinkArchivoCompartido,'')LinkArchivoCompartido
	 ,EX.FgTramiteVirtual
	 ,CONCAT(SD.AbreviaturaSerieDocumentalExpediente +RIGHT('000000'+CONVERT(VARCHAR,EX.NumeroExpediente),6), '-', EX.IdPeriodo)NombreExpediente
	 ,coalesce(E.DescripcionCorreccion,'')DescripcionCorreccion
	 ,coalesce(E.DescripcionObervacionIngresada,'')DescripcionObervacionIngresada
	 ,coalesce(E.NFechaDocumentoCorregido,'')NFechaDocumentoCorregido
	 ,coalesce(convert(varchar,E.FechaEnvioDocumentoCorregido,103),'') + ' '+ coalesce(CONVERT(varchar,E.FechaEnvioDocumentoCorregido,108),'')FechaEnvioDocumentoCorregido
	,concat(coalesce(convert(varchar(10),E.FechaEnvioDocumento,103),''),' ',coalesce(convert(varchar(10),E.FechaEnvioDocumento,108),'') )FechaEnvioDocumento

	,coalesce(EXV.NombreCompletoNoticado,coalesce(EX.NombreCompletoNoticado,''))NombreCompletoNoticado
	,coalesce(EXV.EmailNotificacion,coalesce(EX.EmailNotificacion,''))EmailNotificacion
	,coalesce(EXV.CelularNotificacion,coalesce(EX.CelularNotificacion,''))CelularNotificacion
	,coalesce(EXV.TelefonoNotificacion,coalesce(EX.TelefonoNotificacion,''))TelefonoNotificacion
	,coalesce(EXV.DireccionNotificacion,coalesce(EX.DireccionNotificacion,''))DireccionNotificacion
	,E.FgEnEsperaFirmaDigital
	,E.FgEsObligatorioFirmaDigital
	,COALESCE(E.FechaHoraFirmaDigital,'')FechaHoraFirmaDigital
	,E.FlagParaDespacho
	,E.Correlativo
	--,CASE WHEN YEAR(DATEADD(MONTH,-1,E.FechaCreacionAuditoria))=YEAR(GETDATE()) THEN '' ELSE convert(varchar,YEAR(DATEADD(MONTH,-1,E.FechaCreacionAuditoria))) END PeriodoCreadoDocumento
	,Tramite.funDevolverPeriodoDocumento(GETDATE(),E.FechaCreacionAuditoria) PeriodoCreadoDocumento
        FROM
        Tramite.ExpedienteDocumento E
        INNER join Tramite.Expediente EX on EX.IdExpediente=E.IdExpediente
	 LEFT join Tramite.Expediente EXV on EXV.IdExpediente=E.IdExpedienteVirtual
        INNER join Tramite.Catalogo C on C.IdCatalogo=E.IdCatalogoTipoDocumento
	 INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente=EX.IdSerieDocumentalExpediente
        left join General.Empresa EM on EM.IdEmpresa=E.IdEmpresaEmisor
        left join General.Area AE on AE.IdArea=E.IdAreaEmisor

        left join General.Cargo CE on CE.IdCargo=E.IdCargoEmisor
        left join General.Persona PM on PM.IdPersona=E.IdPersonaEmisor
        left join Tramite.Catalogo CTM on CTM.IdCatalogo=E.IdCatalogoTipoMovimientoDocumento
        WHERE E.IdExpedienteDocumento=@pIdExpedienteDocumento AND E.EstadoAuditoria=1

END TRY
BEGIN CATCH
	DECLARE @ERROR_NUMBER INT
	DECLARE @ERROR_SEVERITY INT
	DECLARE @ERROR_STATE INT
	DECLARE @ERROR_PROCEDURE VARCHAR(MAX)
	DECLARE @ERROR_LINE INT
	DECLARE @ERROR_MESSAGE VARCHAR(MAX)
	SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paObtenerExpedienteDocumento',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
END CATCH
END
