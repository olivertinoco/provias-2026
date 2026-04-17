declare @tablas varchar(max) ='\
Tramite.Descargadocumentoacerbodocumental|\
Tramite.paActivarRegistroDocumentoExpedienteV2_SIGO|\
Tramite.paActivarRegistroExpedienteIngresoTransportistaV2_SIGO|\
Tramite.paActualizarArchivoDocumentoExpedienteV2_SIGO|\
Tramite.paActualizarConcluido|\
Tramite.paActualizarDerivacionesTeso|\
Tramite.paActualizarDocumentoAdjuntoFirmado|\
Tramite.paActualizarDocumentoFirmado|\
Tramite.paActualizarDocumentoFirmadoMasivo|\
Tramite.paActualizarRegistroGestion|\
Tramite.paAgregarVistasValidador|\
Tramite.paAnularDerivacionRegistroDocumentoExpedienteV2_SIGO|\
Tramite.paAnularUltimoRegistroContenedorDocumentoExpedienteV2_SIGO|\
Tramite.paArchivarExpedienteDocumentoOrigenDestino|\
Tramite.paArchivosRepostorio|\
Tramite.paBuscarExpedienteViaticos|\
Tramite.paDerivarRegistroDocumentoExpedienteV2_SIGO|\
Tramite.paDesactivarRegistroDocumentoExpedienteV2_SIGO|\
Tramite.paDesactivarRegistroExpedienteIngresoTransportistaV2_SIGO|\
Tramite.paEnviarAlertaTramitesConPlazo|\
Tramite.paEnviarEmailEnvioExpedienteMesaParte|\
Tramite.paEnviarEmailEnvioExpedienteMesaParteProyectos|\
Tramite.paEnviarEmailPendientesInstitucion|\
Tramite.paEnviarEmailPendientesInstitucionLogistica|\
Tramite.paEnviarEmailPendientesPorArea|\
Tramite.paEnviarEmailPendientesPorPersona|\
Tramite.paEnviarMail|\
Tramite.paEnviarMailDocumentoExpediente|\
Tramite.paEnviarTramiteExpedienteVinculado|\
Tramite.paEnviarTramiteVirtualExpedienteGenerado|\
Tramite.paEnviarTramiteVirtualExpedienteMesaParte|\
Tramite.paGenerarNumeroExpedienteMesaParteAutomatico|\
Tramite.paGuardaExpedienteDocumentoOrigenDestinoExtornarTemp|\
Tramite.paGuardaExpedienteDocumentoPosterior|\
Tramite.paGuardarExpedienteDocumentoAdjuntoTemporal|\
Tramite.paGuardarExpedienteDocumentoOrigenDestinoTemp|\
Tramite.paGuardarNuevoExpedienteDocumentoJefatura|\
Tramite.paGuardarNuevoExpedienteDocumentoJefaturaVinculacion|\
Tramite.paGuardarReenviarExpedienteDocumentoEspecialista|\
Tramite.paGuardarReenviarExpedienteDocumentoEspecialistaSIGA|\
Tramite.paGuardarReenviarExpedienteDocumentoEspecialistaSIGA2|\
Tramite.paGuardarReenviarExpedienteDocumentoEspecialistaSIGA3|\
Tramite.paGuardarReenviarExpedienteDocumentoEspecialistaSIGA4|\
Tramite.paGuardarReenviarExpedienteDocumentoJefatura|\
Tramite.paGuardarReenviarExpedienteDocumentoJefaturaV1|\
Tramite.paGuardarRegistroExpedienteIngresoTransportistaV2_SIGO|\
Tramite.paGuardarRegistroExpedienteMesaParte|\
Tramite.paGuardarRegistroExpedienteMesaParteFisica|\
Tramite.paGuardarRegistroExpedienteMesaParteFisicaV1|\
Tramite.paGuardarRegistroExpedienteMesaParteFisicaV2|\
Tramite.paGuardarResponderExpedienteDocumentoEspecialistaV1|\
Tramite.paGuardarResponderExpedienteDocumentoJefatura|\
Tramite.paGuardarResponderExpedienteDocumentoJefaturaV2|\
Tramite.paGuardarResponderExpedienteDocumentoV2_SIGO|\
Tramite.paInsertarDerivacionEspecialistaContaSGDSIGA|\
Tramite.paInsertarDerivacionSGDSIGA|\
Tramite.paListarCarpetaDocumentosPorExpediente|\
Tramite.paListarCarpetaDocumentosPorExpedienteV2|\
Tramite.paListarComboAutocompleteDestinatariosEspecialista|\
Tramite.paListarComboAutocompleteDestinatariosJefatura|\
Tramite.paListarComboExpedienteDocumentoAdjuntoFirmante|\
Tramite.paListarDataSetExpedienteJefaturax|\
Tramite.paListarDocumentoHojaRuta|\
Tramite.paListarDocumentoOrigenDestinoHojaRuta|\
Tramite.paListarDocumentoPendienteEspecialista|\
Tramite.paListarDocumentoPendienteJefatura|\
Tramite.paListarDocumentosMGD|\
Tramite.paListarExpedienteBloqueado|\
Tramite.paListarExpedienteMesaParte|\
Tramite.paListarExpedienteMesaParteDespachados|\
Tramite.paListarExpedienteMesaParteDespachadosV1_new|\
Tramite.paListarExpedienteMesaParteDespachadosVirtuales|\
Tramite.paListarExpedienteMesaParteDespachadosVirtualesV1_new|\
Tramite.paListarExpedienteMesaParteVirtual|\
Tramite.paListarExpedienteMesaParteVirtual03022022|\
Tramite.paListarExpedienteMesaParteVirtualOLD|\
Tramite.paListarExpedienteMesaParteVirtualV1|\
Tramite.paListarExpedienteMesaParteVirtualV2|\
Tramite.paListarExpedientePendienteEspecialista|\
Tramite.paListarExpedientePendienteEspecialistaCreados_new|\
Tramite.paListarExpedientePendienteEspecialistaPorRecibir_CALIDAD|\
Tramite.paListarExpedientePendienteEspecialistaPorRecibir_new|\
Tramite.paListarExpedientePendienteEspecialistaV1|\
Tramite.paListarExpedientePendienteEspecialistaV2|\
Tramite.paListarExpedientePendienteEspecialistaV3|\
Tramite.paListarExpedientePendienteEspecialistaV4|\
Tramite.paListarExpedientePendienteEspecialistaV5|\
Tramite.paListarExpedientePendienteEspecialistaV6|\
Tramite.paListarExpedientePendienteJefatura|\
Tramite.paListarExpedientePendienteJefaturaPorRecibirFosCad_ia|\
Tramite.paListarExpedientePendienteJefaturaPorRecibirFosCad_new|\
Tramite.paListarExpedientePendienteJefaturaV1|\
Tramite.paListarExpedientePendienteJefaturaV2|\
Tramite.paListarExpedientePendienteJefaturaV3|\
Tramite.paListarExpedientePendienteJefaturaV4|\
Tramite.paListarExpedientePendienteJefaturaV5|\
Tramite.paListarExpedientePendienteJefaturaV6|\
Tramite.paListarExpedientePendienteJefaturaV7|\
Tramite.paListarExpedientePendienteJefaturaVY|\
Tramite.paListarExpedientePendienteReenvioMasivoJefatura|\
Tramite.paListarMisDocumentosGeneradosEspecialista|\
Tramite.paListarMisDocumentosGeneradosJefatura|\
Tramite.paListarPendienteFirmaDigitalEspecialista|\
Tramite.paListarPendienteFirmaDigitalJefatura|\
Tramite.paListarPendienteFirmaDigitalJefaturaV1|\
Tramite.paListarPendientesPorArea|\
Tramite.paListarReportePopUpPendientePorPersona|\
Tramite.paObtenerDocumentoEnviadoAfectados|\
Tramite.paObtenerNumeroDocumentoJefaturaV1|\
Tramite.paObtenerNumeroDocumentoV2_SIGO|\
Tramite.paReenviarConfirmacionEnviarTramiteVirtualExpedienteMesaParte|\
Tramite.paValidarProcesoFirma|\
Tramite.paValidarVistasValidador|\
Tramite.paVistasValidador_Validar'

select value tablas into #tmp001_tablas
from dbo.udf_split(@tablas, default)

declare @data varchar(max)='\
User8UIT|\
UserSIGANET|\
UserWEBSOC|\
usr_appmovil|\
u_repositorio|\
u_reportingservices|\
u_powerbi|\
u_SIGO|\
u_API'


select value usuarios into #tmp001_usuarios
from dbo.udf_split(@data, default)

select StoredProcedure, usuario into #tmp001_procedures
from(SELECT
    dp.name AS Usuario,
    concat(object_schema_name(o.object_id),'.', o.name) AS StoredProcedure,
    p.permission_name,
    p.state_desc
FROM sys.database_permissions p
INNER JOIN sys.objects o
    ON p.major_id = o.object_id
INNER JOIN sys.database_principals dp
    ON p.grantee_principal_id = dp.principal_id
INNER JOIN #tmp001_usuarios UU
    ON UU.usuarios = dp.name
WHERE o.type = 'P'
order by UU.usuarios, object_schema_name(o.object_id), StoredProcedure offset 0 rows
)t



select concat('if exists(select 1 from sys.sysobjects where id = object_id(''',
StoredProcedure, ''',''p'')) drop procedure ', StoredProcedure)
from #tmp001_procedures t
outer apply(select tablas from #tmp001_tablas tt where t.StoredProcedure = tt.tablas )tt
where tt.tablas is null
