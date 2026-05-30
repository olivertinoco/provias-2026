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
	DECLARE @vTablaExpediente TABLE(
	    IdExpediente int,
		FechaMovimiento Datetime,
		EsParaAnular int,
		DiasPendiente int,
		NombrePersonaOrigen varchar(max),
		NumeroDocumento varchar(max),
		IdExpedienteDocumento int
	)

	;WITH Cargo_CTE	AS (SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34))
	insert into @vTablaExpediente
	SELECT E.IdExpediente,
		MAX(CONVERT(DATETIME,edod.FechaDestino +' ' + edod.HoraDestino)) FechaMovimiento, 0 EsParaAnular,
		MAX(CASE WHEN  COALESCE(EDOD.FechaDestinoRecepciona,'')='' THEN
		CASE WHEN DATEDIFF(DAY,CONVERT(DATE, EDO.FechaOrigen),GETDATE())<=0 then 0 ELSE DATEDIFF(DAY,CONVERT(DATE, EDOD.FechaDestino),GETDATE()) END ELSE 0 END) DiasPendiente,
		MAX(CASE WHEN COALESCE(EDO.IdempresaOrigen,0)=0 THEN ed.NombreCompletoEmisor  ELSE A.NombreArea END) NombrePersonaOrigen,
		MAX('<button type="button" data-toggle="tooltip" title="'+
		COALESCE(EDOD.MotivoArchivado,'')+
		'" class="btn ui blue label" onclick="MostrarDocumentoPdfExp('''+
		ED.RutaArchivoDocumento+''','+
		CONVERT(VARCHAR,ed.IdExpedienteDocumento) +
		')"><i style="font-size:16px;" class="fa fa-file-text"></i></button><label style="font-size:10px;line-height:13px;padding-top:6px;">'+
		CASE WHEN ED.Correlativo=0 THEN
		CONCAT( CTD.Descripcion,' ', COALESCE(ED.NumeroDocumento,'')) ELSE COALESCE(ED.NumeroDocumento,'') END+'</label>') NumeroDocumento,
		MAX(ed.IdExpedienteDocumento) IdExpedienteDocumento
	FROM Tramite.Expediente E
	INNER JOIN Tramite.ExpedienteDocumento ED
	    ON ED.IdExpediente = E.IdExpediente AND ED.EstadoAuditoria=1 AND ED.FgEnEsperaFirmaDigital=0
	INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO
	    ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND EDO.EstadoAuditoria=1
	INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD
	    ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen and EDOD.EstadoAuditoria=1
	LEFT JOIN General.Area A ON A.IdArea=EDO.IdAreaOrigen
	LEFT JOIN Tramite.Catalogo CTD ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
	where   E.ExpedienteAnulado=0
    	AND E.EstadoAuditoria=1
    	AND E.IdSerieDocumentalExpediente in (1,2)
    	AND EDOD.IdAreaDestino=@pIdArea
    	AND EDOD.IdCargoDestino IN(SELECT IdCargo FROM Cargo_CTE)
    	AND EDOD.IdEmpresaDestino=2
    	AND EDOD.IdCatalogoSituacionMovimientoDestino=4
    	AND (E.NumeroExpediente =  @pBusquedaGeneral OR @pBusquedaGeneral IS NULL OR @pBusquedaGeneral=0)
	group by E.IdExpediente

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
		tE.EsParaAnular, t,
		tE.DiasPendiente, t,
		tE.NombrePersonaOrigen, t,
		replace(tE.NumeroDocumento,'|',''), t,
		tE.IdExpedienteDocumento, t,
		isnull(x.NombreExpedientesEnlazados, ''), t,
        case when x.NombreExpedientesEnlazados is null then 0 else 1 end, t,
		g2.CatalogoTipoOrigen, t,
		E.IdExpediente, t,
		E.ExpedienteConfidencial, t,
		E.NTFechaExpediente, t,
		E.HoraExpediente, t,
		E.IdCatalogoTipoPrioridad, t,
		CTP.Descripcion, t,
		CTT.Descripcion, t,
		CTT.Detalle, t,
		US.Logueo, t,
		isnull(r.RutaFotoPersona, iif(r.sexo = 0, 'sinfotoH.jpg', 'sinfotoM.jpg')), t,
		UPPER(replace(E.AsuntoExpediente,'|',' ')), t,
		ISNULL(E.NumeroFoliosExpediente,0), t,
		replace(E.ObservacionesExpediente,'|',' '), t,
		CONCAT(E.NTFechaExpediente ,' ', E.HoraExpediente), t,
		CONCAT(SD.AbreviaturaSerieDocumentalExpediente, right(1000000 + E.NumeroExpediente,6), '-', E.IdPeriodo), t,
		CASE WHEN ISNULL(E.NombreCompletoCreador,'')<>'' THEN ISNULL(E.NombreCompletoCreador,'') ELSE PE.NombreCompleto END, t,
		E.NumeroExpediente, t,
		ISNULL(ES.IdExpedienteSeguimiento,0), t,
		FORMAT(tE.FechaMovimiento, 'dd/MM/yyyy HH:mm')
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
    outer apply(
        select top 1
        concat(g2.Descripcion, ' ', E.NumeroExpedienteExterno) CatalogoTipoOrigen
        from Tramite.ExpedienteDocumento tt2
        inner join Tramite.Catalogo g2
            on g2.IdCatalogo = tt2.IdCatalogoTipoOrigen
        where tt2.IdExpediente = E.IdExpediente
            and E.EstadoAuditoria = 1
        order by tt2.IdExpedienteDocumento
    )g2
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


exec tramite.paListarExpedientePendienteJefaturaPorRecibirFosCad_new 0,'22/05/2026','22/05/2026',1,'22/05/2026','22/05/2026',79,4,4,0,0,2026,0,0,0,'','','','',0,'','','',349,NULL,NULL,1,10,NULL,0
