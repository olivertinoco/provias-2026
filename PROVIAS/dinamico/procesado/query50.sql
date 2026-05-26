-- NOTA: DEJAR PARA EL ULTIMO Y NO PONER PERIODO  (todos los años:)
-- =====================================
-- CREATE PROCEDURE Tramite.paListarExpedientePendienteCourrierJefaturaPorAnno_arq
declare
	@pIdArea int,
	@pIdCatalogoSituacionMovimientoDestino INT,
	@pIdUsuarioAuditoria int,
	@pCampoOrdenado varchar(50),
	@pTipoOrdenacion varchar(4),
	@pNumeroPagina INT,
	@pDimensionPagina  INT,
	@pBusquedaGeneral varchar(100)
	@pIdPeriodo int
-- AS
-- BEGIN
-- BEGIN TRY
SET LANGUAGE SPANISH
set tran isolation level read uncommitted
set nocount on


select
@pIdArea= 79,
@pIdCatalogoSituacionMovimientoDestino= 0,
@pIdUsuarioAuditoria= 349,
@pCampoOrdenado= null,
@pTipoOrdenacion= null,
@pNumeroPagina= 1,
@pDimensionPagina= 10,
@pBusquedaGeneral= null,
@pIdPeriodo= 2025


	DECLARE @vIdPeriodo varchar(4) = convert(varchar, @pIdPeriodo)
	DECLARE @Consulta Nvarchar(max)=''
	,@Consulta2 Nvarchar(max)=''
	,@Filtros Nvarchar(max)=''
	,@Offset NVARCHAR(MAX)=''
	,@Fetch NVARCHAR(MAX)=''
	,@Orden NVARCHAR(MAX)=''
	,@Parametros NVARCHAR(MAX)=''
	,@pTotalRegistros  INT
	,@vIdAreaJefe int=0
	,@vIdEmpresaJefe int=0
	,@vTipoPendiente NVARCHAR(max)= ''
	,@vIdCargoJefe int=0

	IF COALESCE(@pBusquedaGeneral,'')<>'' SET @Filtros ='AND (X.NombreExpediente LIKE ''%'+@pBusquedaGeneral +'%''
	OR X.NombreCompletoCreador LIKE ''%'+@pBusquedaGeneral +'%'' )'

	SELECT @vIdAreaJefe=IdArea,@vIdEmpresaJefe=IdEmpresa FROM RecursoHumano.visPersonaJefe where IdArea=@pIdArea

	IF @pIdCatalogoSituacionMovimientoDestino=0
	BEGIN
		IF COALESCE(@pBusquedaGeneral,'')<>'' SET @Filtros =' AND (X.NombreExpediente LIKE ''%'+@pBusquedaGeneral +
		'%'' OR X.NombreCompletoCreador LIKE ''%'+@pBusquedaGeneral +'%'' OR X.AsuntoExpediente LIKE ''%'+@pBusquedaGeneral +'%'')'
		SET @Orden=' ORDER BY Fecha desc '


		IF @pTotalRegistros<=(@pNumeroPagina-1)*@pDimensionPagina
			SET @Offset= ' OFFSET 0 ROWS '
		ELSE
			SET @Offset= ' OFFSET ' +CONVERT(VARCHAR(10),(@pNumeroPagina-1)*@pDimensionPagina) + ' ROWS '
		SET @Fetch= ' FETCH NEXT '+CONVERT(VARCHAR(10),@pDimensionPagina) +' ROWS ONLY '

		SET @Consulta= N'
			DECLARE @vTablaExpediente TABLE(IdExpediente int)
			INSERT INTO @vTablaExpediente
			SELECT ED.IdExpediente
			FROM Tramite.ExpedienteDocumento_Historico_' + @vIdPeriodo + N' ED
			INNER JOIN Tramite.ExpedienteDocumentoOrigen_Historico_' + @vIdPeriodo + N' EDO
			ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1 AND ED.IdAreaEmisor='+
			CONVERT(VARCHAR,@vIdAreaJefe)+' AND ED.IdCargoEmisor in(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34))
			INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD
			ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1 AND EDOD.IdCatalogoTipoMovimientoDestino=72
			WHERE  EDOD.EstadoAuditoria=1 group by ED.IdExpediente

			select * FROM (SELECT
			Tramite.funParaAnularJefatura(E.IdExpediente,'+CONVERT(VARCHAR,@pIdArea)+','+CONVERT(VARCHAR,@vIdCargoJefe)+') EsParaAnular,
			Tramite.funEsMiAnuladoJefatura(E.IdExpediente,'+CONVERT(VARCHAR,@pIdArea)+','+CONVERT(VARCHAR,@vIdCargoJefe)+') EsMiAnulado,
			E.ExpedienteAnulado,COALESCE(E.MotivoExpedienteAnulado,'''')MotivoExpedienteAnulado,
			COALESCE(E.NFechaAnulacionExpediente,'''')NFechaAnulacionExpediente,
			COALESCE(E.HoraAnulacionExpediente,'''')HoraAnulacionExpediente,
			Tramite.funObtenerDiasPendiente(E.IdExpediente,'+ CONVERT(VARCHAR,@vIdAreaJefe)+','+
			CONVERT(VARCHAR,@pIdCatalogoSituacionMovimientoDestino)+') DiasPendiente,
			E.IdExpediente,E.ExpedienteConfidencial,E.NTFechaExpediente,E.HoraExpediente,E.IdCatalogoTipoPrioridad,CTP.Descripcion CatalogoTipoPrioridad,
			COALESCE(CTT.Descripcion,'''') CatalogoTipoTramite,US.Logueo,
			COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(E.IdPersonaCreador),''sinfotoH.jpg'') RutaFotoPersona,
			UPPER(E.AsuntoExpediente) AsuntoExpediente,E.NumeroFoliosExpediente,
			COALESCE(E.ObservacionesExpediente,'''') ObservacionesExpediente,
			CONVERT(DATETIME,E.NTFechaExpediente +'' ''+ E.HoraExpediente) Fecha,
			CONCAT(SD.AbreviaturaSerieDocumentalExpediente +RIGHT(''000000''+CONVERT(VARCHAR,E.NumeroExpediente),6), ''-'', E.IdPeriodo) NombreExpediente,
			CASE WHEN COALESCE(E.IdPersonaCreador,0)=0 THEN COALESCE(E.NombreCompletoCreador,'''') ELSE PE.NombreCompleto END NombreCompletoCreador
			FROM Tramite.Expediente_Historico_' + @vIdPeriodo + N' E
			INNER JOIN @vTablaExpediente EE ON EE.IdExpediente=E.IdExpediente
			INNER JOIN Seguridad.Usuario US ON US.IdUsuario=E.IdUsuarioCreacionAuditoria
			INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
			INNER JOIN Tramite.Catalogo CTP ON CTP.IdCatalogo=E.IdCatalogoTipoPrioridad
			LEFT JOIN General.Persona PE ON PE.IdPersona=E.IdPersonaCreador
			LEFT JOIN Tramite.Catalogo CTT ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
			WHERE E.EstadoAuditoria=1)X WHERE 1=1 '
			+@Filtros
			+@Orden
			+@Offset
			+@Fetch
		set @Consulta2 = @Consulta
		EXECUTE sp_executesql @Consulta2
	END
	ELSE
	BEGIN
		SET @Orden=' ORDER BY DiasPendiente DESC, Fecha DESC '
		SET @Offset= ' OFFSET ' +CONVERT(VARCHAR(10),(@pNumeroPagina-1)*@pDimensionPagina) + ' ROWS'
		SET @Fetch= ' FETCH NEXT '+CONVERT(VARCHAR(10),@pDimensionPagina) +' ROWS ONLY'

		IF @pIdCatalogoSituacionMovimientoDestino=-1
		BEGIN
			SET @vTipoPendiente = ' AND EDOD.EstadoAuditoria=1 '+
			' AND (EDOD.IdAreaDestino='+CONVERT(varchar,@vIdAreaJefe)+' OR EDO.IdAreaOrigen='+CONVERT(varchar,@vIdAreaJefe)+')'+
			' AND (EDOD.IdEmpresaDestino='+ CONVERT(VARCHAR,@vIdEmpresaJefe)+ ' OR EDO.IdEmpresaOrigen='+ CONVERT(VARCHAR,@vIdEmpresaJefe)+ ') '+
			' AND (EDOD.IdCargoDestino IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34))'+
			' OR EDO.IdCargoOrigen IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)))  group by Ed.IdExpediente'
		END

		IF @pIdCatalogoSituacionMovimientoDestino =4
		BEGIN
			SET @vTipoPendiente =
			'AND CASE WHEN EE.IdEnvio IS NULL THEN EDOD.IdCatalogoSituacionMovimientoDestino ELSE EE.IdCatalogoSituacionEnvio  END ='+
			CONVERT(VARCHAR,@pIdCatalogoSituacionMovimientoDestino) +
			' AND EDO.IdAreaOrigenEnvia='+ CONVERT(VARCHAR,@vIdAreaJefe)+
			' AND EDO.IdEmpresaOrigenEnvia =2 group by Ed.IdExpediente'
		END

		IF @pIdCatalogoSituacionMovimientoDestino =5
		BEGIN
			SET @vTipoPendiente =
			' AND EDOD.IdCatalogoSituacionMovimientoDestino ='+CONVERT(VARCHAR,@pIdCatalogoSituacionMovimientoDestino) +
			' AND EDOD.IdAreaDestino='+ CONVERT(VARCHAR,@vIdAreaJefe)+
			' AND EDOD.IdEmpresaDestino='+CONVERT(varchar,@vIdEmpresaJefe)+
			' AND EDOD.IdCargoDestino IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)) group by Ed.IdExpediente'
		END

		IF @pIdCatalogoSituacionMovimientoDestino =3
		BEGIN
			SET @vTipoPendiente =
			' AND EDOD.IdCatalogoSituacionMovimientoDestino ='+CONVERT(VARCHAR,@pIdCatalogoSituacionMovimientoDestino) +
			' AND EDOD.IdAreaDestino='+ CONVERT(VARCHAR,@vIdAreaJefe)+
			' AND EDOD.IdEmpresaDestino='+CONVERT(varchar,@vIdEmpresaJefe)+
			' AND EDOD.IdCargoDestino IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)) group by Ed.IdExpediente'
		END

		IF @pIdCatalogoSituacionMovimientoDestino =116
		BEGIN
			SET @vTipoPendiente =
			' AND EDO.IdCatalogoSituacionMovimientoOrigen ='+CONVERT(VARCHAR,@pIdCatalogoSituacionMovimientoDestino) +
			' AND EDO.IdAreaOrigen='+ CONVERT(VARCHAR,@vIdAreaJefe)+
			' AND EDO.IdEmpresaOrigen='+CONVERT(varchar,@vIdEmpresaJefe)+
			' AND EDO.IdCargoOrigen IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)) group by Ed.IdExpediente'
		END

		IF @pIdCatalogoSituacionMovimientoDestino=6
		BEGIN
			SET @vTipoPendiente =
			' AND EDOD.IdCatalogoSituacionMovimientoDestino ='+CONVERT(VARCHAR,@pIdCatalogoSituacionMovimientoDestino) +
			' AND EDOD.IdAreaDestino='+ CONVERT(VARCHAR,@vIdAreaJefe)+
			' AND EDOD.IdEmpresaDestino='+CONVERT(varchar,@vIdEmpresaJefe)+
			' AND EDOD.IdCargoDestino IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)) group by Ed.IdExpediente'
		END
		IF @pIdCatalogoSituacionMovimientoDestino =111
		BEGIN
			SET @vTipoPendiente =
			' AND EDOD.IdCatalogoSituacionMovimientoDestino ='+CONVERT(VARCHAR,@pIdCatalogoSituacionMovimientoDestino) +
			' AND EDOD.IdAreaDestino='+ CONVERT(VARCHAR,@vIdAreaJefe)+
			' AND EDOD.IdEmpresaDestino='+CONVERT(varchar,@vIdEmpresaJefe)+
			' AND EDOD.IdCargoDestino IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)) group by Ed.IdExpediente'
		END

		IF @pIdCatalogoSituacionMovimientoDestino =112
		BEGIN
			SET @vTipoPendiente =
			' AND EDOD.IdCatalogoSituacionMovimientoDestino ='+CONVERT(VARCHAR,@pIdCatalogoSituacionMovimientoDestino) +
			' AND EDOD.IdAreaDestino='+ CONVERT(VARCHAR,@vIdAreaJefe)+
			' AND EDOD.IdEmpresaDestino='+CONVERT(varchar,@vIdEmpresaJefe)+
			' AND EDOD.IdCargoDestino IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34) CA) group by Ed.IdExpediente'
		END

		IF @pIdCatalogoSituacionMovimientoDestino =12
		BEGIN
			SET @vTipoPendiente =
			'AND CASE WHEN EE.IdEnvio IS NULL THEN EDOD.IdCatalogoSituacionMovimientoDestino ELSE EE.IdCatalogoSituacionEnvio END ='+
			CONVERT(VARCHAR,@pIdCatalogoSituacionMovimientoDestino) +
			' AND EDO.IdAreaOrigenEnvia='+ CONVERT(VARCHAR,@vIdAreaJefe)+
			' AND EDO.IdEmpresaOrigenEnvia =2 group by Ed.IdExpediente'
		END
		IF @pIdCatalogoSituacionMovimientoDestino =3
		BEGIN
			SET @vTipoPendiente =
			'AND CASE WHEN EE.IdEnvio IS NULL THEN EDOD.IdCatalogoSituacionMovimientoDestino ELSE EE.IdCatalogoSituacionEnvio  END ='+
			CONVERT(VARCHAR,@pIdCatalogoSituacionMovimientoDestino) +
			' AND EDO.IdAreaOrigenEnvia='+ CONVERT(VARCHAR,@vIdAreaJefe)+
			' AND EDO.IdEmpresaOrigenEnvia =2 group by Ed.IdExpediente'
		END
		IF @pIdCatalogoSituacionMovimientoDestino =11
		BEGIN
			SET @vTipoPendiente =
			'AND CASE WHEN EE.IdEnvio IS NULL THEN EDOD.IdCatalogoSituacionMovimientoDestino ELSE EE.IdCatalogoSituacionEnvio  END ='+
			CONVERT(VARCHAR,@pIdCatalogoSituacionMovimientoDestino) +
			' AND EDO.IdAreaOrigenEnvia='+ CONVERT(VARCHAR,@vIdAreaJefe)+
			' AND EDO.IdEmpresaOrigenEnvia =2 group by Ed.IdExpediente'
		END

		IF @pIdCatalogoSituacionMovimientoDestino =7
		BEGIN
			SET @vTipoPendiente =
			'AND CASE WHEN EE.IdEnvio IS NULL THEN EDOD.IdCatalogoSituacionMovimientoDestino ELSE EE.IdCatalogoSituacionEnvio  END ='+
			CONVERT(VARCHAR,@pIdCatalogoSituacionMovimientoDestino) +
			' AND EDO.IdAreaOrigenEnvia='+ CONVERT(VARCHAR,@vIdAreaJefe)+
			' AND EDO.IdEmpresaOrigenEnvia =2 group by Ed.IdExpediente'
		END


		SET @Consulta='
		DECLARE @vTablaExpediente TABLE(IdExpediente int)
		INSERT INTO @vTablaExpediente
		SELECT Ed.IdExpediente
		FROM Tramite.ExpedienteDocumento_Historico_' + @vIdPeriodo + N' ED
		INNER JOIN Tramite.ExpedienteDocumentoOrigen_Historico_' + @vIdPeriodo + N' EDO
		ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino_Historico_' + @vIdPeriodo + N' EDOD
		ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen
		AND EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1 AND EDOD.IdCatalogoTipoMovimientoDestino=72
		LEFT JOIN Courrier.Envio EE ON EE.IdExpedienteDocumentoOrigenDestino =	EDOD.IdExpedienteDocumentoOrigenDestino
		AND EE.EstadoAuditoria=1 AND FgEntregado=0
		WHERE 1=1 '
		+@vTipoPendiente
		+' SELECT *
		FROM (SELECT
		Tramite.funParaAnularJefatura(E.IdExpediente,'+CONVERT(VARCHAR,@pIdArea)+','+CONVERT(VARCHAR,@vIdCargoJefe)+') EsParaAnular,
	    E.ExpedienteAnulado,
	    COALESCE(E.MotivoExpedienteAnulado,'''')MotivoExpedienteAnulado,
	    COALESCE(E.NFechaAnulacionExpediente,'''')NFechaAnulacionExpediente,
	    COALESCE(E.HoraAnulacionExpediente,'''')HoraAnulacionExpediente,
		Tramite.funObtenerDiasPendiente(E.IdExpediente,'+ CONVERT(VARCHAR,@vIdAreaJefe)+','+CONVERT(VARCHAR,@pIdCatalogoSituacionMovimientoDestino)+') DiasPendiente,
		E.IdExpediente,E.ExpedienteConfidencial,E.NTFechaExpediente,E.HoraExpediente,E.IdCatalogoTipoPrioridad,CTP.Descripcion CatalogoTipoPrioridad,
		COALESCE(CTT.Descripcion,'''') CatalogoTipoTramite,US.Logueo,
		COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(E.IdPersonaCreador),''sinfotoH.jpg'') RutaFotoPersona,
		UPPER(E.AsuntoExpediente) AsuntoExpediente,
		COALESCE(E.NumeroFoliosExpediente,0)NumeroFoliosExpediente,
		COALESCE(E.ObservacionesExpediente,'''') ObservacionesExpediente,
		CONVERT(DATETIME,E.NTFechaExpediente +'' ''+ E.HoraExpediente) Fecha,
		Tramite.funEsMiAnuladoJefatura(E.IdExpediente,'+CONVERT(VARCHAR,@pIdArea)+','+CONVERT(VARCHAR,@vIdCargoJefe)+') EsMiAnulado,
		CONCAT(SD.AbreviaturaSerieDocumentalExpediente +RIGHT(''0000''+CONVERT(VARCHAR,E.NumeroExpediente),5), ''-'', E.IdPeriodo) NombreExpediente,
		CASE WHEN COALESCE(E.IdPersonaCreador,0)=0 THEN COALESCE(E.NombreCompletoCreador,'''') ELSE PE.NombreCompleto END NombreCompletoCreador
		FROM Tramite.Expediente_Historico_' + @vIdPeriodo + N' E
		INNER JOIN @vTablaExpediente EE ON EE.IdExpediente=E.IdExpediente
		INNER JOIN Seguridad.Usuario US ON US.IdUsuario=E.IdUsuarioCreacionAuditoria
		INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
		INNER JOIN Tramite.Catalogo CTP ON CTP.IdCatalogo=E.IdCatalogoTipoPrioridad
		LEFT JOIN General.Persona PE ON PE.IdPersona=E.IdPersonaCreador
		LEFT JOIN Tramite.Catalogo CTT ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
		WHERE E.EstadoAuditoria=1 ) X  WHERE X.EsMiAnulado=X.ExpedienteAnulado '
		+@Filtros
		+@Orden
		+@Offset
		+@Fetch
		set @Consulta2 = @Consulta
		EXECUTE sp_executesql @Consulta2
	END

-- END TRY
-- BEGIN CATCH
-- 		DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
-- 		SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE(),
-- 		@ERROR_PROCEDURE='Tramite.paListarExpedientePendienteCourrierJefatura',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
-- 		EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE,@pIdUsuarioAuditoria
-- END CATCH
-- END
-- GO



-- EXECUTE Tramite.paListarExpedientePendienteCourrierJefaturaPorAnno_arq ,0,349,null,null,1,10,null,2025
