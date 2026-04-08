
alter PROCEDURE [Tramite].[paListarExpedienteMesaParteDespachadosV1]
    @pIdArea int,
    @pIdUsuarioAuditoria int,
    @pCampoOrdenado varchar(50),
    @pTipoOrdenacion varchar(4),
    @pNumeroPagina INT,
    @pDimensionPagina  INT,
    @pBusquedaGeneral varchar(100)
AS
	BEGIN TRY
		Declare @pBusquedaGeneralfText Varchar(400), @pBusquedaGeneralfTextLike Bit, @iRegistroTotal Int, @iPaginaRegInicio Int, @iPaginaRegFinal Int
		--@vIdPeriodoInicial Int, @vIdPeriodoFinal Int, @vFechaActual Date = GetDate()
		--SET LANGUAGE SPANISH;
        SET @pBusquedaGeneral = RTrim(LTrim(@pBusquedaGeneral))
		--Variable busqueda Texto completo FullText
		Execute General.fnFullTextPrefijoVal @pBusquedaGeneral, 'And', @pBusquedaGeneralfText Output, @pBusquedaGeneralfTextLike Output
        Create Table #vTablaExpediente(IdExpediente BigInt, IdExpedienteDocumento BigInt, eNroOrden Int)

		IF Isnull(@pBusquedaGeneral, '') <> ''
			BEGIN
				INSERT INTO #vTablaExpediente(IdExpediente, IdExpedienteDocumento, eNroOrden)
				SELECT
					SE.IdExpediente,
					SE.IdExpedienteDocumento,
					Row_Number() Over(Order By SE.FechaExpediente desc)
				FROM
					(
						SELECT Top 5000
							E.IdExpediente,
							ED.IdExpedienteDocumento,
							CONVERT(DATETIME, E.NTFechaExpediente +' '+ E.HoraExpediente) As FechaExpediente
						FROM
							Tramite.Expediente E With(NoLock)
							INNER JOIN Tramite.ExpedienteDocumento ED With(NoLock) on
							ED.IdExpediente=E.IdExpediente AND ED.EstadoAuditoria=E.EstadoAuditoria
							AND ED.IdEmpresaEmisor=0 AND E.IdCatalogoSituacionExpediente=63
						WHERE
							E.EstadoAuditoria=1
							And E.ExpedienteAnulado=0
							And
							(
								CONTAINS(E.AsuntoExpediente, @pBusquedaGeneralfText) OR
								CONTAINS(E.NombreExpediente, @pBusquedaGeneralfText) OR
								CONTAINS(E.NombreCompletoCreador, @pBusquedaGeneralfText) OR
								CONTAINS(ED.NumeroDocumento, @pBusquedaGeneralfText)
								-- CONTAINS(PD.NombreCompleto, @pBusquedaGeneralfText)
							)
						ORDER BY E.IdExpediente Desc
					) SE
				OPTION (MAXDOP 2)
			END
		ELSE
			BEGIN
				INSERT INTO #vTablaExpediente(IdExpediente, IdExpedienteDocumento, eNroOrden)
				SELECT
					SE.IdExpediente,
					SE.IdExpedienteDocumento,
					Row_Number() Over(Order By SE.FechaExpediente desc)
				FROM
					(
						SELECT Top 5000
							E.IdExpediente,
							ED.IdExpedienteDocumento,
							CONVERT(DATETIME, E.NTFechaExpediente +' '+ E.HoraExpediente) As FechaExpediente
						FROM
							Tramite.Expediente E With(NoLock)
							INNER JOIN Tramite.ExpedienteDocumento ED With(NoLock) on
							ED.IdExpediente=E.IdExpediente AND ED.EstadoAuditoria=E.EstadoAuditoria
							AND ED.IdEmpresaEmisor=0 AND E.IdCatalogoSituacionExpediente=63
							LEFT JOIN General.Persona PD ON E.IdPersonaCreador=PD.IdPersona
						WHERE
							E.EstadoAuditoria=1
							And E.ExpedienteAnulado=0
						ORDER BY E.IdExpediente Desc
					) SE
				OPTION (MAXDOP 2)
			END
		BEGIN
			Set @iRegistroTotal = (Select Count(1) From #vTablaExpediente)
			SELECT @iPaginaRegInicio = c.iStartRow,
				@iPaginaRegFinal = c.iEndrow
			FROM General.fnObtenerPaginacion(@pDimensionPagina, @pNumeroPagina, @iRegistroTotal) c
		END

        SELECT
            E.IdExpediente,
            E.ExpedienteConfidencial,
			CASE WHEN COALESCE(ED.CorrelativoVinculado,0)=0 THEN E.NTFechaExpediente
			ELSE CONVERT(VARCHAR(10),ISNULl(ED.FechaActualizacionAuditoria,ED.FechaCreacionAuditoria),103) END NTFechaExpediente,
			CASE WHEN COALESCE(ED.CorrelativoVinculado,0)=0 THEN E.HoraExpediente
			ELSE CONVERT(VARCHAR(5),ISNULl(ED.FechaActualizacionAuditoria,ED.FechaCreacionAuditoria),108) END HoraExpediente,
            E.IdCatalogoTipoPrioridad,
            CTP.Descripcion CatalogoTipoPrioridad,
            COALESCE(CTT.Descripcion,'') CatalogoTipoTramite,
			case when COALESCE(E.RazonSocialNombreRemitente,'')='' then COALESCE(NombreCompletoCreador,'')
			else  COALESCE(E.RazonSocialNombreRemitente,'') END +': '+CASE WHEN COALESCE(E.AsuntoExpediente,'')=''
			THEN 'SIN ASUNTO' ELSE E.AsuntoExpediente END AsuntoExpediente,
            E.NumeroFoliosExpediente,
            COALESCE(E.ObservacionesExpediente,'') ObservacionesExpediente,
			Tramite.funParaAnularMesaParte(E.IdExpediente)  ParaAnular,
            COALESCE(EMD.NombreEmpresa,'EXTERNO') NombreEmpresaCreador,
            COALESCE(AD.NombreArea,'') NombreAreaCreador,
            COALESCE(CD.NombreCargo,'') NombreCargoCreador,
			case when COALESCE(E.RazonSocialNombreRemitente,'')='' then COALESCE(NombreCompletoCreador,'')
			else  COALESCE(E.RazonSocialNombreRemitente,'') end NombrePersonaCreador,
            CONCAT(E.NombreExpediente,CASE WHEN COALESCE(ED.CorrelativoVinculado,0)=0 THEN ''
            ELSE '-' +CONVERT(VARCHAR,ED.CorrelativoVinculado) END) NombreExpediente,
            ED.IdExpedienteDocumento,EDO.IdExpedienteDocumentoOrigen,
            CONCAT(C.Descripcion,' ', ED.NumeroDocumento) NumeroDocumento,
			E.FgTramiteVirtual,
			ED.FechaEnvioDocumento
		FROM
			#vTablaExpediente EE
			INNER JOIN Tramite.Expediente E ON E.IdExpediente=EE.IdExpediente
			INNER JOIN Tramite.ExpedienteDocumento ED on ED.IdExpediente=E.IdExpediente AND ED.IdExpedienteDocumento = EE.IdExpedienteDocumento
			INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO on EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND EDO.EstadoAuditoria=1 AND EDO.EsCabecera=1 --and edo.IdAreaOrigenEnvia=@pIdArea
			INNER JOIN Tramite.Catalogo C on C.IdCatalogo=ED.IdCatalogoTipoDocumento
			INNER JOIN Tramite.Catalogo CTP ON CTP.IdCatalogo=E.IdCatalogoTipoPrioridad
			LEFT JOIN General.Empresa EMD ON E.IdEmpresaCreador=EMD.IdEmpresa
			LEFT JOIN General.Area AD ON E.IdAreaCreador= AD.IdArea
			LEFT JOIN General.Cargo CD ON E.IdCargoCreador=CD.IdCargo
			LEFT JOIN General.Persona PD ON E.IdPersonaCreador=PD.IdPersona
			LEFT JOIN Tramite.Catalogo CTT ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
		WHERE EE.eNroOrden Between @iPaginaRegInicio And @iPaginaRegFinal
		ORDER BY EE.eNroOrden ASC

		SELECT @iRegistroTotal
    END TRY
    BEGIN CATCH
		DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX) ,@ERROR_MESSAGE VARCHAR(MAX)
		SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarExpedienteMesaParteDespachadosV1',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
		EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
		SELECT ERROR_MESSAGE()
	END CATCH

go
