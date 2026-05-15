
Declare @vAnno char(4), @vSql nvarchar(max)

select @vAnno = year(getdate())

select @vSql = N'
create table Tramite.Expediente_Historico_'+ @vAnno +N' (
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
)'
exec sp_executesql @vSql

select @vSql = null
select @vSql = N'
create table Tramite.ExpedienteDevuelto_Historico_'+ @vAnno +N' (
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
)'
exec sp_executesql @vSql

select @vSql = null
select @vSql = N'
create table Tramite.ExpedienteDocumento_Historico_'+ @vAnno +N' (
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
)'
exec sp_executesql @vSql

select @vSql = null
select @vSql = N'
create table Tramite.ExpedienteDocumentoAdjunto_Historico_'+ @vAnno +N' (
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
)'
exec sp_executesql @vSql

select @vSql = null
select @vSql = N'
create table Tramite.ExpedienteDocumentoAdjuntoFirmante_Historico_2025 (
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
)'
exec sp_executesql @vSql

select @vSql = null
select @vSql = N'









select*from Tramite.Expediente_Historico_2026
select*from Tramite.ExpedienteDevuelto_Historico_2026
ExpedienteDocumento_Historico_2026
ExpedienteDocumentoAdjunto_Historico_2026
ExpedienteDocumentoAdjuntoFirmante_Historico_2026
