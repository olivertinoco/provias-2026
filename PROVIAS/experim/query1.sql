if exists(select 1 from sys.sysobjects where id=object_id('Tramite.paListarExpedienteMesaParteDespachadosV1_new','p'))
drop procedure [Tramite].[paListarExpedienteMesaParteDespachadosV1_new]
go
create PROCEDURE Tramite.paListarExpedienteMesaParteDespachadosV1_new
    @pIdArea int,
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
set language english

Declare @iRegistroTotal Int, @iPaginaRegInicio Int, @iPaginaRegFinal Int, @IdCatalogo int = 63, @anno int = year(getdate())
create table #tmp001_paginacion (
    nroOrd int,
    IdExpediente int,
    IdExpedienteDocumento int
)

if @pBusquedaGeneral is not null and @pBusquedaGeneral != ''
begin
    create table #tmp001_fullText_exp    (IdExpediente int primary key)
    create table #tmp001_fullText_expDoc (IdExpedienteDocumento int primary key)
    select @pBusquedaGeneral = concat('"', cadena, '*"') from tramite.fnUtilitario_sanitizar(@pBusquedaGeneral)

    insert into #tmp001_fullText_exp
    select [key] from containstable(tramite.Expediente, (AsuntoExpediente, NombreExpediente, NombreCompletoCreador), @pBusquedaGeneral)
    insert into #tmp001_fullText_expDoc
    select [key] from containstable(tramite.ExpedienteDocumento, (NumeroDocumento), @pBusquedaGeneral)

    ;with tmp001_expediente as(
        select t.IdExpediente, t.EstadoAuditoria
        from tramite.Expediente t
        where t.EstadoAuditoria = 1 and t.ExpedienteAnulado = 0 and t.IdPeriodo = @anno
        and t.IdCatalogoSituacionExpediente = @IdCatalogo
    )
    ,tmp001_expedienteDocumento as(
        select t.IdExpedienteDocumento, t.IdExpediente, t.EstadoAuditoria, t.FechaCreacionAuditoria
        from tramite.ExpedienteDocumento t where t.IdEmpresaEmisor = 0 and t.EstadoAuditoria = 1
    )
    insert into #tmp001_paginacion
    select row_number()over(order by t.IdExpedienteDocumento desc), t.IdExpediente, t.IdExpedienteDocumento
    from(select row_number()over(partition by t.IdExpediente order by t.FechaCreacionAuditoria desc) item, t.IdExpediente, t.IdExpedienteDocumento
    from(select top 5000
        tt.IdExpediente,
        tt.IdExpedienteDocumento,
        tt.FechaCreacionAuditoria
    from tmp001_expediente t
    inner join tmp001_expedienteDocumento tt on tt.IdExpediente = t.IdExpediente and tt.EstadoAuditoria = t.EstadoAuditoria
    where exists(select 1 from #tmp001_fullText_exp p    where p.IdExpediente = t.IdExpediente)
    or exists(select 1 from #tmp001_fullText_expDoc p where p.IdExpedienteDocumento = tt.IdExpedienteDocumento)
    order by tt.FechaCreacionAuditoria desc)t)t where item = 1

end
else
    with tmp001_expediente as(
        select t.IdExpediente, t.EstadoAuditoria
        from tramite.Expediente t
        where t.EstadoAuditoria = 1 and t.ExpedienteAnulado = 0 and t.IdPeriodo = @anno
        and t.IdCatalogoSituacionExpediente = @IdCatalogo
    )
    ,tmp001_expedienteDocumento as(
        select t.IdExpedienteDocumento, t.IdExpediente, t.EstadoAuditoria, t.FechaCreacionAuditoria
        from tramite.ExpedienteDocumento t where t.IdEmpresaEmisor = 0 and t.EstadoAuditoria = 1
    )
    insert into #tmp001_paginacion
    select row_number()over(order by t.IdExpedienteDocumento desc), t.IdExpediente, t.IdExpedienteDocumento
    from(select row_number()over(partition by t.IdExpediente order by t.FechaCreacionAuditoria desc) item, t.IdExpediente, t.IdExpedienteDocumento
    from(select top 5000
        tt.IdExpediente,
        tt.IdExpedienteDocumento,
        tt.FechaCreacionAuditoria
    from tmp001_expediente t
    inner join tmp001_expedienteDocumento tt on tt.IdExpediente = t.IdExpediente and tt.EstadoAuditoria = t.EstadoAuditoria
    order by tt.FechaCreacionAuditoria desc)t)t where item = 1


    select @iRegistroTotal = count(1) from #tmp001_paginacion
    select @iPaginaRegInicio = c.iStartRow,
           @iPaginaRegFinal  = c.iEndrow
    from General.fnObtenerPaginacion(@pDimensionPagina, @pNumeroPagina, @iRegistroTotal) c


    ;with tmp001_ExpedienteDocumentoOrigen as(
        select t.IdExpedienteDocumentoOrigen, t.IdExpedienteDocumento
        from tramite.ExpedienteDocumentoOrigen t where t.EsCabecera = 1 and t.EstadoAuditoria = 1
    )
    ,tmp001_empresa as(
        select*from(values(1,'PROVIAS'),(2,'PROVIAS'))e(IdEmpresa,NombreEmpresa)
    )
    select
        t1.IdExpediente,
        t1.ExpedienteConfidencial,
        convert(varchar, isnull(t2.FechaActualizacionAuditoria, t2.FechaCreacionAuditoria), 103) NTFechaExpediente,
        convert(varchar, isnull(t2.FechaActualizacionAuditoria, t2.FechaCreacionAuditoria), 108) HoraExpediente,
        t1.IdCatalogoTipoPrioridad,
        c2.descripcion CatalogoTipoPrioridad,
        c3.descripcion CatalogoTipoTramite,
        concat(isnull(t1.RazonSocialNombreRemitente, t1.NombreCompletoCreador), ': ',
        isnull(t1.AsuntoExpediente, 'SIN ASUNTO')) AsuntoExpediente,
        t1.NumeroFoliosExpediente,
        isnull(t1.ObservacionesExpediente, '') ObservacionesExpediente,
        case count(1)over(partition by t1.IdExpediente) when 1 then anula.paraAnular else 0 end ParaAnular,
        isnull(e.NombreEmpresa,'EXTERNO') NombreEmpresaCreador,
        isnull(a.NombreArea, '') NombreAreaCreador,
        isnull(g.NombreCargo, '') NombreCargoCreador,
        isnull(t1.RazonSocialNombreRemitente, t1.NombreCompletoCreador) NombrePersonaCreador,
        concat(t1.NombreExpediente, '-', t2.CorrelativoVinculado) NombreExpediente,
        t2.IdExpedienteDocumento,
        t3.IdExpedienteDocumentoOrigen,
        concat(c1.descripcion, ' ', t2.NumeroDocumento) NumeroDocumento,
        t1.FgTramiteVirtual,
        t2.FechaEnvioDocumento
    from #tmp001_paginacion p
    inner join tramite.Expediente t1 on t1.IdExpediente = p.IdExpediente
    inner join tramite.ExpedienteDocumento t2 on t2.IdExpedienteDocumento = p.IdExpedienteDocumento
    inner join tmp001_ExpedienteDocumentoOrigen t3 on t3.IdExpedienteDocumento = t2.IdExpedienteDocumento
    inner join Tramite.Catalogo c1 on c1.IdCatalogo = t2.IdCatalogoTipoDocumento
    inner join Tramite.Catalogo c2 on c2.IdCatalogo = t1.IdCatalogoTipoPrioridad
    left join  Tramite.Catalogo c3 on c3.IdCatalogo = t1.IdCatalogoTipoTramite
    left join  tmp001_empresa e on e.IdEmpresa = t1.IdEmpresaCreador
    left join General.Area a on a.IdArea = t1.IdAreaCreador
    left join General.Cargo g on g.IdCargo = t1.IdCargoCreador
    outer apply(
        select case when count(1) > 0 then 0 else 1 end paraAnular
        from Tramite.ExpedienteDocumentoOrigenDestino o
        where o.FechaDestinoRecepciona is not null and o.FechaDestinoRecepciona != ''
        and o.IdExpedienteDocumentoOrigen = t3.IdExpedienteDocumentoOrigen
    )anula
    where p.nroOrd between @iPaginaRegInicio and @iPaginaRegFinal
    order by p.nroOrd

select @iRegistroTotal

END TRY
BEGIN CATCH
	DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX) ,@ERROR_MESSAGE VARCHAR(MAX)
	SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarExpedienteMesaParteDespachadosV1',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
	SELECT ERROR_MESSAGE()
END CATCH
end
go

select concat(object_schema_name(object_id), '.', object_name(object_id)) sp, create_date from sys.procedures order by create_date desc
