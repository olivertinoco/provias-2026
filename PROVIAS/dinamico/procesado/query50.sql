-- CREATE PROCEDURE Tramite.paListarExpedienteAcervoDocumentalExportarExcelEspecialista
declare
    @pIdAreaEmisor INT,
    @pIdPersona INT,
    @pIdUsuarioAuditoria int,
    @pIdPeriodo int,
    @pIdCatalogoTipoDocumento int,
    @pAsuntoDocumento varchar(500),
    @pNumeroDocumento varchar(100),
    @pFechaDocumento varchar(30)
-- AS
-- BEGIN
-- BEGIN TRY
	declare @vFechaInicial varchaR(10)
	declare @vFechaFinal varchaR(10)

select
@pIdAreaEmisor=79,
@pIdPersona=1059,
@pIdUsuarioAuditoria=1059,
@pIdPeriodo=2025,
@pIdCatalogoTipoDocumento=0,
@pAsuntoDocumento='',
@pNumeroDocumento='',
@pFechaDocumento='01/07/2025 - 08/07/2026'


	IF COALESCE(@pFechaDocumento,'')<>''
	begin
		SET @vFechaInicial=left(@pFechaDocumento,10)
		SET @vFechaFinal=RIGHT(@pFechaDocumento,10)
		if @vFechaInicial=@vFechaFinal
		begin
			set @pFechaDocumento=''
		end
	end
    set language spanish


	SELECT Periodo,[Tipo Documento],Expediente,Anulado,NombreArea[Nombre Area],NombreCargo[Nombre Cargo],NombreCompleto[Nombre Completo],Documento, [Fecha documento],
	Asunto,Observaciones,Destinatario,Logueo FROM (
		SELECT DISTINCT
		year(ED.NFechaDocumento) Periodo,
		CTD.Descripcion [Tipo Documento],
		CONCAT(SD.AbreviaturaSerieDocumentalExpediente +RIGHT('000000'+CONVERT(VARCHAR,E.NumeroExpediente),6), '-', E.IdPeriodo) Expediente ,
		CASE WHEN E.ExpedienteAnulado=0 THEN 'NO' ELSE 'SI' END Anulado,
		COALESCE(A.NombreArea,'')NombreArea,
		COALESCE(C.NombreCargo,'')NombreCargo,
		COALESCE(P.NombreCompleto,'')NombreCompleto,
		COALESCE(ED.NumeroDocumento,'') Documento,
		ED.NFechaDocumento [Fecha documento],
		UPPER(COALESCE(ED.AsuntoDocumento,'')) Asunto,
		COALESCE(ED.ObservacionesDocumento,'') Observaciones,
		COALESCE(ED.Correlativo,'')Correlativo,
		Tramite.funMostrarDesatinatarios(EDO.IdExpedienteDocumentoOrigen) Destinatario,
		u.Logueo
		FROM Tramite.Expediente E
		INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
		INNER JOIN Tramite.ExpedienteDocumento ED ON ED.IdExpediente=E.IdExpediente
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen  AND EDO.EstadoAuditoria=1  and edod.EsInicial<>0
		INNER JOIN Tramite.Catalogo CTD ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
		LEFT JOIN General.Cargo C ON C.IdCargo=ED.IdCargoEmisor
		LEFT JOIN General.Area A ON A.IdArea=ED.IdAreaEmisor
		LEFT JOIN General.Empresa EM ON EM.IdEmpresa=ED.IdEmpresaEmisor
		LEFT JOIN General.Persona P ON P.IdPersona=ED.IdPersonaEmisor
		LEFT JOIN Seguridad.Usuario U on U.IdUsuario=E.IdUsuarioCreacionAuditoria
		WHERE EDOD.EstadoAuditoria=1 AND (@pIdCatalogoTipoDocumento=0 or ED.IdCatalogoTipoDocumento = @pIdCatalogoTipoDocumento) AND ED.IdAreaEmisor=@pIdAreaEmisor AND (@pIdPersona=0 OR ED.IdPersonaEmisor=@pIdPersona)
		)X
	WHERE 1=1  AND
	(@pIdPeriodo=0 or X.Periodo =@pIdPeriodo) AND
	(@pAsuntoDocumento='' or X.Asunto LIKE '%'+@pAsuntoDocumento+'%') AND
	(@pNumeroDocumento='' or X.Documento LIKE '%'+@pNumeroDocumento+'%') AND
	(convert(date,X.[Fecha documento]) between case when coalesce(@pFechaDocumento,'')<>'' then convert(date,@vFechaInicial) else X.[Fecha documento] end AND case when coalesce(@pFechaDocumento,'')<>'' then convert(date,@vFechaFinal) else X.[Fecha documento] end)
	ORDER BY X.[Tipo Documento], X.Correlativo




-- END TRY
-- BEGIN CATCH
--     DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX) ,@ERROR_MESSAGE VARCHAR(MAX)
--     SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarDocumentoPendienteJefatura',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()

--     EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
-- END CATCH
-- END
-- GO



execute [bd_sgd_arq].[Tramite].[paListarExpedienteAcervoDocumentalExportarExcelEspecialista] 79,1059,1059,2025,0,'','', '01/07/2025 - 08/07/2026' --PERFIL ESPECIALISTA





--NUEVA CONDICIÓN A MODIFICAR:
Si el parámetro '@pFechaDocumento' es '' buscar todos los expedientes del período que viene en el parámetro '@pIdPeriodo'
caso contrario si el parámetro '@pFechaDocumento' no es '' buscas todos los expedientes en ese rango de fechas


execute [Tramite].[paListarExpedienteAcervoDocumentalExportarExcelEspecialista] 79,1059,1059,2025,0,'','', '01/07/2025 - 08/07/2026' --PERFIL ESPECIALISTA

execute [Tramite].paListarExpedienteAcervoDocumentalExportarExcelJefaturaV1 79,0,349,2025,0,'','', '01/07/2025 - 08/07/2026' --PERFIL JEFE
execute [Tramite].paListarExpedienteAcervoDocumentalExportarExcelJefaturaV1 30,0,53721,2025,0,'','', '01/07/2025 - 08/07/2026' --PERFIL JEFE
execute [Tramite].paListarExpedienteAcervoDocumentalExportarExcelJefaturaV1 79,0,39212,2026,0,'','', '01/07/2025 - 08/07/2026' --PERFIL SECRETARIA
