CREATE PROCEDURE [Tramite].[paListarExpedientePendienteCourrierJefatura]
	@pIdArea int,
	@pIdCatalogoSituacionMovimientoDestino INT,
	@pIdUsuarioAuditoria int,
	@pCampoOrdenado varchar(50),
	@pTipoOrdenacion varchar(4),
	@pNumeroPagina INT,
	@pDimensionPagina  INT,
	@pBusquedaGeneral varchar(100)
AS
	BEGIN TRY
		--declare @t1 datetime;
		--declare @t2 datetime;
		--set @t1=getdate();

		--declare @pIdArea int=7,
		--@pIdCatalogoSituacionMovimientoDestino INT=0,
		--@pIdUsuarioAuditoria int=528,
		--@pCampoOrdenado varchar(50)=null,
		--@pTipoOrdenacion varchar(4)=null,
		--@pNumeroPagina INT=1,
		--@pDimensionPagina  INT=100,
		--@pBusquedaGeneral varchar(100)=null

		--DECLARE @ListaExp NVARCHAR(MAX)='';

		SET LANGUAGE 'SPANISH'
		DECLARE @Consulta Nvarchar(max)=''
		DECLARE @ConsultaTotal Nvarchar(max)=''
		DECLARE @Consulta2 Nvarchar(max)=''
		DECLARE @Filtros Nvarchar(max)=''
		DECLARE @Offset NVARCHAR(MAX)='';
		DECLARE @Fetch NVARCHAR(MAX)='';
		DECLARE @Orden NVARCHAR(MAX)='';
		DECLARE @Parametros NVARCHAR(MAX)='';
		DECLARE @pTotalRegistros  INT;


		DECLARE @vIdAreaJefe int=0
		DECLARE @vIdEmpresaJefe int=0
		DECLARE @vTipoPendiente NVARCHAR(max)= ''
		DECLARE @vIdCargoJefe int=0

		IF COALESCE(@pBusquedaGeneral,'')<>'' SET @Filtros ='AND (X.NombreExpediente LIKE ''%'+@pBusquedaGeneral +'%'' OR X.NombreCompletoCreador LIKE ''%'+@pBusquedaGeneral +'%'' )'

		SELECT @vIdAreaJefe=IdArea,@vIdEmpresaJefe=IdEmpresa FROM RecursoHumano.visPersonaJefe where IdArea=@pIdArea

--		SELECT ED.IdExpediente FROM
--				Tramite.ExpedienteDocumento ED
--				INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1 AND ED.IdAreaEmisor= CONVERT(VARCHAR,@vIdAreaJefe) AND ED.IdCargoEmisor in(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34))
--				INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1 AND EDOD.IdCatalogoTipoMovimientoDestino=72
--				WHERE  EDOD.EstadoAuditoria=1
--				group by ED.IdExpediente
--set @t2 = getdate();
--select datediff(MILLISECOND,@t1,@t2) as elapsed_ms

		IF @pIdCatalogoSituacionMovimientoDestino=0--TODOS
		BEGIN
			PRINT 'ENTRO'
			IF COALESCE(@pBusquedaGeneral,'')<>'' SET @Filtros ='AND (X.NombreExpediente LIKE ''%'+@pBusquedaGeneral +'%'' OR X.NombreCompletoCreador LIKE ''%'+@pBusquedaGeneral +'%'' OR X.AsuntoExpediente LIKE ''%'+@pBusquedaGeneral +'%'')'
			SET @Orden=' ORDER BY Fecha desc '
			SET @ConsultaTotal = N'
				SELECT count(*)
				FROM
				(SELECT
				Tramite.funParaAnularJefatura(E.IdExpediente,'+CONVERT(VARCHAR,@pIdArea)+','+CONVERT(VARCHAR,@vIdCargoJefe)+') EsParaAnular,
				Tramite.funEsMiAnuladoJefatura(E.IdExpediente,'+CONVERT(VARCHAR,@pIdArea)+','+CONVERT(VARCHAR,@vIdCargoJefe)+') EsMiAnulado,
				E.ExpedienteAnulado,
				COALESCE(E.MotivoExpedienteAnulado,'''')MotivoExpedienteAnulado,
				COALESCE(E.NFechaAnulacionExpediente,'''')NFechaAnulacionExpediente,
				COALESCE(E.HoraAnulacionExpediente,'''')HoraAnulacionExpediente,
				E.IdExpediente,
				E.ExpedienteConfidencial,
				E.NTFechaExpediente,
				E.HoraExpediente,
				E.IdCatalogoTipoPrioridad,
				CTP.Descripcion CatalogoTipoPrioridad,
				COALESCE(CTT.Descripcion,'''') CatalogoTipoTramite,
				US.Logueo,
				COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(E.IdPersonaCreador),''sinfotoH.jpg'') RutaFotoPersona,
				UPPER(E.AsuntoExpediente) AsuntoExpediente,
				E.NumeroFoliosExpediente,
				COALESCE(E.ObservacionesExpediente,'''') ObservacionesExpediente,
				CONVERT(DATETIME,E.NTFechaExpediente +'' ''+ E.HoraExpediente) Fecha,
				CONCAT(SD.AbreviaturaSerieDocumentalExpediente +RIGHT(''000000''+CONVERT(VARCHAR,E.NumeroExpediente),6), ''-'', E.IdPeriodo) NombreExpediente	,
				CASE WHEN COALESCE(E.IdPersonaCreador,0)=0 THEN COALESCE(E.NombreCompletoCreador,'''') ELSE PE.NombreCompleto END NombreCompletoCreador
				FROM
				Tramite.Expediente E
				INNER JOIN @vTablaExpediente EE ON EE.IdExpediente=E.IdExpediente
				INNER JOIN Seguridad.Usuario US ON US.IdUsuario=E.IdUsuarioCreacionAuditoria
				INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
				INNER JOIN Tramite.Catalogo CTP ON CTP.IdCatalogo=E.IdCatalogoTipoPrioridad
				LEFT JOIN General.Persona PE ON PE.IdPersona=E.IdPersonaCreador
				LEFT JOIN Tramite.Catalogo CTT ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
				WHERE E.EstadoAuditoria=1 )X WHERE 1=1 '
				+@Filtros
				--SET @Parametros = N'@vpTotalRegistros int OUTPUT';
				--EXECUTE sp_executesql @ConsultaTotal,@Parametros, @vpTotalRegistros = @pTotalRegistros OUTPUT

				IF @pTotalRegistros<=(@pNumeroPagina-1)*@pDimensionPagina
					SET @Offset= ' OFFSET 0 ROWS'
				ELSE
					SET @Offset= ' OFFSET ' +CONVERT(VARCHAR(10),(@pNumeroPagina-1)*@pDimensionPagina) + ' ROWS'
				SET @Fetch= ' FETCH NEXT '+CONVERT(VARCHAR(10),@pDimensionPagina) +' ROWS ONLY'
				SET @Consulta='
					DECLARE @vTablaExpediente TABLE(IdExpediente int)
					INSERT INTO @vTablaExpediente
					SELECT ED.IdExpediente FROM
					Tramite.ExpedienteDocumento ED
					INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1 AND ED.IdAreaEmisor='+CONVERT(VARCHAR,@vIdAreaJefe)+' AND ED.IdCargoEmisor in(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34))
					INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1 AND EDOD.IdCatalogoTipoMovimientoDestino=72
					WHERE  EDOD.EstadoAuditoria=1
					group by ED.IdExpediente

					select *
					FROM
					(SELECT
					Tramite.funParaAnularJefatura(E.IdExpediente,'+CONVERT(VARCHAR,@pIdArea)+','+CONVERT(VARCHAR,@vIdCargoJefe)+') EsParaAnular,
					Tramite.funEsMiAnuladoJefatura(E.IdExpediente,'+CONVERT(VARCHAR,@pIdArea)+','+CONVERT(VARCHAR,@vIdCargoJefe)+') EsMiAnulado,
					E.ExpedienteAnulado,
					COALESCE(E.MotivoExpedienteAnulado,'''')MotivoExpedienteAnulado,
					COALESCE(E.NFechaAnulacionExpediente,'''')NFechaAnulacionExpediente,
					COALESCE(E.HoraAnulacionExpediente,'''')HoraAnulacionExpediente,
					Tramite.funObtenerDiasPendiente(E.IdExpediente,'+ CONVERT(VARCHAR,@vIdAreaJefe)+','+CONVERT(VARCHAR,@pIdCatalogoSituacionMovimientoDestino)+') DiasPendiente,
					E.IdExpediente,
					E.ExpedienteConfidencial,
					E.NTFechaExpediente,
					E.HoraExpediente,
					E.IdCatalogoTipoPrioridad,
					CTP.Descripcion CatalogoTipoPrioridad,
					COALESCE(CTT.Descripcion,'''') CatalogoTipoTramite,
					US.Logueo,
					COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(E.IdPersonaCreador),''sinfotoH.jpg'') RutaFotoPersona,
					UPPER(E.AsuntoExpediente) AsuntoExpediente,
					E.NumeroFoliosExpediente,
					COALESCE(E.ObservacionesExpediente,'''') ObservacionesExpediente,
					CONVERT(DATETIME,E.NTFechaExpediente +'' ''+ E.HoraExpediente) Fecha,
					CONCAT(SD.AbreviaturaSerieDocumentalExpediente +RIGHT(''000000''+CONVERT(VARCHAR,E.NumeroExpediente),6), ''-'', E.IdPeriodo) NombreExpediente,
					CASE WHEN COALESCE(E.IdPersonaCreador,0)=0 THEN COALESCE(E.NombreCompletoCreador,'''') ELSE PE.NombreCompleto END NombreCompletoCreador
					FROM
					Tramite.Expediente E
					INNER JOIN @vTablaExpediente EE ON EE.IdExpediente=E.IdExpediente
					INNER JOIN Seguridad.Usuario US ON US.IdUsuario=E.IdUsuarioCreacionAuditoria
					INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
					INNER JOIN Tramite.Catalogo CTP ON CTP.IdCatalogo=E.IdCatalogoTipoPrioridad
					LEFT JOIN General.Persona PE ON PE.IdPersona=E.IdPersonaCreador
					LEFT JOIN Tramite.Catalogo CTT ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
					WHERE E.EstadoAuditoria=1 )X WHERE 1=1 '
					+@Filtros
					+@Orden
					+@Offset
					+@Fetch
				set @Consulta2 = @Consulta + ' ' + @ConsultaTotal
				print @Consulta
				print @ConsultaTotal
				EXECUTE sp_executesql @Consulta2 --@Consulta
				--select @pTotalRegistros--,@pDimensionPagina
		END
		ELSE
		BEGIN
			SET @Orden=' ORDER BY DiasPendiente DESC, Fecha DESC '
			SET @Offset= ' OFFSET ' +CONVERT(VARCHAR(10),(@pNumeroPagina-1)*@pDimensionPagina) + ' ROWS'
			SET @Fetch= ' FETCH NEXT '+CONVERT(VARCHAR(10),@pDimensionPagina) +' ROWS ONLY'

			IF @pIdCatalogoSituacionMovimientoDestino=-1--MIS EXPEDIENTES COMO JEFATURA
			BEGIN
				SET @vTipoPendiente = ' AND EDOD.EstadoAuditoria=1 '+
				' AND (EDOD.IdAreaDestino='+CONVERT(varchar,@vIdAreaJefe)+' OR EDO.IdAreaOrigen='+CONVERT(varchar,@vIdAreaJefe)+')'+
				' AND (EDOD.IdEmpresaDestino='+ CONVERT(VARCHAR,@vIdEmpresaJefe)+ ' OR EDO.IdEmpresaOrigen='+ CONVERT(VARCHAR,@vIdEmpresaJefe)+ ') '+
				--' AND (EDOD.IdCargoDestino IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)) OR EDO.IdCargoOrigen IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34))))'
				' AND (EDOD.IdCargoDestino IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)) OR EDO.IdCargoOrigen IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)))  group by Ed.IdExpediente'
			END

			IF @pIdCatalogoSituacionMovimientoDestino =4-- POR RECIBIR
			BEGIN
				SET @vTipoPendiente =
				--' AND EDOD.IdCatalogoSituacionMovimientoDestino ='+CONVERT(VARCHAR,@pIdCatalogoSituacionMovimientoDestino) +
				'AND CASE WHEN EE.IdEnvio IS NULL THEN EDOD.IdCatalogoSituacionMovimientoDestino ELSE EE.IdCatalogoSituacionEnvio  END ='+CONVERT(VARCHAR,@pIdCatalogoSituacionMovimientoDestino) +
				' AND EDO.IdAreaOrigenEnvia='+ CONVERT(VARCHAR,@vIdAreaJefe)+
				--' AND EDOD.IdEmpresaDestino='+CONVERT(varchar,@vIdEmpresaJefe)+
				--' AND EDO.IdEmpresaOrigenEnvia =2 )'
				' AND EDO.IdEmpresaOrigenEnvia =2 group by Ed.IdExpediente'
			END

			--SELECT * FROM Tramite.ExpedienteDocumentoOrigen WHERE IdEmpresaOrigenEnvia=1 and IdAreaOrigenEnvia

			IF @pIdCatalogoSituacionMovimientoDestino =5-- RECIBIDO
			BEGIN
				SET @vTipoPendiente =
				' AND EDOD.IdCatalogoSituacionMovimientoDestino ='+CONVERT(VARCHAR,@pIdCatalogoSituacionMovimientoDestino) +
				' AND EDOD.IdAreaDestino='+ CONVERT(VARCHAR,@vIdAreaJefe)+
				' AND EDOD.IdEmpresaDestino='+CONVERT(varchar,@vIdEmpresaJefe)+
				--' AND EDOD.IdCargoDestino IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)))'
				' AND EDOD.IdCargoDestino IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)) group by Ed.IdExpediente'
			END

			IF @pIdCatalogoSituacionMovimientoDestino =3-- RESPONDIDO
			BEGIN
				SET @vTipoPendiente =
				' AND EDOD.IdCatalogoSituacionMovimientoDestino ='+CONVERT(VARCHAR,@pIdCatalogoSituacionMovimientoDestino) +
				' AND EDOD.IdAreaDestino='+ CONVERT(VARCHAR,@vIdAreaJefe)+
				' AND EDOD.IdEmpresaDestino='+CONVERT(varchar,@vIdEmpresaJefe)+
				--' AND EDOD.IdCargoDestino IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)))'
				' AND EDOD.IdCargoDestino IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)) group by Ed.IdExpediente'
			END

			IF @pIdCatalogoSituacionMovimientoDestino =116-- ENVIADOS
			BEGIN
				SET @vTipoPendiente =
				' AND EDO.IdCatalogoSituacionMovimientoOrigen ='+CONVERT(VARCHAR,@pIdCatalogoSituacionMovimientoDestino) +
				' AND EDO.IdAreaOrigen='+ CONVERT(VARCHAR,@vIdAreaJefe)+
				' AND EDO.IdEmpresaOrigen='+CONVERT(varchar,@vIdEmpresaJefe)+
				--' AND EDO.IdCargoOrigen IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)))'
				' AND EDO.IdCargoOrigen IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)) group by Ed.IdExpediente'
			END

			IF @pIdCatalogoSituacionMovimientoDestino=6-- DEVUELTO
			BEGIN
				SET @vTipoPendiente =
				' AND EDOD.IdCatalogoSituacionMovimientoDestino ='+CONVERT(VARCHAR,@pIdCatalogoSituacionMovimientoDestino) +
				' AND EDOD.IdAreaDestino='+ CONVERT(VARCHAR,@vIdAreaJefe)+
				' AND EDOD.IdEmpresaDestino='+CONVERT(varchar,@vIdEmpresaJefe)+
				--' AND EDOD.IdCargoDestino IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)))'
				' AND EDOD.IdCargoDestino IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)) group by Ed.IdExpediente'
			END
			IF @pIdCatalogoSituacionMovimientoDestino =111-- REENVIADO
			BEGIN
				SET @vTipoPendiente =
				' AND EDOD.IdCatalogoSituacionMovimientoDestino ='+CONVERT(VARCHAR,@pIdCatalogoSituacionMovimientoDestino) +
				' AND EDOD.IdAreaDestino='+ CONVERT(VARCHAR,@vIdAreaJefe)+
				' AND EDOD.IdEmpresaDestino='+CONVERT(varchar,@vIdEmpresaJefe)+
				--' AND EDOD.IdCargoDestino IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)))'
				' AND EDOD.IdCargoDestino IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)) group by Ed.IdExpediente'
			END

			IF @pIdCatalogoSituacionMovimientoDestino =112-- ARCHIVADOS
			BEGIN
				SET @vTipoPendiente =
				' AND EDOD.IdCatalogoSituacionMovimientoDestino ='+CONVERT(VARCHAR,@pIdCatalogoSituacionMovimientoDestino) +
				' AND EDOD.IdAreaDestino='+ CONVERT(VARCHAR,@vIdAreaJefe)+
				' AND EDOD.IdEmpresaDestino='+CONVERT(varchar,@vIdEmpresaJefe)+
				--' AND EDOD.IdCargoDestino IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34) CA))'
				' AND EDOD.IdCargoDestino IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34) CA) group by Ed.IdExpediente'
			END

			IF @pIdCatalogoSituacionMovimientoDestino =12-- ENVIADOS A COURRIER
			BEGIN
				SET @vTipoPendiente =
				--' AND EDOD.IdCatalogoSituacionMovimientoDestino ='+CONVERT(VARCHAR,@pIdCatalogoSituacionMovimientoDestino) +
				'AND CASE WHEN EE.IdEnvio IS NULL THEN EDOD.IdCatalogoSituacionMovimientoDestino ELSE EE.IdCatalogoSituacionEnvio  END ='+CONVERT(VARCHAR,@pIdCatalogoSituacionMovimientoDestino) +
				' AND EDO.IdAreaOrigenEnvia='+ CONVERT(VARCHAR,@vIdAreaJefe)+
				--' AND EDOD.IdEmpresaDestino='+CONVERT(varchar,@vIdEmpresaJefe)+
				--' AND EDO.IdEmpresaOrigenEnvia =2 )'
				' AND EDO.IdEmpresaOrigenEnvia =2 group by Ed.IdExpediente'
			END
			IF @pIdCatalogoSituacionMovimientoDestino =3-- ASIGNAR COURRIER
			BEGIN
				SET @vTipoPendiente =
				--' AND EDOD.IdCatalogoSituacionMovimientoDestino ='+CONVERT(VARCHAR,@pIdCatalogoSituacionMovimientoDestino) +
				'AND CASE WHEN EE.IdEnvio IS NULL THEN EDOD.IdCatalogoSituacionMovimientoDestino ELSE EE.IdCatalogoSituacionEnvio  END ='+CONVERT(VARCHAR,@pIdCatalogoSituacionMovimientoDestino) +
				' AND EDO.IdAreaOrigenEnvia='+ CONVERT(VARCHAR,@vIdAreaJefe)+
				--' AND EDOD.IdEmpresaDestino='+CONVERT(varchar,@vIdEmpresaJefe)+
				--' AND EDO.IdEmpresaOrigenEnvia =2 )'
				' AND EDO.IdEmpresaOrigenEnvia =2 group by Ed.IdExpediente'
			END
			IF @pIdCatalogoSituacionMovimientoDestino =11-- ASIGNAR COURRIER
			BEGIN
				SET @vTipoPendiente =
				--' AND EDOD.IdCatalogoSituacionMovimientoDestino ='+CONVERT(VARCHAR,@pIdCatalogoSituacionMovimientoDestino) +
				'AND CASE WHEN EE.IdEnvio IS NULL THEN EDOD.IdCatalogoSituacionMovimientoDestino ELSE EE.IdCatalogoSituacionEnvio  END ='+CONVERT(VARCHAR,@pIdCatalogoSituacionMovimientoDestino) +
				' AND EDO.IdAreaOrigenEnvia='+ CONVERT(VARCHAR,@vIdAreaJefe)+
				--' AND EDOD.IdEmpresaDestino='+CONVERT(varchar,@vIdEmpresaJefe)+
				--' AND EDO.IdEmpresaOrigenEnvia =2 )'
				' AND EDO.IdEmpresaOrigenEnvia =2 group by Ed.IdExpediente'
			END

			IF @pIdCatalogoSituacionMovimientoDestino =7-- ASIGNAR COURRIER
			BEGIN
				SET @vTipoPendiente =
				--' AND EDOD.IdCatalogoSituacionMovimientoDestino ='+CONVERT(VARCHAR,@pIdCatalogoSituacionMovimientoDestino) +
				'AND CASE WHEN EE.IdEnvio IS NULL THEN EDOD.IdCatalogoSituacionMovimientoDestino ELSE EE.IdCatalogoSituacionEnvio  END ='+CONVERT(VARCHAR,@pIdCatalogoSituacionMovimientoDestino) +
				' AND EDO.IdAreaOrigenEnvia='+ CONVERT(VARCHAR,@vIdAreaJefe)+
				--' AND EDOD.IdEmpresaDestino='+CONVERT(varchar,@vIdEmpresaJefe)+
				--' AND EDO.IdEmpresaOrigenEnvia =2 )'
				' AND EDO.IdEmpresaOrigenEnvia =2 group by Ed.IdExpediente'
			END


			--PRINT @Filtros
			SET @ConsultaTotal = N'SELECT count(*)
			FROM (SELECT
			Tramite.funParaAnularJefatura(E.IdExpediente,'+CONVERT(VARCHAR,@pIdArea)+','+CONVERT(VARCHAR,@vIdCargoJefe)+') EsParaAnular,
		    E.ExpedienteAnulado,
		    COALESCE(E.MotivoExpedienteAnulado,'''')MotivoExpedienteAnulado,
		    COALESCE(E.NFechaAnulacionExpediente,'''')NFechaAnulacionExpediente,
		    COALESCE(E.HoraAnulacionExpediente,'''')HoraAnulacionExpediente,
			Tramite.funObtenerDiasPendiente(E.IdExpediente,'+ CONVERT(VARCHAR,@vIdAreaJefe)+','+CONVERT(VARCHAR,@pIdCatalogoSituacionMovimientoDestino)+') DiasPendiente,
			E.IdExpediente,
			E.ExpedienteConfidencial,
			E.NTFechaExpediente,
			E.HoraExpediente,
			E.IdCatalogoTipoPrioridad,
			CTP.Descripcion CatalogoTipoPrioridad,
			COALESCE(CTT.Descripcion,'''') CatalogoTipoTramite,
			US.Logueo,
			COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(E.IdPersonaCreador),''sinfotoH.jpg'') RutaFotoPersona,
			UPPER(E.AsuntoExpediente) AsuntoExpediente,
			COALESCE(E.NumeroFoliosExpediente,0)NumeroFoliosExpediente,
			COALESCE(E.ObservacionesExpediente,'''') ObservacionesExpediente,
			CONVERT(DATETIME,E.NTFechaExpediente +'' ''+ E.HoraExpediente) Fecha,
			Tramite.funEsMiAnuladoJefatura(E.IdExpediente,'+CONVERT(VARCHAR,@pIdArea)+','+CONVERT(VARCHAR,@vIdCargoJefe)+') EsMiAnulado,
			CONCAT(SD.AbreviaturaSerieDocumentalExpediente +RIGHT(''0000''+CONVERT(VARCHAR,E.NumeroExpediente),5), ''-'', E.IdPeriodo) NombreExpediente,
			CASE WHEN COALESCE(E.IdPersonaCreador,0)=0 THEN COALESCE(E.NombreCompletoCreador,'''') ELSE PE.NombreCompleto END NombreCompletoCreador
			FROM
			Tramite.Expediente E
			INNER JOIN @vTablaExpediente EE ON EE.IdExpediente=E.IdExpediente
			INNER JOIN Seguridad.Usuario US ON US.IdUsuario=E.IdUsuarioCreacionAuditoria
			INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
			INNER JOIN Tramite.Catalogo CTP ON CTP.IdCatalogo=E.IdCatalogoTipoPrioridad
			LEFT JOIN General.Persona PE ON PE.IdPersona=E.IdPersonaCreador
			LEFT JOIN Tramite.Catalogo CTT ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
			WHERE E.EstadoAuditoria=1 ) X  WHERE X.EsMiAnulado=X.ExpedienteAnulado '
			+@Filtros
			--PRINT @ConsultaTotal
			--SET @Parametros = N'@vpTotalRegistros int OUTPUT';
			--EXECUTE sp_executesql @ConsultaTotal,@Parametros, @vpTotalRegistros = @pTotalRegistros OUTPUT

			SET @Consulta='
			DECLARE @vTablaExpediente TABLE(IdExpediente int)
			INSERT INTO @vTablaExpediente
			SELECT Ed.IdExpediente FROM
			Tramite.ExpedienteDocumento ED
			INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
			INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen  AND EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1 AND EDOD.IdCatalogoTipoMovimientoDestino=72
			LEFT JOIN Courrier.Envio EE ON EE.IdExpedienteDocumentoOrigenDestino =	EDOD.IdExpedienteDocumentoOrigenDestino AND EE.EstadoAuditoria=1 AND FgEntregado=0
			WHERE 1=1 '
			+@vTipoPendiente
			+'

			SELECT *
			FROM (SELECT
			Tramite.funParaAnularJefatura(E.IdExpediente,'+CONVERT(VARCHAR,@pIdArea)+','+CONVERT(VARCHAR,@vIdCargoJefe)+') EsParaAnular,
		    E.ExpedienteAnulado,
		    COALESCE(E.MotivoExpedienteAnulado,'''')MotivoExpedienteAnulado,
		    COALESCE(E.NFechaAnulacionExpediente,'''')NFechaAnulacionExpediente,
		    COALESCE(E.HoraAnulacionExpediente,'''')HoraAnulacionExpediente,
			Tramite.funObtenerDiasPendiente(E.IdExpediente,'+ CONVERT(VARCHAR,@vIdAreaJefe)+','+CONVERT(VARCHAR,@pIdCatalogoSituacionMovimientoDestino)+') DiasPendiente,
			E.IdExpediente,
			E.ExpedienteConfidencial,
			E.NTFechaExpediente,
			E.HoraExpediente,
			E.IdCatalogoTipoPrioridad,
			CTP.Descripcion CatalogoTipoPrioridad,
			COALESCE(CTT.Descripcion,'''') CatalogoTipoTramite,
			US.Logueo,
			COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(E.IdPersonaCreador),''sinfotoH.jpg'') RutaFotoPersona,
			UPPER(E.AsuntoExpediente) AsuntoExpediente,
			COALESCE(E.NumeroFoliosExpediente,0)NumeroFoliosExpediente,
			COALESCE(E.ObservacionesExpediente,'''') ObservacionesExpediente,
			CONVERT(DATETIME,E.NTFechaExpediente +'' ''+ E.HoraExpediente) Fecha,
			Tramite.funEsMiAnuladoJefatura(E.IdExpediente,'+CONVERT(VARCHAR,@pIdArea)+','+CONVERT(VARCHAR,@vIdCargoJefe)+') EsMiAnulado,
			CONCAT(SD.AbreviaturaSerieDocumentalExpediente +RIGHT(''0000''+CONVERT(VARCHAR,E.NumeroExpediente),5), ''-'', E.IdPeriodo) NombreExpediente,
			CASE WHEN COALESCE(E.IdPersonaCreador,0)=0 THEN COALESCE(E.NombreCompletoCreador,'''') ELSE PE.NombreCompleto END NombreCompletoCreador
			FROM
			Tramite.Expediente E
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
			set @Consulta2 = @Consulta + ' ' + @ConsultaTotal
			--print @Consulta
			print @ConsultaTotal
			print @Consulta
			EXECUTE sp_executesql @Consulta2 --@Consulta
			--select @pTotalRegistros--,@pDimensionPagina
		END
		--set @t2 = getdate();
		--select datediff(MILLISECOND,@t1,@t2) as elapsed_ms
		END TRY
	BEGIN CATCH
			DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
			SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarExpedientePendienteCourrierJefatura',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
			EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE,@pIdUsuarioAuditoria
	END CATCH
