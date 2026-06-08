alter PROCEDURE Tramite.paListarExpedientePendienteEspecialistaArchivados
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
set nocount on
set tran isolation level read uncommitted

	declare @vIdCargo int=0, @vIdArea int=0, @conBus int
	select @conBus = case when @pBusquedaGeneral is null or @pBusquedaGeneral = '' then 1 else 0 end

	DECLARE @vTablaExpediente TABLE(IdExpediente int, FechaMovimiento datetime)
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
		sexo bit,
		FechaMovimiento datetime
	);

	select @vIdCargo = IdCargo, @vIdArea = IdArea
    from recursoHumano.EmpleadoPerfil
    where   IdEmpresaSede   = 1
        and EstadoAuditoria = 1
        and Activo = 1
        and IdEmpleadoPerfil = @pIdEmpleadoPerfil

   	set language spanish
    insert into @vTablaExpediente
    select t1.IdExpediente,
    Tramite.funObtenerFechaMovimientoEnExpedienteEspecialista(t1.IdExpediente,@vIdArea,@vIdCargo,@pIdPersona,@pIdCatalogoSituacionMovimientoDestino)
	from Tramite.Expediente t1
	where   t1.EstadoAuditoria   = 1
        and t1.ExpedienteAnulado = 0
        and t1.IdSerieDocumentalExpediente in (1,2)
        and (@conBus = 1 or t1.NumeroExpediente = @pBusquedaGeneral)
        and exists(
            select 1
            from Tramite.ExpedienteDocumento t2
            inner join Tramite.ExpedienteDocumentoOrigen t3
                on  t3.IdExpedienteDocumento = t2.IdExpedienteDocumento
                and t3.EstadoAuditoria = 1
            inner join Tramite.ExpedienteDocumentoOrigenDestino t4
                on  t4.IdExpedienteDocumentoOrigen = t3.IdExpedienteDocumentoOrigen
                and t4.IdPersonaDestino  = @pIdPersona
                and year(t4.FechaCreacionAuditoria) = @pIdPeriodo
                and t4.IdAreaDestino     = @vIdArea
                and t4.IdCargoDestino    = @vIdCargo
                and t4.IdEmpresaDestino  = 2
                and t4.IdCatalogoSituacionMovimientoDestino = @pIdCatalogoSituacionMovimientoDestino
                and t4.EstadoAuditoria   = 1
                and (@pConFiltroFecha != 1 or convert(date, t4.FechaArchivado) between @pFechaInicio and @pFechaFin)
            where   t2.IdExpediente      = t1.IdExpediente
                and t2.EstadoAuditoria   = 1
                and t2.FgEnEsperaFirmaDigital = 0
        )



    select*into #tmp001_TablaExpediente from @vTablaExpediente
    ORDER BY FechaMovimiento DESC
	OFFSET (@pNumeroPagina-1)*@pDimensionPagina ROWS FETCH NEXT @pDimensionPagina ROWS ONLY


    ;with tmp001_serieDocumental as(
        select*from(values(1,'E-'),(2,'I-'))sd(IdSerieDocumentalExpediente, AbreviaturaSerieDocumentalExpediente)
    )
    insert into @MITABLA
    select
  		t1.IdExpediente,
  		t1.ExpedienteConfidencial,
  		t1.NTFechaExpediente,
  		t1.HoraExpediente,
  		t1.IdCatalogoTipoPrioridad,
  		c1.Descripcion CatalogoTipoPrioridad,
  		isnull(c2.Descripcion,'') CatalogoTipoTramite,
  		isnull(c2.Detalle,'') ColorCatalogoTipoTramite,
  		su.Logueo,
  		t1.IdPersonaCreador,
  		t1.AsuntoExpediente,
  		t1.NumeroFoliosExpediente,
  		isnull(t1.ObservacionesExpediente,'') ObservacionesExpediente,
  		concat(t1.NTFechaExpediente ,' ', t1.HoraExpediente) Fecha,
  		concat(sd.AbreviaturaSerieDocumentalExpediente, right(1000000+t1.NumeroExpediente,6),'-', t1.IdPeriodo) NombreExpediente,
  		isnull(t1.NombreCompletoCreador, p.NombreCompleto) NombreCompletoCreador,
  		t1.NumeroExpediente,
  		isnull(ss.IdExpedienteSeguimiento, 0) IdExpedienteSeguimiento,
        p.sexo,
        t.FechaMovimiento
   	from #tmp001_TablaExpediente t
    inner join Tramite.Expediente t1
        on  t1.IdExpediente      = t.IdExpediente
        and t1.EstadoAuditoria   = 1
        and t1.ExpedienteAnulado = 0
        and t1.IdSerieDocumentalExpediente in (1,2)
    inner join tmp001_serieDocumental sd
        on sd.IdSerieDocumentalExpediente = t1.IdSerieDocumentalExpediente
    inner join Seguridad.Usuario su
        on su.IdUsuario = t1.IdUsuarioCreacionAuditoria
    inner join Tramite.Catalogo c1
        on c1.IdCatalogo = t1.IdCatalogoTipoPrioridad
    inner join Tramite.Catalogo c2
        on c2.IdCatalogo = t1.IdCatalogoTipoTramite
    left join General.Persona p
        on p.IdPersona = t1.IdPersonaCreador
    left join Tramite.ExpedienteSeguimiento ss
        on  ss.IdExpediente = t1.IdExpediente
        and ss.IdArea    = @vIdArea
       	and ss.IdCargo   = @vIdCargo
       	and ss.IdPersona = @pIdPersona
        and ss.EstadoAuditoria = 1
       	and ss.IdEmpresa = 2


    ;with tmp001_cabComp(cab1, cab2, cab3) as(
        select
        '<button type="button" data-toggle="tooltip" title="xxx" class="btn ui blue label" onclick="MostrarDocumentoPdfExp(''',
        ')"><i style="font-size:16px;" class="fa fa-file-text"></i></button><label style="font-size:8px">', '</label>'
    )
    select
		isnull(nro.NumeroDocumento, '') NumeroDocumento,
        nro.IdExpedienteDocumento,
        cat.CatalogoTipoOrigen,
		t.IdExpediente,
		t.ExpedienteConfidencial,
		t.NTFechaExpediente,
		t.HoraExpediente,
		t.IdCatalogoTipoPrioridad,
		t.CatalogoTipoPrioridad,
		t.CatalogoTipoTramite,
		t.ColorCatalogoTipoTramite,
		t.Logueo,
		isnull(rf.RutaFotoPersona, iif(isnull(t.sexo, 0) = 0, 'sinfotoH.jpg', 'sinfotoM.jpg')) RutaFotoPersona,
		t.AsuntoExpediente,
		t.NumeroFoliosExpediente,
		t.ObservacionesExpediente,
		t.Fecha,
		t.NombreExpediente,
		t.NombreCompletoCreador,
		t.NumeroExpediente,
		t.IdExpedienteSeguimiento,
		t.FechaMovimiento
	into #tmp002_resultset
    from @MITABLA t
    outer apply(
        select top 1
            nullif(u.RutaArchivoFoto, '') RutaFotoPersona
        from Seguridad.Usuario u
        where   u.IdPersona = t.IdPersonaCreador
            and u.EstadoAuditoria = 1
            and u.Bloqueado = 0
        order by u.RutaArchivoFoto desc
    )rf
    cross apply tmp001_cabComp g
    outer apply(
        select top 1 t2.IdExpedienteDocumento,
            concat(replace(g.cab1, 'xxx', isnull(t4.MotivoArchivado, '')),
            t2.RutaArchivoDocumento, ''',', t2.IdExpedienteDocumento, g.cab2,
            case t2.Correlativo when 0 then concat(c.Descripcion, ' ', t2.NumeroDocumento)
            else t2.NumeroDocumento end, g.cab3) NumeroDocumento
        from Tramite.ExpedienteDocumento t2
        inner join Tramite.ExpedienteDocumentoOrigen t3
            on  t3.IdExpedienteDocumento = t2.IdExpedienteDocumento
            and t3.EstadoAuditoria = 1
        inner join Tramite.ExpedienteDocumentoOrigenDestino t4
            on  t4.IdExpedienteDocumentoOrigen = t3.IdExpedienteDocumentoOrigen
        left join Tramite.Catalogo c
            on c.IdCatalogo         = t2.IdCatalogoTipoDocumento
        where   t2.IdExpediente     = t.IdExpediente
            and t2.EstadoAuditoria  = 1
            and t4.IdEmpresaDestino = 2
            and t4.IdAreaDestino    = @vIdArea
           	and t4.IdCargoDestino   = @vIdCargo
           	and t4.IdPersonaDestino = @pIdPersona
            and t4.EstadoAuditoria  = 1
           	and t4.IdCatalogoSituacionMovimientoDestino = @pIdCatalogoSituacionMovimientoDestino
    )nro
    outer apply(
        select top 1 concat(c.Descripcion, ' ', e.NumeroExpedienteExterno) CatalogoTipoOrigen
        from Tramite.Expediente e
        inner join Tramite.ExpedienteDocumento tt
            on  tt.IdExpediente = e.IdExpediente
            and tt.EstadoAuditoria = 1
        inner join Tramite.Catalogo c
            on  c.IdCatalogo   = tt.IdCatalogoTipoOrigen
        where   e.IdExpediente = t.IdExpediente
            and e.EstadoAuditoria = 1
        order by tt.IdExpedienteDocumento
    )cat


    ;with tmp001_serieDocumental as(
        select*from(values(1,'E-'),(2,'I-'))sd(IdSerieDocumentalExpediente, AbreviaturaSerieDocumentalExpediente)
    )
    ,tmp001_NombreExpediente(cab1, cab2)as(
        select '<div style="margin: 2px;padding: 2px;" class="ui blue label">', '</div> '
    )
    select
        convert(bit, 0) EsParaAnular,
        0 DiasPendiente,
		'' NombrePersonaOrigen,
		t.NumeroDocumento,
        t.IdExpedienteDocumento,
        isnull(x.NombreExpedientesEnlazados, '') NombreExpedientesEnlazados,
        cast(case when x.NombreExpedientesEnlazados is null then 0 else 1 end as bit) EsPrincipalEnlace,
        t.CatalogoTipoOrigen,
		t.IdExpediente,
		cast(t.ExpedienteConfidencial as bit) ExpedienteConfidencial,
		t.NTFechaExpediente,
		t.HoraExpediente,
		t.IdCatalogoTipoPrioridad,
		t.CatalogoTipoPrioridad,
		t.CatalogoTipoTramite,
		t.ColorCatalogoTipoTramite,
		t.Logueo,
		t.RutaFotoPersona,
		t.AsuntoExpediente,
		t.NumeroFoliosExpediente,
		t.ObservacionesExpediente,
		t.Fecha,
		t.NombreExpediente,
		t.NombreCompletoCreador,
		t.NumeroExpediente,
		t.IdExpedienteSeguimiento,
		t.FechaMovimiento
    from #tmp002_resultset t
    outer apply (
        SELECT (select cb.cab1, AbreviaturaSerieDocumentalExpediente, right(1000000+NumeroExpediente,6),'-', IdPeriodo, cb.cab2
        FROM (
            SELECT ex.NumeroExpediente, ex.IdPeriodo, s.AbreviaturaSerieDocumentalExpediente, ee.IdExpedienteEnlazado orden
            FROM Tramite.ExpedienteEnlazado ee
            INNER JOIN Tramite.Expediente ex
                ON  ex.IdExpediente = ee.IdExpedienteSecundario
                AND ex.EstadoAuditoria   = 1
                AND ex.ExpedienteAnulado = 0
                AND ex.IdSerieDocumentalExpediente in (1,2)
            INNER JOIN tmp001_serieDocumental s
                ON s.IdSerieDocumentalExpediente = ex.IdSerieDocumentalExpediente
            WHERE ee.IdExpediente = t.IdExpediente
                AND ee.EstadoAuditoria = 1
            UNION ALL
            SELECT ex.NumeroExpediente, ex.IdPeriodo, s.AbreviaturaSerieDocumentalExpediente, ee.IdExpedienteEnlazado
            FROM Tramite.ExpedienteEnlazado ee
            INNER JOIN Tramite.Expediente ex
                ON  ex.IdExpediente = ee.IdExpediente
                AND ex.EstadoAuditoria   = 1
                AND ex.ExpedienteAnulado = 0
                AND ex.IdSerieDocumentalExpediente in (1,2)
            INNER JOIN tmp001_serieDocumental s
                ON s.IdSerieDocumentalExpediente = ex.IdSerieDocumentalExpediente
            WHERE ee.IdExpedienteSecundario = t.IdExpediente
                AND ee.EstadoAuditoria = 1
        )Q cross apply tmp001_NombreExpediente cb
        ORDER BY orden
        for xml path, type).value('.','varchar(max)') NombreExpedientesEnlazados
    )x
    order by t.FechaMovimiento desc

	select count(*) from @vTablaExpediente


END TRY
BEGIN CATCH
	DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
	SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE(),
	@ERROR_PROCEDURE='Tramite.paListarExpedientePendienteEspecialistaArchivados',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE, @pIdUsuarioAuditoria
 END CATCH
END
GO
