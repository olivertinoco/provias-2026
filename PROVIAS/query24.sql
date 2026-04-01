-- NOTA: ORIGINAL NO TOCAR
-- =======================
-- CREATE PROCEDURE [Tramite].[paListarExpedienteMesaParteDespachadosVirtualesV1]
declare
    @pIdUsuarioAuditoria int = 56784,
	@pCampoOrdenado varchar(50)= null,
	@pTipoOrdenacion varchar(4)= null,
	@pNumeroPagina INT = 1,
	@pDimensionPagina  INT = 10,
	@pBusquedaGeneral varchar(100) =
    'BONIFICA'
-- AS
-- 	BEGIN TRY

		DECLARE @iRegistroTotal Int, @iPaginaRegInicio Int, @iPaginaRegFinal Int, @pBusquedaGeneralfText varchar(200),
		@pBusquedaGeneralfTextLike Bit
		Create Table #vTablaExpediente (
		    IdExpediente BigInt,
			FgEsObservado Bit,
			FgEnvioCorregido Bit,
			FechaEnvioDocumento DateTime,
			eNroOrden Int)

		if Isnull(@pBusquedaGeneral, '') <> ''
		Begin
			Execute General.fnFullTextPrefijoVal @pBusquedaGeneral, 'And', @pBusquedaGeneralfText Output,
			@pBusquedaGeneralfTextLike Output

			INSERT INTO #vTablaExpediente(IdExpediente, FgEsObservado, FgEnvioCorregido, FechaEnvioDocumento, eNroOrden)
			SELECT E.IdExpediente,
				ED.FgEsObservado,
				ED.FgEnvioCorregido,
				ED.FechaEnvioDocumento,
				Row_Number() Over(Order By ED.FechaEnvioDocumento desc)
			FROM
				(Tramite.Expediente E WITH (NOLOCK)
				INNER JOIN Tramite.ExpedienteDocumento ED WITH (NOLOCK)
				on ED.IdExpediente=E.IdExpediente AND ED.EstadoAuditoria=E.EstadoAuditoria
				AND E.IdCatalogoTipoMovimientoTramite=13 AND E.IdCatalogoSituacionExpediente =62 and E.FgTramiteVirtual=1
				AND ED.IdExpedienteDocumento Is Not Null and ED.FgDocumentoVirtualEnviado=1
                AND ED.FgEsObservado = 0 and ED.FgEnvioCorregido = 0
				INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
				on ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento and EDO.EstadoAuditoria=E.EstadoAuditoria
				)
				LEFT JOIN Tramite.Catalogo CTT WITH (NOLOCK) ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
				left JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
				on EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen and EDOD.EstadoAuditoria=E.EstadoAuditoria
				WHERE E.EstadoAuditoria=1
				AND E.ExpedienteAnulado=0
				AND EDOD.IdExpedienteDocumentoOrigenDestino Is Null
				AND (
						CONTAINS(ED.AsuntoDocumento, @pBusquedaGeneralfText) OR
						CONTAINS(ED.NumeroDocumento, @pBusquedaGeneralfText) OR
						E.NumeroExpediente LIKE '%'+@pBusquedaGeneral +'%' OR
						CTT.Descripcion LIKE '%'+@pBusquedaGeneral +'%' OR
						CONTAINS(ED.NombreCompletoEmisor, @pBusquedaGeneralfText)
					)
			 OPTION (MAXDOP 2)
		End
		Else
		Begin
			INSERT INTO #vTablaExpediente(IdExpediente, FgEsObservado, FgEnvioCorregido, FechaEnvioDocumento, eNroOrden)
			SELECT E.IdExpediente,
				ED.FgEsObservado,
				ED.FgEnvioCorregido,
				ED.FechaEnvioDocumento,
				Row_Number() Over(Order By ED.FechaEnvioDocumento desc)
			FROM
				Tramite.Expediente E WITH (NOLOCK)
				INNER JOIN Tramite.ExpedienteDocumento ED WITH (NOLOCK)
				ON ED.IdExpediente=E.IdExpediente AND E.IdCatalogoTipoMovimientoTramite=13 AND E.IdCatalogoSituacionExpediente =62
				and E.FgTramiteVirtual=1  AND ED.IdExpedienteDocumento Is Not Null and ED.FgDocumentoVirtualEnviado=1
				AND ED.FgEsObservado = 0 AND ED.FgEnvioCorregido = 0
				INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
				ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento and EDO.EstadoAuditoria=E.EstadoAuditoria
				LEFT JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
				ON EDOD.IdExpedienteDocumentoOrigen = EDO.IdExpedienteDocumentoOrigen and EDOD.EstadoAuditoria=E.EstadoAuditoria
			WHERE E.EstadoAuditoria=1
				AND E.ExpedienteAnulado=0
				AND EDOD.IdExpedienteDocumentoOrigenDestino Is Null
			OPTION (MAXDOP 2)
		End

		--Calculando Paginación
		Begin
			Set @iRegistroTotal = (Select Count(1) From #vTablaExpediente)
			SELECT @iPaginaRegInicio = c.iStartRow,
				@iPaginaRegFinal = c.iEndrow
			FROM General.fnObtenerPaginacion(@pDimensionPagina, @pNumeroPagina, @iRegistroTotal) c
		End

		SELECT
			E.IdExpediente,
			E.ExpedienteConfidencial,
			E.NTFechaExpediente,
			E.HoraExpediente,
			E.IdCatalogoTipoPrioridad,
			COALESCE(CTP.Descripcion,'') CatalogoTipoPrioridad,
			COALESCE(CTT.Descripcion,'') CatalogoTipoTramite,
			case when COALESCE(E.RazonSocialNombreRemitente,'')=''
			then COALESCE(NombreCompletoCreador,'')
			else  COALESCE(E.RazonSocialNombreRemitente,'') END +
			': '+
			CASE WHEN COALESCE(E.AsuntoExpediente,'')='' THEN 'SIN ASUNTO' ELSE E.AsuntoExpediente END AsuntoExpediente,
			E.NumeroFoliosExpediente,
			COALESCE(E.ObservacionesExpediente,'') ObservacionesExpediente,
			COALESCE(EMD.NombreEmpresa,'EXTERNO') NombreEmpresaCreador,
			COALESCE(AD.NombreArea,'') NombreAreaCreador,
			COALESCE(CD.NombreCargo,'') NombreCargoCreador,
			case when COALESCE(E.RazonSocialNombreRemitente,'')=''
			then COALESCE(NombreCompletoCreador,'')
			else  COALESCE(E.RazonSocialNombreRemitente,'') end NombrePersonaCreador,
			E.NombreExpediente NombreExpediente,
			COALESCE(EE.FgEsObservado,'false') FgParaEnvio,
			COALESCE(EE.FgEsObservado,'false')FgEsObservado,
			COALESCE(EE.FgEnvioCorregido,'false')FgEnvioCorregido,
			coalesce(convert(varchar,EE.FechaEnvioDocumento,103),'')+' '+
			coalesce(convert(varchar,EE.FechaEnvioDocumento,108) ,'') FechaEnvioDocumento
		FROM
			#vTablaExpediente EE
			INNER JOIN Tramite.Expediente E WITH (NOLOCK) ON E.IdExpediente=EE.IdExpediente
			LEFT JOIN Tramite.Catalogo CTP WITH (NOLOCK) ON CTP.IdCatalogo=E.IdCatalogoTipoPrioridad
			LEFT JOIN General.Empresa EMD WITH (NOLOCK) ON E.IdEmpresaCreador=EMD.IdEmpresa
			LEFT JOIN General.Area AD WITH (NOLOCK) ON E.IdAreaCreador= AD.IdArea
			LEFT JOIN General.Cargo CD WITH (NOLOCK) ON E.IdCargoCreador=CD.IdCargo
			LEFT JOIN General.Persona PD WITH (NOLOCK) ON E.IdPersonaCreador=PD.IdPersona
			LEFT JOIN Tramite.Catalogo CTT WITH (NOLOCK) ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
		WHERE EE.eNroOrden Between @iPaginaRegInicio And @iPaginaRegFinal
		ORDER BY EE.eNroOrden ASC
		--Total Registro
		SELECT @iRegistroTotal


	-- END TRY
	-- BEGIN CATCH
	-- 		DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
	-- 		SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarExpedienteMesaParteDespachadosVirtualesV1',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	-- 		EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
	--  END CATCH
