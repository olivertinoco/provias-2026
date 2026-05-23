alter PROCEDURE Tramite.paListarExpedientePendienteJefaturaPorRecibirFosCad_new
	@pConFiltroFecha bit,
	@pFechaInicio varchar(10),
	@pFechaFin varchar(10),
	@pConFiltroFechaMovimiento bit,
	@pFechaInicioMovimiento varchar(10),
	@pFechaFinMovimiento varchar(10),
	@pIdArea int,
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
	@pFlgBusqueda int
AS
BEGIN
BEGIN TRY
set tran isolation level read uncommitted
set nocount on

	DECLARE @nroReg varchar(6)
	SELECT IdCargo into #tmp001_cargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)
	DECLARE @vTablaExpediente TABLE(
	    IdExpediente int,
		FechaMovimiento Datetime,
		EsParaAnular int,
		DiasPendiente int,
		NombrePersonaOrigen varchar(max),
		NumeroDocumento varchar(max),
		IdExpedienteDocumento int,
		CatalogoTipoOrigen varchar(400)
	)

	select t1.IdExpediente,
	t4.FechaDestino, t4.HoraDestino, t4.FechaDestinoRecepciona, t3.FechaOrigen,
	t3.IdEmpresaOrigen, t2.NombreCompletoEmisor, a.NombreArea, t4.MotivoArchivado, t2.RutaArchivoDocumento,
    t2.IdExpedienteDocumento, t2.Correlativo, t2.NumeroDocumento, g.Descripcion, g2.CatalogoTipoOrigen
    into #tmp001_CabExpediente
	from #tmp001_cargo cc cross apply Tramite.Expediente t1
    inner join Tramite.ExpedienteDocumento t2
        on  t2.IdExpediente = t1.IdExpediente
        and t2.EstadoAuditoria = 1
        and t2.FgEnEsperaFirmaDigital = 0
    inner join Tramite.ExpedienteDocumentoOrigen t3
        on  t3.IdExpedienteDocumento = t2.IdExpedienteDocumento
        and t3.EstadoAuditoria = 1
    inner join Tramite.ExpedienteDocumentoOrigenDestino t4
        on  t4.IdExpedienteDocumentoOrigen = t3.IdExpedienteDocumentoOrigen
        and t4.IdCatalogoSituacionMovimientoDestino = 4
        and t4.IdAreaDestino   = @pIdArea
        and t4.IdCargoDestino  = cc.IdCargo
        and t4.EstadoAuditoria = 1
        and t4.IdEmpresaDestino= 2
    left join General.Area a
        on  a.IdArea = t3.IdAreaOrigen
    left join Tramite.Catalogo g
        on  g.IdCatalogo = t2.IdCatalogoTipoDocumento
    outer apply(
        select top 1
        concat(g2.Descripcion, ' ', t1.NumeroExpedienteExterno) CatalogoTipoOrigen
        from Tramite.ExpedienteDocumento tt2
        inner join Tramite.Catalogo g2
            on g2.IdCatalogo = tt2.IdCatalogoTipoOrigen
        where tt2.IdExpediente = t1.IdExpediente
            and t1.EstadoAuditoria = 1
        order by tt2.IdExpedienteDocumento
    )g2
    where   t1.EstadoAuditoria   = 1
        and t1.ExpedienteAnulado = 0
        and t1.IdSerieDocumentalExpediente in (1,2)


    select t.*into #tmp002_CabExpediente
    from(select IdExpediente,
        row_number()over(partition by IdExpediente
        order by convert(datetime, FechaDestino +' '+ HoraDestino) desc, IdExpediente desc)item,
        convert(datetime, FechaDestino +' '+ HoraDestino) FechaMovimiento,
    	case when isnull(FechaDestinoRecepciona,'') = ''
    	then iif(datediff(day, convert(date, FechaOrigen), getdate()) < 1, 0,
    	    datediff(day, convert(date, FechaDestino), getdate())) else 0 end DiasPendiente,
    	case when isnull(IdEmpresaOrigen,0) = 0 then NombreCompletoEmisor else NombreArea end NombrePersonaOrigen,
    	case Correlativo when 0 then concat(Descripcion, ' ', NumeroDocumento) else isnull(NumeroDocumento, '') end prev,
    	MotivoArchivado, RutaArchivoDocumento, IdExpedienteDocumento, CatalogoTipoOrigen
    from #tmp001_CabExpediente)t where t.item = 1


    ;with tmp001_cabComp(cab1, cab2, cab3) as(
        select
        '<button type="button" data-toggle="tooltip" title="xxx" class="btn ui blue label" onclick="MostrarDocumentoPdfExp(''',
        ')"><i style="font-size:16px;" class="fa fa-file-text"></i></button><label style="font-size:10px;line-height:13px;padding-top:6px;">',
        '</label>'
    )
    insert into @vTablaExpediente
    select t.IdExpediente, t.FechaMovimiento, 0, t.DiasPendiente, t.NombrePersonaOrigen,
        concat(replace(tt.cab1, 'xxx', isnull(t.MotivoArchivado, '')), t.RutaArchivoDocumento, ''',',
        t.IdExpedienteDocumento, tt.cab2, prev, tt.cab3), IdExpedienteDocumento, CatalogoTipoOrigen
    from #tmp002_CabExpediente t, tmp001_cabComp tt

	select @nroReg = count(1) from @vTablaExpediente

    ;with tmp001_serieDocumental as(
        select*from(values(1,'E-'),(2,'I-'))a(IdSerieDocumentalExpediente,AbreviaturaSerieDocumentalExpediente)
    )
    ,tmp001_NombreExpediente(cab1, cab2)as(
        select '<div style="margin: 2px;padding: 2px;" class="ui blue label">', '</div> '
    )
    ,tmp001_sep(t,r,i)as(
        select*from(values('|','¬','¦'))t(SepCamp,SepReg,SepAux)
    )
	select @nroReg + stuff((select r,
		convert(varchar,tE.EsParaAnular), t,
		convert(varchar,tE.DiasPendiente), t,
		tE.NombrePersonaOrigen, t,
		replace(tE.NumeroDocumento,'|',''), t,
		convert(varchar,tE.IdExpedienteDocumento), t,
		isnull(x.NombreExpedientesEnlazados, ''), t,
        case when x.NombreExpedientesEnlazados is null then 0 else 1 end, t,
		tE.CatalogoTipoOrigen, t,
		convert(varchar,E.IdExpediente), t,
		convert(varchar,E.ExpedienteConfidencial), t,
		E.NTFechaExpediente, t,
		E.HoraExpediente, t,
		convert(varchar,E.IdCatalogoTipoPrioridad), t,
		ISNULL(CTP.Descripcion,''), t,
		ISNULL(CTT.Descripcion,''), t,
		ISNULL(CTT.Detalle,''), t,
		US.Logueo, t,
		isnull(r.RutaFotoPersona, iif(r.sexo = 0, 'sinfotoH.jpg', 'sinfotoM.jpg')), t,
		UPPER(replace(E.AsuntoExpediente,'|',' ')), t,
		convert(varchar, ISNULL(E.NumeroFoliosExpediente,0)), t,
		ISNULL(replace(E.ObservacionesExpediente,'|',' '),''), t,
		CONCAT(E.NTFechaExpediente ,' ', E.HoraExpediente), t,
		CONCAT(SD.AbreviaturaSerieDocumentalExpediente, right(1000000 + E.NumeroExpediente,6), '-', E.IdPeriodo), t,
		CASE WHEN ISNULL(E.NombreCompletoCreador,'')<>'' THEN ISNULL(E.NombreCompletoCreador,'') ELSE PE.NombreCompleto END, t,
		convert(varchar,E.NumeroExpediente), t,
		convert(varchar, ISNULL(ES.IdExpedienteSeguimiento,0)), t,
		ISNULL(FORMAT(tE.FechaMovimiento, 'dd/MM/yyyy HH:mm'),'')
	FROM @vTablaExpediente tE
	INNER JOIN 	Tramite.Expediente E
	    ON tE.IdExpediente = E.IdExpediente
		and E.EstadoAuditoria = 1
		and E.ExpedienteAnulado = 0
		and E.IdSerieDocumentalExpediente in (1,2)
	INNER JOIN tmp001_serieDocumental SD
	    ON SD.IdSerieDocumentalExpediente = E.IdSerieDocumentalExpediente
	INNER JOIN Seguridad.Usuario US
	    ON US.IdUsuario=E.IdUsuarioCreacionAuditoria
	INNER JOIN Tramite.Catalogo CTP
	    ON CTP.IdCatalogo=E.IdCatalogoTipoPrioridad
	LEFT JOIN Tramite.ExpedienteSeguimiento ES
	    ON  ES.IdExpediente= E.IdExpediente
		AND ES.EstadoAuditoria=1
		AND ES.IdCargo=0
		AND ES.IdPersona=0
		AND ES.IdArea=@pIdArea
	LEFT JOIN General.Persona PE
	    ON PE.IdPersona=E.IdPersonaCreador
	LEFT JOIN Tramite.Catalogo CTT
	    ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
	outer apply (
        SELECT (select cb.cab1, NombreExpediente, cb.cab2
        FROM (
            SELECT t1.NombreExpediente, ee.IdExpedienteEnlazado orden
            FROM Tramite.ExpedienteEnlazado ee
            INNER JOIN Tramite.Expediente t1
                ON  t1.IdExpediente = ee.IdExpedienteSecundario
                AND t1.EstadoAuditoria = 1
                AND t1.ExpedienteAnulado = 0
            WHERE ee.IdExpediente = E.IdExpediente
                AND ee.EstadoAuditoria = 1
            UNION ALL
            SELECT t1.NombreExpediente, ee.IdExpedienteEnlazado
            FROM Tramite.ExpedienteEnlazado ee
            INNER JOIN Tramite.Expediente t1
                ON  t1.IdExpediente = ee.IdExpediente
                AND t1.EstadoAuditoria = 1
                AND t1.ExpedienteAnulado = 0
            WHERE ee.IdExpedienteSecundario = E.IdExpediente
                AND ee.EstadoAuditoria = 1
        ) Q cross apply tmp001_NombreExpediente cb
        ORDER BY orden desc
        for xml path, type).value('.','varchar(max)') NombreExpedientesEnlazados
    )x
	outer apply(
        select top 1
            isnull(p.sexo, 0) sexo, nullif(u.RutaArchivoFoto,'') RutaFotoPersona
        from General.Persona p
        inner join Seguridad.Usuario u
            on  u.IdPersona = p.IdPersona
            and u.EstadoAuditoria = 1
            and u.Bloqueado = 0
        where p.IdPersona   = E.IdPersonaCreador
        order by u.RutaArchivoFoto desc
    )r
	ORDER BY tE.FechaMovimiento DESC
	OFFSET (@pNumeroPagina-1)*@pDimensionPagina ROWS
	FETCH NEXT @pDimensionPagina ROWS ONLY
	for xml path, type).value('.','varchar(max)'),1,1,i)
	from tmp001_sep

END TRY
BEGIN CATCH
	DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX),@ERROR_MESSAGE VARCHAR(MAX)
	SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE(),
	@ERROR_PROCEDURE='Tramite.paListarExpedientePendienteJefaturaPorRecibirFosCad',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE, @pIdUsuarioAuditoria
END CATCH
END
GO


exec Tramite.paListarExpedientePendienteJefaturaPorRecibirFosCad_new
@pConFiltroFecha=0,
@pFechaInicio='22/05/2026',
@pFechaFin='22/05/2026',
@pConFiltroFechaMovimiento=1,
@pFechaInicioMovimiento='22/05/2026',
@pFechaFinMovimiento='22/05/2026',
@pIdArea=79,
@pIdCatalogoSituacionMovimientoDestino=4,
@pTipoSituacionMovimiento=4,
@pIdAreaOrigen=0,
@pIdAreaDestino=0,
@pIdPeriodo=2026,
@pIdCatalogoTipoPrioridad=0,
@pIdCatalogoTipoTramite=0,
@pIdCatalogoTipoDocumento=0,
@pNumeroExpediente='',
@pNumeroDocumento='',
@pPersonaDesde='',
@pPersonaPara='',
@pIdTipoIngreso=0,
@pFechaDocumento='',
@pEmisorExpediente='',
@pAsuntoExpediente='',
@pIdUsuarioAuditoria=349,
@pCampoOrdenado=NULL,
@pTipoOrdenacion=NULL,
@pNumeroPagina=1,
@pDimensionPagina=10,
@pBusquedaGeneral=NULL,
@pFlgBusqueda=0
