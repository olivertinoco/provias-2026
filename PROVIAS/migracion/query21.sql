
Declare @vSql Nvarchar(max)=null, @vperiodo varchar(4) = year(getdate())-1

select @vperiodo = 2028

-- select count(1) from Tramite.Expediente


-- set identity_insert Tramite.Expediente on;

-- -- insert into Tramite.Expediente
-- -- (IdExpediente,IdSerieDocumentalExpediente,IdProyectoComponente,IdExpedienteVinculado,IdCatalogoTipoPrioridad,IdCatalogoSituacionExpediente,
-- -- IdCatalogoSituacionNotificacionExpediente,IdCatalogoTipoMovimientoTramite,IdCatalogoTipoTramite,IdPeriodo,IdEmpresaCreador,IdAreaCreador,IdCargoCreador,
-- -- IdPersonaCreador,NombreCompletoCreador,NumeroExpediente,AsuntoExpediente,NTFechaExpediente,HoraExpediente,NumeroFoliosExpediente,ObservacionesExpediente,
-- -- NombreCompletoNoticado,EmailNotificacion,CelularNotificacion,TelefonoNotificacion,DireccionNotificacion,ExpedienteConfidencial,ExpedienteAnulado,
-- -- MotivoExpedienteAnulado,NFechaAnulacionExpediente,HoraAnulacionExpediente,ExpedienteArchivado,FechaExpedienteArchivado,HoraExpedienteArchivado,
-- -- IdUsuarioUltimoExpedienteArchivado,IdUsuarioCreacionAuditoria,FechaCreacionAuditoria,IdUsuarioActualizacionAuditoria,FechaActualizacionAuditoria,
-- -- EstadoAuditoria,Clave,FgTramiteVirtual,NumeroExpedienteExterno,FgTramiteVirtualPide,NombreExpediente,NumeroRucDniRemitente,RazonSocialNombreRemitente,
-- -- NumeroContratoRemitente,DescripcionContratoRemitente)




-- insert into Tramite.Expediente
-- (IdExpediente,IdSerieDocumentalExpediente,IdProyectoComponente,IdExpedienteVinculado,IdCatalogoTipoPrioridad,IdCatalogoSituacionExpediente,
-- IdCatalogoSituacionNotificacionExpediente,IdCatalogoTipoMovimientoTramite,IdCatalogoTipoTramite,IdPeriodo,IdEmpresaCreador,IdAreaCreador,IdCargoCreador,
-- IdPersonaCreador,NombreCompletoCreador,NumeroExpediente,AsuntoExpediente,NTFechaExpediente,HoraExpediente,NumeroFoliosExpediente,ObservacionesExpediente,
-- NombreCompletoNoticado,EmailNotificacion,CelularNotificacion,TelefonoNotificacion,DireccionNotificacion,ExpedienteConfidencial,ExpedienteAnulado,
-- MotivoExpedienteAnulado,NFechaAnulacionExpediente,HoraAnulacionExpediente,ExpedienteArchivado,FechaExpedienteArchivado,HoraExpedienteArchivado,
-- IdUsuarioUltimoExpedienteArchivado,IdUsuarioCreacionAuditoria,FechaCreacionAuditoria,IdUsuarioActualizacionAuditoria,FechaActualizacionAuditoria,
-- EstadoAuditoria,Clave,FgTramiteVirtual,NumeroExpedienteExterno,FgTramiteVirtualPide,NumeroRucDniRemitente,RazonSocialNombreRemitente,
-- NumeroContratoRemitente,DescripcionContratoRemitente)
-- select
--     IdExpediente,IdSerieDocumentalExpediente,IdProyectoComponente,IdExpedienteVinculado,IdCatalogoTipoPrioridad,IdCatalogoSituacionExpediente,
--     IdCatalogoSituacionNotificacionExpediente,IdCatalogoTipoMovimientoTramite,IdCatalogoTipoTramite,IdPeriodo,IdEmpresaCreador,IdAreaCreador,IdCargoCreador,
--     IdPersonaCreador,NombreCompletoCreador,NumeroExpediente,AsuntoExpediente,NTFechaExpediente,HoraExpediente,NumeroFoliosExpediente,ObservacionesExpediente,
--     NombreCompletoNoticado,EmailNotificacion,CelularNotificacion,TelefonoNotificacion,DireccionNotificacion,ExpedienteConfidencial,ExpedienteAnulado,
--     MotivoExpedienteAnulado,NFechaAnulacionExpediente,HoraAnulacionExpediente,ExpedienteArchivado,FechaExpedienteArchivado,HoraExpedienteArchivado,
--     IdUsuarioUltimoExpedienteArchivado,IdUsuarioCreacionAuditoria,FechaCreacionAuditoria,IdUsuarioActualizacionAuditoria,FechaActualizacionAuditoria,
--     EstadoAuditoria,Clave,FgTramiteVirtual,NumeroExpedienteExterno,FgTramiteVirtualPide,NumeroRucDniRemitente,RazonSocialNombreRemitente,
--     NumeroContratoRemitente,DescripcionContratoRemitente
-- from Tramite.Expediente_Historico_2028

-- set identity_insert Tramite.Expediente off;



-- set identity_insert Tramite.ExpedienteDocumento on;

-- select @vSql = null
-- select @vSql = N'\
-- insert into Tramite.ExpedienteDocumento
-- (IdExpedienteDocumento,IdExpediente,IdCatalogoTipoDocumento,IdCatalogoTipoMovimientoDocumento,IdEmpresaEmisor,IdAreaEmisor,IdCargoEmisor,IdPersonaEmisor,
-- NombreCompletoEmisor,NumeroDocumento,Correlativo,CorrelativoLetra,NumeroFoliosDocumento,
-- AsuntoDocumento,NFechaDocumento,RutaArchivoDocumento,ObservacionesDocumento,IdUsuarioCreacionAuditoria,FechaCreacionAuditoria,IdUsuarioActualizacionAuditoria,
-- FechaActualizacionAuditoria,EstadoAuditoria,EsVinculado,
-- CorrelativoVinculado,IdExpedientePreviaVinculacion,ObservacionesVinculacion,FgEsObservado,FgEsCorregido,RutaArchivoDocumentoCorregido,NFechaDocumentoCorregido,
-- HoraDocumentoCorregido,DescripcionCorreccion,DescripcionObervacionIngresada,
-- IdExpedienteVirtual,FgDocumentoVirtualEnviado,FgEnvioCorregido,FechaHoraFirmaDigital,FgEsObligatorioFirmaDigital,FlagParaDespacho,FgEnEsperaFirmaDigital,
-- fgFirmaDigitalExterno,FechaEnvioDocumentoCorregido,
-- LinkArchivoCompartido,FechaEnvioDocumento,IdCatalogoTipoOrigen,IdCatalogoTipoDocumentoCopia,NumeroDocumentoCopia,AsuntoDocumentoCopia,NombreCompletoEmisorCopia,
-- EnProcesoFirma,IdUsuarioEnProcesoFirma,CuoPide,FgGeneradoPorExterno,FgActivoExterno)
-- select*from Tramite.ExpedienteDocumento_Historico_'+ @vperiodo


-- exec sp_executesql @vSql


-- set identity_insert Tramite.ExpedienteDocumento off;




-- set identity_insert Tramite.ExpedienteDocumentoOrigen on;

-- select @vSql = null
-- select @vSql = N'\
-- insert into Tramite.ExpedienteDocumentoOrigen
-- (IdExpedienteDocumentoOrigen,IdExpedienteDocumento,NumeroDiasAtencionSolicitado,IdCatalogoSituacionMovimientoOrigen,IdCatalogoTipoMovimientoOrigen,
-- IdEmpresaOrigenEnvia,IdAreaOrigenEnvia,IdCargoOrigenEnvia,IdPersonaOrigenEnvia,IdEmpresaOrigen,IdAreaOrigen,
-- IdCargoOrigen,IdPersonaOrigen,NombreCompletoOrigen,IdCatalogoTipoDevolucion,Descripciondevolucion,FechaOrigen,HoraOrigen,ConCargoFisico,RutaArchiCargoFisico,
-- FechaCargoFisico,HoraCargoFisico,IdEmpresaCargoFisico,IdAreaCargoFisico,
-- IdCargoCargoFisico,IdPersonaCargoFisico,EsCabecera,EsVinculado,IdUsuarioCreacionAuditoria,FechaCreacionAuditoria,IdUsuarioActualizacionAuditoria,
-- FechaActualizacionAuditoria,EstadoAuditoria,FgGeneradoPorExterno,FgActivoExterno)
-- select*from Tramite.ExpedienteDocumentoOrigen_Historico_'+ @vperiodo


-- exec sp_executesql @vSql


-- set identity_insert Tramite.ExpedienteDocumentoOrigen off;





-- set identity_insert Tramite.ExpedienteDocumentoOrigenDestino on;


-- select @vSql = null
-- select @vSql = N'\
-- insert into Tramite.ExpedienteDocumentoOrigenDestino
-- (IdExpedienteDocumentoOrigenDestino,IdExpedienteDocumentoOrigen,IdExpedienteDocumentoOrigenDestinoAnterior,IdExpedienteDocumentoOrigenAnterior,
-- IdCatalogoSituacionMovimientoDestino,IdCatalogoTipoMovimientoDestino,EsInicial,NumeroDiasAtencionSolicitado,
-- NumeroDiasAtencionAceptado,Original,Copia,FechaDestino,HoraDestino,IdEmpresaDestino,IdAreaDestino,IdCargoDestino,IdPersonaDestino,IdEmpresaDestinoAtencion,
-- IdAreaDestinoAtencion,IdCargoDestinoAtencion,IdPersonaDestinoAtencion,IdEmpresaDestinoRecepciona,IdAreaDestinoRecepciona,
-- IdCargoDestinoRecepciona,IdPersonaDestinoRecepciona,FechaDestinoRecepciona,HoraDestinoRecepciona,FechaDestinoEnvia,HoraDestinoEnvia,IdEstanteArchivador,
-- MotivoArchivado,FechaArchivado,HoraArchivado,ObservacionesDestinatario,IdUsuarioCreacionAuditoria,FechaCreacionAuditoria,IdUsuarioActualizacionAuditoria,
-- FechaActualizacionAuditoria,EstadoAuditoria,DestinatarioDestinoRecepciona,DestinatarioDestinoAtencion,DestinatarioDestino)
-- select*from Tramite.ExpedienteDocumentoOrigenDestino_Historico_'+ @vperiodo


-- exec sp_executesql @vSql


-- set identity_insert Tramite.ExpedienteDocumentoOrigenDestino off;




-- set identity_insert Tramite.ExpedienteDevuelto on;


-- select @vSql = null
-- select @vSql = N'\
-- insert into Tramite.ExpedienteDevuelto
-- (IdExpedienteDevuelto,IdExpediente,FechaHoraDevolucion,DescripcionDevolucion,IdUsuarioCreacionAuditoria,FechaCreacionAuditoria,IdUsuarioActualizacionAuditoria,
-- FechaActualizacionAuditoria,EstadoAuditoria,RutaArchivoDocumentoDevuelto)
-- select*from Tramite.ExpedienteDevuelto_Historico_'+ @vperiodo


-- exec sp_executesql @vSql



-- set identity_insert Tramite.ExpedienteDevuelto off;



-- set identity_insert Tramite.ExpedienteEnlazado on;

-- select @vSql = null
-- select @vSql = N'\
-- insert into Tramite.ExpedienteEnlazado
-- (IdExpedienteEnlazado,IdExpediente,IdExpedienteSecundario,Activo,IdUsuarioCreacionAuditoria,FechaCreacionAuditoria,IdUsuarioActualizacionAuditoria,
-- FechaActualizacionAuditoria,EstadoAuditoria)
-- select*from Tramite.ExpedienteEnlazado_Historico_'+ @vperiodo


-- exec sp_executesql @vSql


-- set identity_insert Tramite.ExpedienteEnlazado off;



-- set identity_insert Tramite.ExpedienteSeguimiento on;


-- select @vSql = null
-- select @vSql = N'\
-- insert into Tramite.ExpedienteSeguimiento
-- (IdExpedienteSeguimiento,IdExpediente,IdEmpresa,IdArea,IdCargo,IdPersona,IdUsuarioCreacionAuditoria,FechaCreacionAuditoria,IdUsuarioActualizacionAuditoria,
-- FechaActualizacionAuditoria,EstadoAuditoria)
-- select*from Tramite.ExpedienteSeguimiento_Historico_'+ @vperiodo


-- exec sp_executesql @vSql


-- set identity_insert Tramite.ExpedienteSeguimiento off;



-- set identity_insert Tramite.NumeracionSeparada on;

-- select @vSql = null
-- select @vSql = N'\
-- insert into Tramite.NumeracionSeparada
-- (IdNumeracionSeparada,IdArea,IdCatalogoTipoDocumento,Correlativo,NumeroDocumento,Usado,IdUsuarioCreacionAuditoria,FechaCreacionAuditoria,
-- IdUsuarioActualizacionAuditoria,FechaActualizacionAuditoria,EstadoAuditoria,IdPeriodo)
-- select*from Tramite.NumeracionSeparada_Historico_'+ @vperiodo


-- exec sp_executesql @vSql


-- set identity_insert Tramite.NumeracionSeparada off;




-- set identity_insert Tramite.ExpedienteDocumentoFirmante on;

-- select @vSql = null
-- select @vSql = N'\
-- insert into Tramite.ExpedienteDocumentoFirmante
-- (IdExpedienteDocumentoFirmante,CodigoGuidTemporal,IdExpedienteDocumento,IdEmpresa,IdArea,IdCargo,IdPersona,NombreCompleto,IdEmpleadoPerfilFirmante,
-- IdCatalogoTipoFirmante,FlagFirmado,FechaHoraFirmado,PosicionX,PosicionY,IdCatalogoMotivoFirma,
-- IdUsuarioCreacionAuditoria,FechaCreacionAuditoria,IdUsuarioActualizacionAuditoria,FechaActualizacionAuditoria,EstadoAuditoria,FirmadoIndependiente)
-- select*from Tramite.ExpedienteDocumentoFirmante_Historico_'+ @vperiodo


-- exec sp_executesql @vSql



-- set identity_insert Tramite.ExpedienteDocumentoFirmante off;




-- set identity_insert Tramite.ExpedienteDocumentoAdjunto on;


-- select @vSql = null
-- select @vSql = N'\
-- insert into Tramite.ExpedienteDocumentoAdjunto
-- (IdExpedienteDocumentoAdjunto,IdExpedienteDocumento,IdCatalogoTipoAdjunto,DescripcionDocumentoAdjunto,RutaArchivoDocumentoAdjunto,IdUsuarioCreacionAuditoria,
-- FechaCreacionAuditoria,IdUsuarioActualizacionAuditoria,FechaActualizacionAuditoria,EstadoAuditoria,
-- EnProcesoFirma,FechaHoraFirmaDigital,IdUsuarioEnProcesoFirma,FgEsObligatorioFirmaDigital,FgEnEsperaFirmaDigital)
-- select*from Tramite.ExpedienteDocumentoAdjunto_Historico_'+ @vperiodo


-- exec sp_executesql @vSql



-- set identity_insert Tramite.ExpedienteDocumentoAdjunto off;



-- set identity_insert Tramite.ExpedienteDocumentoAdjuntoFirmante on;

-- select @vSql = null
-- select @vSql = N'\
-- insert into Tramite.ExpedienteDocumentoAdjuntoFirmante
-- (IdExpedienteDocumentoAdjuntoFirmante,IdExpedienteDocumentoAdjunto,CodigoGuidTemporal,IdExpedienteDocumento,IdEmpresa,IdArea,IdCargo,IdPersona,
-- NombreCompleto,IdEmpleadoPerfilFirmante,IdCatalogoTipoFirmante,FlagFirmado,FechaHoraFirmado,PosicionX,PosicionY,IdCatalogoMotivoFirma,FirmadoIndependiente,
-- IdUsuarioCreacionAuditoria,FechaCreacionAuditoria,IdUsuarioActualizacionAuditoria,FechaActualizacionAuditoria,EstadoAuditoria)
-- select*from Tramite.ExpedienteDocumentoAdjuntoFirmante_Historico_'+ @vperiodo


-- exec sp_executesql @vSql


-- set identity_insert Tramite.ExpedienteDocumentoAdjuntoFirmante off;



-- set identity_insert Tramite.ExpedienteDocumentoAdjuntoTemporal on;



-- select @vSql = null
-- select @vSql = N'\
-- insert into Tramite.ExpedienteDocumentoAdjuntoTemporal
-- (IdExpedienteDocumentoAdjuntoTemporal,IdPadreTemporal,IdCatalogoTipoAdjunto,DescripcionDocumentoAdjunto,RutaArchivoDocumentoAdjunto,IdUsuarioCreacionAuditoria,
-- FechaCreacionAuditoria,IdUsuarioActualizacionAuditoria,FechaActualizacionAuditoria,EstadoAuditoria)
-- select*from Tramite.ExpedienteDocumentoAdjuntoTemporal_Historico_'+ @vperiodo


-- exec sp_executesql @vSql


-- set identity_insert Tramite.ExpedienteDocumentoAdjuntoTemporal off;



-- set identity_insert Tramite.ExpedienteDocumentoOrigenAdjunto on;



-- select @vSql = null
-- select @vSql = N'\
-- insert into Tramite.ExpedienteDocumentoOrigenAdjunto
-- (IdExpedienteDocumentoOrigenAdjunto,CodigoGuidTemporalEDO,IdExpedienteDocumentoOrigenEDO,IdCatalogoTipoAdjuntoEDO,DescripcionDocumentoAdjuntoEDO,
-- RutaArchivoDocumentoAdjuntoEDO,IdUsuarioCreacionAuditoria,FechaCreacionAuditoria,
-- IdUsuarioActualizacionAuditoria,FechaActualizacionAuditoria,EstadoAuditoria,FgActivoExterno)
-- select*from Tramite.ExpedienteDocumentoOrigenAdjunto_Historico_'+ @vperiodo


-- exec sp_executesql @vSql


-- set identity_insert Tramite.ExpedienteDocumentoOrigenAdjunto off;



-- set identity_insert Tramite.ExpedienteDocumentoOrigenDestinoAccion on;

-- select @vSql = null
-- select @vSql = N'\
-- insert into Tramite.ExpedienteDocumentoOrigenDestinoAccion
-- (IdExpedienteDocumentoOrigenDestinoAccion,IdExpedienteDocumentoOrigenDestino,IdCatalogoTipoAccion,IdUsuarioCreacionAuditoria,FechaCreacionAuditoria,
-- IdUsuarioActualizacionAuditoria,FechaActualizacionAuditoria,EstadoAuditoria)
-- select*from Tramite.ExpedienteDocumentoOrigenDestinoAccion_Historico_'+ @vperiodo


-- exec sp_executesql @vSql


-- set identity_insert Tramite.ExpedienteDocumentoOrigenDestinoAccion off;



-- set identity_insert Tramite.ExpedienteDocumentoOrigenDestinoTemporal on;

-- select @vSql = null
-- select @vSql = N'\
-- insert into Tramite.ExpedienteDocumentoOrigenDestinoTemporal
-- (IdExpedienteDocumentoOrigenDestinoTemporal,IdPadreTemporal,Original,Copia,ListaIdAccion,NumeroDiasAtencionSolicitado,CodigoDestinatario,Destinatario,
-- ObservacionesDestinatario,IdUsuarioCreacionAuditoria,FechaCreacionAuditoria,
-- IdUsuarioActualizacionAuditoria,FechaActualizacionAuditoria,EstadoAuditoria)
-- select*from Tramite.ExpedienteDocumentoOrigenDestinoTemporal_Historico_'+ @vperiodo


-- exec sp_executesql @vSql


-- set identity_insert Tramite.ExpedienteDocumentoOrigenDestinoTemporal off;



-- select concat(stuff((select ',',name from mastertable('Tramite.ExpedienteDocumentoOrigenDestinoTemporal')
-- where column_id > 10
-- for xml path, type).value('.','varchar(max)'),1,1,'('),')')
