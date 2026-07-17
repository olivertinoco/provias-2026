USADO X:
Tramite.paListarExpedientePendienteCourrierJefatura_arq
===========================================================

CREATE function [Tramite].[funParaAnularJefatura]   = FPAJ
(@pIdExpediente INT,
 @pIdArea INT,
 @pIdCargoJefe int
)
RETURNS BIT
AS
BEGIN
DECLARE @vEstado bit =0
DECLARE @vCantidad int=0

		SELECT @vCantidad=COUNT(ED.IdExpediente) FROM
		 Tramite.ExpedienteDocumento ED
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO  ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD  ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1
		WHERE ED.IdExpediente=@pIdExpediente and EDOD.IdCatalogoSituacionMovimientoDestino<>4 and EDOD.EsInicial=1 AND EDO.EsVinculado<>1 and COALESCE(EDOD.FechaDestinoRecepciona,'')<>'' and edo.IdAreaOrigen=@pIdArea and edo.IdCargoOrigen IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34))


	IF	@vCantidad>0
	BEGIN
			RETURN @vEstado
	END

		SELECT @vCantidad=COUNT(ED.IdExpediente) FROM
		Tramite.ExpedienteDocumento ED
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO  ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD  ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1
		WHERE ED.IdExpediente=@pIdExpediente and EDOD.EsInicial=1 AND EDO.EsVinculado<>1 and COALESCE(EDOD.FechaDestinoRecepciona,'')='' and edo.IdAreaOrigen=@pIdArea and edo.IdCargoOrigen IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34))


	IF	@vCantidad>0
	BEGIN
		SET @vEstado= 1
	END
	ELSE
	BEGIN
		SET @vEstado= 0
	END
	RETURN @vEstado


END

CONSULTA ANTERIOR OPTIMIZADA  = FPAJ
============================
SELECT case when COUNT(CASE WHEN EDOD2.IdCatalogoSituacionMovimientoDestino <> 4 AND COALESCE(EDOD2.FechaDestinoRecepciona, '') <> '' THEN 1 END)>0
then 1 when COUNT(CASE WHEN COALESCE(EDOD2.FechaDestinoRecepciona, '') = '' THEN 1 END)> 0 then 1 else 0 end
FROM Tramite.ExpedienteDocumento ED2
INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO2
    ON EDO2.IdExpedienteDocumento = ED2.IdExpedienteDocumento
INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD2
    ON EDOD2.IdExpedienteDocumentoOrigen = EDO2.IdExpedienteDocumentoOrigen
WHERE ED2.IdExpediente   = @pIdExpediente
  AND ED2.EstadoAuditoria = 1
  AND EDO2.EstadoAuditoria = 1
  AND EDOD2.EsInicial     = 1
  AND EDO2.EsVinculado   != 1
  AND EDO2.IdAreaOrigen   = @pIdArea
  AND EXISTS (SELECT 1 FROM General.Cargo C2 WHERE C2.IdCargo = EDO2.IdCargoOrigen AND C2.IdCatalogoTipoCargo IN (32, 33, 34));







CREATE function [Tramite].[funEsMiAnuladoJefatura]  EMIA
(@pIdExpediente INT,
 @pIdArea INT,
 @pIdCargoJefe int
)
RETURNS BIT
AS
BEGIN
DECLARE @vEstado bit =0
DECLARE @vCantidad int=0
	SELECT @vCantidad=COUNT(*)
	FROM Tramite.Expediente E
	WHERE E.IdExpediente=@pIdExpediente and  E.ExpedienteAnulado=1 and E.IdAreaCreador=@pIdArea
	and E.IdCargoCreador IN(SELECT IdCargo FROM RecursoHumano.visPersonaJefe CA) AND E.EstadoAuditoria=1

	IF @vCantidad>0
	BEGIN
		SET @vEstado= 1
	END
	ELSE
	BEGIN
		SET @vEstado= 0
	END
	RETURN @vEstado
END



SELECT CASE WHEN COUNT(1)>0 THEN 1 ELSE 0 END
FROM Tramite.Expediente E
WHERE E.IdExpediente=@pIdExpediente and  E.ExpedienteAnulado=1 and E.IdAreaCreador=@pIdArea
and E.IdCargoCreador IN(SELECT IdCargo FROM RecursoHumano.visPersonaJefe CA) AND E.EstadoAuditoria=1




CREATE function [Tramite].[funObtenerDiasPendiente] = FODP
(@pIdExpediente INT,
 @pIdArea INT,
 @pIdCatalogoSituacionMovimientoDestino int
)
RETURNS INT
AS
BEGIN
	DECLARE @vDias int =0
	IF @pIdCatalogoSituacionMovimientoDestino=4
	BEGIN
		SELECT
		top 1 @vDias=CASE WHEN  COALESCE(EDOD.FechaDestinoRecepciona,'')='' THEN CASE WHEN DATEDIFF(DAY,CONVERT(DATE, EDO.FechaOrigen),GETDATE())<=0 then 0 ELSE DATEDIFF(DAY,CONVERT(DATE, EDOD.FechaDestino),GETDATE()) END ELSE 0 END
		FROM
		Tramite.ExpedienteDocumento ED
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO  ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD  ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
		WHERE  EDOD.IdAreaDestino=@pIdArea AND
		EDOD.IdCatalogoSituacionMovimientoDestino  =@pIdCatalogoSituacionMovimientoDestino
		AND Ed.IdExpediente=@pIdExpediente AND EDOD.IdCargoDestino IN (SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34))
	END
	IF @pIdCatalogoSituacionMovimientoDestino =5
	BEGIN
		SELECT
		top 1 @vDias=CASE WHEN COALESCE(EDOD.FechaDestinoRecepciona,'')<>'' THEN DATEDIFF(DAY,CONVERT(DATE, EDOD.FechaDestinoRecepciona),GETDATE()) ELSE 0 end
		FROM
		Tramite.ExpedienteDocumento ED
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO  ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD  ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
		WHERE  EDOD.IdAreaDestino=@pIdArea AND
		EDOD.IdCatalogoSituacionMovimientoDestino  =@pIdCatalogoSituacionMovimientoDestino
		AND Ed.IdExpediente=@pIdExpediente AND EDOD.IdCargoDestino IN (SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34))
	END
	RETURN @vDias
END

CONSULTA ANTERIOR OPTIMIZADA  = FODP
============================


SELECT TOP 1 CASE @pIdCatalogoSituacionMovimientoDestino
WHEN 4 THEN
    CASE WHEN COALESCE(EDOD5.FechaDestinoRecepciona, '') = ''
    THEN CASE WHEN DATEDIFF(DAY, CONVERT(DATE, EDO5.FechaOrigen), GETDATE()) <= 0 THEN 0 ELSE DATEDIFF(DAY, CONVERT(DATE, EDOD5.FechaDestino), GETDATE()) END
    ELSE 0 END
WHEN 5 THEN
    CASE WHEN COALESCE(EDOD5.FechaDestinoRecepciona, '') <> '' THEN DATEDIFF(DAY, CONVERT(DATE, EDOD5.FechaDestinoRecepciona), GETDATE()) ELSE 0 END
ELSE 0 END
FROM Tramite.ExpedienteDocumento ED5
INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO5
    ON EDO5.IdExpedienteDocumento = ED5.IdExpedienteDocumento
INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD5
    ON EDOD.IdExpedienteDocumentoOrigen = EDO.IdExpedienteDocumentoOrigen
WHERE ED5.IdExpediente    = @pIdExpediente
AND ED5.EstadoAuditoria  = 1
AND EDO5.EstadoAuditoria  = 1
AND EDOD5.EstadoAuditoria = 1
AND EDOD5.IdAreaDestino   = @pIdArea
AND EDOD5.IdCatalogoSituacionMovimientoDestino = @pIdCatalogoSituacionMovimientoDestino
AND EXISTS (SELECT 1 FROM General.Cargo C5 WHERE C5.IdCargo = EDOD5.IdCargoDestino AND C5.IdCatalogoTipoCargo IN (32, 33, 34));
