-- EXECUTE Tramite.paListarDetalleBusquedaExpedienteGeneral_arq 727733,79,349,null,null,1,25,null,-1, 2025

-- EXECUTE Tramite.paListarDetalleBusquedaExpedienteGeneral_arq 727733,79,349,null,null,1,25,null,-1, 2026



select*from Tramite.Expediente_historico_2025 where IdExpediente = 727733

select*from Tramite.ExpedienteDocumento_historico_2025 where IdExpediente = 727733
select*from Tramite.ExpedienteDocumento where IdExpediente = 727733


select*from Tramite.ExpedienteDocumentoOrigen_historico_2025 where IdExpedienteDocumento in (2282088,2277252,2253074)
select*from Tramite.ExpedienteDocumentoOrigen where IdExpedienteDocumento in (2282088,2277252,2253074)
