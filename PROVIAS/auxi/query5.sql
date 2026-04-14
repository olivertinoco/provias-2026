
-- CREATE function [Tramite].[funObtenerIdExpedienteDocumentoEnExpedienteEspecialista]
declare
 @pIdExpediente INT,
 @pIdArea INT,
 @pIdCargo INT,
 @pIdPersona INT,
 @pIdCatalogoSituacionMovimientoDestino int
-- )
-- RETURNS int
-- AS
-- BEGIN
	DECLARE @vNumeroDocumento int=0
	IF @pIdCatalogoSituacionMovimientoDestino IN(4,5,112)--POR RECIBIR/PENDIENTES/CREADOS
	BEGIN
		SELECT
		TOP 1 @vNumeroDocumento = ed.IdExpedienteDocumento
		FROM
		Tramite.ExpedienteDocumento ED WITH (NOLOCK)
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
		    ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		INNER JOIN  Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
		    ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
		WHERE
    		EDOD.IdAreaDestino=@pIdArea AND
    		EDOD.IdCargoDestino=@pIdCargo AND
    		EDOD.IdPersonaDestino=@pIdPersona AND
    		EDOD.IdCatalogoSituacionMovimientoDestino = @pIdCatalogoSituacionMovimientoDestino
    		AND Ed.IdExpediente=@pIdExpediente
	END


	DECLARE @vIdExpedienteDocumentoOrigenDestino int=0
	IF @pIdCatalogoSituacionMovimientoDestino IN(111)--REENVIADOS/RESPONDIDOS/DEVUELTOS
	BEGIN
		SELECT
		TOP 1 @vIdExpedienteDocumentoOrigenDestino = EDOD.IdExpedienteDocumentoOrigenDestino
		FROM
		Tramite.ExpedienteDocumento ED WITH (NOLOCK)
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
		    ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		INNER JOIN  Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
		    ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
		WHERE
    		EDOD.IdAreaDestino=@pIdArea AND
    		EDOD.IdCargoDestino=@pIdCargo AND
    		EDOD.IdPersonaDestino=@pIdPersona AND
    		EDOD.IdCatalogoSituacionMovimientoDestino  =@pIdCatalogoSituacionMovimientoDestino
    		AND Ed.IdExpediente=@pIdExpediente
        ORDER BY EDOD.IdExpedienteDocumentoOrigenDestino DESC

		SELECT
		TOP 1 @vNumeroDocumento = ed.IdExpedienteDocumento
		FROM
		Tramite.ExpedienteDocumento ED WITH (NOLOCK)
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
		    ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		INNER JOIN  Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
		    ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
		WHERE
		    EDOD.IdExpedienteDocumentoOrigenDestinoAnterior=@vIdExpedienteDocumentoOrigenDestino

	END




	IF @pIdCatalogoSituacionMovimientoDestino IN(3,6)--REENVIADOS/RESPONDIDOS/DEVUELTOS
	BEGIN

		SELECT
		TOP 1 @vIdExpedienteDocumentoOrigenDestino=EDOD.IdExpedienteDocumentoOrigenDestino
		FROM
		Tramite.ExpedienteDocumento ED WITH (NOLOCK)
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
		    ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		INNER JOIN  Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
		    ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
		WHERE
    		EDOD.IdAreaDestino=@pIdArea AND
    		EDOD.IdCargoDestino=@pIdCargo AND
    		EDOD.IdPersonaDestino=@pIdPersona AND
    		EDOD.IdCatalogoSituacionMovimientoDestino  =@pIdCatalogoSituacionMovimientoDestino
    		AND Ed.IdExpediente=@pIdExpediente
    		ORDER BY EDOD.IdExpedienteDocumentoOrigenDestino DESC

		SELECT
		TOP 1 @vNumeroDocumento=ed.IdExpedienteDocumento
		FROM
		Tramite.ExpedienteDocumento ED WITH (NOLOCK)
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
		    ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		INNER JOIN  Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
		    ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
		WHERE
		    EDOD.IdExpedienteDocumentoOrigenDestinoAnterior=@vIdExpedienteDocumentoOrigenDestino

	END


	IF @pIdCatalogoSituacionMovimientoDestino IN(116)--TODOS/POR RECIBIR/PENDIENTES
	BEGIN
		SELECT
		TOP 1 @vNumeroDocumento=ed.IdExpedienteDocumento
		FROM
		Tramite.ExpedienteDocumento ED WITH (NOLOCK)
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
		    ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		WHERE
    		ED.IdExpediente=@pIdExpediente AND
    		EDO.IdAreaOrigen=@pIdArea
    		AND EDO.IdCargoOrigen =@pIdCargo
    		AND EDO.IdPersonaOrigen=@pIdPersona
    		AND EDO.IdCatalogoSituacionMovimientoOrigen=@pIdCatalogoSituacionMovimientoDestino
    		ORDER BY EDO.IdExpedienteDocumentoOrigen DESC
	END

	RETURN coalesce(@vNumeroDocumento,0)














-- 	CREATE function [Seguridad].[funObtenerRutaFotoPorIdPersona]
-- (
Declare
@pIdPersona INT)
-- RETURNS VARCHAR(MAX)
-- AS
-- BEGIN
		DECLARE @Lista  varchar(50)='sinfotoH.jpg'
		SELECT @Lista=case when COALESCE(U.RutaArchivoFoto,'') ='' then
		CASE WHEN COALESCE(Pr.Sexo,0)=0 then 'sinfotoH.jpg' else 'sinfotoM.jpg' end else U.RutaArchivoFoto end
		FROM Seguridad.Usuario U
		INNER JOIN General.Persona PR ON PR.IdPersona=U.IdPersona
		WHERE U.EstadoAuditoria=1 and pr.IdPersona=@pIdPersona AND U.Bloqueado=0
		RETURN @Lista

-- END
