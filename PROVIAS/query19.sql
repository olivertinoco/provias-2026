-- CREATE PROCEDURE [Tramite].[paListarExpedienteMesaParteDespachadosV1]
declare
    @pIdArea int =116,
    @pIdUsuarioAuditoria int=642,
    @pCampoOrdenado varchar(50) = null,
    @pTipoOrdenacion varchar(4) = null,
    @pNumeroPagina INT =1,
    @pDimensionPagina  INT =10,
    @pBusquedaGeneral varchar(100)= '000228'


-- set statistics xml on
-- set statistics io on
-- set statistics time on

set tran isolation level read uncommitted
set language english

select @pBusquedaGeneral = isnull(@pBusquedaGeneral, '')
select @pBusquedaGeneral = cadena from tramite.fnUtilitario_sanitizar(@pBusquedaGeneral)
Declare @pBusquedaGeneralfText Varchar(400)  = case @pBusquedaGeneral when '' then '' else  concat('"',@pBusquedaGeneral,'*"') end
declare @pBusquedaGeneralfText2 varchar(400) = case @pBusquedaGeneral when '' then 'x59dxyr12' else @pBusquedaGeneralfText end
Declare @iRegistroTotal Int, @iPaginaRegInicio Int, @iPaginaRegFinal Int

;with tmp001_text_expediente as(
    select [key]
    from containstable(tramite.Expediente, (AsuntoExpediente, NombreExpediente, NombreCompletoCreador), @pBusquedaGeneralfText2)
)
,tmp001_text_expediente_documento as(
    select [key]
    from containstable(tramite.ExpedienteDocumento, (NumeroDocumento), @pBusquedaGeneralfText2)
)
,tmp001_catalogo as(
    select*from Tramite.Catalogo
)
,tmp001_datos as(
    select top 1 with ties *
    from(select top 5000
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
    cross apply(select*from tramite.ExpedienteDocumento tt
        where tt.IdExpediente = t.IdExpediente and tt.EstadoAuditoria = 1 and tt.IdEmpresaEmisor = 0)tt
    left join tmp001_text_expediente t1 on t1.[key] = t.IdExpediente
    left join tmp001_text_expediente_documento t2 on t2.[key] = tt.IdExpedienteDocumento
    where t.IdCatalogoSituacionExpediente = 63 and t.ExpedienteAnulado = 0 and t.EstadoAuditoria = 1 and
    (@pBusquedaGeneralfText = '' or not t1.[key] is null or not t2.[key] is null)
    order by tt.IdExpediente desc)t
    order by row_number()over(partition by t.IdExpediente order by t.FechaCreacionAuditoria desc)
)
select
    row_number()over(order by t.FechaCreacionAuditoria desc) nroOrd, *
    into #tmp001_salidaDatos
    from(select top 1 with ties
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
    concat(c1.descripcion, ' ', t.NumeroDocumento) NumeroDocumento,
    c2.descripcion CatalogoTipoPrioridad,
    c3.descripcion CatalogoTipoTramite,
    g.NombreCargo,
    a.NombreArea,
    t.ObservacionesExpediente,
    nullif(ltrim(rtrim(t.AsuntoExpediente)), '') AsuntoExpediente
from tmp001_datos t
cross apply Tramite.ExpedienteDocumentoOrigen tt
cross apply tramite.fnExpediente_AnularMesaParte(tt.IdExpedienteDocumentoOrigen)anula
cross apply(select*from tmp001_catalogo c where c.IdCatalogo = t.IdCatalogoTipoDocumento)c1
cross apply(select*from tmp001_catalogo c where c.IdCatalogo = t.IdCatalogoTipoPrioridad)c2
outer apply(select*from tmp001_catalogo c where c.IdCatalogo = t.IdCatalogoTipoTramite)c3
outer apply(select*from(values(1,'PROVIAS'),(2,'PROVIAS'))e(IdEmpresa,NombreEmpresa) where e.IdEmpresa = t.IdEmpresaCreador)e
outer apply(select*from General.Area a where a.IdArea = t.IdAreaCreador)a
outer apply(select*from General.Cargo g where g.IdCargo = t.IdCargoCreador)g
where t.IdExpedienteDocumento = tt.IdExpedienteDocumento and tt.EstadoAuditoria = 1 and tt.EsCabecera = 1
order by row_number()over(partition by t.IdExpediente order by tt.FechaCreacionAuditoria desc))t
order by t.FechaCreacionAuditoria desc

select @iRegistroTotal = count(1) from #tmp001_salidaDatos
select @iPaginaRegInicio = c.iStartRow, @iPaginaRegFinal = c.iEndrow
from General.fnObtenerPaginacion(@pDimensionPagina, @pNumeroPagina, @iRegistroTotal) c

select
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


-- set statistics xml off
-- set statistics io off
-- set statistics time off
