alter PROCEDURE [Tramite].[paListarDocumentoPendienteCourrierJefatura]
    @pIdExpediente int,
    @pIdArea int,
    @pIdUsuarioAuditoria int,
    @pCampoOrdenado varchar(50),
    @pTipoOrdenacion varchar(4),
    @pNumeroPagina INT,
    @pDimensionPagina  INT,
    @pBusquedaGeneral varchar(100),
    @pVerSoloMio INT,
    @pPeriodoCourier INT
AS
BEGIN
BEGIN TRY
SET TRAN ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON
SET LANGUAGE SPANISH

create table #tmp001_ExpedienteDatos(
    ExpedienteAnulado bit,
    IdExpediente int,
    CorrelativoVinculado int,
    IdExpedienteDocumento int,
    NumeroDocumento varchar(200) collate database_default,
    AsuntoDocumento varchar(8000) collate database_default,
    RutaArchivoDocumento varchar(150) collate database_default,
    IdCatalogoTipoDocumento int,
    EsVinculado bit,
    IdCatalogoTipodevolucion int,
    IdPersonaOrigen int,
    NombreCompletoOrigen varchar(100) collate database_default,
    FechaOrigen varchar(10) collate database_default,
    HoraOrigen varchar(5) collate database_default,
    Descripciondevolucion varchar(4000) collate database_default,
    IdAreaOrigen int,
    IdCargoOrigen int,
    IdExpedienteDocumentoOrigenDestino int,
    IdExpedienteDocumentoOrigen int,
    IdCatalogoSituacionMovimientoDestino int,
    IdCatalogoTipoMovimientoDestino int,
    NumeroDiasAtencionSolicitado int,
    FechaDestinoRecepciona varchar(10) collate database_default,
    HoraDestinoRecepciona varchar(5) collate database_default,
    IdPersonaDestino int,
    NumeroDiasAtencionAceptado int,
    Original bit,
    Copia bit,
    FechaDestino varchar(10) collate database_default,
    HoraDestino varchar(5) collate database_default,
    FechaDestinoEnvia varchar(10) collate database_default,
    HoraDestinoEnvia varchar(5) collate database_default,
    DestinatarioDestino varchar(800) collate database_default,
    ObservacionesDestinatario varchar(4000) collate database_default,
    IdCargoDestino int,
    IdAreaDestino int,
    IdEmpresaDestino int,
    FechaArchivado varchar(10) collate database_default,
    EsInicial int,
    MotivoArchivado varchar(8000) collate database_default,
    IdEmpresaOrigen int,
    IdEmpresaDestinoRecepciona int,
    IdAreaDestinoRecepciona int,
    IdCargoDestinoRecepciona int,
    IdPersonaDestinoRecepciona int,
    IdEmpresaDestinoAtencion int,
    IdAreaDestinoAtencion int,
    IdCargoDestinoAtencion int,
    IdPersonaDestinoAtencion int,
    CatalogoTipoDocumento varchar(400) collate database_default,
    CatalogoSituacionMovimientoDestino varchar(400) collate database_default,
    CatalogoTipoMovimientoDestino varchar(400) collate database_default,
    IdCargoEmisor int,
    IdAreaEmisor int,
    IdEmpresaEmisor int
)

    DECLARE @vIdCargoJefe int=0
    DECLARE @vIdAreaJefe int=0
    DECLARE @vIdEmpresaJefe int=0
    DECLARE @vPeriodoAno int = year(getdate()), @vPeriodoCourier varchar(50)
    if(@pPeriodoCourier = @vPeriodoAno) select @vPeriodoCourier = ''
    else select @vPeriodoCourier = concat('_historico_',@pPeriodoCourier)

    SELECT @vIdCargoJefe=IdCargo, @vIdAreaJefe=IdArea,@vIdEmpresaJefe=IdEmpresa FROM RecursoHumano.visPersonaJefe where IdArea=@pIdArea
    SELECT IdCargo into #tmp001_cargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)

    DECLARE @Consulta Nvarchar(max)=''
    DECLARE @Filtros Nvarchar(max)=''
    DECLARE @Parametros NVARCHAR(MAX)='';

    IF COALESCE(@pBusquedaGeneral,'')<>'' SET @Filtros =' AND (CSM.Descripcion LIKE ''%'+@pBusquedaGeneral +'%'')'

    select @Consulta=N'
    insert into #tmp001_ExpedienteDatos SELECT
    E.ExpedienteAnulado,E.IdExpediente,ED.CorrelativoVinculado,ED.IdExpedienteDocumento,ED.NumeroDocumento,ED.AsuntoDocumento,ED.RutaArchivoDocumento,ED.IdCatalogoTipoDocumento,
	EDO.EsVinculado,EDO.IdCatalogoTipodevolucion,EDO.IdPersonaOrigen,EDO.NombreCompletoOrigen,EDO.FechaOrigen,EDO.HoraOrigen,EDO.Descripciondevolucion,EDO.IdAreaOrigen,EDO.IdCargoOrigen,
	EDOD.IdExpedienteDocumentoOrigenDestino,EDOD.IdExpedienteDocumentoOrigen,EDOD.IdCatalogoSituacionMovimientoDestino,EDOD.IdCatalogoTipoMovimientoDestino,
    EDOD.NumeroDiasAtencionSolicitado,EDOD.FechaDestinoRecepciona,EDOD.HoraDestinoRecepciona,EDOD.IdPersonaDestino,EDOD.NumeroDiasAtencionAceptado,EDOD.Original,EDOD.Copia,EDOD.FechaDestino,EDOD.HoraDestino,EDOD.FechaDestinoEnvia,
    EDOD.HoraDestinoEnvia,EDOD.DestinatarioDestino,EDOD.ObservacionesDestinatario,EDOD.IdCargoDestino,EDOD.IdAreaDestino,EDOD.IdEmpresaDestino,EDOD.FechaArchivado,EDOD.EsInicial,EDOD.MotivoArchivado,EDO.IdEmpresaOrigen,EDOD.IdEmpresaDestinoRecepciona,
    EDOD.IdAreaDestinoRecepciona,EDOD.IdCargoDestinoRecepciona,EDOD.IdPersonaDestinoRecepciona,EDOD.IdEmpresaDestinoAtencion,EDOD.IdAreaDestinoAtencion,EDOD.IdCargoDestinoAtencion,EDOD.IdPersonaDestinoAtencion,
    CTD.Descripcion CatalogoTipoDocumento,CSM.Descripcion CatalogoSituacionMovimientoDestino,CTM.Descripcion CatalogoTipoMovimientoDestino,ED.IdCargoEmisor,ED.IdAreaEmisor,ED.IdEmpresaEmisor
    FROM Tramite.Expediente'+ @vPeriodoCourier +N' E
    INNER JOIN Tramite.ExpedienteDocumento'+ @vPeriodoCourier +N' ED ON ED.IdExpediente=E.IdExpediente
    INNER JOIN Tramite.ExpedienteDocumentoOrigen'+ @vPeriodoCourier +N' EDO ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
    INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino'+ @vPeriodoCourier +N' EDOD ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen  AND EDO.EstadoAuditoria=1
    INNER JOIN Tramite.Catalogo CTD ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
    INNER JOIN Tramite.Catalogo CSM ON CSM.IdCatalogo=EDOD.IdCatalogoSituacionMovimientoDestino
    INNER JOIN Tramite.Catalogo CTM ON CTM.IdCatalogo=EDOD.IdCatalogoTipoMovimientoDestino
	WHERE EDOD.EstadoAuditoria=1 AND EDOD.IdCatalogoTipoMovimientoDestino=72 AND E.IdExpediente=@pIdExpediente AND EDO.IdAreaOrigenEnvia=@pIdArea'
    +@Filtros

    EXECUTE sp_executesql @Consulta, N'@pIdExpediente int, @pIdArea int', @pIdExpediente = @pIdExpediente, @pIdArea = @pIdArea

    SELECT
    t.CorrelativoVinculado,
    t.EsVinculado,
    t.ExpedienteAnulado,
    t.IdExpediente,
    t.IdExpedienteDocumento,
    t.IdExpedienteDocumentoOrigenDestino,
    t.IdExpedienteDocumentoOrigen,
    CASE WHEN EE.IdEnvio IS NULL THEN t.IdCatalogoSituacionMovimientoDestino ELSE EE.IdCatalogoSituacionEnvio END IdCatalogoSituacionMovimientoDestino,
    COALESCE(CASE WHEN EE.IdEnvio IS NULL THEN t.CatalogoSituacionMovimientoDestino ELSE CSMEE.Descripcion END,'') CatalogoSituacionMovimientoDestino,
    t.IdCatalogoTipoMovimientoDestino,
    COALESCE(t.CatalogoTipoMovimientoDestino,'') CatalogoTipoMovimientoDestino,
    COALESCE(t.IdCatalogoTipodevolucion,0) IdCatalogoTipoDevolucion,
    t.NumeroDiasAtencionSolicitado,
    COALESCE(t.FechaDestinoRecepciona,'')FechaDestinoRecepciona,
    COALESCE(t.HoraDestinoRecepciona,'')HoraDestinoRecepciona,
    COALESCE(EMO.NombreEmpresa,'') NombreEmpresaOrigen,
    COALESCE(AO.NombreArea,'') NombreAreaOrigen,
    COALESCE(CO.NombreCargo,'') NombreCargoOrigen,
    COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(t.IdPersonaOrigen),'sinfotoH.jpg') RutaFotoPersona,
    COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(t.IdPersonaDestino),'sinfotoH.jpg') RutaFotoPersonaDestino,
    CASE WHEN t.IdPersonaOrigen=0 THEN t.NombreCompletoOrigen ELSE PO.NombreCompleto END  NombrePersonaOrigen,
    COALESCE(t.NumeroDiasAtencionAceptado,0)NumeroDiasAtencionAceptado,
    t.Original,
    t.Copia,
    t.FechaDestino,
    t.HoraDestino,
    t.FechaOrigen,
    t.HoraOrigen,
    COALESCE(t.FechaDestinoEnvia,'') FechaDestinoEnvia,
    COALESCE(t.HoraDestinoEnvia,'') HoraDestinoEnvia,
    COALESCE(EMD.NombreEmpresa,COALESCE(t.DestinatarioDestino,'')) NombreEmpresaDestino,
    COALESCE(AD.NombreArea,'') NombreAreaDestino,
    COALESCE(CD.NombreCargo,'') NombreCargoDestino,
    COALESCE(PD.NombreCompleto,'') NombrePersonaDestino,
    COALESCE(EMR.NombreEmpresa,'EXTERNO') NombreEmpresaDestinoRecepciona,
    COALESCE(AR.NombreArea,'') NombreAreaDestinoRecepciona,
    COALESCE(CR.NombreCargo,'') NombreCargoDestinoRecepciona,
    COALESCE(PR.NombreCompleto,'') NombrePersonaDestinoRecepciona,
    COALESCE(EMA.NombreEmpresa,'EXTERNO') NombreEmpresaDestinoAtencion,
    COALESCE(AA.NombreArea,'') NombreAreaDestinoAtencion,
    COALESCE(CA.NombreCargo,'') NombreCargoDestinoAtencion,
    COALESCE(PA.NombreCompleto,'') NombrePersonaDestinoAtencion,
    COALESCE(t.ObservacionesDestinatario,'') +' '+ CASE WHEN CU.NombreCompletoCourriers IS NULL THEN '' ELSE ' Courrier: ' END   +''+ COALESCE(CU.NombreCompletoCourriers,'') ObservacionesDestinatario,
    Tramite.funMostrarAccionesPorDestino(t.IdExpedienteDocumentoOrigenDestino) Acciones,
    CASE WHEN t.IdCargoDestino IN(select IdCargo from #tmp001_cargo) and t.IdAreaDestino=@vIdAreaJefe and t.IdEmpresaDestino=@vIdEmpresaJefe THEN 1 ELSE 0 END EsPropio,
    CASE WHEN t.IdCargoEmisor IN(select IdCargo from #tmp001_cargo) and t.IdAreaEmisor=@vIdAreaJefe and t.IdEmpresaEmisor=@vIdEmpresaJefe THEN 1 ELSE 0 END EsMiDocumento,
    CASE WHEN t.IdCargoOrigen IN(select IdCargo from #tmp001_cargo) and t.IdAreaOrigen=@vIdAreaJefe and t.IdEmpresaOrigen=@vIdEmpresaJefe THEN 1 ELSE 0 END EsOrigen,
    isnull(t.CatalogoTipoDocumento, '')CatalogoTipoDocumento,
    COALESCE(t.NumeroDocumento,'') NumeroDocumento,
    COALESCE(t.AsuntoDocumento,'') AsuntoDocumento,
    COALESCE(t.RutaArchivoDocumento,'') RutaArchivoDocumento,
    COALESCE(t.FechaArchivado,'')FechaArchivado,
    t.EsInicial,
    COALESCE(t.Descripciondevolucion,'') DescripcionDevolucion,
    COALESCE(t.MotivoArchivado,'')MotivoArchivado,
    COALESCE(EE.IdEnvio,0)IdEnvio,
    COALESCE(DM.IdDestino,0)IdDestino
    from #tmp001_ExpedienteDatos t
    LEFT JOIN General.Empresa EMO ON EMO.IdEmpresa=t.IdEmpresaOrigen
    LEFT JOIN General.Area AO ON AO.IdArea= t.IdAreaOrigen
    LEFT JOIN General.Cargo CO ON CO.IdCargo=t.IdCargoOrigen
    LEFT JOIN General.Empresa EMD ON EMD.IdEmpresa=t.IdEmpresaDestino
    LEFT JOIN General.Area AD ON AD.IdArea= t.IdAreaDestino
    LEFT JOIN General.Cargo CD ON CD.IdCargo=t.IdCargoDestino
    LEFT JOIN General.Persona PD ON PD.IdPersona=t.IdPersonaDestino
    LEFT JOIN General.Persona PO ON PO.IdPersona=t.IdPersonaOrigen
    LEFT JOIN General.Empresa EMR ON EMR.IdEmpresa=t.IdEmpresaDestinoRecepciona
    LEFT JOIN General.Area AR ON AR.IdArea= t.IdAreaDestinoRecepciona
    LEFT JOIN General.Cargo CR ON CR.IdCargo=t.IdCargoDestinoRecepciona
    LEFT JOIN General.Persona PR ON PR.IdPersona=t.IdPersonaDestinoRecepciona
    LEFT JOIN General.Empresa EMA ON EMA.IdEmpresa=t.IdEmpresaDestinoAtencion
    LEFT JOIN General.Area AA ON AA.IdArea= t.IdAreaDestinoAtencion
    LEFT JOIN General.Cargo CA ON CA.IdCargo=t.IdCargoDestinoAtencion
    LEFT JOIN General.Persona PA ON PA.IdPersona=t.IdPersonaDestinoAtencion
	LEFT JOIN Courrier.Envio EE ON EE.IdExpedienteDocumentoOrigenDestino=t.IdExpedienteDocumentoOrigenDestino AND EE.EstadoAuditoria=1 AND isnull(EE.FgEntregado,0)=0
	LEFT JOIN Courrier.Courriers CU ON CU.IdCourriers =EE.IdCourriers
	LEFT JOIN Courrier.Catalogo CSMEE ON CSMEE.IdCatalogo=EE.IdCatalogoSituacionEnvio
	LEFT JOIN Courrier.Destino DM ON DM.PersonaDestino= CASE WHEN CHARINDEX('',COALESCE(t.DestinatarioDestino,'0'))=0
	    THEN COALESCE(t.DestinatarioDestino,'')
		ELSE RTRIM(LTRIM(REPLACE(SUBSTRING(COALESCE(t.DestinatarioDestino,''),1,CHARINDEX('',COALESCE(t.DestinatarioDestino,'0'))),'','')))END AND DM.EstadoAuditoria=1
    ORDER BY CONVERT(DATETIME,t.FechaOrigen +' '+ t.HoraOrigen) DESC, t.IdExpedienteDocumentoOrigenDestino DESC
    OFFSET (@pNumeroPagina-1)*@pDimensionPagina ROWS
    FETCH NEXT @pDimensionPagina ROWS ONLY


    select count(1) from #tmp001_ExpedienteDatos


END TRY
BEGIN CATCH
    DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX) ,@ERROR_MESSAGE VARCHAR(MAX)
    SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarDocumentoPendienteCourrierJefatura',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
    EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
END CATCH
END
GO


-- execute [Tramite].[paListarDocumentoPendienteCourrierJefatura] 518024,79,349,null,null,1,25,null,0



execute [Tramite].[paListarDocumentoPendienteCourrierJefatura]
    @pIdExpediente= 518024,
    @pIdArea= 79,
    @pIdUsuarioAuditoria= 349,
    @pCampoOrdenado= null,
    @pTipoOrdenacion= null,
    @pNumeroPagina= 1,
    @pDimensionPagina= 25,
    @pBusquedaGeneral= null,
    @pVerSoloMio= 0,
    @pPeriodoCourier= 2025


-- CASE WHEN EDO.IdCargoOrigen IN(select IdCargo from #tmp001_cargo) and EDO.IdAreaOrigen=@vIdAreaJefe and EDO.IdEmpresaOrigen=@vIdEmpresaJefe THEN 1 ELSE 0 END,
-- CASE WHEN ED.IdCargoEmisor IN(select IdCargo from #tmp001_cargo) and ED.IdAreaEmisor=@vIdAreaJefe and ED.IdEmpresaEmisor=@vIdEmpresaJefe THEN 1 ELSE 0 END,
-- ,DM.IdDestino



-- LEFT JOIN Courrier.Destino DM ON DM.PersonaDestino=
-- CASE WHEN CHARINDEX('',COALESCE(EDOD.DestinatarioDestino,'0'))=0
-- THEN COALESCE(EDOD.DestinatarioDestino,'''')
-- ELSE  RTRIM(LTRIM(REPLACE(SUBSTRING(isnull(EDOD.DestinatarioDestino,''),1, CHARINDEX('',COALESCE(EDOD.DestinatarioDestino,'0'))  ),'',''))) END
-- AND DM.EstadoAuditoria=1



-- LEFT JOIN Courrier.Destino DM ON DM.PersonaDestino=CASE WHEN CHARINDEX('''',COALESCE(EDOD.DestinatarioDestino,''0''))=0 THEN COALESCE(EDOD.DestinatarioDestino,'''') ELSE  RTRIM(LTRIM(REPLACE( SUBSTRING(COALESCE(EDOD.DestinatarioDestino,''''),1, CHARINDEX('''',COALESCE(EDOD.DestinatarioDestino,''0''))  ),'''',''''))) END AND DM.EstadoAuditoria=1
