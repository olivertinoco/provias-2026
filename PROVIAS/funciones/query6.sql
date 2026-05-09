CREATE function [Tramite].[funObtenerFechaMovimientoEnExpedienteEspecialista]
(@pIdExpediente INT,
 @pIdArea INT,
 @pIdCargo INT,
 @pIdPersona INT,
 @pIdCatalogoSituacionMovimientoDestino int
)
RETURNS datetime
AS
BEGIN
	DECLARE @vfechaMovimiento datetime
	IF @pIdCatalogoSituacionMovimientoDestino IN(4,5)--TODOS/POR RECIBIR/PENDIENTES
	BEGIN
		SELECT
		TOP 1 @vfechaMovimiento=CONVERT(DATETIME,edod.FechaDestino +' ' + edod.HoraDestino)
		FROM
		Tramite.ExpedienteDocumento ED WITH (NOLOCK)
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
		    ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		INNER JOIN  Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
		    ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen
			AND EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
		WHERE
		ED.IdExpediente=@pIdExpediente AND
		EDOD.IdAreaDestino=@pIdArea AND
		EDOD.IdCargoDestino =@pIdCargo AND
		EDOD.IdPersonaDestino=@pIdPersona AND
		EDOD.IdCatalogoSituacionMovimientoDestino =@pIdCatalogoSituacionMovimientoDestino
		ORDER BY EDOD.IdExpedienteDocumentoOrigenDestino DESC
	END


	IF @pIdCatalogoSituacionMovimientoDestino IN(111,3,6)--REENVIADOS/RESPONDIDOS/DEVUELTOS
	BEGIN
		SELECT
		top 1 @vfechaMovimiento=CONVERT(DATETIME,edod.FechaDestinoEnvia +' ' + edod.HoraDestinoEnvia)
		FROM
		Tramite.ExpedienteDocumento ED WITH (NOLOCK)
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
		    ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		INNER JOIN  Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
		    ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen
			AND EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
		WHERE
		ED.IdExpediente=@pIdExpediente AND
		EDOD.IdAreaDestino=@pIdArea AND
		EDOD.IdCargoDestino=@pIdCargo AND
		EDOD.IdPersonaDestino=@pIdPersona AND
		EDOD.IdCatalogoSituacionMovimientoDestino =@pIdCatalogoSituacionMovimientoDestino
		ORDER BY CONVERT(DATETIME,edod.FechaDestinoEnvia +' ' + edod.HoraDestinoEnvia) DESC
	END


	IF @pIdCatalogoSituacionMovimientoDestino IN(112)--ARCHIVADOS
	BEGIN
		SELECT
		TOP 1 @vfechaMovimiento=CONVERT(DATETIME,edod.FechaArchivado +' ' + edod.HoraArchivado)
		FROM
		Tramite.ExpedienteDocumento ED WITH (NOLOCK)
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
		    ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		INNER JOIN  Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
		    ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen
			AND EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
		WHERE
		ED.IdExpediente=@pIdExpediente AND
		EDOD.IdAreaDestino=@pIdArea AND
		EDOD.IdCargoDestino=@pIdCargo AND
		EDOD.IdPersonaDestino=@pIdPersona AND
		EDOD.IdCatalogoSituacionMovimientoDestino =@pIdCatalogoSituacionMovimientoDestino
		ORDER BY EDOD.IdExpedienteDocumentoOrigenDestino DESC
	END



	IF @pIdCatalogoSituacionMovimientoDestino IN(116)--CREADOS
	BEGIN
		SELECT
		TOP 1 @vfechaMovimiento=CONVERT(DATETIME,edo.FechaOrigen +' ' + edo.HoraOrigen)
		FROM
		Tramite.ExpedienteDocumento ED WITH (NOLOCK)
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
		    ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		INNER JOIN  Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
		    ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen
			AND EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
		WHERE
		ED.IdExpediente=@pIdExpediente AND
		EDO.IdAreaOrigen=@pIdArea AND
		EDO.IdCargoOrigen =@pIdCargo AND
		EDO.IdPersonaOrigen=@pIdPersona AND
		EDO.IdCatalogoSituacionMovimientoOrigen=@pIdCatalogoSituacionMovimientoDestino
		ORDER BY EDO.IdExpedienteDocumentoOrigen DESC
	END


-- 	RETURN @vfechaMovimiento
-- END
