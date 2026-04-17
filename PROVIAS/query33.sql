-- if exists(select 1 from sys.sysobjects where id = object_id('[Tramite].[paListarExpedientePendienteEspecialistaPorRecibir_new]','p'))
-- drop procedure [Tramite].[paListarExpedientePendienteEspecialistaPorRecibir_new]
-- go
-- CREATE PROCEDURE [Tramite].[paListarExpedientePendienteEspecialistaPorRecibir_new]
DECLARE
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
-- As
-- begin
-- begin try
set tran isolation level read uncommitted
set nocount on

SELECT
@pConFiltroFecha=0,
@pFechaInicio='13/04/2026',
@pFechaFin='13/04/2026',
@pConFiltroFechaMovimiento=0,
@pFechaInicioMovimiento='13/04/2026',
@pFechaFinMovimiento='13/04/2026',
@pIdPersona=590,
@pIdEmpleadoPerfil=588,
@pIdCatalogoSituacionMovimientoDestino=4,
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
@pIdUsuarioAuditoria=590,
@pCampoOrdenado=NULL,
@pTipoOrdenacion=NULL,
@pNumeroPagina=1,
@pDimensionPagina=100,
@pBusquedaGeneral=NULL,
@pFlgBusqueda=0



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
	FechaMovimiento datetime,
	IdCatalogoTipoOrigen int
)
create table #tmp001_matriz(
    IdExpediente int primary key,
    FechaMovimiento datetime
)
create table #tmp001_orden(
    item int identity,
    IdExpediente int
)

declare @vIdCargo int = 0, @vIdArea int = 0, @vIdEmpresa int = 2

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
    where t1.estadoAuditoria = 1 and t1.ExpedienteAnulado = 0 and
            t1.NumeroExpediente = isnull(@pBusquedaGeneral, t1.NumeroExpediente)
    order by row_number()over(partition by t1.IdExpediente order by t4.fechaCreacionAuditoria desc)

    SELECT
        t.idExpediente,
        x.IdCatalogoTipoOrigen
    INTO #tmp001_catologoTipoOrigen
    FROM #tmp001_matriz t
    CROSS APPLY (
        SELECT TOP 1
            ed.idExpedienteDocumento,
            ed.IdCatalogoTipoOrigen
        FROM tramite.ExpedienteDocumento ed
        WHERE ed.idExpediente = t.idExpediente
        ORDER BY ed.idExpedienteDocumento ASC
    ) x

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
        CONCAT(SD.AbreviaturaSerieDocumentalExpediente, RIGHT(1000000 + t.NumeroExpediente,6), '-', t.IdPeriodo) NombreExpediente,
        isnull(t.NombreCompletoCreador, pe.NombreCompleto) NombreCompletoCreador,
        t.NumeroExpediente,
        isnull(es.IdExpedienteSeguimiento, 0) IdExpedienteSeguimiento,
        t.NumeroExpedienteExterno,
        m.FechaMovimiento,
        tt.IdCatalogoTipoOrigen
    from  tramite.Expediente t
    inner join  #tmp001_matriz m  on m.idExpediente = t.idExpediente
    inner join Seguridad.Usuario su on su.IdUsuario = t.IdUsuarioCreacionAuditoria and su.EstadoAuditoria = 1
    inner join tmp001_serieDocumental sd on sd.IdSerieDocumentalExpediente = t.IdSerieDocumentalExpediente
    inner join #tmp001_catologoTipoOrigen tt on tt.idExpediente = t.idExpediente
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

	insert into #tmp001_orden
    select distinct idExpediente from #tmp001_expediente order by idExpediente desc



    select
    isnull(r.RutaArchivoFoto, iif(r.sexo = 0, 'sinfotoH.jpg', 'sinfotoM.jpg')) RutaFotoPersona,
    convert(bit, case when X.ExistePA1 = 1 then 0 when X.ExistePA2 = 1 then 1 else 0 end) EsParaAnular,
    t.*
    from #tmp001_expediente t
    outer apply(
        select top 1 nullif(u.RutaArchivoFoto, '') RutaArchivoFoto, p.sexo
        from Seguridad.Usuario u
        inner join general.persona p
            on p.IdPersona = u.IdPersona
        where p.IdPersona = t.IdPersonaCreador
            and u.EstadoAuditoria = 1
            and u.Bloqueado = 0
    )r
    CROSS APPLY (
        SELECT TOP 1
            MAX(CASE
                WHEN EDOD.IdCatalogoSituacionMovimientoDestino <> 4 THEN 1
                ELSE 0
            END) AS ExistePA1,
            max(1) AS ExistePA2
        FROM Tramite.ExpedienteDocumento ED
        INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO
            ON EDO.IdExpedienteDocumento = ED.IdExpedienteDocumento
            AND EDO.EstadoAuditoria = 1
        INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD
            ON EDOD.IdExpedienteDocumentoOrigen = EDO.IdExpedienteDocumentoOrigen
            AND EDOD.EstadoAuditoria = 1
        WHERE
            ED.IdExpediente = t.IdExpediente
            AND ED.EstadoAuditoria = 1
            AND EDOD.EsInicial = 1
            AND ED.EsVinculado = 0
            AND ISNULL(EDOD.FechaDestinoRecepciona,'') = ''
            AND EDO.IdPersonaOrigen = @pIdPersona
            AND EDO.IdAreaOrigen = @vIdArea
            AND EDO.IdCargoOrigen = @vIdCargo
            AND EDO.IdempresaOrigen = @vIdEmpresa
    ) X





    OUTER APPLY(
			SELECT
			top 1 CASE WHEN  COALESCE(EDOD.FechaDestinoRecepciona,'')='' THEN CASE
			WHEN DATEDIFF(DAY,CONVERT(DATE, EDO.FechaOrigen),GETDATE())<0 then 0
			ELSE DATEDIFF(DAY,CONVERT(DATE, EDO.FechaOrigen),GETDATE()) END ELSE 0 END DiasPendiente
			FROM Tramite.ExpedienteDocumento ED
			INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO
			    ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento
				AND ED.EstadoAuditoria=1
			INNER JOIN  Tramite.ExpedienteDocumentoOrigenDestino EDOD
			    ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen
				AND EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
			WHERE
			    ED.IdExpediente=E.IdExpediente
    			AND EDOD.IdCatalogoSituacionMovimientoDestino  =@pIdCatalogoSituacionMovimientoDestino
    			AND EDOD.IdCargoDestino =@vIdCargo
    			AND EDOD.IdEmpresaDestino=@vIdEmpresa
    			AND EDOD.IdAreaDestino=@vIdArea
    			AND EDOD.IdPersonaDestino=@pIdPersona
		) DP






-- select
--     EsParaAnular,
--     DiasPendiente,
--     NombrePersonaOrigen,
--     NumeroDocumento,
--     IdExpedienteDocumento,
--     NombreExpedientesEnlazados,
--     EsPrincipalEnlace,
--     CatalogoTipoOrigen,
--     IdExpediente,
--     ExpedienteConfidencial,
--     NTFechaExpediente,
--     HoraExpediente,
--     IdCatalogoTipoPrioridad,
--     CatalogoTipoPrioridad,
--     CatalogoTipoTramite,
--     ColorCatalogoTipoTramite,
--     Logueo,
--     RutaFotoPersona,
--     AsuntoExpediente,
--     NumeroFoliosExpediente,
--     ObservacionesExpediente,
--     Fecha,
--     NombreExpediente,
--     NombreCompletoCreador,
--     NumeroExpediente,
--     IdExpedienteSeguimiento,
--     FechaMovimiento
-- from(select *, row_number()over(partition by item order by item, IdExpedienteDocumento desc, NumeroDocumento desc) nro
-- from #tmp001_resultset)t where t.nro = 1 order by t.item

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

-- END TRY
-- BEGIN CATCH
-- 		DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
-- 		SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarExpedientePendienteEspecialistaPorRecibir',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
-- 		EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE, @pIdUsuarioAuditoria
-- END CATCH
-- END
-- go
