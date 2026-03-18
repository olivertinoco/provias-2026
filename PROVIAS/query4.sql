CREATE function [Tramite].[funObtenerDiasPendienteEspecislista]
(@pIdExpediente INT,
 @pIdPersona INT,
 @pIdEmpresa INT,
 @pIdArea INT,
 @pIdCargo INT,
 @pIdCatalogoSituacionMovimientoDestino int
)
RETURNS INT
AS
BEGIN
	DECLARE @vDias int =0
	IF @pIdCatalogoSituacionMovimientoDestino=4
	BEGIN
		SELECT
		top 1 @vDias=CASE WHEN  COALESCE(EDOD.FechaDestinoRecepciona,'')='' THEN
		CASE WHEN DATEDIFF(DAY,CONVERT(DATE, EDO.FechaOrigen),GETDATE())<0 then 0 ELSE DATEDIFF(DAY,CONVERT(DATE, EDO.FechaOrigen),GETDATE()) END
		ELSE 0 END
		FROM
		Tramite.ExpedienteDocumento ED  WITH (NOLOCK)
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK) ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		INNER JOIN  Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK) ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen
		AND EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
		WHERE  EDOD.IdAreaDestino=@pIdArea AND
		EDOD.IdCatalogoSituacionMovimientoDestino  =@pIdCatalogoSituacionMovimientoDestino
		AND Ed.IdExpediente=@pIdExpediente AND EDOD.IdCargoDestino =@pIdCargo AND EDOD.IdEmpresaDestino=@pIdEmpresa and edod.IdAreaDestino=@pIdArea
		and EDOD.IdPersonaDestino=@pIdPersona
	END
	IF @pIdCatalogoSituacionMovimientoDestino =5
	BEGIN
		SELECT
		top 1 @vDias=CASE WHEN COALESCE(EDOD.FechaDestinoRecepciona,'')<>'' THEN DATEDIFF(DAY,CONVERT(DATE, EDOD.FechaDestinoRecepciona),GETDATE())
		ELSE 0 end
		FROM
		Tramite.ExpedienteDocumento ED  WITH (NOLOCK)
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK) ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		INNER JOIN  Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK) ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen
		AND EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
		WHERE  EDOD.IdAreaDestino=@pIdArea AND
		EDOD.IdCatalogoSituacionMovimientoDestino  =@pIdCatalogoSituacionMovimientoDestino
		AND Ed.IdExpediente=@pIdExpediente AND EDOD.IdCargoDestino =@pIdCargo AND EDOD.IdEmpresaDestino=@pIdEmpresa and edod.IdAreaDestino=@pIdArea
		and EDOD.IdPersonaDestino=@pIdPersona
	END
	RETURN @vDias
END
