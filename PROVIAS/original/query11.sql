CREATE PROCEDURE [Tramite].[paListarExpedientePendienteEspecialistaArchivados]
	@pConFiltroFecha bit,
	@pFechaInicio varchar(10),
	@pFechaFin varchar(10),
	@pConFiltroFechaMovimiento bit,
	@pFechaInicioMovimiento varchar(10),
	@pFechaFinMovimiento varchar(10),
	@pIdPersona int,
	@pIdEmpleadoPerfil int,
	@pIdCatalogoSituacionMovimientoDestino INT,
	@pTipoSituacionMovimiento int,
	@pIdAreaOrigen int,
    @pIdAreaDestino int,
    @pIdPeriodo int,
    @pIdCatalogoTipoPrioridad int,
    @pIdCatalogoTipoTramite int,
    @pIdCatalogoTipoDocumento int,
    @pNumeroExpediente varchar(100),
    @pNumeroDocumento varchar(100),
	@pPersonaDesde varchar(100),
	@pPersonaPara varchar(100),
	@pIdTipoIngreso int,
	@pFechaDocumento  varchar(100),
	@pEmisorExpediente varchar(100),
	@pAsuntoExpediente  varchar(100),
	@pIdUsuarioAuditoria int,
	@pCampoOrdenado varchar(50),
	@pTipoOrdenacion varchar(4),
	@pNumeroPagina INT,
	@pDimensionPagina  INT,
	@pBusquedaGeneral varchar(100),
	@pFlgBusqueda INT
AS
	BEGIN TRY

		DECLARE @vIdCargo int=0
		DECLARE @vIdArea int=0
		DECLARE @vIdEmpresa int=0
		DECLARE @MITABLA TABLE (
			IdExpediente int,
			ExpedienteConfidencial bit,
			NTFechaExpediente varchar (10),
			HoraExpediente varchar (5),
			IdCatalogoTipoPrioridad int,
			CatalogoTipoPrioridad varchar (100),
			CatalogoTipoTramite varchar (100),
			ColorCatalogoTipoTramite varchar (100),
			Logueo varchar (100),
			IdPersonaCreador int,
			AsuntoExpediente varchar (8000),
			NumeroFoliosExpediente int,
			ObservacionesExpediente varchar(4000),
			Fecha VARCHAR(20),
			NombreExpediente varchar (100),
			NombreCompletoCreador varchar (100),
			NumeroExpediente int,
			IdExpedienteSeguimiento int,
			FechaMovimiento datetime
			);

		SELECT @vIdCargo=EP.IdCargo,@vIdArea=EP.IdArea,@vIdEmpresa=ES.IdEmpresa FROM RecursoHumano.EmpleadoPerfil EP INNER JOIN General.EmpresaSede ES ON ES.IdEmpresaSede=EP.IdEmpresaSede where EP.IdEmpleadoPerfil=@pIdEmpleadoPerfil AND EP.EstadoAuditoria=1 AND EP.Activo=1
		SET LANGUAGE 'SPANISH'
	DECLARE @vTablaExpediente TABLE(IdExpediente int)
		IF ISNUMERIC(@pBusquedaGeneral)=1 OR @pBusquedaGeneral IS NULL OR @pBusquedaGeneral=''
		BEGIN
			INSERT INTO @vTablaExpediente
			SELECT ED.IdExpediente FROM
			Tramite.Expediente E WITH (NOLOCK)
			INNER JOIN Tramite.SerieDocumentalExpediente SD WITH (NOLOCK) ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente AND E.EstadoAuditoria=1
			INNER JOIN Tramite.ExpedienteDocumento ED WITH (NOLOCK) ON  E.IdExpediente=ED.IdExpediente AND ED.EstadoAuditoria=1 AND COALESCE(E.ExpedienteAnulado,0)=0
			INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK) ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND EDO.EstadoAuditoria=1
			INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK) ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen AND EDOD.EstadoAuditoria=1
			LEFT JOIN General.Persona PE ON PE.IdPersona=E.IdPersonaCreador
			LEFT JOIN Tramite.Catalogo CTT ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
			WHERE
			EDOD.IdPersonaDestino=@pIdPersona
			AND YEAR(EDOD.FechaCreacionAuditoria) = @pIdPeriodo --archivados para un período
			AND EDOD.IdAreaDestino=@vIdArea
			AND EDOD.IdCargoDestino=@vIdCargo
			AND EDOD.IdEmpresaDestino=@vIdEmpresa
			AND ED.FgEnEsperaFirmaDigital=0
			AND EDOD.IdCatalogoSituacionMovimientoDestino=@pIdCatalogoSituacionMovimientoDestino
			AND CONVERT(DATETIME,EDOD.FechaArchivado) BETWEEN  case when @pConFiltroFecha =1 then @pFechaInicio else EDOD.FechaArchivado end and case when @pConFiltroFecha =1 then @pFechaFin else EDOD.FechaArchivado end
			AND (E.NumeroExpediente =  @pBusquedaGeneral OR @pBusquedaGeneral IS NULL OR @pBusquedaGeneral=0)
			group by ED.IdExpediente
		END
		INSERT INTO @MITABLA
		SELECT
			E.IdExpediente,
			E.ExpedienteConfidencial,
			E.NTFechaExpediente,
			E.HoraExpediente,
			E.IdCatalogoTipoPrioridad,
			CTP.Descripcion CatalogoTipoPrioridad,
			COALESCE(CTT.Descripcion,'') CatalogoTipoTramite,
			COALESCE(CTT.Detalle,'') ColorCatalogoTipoTramite,
			US.Logueo,
			E.IdPersonaCreador,--COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(E.IdPersonaCreador),'sinfotoH.jpg') RutaFotoPersona,
			E.AsuntoExpediente,
			E.NumeroFoliosExpediente,
			COALESCE(E.ObservacionesExpediente,'') ObservacionesExpediente,
			CONCAT(E.NTFechaExpediente ,' ', E.HoraExpediente) Fecha,
			CONCAT(SD.AbreviaturaSerieDocumentalExpediente,RIGHT(CONCAT('000000',E.NumeroExpediente),6), '-', E.IdPeriodo) NombreExpediente,
			CASE WHEN COALESCE(E.NombreCompletoCreador,'')<>'' THEN COALESCE(E.NombreCompletoCreador,'') ELSE PE.NombreCompleto END NombreCompletoCreador,
			E.NumeroExpediente,
			COALESCE(ES.IdExpedienteSeguimiento,0)IdExpedienteSeguimiento,
			Tramite.funObtenerFechaMovimientoEnExpedienteEspecialista(E.IdExpediente,@vIdArea,@vIdCargo,@pIdPersona,@pIdCatalogoSituacionMovimientoDestino) FechaMovimiento
			FROM
			Tramite.Expediente E WITH (NOLOCK)
			INNER JOIN Seguridad.Usuario US ON US.IdUsuario=E.IdUsuarioCreacionAuditoria AND E.EstadoAuditoria=1  AND COALESCE(E.ExpedienteAnulado,0)=0
			INNER JOIN Tramite.SerieDocumentalExpediente SD WITH (NOLOCK) ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
			INNER JOIN Tramite.Catalogo CTP ON CTP.IdCatalogo=E.IdCatalogoTipoPrioridad
			LEFT  JOIN Tramite.ExpedienteSeguimiento ES WITH (NOLOCK) ON ES.IdExpediente= E.IdExpediente AND ES.EstadoAuditoria=1 AND ES.IdEmpresa=@vIdEmpresa AND ES.IdCargo=@vIdCargo AND ES.IdPersona=@pIdPersona AND ES.IdArea=@vIdArea
			LEFT JOIN General.Persona PE ON PE.IdPersona=E.IdPersonaCreador
			LEFT JOIN Tramite.Catalogo CTT ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
			WHERE E.EstadoAuditoria=1 AND E.IdExpediente IN (SELECT * from @vTablaExpediente)
			ORDER BY FechaMovimiento	DESC
			OFFSET (@pNumeroPagina-1)*@pDimensionPagina ROWS
			FETCH NEXT @pDimensionPagina ROWS ONLY


			SELECT
			CONVERT(BIT,0) EsParaAnular,--Tramite.funParaAnularEspecialista(E.IdExpediente,@pIdPersona,@vIdEmpresa,@vIdArea,@vIdCargo) EsParaAnular,
			0 DiasPendiente,--Tramite.funObtenerDiasPendienteEspecislista(E.IdExpediente,@pIdPersona, @vIdEmpresa,@vIdArea,@vIdCargo,@pIdCatalogoSituacionMovimientoDestino) DiasPendiente,
			'' NombrePersonaOrigen,--Tramite.funObtenerAreaEmisorEspecialista(E.IdExpediente,@vIdArea,@vIdCargo,@pIdPersona,@pIdCatalogoSituacionMovimientoDestino) NombrePersonaOrigen,
			isnull(ND.NumeroDocumento,'') NumeroDocumento, --Tramite.funObtenerNumeroDocumentoEnExpedienteEspecialistaV1(E.IdExpediente,@vIdArea,@vIdCargo,@pIdPersona,@pIdCatalogoSituacionMovimientoDestino) NumeroDocumento,
			IED.IdExpedienteDocumento, --Tramite.funObtenerIdExpedienteDocumentoEnExpedienteEspecialista(E.IdExpediente,@vIdArea,@vIdCargo,@pIdPersona,@pIdCatalogoSituacionMovimientoDestino) IdExpedienteDocumento,
			CASE WHEN ENP.ExEnlazadoPri<>'' THEN replace(replace(ENP.ExEnlazadoPri,'&lt;','<'),'&gt;','>') else replace(replace(ENS.ExEnlazadoSec,'&lt;','<'),'&gt;','>') END NombreExpedientesEnlazados, --Tramite.funObtenerExpedientesEnlazados(E.IdExpediente) NombreExpedientesEnlazados,
			CONVERT(BIT,CASE WHEN EE.cantEnlaces>0 THEN 1 ELSE 0 END) EsPrincipalEnlace, --Tramite.funEsPrincipalEnlace(E.IdExpediente)EsPrincipalEnlace,
			OID.CatalogoTipoOrigen, --Tramite.fnObtenerOrigenInicialDocumento(E.IdExpediente) CatalogoTipoOrigen,
			IdExpediente,
			ExpedienteConfidencial,
			NTFechaExpediente,
			HoraExpediente,
			IdCatalogoTipoPrioridad,
			CatalogoTipoPrioridad,
			CatalogoTipoTramite,
			ColorCatalogoTipoTramite,
			Logueo,
			ISNULL(RFP.RutaFotoPersona,'sinfotoH.jpg') RutaFotoPersona,
			AsuntoExpediente,
			NumeroFoliosExpediente,
			ObservacionesExpediente,
			Fecha,
			NombreExpediente,
			NombreCompletoCreador,
			NumeroExpediente,
			IdExpedienteSeguimiento,
			FechaMovimiento
			from @MITABLA E
			OUTER APPLY(
				SELECT TOP 1 case when COALESCE(U1.RutaArchivoFoto,'') ='' then CASE WHEN COALESCE(Pr1.Sexo,0)=0 then 'sinfotoH.jpg' else 'sinfotoM.jpg' end else U1.RutaArchivoFoto end RutaFotoPersona
				FROM Seguridad.Usuario U1
				INNER JOIN General.Persona PR1 ON PR1.IdPersona=U1.IdPersona
				WHERE U1.EstadoAuditoria=1 and pr1.IdPersona=E.IdPersonaCreador AND U1.Bloqueado=0
			)RFP
			OUTER APPLY(
				SELECT
				TOP 1 '<button type="button" data-toggle="tooltip" title="'+COALESCE(EDOD.MotivoArchivado,'')+'" class="btn ui blue label" onclick="MostrarDocumentoPdfExp('''+ED.RutaArchivoDocumento+''','+CONVERT(VARCHAR,ed.IdExpedienteDocumento) +')"><i style="font-size:16px;" class="fa fa-file-text"></i></button><label style="font-size:8px">'+CASE WHEN ED.Correlativo=0 THEN  CONCAT( CTD.Descripcion,' ', COALESCE(ED.NumeroDocumento,'')) ELSE COALESCE(ED.NumeroDocumento,'') END+'</label>' NumeroDocumento
				FROM
				Tramite.ExpedienteDocumento ED WITH (NOLOCK)
				INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK) ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
				INNER JOIN  Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK) ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
				LEFT JOIN Tramite.Catalogo CTD ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
				WHERE  EDOD.IdAreaDestino=@vIdArea AND
				EDOD.IdCargoDestino=@vIdCargo AND
				EDOD.IdPersonaDestino=@pIdPersona AND
				EDOD.IdCatalogoSituacionMovimientoDestino  =@pIdCatalogoSituacionMovimientoDestino
				AND Ed.IdExpediente=E.IdExpediente
			) ND
			OUTER APPLY(
				SELECT
				TOP 1 ed.IdExpedienteDocumento
				FROM
				Tramite.ExpedienteDocumento ED WITH (NOLOCK)
				INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK) ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
				INNER JOIN  Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK) ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
				--LEFT JOIN Tramite.Catalogo CTD ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
				WHERE  EDOD.IdAreaDestino=@vIdArea AND
				EDOD.IdCargoDestino=@vIdCargo AND
				EDOD.IdPersonaDestino=@pIdPersona AND
				EDOD.IdCatalogoSituacionMovimientoDestino  =@pIdCatalogoSituacionMovimientoDestino
				AND Ed.IdExpediente=E.IdExpediente
			) IED
			CROSS APPLY(
				select isnull((select STUFF((
				SELECT distinct '<div style="margin: 2px;padding: 2px;" class="ui blue label">'+
				CONCAT(SD1.AbreviaturaSerieDocumentalExpediente,RIGHT(CONCAT('000000',E1.NumeroExpediente),6), '-', E1.IdPeriodo)
				+'</div> '
				FROM Tramite.ExpedienteEnlazado EE  WITH (NOLOCK)
				INNER JOIN Tramite.Expediente e1  WITH (NOLOCK) ON EE.IdExpedienteSecundario=E1.IdExpediente AND E1.EstadoAuditoria=1 AND E1.ExpedienteAnulado=0
				INNER JOIN Tramite.SerieDocumentalExpediente SD1 ON SD1.IdSerieDocumentalExpediente=E1.IdSerieDocumentalExpediente	 and EE.EstadoAuditoria=1
				where EE.IdExpediente=E.IdExpediente
				FOR XML PATH('')), 1, 0, '')),'') ExEnlazadoPri
			) ENP
			CROSS APPLY(
				select isnull((select STUFF((
				SELECT distinct '<div style="margin: 2px;padding: 2px;" class="ui blue label">'+
				CONCAT(SD1.AbreviaturaSerieDocumentalExpediente,RIGHT(CONCAT('000000',E1.NumeroExpediente),6), '-', E1.IdPeriodo)
				+'</div> '
				FROM Tramite.ExpedienteEnlazado EE  WITH (NOLOCK)
				INNER JOIN Tramite.Expediente e1 WITH (NOLOCK) ON EE.IdExpediente=E1.IdExpediente AND E1.EstadoAuditoria=1 AND E1.ExpedienteAnulado=0
				INNER JOIN Tramite.SerieDocumentalExpediente SD1 ON SD1.IdSerieDocumentalExpediente=E1.IdSerieDocumentalExpediente and EE.EstadoAuditoria=1
				WHERE EE.IdExpedienteSecundario=E.IdExpediente
				FOR XML PATH('')), 1, 0, '')),'') ExEnlazadoSec
			) ENS
			CROSS APPLY(
				SELECT count(ee.Idexpediente) cantEnlaces
				FROM Tramite.ExpedienteEnlazado EE  WITH (NOLOCK)
				INNER JOIN Tramite.Expediente ex WITH (NOLOCK) ON EE.IdExpedienteSecundario=Ex.IdExpediente AND Ex.EstadoAuditoria=1 AND Ex.ExpedienteAnulado=0
				INNER JOIN Tramite.SerieDocumentalExpediente SD1 ON SD1.IdSerieDocumentalExpediente=Ex.IdSerieDocumentalExpediente	 and EE.EstadoAuditoria=1
				where EE.IdExpediente=E.IdExpediente
			) EE
			CROSS APPLY(
				select top 1 CONCAT(coalesce(c.Descripcion,''),' ',EX.NumeroExpedienteExterno) CatalogoTipoOrigen
				from Tramite.ExpedienteDocumento ed1  WITH (NOLOCK)
				INNER JOIN Tramite.Expediente EX  WITH (NOLOCK) ON EX.IdExpediente=Ed1.IdExpediente
				INNER JOIN Tramite.Catalogo c on c.IdCatalogo=ed1.IdCatalogoTipoOrigen
				where ed1.EstadoAuditoria=1 and ed1.IdExpediente=E.IdExpediente
				order by ed1.IdExpedienteDocumento
			) OID

			select count(*) from @vTablaExpediente

	END TRY
	BEGIN CATCH
			DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
			SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarExpedientePendienteEspecialistaArchivados',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
			EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE, @pIdUsuarioAuditoria

	 END CATCH
