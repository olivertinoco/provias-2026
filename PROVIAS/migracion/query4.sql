go
create procedure Tramite.paSGDcreaTablasAnuales_arq
as
begin
begin try
set nocount on
Declare @vSql Nvarchar(max)=null, @vperiodo varchar(4) = year(getdate())-1

select @vperiodo -- = 2028
return

select @vSql = N'\
create table Tramite.Expediente_Historico_'+ @vperiodo +N' (
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
select @vSql = N'\
create table Tramite.ExpedienteDevuelto_Historico_'+ @vperiodo +N' (
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
select @vSql = N'\
create table Tramite.ExpedienteDocumento_Historico_'+ @vperiodo +N' (
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
select @vSql = N'\
create table Tramite.ExpedienteDocumentoAdjunto_Historico_'+ @vperiodo +N' (
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
select @vSql = N'\
create table Tramite.ExpedienteDocumentoAdjuntoFirmante_Historico_'+ @vperiodo +N' (
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
select @vSql = N'\
create table Tramite.ExpedienteDocumentoAdjuntoTemporal_Historico_'+ @vperiodo +N' (
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
)'
exec sp_executesql @vSql

select @vSql = null
select @vSql = N'\
create table Tramite.ExpedienteDocumentoFirmante_Historico_'+ @vperiodo +N' (
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
)'
exec sp_executesql @vSql

select @vSql = null
select @vSql = N'\
create table Tramite.ExpedienteDocumentoOrigen_Historico_'+ @vperiodo +N' (
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
)'
exec sp_executesql @vSql

select @vSql = null
select @vSql = N'\
create table Tramite.ExpedienteDocumentoOrigenAdjunto_Historico_'+ @vperiodo +N' (
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
)'
exec sp_executesql @vSql

select @vSql = null
select @vSql = N'\
create table Tramite.ExpedienteDocumentoOrigenDestino_Historico_'+ @vperiodo +N' (
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
)'
exec sp_executesql @vSql

select @vSql = null
select @vSql = N'\
create table Tramite.ExpedienteDocumentoOrigenDestinoAccion_Historico_'+ @vperiodo +N' (
IdExpedienteDocumentoOrigenDestinoAccion int not null primary key,
IdExpedienteDocumentoOrigenDestino int,
IdCatalogoTipoAccion int,
IdUsuarioCreacionAuditoria int,
FechaCreacionAuditoria datetime,
IdUsuarioActualizacionAuditoria int,
FechaActualizacionAuditoria datetime,
EstadoAuditoria bit
)'
exec sp_executesql @vSql

select @vSql = null
select @vSql = N'\
create table Tramite.ExpedienteDocumentoOrigenDestinoTemporal_Historico_'+ @vperiodo +N' (
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
)'
exec sp_executesql @vSql

select @vSql = null
select @vSql = N'\
create table Tramite.ExpedienteDocumentoVisualizacion_Historico_'+ @vperiodo +N' (
IdExpedienteDocumentoVisualizacion bigint not null primary key,
IdExpedienteDocumento int,
RutaArchivo varchar (400),
Accion varchar (100),
IdUsuarioCreacionAuditoria int,
FechaCreacionAuditoria datetime
)'
exec sp_executesql @vSql

select @vSql = null
select @vSql = N'\
create table Tramite.ExpedienteEnlazado_Historico_'+ @vperiodo +N' (
IdExpedienteEnlazado int not null primary key,
IdExpediente int,
IdExpedienteSecundario int,
Activo bit,
IdUsuarioCreacionAuditoria int,
FechaCreacionAuditoria datetime,
IdUsuarioActualizacionAuditoria int,
FechaActualizacionAuditoria datetime,
EstadoAuditoria tinyint
)'
exec sp_executesql @vSql

select @vSql = null
select @vSql = N'\
create table Tramite.ExpedienteSeguimiento_Historico_'+ @vperiodo +N' (
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
)'
exec sp_executesql @vSql

select @vSql = null
select @vSql = N'\
create table Tramite.NumeracionSeparada_Historico_'+ @vperiodo +N' (
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
)'
exec sp_executesql @vSql

select @vSql = null
select @vSql = N'\
CREATE NONCLUSTERED INDEX IX_Hist_Completo_OrigenDestino
ON Tramite.ExpedienteDocumentoOrigenDestino_historico_'+ @vperiodo +N' (IdExpedienteDocumentoOrigen, EstadoAuditoria, IdCatalogoSituacionMovimientoDestino)
WITH (ONLINE = ON, FILLFACTOR = 90)'

exec sp_executesql @vSql

select @vSql = null
select @vSql = N'\
CREATE NONCLUSTERED INDEX IX_ExpDoc_HistoricoPeriodo_IdExpediente_Estado
ON Tramite.ExpedienteDocumento_historico_'+ @vperiodo +N' (IdExpediente, EstadoAuditoria)
INCLUDE (IdExpedienteDocumento, NumeroDocumento, CorrelativoVinculado,NumeroFoliosDocumento)
WITH (ONLINE = ON, FILLFACTOR = 90)'

exec sp_executesql @vSql

select @vSql = null
select @vSql = N'\
CREATE NONCLUSTERED INDEX IX_ExpDocOrigen_HistoricoPeriodo_IdExpDoc_Estado
ON Tramite.ExpedienteDocumentoOrigen_historico_'+ @vperiodo +N' (IdExpedienteDocumento, EstadoAuditoria)
INCLUDE (IdExpedienteDocumentoOrigen, IdCatalogoTipoMovimientoOrigen, IdPersonaOrigen, FechaOrigen, HoraOrigen)
WITH (ONLINE = ON, FILLFACTOR = 90)'

exec sp_executesql @vSql

select @vSql = null
select @vSql = N'\
CREATE NONCLUSTERED INDEX IX_ExpDocOrigenDest_HistoricoPeriodo_IdOrigen_Estado
ON Tramite.ExpedienteDocumentoOrigenDestino_historico_'+ @vperiodo +N' (IdExpedienteDocumentoOrigen, EstadoAuditoria)
INCLUDE(IdExpedienteDocumentoOrigenDestino,FechaDestino,HoraDestino)
WITH (ONLINE = ON, FILLFACTOR = 90)'

exec sp_executesql @vSql


select @vSql = null
select @vSql = N'\
CREATE NONCLUSTERED INDEX IX_Expediente_HistoricoPeriodo_IdExpediente_Estado
ON Tramite.Expediente_historico_'+ @vperiodo +N' (IdExpediente, EstadoAuditoria, ExpedienteAnulado)
INCLUDE (NumeroExpediente, IdPeriodo, IdSerieDocumentalExpediente)
WITH (ONLINE = ON, FILLFACTOR = 90)'

exec sp_executesql @vSql

end try
begin catch
    DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
	SELECT @ERROR_NUMBER=ERROR_NUMBER(), @ERROR_SEVERITY=ERROR_SEVERITY(), @ERROR_STATE=ERROR_STATE(),
	@ERROR_PROCEDURE='Tramite.paSGDcreaTablasAnuales_arq',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER,@ERROR_SEVERITY,@ERROR_STATE,@ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE,2222
end catch
end
go
