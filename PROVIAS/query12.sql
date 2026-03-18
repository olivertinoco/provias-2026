
-- CREATE PROCEDURE [Tramite].[paListarComboAreaPorAreaPadrePendientes]
declare
@pIdUsuarioAuditoria int,
@IdAreaPadre INT
-- AS
-- 	BEGIN TRY


	IF @IdAreaPadre  in(13,14) BEGIN SET @IdAreaPadre =1 END;
	WITH Areas AS
	(
		SELECT IdAreaPadre, IdArea, NombreArea, 0 AS Nivel
		FROM General.Area
		WHERE IdAreaPadre = @IdAreaPadre
		UNION ALL
		SELECT e.IdAreaPadre, e.IdArea, e.NombreArea, Nivel + 1
		FROM General.Area AS e
		INNER JOIN Areas AS d
		ON e.IdAreaPadre = d.IdArea
		WHERE d.IdArea <> @IdAreaPadre
	)
	SELECT DISTINCT ad.IdArea, ad.NombreArea
	FROM
	Tramite.Expediente E WITH (NOLOCK)
	INNER JOIN Tramite.SerieDocumentalExpediente SD WITH (NOLOCK)
	ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente AND E.ExpedienteAnulado=0
	INNER JOIN Tramite.ExpedienteDocumento ED WITH (NOLOCK)
	ON ED.IdExpediente=E.IdExpediente  and e.EstadoAuditoria=1
	INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
	ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
	INNER JOIN  Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
	ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen
	AND EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
	LEFT JOIN General.Area AD ON AD.IdArea= EDOD.IdAreaDestino
	WHERE  (EDOD.IdAreaDestino IN
    	(
    	SELECT IdArea
    	FROM Areas
    	) or EDOD.IdAreaDestino=@IdAreaPadre)
	AND EDOD.IdCatalogoSituacionMovimientoDestino  in(4,5)
	AND COALESCE(EDOD.IdAreaDestino,0)<>0
	order by NombreArea


	-- 	END TRY
	-- BEGIN CATCH
	-- 		DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
	-- 		SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarComboAreaPorAreaPadrePendientes',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	-- 		EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE ,@pIdUsuarioAuditoria
	--  END CATCH





-- CREATE PROCEDURE [Tramite].[paListarPeriodoBusquedaExpediente_OLI]
-- as
-- begin
-- begin try
--     select t.IdPeriodo, t.IdPeriodo NombrePeriodo
--     from(select IdPeriodo from tramite.expediente group by IdPeriodo)t
--     order by t.IdPeriodo desc
-- end try
-- begin catch
--     DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
-- 	SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarPeriodoBusquedaExpediente',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
-- 	EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
-- end catch
-- end
-- go

-- exec [Tramite].[paListarPeriodoBusquedaExpediente_OLI]


-- select distinct stuff(NTFechaExpediente,1,6,''), year(FechaCreacionAuditoria) from tramite.expediente





	-- select*from mastertable('tramite.expediente')

	-- set rowcount 10
	--
