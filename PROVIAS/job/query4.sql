-- ALTER PROCEDURE [Tramite].[paListarExpedientePendienteJefaturaV8FosCad]
declare
@pConFiltroFecha bit,
@pFechaInicio varchar(10),
@pFechaFin varchar(10),
@pConFiltroFechaMovimiento bit,
@pFechaInicioMovimiento varchar(10),
@pFechaFinMovimiento varchar(10),
@pIdArea int,
@pIdCatalogoSituacionMovimientoDestino INT,
@pTipoSituacionMovimiento int,
@pIdAreaOrigen int,
@pIdAreaDestino int,
@pIdPeriodo int,
@pIdCatalogoTipoPrioridad int,
@pIdCatalogoTipoTramite int,
@pIdCatalogoTipoDocumento int,
@pNumeroExpediente varchar(100),
@pNumeroDocumento varchar(100),
@pPersonaDesde varchar(100),
@pPersonaPara varchar(100),
@pIdTipoIngreso int,
@pFechaDocumento  varchar(100),
@pEmisorExpediente varchar(100),
@pAsuntoExpediente  varchar(100),
@pIdUsuarioAuditoria int,
@pCampoOrdenado varchar(50),
@pTipoOrdenacion varchar(4),
@pNumeroPagina INT,
@pDimensionPagina  INT,
@pBusquedaGeneral varchar(100),
@pFlgBusqueda int
-- AS
-- BEGIN
-- BEGIN TRY
set tran isolation level read uncommitted
set nocount on

-- SELECT
--     @pConFiltroFecha=0,
--     @pFechaInicio='19/05/2026',
--     @pFechaFin='19/05/2026',
--     @pConFiltroFechaMovimiento=1,
--     @pFechaInicioMovimiento='19/05/2026',
--     @pFechaFinMovimiento='19/05/2026',
--     @pIdArea=79,
--     @pIdCatalogoSituacionMovimientoDestino=5,
--     @pTipoSituacionMovimiento=4,
--     @pIdAreaOrigen=0,
--     @pIdAreaDestino=0,
--     @pIdPeriodo=2026,
--     @pIdCatalogoTipoPrioridad=0,
--     @pIdCatalogoTipoTramite=0,
--     @pIdCatalogoTipoDocumento=0,
--     @pNumeroExpediente='',
--     @pNumeroDocumento='',
--     @pPersonaDesde='',
--     @pPersonaPara='',
--     @pIdTipoIngreso=0,
--     @pFechaDocumento='',
--     @pEmisorExpediente='',
--     @pAsuntoExpediente='',
--     @pIdUsuarioAuditoria=349,
--     @pCampoOrdenado=NULL,
--     @pTipoOrdenacion=NULL,
--     @pNumeroPagina=1,
--     @pDimensionPagina=10,
--     @pBusquedaGeneral=NULL,
--     @pFlgBusqueda=0

SELECT
@pConFiltroFecha=0,
@pFechaInicio='19/05/2026',
@pFechaFin='19/05/2026',
@pConFiltroFechaMovimiento=1,
@pFechaInicioMovimiento='19/05/2026',
@pFechaFinMovimiento='19/05/2026',
@pIdArea=30,
@pIdCatalogoSituacionMovimientoDestino=5,
@pTipoSituacionMovimiento=4,
@pIdAreaOrigen=0,
@pIdAreaDestino=0,
@pIdPeriodo=2026,
@pIdCatalogoTipoPrioridad=0,
@pIdCatalogoTipoTramite=0,
@pIdCatalogoTipoDocumento=0,
@pNumeroExpediente='',
@pNumeroDocumento='',
@pPersonaDesde='',
@pPersonaPara='',
@pIdTipoIngreso=0,
@pFechaDocumento='',
@pEmisorExpediente='',
@pAsuntoExpediente='',
@pIdUsuarioAuditoria=53721,
@pCampoOrdenado=NULL,
@pTipoOrdenacion=NULL,
@pNumeroPagina=1,
@pDimensionPagina=10,
@pBusquedaGeneral=NULL,
@pFlgBusqueda=0

    DECLARE @vIdAreaJefe int= @pIdArea, @vIdEmpresaJefe int=2,
    @iRegistroTotal Int, @iPaginaRegInicio Int, @iPaginaRegFinal Int, @conBus int
    select @conBus = case when @pBusquedaGeneral is null or @pBusquedaGeneral = '' or isnumeric(@pBusquedaGeneral) = 0 then 1 else 0 end
    SET LANGUAGE SPANISH

    Create Table #vTablaExpediente(
        IdExpediente BigInt,
        FechaMovimiento Datetime,
        EsParaAnular int not null default(0),
        DiasPendiente int,
        NombrePersonaOrigen varchar(max) not null default (''),
        NumeroDocumento varchar(max),
        IdExpedienteDocumento int,
        eNroOrden Int);

    select t1.IdExpediente,
    t2.IdExpedienteDocumento, t2.Correlativo, t2.NumeroDocumento, t2.RutaArchivoDocumento,
    t4.FechaDestinoEnvia, t4.HoraDestinoEnvia, t4.FechaDestinoRecepciona, t4.MotivoArchivado, g.Descripcion
    into #tmp001_CabExpediente
    from Tramite.Expediente t1
    inner join Tramite.ExpedienteDocumento t2
        on  t2.IdExpediente = t1.IdExpediente
        and t2.EstadoAuditoria = 1
    inner join Tramite.ExpedienteDocumentoOrigen t3
        on  t3.IdExpedienteDocumento = t2.IdExpedienteDocumento
        and t3.EstadoAuditoria = 1
    inner join Tramite.ExpedienteDocumentoOrigenDestino t4
        on  t4.IdExpedienteDocumentoOrigen = t3.IdExpedienteDocumentoOrigen
        and t4.IdCatalogoSituacionMovimientoDestino=@pIdCatalogoSituacionMovimientoDestino
        and t4.IdEmpresaDestino= 2
        and t4.IdAreaDestino   = @pIdArea
        and t4.EstadoAuditoria = 1
    inner join General.Cargo c
        on  c.IdCargo = t4.IdCargoDestino
        and c.IdCatalogoTipoCargo in (32,33,34)
    left join Tramite.Catalogo g
        on  g.IdCatalogo = t2.IdCatalogoTipoDocumento
    where   t1.EstadoAuditoria   = 1
        and t1.ExpedienteAnulado = 0
        and (@conBus = 1 or t1.NumeroExpediente = @pBusquedaGeneral)

    ;with tmp001_expediente as(
        select
        row_number()over(partition by IdExpediente order by convert(datetime,fechadestinoEnvia+' '+horadestinoEnvia) desc,
        IdExpedienteDocumento desc) item,
        IdExpediente, IdExpedienteDocumento, Correlativo, NumeroDocumento, RutaArchivoDocumento,
        convert(datetime,fechadestinoEnvia+' '+horadestinoEnvia) FechaMovimiento, convert(date,FechaDestinoRecepciona) Fecha,
        MotivoArchivado, Descripcion
        from #tmp001_CabExpediente
    )
    select t.*, row_number()over(order by FechaMovimiento desc, IdExpedienteDocumento desc) eNroOrden into #tmp002_CabExpediente
    from(select*from tmp001_expediente where item = 1)t

    ;with tmp001_cabComp as(
        select grupo, cab1, cab2, cab3
        from(select 1, 5,
        '<button type="button" data-toggle="tooltip" title="xxx" class="btn ui blue label" onclick="MostrarDocumentoPdfExp(''',
        ')"><i style="font-size:16px;" class="fa fa-file-text"></i></button><label style="font-size:10px;line-height:13px;padding-top:6px;">',
        '</label>' union all
        select 2, 3,
        '<button type="button" data-toggle="tooltip" class="btn ui blue label" onclick="MostrarDocumentoPdfExp(''',
        ')"><i style="font-size:16px;" class="fa fa-file-text"></i></button><label style="font-size:8px;line-height:13px;padding-top:6px;">',
        '</label>' union all
        select 2, 6,
        '<button type="button" data-toggle="tooltip" class="btn ui blue label" onclick="MostrarDocumentoPdfExp(''',
        ')"><i style="font-size:16px;" class="fa fa-file-text"></i></button><label style="font-size:8px;line-height:13px;padding-top:6px;">',
        '</label>')t(grupo, item, cab1, cab2, cab3) where t.item = @pIdCatalogoSituacionMovimientoDestino
    )
    insert into #vTablaExpediente(
    IdExpediente, FechaMovimiento, DiasPendiente, NumeroDocumento, IdExpedienteDocumento, eNroOrden)
    select
        t.IdExpediente, t.FechaMovimiento,
        case tt.grupo when 1 then isnull(datediff(day, nullif(t.fecha,''), getdate()),0) when 2 then 0 end,
        case tt.grupo when 1 then concat(replace(tt.cab1,'xxx', isnull(t.MotivoArchivado,'')),
            t.RutaArchivoDocumento, ''',', IdExpedienteDocumento, tt.cab2,
            case t.Correlativo when 0 then concat(t.Descripcion, ' ', t.NumeroDocumento) else t.NumeroDocumento end, tt.cab3)
        when 2 then concat(tt.cab1, t.RutaArchivoDocumento, ''',', IdExpedienteDocumento, tt.cab2,
            case t.Correlativo when 0 then concat(t.Descripcion, ' ', t.NumeroDocumento) else t.NumeroDocumento end, tt.cab3)
        end, t.IdExpedienteDocumento, t.eNroOrden
    from #tmp002_CabExpediente t cross apply tmp001_cabComp tt

    select @iRegistroTotal = count(1) from #vTablaExpediente
    select @iPaginaRegInicio = c.iStartRow, @iPaginaRegFinal = c.iEndrow
	from General.fnObtenerPaginacion(@pDimensionPagina, @pNumeroPagina, @iRegistroTotal)c


-- select*from #vTablaExpediente


    -- select
        -- convert(varchar, @iRegistroTotal)+'¦'+
        -- (select STUFF((
                    SELECT
                        '¬'+convert(varchar,tE.EsParaAnular),
                        '|'+convert(varchar,tE.DiasPendiente),
                        '|'+tE.NombrePersonaOrigen,
                        '|'+replace(tE.NumeroDocumento,'|',''),
                        '|'+convert(varchar,tE.IdExpedienteDocumento),
                        '|'+CASE WHEN ENP.ExEnlazadoPri<>'' THEN ENP.ExEnlazadoPri else ENS.ExEnlazadoSec END,
                        '|'+CASE WHEN EE.cantEnlaces>0 THEN '1' ELSE '0' END,
                        '|'+OID.CatalogoTipoOrigen,
                        '|'+convert(varchar,E.IdExpediente),
                        '|'+convert(varchar,E.ExpedienteConfidencial),
                        '|'+E.NTFechaExpediente,
                        '|'+E.HoraExpediente,
                        '|'+convert(varchar,E.IdCatalogoTipoPrioridad),
                        '|'+COALESCE(CTP.Descripcion,''),
                        '|'+COALESCE(CTT.Descripcion,''),
                        '|'+COALESCE(CTT.Detalle,''),
                        '|'+US.Logueo,
                        '|'+case when COALESCE(SFU.RutaArchivoFoto,'') ='' then
                            CASE WHEN COALESCE(PE.Sexo,0)=0 then 'sinfotoH.jpg' else 'sinfotoM.jpg' end else SFU.RutaArchivoFoto end,
                        '|'+replace(UPPER(E.AsuntoExpediente),'|',' '),
                        '|'+convert(varchar,COALESCE(E.NumeroFoliosExpediente,0)),
                        '|'+COALESCE(replace(E.ObservacionesExpediente,'|',' '),''),
                        '|'+CONCAT(E.NTFechaExpediente ,' ', E.HoraExpediente),
                        '|'+E.NombreExpediente,
                        '|'+CASE WHEN COALESCE(E.NombreCompletoCreador,'')<>'' THEN COALESCE(E.NombreCompletoCreador,'') ELSE PE.NombreCompleto END,
                        '|'+convert(varchar,E.NumeroExpediente),
                        '|'+convert(varchar,COALESCE(ES.IdExpedienteSeguimiento, 0 )),
                        '|'+isnull(FORMAT(tE.FechaMovimiento, 'dd/MM/yyyy HH:mm'),'')
                    FROM #vTablaExpediente tE
                INNER JOIN Tramite.Expediente E  ON tE.IdExpediente=E.IdExpediente
                INNER JOIN Seguridad.Usuario US ON US.IdUsuario=E.IdUsuarioCreacionAuditoria
                INNER JOIN Tramite.Catalogo CTP ON CTP.IdCatalogo=E.IdCatalogoTipoPrioridad
                INNER JOIN Tramite.Catalogo CTT ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
                LEFT JOIN General.Persona PE ON PE.IdPersona=E.IdPersonaCreador
                OUTER APPLY(
                    SELECT TOP 1 FU.RutaArchivoFoto
                    FROM Seguridad.Usuario FU
                    WHERE FU.IdPersona = PE.IdPersona
                        And FU.EstadoAuditoria=1
                        AND FU.Bloqueado=0
                    ORDER BY FU.RutaArchivoFoto DESC
                ) SFU
                LEFT JOIN Tramite.ExpedienteSeguimiento ES
                    ON ES.IdExpediente= E.IdExpediente
                    AND ES.EstadoAuditoria=1
                    AND ES.IdCargo=0
                    AND ES.IdPersona=0
                    AND ES.IdArea=@pIdArea
                CROSS APPLY(
                    SELECT count(ee.Idexpediente) cantEnlaces
                    FROM Tramite.ExpedienteEnlazado EE
                    where EE.IdExpedienteSecundario=E.IdExpediente And EE.IdExpediente=E.IdExpediente
                ) EE
                CROSS APPLY(
                    select top 1 CONCAT(coalesce(c.Descripcion,''),' ',E.NumeroExpedienteExterno) CatalogoTipoOrigen
                    from Tramite.ExpedienteDocumento ed1
                    INNER JOIN Tramite.Catalogo c on c.IdCatalogo=ed1.IdCatalogoTipoOrigen
                    where ed1.EstadoAuditoria=1 and ed1.IdExpediente=E.IdExpediente
                    order by ed1.IdExpedienteDocumento
                ) OID
                CROSS APPLY(
                    select isnull((select STUFF((
                    SELECT '<div style="margin: 2px;padding: 2px;" class="ui blue label">'+
                    E.NombreExpediente
                    +'</div>'
                    FROM Tramite.ExpedienteEnlazado EE
                    where EE.IdExpediente=E.IdExpediente
                    FOR XML PATH('')), 1, 0, '')),'') ExEnlazadoPri
                ) ENP
                CROSS APPLY(
                    select isnull((select STUFF((
                    SELECT '<div style="margin: 2px;padding: 2px;" class="ui blue label">'+
                    E.NombreExpediente
                    +'</div>'
                    FROM Tramite.ExpedienteEnlazado EE
                    WHERE EE.IdExpedienteSecundario=E.IdExpediente
                    FOR XML PATH('')), 1, 0, '')),'') ExEnlazadoSec
                ) ENS
                WHERE tE.eNroOrden Between @iPaginaRegInicio And @iPaginaRegFinal
                ORDER BY tE.eNroOrden ASC
         --    FOR XML PATH('')), 1, 1, '')
         -- )

-- END TRY
-- BEGIN CATCH
--     DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
--     SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarExpedientePendienteJefaturaV8',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
--     EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE, @pIdUsuarioAuditoria
-- END CATCH
-- END
-- GO
