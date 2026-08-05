

IF @pIdCatalogoSituacionMovimientoDestino=4
	BEGIN
		SELECT
		top 1 @vDias=
		CASE WHEN  COALESCE(EDOD.FechaDestinoRecepciona,'')='' THEN
		    CASE WHEN DATEDIFF(DAY,CONVERT(DATE, EDO.FechaOrigen),GETDATE())<=0 then 0 ELSE DATEDIFF(DAY,CONVERT(DATE, EDOD.FechaDestino),GETDATE()) END
		ELSE 0 END
		FROM Tramite.ExpedienteDocumento ED
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO  ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD  ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen
		AND EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
		WHERE  EDOD.IdAreaDestino=@pIdArea AND
		EDOD.IdCatalogoSituacionMovimientoDestino  =@pIdCatalogoSituacionMovimientoDestino
		AND Ed.IdExpediente=@pIdExpediente AND EDOD.IdCargoDestino IN (SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34))
	END
	IF @pIdCatalogoSituacionMovimientoDestino =5
	BEGIN
		SELECT
		top 1 @vDias=CASE WHEN COALESCE(EDOD.FechaDestinoRecepciona,'')<>'' THEN DATEDIFF(DAY,CONVERT(DATE, EDOD.FechaDestinoRecepciona),GETDATE()) ELSE 0 end
		FROM Tramite.ExpedienteDocumento ED
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO  ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD  ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1
		AND EDOD.EstadoAuditoria=1
		WHERE  EDOD.IdAreaDestino=@pIdArea AND
		EDOD.IdCatalogoSituacionMovimientoDestino  =@pIdCatalogoSituacionMovimientoDestino
		AND Ed.IdExpediente=@pIdExpediente AND EDOD.IdCargoDestino IN (SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34))






	SELECT TOP 1 EDOD9.FechaDestinoRecepciona, EDOD9.FechaDestino, EDO9.FechaOrigen
	FROM Tramite.ExpedienteDocumento ED9
	INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO9 ON ED9.IdExpedienteDocumento=EDO9.IdExpedienteDocumento AND ED9.EstadoAuditoria=1
	INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD9 ON EDO9.IdExpedienteDocumentoOrigen=EDOD9.IdExpedienteDocumentoOrigen AND EDO9.EstadoAuditoria=1 AND EDOD9.EstadoAuditoria=1
	WHERE  EDOD9.IdAreaDestino=@pIdArea AND EDOD9.IdCatalogoSituacionMovimientoDestino=@pIdCatalogoSituacionMovimientoDestino AND ED9.IdExpediente=@pIdExpediente
	AND EXISTS (SELECT 1 FROM General.Cargo C9 WHERE C9.IdCargo = EDOD9.IdCargoDestino AND C9.IdCatalogoTipoCargo in (32,33,34))




	-- FROM Tramite.ExpedienteDocumento ED9
	-- INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO9 ON ED9.IdExpedienteDocumento=EDO9.IdExpedienteDocumento AND ED9.EstadoAuditoria=1
	-- INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD9 ON EDO9.IdExpedienteDocumentoOrigen=EDOD9.IdExpedienteDocumentoOrigen AND EDO9.EstadoAuditoria=1 AND EDOD9.EstadoAuditoria=1
	-- WHERE  EDOD9.IdAreaDestino=@pIdArea AND EDOD9.IdCatalogoSituacionMovimientoDestino=@pIdCatalogoSituacionMovimientoDestino AND ED9.IdExpediente=@pIdExpediente
	-- AND EXISTS (SELECT 1 FROM General.Cargo C9 WHERE C9.IdCargo = EDOD9.IdCargoDestino AND C9.IdCatalogoTipoCargo in (32,33,34))
