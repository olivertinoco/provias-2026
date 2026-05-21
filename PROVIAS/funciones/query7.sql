CREATE VIEW [RecursoHumano].[visPersonaJefe]
AS
SELECT      DISTINCT     -- a.NombreArea, pe.NombreCompleto, u.Email, a.IdCatalogoTipoArea, cta.Descripcion AS CatalogoTipoArea, pe.IdPersona,
                         cp.IdArea, cp.IdCargo,
                         E.IdEmpresa, CA.NombreCargo, cp.IdEmpleadoPerfil,
                         -- E.NombreEmpresa, a.IdAreaPadre, CA.Abreviatura, CA.IdCatalogoTipoCargo,a.VerRecepcion
FROM                     RecursoHumano.Empleado AS c INNER JOIN
                         RecursoHumano.EmpleadoPerfil AS cp ON c.IdEmpleado = cp.IdEmpleado AND cp.EstadoAuditoria = 1 AND cp.Activo = 1 INNER JOIN
                         General.Cargo AS CA ON CA.IdCargo = cp.IdCargo INNER JOIN
                         General.Persona AS pe ON pe.IdPersona = c.IdPersona INNER JOIN
                         Seguridad.Usuario AS u ON u.IdPersona = pe.IdPersona AND u.EstadoAuditoria = 1 AND u.Bloqueado = 0 INNER JOIN
                         General.Area AS a ON a.IdArea = cp.IdArea INNER JOIN
                         General.Catalogo AS cta ON cta.IdCatalogo = a.IdCatalogoTipoArea INNER JOIN
                         General.EmpresaSede ES ON cp.IdEmpresaSede = ES.IdEmpresaSede
						 inner join General.Empresa E ON E.IdEmpresa=ES.IdEmpresa
WHERE        (c.EstadoAuditoria = 1) AND (cp.EstadoAuditoria = 1) AND (cp.Activo = 1) AND (c.Activo = 1) AND (u.EsInstitucion = 1) AND CA.IdCatalogoTipoCargo IN (32,33,34)
2





CREATE view [Tramite].[visDemoraAtencionPorExpediente]
as
	SELECT e.IdExpediente,
	CONCAT(SD.AbreviaturaSerieDocumentalExpediente +
	RIGHT(''0000'' + CONVERT(VARCHAR, E.NumeroExpediente), 5), ''-'', E.IdPeriodo) NombreExpediente,
	ED.NumeroDocumento,
	ed.NFechaDocumento,
	ed.IdExpedienteDocumento,
	edod.IdExpedienteDocumentoOrigenDestino,
	UPPER(ED.AsuntoDocumento)AsuntoDocumento,
	CASE WHEN EDO.IdPersonaOrigen = 0 THEN EDO.NombreCompletoOrigen ELSE PO.NombreCompleto END +
	'' - '' + COALESCE (CO.NombreCargo, '''') + '' - '' + COALESCE (AO.Abreviatura, '''') NombreEmpleadoPerfilEmisor,
	CASE WHEN EDOD.IdPersonaDestino = 0 THEN EDOD.DestinatarioDestino ELSE PD.NombreCompleto END +
	'' - '' + COALESCE (CD.NombreCargo, '''') + '' - '' + COALESCE (AD.Abreviatura, '''') NombreEmpleadoPerfilDestinatario,
	EDOD.FechaDestino ,
	EDOD.FechaDestinoRecepciona,
	CASE WHEN COALESCE(EDOD.FechaArchivado,'''')<>'''' THEN EDOD.FechaArchivado ELSE  EDOD.FechaDestinoEnvia END FechaDestinoEnvia,
	CONVERT(VARCHAR, EDOD.NumeroDiasAtencionSolicitado) + ''-'' + CONVERT(VARCHAR, EDOD.NumeroDiasAtencionAceptado) SolicitadoAceptado,
	CASE WHEN
	COALESCE (EDOD.FechaDestinoRecepciona, '''') <> ''''
	THEN DATEDIFF(DAY, CONVERT(DATE, EDOD.FechaDestino), CONVERT(DATE,
		CASE
		WHEN COALESCE(EDOD.FechaArchivado,'''')<>''''
		THEN EDOD.FechaArchivado
		ELSE CASE WHEN COALESCE(EDOD.FechaDestinoEnvia,'''')='''' THEN GETDATE() ELSE EDOD.FechaDestinoEnvia END
		END))
	ELSE DATEDIFF(DAY, CONVERT(DATE, EDOD.FechaDestino),getdate())
	END DemoraDias
	,CSD.Descripcion + COALESCE ('' '' + EDOD.FechaDestinoRecepciona + '''', '''') CatalogoSituacionMovimientoDestino
	,CSD.IdCatalogo IdCatalogoSituacionMovimientoDestino
	,COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(EDO.IdPersonaOrigen),''sinfotoH.jpg'') RutaFotoPersona
    ,COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(EDOD.IdPersonaDestino),''sinfotoH.jpg'') RutaFotoPersonaDestino
	FROM Tramite.Expediente E
	INNER JOIN Tramite.SerieDocumentalExpediente SD
	    ON SD.IdSerieDocumentalExpediente = E.IdSerieDocumentalExpediente
		AND E.ExpedienteAnulado = 0
	INNER JOIN Tramite.ExpedienteDocumento ED
	    ON ED.IdExpediente = E.IdExpediente
		AND e.EstadoAuditoria = 1
	INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO
	    ON ED.IdExpedienteDocumento = EDO.IdExpedienteDocumento
		AND ED.EstadoAuditoria = 1
	INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD
	    ON EDO.IdExpedienteDocumentoOrigen = EDOD.IdExpedienteDocumentoOrigen
		AND EDO.EstadoAuditoria = 1
		AND EDOD.EstadoAuditoria = 1
	INNER JOIN Tramite.Catalogo CSD
	    ON CSD.IdCatalogo = EDOD.IdCatalogoSituacionMovimientoDestino
	LEFT JOIN General.Area AO
	    ON AO.IdArea = EDO.IdAreaOrigen
	LEFT JOIN General.Cargo CO
	    ON CO.IdCargo = EDO.IdCargoOrigen
	LEFT JOIN General.Persona PO
	    ON PO.IdPersona = EDO.IdPersonaOrigen
	LEFT JOIN General.Area AD
	    ON AD.IdArea = EDOD.IdAreaDestino
	LEFT JOIN General.Area ADP
	    ON ADP.IdArea = AD.IdArea
	LEFT JOIN General.Cargo CD
	    ON CD.IdCargo = EDOD.IdCargoDestino
	LEFT JOIN General.Persona PD
	    ON PD.IdPersona = EDOD.IdPersonaDestino
