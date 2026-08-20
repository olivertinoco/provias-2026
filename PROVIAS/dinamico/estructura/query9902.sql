alter table Tramite.ExpedienteDevuelto add IdPeriodo int;
alter table Tramite.ExpedienteEnlazado add IdPeriodo int;
alter table Tramite.ExpedienteSeguimiento add IdPeriodo int;

alter table Tramite.ExpedienteDocumento add IdPeriodo int;
alter table Tramite.ExpedienteDocumentoFirmante add IdPeriodo int;
alter table Tramite.ExpedienteDocumentoAdjunto add IdPeriodo int;
alter table Tramite.ExpedienteDocumentoAdjuntoFirmante add IdPeriodo int;
alter table Tramite.ExpedienteDocumentoAdjuntoTemporal add IdPeriodo int;

alter table Tramite.ExpedienteDocumentoOrigen add IdPeriodo int;
alter table Tramite.ExpedienteDocumentoOrigenAdjunto add IdPeriodo int;

alter table Tramite.ExpedienteDocumentoOrigenDestino add IdPeriodo int;
alter table Tramite.ExpedienteDocumentoOrigenDestinoAccion add IdPeriodo int;
alter table Tramite.ExpedienteDocumentoOrigenDestinoTemporal add IdPeriodo int;

go

update t set IdPeriodo = year(FechaCreacionAuditoria) from Tramite.ExpedienteDevuelto t;
update t set IdPeriodo = year(FechaCreacionAuditoria) from Tramite.ExpedienteEnlazado t;
update t set IdPeriodo = year(FechaCreacionAuditoria) from Tramite.ExpedienteSeguimiento t;
update t set IdPeriodo = year(FechaCreacionAuditoria) from Tramite.ExpedienteDocumento t;
update t set IdPeriodo = year(FechaCreacionAuditoria) from Tramite.ExpedienteDocumentoFirmante t;
update t set IdPeriodo = year(FechaCreacionAuditoria) from Tramite.ExpedienteDocumentoAdjunto t;
update t set IdPeriodo = year(FechaCreacionAuditoria) from Tramite.ExpedienteDocumentoAdjuntoFirmante t;
update t set IdPeriodo = year(FechaCreacionAuditoria) from Tramite.ExpedienteDocumentoAdjuntoTemporal t;
update t set IdPeriodo = year(FechaCreacionAuditoria) from Tramite.ExpedienteDocumentoOrigen t;
update t set IdPeriodo = year(FechaCreacionAuditoria) from Tramite.ExpedienteDocumentoOrigenAdjunto t;
update t set IdPeriodo = year(FechaCreacionAuditoria) from Tramite.ExpedienteDocumentoOrigenDestino t;
update t set IdPeriodo = year(FechaCreacionAuditoria) from Tramite.ExpedienteDocumentoOrigenDestinoAccion t;
update t set IdPeriodo = year(FechaCreacionAuditoria) from Tramite.ExpedienteDocumentoOrigenDestinoTemporal t;
