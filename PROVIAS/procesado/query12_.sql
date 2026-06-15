alter PROCEDURE Tramite.paListarExpedientePendienteJefaturaTodosFosCad
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
set nocount on
set tran isolation level read uncommitted

    declare @conBus int, @nroReg varchar(6)
    select @conBus =
    case when nullif(trim(@pBusquedaGeneral),'0') is null or trim(@pBusquedaGeneral) = '' or ISNUMERIC(@pBusquedaGeneral) = 0 then 1 else 0 end
    if @conBus = 1 begin
        select '0¦'
    	return
    end

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
	FechaMovimiento datetime,
	sexo bit);

   ;with tmp001_serieDocumental as(
      select*from(values(1,'E-'),(2,'I-'))sd(IdSerieDocumentalExpediente, AbreviaturaSerieDocumentalExpediente)
   )
	insert into @MITABLA select top 1000
        t1.IdExpediente,
        t1.ExpedienteConfidencial,
        t1.NTFechaExpediente,
        t1.HoraExpediente,
        t1.IdCatalogoTipoPrioridad,
        isnull(c1.Descripcion,'') CatalogoTipoPrioridad,
        isnull(c2.Descripcion,'') CatalogoTipoTramite,
        isnull(c2.Detalle,'') ColorCatalogoTipoTramite,
        isnull(su.Logueo, '') Logueo,
        t1.IdPersonaCreador,
        UPPER(t1.AsuntoExpediente) AsuntoExpediente,
        isnull(t1.NumeroFoliosExpediente,0)NumeroFoliosExpediente,
        isnull(t1.ObservacionesExpediente,'') ObservacionesExpediente,
        concat(t1.NTFechaExpediente ,' ', t1.HoraExpediente) Fecha,
        concat(sd.AbreviaturaSerieDocumentalExpediente, right(1000000+t1.NumeroExpediente,6),'-', t1.IdPeriodo) NombreExpediente,
        isnull(t1.NombreCompletoCreador, p.NombreCompleto) NombreCompletoCreador,
        t1.NumeroExpediente,
        isnull(ss.IdExpedienteSeguimiento, 0 )IdExpedienteSeguimiento,
        NULL FechaMovimiento,
        p.sexo
    from Tramite.Expediente t1
	inner join Seguridad.Usuario su
        on su.IdUsuario = t1.IdUsuarioCreacionAuditoria
    inner join Tramite.Catalogo c1
        on c1.IdCatalogo = t1.IdCatalogoTipoPrioridad
    inner join tmp001_serieDocumental sd
        on sd.IdSerieDocumentalExpediente = t1.IdSerieDocumentalExpediente
    left join Tramite.Catalogo c2
        on c2.IdCatalogo = t1.IdCatalogoTipoTramite
    left join General.Persona p
        on p.IdPersona = t1.IdPersonaCreador
    left join Tramite.ExpedienteSeguimiento ss
        on  ss.IdExpediente      = t1.IdExpediente
        and ss.IdArea            = @pIdArea
        and ss.IdCargo           = 0
        and ss.IdPersona         = 0
        and ss.EstadoAuditoria   = 1
        and ss.IdEmpresa         = 2
    where   t1.IdSerieDocumentalExpediente in (1,2)
        and t1.EstadoAuditoria   = 1
        and t1.ExpedienteAnulado = 0
        and t1.NumeroExpediente  = @pBusquedaGeneral
        and t1.IdPeriodo         = @pIdPeriodo
    order by t1.IdExpediente desc

    select @nroReg = count(1) from @MITABLA

    select*into #tmp001_expedienteDatos from @MITABLA
    ORDER BY IdExpediente DESC
    OFFSET (@pNumeroPagina-1)*@pDimensionPagina ROWS
    FETCH NEXT @pDimensionPagina ROWS ONLY

	;with tmp001_NombreExpediente(cab1, cab2)as(
        select '<div style="margin: 2px;padding: 2px;" class="ui blue label">', '</div>'
    )
	,tmp001_serieDocumental as(
        select*from(values(1,'E-'),(2,'I-'))sd(IdSerieDocumentalExpediente, AbreviaturaSerieDocumentalExpediente)
	)
	select t.*, x.NombreExpedientesEnlazados into #tmp002_expedienteDatos
	from #tmp001_expedienteDatos t
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

    select t.*,cat.CatalogoTipoOrigen into #tmp003_expedienteDatos
    from #tmp002_expedienteDatos t
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

    select t.*,rf.RutaFotoPersona into #tmp004_expedienteDatos
    from #tmp003_expedienteDatos t
    outer apply(
        select top 1
            case when u.RutaArchivoFoto is null or u.RutaArchivoFoto = ''
            then iif(t.sexo = 0, 'sinfotoH.jpg', 'sinfotoM.jpg') else u.RutaArchivoFoto end RutaFotoPersona
        from Seguridad.Usuario u
        where   u.IdPersona = t.IdPersonaCreador
            and u.EstadoAuditoria = 1
            and u.Bloqueado = 0
    )rf

	;with tmp001_sep(t,r,i)as(
	    select*from(values('|','¬','¦'))t(SepCamp,SepReg,SepLst)
	)
    select @nroReg + stuff((select r,
        0, t, 0, t, t, t, 0, t,
        t.NombreExpedientesEnlazados, t,
        case when t.NombreExpedientesEnlazados is null then 0 else 1 end, t,
        t.CatalogoTipoOrigen, t,
        t.IdExpediente, t,
        t.ExpedienteConfidencial, t,
        t.NTFechaExpediente, t,
        t.HoraExpediente, t,
        t.IdCatalogoTipoPrioridad, t,
        t.CatalogoTipoPrioridad, t,
        t.CatalogoTipoTramite, t,
        t.ColorCatalogoTipoTramite, t,
        t.Logueo, t,
        t.RutaFotoPersona, t,
        replace(t.AsuntoExpediente, '|', ' '), t,
        t.NumeroFoliosExpediente, t,
        replace(t.ObservacionesExpediente, '|', ' '), t,
        t.Fecha, t,
        t.NombreExpediente, t,
        t.NombreCompletoCreador, t,
        t.NumeroExpediente, t,
        t.IdExpedienteSeguimiento, t
    from #tmp004_expedienteDatos t
    ORDER BY t.IdExpediente DESC
    for xml path, type).value('.','varchar(max)'),1,1,i)
    from tmp001_sep


END TRY
BEGIN CATCH
    DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX) ,@ERROR_MESSAGE VARCHAR(MAX)
    SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE(),
    @ERROR_PROCEDURE='Tramite.paListarExpedientePendienteJefaturaTodosFosCad',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
    EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE, @pIdUsuarioAuditoria
END CATCH
END
GO


-- exec Tramite.paListarExpedientePendienteJefaturaTodosFosCad
-- @pConFiltroFecha=0,
-- @pFechaInicio='11/06/2026',
-- @pFechaFin='11/06/2026',
-- @pConFiltroFechaMovimiento=1,
-- @pFechaInicioMovimiento='11/06/2026',
-- @pFechaFinMovimiento='11/06/2026',
-- @pIdArea=79,
-- @pIdCatalogoSituacionMovimientoDestino=0,
-- @pTipoSituacionMovimiento=0,
-- @pIdAreaOrigen=0,
-- @pIdAreaDestino=0,
-- @pIdPeriodo=2026,
-- @pIdCatalogoTipoPrioridad=0,
-- @pIdCatalogoTipoTramite=0,
-- @pIdCatalogoTipoDocumento=0,
-- @pNumeroExpediente='',
-- @pNumeroDocumento='',
-- @pPersonaDesde='',
-- @pPersonaPara='',
-- @pIdTipoIngreso=0,
-- @pFechaDocumento='',
-- @pEmisorExpediente='',
-- @pAsuntoExpediente='',
-- @pIdUsuarioAuditoria=349,
-- @pCampoOrdenado=NULL,
-- @pTipoOrdenacion=NULL,
-- @pNumeroPagina=1,
-- @pDimensionPagina=10,
-- @pBusquedaGeneral='1',
-- @pFlgBusqueda=0

-- exec Tramite.paListarExpedientePendienteJefaturaTodosFosCad
-- @pConFiltroFecha=0,@pFechaInicio='01/04/2026',@pFechaFin='01/04/2026',
-- @pConFiltroFechaMovimiento=0,@pFechaInicioMovimiento='01/04/2026',
-- @pFechaFinMovimiento='01/04/2026',@pIdArea=112,@pIdCatalogoSituacionMovimientoDestino=0,
-- @pTipoSituacionMovimiento=0,@pIdAreaOrigen=0,@pIdAreaDestino=0,@pIdPeriodo=2026,
-- @pIdCatalogoTipoPrioridad=0,@pIdCatalogoTipoTramite=0,@pIdCatalogoTipoDocumento=0,
-- @pNumeroExpediente='',@pNumeroDocumento='',@pPersonaDesde='',@pPersonaPara='',
-- @pIdTipoIngreso=0,@pFechaDocumento='',@pEmisorExpediente='',@pAsuntoExpediente='',
-- @pIdUsuarioAuditoria=10367,@pCampoOrdenado=NULL,@pTipoOrdenacion=NULL,@pNumeroPagina=1,
-- @pDimensionPagina=10,@pBusquedaGeneral='0',@pFlgBusqueda=0





-- exec Tramite.paListarExpedientePendienteJefaturaTodosFosCad
-- @pConFiltroFecha=0,@pFechaInicio='01/06/2026',@pFechaFin='01/06/2026',
-- @pConFiltroFechaMovimiento=1,@pFechaInicioMovimiento='01/06/2026',
-- @pFechaFinMovimiento='01/06/2026',@pIdArea=78,@pIdCatalogoSituacionMovimientoDestino=0,
-- @pTipoSituacionMovimiento=0,@pIdAreaOrigen=0,@pIdAreaDestino=0,@pIdPeriodo=2026,
-- @pIdCatalogoTipoPrioridad=0,@pIdCatalogoTipoTramite=0,@pIdCatalogoTipoDocumento=0,
-- @pNumeroExpediente='',@pNumeroDocumento='',@pPersonaDesde='',@pPersonaPara='',
-- @pIdTipoIngreso=0,@pFechaDocumento='',@pEmisorExpediente='',@pAsuntoExpediente='',
-- @pIdUsuarioAuditoria=446,@pCampoOrdenado=NULL,@pTipoOrdenacion=NULL,@pNumeroPagina=1,
-- @pDimensionPagina=10,@pBusquedaGeneral='026493',@pFlgBusqueda=0


-- exec Tramite.paListarExpedientePendienteJefaturaTodosFosCad
-- @pConFiltroFecha=0,@pFechaInicio='01/04/2026',@pFechaFin='01/04/2026',
-- @pConFiltroFechaMovimiento=0,@pFechaInicioMovimiento='01/04/2026',
-- @pFechaFinMovimiento='01/04/2026',@pIdArea=163,@pIdCatalogoSituacionMovimientoDestino=0,
-- @pTipoSituacionMovimiento=0,@pIdAreaOrigen=0,@pIdAreaDestino=0,@pIdPeriodo=2026,
-- @pIdCatalogoTipoPrioridad=0,@pIdCatalogoTipoTramite=0,@pIdCatalogoTipoDocumento=0,
-- @pNumeroExpediente='',@pNumeroDocumento='',@pPersonaDesde='',@pPersonaPara='',
-- @pIdTipoIngreso=0,@pFechaDocumento='',@pEmisorExpediente='',@pAsuntoExpediente='',
-- @pIdUsuarioAuditoria=53859,@pCampoOrdenado=NULL,@pTipoOrdenacion=NULL,
-- @pNumeroPagina=1,@pDimensionPagina=10,@pBusquedaGeneral='023816',@pFlgBusqueda=0


-- exec Tramite.paListarExpedientePendienteJefaturaTodosFosCad_new
-- @pConFiltroFecha=0,@pFechaInicio='01/04/2026',@pFechaFin='01/04/2026',
-- @pConFiltroFechaMovimiento=0,@pFechaInicioMovimiento='01/04/2026',
-- @pFechaFinMovimiento='01/04/2026',@pIdArea=163,@pIdCatalogoSituacionMovimientoDestino=0,
-- @pTipoSituacionMovimiento=0,@pIdAreaOrigen=0,@pIdAreaDestino=0,@pIdPeriodo=2026,
-- @pIdCatalogoTipoPrioridad=0,@pIdCatalogoTipoTramite=0,@pIdCatalogoTipoDocumento=0,
-- @pNumeroExpediente='',@pNumeroDocumento='',@pPersonaDesde='',@pPersonaPara='',
-- @pIdTipoIngreso=0,@pFechaDocumento='',@pEmisorExpediente='',@pAsuntoExpediente='',
-- @pIdUsuarioAuditoria=53859,@pCampoOrdenado=NULL,@pTipoOrdenacion=NULL,
-- @pNumeroPagina=1,@pDimensionPagina=10,@pBusquedaGeneral='023816',@pFlgBusqueda=0
