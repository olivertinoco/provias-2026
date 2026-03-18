-- Tramite.ExpedienteArq

=====================================================
TABLAS CLAVE PARA LA GESTION DE TRAMITE DOCUMENTARIO:
=====================================================

--TRAMITE DOCUMENTAL
select top(20) * from Tramite.Expediente where NumeroExpediente = '0167783' and EstadoAuditoria = 1
select top(20) * from Tramite.ExpedienteDocumento where IdExpediente = '68672'  and EstadoAuditoria = 1

--DATOS DEL EXPEDIENTE AL MOMENTO DE GUARDARLO
select top(20) * from Tramite.ExpedienteDocumento order by IdExpedienteDocumento desc
select top(20) * from Tramite.ExpedienteDocumentoOrigen order by IdExpedienteDocumentoOrigen desc
select top(20) * from Tramite.ExpedienteDocumentoOrigenDestino order by IdExpedienteDocumentoOrigenDestino desc
select top(20) * from Tramite.ExpedienteDocumentoOrigenDestinoAccion order by IdExpedienteDocumentoOrigenDestinoAccion desc
select top(200) * from Tramite.visExpedienteCompleto

--DATOS DE: ARCHIVOS ADJUNTOS DEL DOCUMENTO
select top(5) * from Tramite.ExpedienteDocumentoAdjuntoTemporal order by IdExpedienteDocumentoAdjuntoTemporal desc
--DATOS DE: DESTINATARIOS
select top(5) * from Tramite.ExpedienteDocumentoOrigenDestinoTemporal order by IdExpedienteDocumentoOrigenDestinoTemporal desc

--DATOS DE: FIRMANTES
select top(5) * from Tramite.ExpedienteDocumentoFirmante order by IdExpedienteDocumentoFirmante desc
select top(5) * from tramite.ExpedienteDocumentoAdjuntoFirmante order by IdExpedienteDocumentoAdjuntoFirmante desc
