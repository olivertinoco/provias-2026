
alter table Tramite.ExpedienteDocumentoOrigenDestinoAccion drop constraint fkIdExpedienteDocumentoOrigenDestinoAccion;
alter table Tramite.ExpedienteDocumentoOrigenDestino drop constraint fkIdExpedienteDocumentoOrigenDestino;
alter table Tramite.ExpedienteDocumentoAdjuntoFirmante drop constraint fkIdExpedienteDocumentoAdjuntoFirmante;
alter table Tramite.ExpedienteDocumentoOrigen drop constraint fkIdExpedienteDocumentoOrigen;
alter table Tramite.ExpedienteDocumento drop constraint fkIdExpedienteDocumento;
alter table Tramite.ExpedienteBloqueado drop constraint fkIdExpedienteBloqueado;
alter table Tramite.ExpedienteEnlazado drop constraint fkIdExpedienteEnlazado;

waitfor delay '00:00:10';

drop table Tramite.NumeracionSeparada
waitfor delay '00:00:05';
drop table Tramite.ExpedienteDocumentoOrigenDestinoTemporal
waitfor delay '00:00:05';
drop table Tramite.ExpedienteDocumentoOrigenDestinoAccion
waitfor delay '00:00:05';
drop table Tramite.ExpedienteDocumentoOrigenDestino
waitfor delay '00:00:05';
drop table Tramite.ExpedienteDocumentoOrigenAdjunto
waitfor delay '00:00:05';
drop table Tramite.ExpedienteDocumentoOrigen
waitfor delay '00:00:05';
drop table Tramite.ExpedienteDocumentoAdjuntoTemporal
waitfor delay '00:00:05';
drop table Tramite.ExpedienteDocumentoAdjuntoFirmante
waitfor delay '00:00:05';
drop table Tramite.ExpedienteDocumentoAdjunto
waitfor delay '00:00:05';
drop table Tramite.ExpedienteDocumentoFirmante
waitfor delay '00:00:05';
drop table Tramite.ExpedienteDocumento
waitfor delay '00:00:05';
drop table Tramite.ExpedienteSeguimiento
waitfor delay '00:00:05';
drop table Tramite.ExpedienteEnlazado
waitfor delay '00:00:05';
drop table Tramite.ExpedienteDevuelto
waitfor delay '00:00:05';
drop table Tramite.Expediente

select 'Tablas eliminadas correctamente!...'
