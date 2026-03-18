-- CREATE PROCEDURE [Tramite].[paListarExpedienteMesaParteDespachadosV1]
declare
    @pIdArea int =116,
    @pIdUsuarioAuditoria int=56784,
    @pCampoOrdenado varchar(50) = null,
    @pTipoOrdenacion varchar(4) = null,
    @pNumeroPagina INT =1,
    @pDimensionPagina  INT =10,
    @pBusquedaGeneral varchar(100)=
    '000228'
-- ''

set tran isolation level read uncommitted
set language english

select @pBusquedaGeneral = cadena from tramite.udf_sanitizar(@pBusquedaGeneral)
Declare @pBusquedaGeneralfText Varchar(400)  = case @pBusquedaGeneral when '' then '' else  concat('"',@pBusquedaGeneral,'*"') end
declare @pBusquedaGeneralfText2 varchar(400) = case @pBusquedaGeneral when '' then 'x59dxyr12' else @pBusquedaGeneralfText end
Declare @iRegistroTotal Int, @iPaginaRegInicio Int, @iPaginaRegFinal Int

select @pNumeroPagina pNumeroPagina, @pDimensionPagina pDimensionPagina into #tmp001_paginacion

;with tmp001_text_expediente as(
    select [key]
    from containstable(tramite.Expediente, (AsuntoExpediente, NombreExpediente, NombreCompletoCreador), @pBusquedaGeneralfText2)
)
,tmp001_text_expediente_documento as(
    select [key]
    from containstable(tramite.ExpedienteDocumento, (NumeroDocumento), @pBusquedaGeneralfText2)
)
,tmp001_datos as(
    select top 5000
    row_number()over(order by t.FechaCreacionAuditoria desc) nroOrd,
    t.IdExpediente,
    tt.IdExpedienteDocumento,
    tt.IdCatalogoTipoDocumento,
    t.IdEmpresaCreador,
    t.IdAreaCreador,
    t.IdCargoCreador,
    t.IdPersonaCreador,
    t.IdCatalogoTipoTramite,
    t.IdCatalogoTipoPrioridad,
    t.NumeroFoliosExpediente,
    tt.CorrelativoVinculado,
    t.ExpedienteConfidencial,
    t.FgTramiteVirtual,
    tt.FechaCreacionAuditoria,
    tt.FechaActualizacionAuditoria,
    tt.FechaEnvioDocumento,
    t.NombreExpediente,
    t.RazonSocialNombreRemitente,
    t.NombreCompletoCreador,
    tt.NumeroDocumento,
    t.ObservacionesExpediente,
    t.AsuntoExpediente
    from tramite.Expediente t
    cross apply(select*from tramite.ExpedienteDocumento tt where tt.IdExpediente = t.IdExpediente)tt
    left join tmp001_text_expediente t1 on t1.[key] = t.IdExpediente
    left join tmp001_text_expediente_documento t2 on t2.[key] = tt.IdExpedienteDocumento
    where t.IdCatalogoSituacionExpediente = 63 and
    t.ExpedienteAnulado = 0 and t.EstadoAuditoria = 1  and tt.IdEmpresaEmisor = 0 and tt.EstadoAuditoria = 1 and
    (@pBusquedaGeneralfText = '' or not t1.[key] is null or not t2.[key] is null)
)
select
    row_number()over(order by t.nroOrd) nroOrd,
    t.IdExpediente,
    t.IdExpedienteDocumento,
    tt.IdExpedienteDocumentoOrigen,
    case count(1)over(partition by t.IdExpediente) when 1 then anula.paraAnular else 0 end ParaAnular,
    t.IdCatalogoTipoDocumento,
    t.IdEmpresaCreador,
    t.IdAreaCreador,
    t.IdCargoCreador,
    t.IdPersonaCreador,
    t.IdCatalogoTipoTramite,
    t.IdCatalogoTipoPrioridad,
    t.NumeroFoliosExpediente,
    nullif(t.CorrelativoVinculado, 0) CorrelativoVinculado,
    t.ExpedienteConfidencial,
    t.FgTramiteVirtual,
    t.FechaCreacionAuditoria,
    t.FechaActualizacionAuditoria,
    t.FechaEnvioDocumento,
    t.NombreExpediente,
    nullif(ltrim(rtrim(t.RazonSocialNombreRemitente)),'') RazonSocialNombreRemitente,
    isnull(t.NombreCompletoCreador, '') NombreCompletoCreador,
    e.NombreEmpresa,
    max(case ctg.pos when 1 then concat(c.descripcion, ' ', t.NumeroDocumento) end)over(partition by t.nroOrd) NumeroDocumento,
    max(case ctg.pos when 2 then c.descripcion end)over(partition by t.nroOrd) CatalogoTipoPrioridad,
    max(case ctg.pos when 3 then c.descripcion end)over(partition by t.nroOrd) CatalogoTipoTramite,
    g.NombreCargo,
    a.NombreArea,
    t.ObservacionesExpediente,
    nullif(ltrim(rtrim(t.AsuntoExpediente)), '') AsuntoExpediente
into #tmp001_salidaDatos
from tmp001_datos t
cross apply Tramite.ExpedienteDocumentoOrigen tt
cross apply(values(1, t.IdCatalogoTipoDocumento),(2, t.IdCatalogoTipoPrioridad),(3, t.IdCatalogoTipoTramite))ctg(pos, idCat)
cross apply tramite.udf_funParaAnularMesaParte(tt.IdExpedienteDocumentoOrigen)anula
outer apply(select*from Tramite.Catalogo c where not ctg.idCat is null and c.IdCatalogo = ctg.idCat)c
outer apply(select*from(values(1,'PROVIAS'),(2,'PROVIAS'))e(IdEmpresa,NombreEmpresa) where e.IdEmpresa = t.IdEmpresaCreador)e
outer apply(select*from General.Area a where a.IdArea = t.IdAreaCreador)a
outer apply(select*from General.Cargo g where g.IdCargo = t.IdCargoCreador)g
where t.IdExpedienteDocumento = tt.IdExpedienteDocumento and tt.EstadoAuditoria = 1 and tt.EsCabecera = 1
order by t.nroOrd

select @iRegistroTotal = count(1) from #tmp001_salidaDatos

SELECT @iPaginaRegInicio = c.iStartRow, @iPaginaRegFinal = c.iEndrow
FROM General.fnObtenerPaginacion(@pDimensionPagina, @pNumeroPagina, @iRegistroTotal) c


select
    t.nroOrd,
    t.IdExpediente,
    t.ExpedienteConfidencial,
    convert(varchar, isnull(t.FechaActualizacionAuditoria, t.FechaCreacionAuditoria), 103) NTFechaExpediente,
    convert(varchar, isnull(t.FechaActualizacionAuditoria, t.FechaCreacionAuditoria), 108) HoraExpediente,
    t.IdCatalogoTipoPrioridad,
    t.CatalogoTipoPrioridad,
    t.CatalogoTipoTramite,
    concat(isnull(t.RazonSocialNombreRemitente, t.NombreCompletoCreador), ': ',
    isnull(t.AsuntoExpediente, 'SIN ASUNTO')) AsuntoExpediente,
    t.NumeroFoliosExpediente,
    isnull(t.ObservacionesExpediente, '') ObservacionesExpediente,
    t.ParaAnular,
    isnull(t.NombreEmpresa,'EXTERNO') NombreEmpresaCreador,
    isnull(t.NombreArea, '') NombreAreaCreador,
    isnull(t.NombreCargo, '') NombreCargoCreador,
    isnull(t.RazonSocialNombreRemitente, t.NombreCompletoCreador) NombrePersonaCreador,
    concat(t.NombreExpediente, '-', t.CorrelativoVinculado) NombreExpediente,
    t.IdExpedienteDocumento,
    t.IdExpedienteDocumentoOrigen,
    t.NumeroDocumento,
    t.FgTramiteVirtual,
    t.FechaEnvioDocumento
from #tmp001_salidaDatos t
where t.nroOrd between @iPaginaRegInicio and @iPaginaRegFinal
order by t.nroOrd

select @iRegistroTotal



--    END TRY
--    BEGIN CATCH
	-- 	DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX) ,@ERROR_MESSAGE VARCHAR(MAX)
	-- 	SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarExpedienteMesaParteDespachadosV1',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	-- 	EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
	-- 	SELECT ERROR_MESSAGE()
	-- END CATCH
