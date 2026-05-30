alter procedure Tramite.paListarExpedientePendienteCourrierJefatura_arq
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


    select cast(IdPeriodo as int) IdPeriodo into #tmp001_periodos
    from general.Periodo where IdPeriodo > 2021
    Declare @vPeriodo int = year(getdate()),
    @vExpediente varchar(max), @vExpedienteDocumento varchar(max), @vExpedienteDocumentoOrigen varchar(max), @vExpedienteDocumentoOrigenDestino varchar(max)

    select @vExpediente = concat('select*from Tramite.Expediente',(
    select ' union all select*from Tramite.Expediente_Historico_', IdPeriodo
    from #tmp001_periodos where IdPeriodo != @vPeriodo order by IdPeriodo desc
    for xml path, type).value('.','varchar(max)'))

    select @vExpedienteDocumento = concat('select*from Tramite.ExpedienteDocumento',(
    select ' union all select*from Tramite.ExpedienteDocumento_Historico_', IdPeriodo
    from #tmp001_periodos where IdPeriodo != @vPeriodo order by IdPeriodo desc
    for xml path, type).value('.','varchar(max)'))

    select @vExpedienteDocumentoOrigen = concat('select*from Tramite.ExpedienteDocumentoOrigen',(
    select ' union all select*from Tramite.ExpedienteDocumentoOrigen_Historico_', IdPeriodo
    from #tmp001_periodos where IdPeriodo != @vPeriodo order by IdPeriodo desc
    for xml path, type).value('.','varchar(max)'))

    select @vExpedienteDocumentoOrigenDestino = concat('select*from Tramite.ExpedienteDocumentoOrigenDestino',(
    select ' union all select*from Tramite.ExpedienteDocumentoOrigenDestino_Historico_', IdPeriodo
    from #tmp001_periodos where IdPeriodo != @vPeriodo order by IdPeriodo desc
    for xml path, type).value('.','varchar(max)'))

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

	create table #tmp001_TablaExpediente(IdExpediente int)
	IF @pIdCatalogoSituacionMovimientoDestino=0
	BEGIN
		IF COALESCE(@pBusquedaGeneral,'')<>'' SET @Filtros =' AND (X.NombreExpediente LIKE ''%'+@pBusquedaGeneral +
		'%'' OR X.NombreCompletoCreador LIKE ''%'+@pBusquedaGeneral +'%'' OR X.AsuntoExpediente LIKE ''%'+@pBusquedaGeneral +'%'')'

  		SET @Consulta= N'
		INSERT INTO #tmp001_TablaExpediente SELECT ED.IdExpediente FROM (' + @vExpedienteDocumento + N')ED
		INNER JOIN (' + @vExpedienteDocumentoOrigen + N')EDO
		ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1 AND ED.IdAreaEmisor=@vIdAreaJefe AND ED.IdCargoEmisor in(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34))
		INNER JOIN (' + @vExpedienteDocumentoOrigenDestino + N')EDOD
		ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1 AND EDOD.IdCatalogoTipoMovimientoDestino=72 WHERE  EDOD.EstadoAuditoria=1 group by ED.IdExpediente'

		EXECUTE sp_executesql @Consulta, N'@vIdAreaJefe int', @vIdAreaJefe = @vIdAreaJefe

		select @Consulta= null
		select @Consulta= N'
		insert into #tmp001_expediente_datos select*from(select Tramite.funParaAnularJefatura(E.IdExpediente,@pIdArea,@vIdCargoJefe)EsParaAnular,
		Tramite.funEsMiAnuladoJefatura(E.IdExpediente,@pIdArea,@vIdCargoJefe)EsMiAnulado,E.ExpedienteAnulado,E.MotivoExpedienteAnulado,
		E.NFechaAnulacionExpediente,E.HoraAnulacionExpediente,Tramite.funObtenerDiasPendiente(E.IdExpediente,@vIdAreaJefe,@pIdCatalogoSituacionMovimientoDestino)DiasPendiente,
		E.IdExpediente,E.ExpedienteConfidencial,E.NTFechaExpediente,E.HoraExpediente,E.IdCatalogoTipoPrioridad,CTP.Descripcion CatalogoTipoPrioridad,CTT.Descripcion CatalogoTipoTramite,US.Logueo,
		Seguridad.funObtenerRutaFotoPorIdPersona(E.IdPersonaCreador)RutaFotoPersona,E.AsuntoExpediente,E.NumeroFoliosExpediente,E.ObservacionesExpediente,null fecha,
		SD.AbreviaturaSerieDocumentalExpediente,E.NumeroExpediente,E.IdPeriodo,CASE WHEN isnull(E.IdPersonaCreador,0)=0 THEN E.NombreCompletoCreador ELSE PE.NombreCompleto END NombreCompletoCreador
		FROM (' + @vExpediente + N')E
		INNER JOIN #tmp001_TablaExpediente EE ON EE.IdExpediente=E.IdExpediente INNER JOIN Seguridad.Usuario US ON US.IdUsuario=E.IdUsuarioCreacionAuditoria
		INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente INNER JOIN Tramite.Catalogo CTP ON CTP.IdCatalogo=E.IdCatalogoTipoPrioridad
		LEFT JOIN General.Persona PE ON PE.IdPersona=E.IdPersonaCreador LEFT JOIN Tramite.Catalogo CTT ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
		WHERE E.EstadoAuditoria=1)X where 1=1 '
		+@Filtros

		EXECUTE sp_executesql @Consulta,
		   N'@vIdAreaJefe int, @pIdArea int, @vIdCargoJefe int, @pIdCatalogoSituacionMovimientoDestino int',
		    @vIdAreaJefe = @vIdAreaJefe,
			@pIdArea = @pIdArea,
			@vIdCargoJefe = @vIdCargoJefe,
			@pIdCatalogoSituacionMovimientoDestino = @pIdCatalogoSituacionMovimientoDestino

		select
		    EsParaAnular,
		    EsMiAnulado,
		    ExpedienteAnulado,
		    isnull(MotivoExpedienteAnulado,'')MotivoExpedienteAnulado,
		    isnull(NFechaAnulacionExpediente,'')NFechaAnulacionExpediente,
		    isnull(HoraAnulacionExpediente,'')HoraAnulacionExpediente,
		    DiasPendiente,
		    IdExpediente,
		    ExpedienteConfidencial,
		    NTFechaExpediente,
		    HoraExpediente,
		    IdCatalogoTipoPrioridad,
		    isnull(CatalogoTipoPrioridad,'')CatalogoTipoPrioridad,
		    isnull(CatalogoTipoTramite,'')CatalogoTipoTramite,
		    Logueo,
		    isnull(RutaFotoPersona,'sinfotoH.jpg') RutaFotoPersona,
		    upper(AsuntoExpediente) AsuntoExpediente,
		    isnull(NumeroFoliosExpediente, 0)NumeroFoliosExpediente,
		    isnull(ObservacionesExpediente,'')ObservacionesExpediente,
		    convert(datetime, NTFechaExpediente +' '+ HoraExpediente)fecha,
		    concat(AbreviaturaSerieDocumentalExpediente, right(1000000 + NumeroExpediente,6), '-', IdPeriodo)NombreExpediente,
		    isnull(NombreCompletoCreador,'')NombreCompletoCreador
		from #tmp001_expediente_datos
		order by fecha desc
		offset (@pNumeroPagina-1)*@pDimensionPagina rows fetch next @pDimensionPagina rows only

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


		SET @Consulta= N'
		INSERT INTO #tmp001_TablaExpediente SELECT Ed.IdExpediente
		FROM (' + @vExpedienteDocumento + N')ED
		INNER JOIN (' + @vExpedienteDocumentoOrigen + N')EDO
		ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
		INNER JOIN (' + @vExpedienteDocumentoOrigenDestino + N')EDOD
		ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1 AND EDOD.IdCatalogoTipoMovimientoDestino=72
		LEFT JOIN Courrier.Envio EE ON EE.IdExpedienteDocumentoOrigenDestino =	EDOD.IdExpedienteDocumentoOrigenDestino AND EE.EstadoAuditoria=1 AND FgEntregado=0
		WHERE 1=1 '
		+@vTipoPendiente

		EXECUTE sp_executesql @Consulta

		select @Consulta= null
		select @Consulta= N'
		insert into #tmp001_expediente_datos select*from(select Tramite.funParaAnularJefatura(E.IdExpediente,@pIdArea,@vIdCargoJefe)EsParaAnular,
		Tramite.funEsMiAnuladoJefatura(E.IdExpediente,@pIdArea,@vIdCargoJefe)EsMiAnulado,E.ExpedienteAnulado,E.MotivoExpedienteAnulado,
		E.NFechaAnulacionExpediente,E.HoraAnulacionExpediente,Tramite.funObtenerDiasPendiente(E.IdExpediente,@vIdAreaJefe,@pIdCatalogoSituacionMovimientoDestino)DiasPendiente,
		E.IdExpediente,E.ExpedienteConfidencial,E.NTFechaExpediente,E.HoraExpediente,E.IdCatalogoTipoPrioridad,CTP.Descripcion CatalogoTipoPrioridad,CTT.Descripcion CatalogoTipoTramite,US.Logueo,
		Seguridad.funObtenerRutaFotoPorIdPersona(E.IdPersonaCreador)RutaFotoPersona,E.AsuntoExpediente,E.NumeroFoliosExpediente,E.ObservacionesExpediente,null fecha,
		SD.AbreviaturaSerieDocumentalExpediente,E.NumeroExpediente,E.IdPeriodo,CASE WHEN isnull(E.IdPersonaCreador,0)=0 THEN E.NombreCompletoCreador ELSE PE.NombreCompleto END NombreCompletoCreador
		FROM (' + @vExpediente + N')E
		INNER JOIN #tmp001_TablaExpediente EE ON EE.IdExpediente=E.IdExpediente INNER JOIN Seguridad.Usuario US ON US.IdUsuario=E.IdUsuarioCreacionAuditoria
		INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente INNER JOIN Tramite.Catalogo CTP ON CTP.IdCatalogo=E.IdCatalogoTipoPrioridad
		LEFT JOIN General.Persona PE ON PE.IdPersona=E.IdPersonaCreador LEFT JOIN Tramite.Catalogo CTT ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
		WHERE E.EstadoAuditoria=1)X where X.EsMiAnulado=X.ExpedienteAnulado '
		+@Filtros

		EXECUTE sp_executesql @Consulta,
		   N'@vIdAreaJefe int, @pIdArea int, @vIdCargoJefe int, @pIdCatalogoSituacionMovimientoDestino int',
		    @vIdAreaJefe = @vIdAreaJefe,
			@pIdArea = @pIdArea,
			@vIdCargoJefe = @vIdCargoJefe,
			@pIdCatalogoSituacionMovimientoDestino = @pIdCatalogoSituacionMovimientoDestino

		select
		    EsParaAnular,
		    EsMiAnulado,
		    ExpedienteAnulado,
		    isnull(MotivoExpedienteAnulado,'')MotivoExpedienteAnulado,
		    isnull(NFechaAnulacionExpediente,'')NFechaAnulacionExpediente,
		    isnull(HoraAnulacionExpediente,'')HoraAnulacionExpediente,
		    DiasPendiente,
		    IdExpediente,
		    ExpedienteConfidencial,
		    NTFechaExpediente,
		    HoraExpediente,
		    IdCatalogoTipoPrioridad,
		    isnull(CatalogoTipoPrioridad,'')CatalogoTipoPrioridad,
		    isnull(CatalogoTipoTramite,'')CatalogoTipoTramite,
		    Logueo,
		    isnull(RutaFotoPersona,'sinfotoH.jpg') RutaFotoPersona,
		    upper(AsuntoExpediente) AsuntoExpediente,
		    isnull(NumeroFoliosExpediente, 0)NumeroFoliosExpediente,
		    isnull(ObservacionesExpediente,'')ObservacionesExpediente,
		    convert(datetime, NTFechaExpediente +' '+ HoraExpediente)fecha,
		    concat(AbreviaturaSerieDocumentalExpediente, right(1000000 + NumeroExpediente,6), '-', IdPeriodo)NombreExpediente,
		    isnull(NombreCompletoCreador,'')NombreCompletoCreador
		from #tmp001_expediente_datos
		order by DiasPendiente desc, fecha desc
		offset (@pNumeroPagina-1)*@pDimensionPagina rows fetch next @pDimensionPagina rows only
	END

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


-- EXECUTE [Tramite].[paListarExpedientePendienteCourrierJefatura] 79,0,349,null,null,1,10,null
-- EXECUTE [Tramite].[paListarExpedientePendienteCourrierJefatura_arq] 79,0,349,null,null,1,20,null

-- EXECUTE Tramite.paListarExpedientePendienteCourrierJefatura_arq
-- @pIdArea= 79,
-- @pIdCatalogoSituacionMovimientoDestino= 0,
-- @pIdUsuarioAuditoria= 349,
-- @pCampoOrdenado= null,
-- @pTipoOrdenacion= null,
-- @pNumeroPagina= 1,
-- @pDimensionPagina= 10,
-- @pBusquedaGeneral= null
