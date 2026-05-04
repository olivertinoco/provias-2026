alter PROCEDURE [Tramite].[paListarExpedientePendienteJefaturaPorRecibirFosCad]
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

	DECLARE @vIdAreaJefe int=0, @vIdEmpresaJefe int=0, @nroReg int
	select @vIdAreaJefe = @pIdArea, @vIdEmpresaJefe = 2
	DECLARE @vTablaExpediente TABLE(
	    IdExpediente int,
		FechaMovimiento Datetime,
		EsParaAnular int,
		DiasPendiente int,
		NombrePersonaOrigen varchar(max),
		NumeroDocumento varchar(max),
		IdExpedienteDocumento int,
		CatalogoTipoOrigen varchar(400)
	);

	;WITH Cargo_CTE	AS (SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34))
	INSERT INTO @vTablaExpediente
	SELECT E.IdExpediente,
		MAX(CONVERT(DATETIME,edod.FechaDestino +' ' + edod.HoraDestino)) FechaMovimiento,
		0 EsParaAnular,
		MAX(CASE WHEN  COALESCE(EDOD.FechaDestinoRecepciona,'')='' THEN
    		    CASE WHEN DATEDIFF(DAY,CONVERT(DATE, EDO.FechaOrigen),GETDATE())<=0 then 0
                ELSE DATEDIFF(DAY,CONVERT(DATE, EDOD.FechaDestino),GETDATE()) END
            ELSE 0 END) DiasPendiente,
		MAX(CASE WHEN COALESCE(EDO.IdempresaOrigen,0)=0 THEN ed.NombreCompletoEmisor  ELSE A.NombreArea END) NombrePersonaOrigen,
		MAX('<button type="button" data-toggle="tooltip" title="'+COALESCE(EDOD.MotivoArchivado,'')+
		'" class="btn ui blue label" onclick="MostrarDocumentoPdfExp('''+ED.RutaArchivoDocumento+''','+
		CONVERT(VARCHAR,ed.IdExpedienteDocumento) +
		')"><i style="font-size:16px;" class="fa fa-file-text"></i></button><label style="font-size:10px;line-height:13px;padding-top:6px;">'+
		CASE WHEN ED.Correlativo=0 THEN  CONCAT( CTD.Descripcion,' ', COALESCE(ED.NumeroDocumento,'')) ELSE COALESCE(ED.NumeroDocumento,'') END+
        '</label>') NumeroDocumento,
		MAX(ed.IdExpedienteDocumento) IdExpedienteDocumento,
		MAX(CT.CatalogoTipoOrigen)
	FROM
	Tramite.Expediente E
	INNER JOIN Tramite.SerieDocumentalExpediente SD
	    ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
	INNER JOIN Tramite.ExpedienteDocumento ED
	    ON E.IdExpediente=ED.IdExpediente AND ED.EstadoAuditoria=1 AND COALESCE(E.ExpedienteAnulado,0)=0 AND E.EstadoAuditoria=1
	INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO
	    ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND EDO.EstadoAuditoria=1
	INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD
	    ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen and edod.EstadoAuditoria=1
	left join General.Area A
	    ON A.IdArea=EDO.IdAreaOrigen
	LEFT JOIN Tramite.Catalogo CTD
	    ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
    OUTER APPLY (
        SELECT TOP 1  CONCAT(ISNULL(C.Descripcion,''),' ',E.NumeroExpedienteExterno) AS CatalogoTipoOrigen
        FROM Tramite.ExpedienteDocumento ED
        INNER JOIN Tramite.Catalogo C
        ON C.IdCatalogo = ED.IdCatalogoTipoOrigen
        WHERE ED.IdExpediente = E.IdExpediente AND ED.EstadoAuditoria = 1
        ORDER BY ED.IdExpedienteDocumento ASC
    ) CT
	where COALESCE(E.ExpedienteAnulado,0)=0 AND E.EstadoAuditoria=1
    	AND EDOD.IdAreaDestino=@vIdAreaJefe
    	AND EDOD.IdCargoDestino IN (SELECT IdCargo FROM Cargo_CTE)
    	AND EDOD.IdEmpresaDestino=@vIdEmpresaJefe
    	AND EDOD.IdCatalogoSituacionMovimientoDestino=4
    	AND ED.FgEnEsperaFirmaDigital=0
	group by E.IdExpediente

	select @nroReg = count(1) from @vTablaExpediente

    ;with tmp001_serieDocumental as(
        select*from(values(1,'E-'),(2,'I-'))a(IdSerieDocumentalExpediente,AbreviaturaSerieDocumentalExpediente)
    )
    ,tmp001_NombreExpediente(cab1, cab2) as(
        select '<div style="margin: 2px;padding: 2px;" class="ui blue label">', '</div>'
    )
    ,tmp001_expedientEnlazado(id, cadena, cta, fecha) as(
        select
            t.IdExpedienteDocumento,
            coalesce(en1.ExEnlazadoPri, en2.ExEnlazadoSec, '') NombreExpedientesEnlazados,
            sum(case when en1.ExEnlazadoPri is null and en2.ExEnlazadoSec is null then 0 else 1 end)over() cta,
            t.FechaMovimiento
        from @vTablaExpediente t
        outer apply(
            select (SELECT cb.cab1, s.AbreviaturaSerieDocumentalExpediente,
                right(1000000+ex.NumeroExpediente,6),'-', ex.IdPeriodo, cb.cab2
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
            for xml path, type).value('.','varchar(1000)') ExEnlazadoPri
            from tmp001_NombreExpediente cb
        )en1
        outer apply(
            select (SELECT cb.cab1, s.AbreviaturaSerieDocumentalExpediente,
                right(1000000+ex.NumeroExpediente,6),'-', ex.IdPeriodo, cb.cab2
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
            for xml path, type).value('.','varchar(1000)') ExEnlazadoSec
            from tmp001_NombreExpediente cb
        )en2
    )
    ,tmp001_EsPrincipalEnlace as(
        select id EsPrincipalEnlace from(select id, row_number()over(order by fecha desc) item
        from tmp001_expedientEnlazado where cta > 1)t where item = 1
    )
    select
        t.id, t.cadena, case when tt.EsPrincipalEnlace is null then 0 else 1 end EsPrincipalEnlace
    into #tmp001_ExpedienteEnlazado
    from tmp001_expedientEnlazado t
    left join tmp001_EsPrincipalEnlace tt
        on t.id = tt.EsPrincipalEnlace


    ;with tmp001_serieDocumental as(
        select*from(values(1,'E-'),(2,'I-'))a(IdSerieDocumentalExpediente,AbreviaturaSerieDocumentalExpediente)
    )
    ,tmp001_sep(t,r,i)as(
        select*from(values('|','¬','¦'))t(SepCamp,SepReg,SepAux)
    )
	select concat(@nroReg, stuff((select r,
		convert(varchar,tE.EsParaAnular), t,
		convert(varchar,tE.DiasPendiente), t,
		tE.NombrePersonaOrigen, t,
		replace(tE.NumeroDocumento,'|',''), t,
		convert(varchar,tE.IdExpedienteDocumento), t,
		ee.cadena, t,
		ee.EsPrincipalEnlace, t,
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
		ISNULL(Seguridad.funObtenerRutaFotoPorIdPersona(E.IdPersonaCreador),'sinfotoH.jpg'), t,
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
	    ON tE.IdExpediente = E.IdExpediente and E.EstadoAuditoria = 1 and E.ExpedienteAnulado = 0 and E.IdSerieDocumentalExpediente in (1,2)
	INNER JOIN tmp001_serieDocumental SD
	    ON SD.IdSerieDocumentalExpediente = E.IdSerieDocumentalExpediente
	INNER JOIN Seguridad.Usuario US
	    ON US.IdUsuario=E.IdUsuarioCreacionAuditoria
	INNER JOIN Tramite.Catalogo CTP
	    ON CTP.IdCatalogo=E.IdCatalogoTipoPrioridad
	LEFT JOIN Tramite.ExpedienteSeguimiento ES
	    ON ES.IdExpediente= E.IdExpediente AND ES.EstadoAuditoria=1 AND ES.IdCargo=0 AND ES.IdPersona=0 AND ES.IdArea=@pIdArea
	LEFT JOIN General.Persona PE
	    ON PE.IdPersona=E.IdPersonaCreador
	LEFT JOIN Tramite.Catalogo CTT
	    ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
	LEFT JOIN #tmp001_ExpedienteEnlazado ee
	    ON ee.id = tE.IdExpedienteDocumento
	ORDER BY tE.FechaMovimiento DESC
	OFFSET (@pNumeroPagina-1)*@pDimensionPagina ROWS
	FETCH NEXT @pDimensionPagina ROWS ONLY
	for xml path, type).value('.','varchar(max)'),1,1,i))
	from tmp001_sep


END TRY
BEGIN CATCH
	DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
	SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarExpedientePendienteJefaturaPorRecibir',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE, @pIdUsuarioAuditoria
END CATCH
END
GO
