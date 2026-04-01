alter PROCEDURE [Tramite].[paListarExpedientePendienteEspecialistaPorRecibir]
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
			FechaMovimiento datetime);

	 if @pIdPeriodo = 0
			set @pIdPeriodo = year(getdate())

	 if @pIdPersona>0
	 begin
		SELECT @vIdCargo=EP.IdCargo,@vIdArea=EP.IdArea,@vIdEmpresa=ES.IdEmpresa
		FROM RecursoHumano.EmpleadoPerfil EP INNER JOIN General.EmpresaSede ES ON ES.IdEmpresaSede=EP.IdEmpresaSede
		where EP.IdEmpleadoPerfil=@pIdEmpleadoPerfil AND EP.EstadoAuditoria=1 AND EP.Activo=1
		SET LANGUAGE 'SPANISH'
	    DECLARE @vTablaExpediente TABLE(IdExpediente int)

		IF ISNUMERIC(@pBusquedaGeneral)=1 OR @pBusquedaGeneral IS NULL OR @pBusquedaGeneral=''
		BEGIN
			INSERT INTO @vTablaExpediente
			SELECT ED.IdExpediente FROM
			Tramite.Expediente E WITH (NOLOCK)
			INNER JOIN Tramite.SerieDocumentalExpediente SD WITH (NOLOCK)
			ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
			INNER JOIN Tramite.ExpedienteDocumento ED  WITH (NOLOCK)
			ON E.IdExpediente=ED.IdExpediente AND ED.EstadoAuditoria=1 AND E.ExpedienteAnulado=0 AND E.EstadoAuditoria=1
			AND ED.FgEnEsperaFirmaDigital=0
			INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO  WITH (NOLOCK)
			ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND EDO.EstadoAuditoria=1
			INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD  WITH (NOLOCK)
			ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen AND EDOD.EstadoAuditoria=1
			WHERE EDOD.IdPersonaDestino=@pIdPersona
			AND EDOD.IdAreaDestino=@vIdArea
			AND EDOD.IdCargoDestino=@vIdCargo
			AND EDOD.IdEmpresaDestino=@vIdEmpresa
			AND EDOD.IdCatalogoSituacionMovimientoDestino=4
			AND (E.NumeroExpediente =  CASE WHEN @pBusquedaGeneral<>'' OR @pBusquedaGeneral IS NOT NULL THEN
			CASE WHEN ISNUMERIC(@pBusquedaGeneral)=1 THEN @pBusquedaGeneral ELSE E.NumeroExpediente END ELSE E.NumeroExpediente END)
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
		E.IdPersonaCreador,
		E.AsuntoExpediente,
		E.NumeroFoliosExpediente,
		COALESCE(E.ObservacionesExpediente,'') ObservacionesExpediente,
		CONCAT(E.NTFechaExpediente ,' ', E.HoraExpediente) Fecha,
		CONCAT(SD.AbreviaturaSerieDocumentalExpediente,RIGHT(CONCAT('000000',E.NumeroExpediente),6), '-', E.IdPeriodo) NombreExpediente,
		CASE WHEN COALESCE(E.NombreCompletoCreador,'')<>'' THEN COALESCE(E.NombreCompletoCreador,'')
		ELSE PE.NombreCompleto END NombreCompletoCreador,
		E.NumeroExpediente,
		COALESCE(ES.IdExpedienteSeguimiento,0)IdExpedienteSeguimiento,
		FM.FechaMovimiento
		FROM Tramite.Expediente E WITH (NOLOCK)
		INNER JOIN @vTablaExpediente ET ON ET.IdExpediente=E.IdExpediente
		INNER JOIN Seguridad.Usuario US ON US.IdUsuario=E.IdUsuarioCreacionAuditoria AND E.EstadoAuditoria=1
		AND COALESCE(E.ExpedienteAnulado,0)=0
		INNER JOIN Tramite.SerieDocumentalExpediente SD WITH (NOLOCK) ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
		INNER JOIN Tramite.Catalogo CTP ON CTP.IdCatalogo=E.IdCatalogoTipoPrioridad
		LEFT  JOIN Tramite.ExpedienteSeguimiento ES WITH (NOLOCK) ON ES.IdExpediente= E.IdExpediente AND ES.EstadoAuditoria=1
		AND ES.IdEmpresa=@vIdEmpresa AND ES.IdCargo=@vIdCargo AND ES.IdPersona=@pIdPersona AND ES.IdArea=@vIdArea
		LEFT JOIN General.Persona PE ON PE.IdPersona=E.IdPersonaCreador
		LEFT JOIN Tramite.Catalogo CTT ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
		CROSS APPLY(
			SELECT
			TOP 1 CONVERT(DATETIME,edod.FechaDestino +' ' + edod.HoraDestino) FechaMovimiento
			FROM
			Tramite.ExpedienteDocumento ED WITH (NOLOCK)
			INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
			ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
			INNER JOIN  Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
			ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
			WHERE  EDOD.IdAreaDestino=@vIdArea AND
			EDOD.IdPersonaDestino=@pIdPersona AND
			EDOD.IdCatalogoSituacionMovimientoDestino =@pIdCatalogoSituacionMovimientoDestino
			AND Ed.IdExpediente=E.IdExpediente AND EDOD.IdCargoDestino =@vIdCargo
			ORDER BY EDOD.IdExpedienteDocumentoOrigenDestino DESC
		) FM
		ORDER BY FM.FechaMovimiento	DESC
		OFFSET (@pNumeroPagina-1)*@pDimensionPagina ROWS
		FETCH NEXT @pDimensionPagina ROWS ONLY


		SELECT convert(BIT,case when PA1.Cant>0 then 0 when PA2.Cant>0 then 1 else 0 end) EsParaAnular,
		isnull(DP.DiasPendiente,0) DiasPendiente,
		isnull(NP.NombrePersonaOrigen,'') NombrePersonaOrigen,
		isnull(ND.NumeroDocumento,'') NumeroDocumento,
		IED.IdExpedienteDocumento,
		CASE WHEN ENP.ExEnlazadoPri<>'' THEN replace(replace(ENP.ExEnlazadoPri,'&lt;','<'),'&gt;','>')
		else replace(replace(ENS.ExEnlazadoSec,'&lt;','<'),'&gt;','>') END NombreExpedientesEnlazados,
		CONVERT(BIT,CASE WHEN EE.cantEnlaces>0 THEN 1 ELSE 0 END) EsPrincipalEnlace,
		OID.CatalogoTipoOrigen,
		E.IdExpediente,
		E.ExpedienteConfidencial,
		E.NTFechaExpediente,
		E.HoraExpediente,
		E.IdCatalogoTipoPrioridad,
		E.CatalogoTipoPrioridad,
		E.CatalogoTipoTramite,
		E.ColorCatalogoTipoTramite,
		E.Logueo,
		ISNULL(RFP.RutaFotoPersona,'sinfotoH.jpg') RutaFotoPersona,
		E.AsuntoExpediente,
		E.NumeroFoliosExpediente,
		E.ObservacionesExpediente,
		E.Fecha,
		E.NombreExpediente,
		E.NombreCompletoCreador,
		E.NumeroExpediente,
		E.IdExpedienteSeguimiento,
		E.FechaMovimiento
		from @MITABLA E
		OUTER APPLY(
				SELECT TOP 1 case when COALESCE(U1.RutaArchivoFoto,'') ='' then
				CASE WHEN COALESCE(Pr1.Sexo,0)=0 then 'sinfotoH.jpg' else 'sinfotoM.jpg' end
				else U1.RutaArchivoFoto end RutaFotoPersona
				FROM Seguridad.Usuario U1
				INNER JOIN General.Persona PR1 ON PR1.IdPersona=U1.IdPersona
				WHERE U1.EstadoAuditoria=1 and pr1.IdPersona=E.IdPersonaCreador AND U1.Bloqueado=0
		)RFP
		CROSS APPLY(
			SELECT COUNT(*) Cant FROM
			Tramite.Expediente E1  WITH (NOLOCK)
			INNER JOIN Tramite.ExpedienteDocumento ED WITH (NOLOCK) ON E1.IdExpediente=ED.IdExpediente
			INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
			ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
			INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
			ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1
			WHERE E1.IdExpediente=E.IdExpediente and EDOD.EsInicial=1 and ed.EsVinculado=0
			and edod.IdCatalogoSituacionMovimientoDestino<>4 and COALESCE(EDOD.FechaDestinoRecepciona,'')=''
			AND E1.EstadoAuditoria=1 and edo.IdAreaOrigen=@vIdArea AND  EDO.IdPersonaOrigen=@pIdPersona
				AND  EDO.IdAreaOrigen= @vIdArea
				AND  EDO.IdCargoOrigen=@vIdCargo
				AND  EDO.IdempresaOrigen=@vIdEmpresa
		) PA1
		CROSS APPLY(
			SELECT COUNT(*) Cant FROM
			Tramite.Expediente E1  WITH (NOLOCK)
			INNER JOIN Tramite.ExpedienteDocumento ED WITH (NOLOCK) ON E1.IdExpediente=ED.IdExpediente
			INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
			ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
			INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
			ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1
			WHERE E1.IdExpediente=E.IdExpediente and EDOD.EsInicial=1 and ed.EsVinculado=0
			and COALESCE(EDOD.FechaDestinoRecepciona,'')='' AND E1.EstadoAuditoria=1 and edo.IdAreaOrigen=@vIdArea
			AND  EDO.IdPersonaOrigen=@pIdPersona
				AND  EDO.IdAreaOrigen= @vIdArea
				AND  EDO.IdCargoOrigen=@vIdCargo
				AND  EDO.IdempresaOrigen=@vIdEmpresa
		) PA2
		OUTER APPLY(
			SELECT
			top 1 CASE WHEN  COALESCE(EDOD.FechaDestinoRecepciona,'')='' THEN CASE
			WHEN DATEDIFF(DAY,CONVERT(DATE, EDO.FechaOrigen),GETDATE())<0 then 0
			ELSE DATEDIFF(DAY,CONVERT(DATE, EDO.FechaOrigen),GETDATE()) END ELSE 0 END DiasPendiente
			FROM Tramite.ExpedienteDocumento ED  WITH (NOLOCK)
			INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
			ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
			INNER JOIN  Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
			ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
			WHERE  EDOD.IdAreaDestino=@vIdArea AND
			EDOD.IdCatalogoSituacionMovimientoDestino  =@pIdCatalogoSituacionMovimientoDestino
			AND Ed.IdExpediente=E.IdExpediente AND EDOD.IdCargoDestino =@vIdCargo AND EDOD.IdEmpresaDestino=@vIdEmpresa
			and edod.IdAreaDestino=@vIdArea and EDOD.IdPersonaDestino=@pIdPersona
		) DP
		OUTER APPLY(
			select isnull((select STUFF((
			SELECT
		        CASE WHEN COALESCE(EDO.IdempresaOrigen,0)=0 THEN ed.NombreCompletoEmisor  ELSE A.NombreArea END +'; '
			FROM Tramite.ExpedienteDocumento ED WITH (NOLOCK)
			INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
			ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
			INNER JOIN  Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
			ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
			left join General.Area A ON A.IdArea=EDO.IdAreaOrigen
			left join General.Persona PO ON PO.IdPersona=EDO.IdPersonaOrigen
			WHERE  EDOD.IdAreaDestino=@vIdArea AND
			EDOD.IdPersonaDestino=@pIdPersona AND
			EDOD.IdCatalogoSituacionMovimientoDestino  IN(4,5)
			AND Ed.IdExpediente=E.IdExpediente AND EDOD.IdCargoDestino =@vIdCargo
			FOR XML PATH('')), 1, 0, '')),'') NombrePersonaOrigen
		) NP
		OUTER APPLY(
			SELECT TOP 1
			case when ED.FgEnEsperaFirmaDigital=1 and Ver.doc=0
			then '<label style="font-size:8px">'+
			    CASE WHEN ED.Correlativo=0
    				THEN  CONCAT( CTD.Descripcion,' ', COALESCE(ED.NumeroDocumento,''))
    				ELSE COALESCE(ED.NumeroDocumento,'')
				END+'</label>'
			else
    			'<button type="button" data-toggle="tooltip" title="'+COALESCE(EDOD.MotivoArchivado,'')+
    			'" class="btn ui blue label" onclick="MostrarDocumentoPdfExp('''+ED.RutaArchivoDocumento+''','+
    			CONVERT(VARCHAR,ed.IdExpedienteDocumento) +
    			')"><i style="font-size:16px;" class="fa fa-file-text"></i></button><label style="font-size:8px">'+
    			CASE WHEN ED.Correlativo=0
                THEN CONCAT( CTD.Descripcion,' ', COALESCE(ED.NumeroDocumento,''))
    			ELSE COALESCE(ED.NumeroDocumento,'')
                END+
                '</label>'
            end NumeroDocumento
			FROM Tramite.ExpedienteDocumento ED WITH (NOLOCK)
			INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
			ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
			INNER JOIN  Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
			ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
			LEFT JOIN Tramite.Catalogo CTD ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
			outer apply(
						select isnull(max(1),0) doc
						from Tramite.ExpedienteDocumentoFirmante EDF
						where EDF.IdExpedienteDocumento=ED.IdExpedienteDocumento and EDF.IdPersona=@pIdPersona and EDF.EstadoAuditoria=1
					) Ver
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
			INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
			ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
			INNER JOIN  Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
			ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
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
				INNER JOIN Tramite.Expediente e1  WITH (NOLOCK)
				ON EE.IdExpedienteSecundario=E1.IdExpediente AND E1.EstadoAuditoria=1 AND E1.ExpedienteAnulado=0
				INNER JOIN Tramite.SerieDocumentalExpediente SD1
				ON SD1.IdSerieDocumentalExpediente=E1.IdSerieDocumentalExpediente	 and EE.EstadoAuditoria=1
				where EE.IdExpediente=E.IdExpediente
				FOR XML PATH('')), 1, 0, '')),'') ExEnlazadoPri
		) ENP
		CROSS APPLY(
				select isnull((select STUFF((
				SELECT distinct '<div style="margin: 2px;padding: 2px;" class="ui blue label">'+
				CONCAT(SD1.AbreviaturaSerieDocumentalExpediente,RIGHT(CONCAT('000000',E1.NumeroExpediente),6), '-', E1.IdPeriodo)
				+'</div> '
				FROM Tramite.ExpedienteEnlazado EE  WITH (NOLOCK)
				INNER JOIN Tramite.Expediente e1 WITH (NOLOCK)
				ON EE.IdExpediente=E1.IdExpediente AND E1.EstadoAuditoria=1 AND E1.ExpedienteAnulado=0
				INNER JOIN Tramite.SerieDocumentalExpediente SD1
				ON SD1.IdSerieDocumentalExpediente=E1.IdSerieDocumentalExpediente and EE.EstadoAuditoria=1
				WHERE EE.IdExpedienteSecundario=E.IdExpediente
				FOR XML PATH('')), 1, 0, '')),'') ExEnlazadoSec
		) ENS
		CROSS APPLY(
				SELECT count(ee.Idexpediente) cantEnlaces
				FROM Tramite.ExpedienteEnlazado EE  WITH (NOLOCK)
				INNER JOIN Tramite.Expediente ex WITH (NOLOCK)
				ON EE.IdExpedienteSecundario=Ex.IdExpediente AND Ex.EstadoAuditoria=1 AND Ex.ExpedienteAnulado=0
				INNER JOIN Tramite.SerieDocumentalExpediente SD1
				ON SD1.IdSerieDocumentalExpediente=Ex.IdSerieDocumentalExpediente and EE.EstadoAuditoria=1
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

		SELECT COUNT(IdExpediente)  from @vTablaExpediente
	 end
	 else
	 begin
		SELECT
		 0 EsParaAnular,
		 0 DiasPendiente,
		'' NombrePersonaOrigen,
		'' NumeroDocumento,
		0 IdExpedienteDocumento,
		'' NombreExpedientesEnlazados,
		0 EsPrincipalEnlace,
		'' CatalogoTipoOrigen,
		E.IdExpediente,
		E.ExpedienteConfidencial,
		E.NTFechaExpediente,
		E.HoraExpediente,
		E.IdCatalogoTipoPrioridad,
		E.CatalogoTipoPrioridad,
		E.CatalogoTipoTramite,
		E.ColorCatalogoTipoTramite,
		E.Logueo,
		'sinfotoH.jpg' RutaFotoPersona,
		E.AsuntoExpediente,
		E.NumeroFoliosExpediente,
		E.ObservacionesExpediente,
		E.Fecha,
		E.NombreExpediente,
		E.NombreCompletoCreador,
		E.NumeroExpediente,
		E.IdExpedienteSeguimiento,
		E.FechaMovimiento
		from @MITABLA E

		SELECT COUNT(IdExpediente)  from @vTablaExpediente
	 end
	END TRY
	BEGIN CATCH
			DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
			SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarExpedientePendienteEspecialistaPorRecibir',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
			EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE, @pIdUsuarioAuditoria

	 END CATCH

go
select concat(object_schema_name(object_id), '.', object_name(object_id)) sp, create_date, modify_date from sys.procedures order by 3 desc
