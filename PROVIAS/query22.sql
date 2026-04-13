if exists(select 1 from sys.sysobjects where id=object_id('Tramite.paListarExpedienteMesaParteDespachadosVirtualesV1_new','p'))
drop procedure [Tramite].[paListarExpedienteMesaParteDespachadosVirtualesV1_new]
go
CREATE PROCEDURE Tramite.paListarExpedienteMesaParteDespachadosVirtualesV1_new
    @pIdUsuarioAuditoria int,
	@pCampoOrdenado varchar(50),
	@pTipoOrdenacion varchar(4),
	@pNumeroPagina INT,
	@pDimensionPagina  INT,
	@pBusquedaGeneral varchar(100)
AS
begin
BEGIN TRY
set tran isolation level read uncommitted
set nocount on

	Declare	@pBusquedaGeneralfText Varchar(400), @pBusquedaGeneralfTextLike Bit, @iRegistroTotal Int,
	@iPaginaRegInicio Int, @iPaginaRegFinal Int

    select @pBusquedaGeneral = rTrim(LTrim(@pBusquedaGeneral))
    Create Table #vTablaExpediente (
        eNroOrden int identity,
        IdExpediente BigInt,
        FgEsObservado Bit,
        FgEnvioCorregido Bit,
        FechaEnvioDocumento DateTime,
        FechaExpediente datetime
    )

    IF @pBusquedaGeneral is not null and @pBusquedaGeneral != ''
	BEGIN
        select @pBusquedaGeneralfText = concat('"', cadena, '*"') from tramite.fnUtilitario_sanitizar(@pBusquedaGeneral)

		INSERT INTO #vTablaExpediente(IdExpediente, FgEsObservado, FgEnvioCorregido,FechaEnvioDocumento, FechaExpediente)
		SELECT Top 5000
			E.IdExpediente,
			ED.FgEsObservado,
			ED.FgEnvioCorregido,
			ED.FechaEnvioDocumento,
			cast(concat(E.NTFechaExpediente, ' ', E.HoraExpediente) as datetime) As FechaExpediente
		FROM
			Tramite.Expediente E
			INNER JOIN Tramite.ExpedienteDocumento ED ON
			ED.IdExpediente=E.IdExpediente AND ED.EstadoAuditoria=1
			AND ED.FgDocumentoVirtualEnviado=1 AND ED.FgEsObservado = 0 and ED.FgEnvioCorregido = 0
			INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO ON
			EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento and EDO.EstadoAuditoria = 1
			LEFT JOIN Tramite.Catalogo CTT ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
		WHERE
			E.EstadoAuditoria=1 And E.ExpedienteAnulado=0 AND E.IdCatalogoSituacionExpediente=62
			AND E.IdCatalogoTipoMovimientoTramite=13 AND E.FgTramiteVirtual=1
			And
			(
                CONTAINS(ED.AsuntoDocumento, @pBusquedaGeneralfText) OR
				CONTAINS(ED.NumeroDocumento, @pBusquedaGeneralfText) OR
				CONTAINS(ED.NombreCompletoEmisor, @pBusquedaGeneralfText) OR
				E.NumeroExpediente LIKE '%'+@pBusquedaGeneral +'%' OR
				CTT.Descripcion LIKE '%'+@pBusquedaGeneral +'%'
			)
            AND NOT EXISTS(
                select 1
                from Tramite.ExpedienteDocumentoOrigenDestino EDOD
                WHERE EDOD.IdExpedienteDocumentoOrigen = EDO.IdExpedienteDocumentoOrigen AND EDOD.EstadoAuditoria = 1
            )
		ORDER BY ED.FechaEnvioDocumento DESC
	END
	INSERT INTO #vTablaExpediente(IdExpediente, FgEsObservado, FgEnvioCorregido,FechaEnvioDocumento, FechaExpediente)
	SELECT Top 5000
		E.IdExpediente,
		ED.FgEsObservado,
		ED.FgEnvioCorregido,
		ED.FechaEnvioDocumento,
		cast(concat(E.NTFechaExpediente, ' ', E.HoraExpediente) as datetime) As FechaExpediente
	FROM
		Tramite.Expediente E
		INNER JOIN Tramite.ExpedienteDocumento ED ON
		ED.IdExpediente=E.IdExpediente AND ED.EstadoAuditoria=1
		AND ED.FgDocumentoVirtualEnviado=1 AND ED.FgEsObservado = 0 and ED.FgEnvioCorregido = 0
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO ON
		EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento and EDO.EstadoAuditoria = 1
	WHERE
		E.EstadoAuditoria=1 And E.ExpedienteAnulado=0 AND E.IdCatalogoSituacionExpediente=62
		AND E.IdCatalogoTipoMovimientoTramite=13 AND E.FgTramiteVirtual=1
        AND NOT EXISTS(
            select 1
            from Tramite.ExpedienteDocumentoOrigenDestino EDOD
            WHERE EDOD.IdExpedienteDocumentoOrigen = EDO.IdExpedienteDocumentoOrigen AND EDOD.EstadoAuditoria = 1
        )
	ORDER BY ED.FechaEnvioDocumento DESC

	select @iRegistroTotal = (Select Count(1) From #vTablaExpediente)
	select @iPaginaRegInicio = c.iStartRow,
		@iPaginaRegFinal = c.iEndrow
	FROM General.fnObtenerPaginacion(@pDimensionPagina, @pNumeroPagina, @iRegistroTotal) c


	SELECT
		E.IdExpediente,
		E.ExpedienteConfidencial,
		E.NTFechaExpediente,
		E.HoraExpediente,
		E.IdCatalogoTipoPrioridad,
		COALESCE(CTP.Descripcion,'') CatalogoTipoPrioridad,
		COALESCE(CTT.Descripcion,'') CatalogoTipoTramite,
		case when COALESCE(PD.NombreCompleto,'')='' then COALESCE(NombreCompletoCreador,'')
		else  COALESCE(PD.NombreCompleto,'') END +': '+
		    CASE WHEN COALESCE(E.AsuntoExpediente,'')='' THEN 'SIN ASUNTO' ELSE E.AsuntoExpediente END AsuntoExpediente,
		E.NumeroFoliosExpediente,
		COALESCE(E.ObservacionesExpediente,'') ObservacionesExpediente,
		COALESCE(EMD.NombreEmpresa,'EXTERNO') NombreEmpresaCreador,
		COALESCE(AD.NombreArea,'') NombreAreaCreador,
		COALESCE(CD.NombreCargo,'') NombreCargoCreador,
		case when COALESCE(PD.NombreCompleto,'')='' then COALESCE(NombreCompletoCreador,'')
		else  COALESCE(PD.NombreCompleto,'') end NombrePersonaCreador,
		E.NombreExpediente NombreExpediente,
		COALESCE(EE.FgEsObservado,'false') FgParaEnvio,
		COALESCE(EE.FgEsObservado,'false')FgEsObservado,
		COALESCE(EE.FgEnvioCorregido,'false')FgEnvioCorregido,
		coalesce(convert(varchar,EE.FechaEnvioDocumento,103),'')+' '+
		coalesce(convert(varchar,EE.FechaEnvioDocumento,108) ,'') FechaEnvioDocumento,
		ISNULL(SU.Logueo, '') AS Logueo
	FROM
		#vTablaExpediente EE
		INNER JOIN Tramite.Expediente E  ON E.IdExpediente=EE.IdExpediente
		LEFT JOIN Tramite.Catalogo CTP  ON CTP.IdCatalogo=E.IdCatalogoTipoPrioridad
		LEFT JOIN General.Empresa EMD  ON E.IdEmpresaCreador=EMD.IdEmpresa
		LEFT JOIN General.Area AD  ON E.IdAreaCreador= AD.IdArea
		LEFT JOIN General.Cargo CD  ON E.IdCargoCreador=CD.IdCargo
		LEFT JOIN General.Persona PD  ON E.IdPersonaCreador=PD.IdPersona
		LEFT JOIN Tramite.Catalogo CTT  ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
		LEFT JOIN Seguridad.Usuario SU ON SU.IdUsuario = E.IdUsuarioCreacionAuditoria
	WHERE EE.eNroOrden Between @iPaginaRegInicio And @iPaginaRegFinal
	ORDER BY EE.eNroOrden ASC

	SELECT @iRegistroTotal

END TRY
BEGIN CATCH
		DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
		SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarExpedienteMesaParteDespachadosVirtualesV1',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
		EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
END CATCH
end
go
