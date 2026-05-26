declare
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

    SELECT
    @pIdExpediente= 727733,
    @pIdArea=79,
    @pIdUsuarioAuditoria=349,
    @pCampoOrdenado=null,
    @pTipoOrdenacion=null,
    @pNumeroPagina= 1,
    @pDimensionPagina= 25,
    @pBusquedaGeneral= null,
    @pCorrelativoVinculado= -1,
    @pIdPeriodo= 2026


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

    -- select
    --     null SiPariticipo,EDO.EsVinculado,E.ExpedienteAnulado,E.IdExpediente,ED.IdExpedienteDocumento,EDOD.IdExpedienteDocumentoOrigenDestino,
    -- EDOD.IdExpedienteDocumentoOrigen,EDOD.IdCatalogoSituacionMovimientoDestino,CSM.Descripcion,EDOD.IdCatalogoTipoMovimientoDestino,CTM.Descripcion,EDO.IdCatalogoTipodevolucion,EDOD.NumeroDiasAtencionSolicitado,EDOD.FechaDestinoRecepciona,
    -- EDOD.HoraDestinoRecepciona,EMO.NombreEmpresa,AO.NombreArea,CO.NombreCargo,Seguridad.funObtenerRutaFotoPorIdPersona(EDO.IdPersonaOrigen),
    -- Seguridad.funObtenerRutaFotoPorIdPersona(EDOD.IdPersonaDestino),CASE WHEN EDO.IdPersonaOrigen=0 THEN EDO.NombreCompletoOrigen ELSE PO.NombreCompleto END, null,EDOD.NumeroDiasAtencionAceptado,EDOD.Original,EDOD.Copia,EDOD.FechaDestino,EDOD.HoraDestino,EDOD.FechaDestinoEnvia,EDOD.HoraDestinoEnvia,COALESCE(EMD.NombreEmpresa,EDOD.DestinatarioDestino,''''),AD.NombreArea,CD.NombreCargo,PD.NombreCompleto,EMR.NombreEmpresa,AR.NombreArea, CR.NombreCargo,
    -- PR.NombreCompleto,EMA.NombreEmpresa,AA.NombreArea,CA.NombreCargo,PA.NombreCompleto,EDOD.ObservacionesDestinatario,Tramite.funMostrarAccionesPorDestino(EDOD.IdExpedienteDocumentoOrigenDestino), null,
    -- CTD.Descripcion,ED.NumeroDocumento,ED.AsuntoDocumento,ED.RutaArchivoDocumento,EDOD.FechaArchivado, EDOD.HoraArchivado, EDO.Descripciondevolucion,
    -- Tramite.funEsExtornable(EDOD.IdExpedienteDocumentoOrigen,EDOD.IdExpedienteDocumentoOrigenDestino),EDOD.EsInicial,null,EDOD.MotivoArchivado,EE.FechaEntregaDocumento,EE.HoraEntregaDocumento,EE.RutaArchivoCargo,ED.CorrelativoVinculado,null,CTD.IdCatalogo,
    -- ED.FgEsObligatorioFirmaDigital,ED.FgEnEsperaFirmaDigital,ED.FlagParaDespacho,ED.IdExpedienteVirtual,concat(EDO.FechaOrigen,EDO.HoraOrigen)
    -- FROM Tramite.Expediente E
    -- INNER JOIN Tramite.ExpedienteDocumento ED ON ED.IdExpediente=E.IdExpediente
    -- INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
    -- INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen  AND EDO.EstadoAuditoria=1
    -- INNER JOIN Tramite.Catalogo CTD ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento INNER JOIN Tramite.Catalogo CSM ON CSM.IdCatalogo=EDOD.IdCatalogoSituacionMovimientoDestino
    -- INNER JOIN Tramite.Catalogo CTM ON CTM.IdCatalogo=EDOD.IdCatalogoTipoMovimientoDestino
    -- LEFT JOIN General.Empresa EMO ON EMO.IdEmpresa=EDO.IdEmpresaOrigen LEFT JOIN General.Area AO ON AO.IdArea= EDO.IdAreaOrigen
    -- LEFT JOIN General.Cargo CO ON CO.IdCargo=EDO.IdCargoOrigen LEFT JOIN General.Empresa EMD ON EMD.IdEmpresa=EDOD.IdEmpresaDestino
    -- LEFT JOIN General.Area AD ON AD.IdArea= EDOD.IdAreaDestino LEFT JOIN General.Cargo CD ON CD.IdCargo=EDOD.IdCargoDestino
    -- LEFT JOIN General.Persona PD ON PD.IdPersona=EDOD.IdPersonaDestino LEFT JOIN General.Persona PO ON PO.IdPersona=EDO.IdPersonaOrigen
    -- LEFT JOIN General.Empresa EMR ON EMR.IdEmpresa=EDOD.IdEmpresaDestinoRecepciona LEFT JOIN General.Area AR ON AR.IdArea= EDOD.IdAreaDestinoRecepciona
    -- LEFT JOIN General.Cargo CR ON CR.IdCargo=EDOD.IdCargoDestinoRecepciona LEFT JOIN General.Persona PR ON PR.IdPersona=EDOD.IdPersonaDestinoRecepciona
    -- LEFT JOIN General.Empresa EMA ON EMA.IdEmpresa=EDOD.IdEmpresaDestinoAtencion LEFT JOIN General.Area AA ON AA.IdArea= EDOD.IdAreaDestinoAtencion
    -- LEFT JOIN General.Cargo CA ON CA.IdCargo=EDOD.IdCargoDestinoAtencion LEFT JOIN General.Persona PA ON PA.IdPersona=EDOD.IdPersonaDestinoAtencion
    -- LEFT JOIN Courrier.Envio EE ON EE.IdExpedienteDocumentoOrigenDestino =	EDOD.IdExpedienteDocumentoOrigenDestino AND EE.EstadoAuditoria=1 AND FgEntregado=0
    -- WHERE EDOD.EstadoAuditoria=1 AND E.IdExpediente=@pIdExpediente




select*from Tramite.Expediente where IdExpediente = 727733
select*from Tramite.Expediente_historico_2025 where IdExpediente = 727733


select*from Tramite.ExpedienteDocumento_historico_2025 where IdExpedienteDocumento in (
2282088,
2253074,
2253074,
2282088,
2253074,
2282088,
2253074,
2277252
)

select*from Tramite.ExpedienteDocumento_historico_2022 where IdExpedienteDocumento in (
2282088,
2253074,
2253074,
2282088,
2253074,
2282088,
2253074,
2277252
)
