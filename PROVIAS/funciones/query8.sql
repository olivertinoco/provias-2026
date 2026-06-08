CREATE function [Tramite].[funObtenerNuevoPlazo]
declare
@pPlazoInicial INT=0,
 @pIdExpediente int

-- RETURNS INT
-- AS
-- BEGIN
select
    @pPlazoInicial=0,
     @pIdExpediente = 740699

     SELECT EDOD.NumeroDiasAtencionSolicitado
FROM Tramite.ExpedienteDocumentoOrigenDestino EDOD
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO   ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen and EDO.EstadoAuditoria=1 and edod.EstadoAuditoria=1
		INNER JOIN Tramite.ExpedienteDocumento ED   ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		where ed.IdExpediente=@pIdExpediente
		order by EDOD.IdExpedienteDocumentoOrigenDestino asc


select top 1 EDOD2.NumeroDiasAtencionSolicitado plazoInicial
FROM Tramite.ExpedienteDocumentoOrigenDestino EDOD2
INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO2 ON EDO2.IdExpedienteDocumentoOrigen=EDOD2.IdExpedienteDocumentoOrigen and EDO2.EstadoAuditoria=1 and EDOD2.EstadoAuditoria=1
INNER JOIN Tramite.ExpedienteDocumento ED2 ON ED2.IdExpedienteDocumento=EDO2.IdExpedienteDocumento AND ED2.EstadoAuditoria=1
where ED2.IdExpediente=@pIdExpediente order by EDOD2.IdExpedienteDocumentoOrigenDestino asc
RETURN



    DECLARE @vNuevoPlazo int =0
	DECLARE @vDiasSabDom int =0
	DECLARE @vDiasEnProceso INT=0
	DECLARE @vIdCatalogoTipoTramite INT=0
	DECLARE @pFechaInicial VARCHAr(10)
	---TRAER EL PLAZO Y FECHA DEL EXPEDIENTE
	SELECT @pFechaInicial =NTFechaExpediente, @vIdCatalogoTipoTramite=IdCatalogoTipoTramite FROM Tramite.Expediente  WHERE IdExpediente=@pIdExpediente
	SELECT @pFechaInicial fecha, @vIdCatalogoTipoTramite tipoTramite

	IF @vIdCatalogoTipoTramite NOT IN (211,477,478,129,391)
	BEGIN
		SET @vNuevoPlazo=@pPlazoInicial
	END
	ELSE
	BEGIN
		select top 1 @pPlazoInicial= EDOD.NumeroDiasAtencionSolicitado
		FROM Tramite.ExpedienteDocumentoOrigenDestino EDOD
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO   ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen and EDO.EstadoAuditoria=1 and edod.EstadoAuditoria=1
		INNER JOIN Tramite.ExpedienteDocumento ED   ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		where ed.IdExpediente=@pIdExpediente
		order by EDOD.IdExpedienteDocumentoOrigenDestino asc

		select @pPlazoInicial pPlazoInicial
		SELECT @vDiasEnProceso=	 DATEDIFF(DAY, @pFechaInicial, GETDATE());
		SELECT @vDiasEnProceso vDiasEnProceso
		SELECT @vDiasSabDom=General.ObtenerNumeroDiasSabadoDomingo(@pFechaInicial,GETDATE())

		select @vNuevoPlazo=@pPlazoInicial-@vDiasEnProceso+@vDiasSabDom
		select @vNuevoPlazo vNuevoPlazo
	END

-- 	RETURN @vNuevoPlazo

-- END

-- datediff(day, NTFechaExpediente, getdate())


-- select top 1 EDOD.NumeroDiasAtencionSolicitado plazoInicial
-- FROM Tramite.ExpedienteDocumentoOrigenDestino EDOD2
-- INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO2 ON EDO2.IdExpedienteDocumentoOrigen=EDOD2.IdExpedienteDocumentoOrigen and EDO2.EstadoAuditoria=1 and EDOD2.EstadoAuditoria=1
-- INNER JOIN Tramite.ExpedienteDocumento ED2 ON ED2.IdExpedienteDocumento=EDO2.IdExpedienteDocumento AND ED2.EstadoAuditoria=1
-- where ED2.IdExpediente=@pIdExpediente order by EDO2.IdExpedienteDocumentoOrigenDestino asc
