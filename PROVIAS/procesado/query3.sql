if exists(select 1 from sys.sysobjects where id = object_id('[Tramite].[paListarExpedienteMesaParteDespachadosVirtualesV1_new]', 'p'))
drop procedure [Tramite].[paListarExpedienteMesaParteDespachadosVirtualesV1_new]
go
create PROCEDURE [Tramite].[paListarExpedienteMesaParteDespachadosVirtualesV1_new]
    @pIdUsuarioAuditoria int,
	@pCampoOrdenado varchar(50),
	@pTipoOrdenacion varchar(4),
	@pNumeroPagina INT,
	@pDimensionPagina  INT,
	@pBusquedaGeneral varchar(100)
as
begin
begin try
set tran isolation level read uncommitted
set nocount on
set language english

    Declare @iRegistroTotal Int, @iPaginaRegInicio Int, @iPaginaRegFinal Int
    Declare @pBusquedaGeneral_fulltext varchar(100) =(
    select case isnull(@pBusquedaGeneral,'') when '' then 'xdgpdw84x' else concat('"', cadena, '*"') end
    from tramite.fnUtilitario_sanitizar(@pBusquedaGeneral))

    ;with tmp001_text_expediente_documento as(
        select [key]
        from containstable(tramite.ExpedienteDocumento, (AsuntoDocumento, NumeroDocumento, NombreCompletoEmisor), @pBusquedaGeneral_fulltext)
    )
    ,tmp001_expediente as(
        select*from tramite.expediente
        where EstadoAuditoria = 1 and ExpedienteAnulado = 0 and IdPeriodo = year(getdate()) and
        IdCatalogoTipoMovimientoTramite = 13 and IdCatalogoSituacionExpediente = 62 and FgTramiteVirtual = 1
    )
    select row_number()over(order by FechaEnvioDocumento desc) eNroOrden, *
        into #tmp001_matriz
    from(select top 1 with ties
        t1.IdExpediente,
        t1.IdCatalogoTipoPrioridad,
        t1.IdEmpresaCreador,
        t1.IdAreaCreador,
        t1.IdCargoCreador,
        t1.IdPersonaCreador,
        t1.IdCatalogoTipoTramite,
        t1.NumeroFoliosExpediente,
        t2.FgEsObservado,
        t2.FgEnvioCorregido,
        t1.ExpedienteConfidencial,
        t2.FechaEnvioDocumento,
        t1.fechaCreacionAuditoria,
        t1.NombreExpediente,
        t1.RazonSocialNombreRemitente,
        t1.NombreCompletoCreador,
        t1.ObservacionesExpediente,
        t1.AsuntoExpediente
    from tmp001_expediente t1
    cross apply(select*from Tramite.ExpedienteDocumento t2
        where t2.IdExpediente = t1.IdExpediente and t2.EstadoAuditoria = 1 and
        t2.FgDocumentoVirtualEnviado = 1 and t2.FgEsObservado = 0 and t2.FgEnvioCorregido = 0)t2
    cross apply(select*from Tramite.ExpedienteDocumentoOrigen t3
        where t3.IdExpedienteDocumento = t2.IdExpedienteDocumento and t3.EstadoAuditoria = 1)t3
    outer apply(select*from Tramite.ExpedienteDocumentoOrigenDestino t4
        where t4.IdExpedienteDocumentoOrigen = t3.IdExpedienteDocumentoOrigen and t4.EstadoAuditoria = 1)t4
    left join tmp001_text_expediente_documento tfexp on tfexp.[key] = t2.IdExpedienteDocumento
    where t4.IdExpedienteDocumentoOrigenDestino is null and (isnull(@pBusquedaGeneral, '') = '' or not tfexp.[key] is null)
    order by row_number()over(partition by t1.IdExpediente order by t2.FechaEnvioDocumento desc))ma

    select @iRegistroTotal = count(1) from #tmp001_matriz
    select @iPaginaRegInicio = c.iStartRow, @iPaginaRegFinal = c.iEndrow
    from General.fnObtenerPaginacion(@pDimensionPagina, @pNumeroPagina, @iRegistroTotal)c

    ;with tmp001_catalogo as(
        select*from Tramite.Catalogo
    )
    select
        t.IdExpediente,
        t.ExpedienteConfidencial,
        convert(varchar, t.fechaCreacionAuditoria, 103) NTFechaExpediente,
        convert(char(5), t.fechaCreacionAuditoria, 108) HoraExpediente,
        t.IdCatalogoTipoPrioridad,
        isnull(c1.descripcion, '') CatalogoTipoPrioridad,
        isnull(c2.descripcion, '') CatalogoTipoTramite,
        concat(case isnull(t.RazonSocialNombreRemitente, '') when '' then isnull(t.NombreCompletoCreador, '') else t.RazonSocialNombreRemitente end,
        ': ', case isnull(t.AsuntoExpediente, '') when '' then 'SIN ASUNTO' else t.AsuntoExpediente end) AsuntoExpediente,
        t.NumeroFoliosExpediente,
        isnull(t.ObservacionesExpediente, '') ObservacionesExpediente,
        isnull(e.NombreEmpresa, 'EXTERNO') NombreEmpresaCreador,
        isnull(a.NombreArea, '') NombreAreaCreador,
        isnull(r.NombreCargo, '') NombreCargoCreador,
        case isnull(t.RazonSocialNombreRemitente, '') when '' then isnull(t.NombreCompletoCreador, '')
        else t.RazonSocialNombreRemitente end NombrePersonaCreador,
        t.NombreExpediente,
        isnull(t.FgEsObservado, 'false') FgParaEnvio,
        isnull(t.FgEsObservado, 'false') FgEsObservado,
        isnull(t.FgEnvioCorregido, 'false') FgEnvioCorregido,
        concat(convert(varchar, t.FechaEnvioDocumento, 103), ' ', convert(char(5), t.FechaEnvioDocumento, 108)) FechaEnvioDocumento
    from #tmp001_matriz t
    outer apply(select*from tmp001_catalogo c1 where c1.IdCatalogo = t.IdCatalogoTipoPrioridad)c1
    outer apply(select*from General.Empresa e where e.IdEmpresa = t.IdEmpresaCreador)e
    outer apply(select*from General.Area a where a.IdArea = t.IdAreaCreador)a
    outer apply(select*from General.Cargo r where r.IdCargo = t.IdCargoCreador)r
    outer apply(select*from General.Persona p where p.IdPersona = t.IdPersonaCreador)p
    outer apply(select*from tmp001_catalogo c2 where c2.IdCatalogo = t.IdCatalogoTipoTramite)c2
    where t.eNroOrden Between @iPaginaRegInicio and @iPaginaRegFinal
    order by t.eNroOrden

    select @iRegistroTotal

END TRY
BEGIN CATCH
	DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
	SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarExpedienteMesaParteDespachadosVirtualesV1',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
END CATCH
end
go

select concat(object_schema_name(object_id), '.', object_name(object_id)) sp, create_date from sys.procedures order by create_date desc
