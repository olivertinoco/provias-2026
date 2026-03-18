CREATE function Tramite.funParaAnularEspecialista(
 @pIdExpediente INT,
 @pIdPersona INT,
 @pIdEmpresa INT,
 @pIdArea INT,
 @pIdCargo INT
)
RETURNS BIT
AS
BEGIN
DECLARE @vEstado bit =0

	IF
		(
			SELECT COUNT(1) FROM
				Tramite.ExpedienteDocumento ED WITH (NOLOCK)
				INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
				ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
				INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
				ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1
			WHERE ED.IdExpediente=@pIdExpediente and EDOD.EsInicial=1 and ed.EsVinculado=0  and edod.IdCatalogoSituacionMovimientoDestino<>4
				AND EDOD.FechaDestinoRecepciona Is Null AND edo.IdAreaOrigen=@pIdArea AND  EDO.IdPersonaOrigen=@pIdPersona
				AND  EDO.IdAreaOrigen= @pIdArea
				AND  EDO.IdCargoOrigen=@pIdCargo
				AND  EDO.IdempresaOrigen=@pIdEmpresa
		) > 0
		BEGIN
			RETURN @vEstado
		END
	IF
		(
			SELECT COUNT(1) FROM
				Tramite.ExpedienteDocumento ED WITH (NOLOCK)
				INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
				ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
				INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
				ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1
			WHERE ED.IdExpediente=@pIdExpediente and EDOD.EsInicial=1 and ed.EsVinculado=0  and EDOD.FechaDestinoRecepciona Is Null
			    AND edo.IdAreaOrigen=@pIdArea
				AND  EDO.IdPersonaOrigen=@pIdPersona
				AND  EDO.IdAreaOrigen= @pIdArea
				AND  EDO.IdCargoOrigen=@pIdCargo
				AND  EDO.IdempresaOrigen=@pIdEmpresa
		) > 0
	BEGIN
		SET @vEstado= 1
	END
	ELSE
	BEGIN
		SET @vEstado= 0
	END
	RETURN @vEstado
END
