
-- delete t from Tramite.NumeracionSeparada t
-- cross apply Tramite.NumeracionSeparada_Historico_2024 tt
-- where tt.IdNumeracionSeparada = t.IdNumeracionSeparada


-- delete t from Tramite.ExpedienteDocumentoOrigenDestinoTemporal t
-- cross apply Tramite.ExpedienteDocumentoOrigenDestinoTemporal_Historico_2024 tt
-- where t.IdExpedienteDocumentoOrigenDestinoTemporal = tt.IdExpedienteDocumentoOrigenDestinoTemporal


-- delete t from Tramite.ExpedienteDocumentoOrigenDestinoAccion t
-- cross apply Tramite.ExpedienteDocumentoOrigenDestinoAccion_Historico_2024 tt
-- where t.IdExpedienteDocumentoOrigenDestinoAccion = tt.IdExpedienteDocumentoOrigenDestinoAccion


-- ===========================
-- set rowcount 1000000
-- delete t from Tramite.ExpedienteDocumentoOrigenDestino t
-- cross apply Tramite.ExpedienteDocumentoOrigenDestino_Historico_2024 tt
-- where t.IdExpedienteDocumentoOrigenDestino = tt.IdExpedienteDocumentoOrigenDestino
-- go 3


-- delete t from Tramite.ExpedienteDocumentoOrigenAdjunto t
-- cross apply Tramite.ExpedienteDocumentoOrigenAdjunto_Historico_2024 tt
-- where t.IdExpedienteDocumentoOrigenAdjunto = tt.IdExpedienteDocumentoOrigenAdjunto


-- delete t from Tramite.ExpedienteDocumentoOrigen t
-- cross apply Tramite.ExpedienteDocumentoOrigen_Historico_2024 tt
-- where t.IdExpedienteDocumentoOrigen = tt.IdExpedienteDocumentoOrigen


-- delete t from Tramite.ExpedienteDocumentoAdjuntoTemporal t
-- cross apply Tramite.ExpedienteDocumentoAdjuntoTemporal_Historico_2024 tt
-- where t.IdExpedienteDocumentoAdjuntoTemporal = tt.IdExpedienteDocumentoAdjuntoTemporal


-- delete t from Tramite.ExpedienteDocumentoAdjuntoFirmante t
-- cross apply Tramite.ExpedienteDocumentoAdjuntoFirmante_Historico_2024 tt
-- where t.IdExpedienteDocumentoAdjuntoFirmante = tt.IdExpedienteDocumentoAdjuntoFirmante


-- delete t from Tramite.ExpedienteDocumentoAdjunto t
-- cross apply Tramite.ExpedienteDocumentoAdjunto_Historico_2024 tt
-- where t.IdExpedienteDocumentoAdjunto = tt.IdExpedienteDocumentoAdjunto


-- delete t from Tramite.ExpedienteDocumentoFirmante t
-- cross apply Tramite.ExpedienteDocumentoFirmante_Historico_2024 tt
-- where t.IdExpedienteDocumentoFirmante = tt.IdExpedienteDocumentoFirmante


-- delete t from Tramite.ExpedienteDocumento t
-- cross apply Tramite.ExpedienteDocumento_Historico_2024 tt
-- where t.IdExpedienteDocumento = tt.IdExpedienteDocumento


-- delete t from Tramite.ExpedienteSeguimiento t
-- cross apply Tramite.ExpedienteSeguimiento_Historico_2024 tt
-- where t.IdExpedienteSeguimiento = tt.IdExpedienteSeguimiento


-- delete t from Tramite.ExpedienteEnlazado t
-- cross apply Tramite.ExpedienteEnlazado_Historico_2024 tt
-- where t.IdExpedienteEnlazado = tt.IdExpedienteEnlazado



-- delete t from Tramite.ExpedienteDevuelto t
-- cross apply Tramite.ExpedienteDevuelto_Historico_2024 tt
-- where t.IdExpedienteDevuelto = tt.IdExpedienteDevuelto


-- delete t from Tramite.Expediente t
-- cross apply Tramite.Expediente_Historico_2024 tt
-- where t.IdExpediente = tt.IdExpediente
