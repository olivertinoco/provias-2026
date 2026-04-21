ORIGINAL NO TOCAR
====================

-- if exists(select 1 from sys.sysobjects where id=object_id('Tramite.paListarExpedientePendienteEspecialistaCreados','p'))
-- drop procedure [Tramite].[paListarExpedientePendienteEspecialistaCreados]
-- go
-- CREATE PROCEDURE [Tramite].[paListarExpedientePendienteEspecialistaCreados]
Declare
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
-- AS
-- 	BEGIN TRY

select
	@pConFiltroFecha = 0,
	@pFechaInicio = '13/04/2026',
	@pFechaFin = '13/04/2026',
	@pConFiltroFechaMovimiento = 0,
	@pFechaInicioMovimiento = '13/04/2026',
	@pFechaFinMovimiento = '13/04/2026',
	@pIdPersona = 728,
	@pIdEmpleadoPerfil = 727,
	@pIdCatalogoSituacionMovimientoDestino = 116,
	@pTipoSituacionMovimiento = 4,
	@pIdAreaOrigen = 0,
    @pIdAreaDestino = 0,
    @pIdPeriodo = 2026,
    @pIdCatalogoTipoPrioridad = 0,
    @pIdCatalogoTipoTramite = 0,
    @pIdCatalogoTipoDocumento = 0,
    @pNumeroExpediente = '',
    @pNumeroDocumento = '',
	@pPersonaDesde = '',
	@pPersonaPara = '',
	@pIdTipoIngreso = 0,
	@pFechaDocumento  = '',
	@pEmisorExpediente = '',
	@pAsuntoExpediente  = '',
	@pIdUsuarioAuditoria = 728,
	@pCampoOrdenado = null,
	@pTipoOrdenacion = null,
	@pNumeroPagina = 1,
	@pDimensionPagina = 10,
	@pBusquedaGeneral = null,
	@pFlgBusqueda = 0


		DECLARE @vIdCargo int=0
		DECLARE @vIdArea int=0
		DECLARE @vIdEmpresa int=0

		SELECT @vIdCargo=EP.IdCargo,@vIdArea=EP.IdArea,@vIdEmpresa=ES.IdEmpresa
		FROM RecursoHumano.EmpleadoPerfil EP
		INNER JOIN General.EmpresaSede ES ON ES.IdEmpresaSede=EP.IdEmpresaSede
		    where EP.IdEmpleadoPerfil=@pIdEmpleadoPerfil AND EP.EstadoAuditoria=1 AND EP.Activo=1

		SET LANGUAGE 'SPANISH'
		DECLARE @vTablaExpediente TABLE(IdExpediente int, FechaMovimiento DATETIME )

		IF ISNUMERIC(@pBusquedaGeneral)=1 OR @pBusquedaGeneral IS NULL OR @pBusquedaGeneral=''
		BEGIN
			INSERT INTO @vTablaExpediente
			SELECT EDO.IdExpediente,MAX(CONVERT(DATETIME,edo.FechaOrigen +' ' + edo.HoraOrigen)) FechaMovimiento
			FROM Tramite.visExpedienteCompleto EDO
    			WHERE
    			    EDO.IdPersonaOrigen=@pIdPersona
    			AND EDO.IdPeriodo = @pIdPeriodo
    			AND EDO.IdAreaOrigen=@vIdArea
    			AND EDO.IdCargoOrigen=@vIdCargo
    			AND EDO.IdEmpresaOrigen=@vIdEmpresa
    			AND EDO.IdCatalogoSituacionMovimientoOrigen=116
    			AND CONVERT(DATETIME,EDO.FechaOrigen) BETWEEN
    			case when @pConFiltroFecha =1 then @pFechaInicio else EDO.FechaOrigen end
    			and case when @pConFiltroFecha =1 then @pFechaFin else EDO.FechaOrigen end
    			AND (EDO.NumeroExpediente =
    			    CASE WHEN @pBusquedaGeneral<>'' OR @pBusquedaGeneral IS NOT NULL THEN
    					CASE WHEN ISNUMERIC(@pBusquedaGeneral)=1 THEN @pBusquedaGeneral ELSE EDO.NumeroExpediente END
    				ELSE EDO.NumeroExpediente END)
			GROUP BY IdExpediente
		END


		SELECT
    		Tramite.funParaAnularEspecialista(E.IdExpediente,@pIdPersona,@vIdEmpresa,@vIdArea,@vIdCargo) EsParaAnular,
    		Tramite.fnObtenerOrigenInicialDocumento(E.IdExpediente) CatalogoTipoOrigen,
    		0 DiasPendiente,
    		'' NombrePersonaOrigen,
    		Tramite.funObtenerNumeroDocumentoEnExpedienteEspecialistaV1(
                E.IdExpediente,@vIdArea,@vIdCargo,@pIdPersona,@pIdCatalogoSituacionMovimientoDestino) NumeroDocumento,
    		Tramite.funObtenerIdExpedienteDocumentoEnExpedienteEspecialista(
                E.IdExpediente,@vIdArea,@vIdCargo,@pIdPersona,@pIdCatalogoSituacionMovimientoDestino) IdExpedienteDocumento,
    		Tramite.funObtenerExpedientesEnlazados(E.IdExpediente) NombreExpedientesEnlazados,
    		Tramite.funEsPrincipalEnlace(E.IdExpediente)EsPrincipalEnlace,
    		Tramite.fnObtenerOrigenInicialDocumento(E.IdExpediente) CatalogoTipoOrigen,
    		E.IdExpediente,
    		E.ExpedienteConfidencial,
    		E.NTFechaExpediente,
    		E.HoraExpediente,
    		E.IdCatalogoTipoPrioridad,
    		CTP.Descripcion CatalogoTipoPrioridad,
    		COALESCE(CTT.Descripcion,'') CatalogoTipoTramite,
    		COALESCE(CTT.Detalle,'') ColorCatalogoTipoTramite,
    		US.Logueo,
    		COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(E.IdPersonaCreador),'sinfotoH.jpg') RutaFotoPersona,
    		E.AsuntoExpediente,
    		E.NumeroFoliosExpediente,
    		COALESCE(E.ObservacionesExpediente,'') ObservacionesExpediente,
    		CONCAT(E.NTFechaExpediente ,' ', E.HoraExpediente) Fecha,
    		CONCAT(SD.AbreviaturaSerieDocumentalExpediente,RIGHT(CONCAT('000000',E.NumeroExpediente),6), '-', E.IdPeriodo) NombreExpediente,
    		CASE WHEN COALESCE(E.NombreCompletoCreador,'')<>'' THEN COALESCE(E.NombreCompletoCreador,'') ELSE PE.NombreCompleto END NombreCompletoCreador,
    		E.NumeroExpediente,
    		COALESCE(ES.IdExpedienteSeguimiento,0) IdExpedienteSeguimiento,
    		EX.FechaMovimiento
		FROM
		Tramite.Expediente E WITH (NOLOCK)
		INNER JOIN @vTablaExpediente EX ON EX.IDEXPEDIENTE=E.IDEXPEDIENTE
		INNER JOIN Seguridad.Usuario US ON US.IdUsuario=E.IdUsuarioCreacionAuditoria AND E.EstadoAuditoria=1  AND COALESCE(E.ExpedienteAnulado,0)=0
		INNER JOIN Tramite.SerieDocumentalExpediente SD WITH (NOLOCK) ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
		INNER JOIN Tramite.Catalogo CTP ON CTP.IdCatalogo=E.IdCatalogoTipoPrioridad
		INNER JOIN Tramite.Catalogo CTT ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
		LEFT JOIN General.Persona PE ON PE.IdPersona=E.IdPersonaCreador
		LEFT JOIN Tramite.ExpedienteSeguimiento ES WITH (NOLOCK) ON ES.IdExpediente= E.IdExpediente AND ES.EstadoAuditoria=1 AND ES.IdEmpresa=@vIdEmpresa AND ES.IdCargo=@vIdCargo AND ES.IdPersona=@pIdPersona AND ES.IdArea=@vIdArea
		ORDER BY EX.FechaMovimiento DESC
		OFFSET (@pNumeroPagina-1)*@pDimensionPagina ROWS
		FETCH NEXT @pDimensionPagina ROWS ONLY


		SELECT  COUNT(*)
		FROM
		Tramite.Expediente E WITH (NOLOCK)
		INNER JOIN @vTablaExpediente EX
		    ON EX.IDEXPEDIENTE=E.IDEXPEDIENTE
		INNER JOIN Seguridad.Usuario US
		    ON US.IdUsuario=E.IdUsuarioCreacionAuditoria AND E.EstadoAuditoria=1  AND COALESCE(E.ExpedienteAnulado,0)=0
		INNER JOIN Tramite.SerieDocumentalExpediente SD WITH (NOLOCK)
		    ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
		INNER JOIN Tramite.Catalogo CTP
		    ON CTP.IdCatalogo=E.IdCatalogoTipoPrioridad
		INNER JOIN Tramite.Catalogo CTT
		    ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
		LEFT JOIN General.Persona PE
		    ON PE.IdPersona=E.IdPersonaCreador
		LEFT JOIN Tramite.ExpedienteSeguimiento ES WITH (NOLOCK)
		    ON ES.IdExpediente= E.IdExpediente AND ES.EstadoAuditoria=1 AND ES.IdEmpresa=@vIdEmpresa AND ES.IdCargo=@vIdCargo
			AND ES.IdPersona=@pIdPersona AND ES.IdArea=@vIdArea


	-- END TRY
	-- BEGIN CATCH
	-- 		DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
	-- 		SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarExpedientePendienteEspecialistaCreados',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	-- 		EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE, @pIdUsuarioAuditoria
	--  END CATCH
