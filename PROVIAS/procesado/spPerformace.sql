
if exists(select 1 from sys.sysobjects where id=object_id('tramite.fnUtilitario_sanitizar','if'))
drop function tramite.fnUtilitario_sanitizar
go
create function tramite.fnUtilitario_sanitizar(
    @texto varchar(1000)
)returns table as return(
select cadena =
    ltrim(rtrim(
    replace(
    replace(
    replace(
    replace(
    replace(
    replace(
    replace(
    replace(
    replace(
    replace(
    replace(
    isnull(@texto,''),
    '"',''),
    '''',''),
    '(',''),
    ')',''),
    '&',''),
    '|',''),
    '!',''),
    '-',''),
    char(9), ' '),
    char(10), ' '),
    char(13), ' ')
    ))
)
go




if exists(select 1 from sys.sysobjects where id=object_id('Tramite.paListarExpedienteMesaParteDespachadosV1_new','p'))
drop procedure [Tramite].[paListarExpedienteMesaParteDespachadosV1_new]
go
create PROCEDURE [Tramite].[paListarExpedienteMesaParteDespachadosV1_new]
    @pIdArea int,
    @pIdUsuarioAuditoria int,
    @pCampoOrdenado varchar(50),
    @pTipoOrdenacion varchar(4),
    @pNumeroPagina INT,
    @pDimensionPagina  INT,
    @pBusquedaGeneral varchar(100)
as
begin
	BEGIN TRY
	set nocount on
	set tran isolation level read uncommitted

		Declare
		@pBusquedaGeneralfText Varchar(400), @pBusquedaGeneralfTextLike Bit, @iRegistroTotal Int,
		@iPaginaRegInicio Int, @iPaginaRegFinal Int, @anno int = year(getdate())

        select @pBusquedaGeneral = RTrim(LTrim(@pBusquedaGeneral))
        Create Table #vTablaExpediente(IdExpediente BigInt, IdExpedienteDocumento BigInt, eNroOrden Int)

		IF @pBusquedaGeneral is not null and @pBusquedaGeneral != ''
			BEGIN
                select @pBusquedaGeneralfText = concat('"', cadena, '*"') from tramite.fnUtilitario_sanitizar(@pBusquedaGeneral)

				INSERT INTO #vTablaExpediente(IdExpediente, IdExpedienteDocumento, eNroOrden)
				SELECT
					SE.IdExpediente,
					SE.IdExpedienteDocumento,
					Row_Number() Over(Order By SE.FechaExpediente desc)
				FROM
					(
						SELECT Top 5000
							E.IdExpediente,
							ED.IdExpedienteDocumento,
							cast(concat(E.NTFechaExpediente, ' ', E.HoraExpediente) as datetime) As FechaExpediente
						FROM
							Tramite.Expediente E
							INNER JOIN Tramite.ExpedienteDocumento ED ON
							ED.IdExpediente=E.IdExpediente AND ED.EstadoAuditoria=1 AND ED.IdEmpresaEmisor=0
						WHERE
							E.EstadoAuditoria=1 And E.ExpedienteAnulado=0 AND E.IdPeriodo = @anno and  E.IdCatalogoSituacionExpediente=63
							And
							(
    			                CONTAINS(E.AsuntoExpediente, @pBusquedaGeneralfText) OR
    							CONTAINS(E.NombreExpediente, @pBusquedaGeneralfText) OR
    							CONTAINS(E.NombreCompletoCreador, @pBusquedaGeneralfText) OR
    							CONTAINS(ED.NumeroDocumento, @pBusquedaGeneralfText)
							)
						ORDER BY E.IdExpediente Desc
					) SE
			END
		ELSE
			INSERT INTO #vTablaExpediente(IdExpediente, IdExpedienteDocumento, eNroOrden)
			SELECT
				SE.IdExpediente,
				SE.IdExpedienteDocumento,
				Row_Number() Over(Order By SE.FechaExpediente desc)
			FROM
				(
					SELECT Top 5000
						E.IdExpediente,
						ED.IdExpedienteDocumento,
					cast(concat(E.NTFechaExpediente, ' ', E.HoraExpediente) as datetime) As FechaExpediente
					FROM
						Tramite.Expediente E
						INNER JOIN Tramite.ExpedienteDocumento ED  on
						ED.IdExpediente=E.IdExpediente AND ED.EstadoAuditoria=1 AND ED.IdEmpresaEmisor=0
					WHERE
						E.EstadoAuditoria=1	And E.ExpedienteAnulado=0 AND E.IdPeriodo = @anno and E.IdCatalogoSituacionExpediente=63
					ORDER BY E.IdExpediente Desc
				) SE


		Set @iRegistroTotal = (Select Count(1) From #vTablaExpediente)
		SELECT @iPaginaRegInicio = c.iStartRow,
			@iPaginaRegFinal = c.iEndrow
		FROM General.fnObtenerPaginacion(@pDimensionPagina, @pNumeroPagina, @iRegistroTotal) c


		;with tmp001_empresa as(
            select*from(values(1,'PROVIAS'),(2,'PROVIAS'))EMD(IdEmpresa,NombreEmpresa)
        )
        SELECT
            E.IdExpediente,
            E.ExpedienteConfidencial,
			CASE WHEN COALESCE(ED.CorrelativoVinculado,0)=0 THEN E.NTFechaExpediente
			ELSE CONVERT(VARCHAR(10),ISNULl(ED.FechaActualizacionAuditoria,ED.FechaCreacionAuditoria),103) END NTFechaExpediente,
			CASE WHEN COALESCE(ED.CorrelativoVinculado,0)=0 THEN E.HoraExpediente
			ELSE CONVERT(VARCHAR(5),ISNULl(ED.FechaActualizacionAuditoria,ED.FechaCreacionAuditoria),108) END HoraExpediente,
            E.IdCatalogoTipoPrioridad,
            CTP.Descripcion CatalogoTipoPrioridad,
            COALESCE(CTT.Descripcion,'') CatalogoTipoTramite,
			case when COALESCE(E.RazonSocialNombreRemitente,'')='' then COALESCE(NombreCompletoCreador,'')
			else  COALESCE(E.RazonSocialNombreRemitente,'') END +': '+CASE WHEN COALESCE(E.AsuntoExpediente,'')=''
			THEN 'SIN ASUNTO' ELSE E.AsuntoExpediente END AsuntoExpediente,
            E.NumeroFoliosExpediente,
            COALESCE(E.ObservacionesExpediente,'') ObservacionesExpediente,
			case count(1)over(partition by E.IdExpediente) when 1 then anula.paraAnular else 0 end ParaAnular,
            COALESCE(EMD.NombreEmpresa,'EXTERNO') NombreEmpresaCreador,
            COALESCE(AD.NombreArea,'') NombreAreaCreador,
            COALESCE(CD.NombreCargo,'') NombreCargoCreador,
			case when COALESCE(E.RazonSocialNombreRemitente,'')='' then COALESCE(NombreCompletoCreador,'')
			else  COALESCE(E.RazonSocialNombreRemitente,'') end NombrePersonaCreador,
            CONCAT(E.NombreExpediente,CASE WHEN COALESCE(ED.CorrelativoVinculado,0)=0 THEN ''
            ELSE '-' +CONVERT(VARCHAR,ED.CorrelativoVinculado) END) NombreExpediente,
            ED.IdExpedienteDocumento,EDO.IdExpedienteDocumentoOrigen,CONCAT(C.Descripcion,' ', ED.NumeroDocumento) NumeroDocumento,
			E.FgTramiteVirtual,
			ED.FechaEnvioDocumento
		FROM
			#vTablaExpediente EE
			inner join Tramite.Expediente E on E.IdExpediente=EE.IdExpediente
			inner join Tramite.ExpedienteDocumento ED
			    on ED.IdExpediente=E.IdExpediente AND ED.IdExpedienteDocumento = EE.IdExpedienteDocumento
			inner join Tramite.ExpedienteDocumentoOrigen EDO
			    on EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND EDO.EstadoAuditoria=1 AND EDO.EsCabecera=1
			inner join Tramite.Catalogo C on C.IdCatalogo = ED.IdCatalogoTipoDocumento
			inner join Tramite.Catalogo CTP on CTP.IdCatalogo = E.IdCatalogoTipoPrioridad
			left join Tramite.Catalogo CTT on CTT.IdCatalogo= E.IdCatalogoTipoTramite
			left join tmp001_empresa EMD on EMD.IdEmpresa = E.IdEmpresaCreador
			left join General.Area AD on AD.IdArea = E.IdAreaCreador
			left join General.Cargo CD on CD.IdCargo = E.IdCargoCreador
			left join General.Persona PD on PD.IdPersona = E.IdPersonaCreador
			left join (
    			SELECT IdExpedienteDocumentoOrigen, paraAnular
                FROM(SELECT o.IdExpedienteDocumentoOrigen,
                    CASE
                        WHEN COUNT(1) OVER(PARTITION BY o.IdExpedienteDocumentoOrigen) > 0
                        THEN 0
                        ELSE 1
                    END AS paraAnular,
                    ROW_NUMBER() OVER(
                        PARTITION BY o.IdExpedienteDocumentoOrigen
                        ORDER BY o.IdExpedienteDocumentoOrigen
                    ) AS rn
                    FROM Tramite.ExpedienteDocumentoOrigenDestino o WHERE o.FechaDestinoRecepciona IS NOT NULL
                ) x WHERE rn = 1
            ) anula ON anula.IdExpedienteDocumentoOrigen = EDO.IdExpedienteDocumentoOrigen
		WHERE EE.eNroOrden Between @iPaginaRegInicio And @iPaginaRegFinal
		ORDER BY EE.eNroOrden ASC

		SELECT @iRegistroTotal

    END TRY
    BEGIN CATCH
		DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX) ,@ERROR_MESSAGE VARCHAR(MAX)
		SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarExpedienteMesaParteDespachadosV1',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
		EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
		SELECT ERROR_MESSAGE()
	END CATCH
end
go



if exists(select 1 from sys.sysobjects where id = object_id('[Tramite].[paListarExpedientePendienteEspecialistaPorRecibir_new]','p'))
drop procedure [Tramite].[paListarExpedientePendienteEspecialistaPorRecibir_new]
go
CREATE PROCEDURE [Tramite].[paListarExpedientePendienteEspecialistaPorRecibir_new]
    @pConFiltroFecha bit,
	@pFechaInicio varchar(10),
	@pFechaFin varchar(10),
	@pConFiltroFechaMovimiento bit,
	@pFechaInicioMovimiento varchar(10),
	@pFechaFinMovimiento varchar(10),
	@pIdPersona int,
	@pIdEmpleadoPerfil int,
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
	@pFlgBusqueda INT
As
begin
begin try
set tran isolation level read uncommitted
set nocount on

create table #tmp001_expediente (
	IdExpediente int,
	ExpedienteConfidencial bit,
	NTFechaExpediente varchar (10),
	HoraExpediente varchar (5),
	IdCatalogoTipoPrioridad int,
	CatalogoTipoPrioridad varchar (100),
	CatalogoTipoTramite varchar (100),
	ColorCatalogoTipoTramite varchar (100),
	Logueo varchar (100),
	IdPersonaCreador int,
	AsuntoExpediente varchar (8000),
	NumeroFoliosExpediente int,
	ObservacionesExpediente varchar(4000),
	Fecha VARCHAR(20),
	NombreExpediente varchar (100),
	NombreCompletoCreador varchar (100),
	NumeroExpediente int,
	IdExpedienteSeguimiento int,
	NumeroExpedienteExterno varchar(100),
	FechaMovimiento datetime
)
create table #tmp001_matriz(
    IdExpediente int primary key,
    FechaMovimiento datetime
)
declare @anno int = year(getdate()), @vIdCargo int = 0, @vIdArea int = 0, @vIdEmpresa int = 2

select @vIdArea = t.IdArea, @vIdCargo = t.IdCargo, @pBusquedaGeneral = nullif(rtrim(ltrim(@pBusquedaGeneral)),'')
from RecursoHumano.EmpleadoPerfil t
where t.IdEmpresaSede = 1 and t.EstadoAuditoria = 1 and t.activo = 1 and t.IdEmpleadoPerfil = @pIdEmpleadoPerfil

if @pIdPersona > 0 and (try_convert(int, @pBusquedaGeneral) is not null or @pBusquedaGeneral is null) begin
    set language 'spanish'

    ;with tmp001_serieDocumental as(
        select*from(values(1,'E-'),(2,'I-'))sd(IdSerieDocumentalExpediente, AbreviaturaSerieDocumentalExpediente)
    )
    insert into #tmp001_matriz
    select top 1 with ties
        t1.IdExpediente, t4.fechaCreacionAuditoria
    from tramite.Expediente t1
    inner join tramite.ExpedienteDocumento t2
        on t2.idExpediente = t1.idExpediente and t2.EstadoAuditoria = 1 and t2.FgEnEsperaFirmaDigital = 0
    inner join tramite.ExpedienteDocumentoOrigen t3
        on t3.idExpedienteDocumento = t2.idExpedienteDocumento and t3.estadoAuditoria = 1
    inner join tramite.ExpedienteDocumentoOrigenDestino t4
        on t4.idExpedienteDocumentoOrigen = t3.idExpedienteDocumentoOrigen and t4.EstadoAuditoria = 1 and
            t4.IdPersonaDestino = @pIdPersona and
            t4.IdAreaDestino = @vIdArea and
            t4.IdCargoDestino = @vIdCargo and
            t4.IdEmpresaDestino = @vIdEmpresa and
            t4.IdCatalogoSituacionMovimientoDestino = 4
    inner join tmp001_serieDocumental sd on sd.IdSerieDocumentalExpediente = t1.IdSerieDocumentalExpediente
    where t1.estadoAuditoria = 1 and t1.ExpedienteAnulado = 0 and  t1.IdPeriodo = @anno and
            t1.NumeroExpediente = isnull(@pBusquedaGeneral, t1.NumeroExpediente)
    order by row_number()over(partition by t1.IdExpediente order by t4.fechaCreacionAuditoria desc)


    ;with tmp001_serieDocumental as(
        select*from(values(1,'E-'),(2,'I-'))sd(IdSerieDocumentalExpediente, AbreviaturaSerieDocumentalExpediente)
    )
    insert into #tmp001_expediente
    select
        t.IdExpediente,
        t.ExpedienteConfidencial,
        convert(varchar, m.FechaMovimiento, 103)  NTFechaExpediente,
        convert(char(5), m.FechaMovimiento, 108) HoraExpediente,
        t.IdCatalogoTipoPrioridad,
        c1.descripcion CatalogoTipoPrioridad,
        c2.descripcion CatalogoTipoTramite,
        c2.detalle ColorCatalogoTipoTramite,
        su.Logueo,
        t.IdPersonaCreador,
        t.AsuntoExpediente,
        t.NumeroFoliosExpediente,
        isnull(t.ObservacionesExpediente, '') ObservacionesExpediente,
        concat(convert(varchar, t.fechaCreacionAuditoria, 103), ' ', convert(char(5), t.fechaCreacionAuditoria, 108)) Fecha,
        CONCAT(SD.AbreviaturaSerieDocumentalExpediente, RIGHT(CONCAT('000000', t.NumeroExpediente),6), '-', t.IdPeriodo) NombreExpediente,
        isnull(t.NombreCompletoCreador, pe.NombreCompleto) NombreCompletoCreador,
        t.NumeroExpediente,
        isnull(es.IdExpedienteSeguimiento, 0) IdExpedienteSeguimiento,
        t.NumeroExpedienteExterno,
        m.FechaMovimiento
    from  tramite.Expediente t
    cross apply(select*from  #tmp001_matriz m  where m.idExpediente = t.idExpediente)m
    cross apply(select*from Seguridad.Usuario su where su.IdUsuario = t.IdUsuarioCreacionAuditoria and
        su.EstadoAuditoria = 1 and su.Bloqueado = 0)su
    cross apply(select*from tmp001_serieDocumental sd where sd.IdSerieDocumentalExpediente = t.IdSerieDocumentalExpediente)sd
    outer apply(select*from tramite.catalogo c1 where c1.IdCatalogo = t.IdCatalogoTipoPrioridad)c1
    outer apply(select*from Tramite.ExpedienteSeguimiento es
        where es.IdExpediente = t.IdExpediente and
        es.EstadoAuditoria = 1 and
        es.IdEmpresa = @vIdEmpresa and
        es.IdCargo = @vIdCargo and
        es.IdPersona = @pIdPersona and
        es.IdArea = @vIdArea
    )es
    outer apply(select*from General.Persona pe where pe.IdPersona = t.IdPersonaCreador)pe
    outer apply(select*from tramite.catalogo c2 where c2.IdCatalogo = t.IdCatalogoTipoTramite)c2
    order by m.FechaMovimiento desc
	OFFSET (@pNumeroPagina-1)*@pDimensionPagina ROWS
	FETCH NEXT @pDimensionPagina ROWS ONLY


select top 1 with ties
    convert(bit,case when pa1.cant>0 then 0 when pa2.cant>0 then 1 else 0 end) EsParaAnular,
    isnull(dp.DiasPendiente, 0) DiasPendiente,
    isnull(np.NombrePersonaOrigen,'') NombrePersonaOrigen,
    isnull(nd.NumeroDocumento,'') NumeroDocumento,
    ied.IdExpedienteDocumento,
    isnull(case when enp.ExEnlazadoPri != '' then replace(replace(enp.ExEnlazadoPri,'&lt;','<'),'&gt;','>')
    else replace(replace(ens.ExEnlazadoSec,'&lt;','<'),'&gt;','>') end, '') NombreExpedientesEnlazados,
    convert(bit, case when ee.cantEnlaces > 0 then 1 else 0 end) EsPrincipalEnlace,
    concat(c3.descripcion,' ', t.NumeroExpedienteExterno) CatalogoTipoOrigen,
    t.IdExpediente,
    t.ExpedienteConfidencial,
    t.NTFechaExpediente,
    t.HoraExpediente,
    t.IdCatalogoTipoPrioridad,
    t.CatalogoTipoPrioridad,
    t.CatalogoTipoTramite,
    t.ColorCatalogoTipoTramite,
    t.Logueo,
    iif(isnull(rfp.RutaArchivoFoto, '') = '', case when isnull(pe.sexo, 0) = 0 then 'sinfotoH.jpg' else 'sinfotoM.jpg' end,
    rfp.RutaArchivoFoto) RutaFotoPersona,
    t.AsuntoExpediente,
    t.NumeroFoliosExpediente,
    t.ObservacionesExpediente,
    t.Fecha,
    t.NombreExpediente,
    t.NombreCompletoCreador,
    t.NumeroExpediente,
    t.IdExpedienteSeguimiento,
    t.FechaMovimiento
from #tmp001_expediente t
inner join tramite.ExpedienteDocumento t2 on t2.IdExpediente = t.IdExpediente and t2.EstadoAuditoria = 1
inner join tramite.ExpedienteDocumentoOrigen t3 on t3.idExpedienteDocumento = t2.idExpedienteDocumento and t3.estadoAuditoria = 1
inner join tramite.ExpedienteDocumentoOrigenDestino t4
    on t4.idExpedienteDocumentoOrigen = t3.idExpedienteDocumentoOrigen and t4.estadoAuditoria = 1
cross apply(select datediff(day, cast(t3.FechaOrigen as date), getdate()) diasPass)dia
left join tramite.catalogo c3 on c3.IdCatalogo = t2.IdCatalogoTipoOrigen
left join tramite.catalogo c4 on c4.IdCatalogo = t2.IdCatalogoTipoDocumento
left join General.Persona pe on pe.IdPersona = t.IdPersonaCreador
outer apply(select max(1)over(partition by t.IdExpediente) doc from Tramite.ExpedienteDocumentoFirmante ef
    where ef.IdExpedienteDocumento = t2.IdExpedienteDocumento and ef.IdPersona = @pIdPersona and ef.EstadoAuditoria = 1)ef
outer apply(select distinct concat('<div style="margin: 2px;padding: 2px;" class="ui blue label">',
    t.NombreExpediente, '</div> ')ExEnlazadoPri
    from tramite.ExpedienteEnlazado ee where ee.IdExpedienteSecundario = t.IdExpediente and ee.EstadoAuditoria = 1)enp
outer apply(select distinct concat('<div style="margin: 2px;padding: 2px;" class="ui blue label">',
    t.NombreExpediente, '</div> ')ExEnlazadoSec
    from tramite.ExpedienteEnlazado ee where ee.IdExpediente = t.IdExpediente and ee.EstadoAuditoria = 1)ens
outer apply(select distinct t.IdExpediente, count(1)over(partition by ee.IdExpediente) cantEnlaces
    from tramite.ExpedienteEnlazado ee where ee.IdExpedienteSecundario = t.IdExpediente and ee.EstadoAuditoria = 1)ee
outer apply(select max(IdExpedienteSeguimiento)over(partition by t.IdExpediente) IdExpedienteSeguimiento
    from Tramite.ExpedienteSeguimiento es
    where es.IdExpediente = t.IdExpediente and
    es.IdEmpresa = @vIdEmpresa and
    es.IdArea = @vIdArea and
    es.IdCargo = @vIdCargo and
    es.IdPersona = @pIdPersona and
    es.EstadoAuditoria = 1
)es
outer apply(select max(a.NombreArea)over(partition by t.IdExpediente) NombreArea from General.Area a where a.IdArea = t3.IdAreaOrigen)a
outer apply(select max(rfp.RutaArchivoFoto)over(partition by t.IdExpediente) RutaArchivoFoto
    from Seguridad.Usuario rfp
    where rfp.IdPersona = pe.IdPersona and isnull(rfp.RutaArchivoFoto, '') != '' and rfp.EstadoAuditoria = 1 and rfp.Bloqueado = 0)rfp
outer apply(select sum(case when
    t4.EsInicial = 1 and
    t3.EsVinculado = 0 and
    t4.IdCatalogoSituacionMovimientoDestino != 4 and
    t4.FechaDestinoRecepciona = '' and
    t3.IdempresaOrigen = @vIdEmpresa and
    t3.IdAreaOrigen = @vIdArea and
    t3.IdCargoOrigen = @vIdCargo and
    t3.IdPersonaOrigen = @pIdPersona then 1 else 0 end
    )over(partition by t.IdExpediente) cant
)pa1
outer apply(select sum(case when
    t4.EsInicial = 1 and
    t3.EsVinculado = 0 and
    t4.FechaDestinoRecepciona = '' and
    t3.IdempresaOrigen = @vIdEmpresa and
    t3.IdAreaOrigen = @vIdArea and
    t3.IdCargoOrigen = @vIdCargo and
    t3.IdPersonaOrigen = @pIdPersona then 1 else 0 end
    )over(partition by t.IdExpediente) cant
)pa2
outer apply(select max(case when
    t4.IdCatalogoSituacionMovimientoDestino = @pIdCatalogoSituacionMovimientoDestino and
    t4.FechaDestinoRecepciona = '' and
    t4.IdEmpresaDestino = @vIdEmpresa and
    t4.IdAreaDestino = @vIdArea and
    t4.IdCargoDestino = @vIdCargo and
    t4.IdPersonaDestino = @pIdPersona then iif(dia.diasPass < 0 , 0, dia.diasPass) else 0 end
    )over(partition by t.IdExpediente) DiasPendiente
)dp
outer apply(select concat(max(case when
    t4.IdCatalogoSituacionMovimientoDestino in (4,5) and
    isnull(t3.IdempresaOrigen, 0) = 0 and
    t4.IdAreaDestino = @vIdArea and
    t4.IdCargoDestino = @vIdCargo and
    t4.IdPersonaDestino = @pIdPersona then t2.NombreCompletoEmisor else a.NombreArea end
    )over(partition by t.IdExpediente), '; ') NombrePersonaOrigen
)np
outer apply(select max(case when
    t4.IdCatalogoSituacionMovimientoDestino = @pIdCatalogoSituacionMovimientoDestino and
    t4.IdAreaDestino = @vIdArea and
    t4.IdCargoDestino = @vIdCargo and
    t4.IdPersonaDestino = @pIdPersona then t2.IdExpedienteDocumento end
    )over(partition by t.IdExpediente) IdExpedienteDocumento
)ied
outer apply(select max(case when
    t4.IdCatalogoSituacionMovimientoDestino = @pIdCatalogoSituacionMovimientoDestino and
    t4.IdAreaDestino = @vIdArea and
    t4.IdCargoDestino = @vIdCargo and
    t4.IdPersonaDestino = @pIdPersona then
        case when t2.FgEnEsperaFirmaDigital = 1 and ef.doc = 0 then
            concat('<label style="font-size:8px">',
            case t2.Correlativo when 0 then concat(c4.descripcion, ' ', t2.NumeroDocumento) else t2.NumeroDocumento end,
            '</label>')
        else
            concat('<button type="button" data-toggle="tooltip" title="',
            t4.MotivoArchivado, '" class="btn ui blue label" onclick="MostrarDocumentoPdfExp(''',
            t2.RutaArchivoDocumento, ''',', t2.IdExpedienteDocumento,
            ')"><i style="font-size:16px;" class="fa fa-file-text"></i></button><label style="font-size:8px">',
            case t2.Correlativo when 0 then concat(c4.descripcion, ' ', t2.NumeroDocumento) else t2.NumeroDocumento end,
            '</label>')
        end
    end)over(partition by t.IdExpediente) NumeroDocumento
)nd
order by row_number()over(partition by t.idExpediente order by t.FechaMovimiento desc)


select count(1) from #tmp001_matriz

end else begin
    select
		 0 EsParaAnular,
		 0 DiasPendiente,
		'' NombrePersonaOrigen,
		'' NumeroDocumento,
		0 IdExpedienteDocumento,
		'' NombreExpedientesEnlazados,
		0 EsPrincipalEnlace,
		'' CatalogoTipoOrigen,
		0 IdExpediente,
		'' ExpedienteConfidencial,
		'' NTFechaExpediente,
		'' HoraExpediente,
		0 IdCatalogoTipoPrioridad,
		'' CatalogoTipoPrioridad,
		'' CatalogoTipoTramite,
		'' ColorCatalogoTipoTramite,
		'' Logueo,
		'sinfotoH.jpg' RutaFotoPersona,
		'' AsuntoExpediente,
		0 NumeroFoliosExpediente,
		'' ObservacionesExpediente,
		'' Fecha,
		'' NombreExpediente,
		'' NombreCompletoCreador,
		'' NumeroExpediente,
		0 IdExpedienteSeguimiento,
		'' FechaMovimiento
	select 0
end

END TRY
BEGIN CATCH
		DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
		SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarExpedientePendienteEspecialistaPorRecibir',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
		EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE, @pIdUsuarioAuditoria
END CATCH
END
go
