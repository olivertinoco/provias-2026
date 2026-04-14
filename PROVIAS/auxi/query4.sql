	-- CREATE FUNCTION [Tramite].[fnObtenerOrigenInicialDocumento]
 --  (
 declare
    @pIdExpediente int
-- 	)
-- RETURNS varchar(100)
-- AS
-- BEGIN
   DECLARE @vCatalogoTipoOrigen varchar(100)=''
  select top 1 @vCatalogoTipoOrigen=CONCAT(coalesce(c.Descripcion,''),' ',EX.NumeroExpedienteExterno)
  from Tramite.ExpedienteDocumento e  WITH (NOLOCK)
  INNER JOIN Tramite.Expediente EX  WITH (NOLOCK)
    ON EX.IdExpediente=E.IdExpediente
  INNER JOIN Tramite.Catalogo c
    on c.IdCatalogo=e.IdCatalogoTipoOrigen
  where
    e.EstadoAuditoria=1 and e.IdExpediente=@pIdExpediente
  order by e.IdExpedienteDocumento

  return @vCatalogoTipoOrigen
-- END
--
--
--
--



-- CREATE function [Tramite].[funObtenerNumeroDocumentoEnExpedienteEspecialistaV1](
declare
@pIdExpediente INT,
 @pIdArea INT,
 @pIdCargo INT,
 @pIdPersona INT,
 @pIdCatalogoSituacionMovimientoDestino int
-- )
-- RETURNS VARCHAr(4000)
-- AS
-- BEGIN
	DECLARE @vNumeroDocumento VARCHAR(4000) =''
	IF @pIdCatalogoSituacionMovimientoDestino IN(4,5,112)
	BEGIN
		SELECT
		TOP 1 @vNumeroDocumento =
		'<button type="button" data-toggle="tooltip" title="'+
		COALESCE(EDOD.MotivoArchivado,'')+
		'" class="btn ui blue label" onclick="MostrarDocumentoPdfExp('''+
		ED.RutaArchivoDocumento +''','+ CONVERT(VARCHAR,ed.IdExpedienteDocumento) +
		')"><i style="font-size:16px;" class="fa fa-file-text"></i></button><label style="font-size:8px">'+
		CASE WHEN ED.Correlativo=0 THEN  CONCAT( CTD.Descripcion,' ', COALESCE(ED.NumeroDocumento,'')) ELSE COALESCE(ED.NumeroDocumento,'') END+
		'</label>'
		FROM
		Tramite.ExpedienteDocumento ED WITH (NOLOCK)
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
		    ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		INNER JOIN  Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
		    ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
		LEFT JOIN Tramite.Catalogo CTD
		    ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
		WHERE
    		EDOD.IdAreaDestino=@pIdArea AND
    		EDOD.IdCargoDestino=@pIdCargo AND
    		EDOD.IdPersonaDestino=@pIdPersona AND
    		EDOD.IdCatalogoSituacionMovimientoDestino  =@pIdCatalogoSituacionMovimientoDestino
    		AND Ed.IdExpediente=@pIdExpediente
	END

	IF @pIdCatalogoSituacionMovimientoDestino IN(111)--REENVIADOS/RESPONDIDOS/DEVUELTOS
	BEGIN
		SELECT
		TOP 1 @vNumeroDocumento =
		'<button type="button" data-toggle="tooltip" class="btn ui blue label" onclick="MostrarDocumentoPdfExp('''+
		ED.RutaArchivoDocumento +''','+ CONVERT(VARCHAR,ed.IdExpedienteDocumento) +
		')"><i style="font-size:16px;" class="fa fa-file-text"></i></button><label style="font-size:8px">'+
		CASE WHEN ED.Correlativo=0 THEN  CONCAT( CTD.Descripcion,' ', COALESCE(ED.NumeroDocumento,'')) ELSE COALESCE(ED.NumeroDocumento,'') END+
		'</label>'
		FROM
		Tramite.ExpedienteDocumento ED WITH (NOLOCK)
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
		    ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		INNER JOIN  Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
		    ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
		INNER JOIN Tramite.Catalogo CTD
		    ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
		WHERE
    		EDO.IdAreaOrigen=@pIdArea AND
    		EDO.IdCargoOrigen=@pIdCargo AND
    		EDO.IdPersonaOrigen=@pIdPersona
    		AND Ed.IdExpediente=@pIdExpediente
    		ORDER BY EDOD.IdExpedienteDocumentoOrigenDestino DESC
	END

	IF @pIdCatalogoSituacionMovimientoDestino IN(3,6)--REENVIADOS/RESPONDIDOS/DEVUELTOS
	BEGIN
		SELECT
		TOP 1 @vNumeroDocumento =
		'<button type="button" data-toggle="tooltip" class="btn ui blue label" onclick="MostrarDocumentoPdfExp('''+
		ED.RutaArchivoDocumento+''','+CONVERT(VARCHAR,ed.IdExpedienteDocumento) +
		')"><i style="font-size:16px;" class="fa fa-file-text"></i></button><label style="font-size:8px">'+
		CASE WHEN ED.Correlativo=0 THEN  CONCAT( CTD.Descripcion,' ', COALESCE(ED.NumeroDocumento,'')) ELSE COALESCE(ED.NumeroDocumento,'') END+
		'</label>'
		FROM
		Tramite.ExpedienteDocumento ED WITH (NOLOCK)
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
		    ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		INNER JOIN  Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
		    ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
		INNER JOIN Tramite.Catalogo CTD
		    ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
		WHERE
    		EDO.IdAreaOrigen=@pIdArea AND
    		EDO.IdCargoOrigen=@pIdCargo AND
    		EDO.IdPersonaOrigen=@pIdPersona
    		AND Ed.IdExpediente=@pIdExpediente
    		ORDER BY EDOD.IdExpedienteDocumentoOrigenDestino DESC
	END

	IF @pIdCatalogoSituacionMovimientoDestino IN(116)--TODOS/POR RECIBIR/PENDIENTES
	BEGIN
		SELECT
		TOP 1 @vNumeroDocumento =
		'<button type="button" data-toggle="tooltip" class="btn ui blue label" onclick="MostrarDocumentoPdfExp('''+
		ED.RutaArchivoDocumento+''','+CONVERT(VARCHAR,ed.IdExpedienteDocumento) +
		')"><i style="font-size:16px;" class="fa fa-file-text"></i></button><label style="font-size:8px">'+
		CASE WHEN ED.Correlativo=0 THEN  CONCAT( CTD.Descripcion,' ', COALESCE(ED.NumeroDocumento,'')) ELSE COALESCE(ED.NumeroDocumento,'') END+
		'</label>'
		FROM
		Tramite.ExpedienteDocumento ED WITH (NOLOCK)
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
		    ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		INNER JOIN  Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
		    ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
		LEFT JOIN Tramite.Catalogo CTD
	        ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
		left join General.Area A
		    ON A.IdArea=EDO.IdAreaOrigen
		left join General.Persona PO
		    ON PO.IdPersona=EDO.IdPersonaOrigen
		WHERE
    		ED.IdExpediente=@pIdExpediente AND
    		EDO.IdAreaOrigen=@pIdArea
    		AND EDO.IdCargoOrigen =@pIdCargo
    		AND EDO.IdPersonaOrigen=@pIdPersona
    		AND EDO.IdCatalogoSituacionMovimientoOrigen=@pIdCatalogoSituacionMovimientoDestino
    		ORDER BY EDO.IdExpedienteDocumentoOrigen DESC
	END


	RETURN coalesce(@vNumeroDocumento,'')

-- END
