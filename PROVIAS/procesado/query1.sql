if exists(select 1 from sys.sysobjects where id=object_id('Tramite.paListarExpedienteMesaParteDespachadosV1','p'))
drop procedure [Tramite].[paListarExpedienteMesaParteDespachadosV1]
go
create PROCEDURE [Tramite].[paListarExpedienteMesaParteDespachadosV1]
    @pIdArea int,
    @pIdUsuarioAuditoria int,
    @pCampoOrdenado varchar(50),
    @pTipoOrdenacion varchar(4),
    @pNumeroPagina INT,
    @pDimensionPagina  INT,
    @pBusquedaGeneral varchar(100)
as
begin
	BEGIN TRY
	set nocount on
	set tran isolation level read uncommitted

		Declare
		@pBusquedaGeneralfText Varchar(400), @pBusquedaGeneralfTextLike Bit, @iRegistroTotal Int,
		@iPaginaRegInicio Int, @iPaginaRegFinal Int

        select @pBusquedaGeneral = RTrim(LTrim(@pBusquedaGeneral))
        Create Table #vTablaExpediente(IdExpediente BigInt, IdExpedienteDocumento BigInt, eNroOrden Int)

		IF @pBusquedaGeneral is not null and @pBusquedaGeneral != ''
			BEGIN
                select @pBusquedaGeneralfText = concat('"', cadena, '*"') from tramite.fnUtilitario_sanitizar(@pBusquedaGeneral)

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
							cast(concat(E.NTFechaExpediente, ' ', E.HoraExpediente) as datetime) As FechaExpediente
						FROM
							Tramite.Expediente E
							INNER JOIN Tramite.ExpedienteDocumento ED ON
							ED.IdExpediente=E.IdExpediente AND ED.EstadoAuditoria=1 AND ED.IdEmpresaEmisor=0
						WHERE
							E.EstadoAuditoria=1 And E.ExpedienteAnulado=0 AND E.IdCatalogoSituacionExpediente=63
							And
							(
    			                CONTAINS(E.AsuntoExpediente, @pBusquedaGeneralfText) OR
    							CONTAINS(E.NombreExpediente, @pBusquedaGeneralfText) OR
    							CONTAINS(E.NombreCompletoCreador, @pBusquedaGeneralfText) OR
    							CONTAINS(ED.NumeroDocumento, @pBusquedaGeneralfText)
							)
						ORDER BY E.IdExpediente Desc
					) SE
			END
		ELSE
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
					cast(concat(E.NTFechaExpediente, ' ', E.HoraExpediente) as datetime) As FechaExpediente
					FROM
						Tramite.Expediente E
						INNER JOIN Tramite.ExpedienteDocumento ED  on
						ED.IdExpediente=E.IdExpediente AND ED.EstadoAuditoria=1 AND ED.IdEmpresaEmisor=0
					WHERE
						E.EstadoAuditoria=1	And E.ExpedienteAnulado=0 AND E.IdCatalogoSituacionExpediente=63
					ORDER BY E.IdExpediente Desc
				) SE


		Set @iRegistroTotal = (Select Count(1) From #vTablaExpediente)
		SELECT @iPaginaRegInicio = c.iStartRow,
			@iPaginaRegFinal = c.iEndrow
		FROM General.fnObtenerPaginacion(@pDimensionPagina, @pNumeroPagina, @iRegistroTotal) c


		;with tmp001_empresa as(
            select*from(values(1,'PROVIAS'),(2,'PROVIAS'))EMD(IdEmpresa,NombreEmpresa)
        )
        SELECT
            E.IdExpediente,
            isnull(E.ExpedienteConfidencial, 0) ExpedienteConfidencial,
			CASE WHEN COALESCE(ED.CorrelativoVinculado,0)=0 THEN E.NTFechaExpediente
			ELSE CONVERT(VARCHAR(10),ISNULl(ED.FechaActualizacionAuditoria,ED.FechaCreacionAuditoria),103) END NTFechaExpediente,
			CASE WHEN COALESCE(ED.CorrelativoVinculado,0)=0 THEN E.HoraExpediente
			ELSE CONVERT(VARCHAR(5),ISNULl(ED.FechaActualizacionAuditoria,ED.FechaCreacionAuditoria),108) END HoraExpediente,
            isnull(E.IdCatalogoTipoPrioridad, 0) IdCatalogoTipoPrioridad,
            isnull(CTP.Descripcion, '') CatalogoTipoPrioridad,
            isnull(CTT.Descripcion,'') CatalogoTipoTramite,
			case when COALESCE(E.RazonSocialNombreRemitente,'')='' then COALESCE(NombreCompletoCreador,'')
			else  COALESCE(E.RazonSocialNombreRemitente,'') END +': '+CASE WHEN COALESCE(E.AsuntoExpediente,'')=''
			THEN 'SIN ASUNTO' ELSE E.AsuntoExpediente END AsuntoExpediente,
            isnull(E.NumeroFoliosExpediente, 0) NumeroFoliosExpediente,
            COALESCE(E.ObservacionesExpediente,'') ObservacionesExpediente,
			isnull(case count(1)over(partition by E.IdExpediente) when 1 then anula.paraAnular else 0 end,0) ParaAnular,
            COALESCE(EMD.NombreEmpresa,'EXTERNO') NombreEmpresaCreador,
            COALESCE(AD.NombreArea,'') NombreAreaCreador,
            COALESCE(CD.NombreCargo,'') NombreCargoCreador,
			case when COALESCE(E.RazonSocialNombreRemitente,'')='' then COALESCE(NombreCompletoCreador,'')
			else  COALESCE(E.RazonSocialNombreRemitente,'') end NombrePersonaCreador,
            CONCAT(E.NombreExpediente,CASE WHEN COALESCE(ED.CorrelativoVinculado,0)=0 THEN ''
            ELSE '-' +CONVERT(VARCHAR,ED.CorrelativoVinculado) END) NombreExpediente,
            ED.IdExpedienteDocumento,
            EDO.IdExpedienteDocumentoOrigen,
            CONCAT(C.Descripcion,' ', ED.NumeroDocumento) NumeroDocumento,
			isnull(E.FgTramiteVirtual,0) FgTramiteVirtual,
			isnull(ED.FechaEnvioDocumento,'') FechaEnvioDocumento
		FROM
			#vTablaExpediente EE
			inner join Tramite.Expediente E on E.IdExpediente=EE.IdExpediente
			inner join Tramite.ExpedienteDocumento ED
			    on ED.IdExpediente=E.IdExpediente AND ED.IdExpedienteDocumento = EE.IdExpedienteDocumento
			inner join Tramite.ExpedienteDocumentoOrigen EDO
			    on EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND EDO.EstadoAuditoria=1 AND EDO.EsCabecera=1
			inner join Tramite.Catalogo C on C.IdCatalogo = ED.IdCatalogoTipoDocumento
			inner join Tramite.Catalogo CTP on CTP.IdCatalogo = E.IdCatalogoTipoPrioridad
			left join Tramite.Catalogo CTT on CTT.IdCatalogo= E.IdCatalogoTipoTramite
			left join tmp001_empresa EMD on EMD.IdEmpresa = E.IdEmpresaCreador
			left join General.Area AD on AD.IdArea = E.IdAreaCreador
			left join General.Cargo CD on CD.IdCargo = E.IdCargoCreador
			left join General.Persona PD on PD.IdPersona = E.IdPersonaCreador
			left join (
    			SELECT IdExpedienteDocumentoOrigen, paraAnular
                FROM(SELECT o.IdExpedienteDocumentoOrigen,
                    CASE
                        WHEN COUNT(1) OVER(PARTITION BY o.IdExpedienteDocumentoOrigen) > 0
                        THEN 0
                        ELSE 1
                    END AS paraAnular,
                    ROW_NUMBER() OVER(
                        PARTITION BY o.IdExpedienteDocumentoOrigen
                        ORDER BY o.IdExpedienteDocumentoOrigen
                    ) AS rn
                    FROM Tramite.ExpedienteDocumentoOrigenDestino o WHERE o.FechaDestinoRecepciona IS NOT NULL
                ) x WHERE rn = 1
            ) anula ON anula.IdExpedienteDocumentoOrigen = EDO.IdExpedienteDocumentoOrigen
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
end
go
