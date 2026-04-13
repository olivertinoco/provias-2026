-- select*from dbo.mastertable('Tramite.Expediente')
-- select*from dbo.mastertable('Tramite.ExpedienteDocumento')

-- ====================================================================================
-- MATRIZ DE TABLAS DE LA GESTION DE EXPEDIENTES SGD (SISTEMA DE GESTION DOCUMENTARIA)
-- ====================================================================================
-- select t.NTFechaExpediente, t.HoraExpediente, t.FechaCreacionAuditoria
-- from tramite.Expediente t
-- cross apply tramite.ExpedienteDocumento tt
-- cross apply tramite.ExpedienteDocumentoOrigen ttt
-- cross apply tramite.ExpedienteDocumentoOrigenDestino tttt
-- where t.IdExpediente = tt.IdExpediente and t.ExpedienteAnulado = 0 and t.EstadoAuditoria = 1
-- and tt.IdExpedienteDocumento = ttt.IdExpedienteDocumento and tt.EstadoAuditoria = 1
-- and ttt.IdExpedienteDocumentoOrigen = tttt.IdExpedienteDocumentoOrigen and ttt.EstadoAuditoria = 1 and tttt.EstadoAuditoria = 1
-- and left(convert(varchar, t.FechaCreacionAuditoria, 23),7) = '2026-02'


Declare @sp varchar(1000) =
-- '[Tramite].[paListarPeriodoBusquedaExpediente]'
-- '[Tramite].[paListarComboAreaPorAreaPadrePendientes]'
-- '[Tramite].[paListarComboPersonaPorAreaPadrePendientes]'
-- '[Tramite].[paListarExpedienteMesaParteDespachadosV1]' -- DURO 30 S
'[Tramite].[paListarExpedienteMesaParteDespachadosV1]' -- DURO 5 S
--  ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- 'Tramite.paListarExpedienteMesaParteDespachadosV1'
-- 'General.fnFullTextPrefijoVal'
-- 'General.SplitFilas'
-- 'General.fnFullTextBusCarEspecial'
-- 'General.fnObtenerPaginacion'
-- 'tramite.paListarExpedienteMesaParteDespachadosV1_new'


select text from sys.syscomments where id = object_id(@sp)
return
--CORREGIR URGENTE PARA EL PROXIMO PASE DEL MIÉRCOLES 18/03/2026
-- ==============================================================
exec Tramite.paListarExpedienteMesaParteDespachadosV1
@pIdArea=116,
@pIdUsuarioAuditoria=56784,
@pCampoOrdenado=NULL,
@pTipoOrdenacion=NULL,
@pNumeroPagina=1,
@pDimensionPagina=10,
@pBusquedaGeneral='000228'


exec Tramite.paListarExpedienteMesaParteDespachadosV1
@pIdArea=116,
@pIdUsuarioAuditoria=56784,
@pCampoOrdenado=NULL,
@pTipoOrdenacion=NULL,
@pNumeroPagina=1,
@pDimensionPagina=10,
@pBusquedaGeneral='228'


exec Tramite.paListarExpedientePendienteEspecialistaPorRecibir
@pConFiltroFecha=0,
@pFechaInicio='12/03/2026',
@pFechaFin='12/03/2026',
@pConFiltroFechaMovimiento=0,
@pFechaInicioMovimiento='12/03/2026',
@pFechaFinMovimiento='12/03/2026',
@pIdPersona=950,
@pIdEmpleadoPerfil=949,
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
@pIdUsuarioAuditoria=950,
@pCampoOrdenado=NULL,
@pTipoOrdenacion=NULL,
@pNumeroPagina=1,
@pDimensionPagina=10,
@pBusquedaGeneral=NULL,
@pFlgBusqueda=0



exec Tramite.paListarExpedienteBusquedaPendiente
@pIdUsuarioAuditoria=642,
@pCampoOrdenado=NULL,
@pTipoOrdenacion=NULL,
@pNumeroPagina=1,
@pDimensionPagina=10,
@pBusquedaGeneral=NULL,
@pIdPeriodo=2026,
@pIdSerieDocumental=0,
@pNombreProyecto='',
@pNumeroExpediente='',
@pFechaExpediente='',
@pAsuntoExpediente='',
@pIdCatategoriaExpediente=0,
@pIdPrioridadExpediente=0,
@pNumeroDocumento='',
@pFechaDocumento='',
@pIdCatalogoTipoDocumento=0,
@pAsuntoDocumento='movilidad',
@pIdAreaOrigen=0,
@pIdAreaDestino=0,
@pIdCargoOrigen=0,
@pIdCargoDestino=0,
@pEmisor='',
@pDestinatario=''


exec Tramite.paListarPendientesPorAreaV1
@pIdAreaPadre=2,
@pIdAreaFiltro=0,
@pIdPersonaFiltro=0,
@pTipoPendienteFiltro=0,
@pIdCatategoriaExpediente=0,
@pIdUsuarioAuditoria=54064,
@pCampoOrdenado=NULL,
@pTipoOrdenacion=NULL,
@pNumeroPagina=1,
@pDimensionPagina=25,
@pBusquedaGeneral=NULL


exec Tramite.paListarPendientesPorAreaV1
@pIdAreaPadre=84,
@pIdAreaFiltro=0,
@pIdPersonaFiltro=0,
@pTipoPendienteFiltro=0,
@pIdCatategoriaExpediente=0,
@pIdUsuarioAuditoria=292,
@pCampoOrdenado=NULL,
@pTipoOrdenacion=NULL,
@pNumeroPagina=1,
@pDimensionPagina=25,
@pBusquedaGeneral=NULL


exec Tramite.paListarExpedienteMesaParteDespachadosVirtualesV1   -- //////////***//////////////////
@pIdUsuarioAuditoria=56784,
@pCampoOrdenado=NULL,
@pTipoOrdenacion=NULL,
@pNumeroPagina=1,
@pDimensionPagina=10,
@pBusquedaGeneral='BONIFICA'


exec Tramite.paListarExpedienteMesaParteDespachadosVirtualesV1
@pIdUsuarioAuditoria=56495,
@pCampoOrdenado=NULL,
@pTipoOrdenacion=NULL,
@pNumeroPagina=1,
@pDimensionPagina=10,
@pBusquedaGeneral='BONIF'


exec Tramite.paListarExpedienteMesaParteDespachadosVirtualesV1
@pIdUsuarioAuditoria=56784,
@pCampoOrdenado=NULL,
@pTipoOrdenacion=NULL,
@pNumeroPagina=1,
@pDimensionPagina=10,
@pBusquedaGeneral='ENTREGA'


exec Tramite.paListarExpedienteMesaParteDespachadosVirtualesV1
@pIdUsuarioAuditoria=34085,
@pCampoOrdenado=NULL,
@pTipoOrdenacion=NULL,
@pNumeroPagina=6,
@pDimensionPagina=10,
@pBusquedaGeneral=NULL



exec General.paListarComboAutocompleteMesaParte
@pNombreCompleto='CO'


exec Tramite.paListarDocumentoPendienteEspecialistaV1  -- //////////***//////////////////
@pIdExpediente=731839,
@pIdEmpresa=2,
@pIdArea=54,
@pIdCargo=86,
@pIdPersona=544,
@pIdUsuarioAuditoria=544,
@pCampoOrdenado=NULL,
@pTipoOrdenacion=NULL,
@pNumeroPagina=1,
@pDimensionPagina=10,
@pBusquedaGeneral=NULL,
@pVerSoloMio=0,
@pCorrelativoVinculado=-1



exec Tramite.paListarDocumentoPendienteJefaturaV1   -- //////////***//////////////////
@pIdExpediente=731839,
@pIdArea=67,
@pIdUsuarioAuditoria=863,
@pCampoOrdenado=NULL,
@pTipoOrdenacion=NULL,
@pNumeroPagina=1,
@pDimensionPagina=10,
@pBusquedaGeneral=NULL,
@pVerSoloMio=0,
@pCorrelativoVinculado=-1


exec Tramite.paListarCargoOrigenBusquedaExpediente


exec Tramite.paListarComboAutocompleteDestinatariosJefaturaV1
@pIdExpedienteDocumentoOrigen=6264337,
@pIdArea=8,
@pNombreCompleto='LUIS E',
@pOpcion=3


exec Tramite.paListarComboAutocompleteDestinatariosJefaturaV1
@pIdExpedienteDocumentoOrigen=6262054,
@pIdArea=42,
@pNombreCompleto='MOTA',
@pOpcion=3


exec Tramite.paListarComboAutocompleteDestinatariosJefaturaV1
@pIdExpedienteDocumentoOrigen=6264337,
@pIdArea=8,
@pNombreCompleto='LUIS ERNESTO ',
@pOpcion=3


exec Tramite.paListarComboAutocompleteDestinatariosJefaturaV1
@pIdExpedienteDocumentoOrigen=6262662,
@pIdArea=8,
@pNombreCompleto='CONSORCIO VIAL RUMI',
@pOpcion=3


exec Tramite.paListarComboAutocompleteDestinatariosJefaturaV1
@pIdExpedienteDocumentoOrigen=6264337,
@pIdArea=8,
@pNombreCompleto='LUIS ERENESTO ',
@pOpcion=3


exec Tramite.paListarComboAutocompleteDestinatariosJefaturaV1
@pIdExpedienteDocumentoOrigen=6262662,
@pIdArea=8,
@pNombreCompleto='CONSORCIO VIAL RUMIC',
@pOpcion=3
