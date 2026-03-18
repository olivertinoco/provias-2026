CREATE function [Tramite].[funObtenerIdExpedienteDocumentoEnExpedienteEspecialista]
(@pIdExpediente INT,
 @pIdArea INT,
 @pIdCargo INT,
 @pIdPersona INT,
 @pIdCatalogoSituacionMovimientoDestino int
)
RETURNS int
AS
BEGIN
	DECLARE @vNumeroDocumento int=0
	IF @pIdCatalogoSituacionMovimientoDestino IN(4,5,112)--POR RECIBIR/PENDIENTES/CREADOS
	BEGIN
		SELECT
		TOP 1 @vNumeroDocumento=ed.IdExpedienteDocumento
		FROM
		Tramite.ExpedienteDocumento ED WITH (NOLOCK)
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK) ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		INNER JOIN  Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK) ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen AND
		EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
		--LEFT JOIN Tramite.Catalogo CTD ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
		WHERE  EDOD.IdAreaDestino=@pIdArea AND
		EDOD.IdCargoDestino=@pIdCargo AND
		EDOD.IdPersonaDestino=@pIdPersona AND
		EDOD.IdCatalogoSituacionMovimientoDestino  =@pIdCatalogoSituacionMovimientoDestino
		AND Ed.IdExpediente=@pIdExpediente
	END
	DECLARE @vIdExpedienteDocumentoOrigenDestino int=0
	IF @pIdCatalogoSituacionMovimientoDestino IN(111)--REENVIADOS/RESPONDIDOS/DEVUELTOS
	BEGIN
		SELECT
		TOP 1 @vIdExpedienteDocumentoOrigenDestino=EDOD.IdExpedienteDocumentoOrigenDestino
		FROM
		Tramite.ExpedienteDocumento ED WITH (NOLOCK)
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK) ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		INNER JOIN  Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK) ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen AND
		EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
		WHERE  EDOD.IdAreaDestino=@pIdArea AND
		EDOD.IdCargoDestino=@pIdCargo AND
		EDOD.IdPersonaDestino=@pIdPersona AND
		EDOD.IdCatalogoSituacionMovimientoDestino  =@pIdCatalogoSituacionMovimientoDestino
		AND Ed.IdExpediente=@pIdExpediente
		ORDER BY EDOD.IdExpedienteDocumentoOrigenDestino DESC
		SELECT
		TOP 1 @vNumeroDocumento=ed.IdExpedienteDocumento
		FROM
		Tramite.ExpedienteDocumento ED WITH (NOLOCK)
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK) ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		INNER JOIN  Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK) ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen AND
		EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
		WHERE  EDOD.IdExpedienteDocumentoOrigenDestinoAnterior=@vIdExpedienteDocumentoOrigenDestino

	END
	IF @pIdCatalogoSituacionMovimientoDestino IN(3,6)--REENVIADOS/RESPONDIDOS/DEVUELTOS
	BEGIN

		SELECT
		TOP 1 @vIdExpedienteDocumentoOrigenDestino=EDOD.IdExpedienteDocumentoOrigenDestino
		FROM
		Tramite.ExpedienteDocumento ED WITH (NOLOCK)
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK) ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		INNER JOIN  Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK) ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen AND
		EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
		WHERE  EDOD.IdAreaDestino=@pIdArea AND
		EDOD.IdCargoDestino=@pIdCargo AND
		EDOD.IdPersonaDestino=@pIdPersona AND
		EDOD.IdCatalogoSituacionMovimientoDestino  =@pIdCatalogoSituacionMovimientoDestino
		AND Ed.IdExpediente=@pIdExpediente
		ORDER BY EDOD.IdExpedienteDocumentoOrigenDestino DESC

		SELECT
		TOP 1 @vNumeroDocumento=ed.IdExpedienteDocumento
		FROM
		Tramite.ExpedienteDocumento ED WITH (NOLOCK)
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK) ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		INNER JOIN  Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK) ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen AND
		EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
		--LEFT JOIN Tramite.Catalogo CTD ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
		WHERE  EDOD.IdExpedienteDocumentoOrigenDestinoAnterior=@vIdExpedienteDocumentoOrigenDestino

	END
	IF @pIdCatalogoSituacionMovimientoDestino IN(116)--TODOS/POR RECIBIR/PENDIENTES
	BEGIN
		SELECT
		TOP 1 @vNumeroDocumento=ed.IdExpedienteDocumento
		FROM
		Tramite.ExpedienteDocumento ED WITH (NOLOCK)
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK) ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		--INNER JOIN  Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK) ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen
		-- AND EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
		--LEFT JOIN Tramite.Catalogo CTD ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
		--left join General.Area A ON A.IdArea=EDO.IdAreaOrigen
		--left join General.Persona PO ON PO.IdPersona=EDO.IdPersonaOrigen
		WHERE
		ED.IdExpediente=@pIdExpediente AND
		EDO.IdAreaOrigen=@pIdArea
		AND EDO.IdCargoOrigen =@pIdCargo
		AND EDO.IdPersonaOrigen=@pIdPersona
		AND EDO.IdCatalogoSituacionMovimientoOrigen=@pIdCatalogoSituacionMovimientoDestino
		ORDER BY EDO.IdExpedienteDocumentoOrigen DESC
	END

	RETURN coalesce(@vNumeroDocumento,0)
END

--SELECT Tramite.funObtenerIdExpedienteDocumentoEnExpedienteEspecialista(19877,8,480,9516,116)
