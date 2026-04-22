GO
if exists(select 1 from sys.sysobjects where id=object_id('Tramite.Expediente_Historico_2023','U'))
drop table Tramite.Expediente_Historico_2023
GO
create table Tramite.Expediente_Historico_2023 (
IdExpediente int not null primary key,
IdSerieDocumentalExpediente int,
IdProyectoComponente int,
IdExpedienteVinculado int,
IdCatalogoTipoPrioridad int,
IdCatalogoSituacionExpediente int,
IdCatalogoSituacionNotificacionExpediente int,
IdCatalogoTipoMovimientoTramite int,
IdCatalogoTipoTramite int,
IdPeriodo int,
IdEmpresaCreador int,
IdAreaCreador int,
IdCargoCreador int,
IdPersonaCreador int,
NombreCompletoCreador varchar (100),
NumeroExpediente int,
AsuntoExpediente varchar (8000),
NTFechaExpediente varchar (10),
HoraExpediente varchar (5),
NumeroFoliosExpediente int,
ObservacionesExpediente varchar (4000),
NombreCompletoNoticado varchar (100),
EmailNotificacion varchar (100),
CelularNotificacion varchar (100),
TelefonoNotificacion varchar (100),
DireccionNotificacion varchar (100),
ExpedienteConfidencial bit,
ExpedienteAnulado bit,
MotivoExpedienteAnulado varchar (4000),
NFechaAnulacionExpediente varchar (10),
HoraAnulacionExpediente varchar (5),
ExpedienteArchivado bit,
FechaExpedienteArchivado varchar (10),
HoraExpedienteArchivado varchar (5),
IdUsuarioUltimoExpedienteArchivado int,
IdUsuarioCreacionAuditoria int,
FechaCreacionAuditoria datetime,
IdUsuarioActualizacionAuditoria int,
FechaActualizacionAuditoria datetime,
EstadoAuditoria bit,
Clave varchar (6),
FgTramiteVirtual bit,
NumeroExpedienteExterno varchar (100),
FgTramiteVirtualPide bit,
NombreExpediente varchar (21),
NumeroRucDniRemitente varchar (11),
RazonSocialNombreRemitente varchar (100),
NumeroContratoRemitente varchar (100),
DescripcionContratoRemitente varchar (1000)
);

GO
if exists(select 1 from sys.sysobjects where id=object_id('Tramite.ExpedienteDevuelto_Historico_2023','U'))
drop table Tramite.ExpedienteDevuelto_Historico_2023
GO
create table Tramite.ExpedienteDevuelto_Historico_2023 (
IdExpedienteDevuelto int not null primary key,
IdExpediente int,
FechaHoraDevolucion datetime,
DescripcionDevolucion varchar (1000),
IdUsuarioCreacionAuditoria int,
FechaCreacionAuditoria datetime,
IdUsuarioActualizacionAuditoria int,
FechaActualizacionAuditoria datetime,
EstadoAuditoria bit,
RutaArchivoDocumentoDevuelto varchar (200)
);

GO
if exists(select 1 from sys.sysobjects where id=object_id('Tramite.ExpedienteDocumento_Historico_2023','U'))
drop table Tramite.ExpedienteDocumento_Historico_2023
GO
create table Tramite.ExpedienteDocumento_Historico_2023 (
IdExpedienteDocumento int not null primary key,
IdExpediente int,
IdCatalogoTipoDocumento int,
IdCatalogoTipoMovimientoDocumento int,
IdEmpresaEmisor int,
IdAreaEmisor int,
IdCargoEmisor int,
IdPersonaEmisor int,
NombreCompletoEmisor varchar (100),
NumeroDocumento varchar (200),
Correlativo int,
CorrelativoLetra varchar (10),
NumeroFoliosDocumento int,
AsuntoDocumento varchar (8000),
NFechaDocumento varchar (10),
RutaArchivoDocumento varchar (150),
ObservacionesDocumento varchar (4000),
IdUsuarioCreacionAuditoria int,
FechaCreacionAuditoria datetime,
IdUsuarioActualizacionAuditoria int,
FechaActualizacionAuditoria datetime,
EstadoAuditoria bit,
EsVinculado int,
CorrelativoVinculado int,
IdExpedientePreviaVinculacion int,
ObservacionesVinculacion varchar (max),
FgEsObservado bit,
FgEsCorregido bit,
RutaArchivoDocumentoCorregido varchar (200),
NFechaDocumentoCorregido varchar (10),
HoraDocumentoCorregido varchar (5),
DescripcionCorreccion varchar (1000),
DescripcionObervacionIngresada varchar (1000),
IdExpedienteVirtual int,
FgDocumentoVirtualEnviado bit,
FgEnvioCorregido bit,
FechaHoraFirmaDigital varchar (16),
FgEsObligatorioFirmaDigital bit,
FlagParaDespacho bit,
FgEnEsperaFirmaDigital bit,
fgFirmaDigitalExterno bit,
FechaEnvioDocumentoCorregido datetime,
LinkArchivoCompartido varchar (max),
FechaEnvioDocumento datetime,
IdCatalogoTipoOrigen int,
IdCatalogoTipoDocumentoCopia int,
NumeroDocumentoCopia varchar (100),
AsuntoDocumentoCopia varchar (8000),
NombreCompletoEmisorCopia varchar (100),
EnProcesoFirma bit,
IdUsuarioEnProcesoFirma int,
CuoPide varchar (10),
FgGeneradoPorExterno bit,
FgActivoExterno bit
);

GO
if exists(select 1 from sys.sysobjects where id=object_id('Tramite.ExpedienteDocumentoAdjunto_Historico_2023','U'))
drop table Tramite.ExpedienteDocumentoAdjunto_Historico_2023
GO
create table Tramite.ExpedienteDocumentoAdjunto_Historico_2023 (
IdExpedienteDocumentoAdjunto int not null primary key,
IdExpedienteDocumento int,
IdCatalogoTipoAdjunto int,
DescripcionDocumentoAdjunto varchar (4000),
RutaArchivoDocumentoAdjunto varchar (200),
IdUsuarioCreacionAuditoria int,
FechaCreacionAuditoria datetime,
IdUsuarioActualizacionAuditoria int,
FechaActualizacionAuditoria datetime,
EstadoAuditoria bit,
EnProcesoFirma bit,
FechaHoraFirmaDigital datetime,
IdUsuarioEnProcesoFirma int,
FgEsObligatorioFirmaDigital bit,
FgEnEsperaFirmaDigital bit
);

GO
if exists(select 1 from sys.sysobjects where id=object_id('Tramite.ExpedienteDocumentoAdjuntoFirmante_Historico_2023','U'))
drop table Tramite.ExpedienteDocumentoAdjuntoFirmante_Historico_2023
GO
create table Tramite.ExpedienteDocumentoAdjuntoFirmante_Historico_2023 (
IdExpedienteDocumentoAdjuntoFirmante int not null primary key,
IdExpedienteDocumentoAdjunto int,
CodigoGuidTemporal varchar (100),
IdExpedienteDocumento int,
IdEmpresa int,
IdArea int,
IdCargo int,
IdPersona int,
NombreCompleto varchar (100),
IdEmpleadoPerfilFirmante int,
IdCatalogoTipoFirmante int,
FlagFirmado bit,
FechaHoraFirmado varchar (16),
PosicionX int,
PosicionY int,
IdCatalogoMotivoFirma int,
FirmadoIndependiente bit,
IdUsuarioCreacionAuditoria int,
FechaCreacionAuditoria datetime,
IdUsuarioActualizacionAuditoria int,
FechaActualizacionAuditoria datetime,
EstadoAuditoria tinyint
);

GO
if exists(select 1 from sys.sysobjects where id=object_id('Tramite.ExpedienteDocumentoAdjuntoTemporal_Historico_2023','U'))
drop table Tramite.ExpedienteDocumentoAdjuntoTemporal_Historico_2023
GO
create table Tramite.ExpedienteDocumentoAdjuntoTemporal_Historico_2023 (
IdExpedienteDocumentoAdjuntoTemporal int not null primary key,
IdPadreTemporal varchar (100),
IdCatalogoTipoAdjunto int,
DescripcionDocumentoAdjunto nvarchar (4000),
RutaArchivoDocumentoAdjunto nvarchar (200),
IdUsuarioCreacionAuditoria int,
FechaCreacionAuditoria datetime,
IdUsuarioActualizacionAuditoria int,
FechaActualizacionAuditoria datetime,
EstadoAuditoria bit
);

GO
if exists(select 1 from sys.sysobjects where id=object_id('Tramite.ExpedienteDocumentoFirmante_Historico_2023','U'))
drop table Tramite.ExpedienteDocumentoFirmante_Historico_2023
GO
create table Tramite.ExpedienteDocumentoFirmante_Historico_2023 (
IdExpedienteDocumentoFirmante int not null primary key,
CodigoGuidTemporal varchar (100),
IdExpedienteDocumento int,
IdEmpresa int,
IdArea int,
IdCargo int,
IdPersona int,
NombreCompleto varchar (100),
IdEmpleadoPerfilFirmante int,
IdCatalogoTipoFirmante int,
FlagFirmado bit,
FechaHoraFirmado varchar (16),
PosicionX int,
PosicionY int,
IdCatalogoMotivoFirma int,
IdUsuarioCreacionAuditoria int,
FechaCreacionAuditoria datetime,
IdUsuarioActualizacionAuditoria int,
FechaActualizacionAuditoria datetime,
EstadoAuditoria tinyint,
FirmadoIndependiente bit
);

GO
if exists(select 1 from sys.sysobjects where id=object_id('Tramite.ExpedienteDocumentoOrigen_Historico_2023','U'))
drop table Tramite.ExpedienteDocumentoOrigen_Historico_2023
GO
create table Tramite.ExpedienteDocumentoOrigen_Historico_2023 (
IdExpedienteDocumentoOrigen int not null primary key,
IdExpedienteDocumento int,
NumeroDiasAtencionSolicitado int,
IdCatalogoSituacionMovimientoOrigen int,
IdCatalogoTipoMovimientoOrigen int,
IdEmpresaOrigenEnvia int,
IdAreaOrigenEnvia int,
IdCargoOrigenEnvia int,
IdPersonaOrigenEnvia int,
IdEmpresaOrigen int,
IdAreaOrigen int,
IdCargoOrigen int,
IdPersonaOrigen int,
NombreCompletoOrigen varchar (100),
IdCatalogoTipoDevolucion int,
Descripciondevolucion varchar (4000),
FechaOrigen varchar (10),
HoraOrigen varchar (5),
ConCargoFisico bit,
RutaArchiCargoFisico varchar (50),
FechaCargoFisico varchar (10),
HoraCargoFisico varchar (5),
IdEmpresaCargoFisico int,
IdAreaCargoFisico int,
IdCargoCargoFisico int,
IdPersonaCargoFisico int,
EsCabecera bit,
EsVinculado bit,
IdUsuarioCreacionAuditoria int,
FechaCreacionAuditoria datetime,
IdUsuarioActualizacionAuditoria int,
FechaActualizacionAuditoria datetime,
EstadoAuditoria bit,
FgGeneradoPorExterno bit,
FgActivoExterno bit
);

GO
if exists(select 1 from sys.sysobjects where id=object_id('Tramite.ExpedienteDocumentoOrigenAdjunto_Historico_2023','U'))
drop table Tramite.ExpedienteDocumentoOrigenAdjunto_Historico_2023
GO
create table Tramite.ExpedienteDocumentoOrigenAdjunto_Historico_2023 (
IdExpedienteDocumentoOrigenAdjunto int not null primary key,
CodigoGuidTemporalEDO varchar (100),
IdExpedienteDocumentoOrigenEDO int,
IdCatalogoTipoAdjuntoEDO int,
DescripcionDocumentoAdjuntoEDO varchar (4000),
RutaArchivoDocumentoAdjuntoEDO varchar (50),
IdUsuarioCreacionAuditoria int,
FechaCreacionAuditoria datetime,
IdUsuarioActualizacionAuditoria int,
FechaActualizacionAuditoria datetime,
EstadoAuditoria tinyint,
FgActivoExterno bit
);

GO
if exists(select 1 from sys.sysobjects where id=object_id('Tramite.ExpedienteDocumentoOrigenDestino_Historico_2023','U'))
drop table Tramite.ExpedienteDocumentoOrigenDestino_Historico_2023
GO
create table Tramite.ExpedienteDocumentoOrigenDestino_Historico_2023 (
IdExpedienteDocumentoOrigenDestino int not null primary key,
IdExpedienteDocumentoOrigen int,
IdExpedienteDocumentoOrigenDestinoAnterior int,
IdExpedienteDocumentoOrigenAnterior int,
IdCatalogoSituacionMovimientoDestino int,
IdCatalogoTipoMovimientoDestino int,
EsInicial int,
NumeroDiasAtencionSolicitado int,
NumeroDiasAtencionAceptado int,
Original bit,
Copia bit,
FechaDestino varchar (10),
HoraDestino varchar (5),
IdEmpresaDestino int,
IdAreaDestino int,
IdCargoDestino int,
IdPersonaDestino int,
IdEmpresaDestinoAtencion int,
IdAreaDestinoAtencion int,
IdCargoDestinoAtencion int,
IdPersonaDestinoAtencion int,
IdEmpresaDestinoRecepciona int,
IdAreaDestinoRecepciona int,
IdCargoDestinoRecepciona int,
IdPersonaDestinoRecepciona int,
FechaDestinoRecepciona varchar (10),
HoraDestinoRecepciona varchar (5),
FechaDestinoEnvia varchar (10),
HoraDestinoEnvia varchar (5),
IdEstanteArchivador int,
MotivoArchivado varchar (8000),
FechaArchivado varchar (10),
HoraArchivado varchar (5),
ObservacionesDestinatario varchar (4000),
IdUsuarioCreacionAuditoria int,
FechaCreacionAuditoria datetime,
IdUsuarioActualizacionAuditoria int,
FechaActualizacionAuditoria datetime,
EstadoAuditoria bit,
DestinatarioDestinoRecepciona varchar (800),
DestinatarioDestinoAtencion varchar (800),
DestinatarioDestino varchar (800)
);

GO
if exists(select 1 from sys.sysobjects where id=object_id('Tramite.ExpedienteDocumentoOrigenDestinoAccion_Historico_2023','U'))
drop table Tramite.ExpedienteDocumentoOrigenDestinoAccion_Historico_2023
GO
create table Tramite.ExpedienteDocumentoOrigenDestinoAccion_Historico_2023 (
IdExpedienteDocumentoOrigenDestinoAccion int not null primary key,
IdExpedienteDocumentoOrigenDestino int,
IdCatalogoTipoAccion int,
IdUsuarioCreacionAuditoria int,
FechaCreacionAuditoria datetime,
IdUsuarioActualizacionAuditoria int,
FechaActualizacionAuditoria datetime,
EstadoAuditoria bit
);

GO
if exists(select 1 from sys.sysobjects where id=object_id('Tramite.ExpedienteDocumentoOrigenDestinoTemporal_Historico_2023','U'))
drop table Tramite.ExpedienteDocumentoOrigenDestinoTemporal_Historico_2023
GO
create table Tramite.ExpedienteDocumentoOrigenDestinoTemporal_Historico_2023 (
IdExpedienteDocumentoOrigenDestinoTemporal int not null primary key,
IdPadreTemporal varchar (100),
Original bit,
Copia bit,
ListaIdAccion varchar (200),
NumeroDiasAtencionSolicitado int,
CodigoDestinatario varchar (100),
Destinatario varchar (400),
ObservacionesDestinatario varchar (4000),
IdUsuarioCreacionAuditoria int,
FechaCreacionAuditoria datetime,
IdUsuarioActualizacionAuditoria int,
FechaActualizacionAuditoria datetime,
EstadoAuditoria bit
);

GO
if exists(select 1 from sys.sysobjects where id=object_id('Tramite.ExpedienteDocumentoVisualizacion_Historico_2023','U'))
drop table Tramite.ExpedienteDocumentoVisualizacion_Historico_2023
GO
create table Tramite.ExpedienteDocumentoVisualizacion_Historico_2023 (
IdExpedienteDocumentoVisualizacion bigint not null primary key,
IdExpedienteDocumento int,
RutaArchivo varchar (400),
Accion varchar (100),
IdUsuarioCreacionAuditoria int,
FechaCreacionAuditoria datetime
);

GO
if exists(select 1 from sys.sysobjects where id=object_id('Tramite.ExpedienteEnlazado_Historico_2023','U'))
drop table Tramite.ExpedienteEnlazado_Historico_2023
GO
create table Tramite.ExpedienteEnlazado_Historico_2023 (
IdExpedienteEnlazado int not null primary key,
IdExpediente int,
IdExpedienteSecundario int,
Activo bit,
IdUsuarioCreacionAuditoria int,
FechaCreacionAuditoria datetime,
IdUsuarioActualizacionAuditoria int,
FechaActualizacionAuditoria datetime,
EstadoAuditoria tinyint
);

GO
if exists(select 1 from sys.sysobjects where id=object_id('Tramite.ExpedienteSeguimiento_Historico_2023','U'))
drop table Tramite.ExpedienteSeguimiento_Historico_2023
GO
create table Tramite.ExpedienteSeguimiento_Historico_2023 (
IdExpedienteSeguimiento int not null primary key,
IdExpediente int,
IdEmpresa int,
IdArea int,
IdCargo int,
IdPersona int,
IdUsuarioCreacionAuditoria int,
FechaCreacionAuditoria datetime,
IdUsuarioActualizacionAuditoria int,
FechaActualizacionAuditoria datetime,
EstadoAuditoria tinyint
);

GO
if exists(select 1 from sys.sysobjects where id=object_id('Tramite.NumeracionSeparada_Historico_2023','U'))
drop table Tramite.NumeracionSeparada_Historico_2023
GO
create table Tramite.NumeracionSeparada_Historico_2023 (
IdNumeracionSeparada int not null primary key,
IdArea int,
IdCatalogoTipoDocumento int,
Correlativo int,
NumeroDocumento varchar (1000),
Usado bit,
IdUsuarioCreacionAuditoria int,
FechaCreacionAuditoria datetime,
IdUsuarioActualizacionAuditoria int,
FechaActualizacionAuditoria datetime,
EstadoAuditoria tinyint,
IdPeriodo int
);
GO
