ALTER PROCEDURE Tramite.paListarDocumentoOrigenDestinoHojaRuta_BusquedaGeneral_arq
	@pIdExpediente int,
	@pIdArea int,
	@pEsVinculado int,
	@pCorrelativoVinculado int,
	@pIdUsuarioAuditoria int,
	@pIdPeriodo int
AS
BEGIN
BEGIN TRY
SET LANGUAGE SPANISH
set nocount on
set tran isolation level read uncommitted

create table #tmp001_Expediente(
    IdExpediente int,
    CelularNotificacion varchar(100) collate database_default,
    EmailNotificacion varchar(100) collate database_default,
    NumeroExpediente int,
    NTFechaExpediente varchar(10) collate database_default,
    AbreviaturaSerieDocumentalExpediente varchar(10) collate database_default,
    IdPeriodo int,
    EsVinculado int,
    CorrelativoVinculado int,
    ObservacionesExpediente varchar(4000) collate database_default,
    IdExpedienteDocumento int,
    IdExpedienteDocumentoOrigenDestino int,
    IdExpedienteDocumentoOrigen int,
    IdCatalogoSituacionMovimientoDestino int,
    CatalogoSituacionMovimientoDestino varchar(400) collate database_default,
    IdCatalogoTipoMovimientoDestino int,
    CatalogoTipoMovimientoDestino varchar(400) collate database_default,
    IdCatalogoTipoDevolucion int,
    NumeroDiasAtencionSolicitado int,
    FechaDestinoRecepciona varchar(10) collate database_default,
    HoraDestinoRecepciona varchar(5) collate database_default,
    IdPersonaOrigen int,
    NombreCompletoOrigen varchar(100) collate database_default,
    NumeroDiasAtencionAceptado int,
    Original bit,
    Copia bit,
    FechaDestino varchar(10) collate database_default,
    HoraDestino varchar(5) collate database_default,
    FechaDestinoEnvia varchar(10) collate database_default,
    HoraDestinoEnvia varchar(5) collate database_default,
    DestinatarioDestino varchar(800) collate database_default,
    ObservacionesDestinatario varchar(4000) collate database_default,
    Acciones varchar(8000) collate database_default,
    CatalogoTipoDocumento varchar(400) collate database_default,
    NumeroDocumento varchar(601) collate database_default,
    AsuntoDocumento varchar(8000) collate database_default,
    RutaArchivoDocumento varchar(150) collate database_default,
    NumeroExpedienteExterno varchar(100) collate database_default,
    Correlativo int,
    IdEmpresaOrigen int,
    IdAreaOrigen int,
    IdCargoOrigen int,
    IdEmpresaDestino int,
    IdAreaDestino int,
    IdCargoDestino int,
    IdPersonaDestino int,
    IdEmpresaDestinoRecepciona int,
    IdAreaDestinoRecepciona int,
    IdCargoDestinoRecepciona int,
    IdPersonaDestinoRecepciona int,
    IdEmpresaDestinoAtencion int,
    IdAreaDestinoAtencion int,
    IdCargoDestinoAtencion int,
    IdPersonaDestinoAtencion int
)

    Declare @vSql nvarchar(max)
    declare @vAnno int = year(getdate()), @vItera int = 0, @vNuevoPeriodo int
	declare @vTotalItera int = @vAnno - @pIdPeriodo + 1
	declare @vcExpediente varchar(100) = 'select*from Tramite.Expediente'
	declare @vcExpedienteDocumento varchar(100) = 'select*from Tramite.ExpedienteDocumento'
	declare @vcExpedienteDocumentoOrigen varchar(100) = 'select*from Tramite.ExpedienteDocumentoOrigen'
	declare @vcExpedienteDocumentoOrigenDestino varchar(100) = 'select*from Tramite.ExpedienteDocumentoOrigenDestino'
	declare @vcExpedienteRpta Nvarchar(4000) = ''
	declare @vcExpedienteDocumentoRpta Nvarchar(4000) = ''
	declare @vcExpedienteDocumentoOrigenRpta Nvarchar(4000) = ''
	declare @vcExpedienteDocumentoOrigenDestinoRpta Nvarchar(4000) = ''
	while(@vItera < @vTotalItera)begin
	    select @vNuevoPeriodo = @pIdPeriodo + @vItera
		if(@vNuevoPeriodo = @vAnno) begin
		    select @vcExpedienteRpta+=@vcExpediente
            select @vcExpedienteDocumentoRpta+=@vcExpedienteDocumento
            select @vcExpedienteDocumentoOrigenRpta+=@vcExpedienteDocumentoOrigen
            select @vcExpedienteDocumentoOrigenDestinoRpta+=@vcExpedienteDocumentoOrigenDestino
		end else begin
			select @vcExpedienteRpta+=concat(@vcExpediente,'_historico_',@vNuevoPeriodo)
            select @vcExpedienteDocumentoRpta+=concat(@vcExpedienteDocumento,'_historico_',@vNuevoPeriodo)
            select @vcExpedienteDocumentoOrigenRpta+=concat(@vcExpedienteDocumentoOrigen,'_historico_',@vNuevoPeriodo)
            select @vcExpedienteDocumentoOrigenDestinoRpta+=concat(@vcExpedienteDocumentoOrigenDestino,'_historico_',@vNuevoPeriodo)
		end
		if(@vItera < @vTotalItera-1)begin
		   select @vcExpedienteRpta+=' union all '
           select @vcExpedienteDocumentoRpta+=' union all '
           select @vcExpedienteDocumentoOrigenRpta+=' union all '
           select @vcExpedienteDocumentoOrigenDestinoRpta+=' union all '
		end
	    select @vItera+=1
	end

    select @vSql = concat(N'\
    insert into #tmp001_Expediente SELECT \
    E.IdExpediente,E.CelularNotificacion,E.EmailNotificacion,E.NumeroExpediente,E.NTFechaExpediente,SD.AbreviaturaSerieDocumentalExpediente,E.IdPeriodo,ED.EsVinculado,ED.CorrelativoVinculado,ED.ObservacionesDocumento,ED.IdExpedienteDocumento,EDOD.IdExpedienteDocumentoOrigenDestino,EDOD.IdExpedienteDocumentoOrigen,EDOD.IdCatalogoSituacionMovimientoDestino,CSM.Descripcion,EDOD.IdCatalogoTipoMovimientoDestino,CTM.Descripcion,EDO.IdCatalogoTipodevolucion,EDOD.NumeroDiasAtencionSolicitado,\
    EDOD.FechaDestinoRecepciona,EDOD.HoraDestinoRecepciona,EDO.IdPersonaOrigen,EDO.NombreCompletoOrigen,EDOD.NumeroDiasAtencionAceptado,EDOD.Original,EDOD.Copia,EDOD.FechaDestino,EDOD.HoraDestino,EDOD.FechaDestinoEnvia,EDOD.HoraDestinoEnvia,EDOD.DestinatarioDestino,EDOD.ObservacionesDestinatario,Tramite.funMostrarAccionesPorDestinoSoloCodigos(EDOD.IdExpedienteDocumentoOrigenDestino),\
    CTD.Descripcion,ED.NumeroDocumento,ED.AsuntoDocumento,ED.RutaArchivoDocumento,E.NumeroExpedienteExterno,ED.Correlativo,EDO.IdEmpresaOrigen,EDO.IdAreaOrigen,EDO.IdCargoOrigen,EDOD.IdEmpresaDestino,EDOD.IdAreaDestino,EDOD.IdCargoDestino,EDOD.IdPersonaDestino,EDOD.IdEmpresaDestinoRecepciona,EDOD.IdAreaDestinoRecepciona,EDOD.IdCargoDestinoRecepciona,EDOD.IdPersonaDestinoRecepciona,EDOD.IdEmpresaDestinoAtencion,EDOD.IdAreaDestinoAtencion,EDOD.IdCargoDestinoAtencion,EDOD.IdPersonaDestinoAtencion \
	FROM (', @vcExpedienteRpta, N')E INNER JOIN (', @vcExpedienteDocumentoRpta, N')ED ON ED.IdExpediente=E.IdExpediente AND ED.EstadoAuditoria=1 INNER JOIN (', @vcExpedienteDocumentoOrigenRpta, N')EDO ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND EDO.EstadoAuditoria=1 INNER JOIN (', @vcExpedienteDocumentoOrigenDestinoRpta, N')EDOD ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen AND EDOD.EstadoAuditoria=1 \
	INNER JOIN Tramite.Catalogo CTD ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento INNER JOIN Tramite.Catalogo CSM ON CSM.IdCatalogo=EDOD.IdCatalogoSituacionMovimientoDestino INNER JOIN Tramite.Catalogo CTM ON CTM.IdCatalogo=EDOD.IdCatalogoTipoMovimientoDestino INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente \
	WHERE E.EstadoAuditoria=1 AND E.IdExpediente=@pIdExpediente AND isnull(ED.CorrelativoVinculado,0)=@pCorrelativoVinculado')

	EXEC sp_executesql @vSql,
	    N'@pIdExpediente int, @pCorrelativoVinculado int',
		@pIdExpediente = @pIdExpediente,
		@pCorrelativoVinculado = @pCorrelativoVinculado

	select
    t.IdExpediente,
    isnull(t.CelularNotificacion,'') CelularNotificacion,
    isnull(t.EmailNotificacion,'') EmailNotificacion,
    t.NumeroExpediente,
    isnull(t.NTFechaExpediente,'') NTFechaExpediente,
    CONCAT(t.AbreviaturaSerieDocumentalExpediente, RIGHT(1000000+t.NumeroExpediente,6), '-', t.IdPeriodo,CASE WHEN t.EsVinculado=1 THEN CONCAT('- V-',t.CorrelativoVinculado) else '' END)NombreExpediente,
    isnull(t.ObservacionesExpediente,'') ObservacionesExpediente,
    t.IdExpedienteDocumento,
    t.IdExpedienteDocumentoOrigenDestino,
    t.IdExpedienteDocumentoOrigen,
    t.IdCatalogoSituacionMovimientoDestino,
    t.CatalogoSituacionMovimientoDestino,
    t.IdCatalogoTipoMovimientoDestino,
    t.CatalogoTipoMovimientoDestino,
    isnull(t.IdCatalogoTipoDevolucion, 0) IdCatalogoTipoDevolucion,
    t.NumeroDiasAtencionSolicitado,
    isnull(t.FechaDestinoRecepciona,'') FechaDestinoRecepciona,
    isnull(t.HoraDestinoRecepciona,'') HoraDestinoRecepciona,
    isnull(EMO.NombreEmpresa, 'EXTERNO') NombreEmpresaOrigen,
    isnull(AO.NombreArea, '') NombreAreaOrigen,
    isnull(CO.NombreCargo, '') NombreCargoOrigen,
    CASE WHEN t.IdPersonaOrigen = 0 THEN ISNULL(t.NombreCompletoOrigen, '') ELSE COALESCE(NULLIF(t.NombreCompletoOrigen, ''), PO.NombreCompleto, '')END NombrePersonaOrigen,
    t.NumeroDiasAtencionAceptado,
    t.Original,
    t.Copia,
    t.FechaDestino,
    t.HoraDestino,
    isnull(t.FechaDestinoEnvia,'') FechaDestinoEnvia,
    isnull(t.HoraDestinoEnvia,'') HoraDestinoEnvia,
    isnull(EMD.NombreEmpresa,'') NombreEmpresaDestino,
    isnull(AD.NombreArea,'') NombreAreaDestino,
    isnull(CD.NombreCargo,'') NombreCargoDestino,
    isnull(PD.NombreCompleto, t.DestinatarioDestino) NombrePersonaDestino,
    isnull(EMR.NombreEmpresa, 'EXTERNO') NombreEmpresaDestinoRecepciona,
    isnull(AR.NombreArea,'') NombreAreaDestinoRecepciona,
    isnull(CR.NombreCargo,'') NombreCargoDestinoRecepciona,
    isnull(PR.NombreCompleto,'') NombrePersonaDestinoRecepciona,
    isnull(EMA.NombreEmpresa, 'EXTERNO') NombreEmpresaDestinoAtencion,
    isnull(AA.NombreArea, '') NombreAreaDestinoAtencion,
    isnull(CA.NombreCargo, '') NombreCargoDestinoAtencion,
    isnull(PA.NombreCompleto, '') NombrePersonaDestinoAtencion,
    isnull(t.ObservacionesDestinatario, '') ObservacionesDestinatario,
    t.Acciones,
    isnull(t.CatalogoTipoDocumento, '')CatalogoTipoDocumento,
    case t.Correlativo when 0 then concat(t.CatalogoTipoDocumento,' ', t.NumeroDocumento) else t.NumeroDocumento end NumeroDocumento,
    isnull(t.AsuntoDocumento,'') AsuntoDocumento,
    isnull(t.RutaArchivoDocumento,'') RutaArchivoDocumento,
    isnull(t.NumeroExpedienteExterno,'') NumeroExpedienteExterno
from #tmp001_Expediente t
    LEFT JOIN General.Empresa EMO ON EMO.IdEmpresa=t.IdEmpresaOrigen
    LEFT JOIN General.Area AO ON AO.IdArea= t.IdAreaOrigen
    LEFT JOIN General.Cargo CO ON CO.IdCargo=t.IdCargoOrigen
    LEFT JOIN General.Empresa EMD ON EMD.IdEmpresa=t.IdEmpresaDestino
    LEFT JOIN General.Area AD ON AD.IdArea= t.IdAreaDestino
    LEFT JOIN General.Cargo CD ON CD.IdCargo=t.IdCargoDestino
    LEFT JOIN General.Persona PD ON PD.IdPersona=t.IdPersonaDestino
    LEFT JOIN General.Persona PO ON PO.IdPersona=t.IdPersonaOrigen
    LEFT JOIN General.Empresa EMR ON EMR.IdEmpresa=t.IdEmpresaDestinoRecepciona
    LEFT JOIN General.Area AR ON AR.IdArea= t.IdAreaDestinoRecepciona
    LEFT JOIN General.Cargo CR ON CR.IdCargo=t.IdCargoDestinoRecepciona
    LEFT JOIN General.Persona PR ON PR.IdPersona=t.IdPersonaDestinoRecepciona
    LEFT JOIN General.Empresa EMA ON EMA.IdEmpresa=t.IdEmpresaDestinoAtencion
    LEFT JOIN General.Area AA ON AA.IdArea= t.IdAreaDestinoAtencion
    LEFT JOIN General.Cargo CA ON CA.IdCargo=t.IdCargoDestinoAtencion
    LEFT JOIN General.Persona PA ON PA.IdPersona=t.IdPersonaDestinoAtencion
ORDER BY convert(datetime,t.FechaDestino +' '+ t.HoraDestino)

END TRY
BEGIN CATCH
	DECLARE @ERROR_NUMBER INT
	DECLARE @ERROR_SEVERITY INT
	DECLARE @ERROR_STATE INT
	DECLARE @ERROR_PROCEDURE VARCHAR(MAX)
	DECLARE @ERROR_LINE INT
	DECLARE @ERROR_MESSAGE VARCHAR(MAX)
	SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE(),
	@ERROR_PROCEDURE='Tramite.paListarDocumentoOrigenDestinoHojaRuta_BusquedaGeneral_arq',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
END CATCH
END
GO


exec tramite.paListarDocumentoOrigenDestinoHojaRuta_BusquedaGeneral_arq
@pIdExpediente= 727733,
@pIdArea= 79,
@pEsVinculado= 0,
@pCorrelativoVinculado= 0,
@pIdUsuarioAuditoria= 349,
@pIdPeriodo= 2025


exec tramite.paListarDocumentoOrigenDestinoHojaRuta_BusquedaGeneral_arq
@pIdExpediente= 506364,
@pIdArea= 79,
@pEsVinculado= 0,
@pCorrelativoVinculado= 0,
@pIdUsuarioAuditoria= 349,
@pIdPeriodo= 2024



exec tramite.paListarDocumentoOrigenDestinoHojaRuta_BusquedaGeneral_arq
@pIdExpediente= 76958,
@pIdArea= 79,
@pEsVinculado= 0,
@pCorrelativoVinculado= 0,
@pIdUsuarioAuditoria= 349,
@pIdPeriodo= 2022



--I-091266-2025
--HOJA DE RUTA ACTUAL -> TRAE 8 FILAS
-- EXECUTE [Tramite].[paListarDocumentoOrigenDestinoHojaRutaV1] 727733,79,0,0,349

--HOJA DE RUTA CON ARQ -> TRAE SOLO 1 FILA
-- EXECUTE [Tramite].[paListarDocumentoOrigenDestinoHojaRuta_BusquedaGeneral_arq] 727733,79,0,0,349,2025
