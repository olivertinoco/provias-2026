create or alter procedure Tramite.paListarExpedientePendienteCourrierJefatura_arq
	@pIdArea int,
	@pIdCatalogoSituacionMovimientoDestino INT,
	@pIdUsuarioAuditoria int,
	@pCampoOrdenado varchar(50),
	@pTipoOrdenacion varchar(4),
	@pNumeroPagina INT,
	@pDimensionPagina  INT,
	@pBusquedaGeneral varchar(100)
AS
BEGIN
BEGIN TRY
SET LANGUAGE SPANISH
set tran isolation level read uncommitted
set nocount on

create table #tmp001_TablaExpediente(IdExpediente int)
create table #tmp001_expediente_datos(
    EsParaAnular bit,
    EsMiAnulado bit,
    ExpedienteAnulado bit,
    MotivoExpedienteAnulado varchar(4000) collate database_default,
    NFechaAnulacionExpediente varchar(10) collate database_default,
    HoraAnulacionExpediente varchar(5) collate database_default,
    DiasPendiente int,
    IdExpediente int,
    ExpedienteConfidencial bit,
    NTFechaExpediente varchar(10) collate database_default,
    HoraExpediente varchar(5) collate database_default,
    IdCatalogoTipoPrioridad int,
    CatalogoTipoPrioridad varchar(400) collate database_default,
    CatalogoTipoTramite varchar(400) collate database_default,
    Logueo varchar(100) collate database_default,
    RutaFotoPersona varchar(max) collate database_default,
    AsuntoExpediente varchar(8000) collate database_default,
    NumeroFoliosExpediente int,
    ObservacionesExpediente varchar(4000) collate database_default,
    fecha datetime,
    AbreviaturaSerieDocumentalExpediente varchar(10) collate database_default,
    NumeroExpediente int,
    IdPeriodo int,
    NombreCompletoCreador varchar(400) collate database_default
)
create table #tmp002_expediente_datos(
    IdExpediente int,
    DiasPendiente int
)

    Declare @vPeriodo varchar(4)=null, @cta int = 0, @tot int = year(getdate()) - 2022

	DECLARE @Consulta Nvarchar(max)='',@Consulta2 Nvarchar(max)='',@Filtros Nvarchar(max)='',@Offset NVARCHAR(MAX)='',@Fetch NVARCHAR(MAX)='',@Orden NVARCHAR(MAX)='',
	@Parametros NVARCHAR(MAX)='',@pTotalRegistros  INT,@vIdAreaJefe int=0,@vIdEmpresaJefe int=0,@vTipoPendiente NVARCHAR(max)= '',@vIdCargoJefe int=0

	IF COALESCE(@pBusquedaGeneral,'')<>'' SET @Filtros ='AND (X.NombreExpediente LIKE ''%'+@pBusquedaGeneral +'%'' OR X.NombreCompletoCreador LIKE ''%'+@pBusquedaGeneral +'%'' )'
	SELECT @vIdAreaJefe=IdArea,@vIdEmpresaJefe=IdEmpresa FROM RecursoHumano.visPersonaJefe where IdArea=@pIdArea

	IF @pIdCatalogoSituacionMovimientoDestino=0
	BEGIN
		IF COALESCE(@pBusquedaGeneral,'')<>'' SET @Filtros =' AND (X.NombreExpediente LIKE ''%'+@pBusquedaGeneral +
		'%'' OR X.NombreCompletoCreador LIKE ''%'+@pBusquedaGeneral +'%'' OR X.AsuntoExpediente LIKE ''%'+@pBusquedaGeneral +'%'')'

		select @cta = 0, @vPeriodo = null
        while @cta < @tot begin
            select @vPeriodo = 2022 + @cta

            select @Consulta= null
      		select @Consulta= N'\
    		INSERT INTO #tmp001_TablaExpediente SELECT ED.IdExpediente FROM Tramite.ExpedienteDocumento_historico_' + @vPeriodo + N' ED
    		INNER JOIN Tramite.ExpedienteDocumentoOrigen_historico_' + @vPeriodo + N' EDO
    		ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1 AND ED.IdAreaEmisor=@vIdAreaJefe AND ED.IdCargoEmisor in(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34))
    		INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino_historico_' + @vPeriodo + N' EDOD
    		ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1 AND EDOD.IdCatalogoTipoMovimientoDestino=72 WHERE  EDOD.EstadoAuditoria=1 group by ED.IdExpediente'

    		EXECUTE sp_executesql @Consulta, N'@vIdAreaJefe int', @vIdAreaJefe

            select @cta+=1
        end

        select @cta = 0, @vPeriodo = null
        while @cta < @tot begin
            select @vPeriodo = 2022 + @cta

    		select @Consulta= null
    		select @Consulta= N'\
    		insert into #tmp001_expediente_datos select*from(select FPAJ.EsParaAnular,EMA.EsMiAnulado,
            E.ExpedienteAnulado,E.MotivoExpedienteAnulado,E.NFechaAnulacionExpediente,E.HoraAnulacionExpediente, null DiasPendiente,E.IdExpediente,E.ExpedienteConfidencial,E.NTFechaExpediente,
            E.HoraExpediente,E.IdCatalogoTipoPrioridad,CTP.Descripcion CatalogoTipoPrioridad,CTT.Descripcion CatalogoTipoTramite,US.Logueo,
            Seguridad.funObtenerRutaFotoPorIdPersona(E.IdPersonaCreador)RutaFotoPersona,E.AsuntoExpediente,E.NumeroFoliosExpediente,
            E.ObservacionesExpediente,null fecha, SD.AbreviaturaSerieDocumentalExpediente,E.NumeroExpediente,E.IdPeriodo,
            CASE WHEN isnull(E.IdPersonaCreador,0)=0 THEN E.NombreCompletoCreador ELSE PE.NombreCompleto END NombreCompletoCreador
    		FROM Tramite.Expediente_Historico_' + @vPeriodo + N' E INNER JOIN #tmp001_TablaExpediente EE ON EE.IdExpediente=E.IdExpediente
            INNER JOIN Seguridad.Usuario US ON US.IdUsuario=E.IdUsuarioCreacionAuditoria
    		INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
            INNER JOIN Tramite.Catalogo CTP ON CTP.IdCatalogo=E.IdCatalogoTipoPrioridad
    		LEFT JOIN General.Persona PE ON PE.IdPersona=E.IdPersonaCreador LEFT JOIN Tramite.Catalogo CTT ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
            OUTER APPLY(
                SELECT CASE WHEN EXISTS (
                    SELECT 1 FROM Tramite.Expediente_Historico_' + @vPeriodo + N' E5
                    WHERE E5.IdExpediente = E.IdExpediente AND E5.ExpedienteAnulado = 1 AND E5.IdAreaCreador = @pIdArea AND E5.EstadoAuditoria = 1
                    AND EXISTS (SELECT 1 FROM RecursoHumano.visPersonaJefe CA5 WHERE CA5.IdCargo = E5.IdCargoCreador)
                ) THEN 1 ELSE 0 END EsMiAnulado
            )EMA
            OUTER APPLY(
                SELECT CASE WHEN EXISTS (
                    SELECT 1 FROM Tramite.ExpedienteDocumento_Historico_' + @vPeriodo + N' ED2
                    INNER JOIN Tramite.ExpedienteDocumentoOrigen_Historico_' + @vPeriodo + N' EDO2 ON EDO2.IdExpedienteDocumento = ED2.IdExpedienteDocumento
                    INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino_Historico_' + @vPeriodo + N' EDOD2 ON EDOD2.IdExpedienteDocumentoOrigen = EDO2.IdExpedienteDocumentoOrigen
                    WHERE ED2.IdExpediente = E.IdExpediente AND ED2.EstadoAuditoria = 1 AND EDO2.EstadoAuditoria = 1 AND EDOD2.EsInicial = 1 AND EDO2.EsVinculado <> 1 AND EDO2.IdAreaOrigen = @pIdArea AND EDOD2.IdCatalogoSituacionMovimientoDestino <> 4 AND COALESCE(EDOD2.FechaDestinoRecepciona, '''') <> ''''
                    AND EXISTS (SELECT 1 FROM General.Cargo C2 WHERE C2.IdCargo = EDO2.IdCargoOrigen AND C2.IdCatalogoTipoCargo IN (32, 33, 34))
                ) THEN 0 WHEN EXISTS (
                    SELECT 1 FROM Tramite.ExpedienteDocumento_Historico_' + @vPeriodo + N' ED2
                    INNER JOIN Tramite.ExpedienteDocumentoOrigen_Historico_' + @vPeriodo + N' EDO2 ON EDO2.IdExpedienteDocumento = ED2.IdExpedienteDocumento
                    INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino_Historico_' + @vPeriodo + N' EDOD2 ON EDOD2.IdExpedienteDocumentoOrigen = EDO2.IdExpedienteDocumentoOrigen
                    WHERE ED2.IdExpediente = E.IdExpediente AND ED2.EstadoAuditoria = 1 AND EDO2.EstadoAuditoria = 1 AND EDOD2.EsInicial = 1 AND EDO2.EsVinculado <> 1 AND EDO2.IdAreaOrigen = @pIdArea AND COALESCE(EDOD2.FechaDestinoRecepciona, '''') = ''''
                    AND EXISTS (SELECT 1 FROM General.Cargo C2 WHERE C2.IdCargo = EDO2.IdCargoOrigen AND C2.IdCatalogoTipoCargo IN (32, 33, 34))
                ) THEN 1 ELSE 0 END EsParaAnular
            )FPAJ
    		WHERE E.EstadoAuditoria=1)X where 1=1 '
    		+@Filtros

    		EXEC sp_executesql @Consulta, N'@vIdAreaJefe int, @pIdArea int', @vIdAreaJefe, @pIdArea

            select @Consulta= null
            select @Consulta= N'\
            insert into #tmp002_expediente_datos select E.IdExpediente, isnull(case @pIdCatalogoSituacionMovimientoDestino when 4 then
            case when FODP.FechaDestinoRecepciona is null then CASE WHEN DATEDIFF(DAY,CONVERT(DATE, FODP.FechaOrigen),GETDATE())<=0 then 0 ELSE DATEDIFF(DAY,CONVERT(DATE, FODP.FechaDestino),GETDATE()) END else 0 end
            when 5 then CASE WHEN FODP.FechaDestinoRecepciona is not null THEN DATEDIFF(DAY,CONVERT(DATE, FODP.FechaDestinoRecepciona),GETDATE()) ELSE 0 end else 0 end, 0)
            from #tmp001_expediente_datos E
            OUTER APPLY (
                SELECT TOP 1 EDOD9.FechaDestinoRecepciona, EDOD9.FechaDestino, EDO9.FechaOrigen
                FROM Tramite.ExpedienteDocumento_Historico_' + @vPeriodo + N' ED9 INNER JOIN Tramite.ExpedienteDocumentoOrigen_Historico_' + @vPeriodo + N' EDO9 ON ED9.IdExpedienteDocumento=EDO9.IdExpedienteDocumento AND ED9.EstadoAuditoria=1
               	INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino_Historico_' + @vPeriodo + N' EDOD9 ON EDO9.IdExpedienteDocumentoOrigen=EDOD9.IdExpedienteDocumentoOrigen AND EDO9.EstadoAuditoria=1 AND EDOD9.EstadoAuditoria=1
               	WHERE  EDOD9.IdAreaDestino=@pIdArea AND EDOD9.IdCatalogoSituacionMovimientoDestino=@pIdCatalogoSituacionMovimientoDestino AND ED9.IdExpediente= E.IdExpediente AND EXISTS (SELECT 1 FROM General.Cargo C9 WHERE C9.IdCargo = EDOD9.IdCargoDestino AND C9.IdCatalogoTipoCargo in (32,33,34))
            )FODP'

            EXEC sp_executesql @Consulta, N'@pIdArea int, @pIdCatalogoSituacionMovimientoDestino int', @pIdArea, @pIdCatalogoSituacionMovimientoDestino

            select @cta+=1
        end

	END ELSE BEGIN
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


		select @cta = 0, @vPeriodo = null
        while @cta < @tot begin
            select @vPeriodo = 2022 + @cta

    		select @Consulta=null
    		select @Consulta= N'\
    		INSERT INTO #tmp001_TablaExpediente SELECT Ed.IdExpediente
    		FROM Tramite.ExpedienteDocumento_Historico_' + @vPeriodo + N' ED
    		INNER JOIN Tramite.ExpedienteDocumentoOrigen_Historico_' + @vPeriodo + N' EDO
    		ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
    		INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino_Historico_' + @vPeriodo + N' EDOD
    		ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1 AND EDOD.IdCatalogoTipoMovimientoDestino=72
    		LEFT JOIN Courrier.Envio EE ON EE.IdExpedienteDocumentoOrigenDestino =	EDOD.IdExpedienteDocumentoOrigenDestino AND EE.EstadoAuditoria=1 AND FgEntregado=0
    		WHERE 1=1 '
    		+@vTipoPendiente

    		EXECUTE sp_executesql @Consulta

            select @cta+=1
        end

        select @cta = 0, @vPeriodo = null
        while @cta < @tot begin
            select @vPeriodo = 2022 + @cta

    		select @Consulta= null
    		select @Consulta= N'\
    		insert into #tmp001_expediente_datos select*from(select FPAJ.EsParaAnular,EMA.EsMiAnulado,
            E.ExpedienteAnulado,E.MotivoExpedienteAnulado,E.NFechaAnulacionExpediente,E.HoraAnulacionExpediente,null DiasPendiente,
    		E.IdExpediente,E.ExpedienteConfidencial,E.NTFechaExpediente,E.HoraExpediente,E.IdCatalogoTipoPrioridad,CTP.Descripcion CatalogoTipoPrioridad,CTT.Descripcion CatalogoTipoTramite,US.Logueo,
    		Seguridad.funObtenerRutaFotoPorIdPersona(E.IdPersonaCreador)RutaFotoPersona,E.AsuntoExpediente,E.NumeroFoliosExpediente,E.ObservacionesExpediente,null fecha,
    		SD.AbreviaturaSerieDocumentalExpediente,E.NumeroExpediente,E.IdPeriodo,CASE WHEN isnull(E.IdPersonaCreador,0)=0 THEN E.NombreCompletoCreador ELSE PE.NombreCompleto END NombreCompletoCreador
    		FROM Tramite.Expediente_Historico_' + @vPeriodo + N' E
    		INNER JOIN #tmp001_TablaExpediente EE ON EE.IdExpediente=E.IdExpediente INNER JOIN Seguridad.Usuario US ON US.IdUsuario=E.IdUsuarioCreacionAuditoria
    		INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
            INNER JOIN Tramite.Catalogo CTP ON CTP.IdCatalogo=E.IdCatalogoTipoPrioridad
    		LEFT JOIN General.Persona PE ON PE.IdPersona=E.IdPersonaCreador
            LEFT JOIN Tramite.Catalogo CTT ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
            OUTER APPLY(
                SELECT CASE WHEN EXISTS (
                    SELECT 1 FROM Tramite.Expediente_Historico_' + @vPeriodo + N' E5
                    WHERE E5.IdExpediente = E.IdExpediente AND E5.ExpedienteAnulado = 1 AND E5.IdAreaCreador = @pIdArea AND E5.EstadoAuditoria = 1
                    AND EXISTS (SELECT 1 FROM RecursoHumano.visPersonaJefe CA5 WHERE CA5.IdCargo = E5.IdCargoCreador)
                ) THEN 1 ELSE 0 END EsMiAnulado
            )EMA
            OUTER APPLY(
                SELECT CASE WHEN EXISTS (
                    SELECT 1 FROM Tramite.ExpedienteDocumento_Historico_' + @vPeriodo + N' ED2
                    INNER JOIN Tramite.ExpedienteDocumentoOrigen_Historico_' + @vPeriodo + N' EDO2 ON EDO2.IdExpedienteDocumento = ED2.IdExpedienteDocumento
                    INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino_Historico_' + @vPeriodo + N' EDOD2 ON EDOD2.IdExpedienteDocumentoOrigen = EDO2.IdExpedienteDocumentoOrigen
                    WHERE ED2.IdExpediente = E.IdExpediente AND ED2.EstadoAuditoria = 1 AND EDO2.EstadoAuditoria = 1 AND EDOD2.EsInicial = 1 AND EDO2.EsVinculado <> 1 AND EDO2.IdAreaOrigen = @pIdArea AND EDOD2.IdCatalogoSituacionMovimientoDestino <> 4 AND COALESCE(EDOD2.FechaDestinoRecepciona, '''') <> ''''
                    AND EXISTS (SELECT 1 FROM General.Cargo C2 WHERE C2.IdCargo = EDO2.IdCargoOrigen AND C2.IdCatalogoTipoCargo IN (32, 33, 34))
                ) THEN 0 WHEN EXISTS (
                    SELECT 1 FROM Tramite.ExpedienteDocumento_Historico_' + @vPeriodo + N' ED2
                    INNER JOIN Tramite.ExpedienteDocumentoOrigen_Historico_' + @vPeriodo + N' EDO2 ON EDO2.IdExpedienteDocumento = ED2.IdExpedienteDocumento
                    INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino_Historico_' + @vPeriodo + N' EDOD2 ON EDOD2.IdExpedienteDocumentoOrigen = EDO2.IdExpedienteDocumentoOrigen
                    WHERE ED2.IdExpediente = E.IdExpediente AND ED2.EstadoAuditoria = 1 AND EDO2.EstadoAuditoria = 1 AND EDOD2.EsInicial = 1 AND EDO2.EsVinculado <> 1 AND EDO2.IdAreaOrigen = @pIdArea AND COALESCE(EDOD2.FechaDestinoRecepciona, '''') = ''''
                    AND EXISTS (SELECT 1 FROM General.Cargo C2 WHERE C2.IdCargo = EDO2.IdCargoOrigen AND C2.IdCatalogoTipoCargo IN (32, 33, 34))
                ) THEN 1 ELSE 0 END EsParaAnular
            )FPAJ
    		WHERE E.EstadoAuditoria=1)X where X.EsMiAnulado=X.ExpedienteAnulado '
    		+@Filtros

    		EXEC sp_executesql @Consulta, N'@pIdArea int', @pIdArea

            select @Consulta= null
            select @Consulta= N'\
            insert into #tmp002_expediente_datos select E.IdExpediente, isnull(case @pIdCatalogoSituacionMovimientoDestino when 4 then
            case when FODP.FechaDestinoRecepciona is null then CASE WHEN DATEDIFF(DAY,CONVERT(DATE, FODP.FechaOrigen),GETDATE())<=0 then 0 ELSE DATEDIFF(DAY,CONVERT(DATE, FODP.FechaDestino),GETDATE()) END else 0 end
            when 5 then CASE WHEN FODP.FechaDestinoRecepciona is not null THEN DATEDIFF(DAY,CONVERT(DATE, FODP.FechaDestinoRecepciona),GETDATE()) ELSE 0 end else 0 end, 0)
            from #tmp001_expediente_datos E
            OUTER APPLY (
                SELECT TOP 1 EDOD9.FechaDestinoRecepciona, EDOD9.FechaDestino, EDO9.FechaOrigen
                FROM Tramite.ExpedienteDocumento_Historico_' + @vPeriodo + N' ED9 INNER JOIN Tramite.ExpedienteDocumentoOrigen_Historico_' + @vPeriodo + N' EDO9 ON ED9.IdExpedienteDocumento=EDO9.IdExpedienteDocumento AND ED9.EstadoAuditoria=1
               	INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino_Historico_' + @vPeriodo + N' EDOD9 ON EDO9.IdExpedienteDocumentoOrigen=EDOD9.IdExpedienteDocumentoOrigen AND EDO9.EstadoAuditoria=1 AND EDOD9.EstadoAuditoria=1
               	WHERE  EDOD9.IdAreaDestino=@pIdArea AND EDOD9.IdCatalogoSituacionMovimientoDestino=@pIdCatalogoSituacionMovimientoDestino AND ED9.IdExpediente= E.IdExpediente AND EXISTS (SELECT 1 FROM General.Cargo C9 WHERE C9.IdCargo = EDOD9.IdCargoDestino AND C9.IdCatalogoTipoCargo in (32,33,34))
            )FODP'

            EXEC sp_executesql @Consulta, N'@pIdArea int, @pIdCatalogoSituacionMovimientoDestino int', @pIdArea, @pIdCatalogoSituacionMovimientoDestino

            select @cta+=1
        end

	END

   	select
   	    t.EsParaAnular,
   	    t.EsMiAnulado,
   	    t.ExpedienteAnulado,
   	    isnull(MotivoExpedienteAnulado,'')MotivoExpedienteAnulado,
   	    isnull(NFechaAnulacionExpediente,'')NFechaAnulacionExpediente,
   	    isnull(HoraAnulacionExpediente,'')HoraAnulacionExpediente,
   	    tt.DiasPendiente,
   	    t.IdExpediente,
   	    t.ExpedienteConfidencial,
   	    t.NTFechaExpediente,
   	    t.HoraExpediente,
   	    t.IdCatalogoTipoPrioridad,
   	    isnull(t.CatalogoTipoPrioridad,'')CatalogoTipoPrioridad,
   	    isnull(t.CatalogoTipoTramite,'')CatalogoTipoTramite,
   	    t.Logueo,
   	    isnull(t.RutaFotoPersona,'sinfotoH.jpg') RutaFotoPersona,
   	    upper(t.AsuntoExpediente) AsuntoExpediente,
   	    isnull(t.NumeroFoliosExpediente, 0)NumeroFoliosExpediente,
   	    isnull(t.ObservacionesExpediente,'')ObservacionesExpediente,
   	    convert(datetime, t.NTFechaExpediente +' '+ t.HoraExpediente)fecha,
   	    concat(t.AbreviaturaSerieDocumentalExpediente, right(1000000 + t.NumeroExpediente,6), '-', t.IdPeriodo)NombreExpediente,
   	    isnull(t.NombreCompletoCreador,'')NombreCompletoCreador
   	from #tmp001_expediente_datos t cross apply(select distinct IdExpediente, DiasPendiente from #tmp002_expediente_datos)tt
    where t.IdExpediente = tt.IdExpediente
   	order by case when @pIdCatalogoSituacionMovimientoDestino != 0 then tt.DiasPendiente end desc, t.fecha desc
   	offset (@pNumeroPagina-1)*@pDimensionPagina rows fetch next @pDimensionPagina rows only

	select count(1) from #tmp001_TablaExpediente

END TRY
BEGIN CATCH
	DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
	SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE(),
	@ERROR_PROCEDURE='Tramite.paListarExpedientePendienteCourrierJefatura_arq',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE,@pIdUsuarioAuditoria
END CATCH
END
GO


EXECUTE [BD_SGD_ARQ].[Tramite].[paListarExpedientePendienteCourrierJefatura] 79,4,349,null,null,1,10,null


EXECUTE [Tramite].[paListarExpedientePendienteCourrierJefatura_arq] 79,4,349,null,null,1,10,null


-- EXECUTE Tramite.paListarExpedientePendienteCourrierJefatura_arq
-- @pIdArea= 79,
-- @pIdCatalogoSituacionMovimientoDestino= 0,
-- @pIdUsuarioAuditoria= 349,
-- @pCampoOrdenado= null,
-- @pTipoOrdenacion= null,
-- @pNumeroPagina= 1,
-- @pDimensionPagina= 10,
-- @pBusquedaGeneral= null


-- select
--     @pIdArea= 79,
--     @pIdCatalogoSituacionMovimientoDestino= 0,
--     -- @pIdCatalogoSituacionMovimientoDestino= 4,
--     @pIdUsuarioAuditoria= 349,
--     @pCampoOrdenado= null,
--     @pTipoOrdenacion= null,
--     @pNumeroPagina= 1,
--     @pDimensionPagina= 10,
--     @pBusquedaGeneral= null
