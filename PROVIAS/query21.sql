
-- CREATE PROCEDURE Tramite.paListarExpedienteMesaParteDespachadosVirtualesV1
declare
	@pIdUsuarioAuditoria int,
	@pCampoOrdenado varchar(50),
	@pTipoOrdenacion varchar(4),
	@pNumeroPagina INT,
	@pDimensionPagina  INT,
	@pBusquedaGeneral varchar(100)

SELECT
    @pIdUsuarioAuditoria=56784,
    @pCampoOrdenado=NULL,
    @pTipoOrdenacion=NULL,
    @pNumeroPagina=1,
    @pDimensionPagina=10,
    @pBusquedaGeneral='ENTREGA'



exec Tramite.paListarExpedienteMesaParteDespachadosVirtualesV1 56784, null, null, 1, 10, 'ENTREGA'
exec Tramite.paListarExpedienteMesaParteDespachadosVirtualesV1_new 56784, null, null, 1, 10, 'ENTREGA'

  return
    -- set statistics xml on
    -- set statistics io on
    -- set statistics time on

-- AS
-- 	BEGIN TRY
		--set language 'spanish'
		set tran isolation level read uncommitted

		Declare
		@pBusquedaGeneralfText Varchar(400), @pBusquedaGeneralfTextLike Bit, @iRegistroTotal Int,
		@iPaginaRegInicio Int, @iPaginaRegFinal Int, @anno int = year(getdate())
        select @pBusquedaGeneral = rTrim(LTrim(@pBusquedaGeneral))
        Create Table #vTablaExpediente (
            IdExpediente BigInt,
            FgEsObservado Bit,
            FgEnvioCorregido Bit,
            FechaEnvioDocumento DateTime,
            eNroOrden Int
        )

        -- INSERT INTO #vTablaExpediente(IdExpediente, FgEsObservado, FgEnvioCorregido, FechaEnvioDocumento, eNroOrden)


        if @pBusquedaGeneral is not null and @pBusquedaGeneral != '' Begin
		    select @pBusquedaGeneralfText = concat('"', cadena, '*"') from tramite.fnUtilitario_sanitizar(@pBusquedaGeneral)



			select t.IdExpediente
			from tramite.expediente t
			where t.EstadoAuditoria = 1
			    and t.ExpedienteAnulado = 0
				and t.IdPeriodo = @anno
				and t.IdCatalogoTipoMovimientoTramite = 13
				and t.IdCatalogoSituacionExpediente = 62
				and t.FgTramiteVirtual = 1
         		and	exists(
         			    select 1
            				from tramite.ExpedienteDocumentoOrigen t3
            				inner join tramite.ExpedienteDocumento t2
           				        on t2.IdExpedienteDocumento = t3.IdExpedienteDocumento and t2.EstadoAuditoria = 1
                            where t2.IdExpediente = t.IdExpediente
                                and t3.EstadoAuditoria = 1
                           	    and t2.FgDocumentoVirtualEnviado = 1
                                and t2.FgEsObservado = 0
                                and t2.FgEnvioCorregido = 0
                                and not exists(
                                    select 1
                                    from tramite.ExpedienteDocumentoOrigenDestino t4
                                    where t4.IdExpedienteDocumentoOrigen = t3.IdExpedienteDocumentoOrigen
                                        and t4.EstadoAuditoria = 1
                                    )
                				and	(
              						   CONTAINS(t2.AsuntoDocumento, @pBusquedaGeneralfText)
              						or CONTAINS(t2.NumeroDocumento, @pBusquedaGeneralfText)
              						or CONTAINS(t2.NombreCompletoEmisor, @pBusquedaGeneralfText)
             					  )
         			);




			-- SELECT E.IdExpediente,
			-- 	ED.FgEsObservado,
			-- 	ED.FgEnvioCorregido,
			-- 	ED.FechaEnvioDocumento,
			-- 	Row_Number() Over(Order By ED.FechaEnvioDocumento desc)
			-- FROM
			-- 	(Tramite.Expediente E WITH (NOLOCK)
			-- 	INNER JOIN Tramite.ExpedienteDocumento ED WITH (NOLOCK)
   --  				on ED.IdExpediente=E.IdExpediente AND ED.EstadoAuditoria=E.EstadoAuditoria

   --                  AND E.IdCatalogoTipoMovimientoTramite=13
   --  				AND E.IdCatalogoSituacionExpediente =62
   --                  and E.FgTramiteVirtual=1

   --  				AND ED.IdExpedienteDocumento Is Not Null
   --  				and ED.FgDocumentoVirtualEnviado=1 AND ED.FgEsObservado = 0 and ED.FgEnvioCorregido = 0
			-- 	INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
			-- 	    on ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento and EDO.EstadoAuditoria=E.EstadoAuditoria
			-- 	)
			-- 	LEFT JOIN Tramite.Catalogo CTT WITH (NOLOCK) ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
			-- 	LEFT JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
			-- 	on EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen and EDOD.EstadoAuditoria=E.EstadoAuditoria
			-- WHERE E.EstadoAuditoria=1
			-- 	AND E.ExpedienteAnulado=0
			-- 	AND EDOD.IdExpedienteDocumentoOrigenDestino Is Null
			-- 	AND (
			-- 			CONTAINS(ED.AsuntoDocumento, @pBusquedaGeneralfText) OR
			-- 			CONTAINS(ED.NumeroDocumento, @pBusquedaGeneralfText) OR
			-- 			CONTAINS(ED.NombreCompletoEmisor, @pBusquedaGeneralfText) or
			-- 			E.NumeroExpediente LIKE '%'+@pBusquedaGeneral +'%' OR
			-- 			CTT.Descripcion LIKE '%'+@pBusquedaGeneral +'%'
			-- 		)

		End

		-- Else
		-- Begin
		-- 	INSERT INTO #vTablaExpediente(IdExpediente, FgEsObservado, FgEnvioCorregido, FechaEnvioDocumento, eNroOrden)
		-- 	SELECT E.IdExpediente,
		-- 		ED.FgEsObservado,
		-- 		ED.FgEnvioCorregido,
		-- 		ED.FechaEnvioDocumento,
		-- 		Row_Number() Over(Order By ED.FechaEnvioDocumento desc)
		-- 	FROM
		-- 		Tramite.Expediente E WITH (NOLOCK)
		-- 		INNER JOIN Tramite.ExpedienteDocumento ED WITH (NOLOCK)
		-- 		ON ED.IdExpediente=E.IdExpediente AND E.IdCatalogoTipoMovimientoTramite=13 AND E.IdCatalogoSituacionExpediente =62
		-- 		and E.FgTramiteVirtual=1  AND ED.IdExpedienteDocumento Is Not Null and ED.FgDocumentoVirtualEnviado=1
  --               AND ED.FgEsObservado = 0 AND ED.FgEnvioCorregido = 0
		-- 		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
		-- 		ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento and EDO.EstadoAuditoria=E.EstadoAuditoria
		-- 		LEFT JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
		-- 		ON EDOD.IdExpedienteDocumentoOrigen = EDO.IdExpedienteDocumentoOrigen and EDOD.EstadoAuditoria=E.EstadoAuditoria
		-- 	WHERE E.EstadoAuditoria=1
		-- 		AND E.ExpedienteAnulado=0
		-- 		AND EDOD.IdExpedienteDocumentoOrigenDestino Is Null
		-- End


		-- Set @iRegistroTotal = (Select Count(1) From #vTablaExpediente)
		-- SELECT @iPaginaRegInicio = c.iStartRow,
		-- 	@iPaginaRegFinal = c.iEndrow
		-- FROM General.fnObtenerPaginacion(@pDimensionPagina, @pNumeroPagina, @iRegistroTotal) c

		-- SELECT
		-- 	E.IdExpediente,
		-- 	E.ExpedienteConfidencial,
		-- 	E.NTFechaExpediente,
		-- 	E.HoraExpediente,
		-- 	E.IdCatalogoTipoPrioridad,
		-- 	COALESCE(CTP.Descripcion,'') CatalogoTipoPrioridad,
		-- 	COALESCE(CTT.Descripcion,'') CatalogoTipoTramite,
		-- 	case when COALESCE(PD.NombreCompleto,'')='' then COALESCE(NombreCompletoCreador,'')
		-- 	else  COALESCE(PD.NombreCompleto,'') END +': '+
		-- 	CASE WHEN COALESCE(E.AsuntoExpediente,'')='' THEN 'SIN ASUNTO' ELSE E.AsuntoExpediente END AsuntoExpediente,
		-- 	E.NumeroFoliosExpediente,
		-- 	COALESCE(E.ObservacionesExpediente,'') ObservacionesExpediente,
		-- 	COALESCE(EMD.NombreEmpresa,'EXTERNO') NombreEmpresaCreador,
		-- 	COALESCE(AD.NombreArea,'') NombreAreaCreador,
		-- 	COALESCE(CD.NombreCargo,'') NombreCargoCreador,
		-- 	case when COALESCE(PD.NombreCompleto,'')='' then COALESCE(NombreCompletoCreador,'')
		-- 	else  COALESCE(PD.NombreCompleto,'') end NombrePersonaCreador,
		-- 	E.NombreExpediente NombreExpediente,
		-- 	COALESCE(EE.FgEsObservado,'false') FgParaEnvio,
		-- 	COALESCE(EE.FgEsObservado,'false')FgEsObservado,
		-- 	COALESCE(EE.FgEnvioCorregido,'false')FgEnvioCorregido,
		-- 	coalesce(convert(varchar,EE.FechaEnvioDocumento,103),'')+' '+coalesce(convert(varchar,EE.FechaEnvioDocumento,108) ,'') FechaEnvioDocumento
		-- FROM
		-- 	#vTablaExpediente EE
		-- 	INNER JOIN Tramite.Expediente E WITH (NOLOCK) ON E.IdExpediente=EE.IdExpediente
		-- 	LEFT JOIN Tramite.Catalogo CTP WITH (NOLOCK) ON CTP.IdCatalogo=E.IdCatalogoTipoPrioridad
		-- 	LEFT JOIN General.Empresa EMD WITH (NOLOCK) ON E.IdEmpresaCreador=EMD.IdEmpresa
		-- 	LEFT JOIN General.Area AD WITH (NOLOCK) ON E.IdAreaCreador= AD.IdArea
		-- 	LEFT JOIN General.Cargo CD WITH (NOLOCK) ON E.IdCargoCreador=CD.IdCargo
		-- 	LEFT JOIN General.Persona PD WITH (NOLOCK) ON E.IdPersonaCreador=PD.IdPersona
		-- 	LEFT JOIN Tramite.Catalogo CTT WITH (NOLOCK) ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
		-- WHERE EE.eNroOrden Between @iPaginaRegInicio And @iPaginaRegFinal
		-- ORDER BY EE.eNroOrden ASC


		--Total Registro
		SELECT @iRegistroTotal
		--
	-- 	Drop Table #vTablaExpediente
	-- END TRY
	-- BEGIN CATCH
	-- 		DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
	-- 		SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarExpedienteMesaParteDespachadosVirtualesV1',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	-- 		EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
	--  END CATCH


set statistics xml off
set statistics io off
set statistics time off
