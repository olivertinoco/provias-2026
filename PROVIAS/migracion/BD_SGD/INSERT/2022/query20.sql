insert into Tramite.Expediente_Historico_2022
select*from Tramite.Expediente t
WHERE t.FechaCreacionAuditoria >= '20220101'
    AND t.FechaCreacionAuditoria <  '20230101'

insert into Tramite.ExpedienteDocumento_Historico_2022
select t.* from Tramite.ExpedienteDocumento t
cross apply Tramite.Expediente_historico_2022 tt
where t.IdExpediente = tt.IdExpediente

insert into Tramite.ExpedienteDocumentoOrigen_Historico_2022
select t.* from Tramite.ExpedienteDocumentoOrigen t
cross apply Tramite.ExpedienteDocumento_historico_2022 tt
where t.IdExpedienteDocumento = tt.IdExpedienteDocumento

insert into Tramite.ExpedienteDocumentoOrigenDestino_Historico_2022
select t.* from Tramite.ExpedienteDocumentoOrigenDestino t
cross apply Tramite.ExpedienteDocumentoOrigen_Historico_2022 tt
where t.IdExpedienteDocumentoOrigen = tt.IdExpedienteDocumentoOrigen





insert into Tramite.ExpedienteDevuelto_Historico_2022
select t.* from Tramite.ExpedienteDevuelto t
cross apply Tramite.Expediente_historico_2022 tt
where t.IdExpediente = tt.IdExpediente

insert into Tramite.ExpedienteEnlazado_Historico_2022
select t.* from Tramite.ExpedienteEnlazado t
cross apply Tramite.Expediente_historico_2022 tt
where t.IdExpediente = tt.IdExpediente

insert into Tramite.ExpedienteSeguimiento_Historico_2022
select t.* from Tramite.ExpedienteSeguimiento t
cross apply Tramite.Expediente_historico_2022 tt
where t.IdExpediente = tt.IdExpediente

insert into Tramite.NumeracionSeparada_Historico_2022
select t.* from Tramite.NumeracionSeparada t
WHERE t.FechaCreacionAuditoria >= '20220101'
    AND t.FechaCreacionAuditoria <  '20230101'





insert into Tramite.ExpedienteDocumentoFirmante_Historico_2022
select t.* from Tramite.ExpedienteDocumentoFirmante t
cross apply Tramite.ExpedienteDocumento_historico_2022 tt
where t.IdExpedienteDocumento = tt.IdExpedienteDocumento

insert into Tramite.ExpedienteDocumentoAdjunto_Historico_2022
select t.* from Tramite.ExpedienteDocumentoAdjunto t
cross apply Tramite.ExpedienteDocumento_historico_2022 tt
where t.IdExpedienteDocumento = tt.IdExpedienteDocumento

insert into Tramite.ExpedienteDocumentoAdjuntoFirmante_Historico_2022
select t.* from Tramite.ExpedienteDocumentoAdjuntoFirmante t
cross apply Tramite.ExpedienteDocumento_historico_2022 tt
where t.IdExpedienteDocumento = tt.IdExpedienteDocumento

insert into Tramite.ExpedienteDocumentoAdjuntoTemporal_Historico_2022
select t.* from Tramite.ExpedienteDocumentoAdjuntoTemporal t
WHERE t.FechaCreacionAuditoria >= '20220101'
    AND t.FechaCreacionAuditoria <  '20230101'





insert into Tramite.ExpedienteDocumentoOrigenAdjunto_Historico_2022
select t.* from Tramite.ExpedienteDocumentoOrigenAdjunto t
WHERE t.FechaCreacionAuditoria >= '20220101'
    AND t.FechaCreacionAuditoria <  '20230101'





insert into Tramite.ExpedienteDocumentoOrigenDestinoAccion_Historico_2022
select t.* from Tramite.ExpedienteDocumentoOrigenDestinoAccion t
cross apply Tramite.ExpedienteDocumentoOrigenDestino_Historico_2022 tt
where t.IdExpedienteDocumentoOrigenDestino = tt.IdExpedienteDocumentoOrigenDestino

insert into Tramite.ExpedienteDocumentoOrigenDestinoTemporal_Historico_2022
select t.* from Tramite.ExpedienteDocumentoOrigenDestinoTemporal t
WHERE t.FechaCreacionAuditoria >= '20220101'
    AND t.FechaCreacionAuditoria <  '20230101'
