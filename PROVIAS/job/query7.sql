-- exec Tramite.paListarPendienteFirmaDigitalJefaturaV2
-- @pIdArea=30,@pIdUsuarioAuditoria=53721,@pCampoOrdenado=NULL,@pTipoOrdenacion=NULL,@pNumeroPagina=1,@pDimensionPagina=10,@pBusquedaGeneral=NULL
-- execute [Tramite].[paListarPendienteFirmaDigitalJefaturaV2] 30,53721,null,null,1,10,null

-- CREATE PROCEDURE [Tramite].[paListarPendienteFirmaDigitalJefaturaV2]
declare
	@pIdArea int,
	@pIdUsuarioAuditoria int,
	@pCampoOrdenado varchar(50),
	@pTipoOrdenacion varchar(4),
	@pNumeroPagina INT,
	@pDimensionPagina  INT,
	@pBusquedaGeneral varchar(20)

-- AS
-- 	BEGIN TRY
	SET LANGUAGE SPANISH

	select @pIdArea=30,@pIdUsuarioAuditoria=53721,@pCampoOrdenado=NULL,@pTipoOrdenacion=NULL,@pNumeroPagina=1,@pDimensionPagina=10,@pBusquedaGeneral=NULL


select*from Tramite.ExpedienteDocumentoFirmante edf
where
-- EDF.IdArea=@pIdArea
-- and NombreCompleto = 'MARIA ISABEL VASQUEZ ALDAVE'
-- EDF.IdCargo IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34))

IdExpedienteDocumento in (2596972, 2596905)

select*from BD_SGD_ARQ.Tramite.ExpedienteDocumentoFirmante edf
where IdExpedienteDocumento in (2596972, 2596905)

RETURN

	-- select*from Tramite.ExpedienteDocumentoFirmante_historico_2025 EDF
	-- where EDF.IdArea=@pIdArea and NombreCompleto = 'MARIA ISABEL VASQUEZ ALDAVE' and EDF.IdCargo IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34))



	-- select FgEnEsperaFirmaDigital, EstadoAuditoria, *from Tramite.ExpedienteDocumento_historico_2025 where IdExpedienteDocumento in(
	--     select IdExpedienteDocumento from Tramite.ExpedienteDocumentoFirmante_historico_2025 EDF
	-- 	where EDF.IdArea=@pIdArea and EDF.NombreCompleto = 'MARIA ISABEL VASQUEZ ALDAVE' and EDF.EstadoAuditoria = 1
	-- 	AND EDF.IdCargo IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34))
	-- )and FgEnEsperaFirmaDigital = 1 -- AND EstadoAuditoria = 1


	select FgEnEsperaFirmaDigital, EstadoAuditoria, *from BD_SGD_ARQ.Tramite.ExpedienteDocumento where IdExpedienteDocumento in(
	    select IdExpedienteDocumento from Tramite.ExpedienteDocumentoFirmante EDF
		where EDF.IdArea=@pIdArea and EDF.NombreCompleto = 'MARIA ISABEL VASQUEZ ALDAVE' and EDF.EstadoAuditoria = 1
		AND EDF.IdCargo IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34))
	)and FgEnEsperaFirmaDigital = 1 -- AND EstadoAuditoria = 1


-- return

-- 	select ExpedienteAnulado,EstadoAuditoria, *from Tramite.Expediente_historico_2025 where IdExpediente in (
-- 693494,
-- 691661,
-- 698334
-- ) -- and ExpedienteAnulado=0 and EstadoAuditoria = 1


select ExpedienteAnulado,EstadoAuditoria, *from Tramite.Expediente where IdExpediente in (
722741,
733076,
741086,
763506,
783874,
788610,
789033,
789033,
799656,
825511
) -- and ExpedienteAnulado=0 and EstadoAuditoria = 1



	return

			SELECT count(1)over() tot,
			E.IdExpediente,
			E.ExpedienteAnulado,
			E.IdSerieDocumentalExpediente,
			E.EstadoAuditoria,
			ED.FlagParaDespacho,
			ED.FgEsObligatorioFirmaDigital,
			ED.IdExpedienteDocumento,
			ED.IdExpediente,
			ED.EstadoAuditoria,
			ED.FgEnEsperaFirmaDigital,
			EDF.IdCargo,
			EDF.FlagFirmado,
			EDF.IdExpedienteDocumento,
			EDF.EstadoAuditoria



			-- CONCAT(SD.AbreviaturaSerieDocumentalExpediente +RIGHT('000000'+CONVERT(VARCHAR,E.NumeroExpediente),6), '-', E.IdPeriodo) NombreExpediente,
			-- ED.NumeroDocumento,
			-- ED.NFechaDocumento,
			-- ED.AsuntoDocumento,
			-- COALESCE(ED.NumeroFoliosDocumento,1)NumeroFoliosDocumento,
			-- ED.RutaArchivoDocumento,
			-- COALESCE(ED.ObservacionesDocumento,'''') ObservacionesDocumento,
			-- EDF.IdExpedienteDocumentoFirmante,
			-- COALESCE(EDF.PosicionX,0)PosicionX,
			-- COALESCE(EDF.PosicionY,0)PosicionY,
			-- CASE WHEN ED.IdCargoEmisor IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)) and ED.IdAreaEmisor=@pIdArea and ED.IdEmpresaEmisor=2 THEN 1 ELSE 0 END EsMiDocumento,
			-- CASE EDF.IdCatalogoTipoFirmante WHEN 296 THEN 'FIRMAR' ELSE 'VISTO BUENO' END+'¦'+F.FaltaFirma TipoFirma,
			-- (SELECT COUNT(IdExpedienteDocumento) FROM Tramite.ExpedienteDocumento WHERE IdUsuarioEnProcesoFirma =@pIdUsuarioAuditoria AND EnProcesoFirma=1 AND IdExpedienteDocumento=ED.IdExpedienteDocumento AND EstadoAuditoria=1) EsLiberado,
			-- A.NombreArea AreaEmisor,P.NombreCompleto PersonaEmisor,
			-- isnull(case when EB.FechaHoraBloquea is null then  '0'
			-- 		else
			-- 			 case when EB.FechaHoraBloquea<=ED.FechaCreacionAuditoria then '1' else '0' end
			-- 		end,'0') ExpedienteBloqueado,
			-- isnull(EB1.PersonaVisualiza,'0') PersonaVisualiza
			FROM
			Tramite.Expediente_historico_2025 E WITH (NOLOCK)
			INNER JOIN Tramite.SerieDocumentalExpediente SD  WITH (NOLOCK)
			ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente	AND E.ExpedienteAnulado=0
			INNER JOIN Tramite.ExpedienteDocumento_historico_2025 ED  WITH (NOLOCK)
			ON ED.IdExpediente=E.IdExpediente  and e.EstadoAuditoria=1 AND ED.EstadoAuditoria=1 -- AND ED.FgEnEsperaFirmaDigital=1
			INNER JOIN Tramite.ExpedienteDocumentoFirmante_historico_2025 EDF  WITH (NOLOCK)
			ON ED.IdExpedienteDocumento=EDF.IdExpedienteDocumento AND EDF.EstadoAuditoria=1 AND EDF.FlagFirmado=0
			AND EDF.IdCargo IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)) AND EDF.IdArea=@pIdArea
			-- INNER JOIN [General].[Area] A ON ED.IdAreaEmisor=A.IdArea
			-- INNER JOIN [General].[Persona] P ON ED.IdPersonaEmisor=p.IdPersona
			-- OUTER APPLY(
			-- 	select EB.IdExpedienteBloqueado,EB.FechaHoraBloquea
			-- 	from Tramite.ExpedienteBloqueado EB
			-- 	where ED.IdExpediente=EB.IdExpediente and EB.EstadoAuditoria=1 and EB.EstadoBloqueo=1
			-- )EB
			-- OUTER APPLY(
			-- 	select '1' PersonaVisualiza
			-- 	from Tramite.ExpedienteBloqueadoPersonaVisualiza EBPV
			-- 	inner join Seguridad.Usuario U on EBPV.IdPersonaVisualiza=U.IdPersona and U.IdUsuario=@pIdUsuarioAuditoria
			-- 	where EB.IdExpedienteBloqueado=EBPV.IdExpedienteBloqueado and EBPV.EstadoAuditoria=1
			-- )EB1
			-- CROSS APPLY(
			-- 	select
			-- 	(SELECT convert(varchar,count(*))
			-- 	FROM Tramite.ExpedienteDocumentoFirmante EDF
			-- 	WHERE EDF.EstadoAuditoria=1 and EDF.IdExpedienteDocumento=ED.IdExpedienteDocumento and EDF.FlagFirmado=0)+'¦'+
			-- 	(select STUFF((
			-- 	SELECT
			-- 	'¬'+COALESCE(Ep.NombreCompleto,'''')
			-- 	FROM Tramite.ExpedienteDocumentoFirmante EDF
			-- 	INNER JOIN RecursoHumano.visEmpleadoPerfilPersona EP ON EP.IdEmpleadoPerfil=EDF.IdEmpleadoPerfilFirmante
			-- 	WHERE EDF.EstadoAuditoria=1 and EDF.IdExpedienteDocumento=ED.IdExpedienteDocumento and EDF.FlagFirmado=0
			-- 	FOR XML PATH('')), 1, 1, '')) FaltaFirma
			-- )F
			WHERE ED.FlagParaDespacho=1 AND ED.FgEsObligatorioFirmaDigital=1
			-- AND CONCAT(SD.AbreviaturaSerieDocumentalExpediente ,RIGHT('000000'+CONVERT(VARCHAR,E.NumeroExpediente),6), '-', E.IdPeriodo) LIKE  case when COALESCE(@pBusquedaGeneral,'')<>'' THEN '%'+@pBusquedaGeneral +'%' ELSE '%' END
			ORDER BY ED.IdExpedienteDocumento DESC
            -- OFFSET (@pNumeroPagina-1)*@pDimensionPagina ROWS
            -- FETCH NEXT @pDimensionPagina ROWS ONLY


			-- SELECT COUNT(*)over(), E.IdExpediente, ED.FgEnEsperaFirmaDigital FROM
			-- Tramite.Expediente E  WITH (NOLOCK)
			-- INNER JOIN Tramite.SerieDocumentalExpediente SD  WITH (NOLOCK)
			-- ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente	AND E.ExpedienteAnulado=0
			-- INNER JOIN Tramite.ExpedienteDocumento ED  WITH (NOLOCK)
			-- ON ED.IdExpediente=E.IdExpediente  and e.EstadoAuditoria=1 AND ED.EstadoAuditoria=1 -- AND ED.FgEnEsperaFirmaDigital=1
			-- -- INNER JOIN Tramite.ExpedienteDocumentoFirmante EDF  WITH (NOLOCK) ON ED.IdExpedienteDocumento=EDF.IdExpedienteDocumento AND EDF.EstadoAuditoria=1 AND EDF.FlagFirmado=0 AND EDF.IdCargo IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)) AND EDF.IdArea=@pIdArea
			-- INNER JOIN [General].[Area] A ON ED.IdAreaEmisor=A.IdArea
			-- INNER JOIN [General].[Persona] P ON ED.IdPersonaEmisor=p.IdPersona
			-- where E.idExpediente in(829652,823476) and
			-- -- WHERE
			-- ED.FlagParaDespacho=1 AND ED.FgEsObligatorioFirmaDigital=1
			-- AND CONCAT(SD.AbreviaturaSerieDocumentalExpediente ,RIGHT('000000'+CONVERT(VARCHAR,E.NumeroExpediente),6), '-', E.IdPeriodo) LIKE  case when COALESCE(@pBusquedaGeneral,'')<>'' THEN '%'+@pBusquedaGeneral +'%' ELSE '%' END

	-- END TRY
	-- BEGIN CATCH
	-- 		DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
	-- 		SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarPendienteFirmaDigitalJefaturaV1',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	-- 		EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE ,@pIdUsuarioAuditoria
	-- END CATCH
