ALTER PROCEDURE Tramite.paListarExpedientePendienteEspecialistaReenviados
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
BEGIN
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
			IdPersonaCreador INT,
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
		SELECT @vIdCargo=EP.IdCargo,@vIdArea=EP.IdArea,@vIdEmpresa=ES.IdEmpresa
		FROM RecursoHumano.EmpleadoPerfil EP
		INNER JOIN General.EmpresaSede ES
		    ON ES.IdEmpresaSede=EP.IdEmpresaSede
		where EP.IdEmpleadoPerfil=@pIdEmpleadoPerfil
		    AND EP.EstadoAuditoria=1
			AND EP.Activo=1

		SET LANGUAGE 'SPANISH'
		DECLARE @vTablaExpediente TABLE(IdExpediente int, FechaMovimiento DATETIME )

		IF ISNUMERIC(@pBusquedaGeneral)=1 OR @pBusquedaGeneral IS NULL OR @pBusquedaGeneral=''
		BEGIN
			INSERT INTO @vTablaExpediente
			SELECT EDOD.IdExpediente,MAX(CONVERT(DATETIME,edod.FechaDestinoEnvia +' ' + edod.HoraDestinoEnvia)) FechaMovimiento
			FROM Tramite.visExpedienteCompleto EDOD
			WHERE EDOD.IdPersonaDestino=@pIdPersona
			AND EDOD.IdAreaDestino=@vIdArea
			AND EDOD.IdCargoDestino=@vIdCargo
			AND EDOD.IdEmpresaDestino=@vIdEmpresa
			AND EDOD.IdCatalogoSituacionMovimientoDestino=111
			AND CONVERT(DATETIME,EDOD.FechaDestinoEnvia) BETWEEN  case when @pConFiltroFecha =1 then @pFechaInicio else EDOD.FechaDestinoEnvia end and case when @pConFiltroFecha =1 then @pFechaFin else EDOD.FechaDestinoEnvia end
			AND (EDOD.NumeroExpediente =  @pBusquedaGeneral OR @pBusquedaGeneral IS NULL OR @pBusquedaGeneral=0)
			AND year(convert(datetime,EDOD.FechaDestinoEnvia)) = @pIdPeriodo
			GROUP BY IdExpediente

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
			CASE WHEN COALESCE(E.NombreCompletoCreador,'')<>'' THEN COALESCE(E.NombreCompletoCreador,'') ELSE PE.NombreCompleto END NombreCompletoCreador,
			E.NumeroExpediente,
			COALESCE(ES.IdExpedienteSeguimiento,0)IdExpedienteSeguimiento,
			E1.FechaMovimiento
			FROM Tramite.Expediente E WITH (NOLOCK)
			INNER JOIN @vTablaExpediente E1 ON E1.IdExpediente=E.IdExpediente
			INNER JOIN Seguridad.Usuario US ON US.IdUsuario=E.IdUsuarioCreacionAuditoria AND E.EstadoAuditoria=1  AND COALESCE(E.ExpedienteAnulado,0)=0
			INNER JOIN Tramite.SerieDocumentalExpediente SD WITH (NOLOCK) ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
			INNER JOIN Tramite.Catalogo CTP ON CTP.IdCatalogo=E.IdCatalogoTipoPrioridad
			LEFT  JOIN Tramite.ExpedienteSeguimiento ES WITH (NOLOCK) ON ES.IdExpediente= E.IdExpediente AND ES.EstadoAuditoria=1 AND ES.IdEmpresa=@vIdEmpresa AND ES.IdCargo=@vIdCargo AND ES.IdPersona=@pIdPersona AND ES.IdArea=@vIdArea
			LEFT JOIN General.Persona PE ON PE.IdPersona=E.IdPersonaCreador
			LEFT JOIN Tramite.Catalogo CTT ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
			WHERE E.EstadoAuditoria=1
			ORDER BY FechaMovimiento	DESC
			OFFSET (@pNumeroPagina-1)*@pDimensionPagina ROWS
			FETCH NEXT @pDimensionPagina ROWS ONLY

			SELECT
			CONVERT(BIT,0) EsParaAnular,
			0 DiasPendiente,
			'' NombrePersonaOrigen,
			Tramite.funObtenerNumeroDocumentoEnExpedienteEspecialistaV1(E.IdExpediente,@vIdArea,@vIdCargo,@pIdPersona,@pIdCatalogoSituacionMovimientoDestino) NumeroDocumento,
			Tramite.funObtenerIdExpedienteDocumentoEnExpedienteEspecialista(E.IdExpediente,@vIdArea,@vIdCargo,@pIdPersona,@pIdCatalogoSituacionMovimientoDestino) IdExpedienteDocumento,
			Tramite.funObtenerExpedientesEnlazados(E.IdExpediente) NombreExpedientesEnlazados,
			Tramite.funEsPrincipalEnlace(E.IdExpediente)EsPrincipalEnlace,
			Tramite.fnObtenerOrigenInicialDocumento(E.IdExpediente) CatalogoTipoOrigen,
			COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(E.IdPersonaCreador),'sinfotoH.jpg') RutaFotoPersona,
			*
			FROM @MITABLA E

			SELECT
			COUNT(*)
			FROM
			Tramite.Expediente E WITH (NOLOCK)
			INNER JOIN @vTablaExpediente E1 ON E1.IdExpediente=E.IdExpediente
			INNER JOIN Seguridad.Usuario US ON US.IdUsuario=E.IdUsuarioCreacionAuditoria AND E.EstadoAuditoria=1  AND COALESCE(E.ExpedienteAnulado,0)=0
			INNER JOIN Tramite.SerieDocumentalExpediente SD WITH (NOLOCK) ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
			INNER JOIN Tramite.Catalogo CTP ON CTP.IdCatalogo=E.IdCatalogoTipoPrioridad
			LEFT JOIN General.Persona PE ON PE.IdPersona=E.IdPersonaCreador
			LEFT JOIN Tramite.Catalogo CTT ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
			WHERE E.EstadoAuditoria=1
	END TRY
	BEGIN CATCH
		DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
		SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE(),
		@ERROR_PROCEDURE='Tramite.paListarExpedientePendienteEspecialistaReenviados',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
		EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE, @pIdUsuarioAuditoria
	 END CATCH
END
GO
