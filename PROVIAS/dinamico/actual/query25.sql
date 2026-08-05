CREATE PROCEDURE [Tramite].[paListarExpedienteAcervoDocumentalExportarExcelJefaturaV1]
    @pIdAreaEmisor INT,
    @pIdPersona INT,
    @pIdUsuarioAuditoria int,
    @pIdPeriodo int,
    @pIdCatalogoTipoDocumento int,
    @pAsuntoDocumento varchar(500),
    @pNumeroDocumento varchar(100),
    @pFechaDocumento varchar(30)
AS
BEGIN TRY
declare @vFechaInicial varchaR(10)
declare @vFechaFinal varchaR(10)

	IF COALESCE(@pFechaDocumento,'')<>''
	begin
		SET @vFechaInicial=left(@pFechaDocumento,10)
		SET @vFechaFinal=RIGHT(@pFechaDocumento,10)
		if @vFechaInicial=@vFechaFinal
		begin
			set @pFechaDocumento=''
		end
	end

    set language 'spanish'
    SELECT Periodo,[Tipo Documento],Expediente,Anulado,NombreEmpresa[Razon Social],NombreArea[Nombre Area],NombreCargo[Nombre Cargo],NombreCompleto[Nombre Completo],Documento, [Fecha documento],Asunto,Observaciones,Destinatario,Logueo FROM (
       	SELECT
		DISTINCT
		--E.IdPeriodo Periodo,
		year(ED.NFechaDocumento) Periodo,
		CTD.Descripcion [Tipo Documento],
		CONCAT(SD.AbreviaturaSerieDocumentalExpediente +RIGHT('000000'+CONVERT(VARCHAR,E.NumeroExpediente),6), '-', E.IdPeriodo) Expediente ,
		CASE WHEN E.ExpedienteAnulado=0 THEN 'NO' ELSE 'SI' END Anulado,
		COALESCE(EM.NombreEmpresa,'EXTERNO')NombreEmpresa,
		COALESCE(A.NombreArea,'')NombreArea,
		COALESCE(C.NombreCargo,'')NombreCargo,
		COALESCE(P.NombreCompleto,'')NombreCompleto,

		COALESCE(ED.NumeroDocumento,'') Documento,
		ED.NFechaDocumento [Fecha documento],
		UPPER(COALESCE(ED.AsuntoDocumento,'')) Asunto,
		COALESCE(ED.ObservacionesDocumento,'') Observaciones,
		COALESCE(ED.Correlativo,'')Correlativo,
		Tramite.funMostrarDesatinatarios(EDO.IdExpedienteDocumentoOrigen) Destinatario
		,u.Logueo
		FROM
		Tramite.Expediente E
		INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
		INNER JOIN Tramite.ExpedienteDocumento ED ON ED.IdExpediente=E.IdExpediente
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen  AND EDO.EstadoAuditoria=1  and edod.EsInicial<>0
		INNER JOIN Tramite.Catalogo CTD ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
		LEFT JOIN General.Cargo C ON C.IdCargo=ED.IdCargoEmisor
		LEFT JOIN General.Area A ON A.IdArea=ED.IdAreaEmisor
		LEFT JOIN General.Empresa EM ON EM.IdEmpresa=ED.IdEmpresaEmisor
		LEFT JOIN General.Persona P ON P.IdPersona=ED.IdPersonaEmisor
		LEFT JOIN Seguridad.Usuario U on U.IdUsuario=E.IdUsuarioCreacionAuditoria --and u.EstadoAuditoria=1
		WHERE EDOD.EstadoAuditoria=1 AND (@pIdCatalogoTipoDocumento=0 or ED.IdCatalogoTipoDocumento = @pIdCatalogoTipoDocumento) AND ED.IdAreaEmisor=@pIdAreaEmisor AND (@pIdPersona=0 OR ED.IdPersonaEmisor=@pIdPersona) --AND ED.IdCargoEmisor IN (SELECT DISTINCT IdCargo FROM RecursoHumano.visPersonaJefe)
		)X WHERE 1=1  AND
		(@pIdPeriodo=0 or X.Periodo =@pIdPeriodo) AND
		(@pAsuntoDocumento='' or X.Asunto LIKE '%'+@pAsuntoDocumento+'%') AND
		(@pNumeroDocumento='' or X.Documento LIKE '%'+@pNumeroDocumento+'%') AND
		(convert(date,X.[Fecha documento]) between case when coalesce(@pFechaDocumento,'')<>'' then convert(date,@vFechaInicial) else X.[Fecha documento] end AND case when coalesce(@pFechaDocumento,'')<>'' then convert(date,@vFechaFinal) else X.[Fecha documento] end  )
		ORDER BY X.[Tipo Documento], X.Correlativo

END TRY
BEGIN CATCH
    DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX) ,@ERROR_MESSAGE VARCHAR(MAX)
    SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarDocumentoPendienteJefatura',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
    EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
END CATCH
