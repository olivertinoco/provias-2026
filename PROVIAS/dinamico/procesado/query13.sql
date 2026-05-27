alter PROCEDURE Tramite.paListarDetalleBusquedaExpedienteGeneral_arq
    @pIdExpediente int,
    @pIdArea int,
    @pIdUsuarioAuditoria int,
    @pCampoOrdenado varchar(50),
    @pTipoOrdenacion varchar(4),
    @pNumeroPagina INT,
    @pDimensionPagina  INT,
    @pBusquedaGeneral varchar(100),
    @pCorrelativoVinculado int,
    @pIdPeriodo int
as
begin
begin try
set nocount on
set tran isolation level read uncommitted
set language spanish

declare @vAnno int = year(getdate()), @vItera int = 0, @vNuevoPeriodo int
declare @vTotalItera int = @vAnno - @pIdPeriodo + 1

create table #tmp001_expediente_listar(
    SiPariticipo int,
    EsVinculado bit,
    ExpedienteAnulado bit,
    IdExpediente int,
    IdExpedienteDocumento int,
    IdExpedienteDocumentoOrigenDestino int,
    IdExpedienteDocumentoOrigen int,
    IdCatalogoSituacionMovimientoDestino int,
    CatalogoSituacionMovimientoDestino varchar(400) collate database_default,
    IdCatalogoTipoMovimientoDestino int,
    CatalogoTipoMovimientoDestino varchar(400) collate database_default,
    IdCatalogoTipoDevolucion int,
    NumeroDiasAtencionSolicitado int,
    FechaDestinoRecepciona varchar(10) collate database_default,
    HoraDestinoRecepciona varchar(5) collate database_default,
    NombreEmpresaOrigen varchar(100) collate database_default,
    NombreAreaOrigen varchar(500) collate database_default,
    NombreCargoOrigen varchar(200) collate database_default,
    RutaFotoPersona varchar(max) collate database_default,
    RutaFotoPersonaDestino varchar(max) collate database_default,
    NombrePersonaOrigen varchar(400) collate database_default,
    RutaFotoPersonaDestino2 int,
    NumeroDiasAtencionAceptado int,
    Original bit,
    Copia bit,
    FechaDestino varchar(10) collate database_default,
    HoraDestino varchar(5) collate database_default,
    FechaDestinoEnvia varchar(10) collate database_default,
    HoraDestinoEnvia varchar(5) collate database_default,
    NombreEmpresaDestino varchar(800) collate database_default,
    NombreAreaDestino varchar(500) collate database_default,
    NombreCargoDestino varchar(200) collate database_default,
    NombrePersonaDestino varchar(400) collate database_default,
    NombreEmpresaDestinoRecepciona varchar(100) collate database_default,
    NombreAreaDestinoRecepciona varchar(500) collate database_default,
    NombreCargoDestinoRecepciona varchar(200) collate database_default,
    NombrePersonaDestinoRecepciona varchar(400) collate database_default,
    NombreEmpresaDestinoAtencion varchar(100) collate database_default,
    NombreAreaDestinoAtencion varchar(500) collate database_default,
    NombreCargoDestinoAtencion varchar(200) collate database_default,
    NombrePersonaDestinoAtencion varchar(400) collate database_default,
    ObservacionesDestinatario varchar(4000) collate database_default,
    Acciones varchar(max) collate database_default,
    IdExpedienteDocumento2 int,
    CatalogoTipoDocumento varchar(400) collate database_default,
    NumeroDocumento varchar(200) collate database_default,
    AsuntoDocumento varchar(8000) collate database_default,
    RutaArchivoDocumento varchar(150) collate database_default,
    FechaArchivado varchar(10) collate database_default,
    HoraArchivado varchar(5) collate database_default,
    DescripcionDevolucion varchar(4000) collate database_default,
    EsExtornable int,
    EsInicial int,
    DescripcionDevolucion2 int,
    MotivoArchivado varchar(8000) collate database_default,
    FechaEntregaDocumento varchar(10) collate database_default,
    HoraEntregaDocumento varchar(5) collate database_default,
    RutaArchivoCargo varchar(100) collate database_default,
    CorrelativoVinculado int,
    CatalogoTipoDocumento2 int,
    IdCatalogoTipoDocumento int,
    FgEsObligatorioFirmaDigital bit,
    FgEnEsperaFirmaDigital bit,
    FlagParaDespacho bit,
    IdExpedienteVirtual int,
    fechaOrden varchar(20) collate database_default
);

while (@vItera < @vTotalItera)begin
    select @vNuevoPeriodo = @pIdPeriodo + @vItera
    exec Tramite.paListarDetalleBusquedaExpedienteGeneralPorAnno_arq
    @pIdExpediente,
    @pIdArea,
    @pIdUsuarioAuditoria,
    @pCampoOrdenado,
    @pTipoOrdenacion,
    @pNumeroPagina,
    @pDimensionPagina,
    @pBusquedaGeneral,
    @pCorrelativoVinculado,
    @vNuevoPeriodo

    select @vItera+=1
end

SELECT
    SiPariticipo,
    EsVinculado,
    ExpedienteAnulado,
    IdExpediente,
    IdExpedienteDocumento,
    IdExpedienteDocumentoOrigenDestino,
    IdExpedienteDocumentoOrigen,
    IdCatalogoSituacionMovimientoDestino,
    CatalogoSituacionMovimientoDestino,
    IdCatalogoTipoMovimientoDestino,
    CatalogoTipoMovimientoDestino,
    isnull(IdCatalogoTipoDevolucion, 0) IdCatalogoTipoDevolucion,
    NumeroDiasAtencionSolicitado,
    isnull(FechaDestinoRecepciona, '') FechaDestinoRecepciona,
    isnull(HoraDestinoRecepciona,'') HoraDestinoRecepciona,
    isnull(NombreEmpresaOrigen,'') NombreEmpresaOrigen,
    isnull(NombreAreaOrigen,'') NombreAreaOrigen,
    isnull(NombreCargoOrigen,'') NombreCargoOrigen,
    isnull(RutaFotoPersona,'sinfotoH.jpg') RutaFotoPersona,
    isnull(RutaFotoPersonaDestino,'sinfotoH.jpg') RutaFotoPersonaDestino,
    NombrePersonaOrigen,
    isnull(RutaFotoPersonaDestino,'sinfotoH.jpg') RutaFotoPersonaDestino,
    NumeroDiasAtencionAceptado,
    Original,
    Copia,
    FechaDestino,
    HoraDestino,
    isnull(FechaDestinoEnvia,'') FechaDestinoEnvia,
    isnull(HoraDestinoEnvia,'') HoraDestinoEnvia,
    NombreEmpresaDestino,
    isnull(NombreAreaDestino,'') NombreAreaDestino,
    isnull(NombreCargoDestino,'') NombreCargoDestino,
    isnull(NombrePersonaDestino,'') NombrePersonaDestino,
    isnull(NombreEmpresaDestinoRecepciona, 'EXTERNO') NombreEmpresaDestinoRecepciona,
    isnull(NombreAreaDestinoRecepciona,'') NombreAreaDestinoRecepciona,
    isnull(NombreCargoDestinoRecepciona,'') NombreCargoDestinoRecepciona,
    isnull(NombrePersonaDestinoRecepciona,'') NombrePersonaDestinoRecepciona,
    isnull(NombreEmpresaDestinoAtencion, 'EXTERNO') NombreEmpresaDestinoAtencion,
    isnull(NombreAreaDestinoAtencion,'') NombreAreaDestinoAtencion,
    isnull(NombreCargoDestinoAtencion,'') NombreCargoDestinoAtencion,
    isnull(NombrePersonaDestinoAtencion,'') NombrePersonaDestinoAtencion,
    isnull(ObservacionesDestinatario,'') ObservacionesDestinatario,
    Acciones,
    IdExpedienteDocumento,
    CatalogoTipoDocumento,
    isnull(NumeroDocumento,'') NumeroDocumento,
    isnull(AsuntoDocumento,'') AsuntoDocumento,
    isnull(RutaArchivoDocumento,'') RutaArchivoDocumento,
    isnull(FechaArchivado,'') +' '+ isnull(HoraArchivado,'') FechaArchivado,
    isnull(DescripcionDevolucion,'') DescripcionDevolucion,
    EsExtornable,
    EsInicial,
    isnull(DescripcionDevolucion,'') DescripcionDevolucion,
    isnull(MotivoArchivado, '') MotivoArchivado,
    isnull(FechaEntregaDocumento, '') FechaEntregaDocumento,
    isnull(HoraEntregaDocumento, '') HoraEntregaDocumento,
    isnull(RutaArchivoCargo, '') RutaArchivoCargo,
    CorrelativoVinculado,
    CatalogoTipoDocumento,
    IdCatalogoTipoDocumento,
    FgEsObligatorioFirmaDigital,
    FgEnEsperaFirmaDigital,
    FlagParaDespacho,
    isnull(IdExpedienteVirtual, 0) IdExpedienteVirtual
FROM #tmp001_expediente_listar
order by convert(datetime, substring(fechaOrden,1,10) +' '+ stuff(fechaOrden,1,10,'')) desc
OFFSET (@pNumeroPagina-1)*@pDimensionPagina ROWS FETCH NEXT @pDimensionPagina ROWS ONLY

select count(1) from #tmp001_expediente_listar

END TRY
BEGIN CATCH
    DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX) ,@ERROR_MESSAGE VARCHAR(MAX)
    SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE(),
    @ERROR_PROCEDURE='Tramite.paListarDetalleBusquedaExpedienteGeneral_arq',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
    EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
END CATCH
END
GO



EXECUTE Tramite.paListarDetalleBusquedaExpedienteGeneral 727733,79,349,null,null,1,25,null,-1
-- EXECUTE Tramite.paListarDetalleBusquedaExpedienteGeneral_arq 727733,79,349,null,null,1,25,null,-1, 2025


-- exec Tramite.paListarDetalleBusquedaExpedienteGeneral_arq 727730,79,349,null,null,1,25,null,-1, 2025
-- EXECUTE Tramite.paListarDetalleBusquedaExpedienteGeneral_arq 727730,79,349,null,null,1,25,null,-1, 2025
-- EXECUTE Tramite.paListarDetalleBusquedaExpedienteGeneral_arq 797442,79,349,null,null,1,25,null,-1, 2025
-- EXECUTE Tramite.paListarDetalleBusquedaExpedienteGeneral_arq 506369,79,349,null,null,1,25,null,-1, 2025



-- SELECT
-- @pIdExpediente= 727730,
-- @pIdArea=79,
-- @pIdUsuarioAuditoria=349,
-- @pCampoOrdenado=null,
-- @pTipoOrdenacion=null,
-- @pNumeroPagina= 1,
-- @pDimensionPagina= 25,
-- @pBusquedaGeneral= null,
-- @pCorrelativoVinculado= -1,
-- @pIdPeriodo= 2025
--
